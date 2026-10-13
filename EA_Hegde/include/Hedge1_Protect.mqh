//+------------------------------------------------------------------+
//|                                             Hedge1_Protect.mqh   |
//| ระบบป้องกัน: Cut Loss, Auto Break-even (3 โหมด), R:R,            |
//| Trailing TP ตามราคาที่ดีที่สุด - ทำงานต่อแม้ Session บล็อก        |
//| ปิดไม้/แก้ SL ผ่านฟังก์ชัน OrderSend ตรงจาก Engine              |
//+------------------------------------------------------------------+
#ifndef HEDGE1_PROTECT_MQH
#define HEDGE1_PROTECT_MQH

#include "Hedge1_Inputs.mqh"
#include "Hedge1_Engine.mqh"
#include "Hedge1_Utils.mqh"

//--- ตัวติดตามกำไรสูงสุดของแต่ละไม้ (ใช้กับ Trailing TP)
struct STrailTrack
  {
   ulong  ticket;    // เลขไม้
   double bestPts;  // กำไรสูงสุด (Points) ที่เคยเห็น
  };
STrailTrack g_trail[];

//+------------------------------------------------------------------+
//| ชื่อ Global Variable สำหรับเก็บ Best Profit ของ Trailing TP      |
//| ผูกด้วย Symbol + Magic + Position Ticket                          |
//+------------------------------------------------------------------+
string TrailGVName(ulong ticket)
  {
   return("HEDGE1_"
          + _Symbol
          + "_"
          + IntegerToString(InpMagicNumber)
          + "_TRAIL_"
          + IntegerToString((long)ticket));
  }

//+------------------------------------------------------------------+
//| อ่าน Best Profit เดิมจาก Terminal Global Variable                |
//| found=true หมายถึงมีข้อมูลจากก่อน Restart                        |
//+------------------------------------------------------------------+
double TrailLoadBest(ulong ticket, bool &found)
  {
   found = false;

   string gvName = TrailGVName(ticket);

   if(!GlobalVariableCheck(gvName))
      return(0.0);

   found = true;
   return(GlobalVariableGet(gvName));
  }

//+------------------------------------------------------------------+
//| บันทึก Best Profit ของ Ticket ลง Terminal Global Variable        |
//+------------------------------------------------------------------+
void TrailSaveBest(ulong ticket, double bestPts)
  {
   string gvName = TrailGVName(ticket);

   if(!GlobalVariableSet(gvName, bestPts))
      Print("Hedge1: บันทึก Trailing State ล้มเหลว #", ticket,
            " error=", GetLastError());
  }

//+------------------------------------------------------------------+
//| ลบ Persistent State หลัง Position ปิด                             |
//+------------------------------------------------------------------+
void TrailDeleteBest(ulong ticket)
  {
   string gvName = TrailGVName(ticket);

   if(GlobalVariableCheck(gvName))
     {
      if(!GlobalVariableDel(gvName))
         Print("Hedge1: ลบ Trailing State ล้มเหลว #", ticket,
               " error=", GetLastError());
     }
  }

//+------------------------------------------------------------------+
//| หา index ของไม้ในตัวติดตาม (-1 = ไม่มี)                          |
//+------------------------------------------------------------------+
int TrailFind(ulong ticket)
  {
   for(int i = 0; i < ArraySize(g_trail); i++)
      if(g_trail[i].ticket == ticket)
         return(i);
   return(-1);
  }

//+------------------------------------------------------------------+
//| บันทึก/อัปเดตกำไรสูงสุดของไม้ (บันทึกเฉพาะค่าที่ดีขึ้นเท่านั้น)    |
//+------------------------------------------------------------------+
void TrailUpsert(ulong ticket, double profitPts)
  {
   int idx = TrailFind(ticket);

   if(idx < 0)
     {
      //--- หาก EA Restart ให้พยายาม Restore Best Profit เดิมก่อน
      bool foundSaved = false;
      double savedBest = TrailLoadBest(ticket, foundSaved);

      int n = ArraySize(g_trail);
      ArrayResize(g_trail, n + 1);

      g_trail[n].ticket = ticket;
      g_trail[n].bestPts = MathMax(profitPts, savedBest);

      TrailSaveBest(ticket, g_trail[n].bestPts);

      if(foundSaved)
         Print("Hedge1: Restore Trailing State #", ticket,
               " | Best=", DoubleToString(savedBest, 0), " pts");

      return;
     }

   if(profitPts > g_trail[idx].bestPts)
     {
      g_trail[idx].bestPts = profitPts;
      TrailSaveBest(ticket, g_trail[idx].bestPts);
     }
  }

//+------------------------------------------------------------------+
//| ลบไม้ออกจากตัวติดตาม                                              |
//+------------------------------------------------------------------+
void TrailRemove(ulong ticket)
  {
   int idx = TrailFind(ticket);

   if(idx >= 0)
     {
      int n = ArraySize(g_trail);

      for(int i = idx; i < n - 1; i++)
         g_trail[i] = g_trail[i + 1];

      ArrayResize(g_trail, n - 1);
     }

   //--- ลบข้อมูลถาวรด้วย แม้ g_trail ใน Memory จะไม่มีแล้ว
   TrailDeleteBest(ticket);
  }

//+------------------------------------------------------------------+
//| เก็บกวาดรายชื่อไม้ที่ปิดไปแล้วออกจากตัวติดตาม                    |
//+------------------------------------------------------------------+
void TrailCleanup()
  {
   for(int i = ArraySize(g_trail) - 1; i >= 0; i--)
      if(!PositionSelectByTicket(g_trail[i].ticket))
         TrailRemove(g_trail[i].ticket);
  }

//+------------------------------------------------------------------+
//| กำไร/ขาดทุนปัจจุบันของไม้ เป็น Points (ตามหน่วย InpPointDigits)   |
//+------------------------------------------------------------------+
double GetProfitPoints(ENUM_POSITION_TYPE dir, double entry)
  {
   double pt = HedgePoint();
   if(pt <= 0.0)
      return(0.0);
   if(dir == POSITION_TYPE_BUY)
     {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      return((bid - entry) / pt);
     }
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   return((entry - ask) / pt);
  }

//+------------------------------------------------------------------+
//| ปิดไม้รายตัว (ใช้กับ RR และ Trailing TP)                          |
//+------------------------------------------------------------------+
bool ClosePositionByTicket(ulong ticket, string reason)
  {
   return(RawPositionClose(ticket, reason));
  }

//+------------------------------------------------------------------+
//| แก้ไข SL ของไม้ (คงค่า TP เดิมไว้)                               |
//| คืนค่า true เมื่อ Broker ยอมแก้ SL สำเร็จจริง                     |
//+------------------------------------------------------------------+
bool ModifySL(ulong ticket, double newSL, double keepTP, string tag)
  {
   return(RawPositionModify(ticket, newSL, keepTP, tag));
  }

//+------------------------------------------------------------------+
//| หัวใจของ Protect - เรียกทุก Tick (ก่อน EngineOnTick)                |
//| ลำดับ: ใส่ SL ตัดขาดทุน -> RR -> Trailing TP -> Break-even        |
//+------------------------------------------------------------------+
void ProtectOnTick()
  {
   if(!g_engineReady)
      return;

   TrailCleanup();

   double rrTarget = InpRRPercent / 100.0 * InpBreakEvenTrigger;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;

      ENUM_POSITION_TYPE dir = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl    = PositionGetDouble(POSITION_SL);
      double tp    = PositionGetDouble(POSITION_TP);
      double profPts = GetProfitPoints(dir, entry);

      //--- 1) Cut Loss
      //--- SL ชั้นแรกถูกส่งมากับ Order ตั้งแต่เปิด
      //--- ตรงนี้ทำหน้าที่ตรวจและปรับให้ระยะ Cut Loss
      //--- อิงราคา Fill จริงของ Position เพื่อให้แม่นที่สุด
      double exactCutSL = (dir == POSITION_TYPE_BUY)
                          ? entry - PointsToPrice(InpCutLossPoints)
                          : entry + PointsToPrice(InpCutLossPoints);

      exactCutSL = NormalizeDouble(exactCutSL, _Digits);

      //--- ก่อนถึง Break-even ต้องรักษา SL ให้ตรง Cut Loss จริงเสมอ
      bool beforeBreakEven = (InpBreakEvenMode == BE_OFF
                               || profPts < InpBreakEvenTrigger);

      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      if(tickSize <= 0.0)
         tickSize = _Point;

      bool cutSLDifferent = (sl == 0.0
                              || MathAbs(sl - exactCutSL) >= tickSize);

      if(beforeBreakEven && cutSLDifferent)
        {
         if(ModifySL(ticket, exactCutSL, tp, "CUTLOSS-SL"))
            sl = exactCutSL;
        }

      //--- 2) R:R: ปิดทำกำไรเมื่อกำไรถึง % ของ Break-even Trigger
      //---    (100% = 1000 pts / 200% = 2000 pts)
      if(rrTarget > 0.0 && profPts >= rrTarget)
        {
         if(ClosePositionByTicket(ticket, "RR"))
           {
            TrailRemove(ticket);
            continue;
           }

         //--- ปิดไม่สำเร็จ: เก็บ State ไว้และลองใหม่ Tick ถัดไป
         continue;
        }

      //--- 3) Trailing TP แบบ Armed Trailing
      //--- เริ่มทำงานต่อเมื่อกำไรถึง:
      //--- Cut Loss Points + Trailing Pullback
      //--- ตัวอย่าง CutLoss=1000, Pullback=500:
      //--- กำไรต้องถึง +1500 ก่อน จึงเริ่มมี Trailing TP
      //--- พีค +1800 -> ปิดเมื่อย่อลงถึง +1300
      //--- พีค +1900 -> ปิดเมื่อย่อลงถึง +1400
      if(InpUseTrailingTP)
        {
         double trailingArmPoints = InpCutLossPoints + InpTrailingPullback;

         //--- Restore State เดิมก่อนเสมอ
         //--- สำคัญ: แม้ราคาปัจจุบันย่อต่ำกว่า Arm Level แล้ว
         //--- แต่หากเคย Arm ก่อน Restart ต้อง Trailing ต่อได้
         int oldIdx = TrailFind(ticket);

         if(oldIdx < 0)
           {
            bool foundSaved = false;
            double savedBest = TrailLoadBest(ticket, foundSaved);

            if(foundSaved && savedBest >= trailingArmPoints)
               TrailUpsert(ticket, savedBest);
           }

         oldIdx = TrailFind(ticket);
         bool wasArmed = (oldIdx >= 0);

         //--- เริ่มติดตามราคาสูงสุดใหม่ เมื่อกำไรแตะระดับ Arm
         if(profPts >= trailingArmPoints)
            TrailUpsert(ticket, profPts);

         int idx = TrailFind(ticket);

         //--- Log เพียงครั้งเดียว เมื่อ Trailing TP เริ่มทำงาน
         if(!wasArmed && idx >= 0)
           {
            double exitAt = g_trail[idx].bestPts - InpTrailingPullback;

            Print("Hedge1: Trailing TP ARMED #", ticket,
                  " | Profit=", DoubleToString(profPts, 0),
                  " pts | Arm=", DoubleToString(trailingArmPoints, 0),
                  " pts | Exit if retrace to ",
                  DoubleToString(exitAt, 0), " pts");
           }

         //--- เมื่อเคย Arm แล้ว ให้ตรวจการย่อเสมอ
         //--- แม้ราคาย่อต่ำกว่า 1500 ก็ยังต้องปิดได้ตาม Trailing
         if(idx >= 0
            && g_trail[idx].bestPts - profPts >= InpTrailingPullback)
           {
            Print("Hedge1: Trailing TP CLOSE #", ticket,
                  " | Best=", DoubleToString(g_trail[idx].bestPts, 0),
                  " pts | Current=", DoubleToString(profPts, 0),
                  " pts | Pullback=", DoubleToString(InpTrailingPullback, 0),
                  " pts");

            if(ClosePositionByTicket(ticket, "TRAILING-TP"))
              {
               TrailRemove(ticket);
               continue;
              }

            //--- ปิดไม่สำเร็จ: ห้ามลบ Best Profit
            //--- Tick ถัดไปจะพยายามปิดใหม่ตาม Trailing State เดิม
            continue;
           }
        }

      //--- 4) Auto Break-even (ล็อกกำไรตามสัดส่วน % ของระยะที่วิ่งได้)
      if(InpBreakEvenMode != BE_OFF && profPts >= InpBreakEvenTrigger)
        {
         double lockPts = 0.0;
         if(InpBreakEvenMode == BE_TRAILING)
           {
            //--- เลื่อนตาม: นับเฉพาะ step ที่เต็ม 100 Points
            //--- เช่น กำไร 1800 = 18 step -> ล็อก 20% ของ 1800 = +360
            int stepCount = (int)MathFloor(profPts / InpBreakEvenStep);
            double stepped = stepCount * InpBreakEvenStep;
            lockPts = stepped * InpBreakEvenPct / 100.0;
           }
         else
           {
            //--- ไม่เลื่อน: ล็อกครั้งเดียวที่ 20% ของ Trigger (1000) = +200
            lockPts = InpBreakEvenTrigger * InpBreakEvenPct / 100.0;
           }

         double newSL = (dir == POSITION_TYPE_BUY)
                        ? entry + PointsToPrice(lockPts)
                        : entry - PointsToPrice(lockPts);

         //--- ขยับเฉพาะทิศที่ดีขึ้นเท่านั้น (Buy: SL ขึ้นเท่านั้น / Sell: ลงเท่านั้น)
         bool better = (dir == POSITION_TYPE_BUY) ? (newSL > sl) : (newSL < sl);
         if(better)
            ModifySL(ticket, newSL, tp, "BREAK-EVEN");
        }
     }
  }

#endif // HEDGE1_PROTECT_MQH