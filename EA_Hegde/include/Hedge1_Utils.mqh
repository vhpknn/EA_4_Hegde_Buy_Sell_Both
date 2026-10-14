//+------------------------------------------------------------------+
//|                                              Hedge1_Utils.mqh    |
//|  ไม้บรรทัดกลาง: หน่วย Point ตามทศนิยม Broker + สเปรด            |
//|  + ตัวช่วยแปลงค่า/จัดรูปแบบข้อความสำหรับทุกโมดูล                 |
//+------------------------------------------------------------------+
#ifndef HEDGE1_UTILS_MQH
#define HEDGE1_UTILS_MQH

#include "Hedge1_Inputs.mqh"

//--- State เงิน/รายงานไม่ผูก Point Digits เพราะไม่ได้เก็บระยะราคา
string HedgeStateGVName(string suffix)
  {
   return("H1S_"
          + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))
          + "_"
          + _Symbol
          + "_"
          + IntegerToString(InpMagicNumber)
          + "_"
          + suffix);
  }

bool HedgeStateInit()
  {
   string suffixes[] = {"REFILL", "RPD", "RNET"};

   //--- ตรวจความยาวทุก Key ก่อนเริ่มระบบ
   for(int i = 0; i < ArraySize(suffixes); i++)
     {
      string name = HedgeStateGVName(suffixes[i]);

      if(StringLen(name) > 63)
        {
         Alert("Hedge1: State Key ยาวเกิน 63 ตัวอักษร: ", name);
         return(false);
        }
     }

   //--- การนำเข้า State เก่าอนุญาตเฉพาะ Basket ของ EA ว่าง
   if(InpStateImportLegacy)
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);

         if(ticket == 0)
            continue;

         if(PositionGetString(POSITION_SYMBOL) == _Symbol
            && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
           {
            Alert("Hedge1: Legacy State Import ต้องทำเมื่อ Basket ว่าง");
            return(false);
           }
        }
     }

   bool copiedAny = false;

   for(int i = 0; i < ArraySize(suffixes); i++)
     {
      string newName = HedgeStateGVName(suffixes[i]);
      string sourceName = newName;
      bool importing = false;

      if(!GlobalVariableCheck(newName))
        {
         if(!InpStateImportLegacy)
            continue;

         sourceName = "HEDGE1_"
                      + IntegerToString(InpMagicNumber)
                      + "_"
                      + suffixes[i];

         if(!GlobalVariableCheck(sourceName))
            continue;

         importing = true;
        }

      double value = 0.0;

      if(!GlobalVariableGet(sourceName, value)
         || !MathIsValidNumber(value))
        {
         Alert("Hedge1: อ่าน State ไม่สำเร็จหรือค่าไม่ถูกต้อง: ",
               sourceName);
         return(false);
        }

      //--- REFILL ต้องไม่ติดลบ
      if(suffixes[i] == "REFILL" && value < 0.0)
        {
         Alert("Hedge1: REFILL State ต้องไม่ติดลบ");
         return(false);
        }

      //--- วันเริ่มรอบรายงานต้องมากกว่า 0
      if(suffixes[i] == "RPD" && value <= 0.0)
        {
         Alert("Hedge1: Report State ไม่ถูกต้อง");
         return(false);
        }

      //--- RNET เป็นยอดสุทธิ จึงติดลบได้
      //--- ฐาน Cycle ใหม่ถูกกำหนดโดย Engine ก่อนส่ง Order
      if(!importing)
         continue;

      ResetLastError();

      if(GlobalVariableSet(newName, value) == 0)
        {
         Alert("Hedge1: นำเข้า State ไม่สำเร็จ: ",
               newName, " error=", GetLastError());
         return(false);
        }

      copiedAny = true;

      Print("Hedge1: Migrate State ", suffixes[i],
            " | Account=", AccountInfoInteger(ACCOUNT_LOGIN),
            " | Symbol=", _Symbol,
            " | Value=", DoubleToString(value, 2));
     }

   if(copiedAny)
      GlobalVariablesFlush();

   return(true);
  }

//+------------------------------------------------------------------+
//| ขนาด 1 Point ตามทศนิยมที่ผู้ใช้กำหนด (InpPointDigits)             |
//| เช่น ตั้ง 2 ตำแหน่ง = 1 Point เท่ากับ 0.01 (ราคาทอง)             |
//| ทำให้ "1000 Points" หมายถึงราคาเคลื่อน $10.00 เสมอ               |
//| ไม่สนว่าโบรกเกอร์ quote กี่หลัก                                  |
//+------------------------------------------------------------------+
double HedgePoint()
  {
   int digits = InpPointDigits;
   if(digits < 0)
      digits = 0;
   if(digits > 8)
      digits = 8;
   return(MathPow(10.0, -digits));
  }

//+------------------------------------------------------------------+
//| แปลงจำนวน Points เป็นระยะราคา (เช่น 1000 pts -> 10.00)           |
//+------------------------------------------------------------------+
double PointsToPrice(double points)
  {
   return(points * HedgePoint());
  }

//+------------------------------------------------------------------+
//| แปลงระยะราคาเป็นจำนวน Points (เช่น 10.00 -> 1000 pts)             |
//+------------------------------------------------------------------+
double PriceToPoints(double priceDiff)
  {
   double pt = HedgePoint();
   if(pt <= 0.0)
      return(0.0);
   return(priceDiff / pt);
  }

//+------------------------------------------------------------------+
//| สเปรดปัจจุบันเป็น Points (ตามหน่วยของ InpPointDigits)            |
//| Panel ใช้แสดง เช่น "45 / Trigger 25"                             |
//+------------------------------------------------------------------+
double GetSpreadPoints()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ask <= 0.0 || bid <= 0.0)
     {
      Print("Hedge1: อ่านราคา Ask/Bid ไม่ได้ error=", GetLastError());
      return(999999.0);   // ค่าสูงสุด = ไม่อนุญาตให้เปิดไม้ กันเปิดตอนราคาพัง
     }
   return(PriceToPoints(ask - bid));
  }

//+------------------------------------------------------------------+
//| จัดรูปแบบเงินสำหรับ Panel เช่น +$197.58 / -$75.07                 |
//+------------------------------------------------------------------+
string FormatMoney(double v)
  {
   string sign = (v >= 0.0) ? "+" : "-";
   double a = MathAbs(v);
   return(sign + "$" + DoubleToString(a, 2));
  }

//+------------------------------------------------------------------+
//| จัดรูปแบบ Points สำหรับ Panel เช่น 1000 pts / 0.04                 |
//+------------------------------------------------------------------+
string FormatPoints(double pts)
  {
   return(DoubleToString(pts, 0) + " pts");
  }

#endif // HEDGE1_UTILS_MQH