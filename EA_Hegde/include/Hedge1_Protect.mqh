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
//| หา index ของไม้ในตัวติดตาม (-1 = ไม่มี)                          |
//+------------------------------------------------------------------+
//--- เปิดเฉพาะตอนย้าย State เก่าจากบัญชีเดิมที่ยืนยันแล้ว
input bool InpTrailImportLegacy = false;

string TrailGVPrefix()
  {
   return("H1T3_"
          + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))
          + "_"
          + _Symbol
          + "_"
          + IntegerToString(InpMagicNumber)
          + "_D"
          + IntegerToString(InpPointDigits)
          + "_");
  }

string TrailGVName(ulong ticket)
  {
   return(TrailGVPrefix() + IntegerToString((long)ticket));
  }

string TrailLegacyGVName(ulong ticket)
  {
   return("HEDGE1_"
          + _Symbol
          + "_"
          + IntegerToString(InpMagicNumber)
          + "_TRAIL_"
          + IntegerToString((long)ticket));
  }

bool ProtectInit()
  {
   if(AccountInfoInteger(ACCOUNT_LOGIN) <= 0)
     {
      Alert("Hedge1: ไม่พบ Account Login สำหรับ Trailing State");
      return(false);
     }

   //--- สำรองพื้นที่ Ticket สูงสุด 20 ตัวอักษร
   if(StringLen(TrailGVPrefix()) + 20 > 63)
     {
      Alert("Hedge1: Trailing State Key ยาวเกิน 63 ตัวอักษร");
      return(false);
     }

   if(InpTrailImportLegacy)
      Print("Hedge1: Legacy Trail Import ENABLED",
            " | ใช้เฉพาะบัญชีเดิมและ Point Digits เดิม");

   return(true);
  }

double TrailLoadBest(ulong ticket, bool &found)
  {
   found = false;

   string gvName = TrailGVName(ticket);
   double bestPts = 0.0;

   //--- มี Key ใหม่แล้ว: ใช้ Key ใหม่เท่านั้น
   if(GlobalVariableCheck(gvName))
     {
      if(!GlobalVariableGet(gvName, bestPts))
        {
         Print("Hedge1: อ่าน Trailing State ล้มเหลว #", ticket,
               " | error=", GetLastError());
         return(0.0);
        }

      if(!MathIsValidNumber(bestPts) || bestPts <= 0.0)
        {
         Print("Hedge1: Trailing State ไม่ถูกต้อง #", ticket);
         return(0.0);
        }

      found = true;
      return(bestPts);
     }

   //--- ไม่อ่าน Key เก่า หากผู้ใช้ไม่ได้อนุญาต
   if(!InpTrailImportLegacy)
      return(0.0);

   //--- นำเข้าเฉพาะ Position ที่ยังเปิดและเป็นของ EA นี้
   if(!PositionSelectByTicket(ticket))
      return(0.0);

   if(PositionGetString(POSITION_SYMBOL) != _Symbol
      || PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
      return(0.0);

   string legacyName = TrailLegacyGVName(ticket);

   if(!GlobalVariableCheck(legacyName))
      return(0.0);

   if(!GlobalVariableGet(legacyName, bestPts))
      return(0.0);

   if(!MathIsValidNumber(bestPts) || bestPts <= 0.0)
      return(0.0);

   //--- คืนค่าเดิมให้ RAM ใช้งาน แม้การย้าย Key ล้มเหลว
   found = true;

   ResetLastError();

   if(GlobalVariableSet(gvName, bestPts) == 0)
     {
      Print("Hedge1: Migrate Trailing State FAILED #", ticket,
            " | error=", GetLastError());
      return(bestPts);
     }

   //--- บันทึก Key ใหม่ลงดิสก์ก่อนลบ Key เก่า
   GlobalVariablesFlush();

   if(!GlobalVariableDel(legacyName))
      Print("Hedge1: ลบ Legacy Trailing State ไม่สำเร็จ #",
            ticket, " | error=", GetLastError());

   GlobalVariablesFlush();

   Print("Hedge1: Migrate Trailing State #", ticket,
         " | Best=", DoubleToString(bestPts, 0), " pts",
         " | Account=", AccountInfoInteger(ACCOUNT_LOGIN));

   return(bestPts);
  }

bool TrailSaveBest(ulong ticket, double bestPts)
  {
   string gvName = TrailGVName(ticket);

   if(StringLen(gvName) > 63)
     {
      Print("Hedge1: Trailing State Key ยาวเกินกำหนด #",
            ticket);
      return(false);
     }

   if(!MathIsValidNumber(bestPts) || bestPts <= 0.0)
     {
      Print("Hedge1: ปฏิเสธการบันทึก Best Profit ผิดปกติ #",
            ticket);
      return(false);
     }

   ResetLastError();

   if(GlobalVariableSet(gvName, bestPts) == 0)
     {
      Print("Hedge1: บันทึก Trailing State ล้มเหลว #", ticket,
            " | error=", GetLastError());
      return(false);
     }

   //--- Audit baseline: Flush ทุกครั้งที่มีการบันทึก Best ใหม่
   GlobalVariablesFlush();

   return(true);
  }

void TrailDeleteBest(ulong ticket)
  {
   string gvName = TrailGVName(ticket);

   if(!GlobalVariableCheck(gvName))
      return;

   if(GlobalVariableDel(gvName))
      Print("Hedge1: Clear Trailing State #", ticket);
   else
      Print("Hedge1: ลบ Trailing State ล้มเหลว #", ticket,
            " | error=", GetLastError());
  }

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
      bool foundSaved = false;
      double savedBest = TrailLoadBest(ticket, foundSaved);

      int n = ArraySize(g_trail);

      if(ArrayResize(g_trail, n + 1) != n + 1)
        {
         Print("Hedge1: เพิ่ม Trail Track ไม่สำเร็จ #", ticket);
         return;
        }

      g_trail[n].ticket = ticket;
      g_trail[n].bestPts = foundSaved
                          ? MathMax(profitPts, savedBest)
                          : profitPts;

      idx = n;

      if(foundSaved)
         Print("Hedge1: Restore Trailing State #", ticket,
               " | Best=",
               DoubleToString(g_trail[idx].bestPts, 0),
               " pts");
     }
   else if(profitPts > g_trail[idx].bestPts)
      g_trail[idx].bestPts = profitPts;

   //--- ตรวจค่าที่บันทึกไว้ เพื่อ retry หากการ Save ก่อนหน้าล้มเหลว
   bool foundStored = false;
   double storedBest = TrailLoadBest(ticket, foundStored);

   if(foundStored && storedBest > g_trail[idx].bestPts)
      g_trail[idx].bestPts = storedBest;

   if(!foundStored || g_trail[idx].bestPts > storedBest)
      TrailSaveBest(ticket, g_trail[idx].bestPts);
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

   TrailDeleteBest(ticket);
  }

//+------------------------------------------------------------------+
//| เก็บกวาดรายชื่อไม้ที่ปิดไปแล้วออกจากตัวติดตาม                    |
//+------------------------------------------------------------------+
//--- ยืนยันว่าตำแหน่งปิดครบแล้วจากประวัติ
//--- หากตรวจไม่ได้ ให้เก็บ State ไว้ก่อน
bool TrailConfirmedClosed(ulong ticket)
  {
   //--- ตรวจทั้ง Ticket และ Identifier ของ Position ที่ยังเปิด
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong liveTicket = PositionGetTicket(i);

      if(liveTicket == 0)
         continue;

      ulong identifier =
         (ulong)PositionGetInteger(POSITION_IDENTIFIER);

      if(liveTicket == ticket || identifier == ticket)
         return(false);
     }

   //--- ใช้ Ticket เป็น Identifier เฉพาะกรณีที่ค้นประวัติได้
   //--- หาก Ticket เคยเปลี่ยนและค้นไม่พบ จะไม่ลบ State
   if(!HistorySelectByPosition(ticket))
      return(false);

   double netVolume = 0.0;
   bool sawOwnEntry = false;
   bool sawExit = false;

   int total = HistoryDealsTotal();

   for(int i = 0; i < total; i++)
     {
      ulong deal = HistoryDealGetTicket(i);

      if(deal == 0)
         return(false);

      ENUM_DEAL_TYPE dealType =
         (ENUM_DEAL_TYPE)HistoryDealGetInteger(deal, DEAL_TYPE);

      if(dealType != DEAL_TYPE_BUY
         && dealType != DEAL_TYPE_SELL)
         continue;

      if(HistoryDealGetString(deal, DEAL_SYMBOL) != _Symbol)
         return(false);

      ENUM_DEAL_ENTRY entry =
         (ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal, DEAL_ENTRY);

      double volume = HistoryDealGetDouble(deal, DEAL_VOLUME);

      if(entry == DEAL_ENTRY_IN)
        {
         netVolume += volume;

         if(HistoryDealGetInteger(deal, DEAL_MAGIC)
            == InpMagicNumber)
            sawOwnEntry = true;
        }
      else if(entry == DEAL_ENTRY_OUT
              || entry == DEAL_ENTRY_OUT_BY)
        {
         netVolume -= volume;
         sawExit = true;
        }
      else
         return(false);
     }

   return(sawOwnEntry
          && sawExit
          && MathAbs(netVolume) < 0.00000001);
  }

void TrailCleanup()
  {
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
      return;

   bool deletedAny = false;

   //--- Cleanup รายการใน RAM เฉพาะที่ยืนยันว่าปิดครบแล้ว
   for(int i = ArraySize(g_trail) - 1; i >= 0; i--)
     {
      ulong ticket = g_trail[i].ticket;

      if(PositionSelectByTicket(ticket))
         continue;

      if(TrailConfirmedClosed(ticket))
        {
         TrailRemove(ticket);
         deletedAny = true;
        }
     }

   //--- สแกน State ค้างจากก่อน Restart ไม่เกินครั้งต่อนาที
   static datetime lastScan = 0;
   datetime now = TimeCurrent();

   bool scanDue = (lastScan == 0
                   || now < lastScan
                   || now - lastScan >= 60);

   if(scanDue)
     {
      lastScan = now;

      string prefix = TrailGVPrefix();
      int prefixLen = StringLen(prefix);

      for(int i = GlobalVariablesTotal() - 1; i >= 0; i--)
        {
         string name = GlobalVariableName(i);

         if(StringFind(name, prefix) != 0)
            continue;

         string suffix = StringSubstr(name, prefixLen);
         long ticketValue = StringToInteger(suffix);

         //--- ไม่แตะชื่อผิดรูปแบบ
         if(ticketValue <= 0
            || suffix != IntegerToString(ticketValue))
            continue;

         ulong ticket = (ulong)ticketValue;

         if(!TrailConfirmedClosed(ticket))
            continue;

         if(GlobalVariableDel(name))
           {
            deletedAny = true;
            Print("Hedge1: Clear Orphan Trailing State #",
                  ticket);
           }
         else
            Print("Hedge1: Cleanup Trailing State FAILED #",
                  ticket, " | error=", GetLastError());
        }
     }

   if(deletedAny)
      GlobalVariablesFlush();
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

      //--- Cut Loss เป็น SL ขั้นพื้นฐาน
      //--- ห้ามคลาย SL ที่ BE หรือผู้ใช้ป้องกันไว้ดีกว่าแล้ว
      bool beforeBreakEven = (InpBreakEvenMode == BE_OFF
                               || profPts < InpBreakEvenTrigger);

      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      if(tickSize <= 0.0)
         tickSize = _Point;

      bool cutSLDifferent = (sl == 0.0
                              || MathAbs(sl - exactCutSL) >= tickSize);

      bool cutSLImproves = (sl == 0.0);

      if(sl > 0.0)
        {
         if(dir == POSITION_TYPE_BUY)
            cutSLImproves = (exactCutSL > sl);
         else
            cutSLImproves = (exactCutSL < sl);
        }

      if((sl == 0.0 || beforeBreakEven)
         && cutSLDifferent
         && cutSLImproves)
        {
         if(ModifySL(ticket, exactCutSL, tp, "CUTLOSS-SL"))
            sl = exactCutSL;
        }

      //--- 2) R:R: ปิดทำกำไรเมื่อกำไรถึง % ของ Break-even Trigger
      //---    (100% = 1000 pts / 200% = 2000 pts)
      if(rrTarget > 0.0 && profPts >= rrTarget)
        {
         bool closeOK = ClosePositionByTicket(ticket, "RR");

         //--- ลบ State เฉพาะเมื่อคำสั่งสำเร็จและไม่เหลือ Position
         if(closeOK && !PositionSelectByTicket(ticket))
            TrailRemove(ticket);

         //--- ปิดไม่สำเร็จหรือยังเหลือ Position ให้เก็บ State ไว้
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

         //--- โหลด State เดิมก่อน แม้กำไรปัจจุบันต่ำกว่า Arm
         int oldIdx = TrailFind(ticket);

         if(oldIdx < 0)
           {
            bool foundSaved = false;
            double savedBest = TrailLoadBest(ticket, foundSaved);

            //--- State ที่มีอยู่ถูกสร้างหลัง Arm เท่านั้น
            if(foundSaved)
               TrailUpsert(ticket, MathMax(savedBest, profPts));
           }

         oldIdx = TrailFind(ticket);
         bool wasArmed = (oldIdx >= 0);

         //--- เคย Arm แล้วต้องติดตามต่อเสมอ
         //--- หากยังไม่ Arm ให้เริ่มเมื่อถึงระดับที่กำหนด
         if(wasArmed || profPts >= trailingArmPoints)
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

            bool closeOK =
               ClosePositionByTicket(ticket, "TRAILING-TP");

            //--- ห้ามลบ Best Profit ถ้าปิดไม่สำเร็จหรือยังเหลือไม้
            if(closeOK && !PositionSelectByTicket(ticket))
               TrailRemove(ticket);

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