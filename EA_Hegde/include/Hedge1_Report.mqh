//+------------------------------------------------------------------+
//|                                             Hedge1_Report.mqh    |
//| รายงานกำไรขาดทุนเป็นไฟล์ .csv                                     |
//| - คำนวณรอบระยะเวลา (ค่าเริ่มต้น 5 วัน) เริ่มนับใหม่หลังสร้างไฟล์ |
//| - สร้างเมื่อครบกำหนด "และ" Basket ว่าง (order=0) เท่านั้น         |
//|   (เลยวันที่ 5 ไปเป็นวันที่ 6-8 ก็ได้ ถ้าไม้ยังไม่จบ)              |
//| - ชื่อไฟล์: คู่เงิน_Magic_วันที่_เวลา.csv                        |
//+------------------------------------------------------------------+
#ifndef HEDGE1_REPORT_MQH
#define HEDGE1_REPORT_MQH

#include "Hedge1_Inputs.mqh"
#include "Hedge1_Capital.mqh"
#include "Hedge1_Engine.mqh"
#include "Hedge1_Utils.mqh"

datetime g_reportLastFail = 0;   // เวลาที่สร้างไฟล์ล้มเหลวล่าสุด (พัก 60 วิ กันรัว)

//+------------------------------------------------------------------+
//| ชื่อตัวแปรถาวรเก็บวันเริ่มนับรอบรายงาน (กันหายเวลารีสตาร์ท)        |
//+------------------------------------------------------------------+
string ReportGVName()
  {
   return("HEDGE1_" + IntegerToString(InpMagicNumber) + "_RPD");
  }

//+------------------------------------------------------------------+
//| เริ่มระบบรายงาน (เรียกจาก OnInit) - ถ้ายังไม่เคยนับก็เริ่มนับวันนี้ |
//+------------------------------------------------------------------+
void ReportInit()
  {
   if(!GlobalVariableCheck(ReportGVName()))
      GlobalVariableSet(ReportGVName(), (double)TimeCurrent());
  }

//+------------------------------------------------------------------+
//| สร้างไฟล์ CSV สรุปรายวันของช่วงรายงาน                             |
//| คอลัมน์: Date, ClosedPL, ClosedTrades, TradedLots, PeriodCumNet   |
//+------------------------------------------------------------------+
bool GenerateReportCSV(datetime periodStart)
  {
   //--- สร้างชื่อไฟล์: คู่เงิน_Magic_วันที่_เวลา.csv
   string stamp = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES);
   StringReplace(stamp, ".", "");
   StringReplace(stamp, ":", "");
   StringReplace(stamp, " ", "_");
   string fname = _Symbol + "_" + IntegerToString(InpMagicNumber) + "_" + stamp + ".csv";

   int fh = FileOpen(fname, FILE_WRITE | FILE_CSV | FILE_ANSI, ',');
   if(fh == INVALID_HANDLE)
     {
      Print("Hedge1: สร้างไฟล์ CSV ล้มเหลว (", fname, ") error=", GetLastError());
      return(false);
     }
   FileWrite(fh, "Date", "ClosedPL", "ClosedTrades", "TradedLots", "PeriodCumNet");

   //--- อ่านประวัติการเทรดของบอทในช่วงรายงาน
   if(!HistorySelect(periodStart, TimeCurrent() + 60))
     {
      Print("Hedge1: HistorySelect สำหรับรายงานล้มเหลว error=", GetLastError());
      FileClose(fh);
      return(false);
     }

   string days[];    double pls[];    int trds[];    double lots[];
   int nd = 0;       // จำนวนวันที่มีการเทรด
   int total = HistoryDealsTotal();

   for(int i = 0; i < total; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0)
         continue;
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != InpMagicNumber)
         continue;
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol)
         continue;

      datetime t   = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      string day   = TimeToString(t, TIME_DATE);   // "2026.10.13"
      double pl     = HistoryDealGetDouble(ticket, DEAL_PROFIT)
                    + HistoryDealGetDouble(ticket, DEAL_SWAP)
                    + HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      double vol    = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      bool   isOut  = (HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT);

      //--- หา/สร้างกลุ่มของวันนั้น
      int idx = -1;
      for(int j = 0; j < nd; j++)
         if(days[j] == day)
           { idx = j; break; }
      if(idx < 0)
        {
         nd++;
         ArrayResize(days, nd);
         ArrayResize(pls, nd);
         ArrayResize(trds, nd);
         ArrayResize(lots, nd);
         idx = nd - 1;
         days[idx] = day;
         pls[idx]  = 0.0;
         trds[idx]  = 0;
         lots[idx]  = 0.0;
        }

      pls[idx] += pl;
      if(isOut)
        {
         trds[idx]++;
         lots[idx] += vol;
        }
     }

   //--- เขียนทีละวัน + รวมยอด
   double cum = 0.0, totPL = 0.0, totLot = 0.0;
   int totTrd = 0;
   for(int j = 0; j < nd; j++)
     {
      cum    += pls[j];
      totPL  += pls[j];
      totTrd += trds[j];
      totLot += lots[j];
      FileWrite(fh, days[j],
                DoubleToString(pls[j], 2),
                IntegerToString(trds[j]),
                DoubleToString(lots[j], 2),
                DoubleToString(cum, 2));
     }
   FileWrite(fh, "TOTAL",
             DoubleToString(totPL, 2),
             IntegerToString(totTrd),
             DoubleToString(totLot, 2),
             DoubleToString(cum, 2));
   FileClose(fh);

   Print("Hedge1: สร้างรายงาน CSV แล้ว -> MQL5\\Files\\", fname,
         " (สรุป ", nd, " วัน, สุทธิ ", FormatMoney(cum), ")");
   return(true);
  }

//+------------------------------------------------------------------+
//| ตรวจสร้างรายงานทุก Tick (เรียกจาก OnTick ของ EA หลัก)             |
//+------------------------------------------------------------------+
void ReportOnTick()
  {
   if(!InpEnableReport)
      return;

   //--- เงื่อนไขหลัก: ต้อง Basket ว่างก่อนถึงสร้างไฟล์ได้
   int total = CountSide(POSITION_TYPE_BUY) + CountSide(POSITION_TYPE_SELL);
   if(total > 0)
      return;

   //--- พัก 60 วินาที ถ้าสร้างไฟล์ล้มเหลว (เช่น ดิสก์ติด) กันลูปรัว
   if(g_reportLastFail > 0 && TimeCurrent() - g_reportLastFail < 60)
      return;

   datetime periodStart = GlobalVariableCheck(ReportGVName())
                           ? (datetime)GlobalVariableGet(ReportGVName()) : 0;
   if(periodStart == 0)
     {
      GlobalVariableSet(ReportGVName(), (double)TimeCurrent());
      return;
     }

   //--- ยังไม่ครบกำหนด (ค่าเริ่มต้น 5 วัน) ก็ยังไม่สร้าง
   if(TimeCurrent() - periodStart < (long)InpReportDays * 86400)
      return;

   if(GenerateReportCSV(periodStart))
      GlobalVariableSet(ReportGVName(), (double)TimeCurrent());   // เริ่มนับรอบใหม่ วนลูป
   else
      g_reportLastFail = TimeCurrent();
  }

#endif // HEDGE1_REPORT_MQH