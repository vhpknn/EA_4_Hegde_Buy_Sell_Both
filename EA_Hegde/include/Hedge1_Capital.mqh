//+------------------------------------------------------------------+
//|                                             Hedge1_Capital.mqh   |
//|  Virtual Capital + สูตรบันได Lot + REFILL + หยุดเมื่อทุนหมด      |
//+------------------------------------------------------------------+
#ifndef HEDGE1_CAPITAL_MQH
#define HEDGE1_CAPITAL_MQH

#include "Hedge1_Inputs.mqh"
#include "Hedge1_Utils.mqh"

//--- ชื่อตัวแปรถาวรของ Terminal ใช้เก็บยอด REFILL สะสม (กันหายเวลารีสตาร์ท EA)
string RefillGVName()
  {
   return(HedgeStateGVName("REFILL"));
  }

//+------------------------------------------------------------------+
//| กำไรขาดทุนสุทธิที่ปิดไปแล้ว (นับจากประวัติตาม Magic + คู่เงิน)     |
//| นับทุกดีลของบอทนี้ รวมค่าคอมมิชชั่น/สวอปฝั่งเปิดด้วย              |
//| เพื่อให้ยอด Virtual Equity ตรงกับเน็ตจริงที่เกิดกับบัญชี           |
//+------------------------------------------------------------------+
bool TryGetClosedNet(double &net)
  {
   net = 0.0;

   if(!HistorySelect(0, TimeCurrent() + 60))
     {
      Print("Hedge1: HistorySelect ล้มเหลว error=",
            GetLastError());
      return(false);
     }

   int total = HistoryDealsTotal();

   for(int i = 0; i < total; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);

      if(ticket == 0)
        {
         Print("Hedge1: อ่าน History Deal ไม่สำเร็จ",
               " | index=", i,
               " | error=", GetLastError());
         net = 0.0;
         return(false);
        }

      if(HistoryDealGetInteger(ticket, DEAL_MAGIC)
         != InpMagicNumber)
         continue;

      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol)
         continue;

      net += HistoryDealGetDouble(ticket, DEAL_PROFIT)
           + HistoryDealGetDouble(ticket, DEAL_SWAP)
           + HistoryDealGetDouble(ticket, DEAL_COMMISSION);
     }

   if(!MathIsValidNumber(net))
     {
      Print("Hedge1: Closed Net ไม่ถูกต้อง");
      net = 0.0;
      return(false);
     }

   return(true);
  }

double GetClosedNet()
  {
   double net = 0.0;

   if(!TryGetClosedNet(net))
      return(0.0);

   return(net);
  }

//+------------------------------------------------------------------+
//| ยอด REFILL สะสมทั้งหมด (อ่านจาก Terminal Global Variable)         |
//+------------------------------------------------------------------+
bool TryGetTotalRefill(double &total)
  {
   total = 0.0;
   string name = RefillGVName();

   //--- ไม่มี Key หมายถึงยังไม่มียอด REFILL
   if(!GlobalVariableCheck(name))
      return(true);

   if(!GlobalVariableGet(name, total)
      || !MathIsValidNumber(total)
      || total < 0.0)
     {
      Print("Hedge1: REFILL State อ่านไม่ได้หรือไม่ถูกต้อง");
      total = 0.0;
      return(false);
     }

   return(true);
  }

double GetTotalRefill()
  {
   double total = 0.0;

   if(!TryGetTotalRefill(total))
      return(0.0);

   return(total);
  }

//+------------------------------------------------------------------+
//| กดปุ่ม REFILL หนึ่งครั้ง = เติมทุนเสมือนตามค่า InpRefillAmount     |
//+------------------------------------------------------------------+
bool AddRefill()
  {
   double previous = 0.0;

   if(!TryGetTotalRefill(previous))
     {
      Print("Hedge1: REFILL FAILED",
            " | Existing state unavailable");
      return(false);
     }

   if(!MathIsValidNumber(InpRefillAmount)
      || InpRefillAmount <= 0.0)
     {
      Print("Hedge1: REFILL FAILED",
            " | Invalid refill amount");
      return(false);
     }

   double total = previous + InpRefillAmount;

   if(!MathIsValidNumber(total) || total < 0.0)
     {
      Print("Hedge1: REFILL FAILED",
            " | Invalid total");
      return(false);
     }

   ResetLastError();

   if(GlobalVariableSet(RefillGVName(), total) == 0)
     {
      Print("Hedge1: REFILL FAILED",
            " | Save error=", GetLastError());
      return(false);
     }

   GlobalVariablesFlush();

   return(true);
  }

//+------------------------------------------------------------------+
//| ทุนเสมือนปัจจุบัน = ทุนเริ่มต้น + REFILL สะสม + กำไรขาดทุนที่ปิดแล้ว|
//| (ไม่รวมกำไรลอยตัว ตรงกับตัวเลขบน Panel ตาม Blueprint)             |
//+------------------------------------------------------------------+
bool TryGetVirtualEquity(double &equity)
  {
   equity = 0.0;

   double refill = 0.0;
   double closedNet = 0.0;

   if(!TryGetTotalRefill(refill))
      return(false);

   if(!TryGetClosedNet(closedNet))
      return(false);

   equity = InpInitialCapital + refill + closedNet;

   if(!MathIsValidNumber(equity))
     {
      Print("Hedge1: Virtual Equity ไม่ถูกต้อง");
      equity = 0.0;
      return(false);
     }

   return(true);
  }

double GetVirtualEquity()
  {
   double equity = 0.0;

   if(!TryGetVirtualEquity(equity))
      return(0.0);

   return(equity);
  }

//+------------------------------------------------------------------+
//| ปรับขนาด Lot ให้อยู่ในกฎของโบรกเกอร์ (min / max / step)            |
//+------------------------------------------------------------------+
double NormalizeVolume(double lot)
  {
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(!MathIsValidNumber(lot)
      || !MathIsValidNumber(minLot)
      || !MathIsValidNumber(maxLot)
      || !MathIsValidNumber(step)
      || lot <= 0.0
      || minLot <= 0.0
      || maxLot < minLot
      || step <= 0.0)
      return(0.0);

   lot = MathMax(minLot, MathMin(lot, maxLot));

   double units = lot / step;

   if(!MathIsValidNumber(units))
      return(0.0);

   units = MathFloor(units + 0.000000001);

   double normalized = NormalizeDouble(units * step, 8);

   if(normalized < minLot)
      normalized = NormalizeDouble(minLot, 8);

   if(normalized <= 0.0 || normalized > maxLot + 0.00000001)
      return(0.0);

   //--- ถ้าปริมาณที่ได้ไม่ตรง Step ให้ปฏิเสธแทนการส่งค่าผิด
   double checkUnits = normalized / step;

   if(!MathIsValidNumber(checkUnits)
      || MathAbs(checkUnits - MathRound(checkUnits)) > 0.0000001)
      return(0.0);

   return(normalized);
  }

//+------------------------------------------------------------------+
//| สูตรบันได Lot (คำนวณทุกครั้งที่ต้องการใช้ ขยับได้ทั้งขึ้น-ลง)        |
//|   step      = floor(ทุนรวม ÷ InpLotStepMoney)  ปัดเศษทิ้ง          |
//|   Lot       = InpBaseLot + (step - 1) x InpLotIncrement            |
//|   เพดาน     = InpMaxLotStep x InpLotIncrement (ค่า 0 = ไม่จำกัด)   |
//| ตัวอย่าง: ทุน 50=0.01 / 120=0.02 / 230=0.04 / เกิน300=หั่นเหลือ0.04 |
//+------------------------------------------------------------------+
double GetEffectiveLotForEquity(double equity)
  {
   if(!MathIsValidNumber(equity) || equity <= 0.0)
      return(0.0);

   if(!InpAutoLot)
      return(NormalizeVolume(InpBaseLot));

   if(InpLotStepMoney <= 0.0 || InpLotIncrement <= 0.0)
      return(0.0);

   double steps = MathFloor(equity / InpLotStepMoney);

   if(!MathIsValidNumber(steps))
      return(0.0);

   if(steps < 1.0)
      steps = 1.0;

   double lot = InpBaseLot + (steps - 1.0) * InpLotIncrement;

   if(!MathIsValidNumber(lot) || lot <= 0.0)
      return(0.0);

   double cap = 0.0;

   if(InpMaxLotStep > 0)
     {
      cap = InpMaxLotStep * InpLotIncrement;
      lot = MathMin(lot, cap);
     }

   double normalized = NormalizeVolume(lot);

   if(normalized <= 0.0)
      return(0.0);

   //--- ห้าม Broker minimum ดัน Lot เกินเพดาน Auto-Lot ที่กำหนด
   if(cap > 0.0 && normalized > cap + 0.00000001)
      return(0.0);

   return(normalized);
  }

double GetEffectiveLot()
  {
   double equity = 0.0;

   if(!TryGetVirtualEquity(equity))
      return(0.0);

   return(GetEffectiveLotForEquity(equity));
  }

//+------------------------------------------------------------------+
//| กติกาหยุด: ทุนเสมือนติดลบ/เหลือ $0 = หยุดเปิดไม้ใหม่ รอกด REFILL    |
//+------------------------------------------------------------------+
bool IsCapitalDead()
  {
   double equity = 0.0;

   //--- Fail-closed: ไม่อนุญาตเปิดเพิ่มเมื่ออ่านทุนไม่ได้
   if(!TryGetVirtualEquity(equity))
      return(true);

   return(equity <= 0.0);
  }

#endif // HEDGE1_CAPITAL_MQH