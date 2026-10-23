//+------------------------------------------------------------------+
//|                                             Hedge1_Report.mqh    |
//| รายงานกำไรขาดทุนเป็นไฟล์ .csv                                     |
//| - คำนวณรอบระยะเวลา (ค่าเริ่มต้น 5 วัน) เริ่มนับใหม่หลังสร้างไฟล์ |
//| - สร้างเมื่อครบกำหนด "และ" Basket ว่าง (order=0) เท่านั้น         |
//|   (เลยวันที่ 5 ไปเป็นวันที่ 6-8 ก็ได้ ถ้าไม้ยังไม่จบ)              |
//| - ชื่อไฟล์: Symbol_Account_Magic_FROM_PeriodStart.csv             |
//+------------------------------------------------------------------+
#ifndef HEDGE1_REPORT_MQH
#define HEDGE1_REPORT_MQH

#include "Hedge1_Inputs.mqh"
#include "Hedge1_Capital.mqh"
#include "Hedge1_Engine.mqh"
#include "Hedge1_Utils.mqh"

datetime g_reportLastFail = 0;   // เวลาที่ Report ล้มเหลวล่าสุด
datetime g_reportCompletedAt = 0; // สร้าง CSV แล้ว แต่ยังรอบันทึกขอบเขตรอบใหม่
ulong    g_reportEmptyTick = 0;   // GetTickCount64() ตอนเห็น Basket ว่างครั้งแรก

//+------------------------------------------------------------------+
//| ชื่อตัวแปรถาวรเก็บวันเริ่มนับรอบรายงาน (กันหายเวลารีสตาร์ท)        |
//+------------------------------------------------------------------+
string ReportGVName()
  {
   return(HedgeStateGVName("RPD"));
  }

//+------------------------------------------------------------------+
//| เริ่มระบบรายงาน (เรียกจาก OnInit) - ถ้ายังไม่เคยนับก็เริ่มนับวันนี้ |
//+------------------------------------------------------------------+
void ReportInit()
  {
   g_reportBlocksEntry = false;
   g_reportLastFail = 0;
   g_reportCompletedAt = 0;
   g_reportEmptyTick = 0;

   if(!InpEnableReport)
      return;

   string name = ReportGVName();

   if(!GlobalVariableCheck(name))
     {
      ResetLastError();

      if(GlobalVariableSet(name, (double)TimeCurrent()) == 0)
        {
         g_reportBlocksEntry = true;
         g_reportLastFail = TimeCurrent();

         Print("Hedge1: เริ่ม Report State ไม่สำเร็จ",
               " | error=", GetLastError());
         return;
        }

      GlobalVariablesFlush();
     }

   double savedStart = 0.0;

   if(!GlobalVariableGet(name, savedStart)
      || !MathIsValidNumber(savedStart)
      || savedStart <= 0.0)
     {
      g_reportBlocksEntry = true;
      Print("Hedge1: Report State อ่านไม่ได้หรือไม่ถูกต้อง");
      return;
     }

   datetime periodStart = (datetime)savedStart;

   g_reportBlocksEntry =
      (TimeCurrent() - periodStart
       >= (long)InpReportDays * 86400);
  }

//+------------------------------------------------------------------+
//| สร้างไฟล์ CSV สรุปรายวันของช่วงรายงาน                             |
//| คอลัมน์: Date, ClosedPL, ClosedTrades, TradedLots, PeriodCumNet   |
//+------------------------------------------------------------------+
bool ReportWriteRow(int fh,
                    string a,
                    string b,
                    string c,
                    string d,
                    string e,
                    ulong &expectedBytes)
  {
   //--- ทุก field ที่ใช้ในรายงานนี้เป็น ASCII
   //--- 5 fields = 4 commas + CR/LF อีก 2 bytes
   uint expected = (uint)(StringLen(a)
                          + StringLen(b)
                          + StringLen(c)
                          + StringLen(d)
                          + StringLen(e)
                          + 6);

   ResetLastError();

   uint written = FileWrite(fh, a, b, c, d, e);
   int error = GetLastError();

   if(error != 0 || written != expected)
     {
      Print("Hedge1: CSV WRITE FAILED",
            " | Row=", a,
            " | Bytes=", written,
            " / Expected=", expected,
            " | error=", error);
      return(false);
     }

   expectedBytes += (ulong)written;
   return(true);
  }

void ReportAbortTemp(int fh, string tempName, string stage)
  {
   Print("Hedge1: CSV ABORT",
         " | Stage=", stage,
         " | error=", GetLastError());

   if(fh != INVALID_HANDLE)
      FileClose(fh);

   if(FileIsExist(tempName))
     {
      if(!FileDelete(tempName))
         Print("Hedge1: ลบไฟล์ชั่วคราวไม่สำเร็จ",
               " | File=", tempName,
               " | error=", GetLastError());
     }
  }

bool ReportReadRow(int fh, string &fields[])
  {
   if(ArrayResize(fields, 5) != 5)
      return(false);

   for(int i = 0; i < 5; i++)
     {
      if(FileIsEnding(fh))
         return(false);

      if(i > 0 && FileIsLineEnding(fh))
         return(false);

      ResetLastError();
      fields[i] = FileReadString(fh);

      if(GetLastError() != 0)
         return(false);
     }

   //--- ต้องมี 5 fields เท่านั้น
   return(FileIsLineEnding(fh) || FileIsEnding(fh));
  }

bool ReportReadCompletion(string fname,
                          datetime periodStart,
                          datetime &savedEnd)
  {
   savedEnd = 0;

   int fh = FileOpen(fname, FILE_READ | FILE_CSV | FILE_ANSI, ',');

   if(fh == INVALID_HANDLE)
      return(false);

   string fields[];
   string expectedHeader[] =
     {"Date", "ClosedPL", "ClosedTrades", "TradedLots", "PeriodCumNet"};

   if(!ReportReadRow(fh, fields))
     {
      FileClose(fh);
      return(false);
     }

   for(int i = 0; i < 5; i++)
     {
      if(fields[i] != expectedHeader[i])
        {
         FileClose(fh);
         return(false);
        }
     }

   bool sawTotal = false;

   while(!FileIsEnding(fh))
     {
      if(!ReportReadRow(fh, fields))
        {
         FileClose(fh);
         return(false);
        }

      if(fields[0] == "TOTAL")
        {
         if(sawTotal)
           {
            FileClose(fh);
            return(false);
           }

         sawTotal = true;
         continue;
        }

      if(fields[0] == "REPORT_COMPLETE")
        {
         long endValue = StringToInteger(fields[2]);

         bool valid =
            sawTotal
            && fields[1] == IntegerToString((long)periodStart)
            && fields[2] == IntegerToString(endValue)
            && endValue > (long)periodStart
            && endValue <= (long)TimeCurrent()
            && fields[3] ==
               IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))
            && fields[4] == IntegerToString(InpMagicNumber)
            && FileIsEnding(fh);

         FileClose(fh);

         if(!valid)
            return(false);

         savedEnd = (datetime)endValue;
         return(true);
        }

      //--- หลัง TOTAL ต้องเป็น Completion Marker เท่านั้น
      if(sawTotal)
        {
         FileClose(fh);
         return(false);
        }

      //--- แถวข้อมูลรายวันต้องมีรูปแบบวันที่ YYYY.MM.DD
      if(StringLen(fields[0]) != 10
         || StringSubstr(fields[0], 4, 1) != "."
         || StringSubstr(fields[0], 7, 1) != ".")
        {
         FileClose(fh);
         return(false);
        }
     }

   FileClose(fh);
   return(false);
  }

//+------------------------------------------------------------------+
//| เวลาของดีลล่าสุดของ Magic/Symbol นี้ตั้งแต่ต้นรอบรายงาน             |
//| คืน false ถ้าอ่าน History ไม่สำเร็จ (ผู้เรียกต้องรอแล้วลองใหม่)       |
//+------------------------------------------------------------------+
bool ReportLastDealTime(datetime periodStart, datetime &lastDeal)
  {
   lastDeal = 0;

   if(!HistorySelect(periodStart, TimeCurrent() + 86400))
      return(false);

   int total = HistoryDealsTotal();

   for(int i = 0; i < total; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);

      if(ticket == 0)
         return(false);

      long magic = 0;
      string symbol = "";
      long timeValue = 0;

      if(!HistoryDealGetInteger(ticket, DEAL_MAGIC, magic)
         || !HistoryDealGetString(ticket, DEAL_SYMBOL, symbol)
         || !HistoryDealGetInteger(ticket, DEAL_TIME, timeValue))
         return(false);

      if(magic != InpMagicNumber || symbol != _Symbol)
         continue;

      if((datetime)timeValue > lastDeal)
         lastDeal = (datetime)timeValue;
     }

   return(true);
  }

bool GenerateReportCSV(datetime periodStart, datetime &periodEnd)
  {
   if(periodStart <= 0 || periodEnd <= periodStart)
      return(false);

   //--- ชื่อคงเดิมสำหรับรอบเดียวกัน เพื่อกู้หลัง Restart
   string stamp = TimeToString(periodStart, TIME_DATE | TIME_SECONDS);
   StringReplace(stamp, ".", "");
   StringReplace(stamp, ":", "");
   StringReplace(stamp, " ", "_");

   string fname = _Symbol
                  + "_"
                  + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))
                  + "_"
                  + IntegerToString(InpMagicNumber)
                  + "_FROM_"
                  + stamp
                  + ".csv";

   //--- ถ้า CSV รอบนี้มีอยู่แล้ว ต้องตรวจ Completion ก่อนใช้
   if(FileIsExist(fname))
     {
      datetime savedEnd = 0;

      if(!ReportReadCompletion(fname, periodStart, savedEnd))
        {
         Print("Hedge1: REPORT EXISTS BUT INVALID",
               " | File=", fname,
               " | ไม่เขียนทับไฟล์เดิม");
         return(false);
        }

      //--- ส่ง End เดิมกลับให้ ReportOnTick บันทึก RPD
      periodEnd = savedEnd;

      Print("Hedge1: Recover Completed Report",
            " | File=", fname,
            " | End=",
            TimeToString(savedEnd, TIME_DATE | TIME_SECONDS));

      return(true);
     }

   //--- อ่านข้อมูลให้สำเร็จก่อนสร้างไฟล์ชั่วคราว
   if(!HistorySelect(periodStart, periodEnd))
     {
      Print("Hedge1: HistorySelect สำหรับรายงานล้มเหลว",
            " | error=", GetLastError());
      return(false);
     }

   string days[];
   double pls[];
   int trds[];
   double lots[];

   int nd = 0;
   int total = HistoryDealsTotal();

   for(int i = 0; i < total; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);

      if(ticket == 0)
        {
         Print("Hedge1: อ่าน Report Deal ไม่สำเร็จ",
               " | index=", i);
         return(false);
        }

      long magic = 0;
      string symbol = "";

      if(!HistoryDealGetInteger(ticket, DEAL_MAGIC, magic)
         || !HistoryDealGetString(ticket, DEAL_SYMBOL, symbol))
        {
         Print("Hedge1: อ่าน Report Deal Identity ไม่สำเร็จ",
               " | Deal=", ticket);
         return(false);
        }

      if(magic != InpMagicNumber || symbol != _Symbol)
         continue;

      long timeValue = 0;
      long entryValue = 0;

      if(!HistoryDealGetInteger(ticket, DEAL_TIME, timeValue))
         return(false);

      datetime t = (datetime)timeValue;

      //--- ช่วงรายงานไม่ทับกัน: [Start, End)
      if(t < periodStart || t >= periodEnd)
         continue;

      double profit = 0.0;
      double swap = 0.0;
      double commission = 0.0;
      double vol = 0.0;

      if(!HistoryDealGetDouble(ticket, DEAL_PROFIT, profit)
         || !HistoryDealGetDouble(ticket, DEAL_SWAP, swap)
         || !HistoryDealGetDouble(ticket, DEAL_COMMISSION, commission)
         || !HistoryDealGetDouble(ticket, DEAL_VOLUME, vol)
         || !HistoryDealGetInteger(ticket, DEAL_ENTRY, entryValue))
        {
         Print("Hedge1: อ่าน Report Deal Values ไม่สำเร็จ",
               " | Deal=", ticket);
         return(false);
        }

      double pl = profit + swap + commission;

      if(!MathIsValidNumber(pl)
         || !MathIsValidNumber(vol)
         || vol < 0.0)
         return(false);

      string day = TimeToString(t, TIME_DATE);

      bool isOut =
         (entryValue == DEAL_ENTRY_OUT
          || entryValue == DEAL_ENTRY_OUT_BY);

      int idx = -1;

      for(int j = 0; j < nd; j++)
         if(days[j] == day)
           {
            idx = j;
            break;
           }

      if(idx < 0)
        {
         int newSize = nd + 1;

         if(ArrayResize(days, newSize) != newSize
            || ArrayResize(pls, newSize) != newSize
            || ArrayResize(trds, newSize) != newSize
            || ArrayResize(lots, newSize) != newSize)
           {
            Print("Hedge1: จัดสรรข้อมูล Report ไม่สำเร็จ");
            return(false);
           }

         idx = nd;
         nd = newSize;

         days[idx] = day;
         pls[idx] = 0.0;
         trds[idx] = 0;
         lots[idx] = 0.0;
        }

      pls[idx] += pl;

      if(isOut)
        {
         trds[idx]++;
         lots[idx] += vol;
        }

      if(!MathIsValidNumber(pls[idx])
         || !MathIsValidNumber(lots[idx]))
         return(false);
     }

   //--- เรียงวันก่อนคำนวณยอดสะสม
   for(int i = 0; i < nd - 1; i++)
      for(int j = i + 1; j < nd; j++)
         if(StringCompare(days[i], days[j]) > 0)
           {
            string daySwap = days[i];
            days[i] = days[j];
            days[j] = daySwap;

            double plSwap = pls[i];
            pls[i] = pls[j];
            pls[j] = plSwap;

            int tradeSwap = trds[i];
            trds[i] = trds[j];
            trds[j] = tradeSwap;

            double lotSwap = lots[i];
            lots[i] = lots[j];
            lots[j] = lotSwap;
           }

   string tempName = fname
                     + "."
                     + IntegerToString(ChartID())
                     + ".tmp";

   int fh = FileOpen(tempName,
                     FILE_WRITE | FILE_CSV | FILE_ANSI,
                     ',');

   if(fh == INVALID_HANDLE)
     {
      Print("Hedge1: สร้าง Report Temp ไม่สำเร็จ",
            " | File=", tempName,
            " | error=", GetLastError());
      return(false);
     }

   ulong expectedBytes = 0;

   if(!ReportWriteRow(fh,
                      "Date",
                      "ClosedPL",
                      "ClosedTrades",
                      "TradedLots",
                      "PeriodCumNet",
                      expectedBytes))
     {
      ReportAbortTemp(fh, tempName, "HEADER");
      return(false);
     }

   double cum = 0.0;
   double totPL = 0.0;
   double totLot = 0.0;
   int totTrd = 0;

   for(int j = 0; j < nd; j++)
     {
      cum += pls[j];
      totPL += pls[j];
      totTrd += trds[j];
      totLot += lots[j];

      if(!MathIsValidNumber(cum)
         || !MathIsValidNumber(totPL)
         || !MathIsValidNumber(totLot))
        {
         ReportAbortTemp(fh, tempName, "TOTAL_VALUES");
         return(false);
        }

      if(!ReportWriteRow(fh,
                         days[j],
                         DoubleToString(pls[j], 2),
                         IntegerToString(trds[j]),
                         DoubleToString(lots[j], 8),
                         DoubleToString(cum, 2),
                         expectedBytes))
        {
         ReportAbortTemp(fh, tempName, "DAILY_ROW");
         return(false);
        }
     }

   if(!ReportWriteRow(fh,
                      "TOTAL",
                      DoubleToString(totPL, 2),
                      IntegerToString(totTrd),
                      DoubleToString(totLot, 8),
                      DoubleToString(cum, 2),
                      expectedBytes))
     {
      ReportAbortTemp(fh, tempName, "TOTAL_ROW");
      return(false);
     }

   if(!ReportWriteRow(fh,
                      "REPORT_COMPLETE",
                      IntegerToString((long)periodStart),
                      IntegerToString((long)periodEnd),
                      IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)),
                      IntegerToString(InpMagicNumber),
                      expectedBytes))
     {
      ReportAbortTemp(fh, tempName, "COMPLETION_ROW");
      return(false);
     }

   ResetLastError();
   FileFlush(fh);

   if(GetLastError() != 0)
     {
      ReportAbortTemp(fh, tempName, "FLUSH");
      return(false);
     }

   ResetLastError();
   ulong actualBytes = FileSize(fh);
   int sizeError = GetLastError();

   if(sizeError != 0 || actualBytes != expectedBytes)
     {
      Print("Hedge1: CSV SIZE CHECK FAILED",
            " | Actual=", actualBytes,
            " | Expected=", expectedBytes);

      ReportAbortTemp(fh, tempName, "FILE_SIZE");
      return(false);
     }

   ResetLastError();
   FileClose(fh);

   if(GetLastError() != 0)
     {
      Print("Hedge1: CSV CLOSE FAILED",
            " | Temp=", tempName,
            " | error=", GetLastError());
      return(false);
     }

   //--- ไม่ใช้ FILE_REWRITE เพื่อไม่เขียนทับปลายทาง
   ResetLastError();

   if(!FileMove(tempName, 0, fname, 0))
     {
      Print("Hedge1: CSV PUBLISH FAILED",
            " | Temp=", tempName,
            " | Final=", fname,
            " | error=", GetLastError());
      return(false);
     }

   datetime verifiedEnd = 0;

   if(!ReportReadCompletion(fname, periodStart, verifiedEnd)
      || verifiedEnd != periodEnd)
     {
      Print("Hedge1: CSV COMPLETION CHECK FAILED",
            " | File=", fname);
      return(false);
     }

   Print("Hedge1: CSV COMPLETE",
         " | File=", fname,
         " | Days=", nd,
         " | Net=", FormatMoney(cum));

   return(true);
  }

//+------------------------------------------------------------------+
//| ตรวจสร้างรายงานทุก Tick (เรียกจาก OnTick ของ EA หลัก)             |
//+------------------------------------------------------------------+
void ReportOnTick()
  {
   g_reportBlocksEntry = false;

   if(!InpEnableReport)
      return;

   int total = CountSide(POSITION_TYPE_BUY)
               + CountSide(POSITION_TYPE_SELL);

   //--- Basket ยังไม่ว่าง: ให้ Protection จัดการต่อ
   if(total > 0)
     {
      g_reportEmptyTick = 0;
      return;
     }

   datetime now = TimeCurrent();
   string name = ReportGVName();

   //--- ยังไม่มี State: ต้องสร้างให้สำเร็จก่อนเปิดรอบใหม่
   if(!GlobalVariableCheck(name))
     {
      g_reportBlocksEntry = true;

      if(g_reportLastFail > 0
         && now >= g_reportLastFail
         && now - g_reportLastFail < 60)
         return;

      ResetLastError();

      if(GlobalVariableSet(name, (double)now) == 0)
        {
         g_reportLastFail = now;

         Print("Hedge1: สร้าง Report State ไม่สำเร็จ",
               " | error=", GetLastError());
         return;
        }

      GlobalVariablesFlush();

      g_reportLastFail = 0;
      g_reportBlocksEntry = false;
      return;
     }

   double savedStart = 0.0;

   if(!GlobalVariableGet(name, savedStart)
      || !MathIsValidNumber(savedStart)
      || savedStart <= 0.0)
     {
      g_reportBlocksEntry = true;

      if(g_reportLastFail == 0
         || now < g_reportLastFail
         || now - g_reportLastFail >= 60)
        {
         g_reportLastFail = now;
         Print("Hedge1: Report State อ่านไม่ได้หรือไม่ถูกต้อง");
        }

      return;
     }

   datetime periodStart = (datetime)savedStart;

   //--- ไม่มี CSV ค้างบันทึก และยังไม่ครบกำหนด
   if(g_reportCompletedAt == 0
      && now - periodStart < (long)InpReportDays * 86400)
      return;

   g_reportBlocksEntry = true;

   //--- พักก่อน retry แต่ยังคง Block Entry
   if(g_reportLastFail > 0
      && now >= g_reportLastFail
      && now - g_reportLastFail < 60)
      return;

   if(g_reportCompletedAt == 0)
     {
      //--- รอให้ Basket ว่างนิ่งอย่างน้อย 2 วินาที เพื่อให้ History รับดีลสุดท้ายครบ
      if(g_reportEmptyTick == 0)
         g_reportEmptyTick = GetTickCount64();

      if(GetTickCount64() - g_reportEmptyTick < 2000)
         return;

      datetime periodEnd = now;

      //--- ปลายช่วงต้องเลยเวลาดีลสุดท้าย ไม่เช่นนั้นดีลนั้นถูกตัดทิ้งโดย t >= periodEnd
      datetime lastDeal = 0;

      if(!ReportLastDealTime(periodStart, lastDeal))
         return;

      if(periodEnd <= lastDeal)
         return;

      if(periodEnd <= periodStart)
        {
         g_reportLastFail = now;
         Print("Hedge1: Report Period ไม่ถูกต้อง");
         return;
        }

      if(!GenerateReportCSV(periodStart, periodEnd))
        {
         g_reportLastFail = now;
         return;
        }

      g_reportCompletedAt = periodEnd;
     }

   //--- หาก CSV สร้างแล้ว ให้ retry เฉพาะการบันทึก State
   ResetLastError();

   if(GlobalVariableSet(name, (double)g_reportCompletedAt) == 0)
     {
      g_reportLastFail = now;

      Print("Hedge1: CSV สร้างแล้ว แต่บันทึกรอบใหม่ไม่สำเร็จ",
            " | error=", GetLastError());
      return;
     }

   GlobalVariablesFlush();

   g_reportCompletedAt = 0;
   g_reportLastFail = 0;
   g_reportBlocksEntry = false;
   g_reportEmptyTick = 0;

   Print("Hedge1: Report Cycle COMPLETE | Entry unlocked");
  }

#endif // HEDGE1_REPORT_MQH