//+------------------------------------------------------------------+
//|                                             Hedge1_Capital.mqh   |
//|  Virtual Capital + สูตรบันได Lot + REFILL + หยุดเมื่อทุนหมด      |
//+------------------------------------------------------------------+
#ifndef HEDGE1_CAPITAL_MQH
#define HEDGE1_CAPITAL_MQH

#include "Hedge1_Inputs.mqh"

//--- ชื่อตัวแปรถาวรของ Terminal ใช้เก็บยอด REFILL สะสม (กันหายเวลารีสตาร์ท EA)
string RefillGVName()
  {
   return("HEDGE1_" + IntegerToString(InpMagicNumber) + "_REFILL");
  }

//+------------------------------------------------------------------+
//| กำไรขาดทุนสุทธิที่ปิดไปแล้ว (นับจากประวัติตาม Magic + คู่เงิน)     |
//| นับทุกดีลของบอทนี้ รวมค่าคอมมิชชั่น/สวอปฝั่งเปิดด้วย              |
//| เพื่อให้ยอด Virtual Equity ตรงกับเน็ตจริงที่เกิดกับบัญชี           |
//+------------------------------------------------------------------+
double GetClosedNet()
  {
   double net = 0.0;
   if(!HistorySelect(0, TimeCurrent() + 60))
     {
      Print("Hedge1: HistorySelect ล้มเหลว error=", GetLastError());
      return(0.0);
     }
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
      net += HistoryDealGetDouble(ticket, DEAL_PROFIT)
           + HistoryDealGetDouble(ticket, DEAL_SWAP)
           + HistoryDealGetDouble(ticket, DEAL_COMMISSION);
     }
   return(net);
  }

//+------------------------------------------------------------------+
//| ยอด REFILL สะสมทั้งหมด (อ่านจาก Terminal Global Variable)         |
//+------------------------------------------------------------------+
double GetTotalRefill()
  {
   string name = RefillGVName();
   if(GlobalVariableCheck(name))
      return(GlobalVariableGet(name));
   return(0.0);
  }

//+------------------------------------------------------------------+
//| กดปุ่ม REFILL หนึ่งครั้ง = เติมทุนเสมือนตามค่า InpRefillAmount     |
//+------------------------------------------------------------------+
void AddRefill()
  {
   double total = GetTotalRefill() + InpRefillAmount;
   if(!GlobalVariableSet(RefillGVName(), total))
      Print("Hedge1: บันทึกยอด REFILL ล้มเหลว error=", GetLastError());
  }

//+------------------------------------------------------------------+
//| ทุนเสมือนปัจจุบัน = ทุนเริ่มต้น + REFILL สะสม + กำไรขาดทุนที่ปิดแล้ว|
//| (ไม่รวมกำไรลอยตัว ตรงกับตัวเลขบน Panel ตาม Blueprint)             |
//+------------------------------------------------------------------+
double GetVirtualEquity()
  {
   return(InpInitialCapital + GetTotalRefill() + GetClosedNet());
  }

//+------------------------------------------------------------------+
//| ปรับขนาด Lot ให้อยู่ในกฎของโบรกเกอร์ (min / max / step)            |
//+------------------------------------------------------------------+
double NormalizeVolume(double lot)
  {
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step > 0.0)
      lot = MathFloor(lot / step) * step;
   if(lot < minLot)
      lot = minLot;
   if(lot > maxLot)
      lot = maxLot;
   return(NormalizeDouble(lot, 2));
  }

//+------------------------------------------------------------------+
//| สูตรบันได Lot (คำนวณทุกครั้งที่ต้องการใช้ ขยับได้ทั้งขึ้น-ลง)        |
//|   step      = floor(ทุนรวม ÷ InpLotStepMoney)  ปัดเศษทิ้ง          |
//|   Lot       = InpBaseLot + (step - 1) x InpLotIncrement            |
//|   เพดาน     = InpMaxLotStep x InpLotIncrement (ค่า 0 = ไม่จำกัด)   |
//| ตัวอย่าง: ทุน 50=0.01 / 120=0.02 / 230=0.04 / เกิน300=หั่นเหลือ0.04 |
//+------------------------------------------------------------------+
double GetEffectiveLot()
  {
   if(!InpAutoLot)
      return(NormalizeVolume(InpBaseLot));

   double equity = GetVirtualEquity();
   int steps = (int)MathFloor(equity / InpLotStepMoney);
   if(steps < 1)
      steps = 1;   // ทุนยังไม่ถึงขั้นบันไดแรก ใช้ Lot เริ่มต้น

   double lot = InpBaseLot + (steps - 1) * InpLotIncrement;

   if(InpMaxLotStep > 0)
     {
      double cap = InpMaxLotStep * InpLotIncrement;
      if(lot > cap)
         lot = cap;
     }
   return(NormalizeVolume(lot));
  }

//+------------------------------------------------------------------+
//| กติกาหยุด: ทุนเสมือนติดลบ/เหลือ $0 = หยุดเปิดไม้ใหม่ รอกด REFILL    |
//+------------------------------------------------------------------+
bool IsCapitalDead()
  {
   return(GetVirtualEquity() <= 0.0);
  }

#endif // HEDGE1_CAPITAL_MQH