//+------------------------------------------------------------------+
//|                                              Hedge1_Engine.mqh   |
//| เครื่องจักร: เปิดคู่ Hedge, Timeout, สเปรด, One Basket Only     |
//| ปิดไม้, Strict Manual Entry, Mirror-and-Verify ตอนเปิดคู่        |
//| ใช้ OrderSend ตรงทั้งหมด ไม่พึ่งไลบรารี CTrade (ใช้ได้ทุก MT5)   |
//+------------------------------------------------------------------+
#ifndef HEDGE1_ENGINE_MQH
#define HEDGE1_ENGINE_MQH

#include "Hedge1_Inputs.mqh"
#include "Hedge1_Capital.mqh"
#include "Hedge1_Session.mqh"
#include "Hedge1_Utils.mqh"

bool     g_engineReady = false;

//--- true = ต้องจัดการ Report ที่ค้างก่อนเปิด Basket ใหม่
bool     g_reportBlocksEntry = false;

datetime g_emptySince       = 0;  // เวลาที่ Basket ของ EA ว่างล่าสุด
datetime g_lastOpenFail     = 0;  // เวลาที่เปิดคู่ Hedge ล้มเหลวล่าสุด

string   g_gateReason = "INIT";   // เหตุผลล่าสุดที่ยังไม่เปิดรอบใหม่ (แสดงบน Panel)

#define HEDGE_FAIL_COOLDOWN 60    // วินาทีพักหลังเปิดคู่ Hedge ล้มเหลว
#define HEDGE_RETRY_MAX     3     // จำนวน retry ฝั่งที่เปิดไม่สำเร็จ

//+------------------------------------------------------------------+
//| เริ่มระบบ Engine (เรียกจาก OnInit ของ EA หลัก)                     |
//+------------------------------------------------------------------+
void EngineInit()
  {
   g_engineReady = true;
   Print("Hedge1: Engine พร้อมทำงาน Magic=", InpMagicNumber,
         " EffectiveLot=", DoubleToString(GetEffectiveLot(), 2));
  }

//+------------------------------------------------------------------+
//| นับไม้ของบอทนี้ตามฝั่ง (Magic + คู่เงิน)                          |
//+------------------------------------------------------------------+
int CountSide(ENUM_POSITION_TYPE type)
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type)
         count++;
     }
   return(count);
  }

//+------------------------------------------------------------------+
//| เปิดไม้ 1 ฝั่งด้วย OrderSend ตรงๆ + ตรวจผล + log slippage        |
//| ตามกฎ Mirror-and-Verify                                          |
//+------------------------------------------------------------------+
bool OpenOneOrder(ENUM_POSITION_TYPE dir, double lot, string tag)
  {
   if(!g_engineReady)
      return(false);

   MqlTradeRequest req;
   MqlTradeResult  res;
   ZeroMemory(req);
   ZeroMemory(res);
   req.action       = TRADE_ACTION_DEAL;
   req.symbol       = _Symbol;
   req.volume       = lot;
   req.magic        = (ulong)InpMagicNumber;
   req.deviation    = InpDeviationPoints;
   req.type_filling = GetSymbolFilling();
   req.comment      = InpTradeComment;
   if(dir == POSITION_TYPE_BUY)
     {
      req.type  = ORDER_TYPE_BUY;
      req.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

      //--- ส่ง Cut Loss SL ไปพร้อม Buy Order ตั้งแต่ต้น
      req.sl = NormalizeDouble(
                  req.price - PointsToPrice(InpCutLossPoints),
                  _Digits
               );
     }
   else
     {
      req.type  = ORDER_TYPE_SELL;
      req.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);

      //--- ส่ง Cut Loss SL ไปพร้อม Sell Order ตั้งแต่ต้น
      req.sl = NormalizeDouble(
                  req.price + PointsToPrice(InpCutLossPoints),
                  _Digits
               );
     }

   //--- Guard: ห้ามเปิดไม้หากราคาหรือ SL คำนวณผิดปกติ
   if(req.price <= 0.0 || req.sl <= 0.0)
     {
      Print("Hedge1: [", tag, "] ปฏิเสธการเปิด Order เพราะราคา/SL ไม่ถูกต้อง",
            " | Price=", DoubleToString(req.price, _Digits),
            " | SL=", DoubleToString(req.sl, _Digits));
      return(false);
     }

   if(!OrderSend(req, res))
     {
      Print("Hedge1: [", tag, "] ส่งคำสั่งเปิดออเดอร์ล้มเหลว retcode=", res.retcode,
            " (", res.comment, ") error=", GetLastError());
      return(false);
     }

   if(res.retcode != TRADE_RETCODE_DONE
      && res.retcode != TRADE_RETCODE_DONE_PARTIAL)
     {
      Print("Hedge1: [", tag, "] เปิดออเดอร์ล้มเหลว retcode=", res.retcode,
            " (", res.comment, ")");
      return(false);
     }

   if(res.price > 0.0 && HedgePoint() > 0.0)
     {
      double slipPts = MathAbs(res.price - req.price) / HedgePoint();
      if(slipPts > 0.0)
         Print("Hedge1: [", tag, "] slippage ", DoubleToString(slipPts, 1),
               " pts (", DoubleToString(req.price, _Digits), " -> ",
               DoubleToString(res.price, _Digits), ")");
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| โหมด Filling ที่โบรกเกอร์รองรับ (ใช้ได้กับทุกเวอร์ชั่น MT5)      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING GetSymbolFilling()
  {
   long fillFlags = SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   if((fillFlags & SYMBOL_FILLING_FOK) != 0)
      return(ORDER_FILLING_FOK);
   if((fillFlags & SYMBOL_FILLING_IOC) != 0)
      return(ORDER_FILLING_IOC);
   return(ORDER_FILLING_RETURN);
  }

//+------------------------------------------------------------------+
//| ตรวจว่าคำสั่ง Trade ทำสำเร็จจริงที่ฝั่ง Server หรือไม่             |
//| หมายเหตุ: OrderSend=true แปลว่า Terminal ส่ง Request ได้           |
//| แต่ต้องตรวจ retcode ต่อ จึงจะรู้ว่า Broker ทำสำเร็จจริง             |
//+------------------------------------------------------------------+
bool IsTradeRetcodeDone(uint retcode)
  {
   return(retcode == TRADE_RETCODE_DONE);
  }

//+------------------------------------------------------------------+
//| ปิดไม้รายตัวด้วย ticket ผ่าน OrderSend ตรงๆ                        |
//+------------------------------------------------------------------+
bool RawPositionClose(ulong ticket, string tag)
  {
   if(!PositionSelectByTicket(ticket))
     {
      Print("Hedge1: [", tag, "] ไม่พบไม้ #", ticket, " (ปิดไปแล้ว?)");
      return(false);
     }
   ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   double volume = PositionGetDouble(POSITION_VOLUME);

   MqlTradeRequest req;
   MqlTradeResult  res;
   ZeroMemory(req);
   ZeroMemory(res);
   req.action       = TRADE_ACTION_DEAL;
   req.position     = ticket;
   req.symbol       = _Symbol;
   req.volume       = volume;
   req.deviation    = InpDeviationPoints;
   req.magic        = (ulong)InpMagicNumber;
   req.type_filling = GetSymbolFilling();
   req.type         = (ptype == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
   req.price        = (ptype == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
                                                  : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   req.comment      = tag;

   if(!OrderSend(req, res))
     {
      Print("Hedge1: [", tag, "] ส่งคำสั่งปิดไม้ #", ticket,
            " ล้มเหลว retcode=", res.retcode,
            " (", res.comment, ") error=", GetLastError());
      return(false);
     }

   //--- สำคัญ: OrderSend ผ่าน ไม่ได้แปลว่าปิดสำเร็จเสมอไป
   if(!IsTradeRetcodeDone(res.retcode))
     {
      Print("Hedge1: [", tag, "] Broker ปฏิเสธ/ปิดไม่สมบูรณ์ #", ticket,
            " retcode=", res.retcode,
            " (", res.comment, ")",
            " | Position ยังต้องถือว่าเปิดอยู่");
      return(false);
     }

   Print("Hedge1: [", tag, "] ปิดไม้ #", ticket,
         " สำเร็จจริง | ราคา=", DoubleToString(res.price, _Digits),
         " | volume=", DoubleToString(res.volume, 2));
   return(true);
  }

//+------------------------------------------------------------------+
//| แก้ SL/TP ของไม้ด้วย ticket ผ่าน OrderSend ตรงๆ                   |
//+------------------------------------------------------------------+
bool RawPositionModify(ulong ticket, double newSL, double keepTP, string tag)
  {
   MqlTradeRequest req;
   MqlTradeResult  res;
   ZeroMemory(req);
   ZeroMemory(res);
   req.action   = TRADE_ACTION_SLTP;
   req.position = ticket;
   req.symbol   = _Symbol;
   req.sl       = NormalizeDouble(newSL, _Digits);
   req.tp       = keepTP;

   if(!OrderSend(req, res))
     {
      Print("Hedge1: [", tag, "] ส่งคำสั่งแก้ SL ไม้ #", ticket,
            " ล้มเหลว retcode=", res.retcode,
            " (", res.comment, ") error=", GetLastError());
      return(false);
     }

   //--- สำคัญ: ต้องตรวจว่าฝั่ง Broker ยอมแก้ SL จริง
   if(!IsTradeRetcodeDone(res.retcode))
     {
      Print("Hedge1: [", tag, "] Broker ปฏิเสธการแก้ SL #", ticket,
            " retcode=", res.retcode,
            " (", res.comment, ")",
            " | SL เดิมยังอาจคงอยู่");
      return(false);
     }

   Print("Hedge1: [", tag, "] แก้ SL สำเร็จจริง #", ticket,
         " | New SL=", DoubleToString(req.sl, _Digits));
   return(true);
  }

//+------------------------------------------------------------------+
//| ปิดไม้ทั้งหมดของฝั่งที่ระบุ (Magic + คู่เงิน) คืนจำนวนที่ปิดสำเร็จ |
//+------------------------------------------------------------------+
int CloseOneSide(ENUM_POSITION_TYPE dir, string tag)
  {
   if(!g_engineReady)
      return(0);
   int closed = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != dir)
         continue;

      if(RawPositionClose(ticket, tag))
         closed++;
     }
   return(closed);
  }

//+------------------------------------------------------------------+
//| รวม Volume ของ Position ฝั่งที่ระบุ                               |
//| ใช้ตรวจว่า Lot จริงตรงกับ Lot ที่ระบบขอหรือไม่                     |
//+------------------------------------------------------------------+
double GetSideVolume(ENUM_POSITION_TYPE dir)
  {
   double totalVolume = 0.0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;

      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;

      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;

      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != dir)
         continue;

      totalVolume += PositionGetDouble(POSITION_VOLUME);
     }

   return(totalVolume);
  }

//+------------------------------------------------------------------+
//| ตรวจว่า Volume ที่เปิดจริงตรงกับ Lot ที่ร้องขอหรือไม่              |
//+------------------------------------------------------------------+
bool IsLotMatched(double actualLot, double expectedLot)
  {
   double volumeStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(volumeStep <= 0.0)
      volumeStep = 0.01;

   //--- ยอมให้ต่างได้ไม่เกินครึ่งหนึ่งของ Volume Step
   return(MathAbs(actualLot - expectedLot) < volumeStep * 0.5);
  }

//+------------------------------------------------------------------+
//| ตรวจว่า Hedge Pair สมบูรณ์จริงหรือไม่                              |
//| ต้องมี Buy 1, Sell 1 และ Lot ทั้งสองฝั่งต้องตรงกัน                 |
//+------------------------------------------------------------------+
bool IsExactHedgePair(double expectedLot)
  {
   int buyCount  = CountSide(POSITION_TYPE_BUY);
   int sellCount = CountSide(POSITION_TYPE_SELL);

   double buyLot  = GetSideVolume(POSITION_TYPE_BUY);
   double sellLot = GetSideVolume(POSITION_TYPE_SELL);

   return(buyCount == 1
          && sellCount == 1
          && IsLotMatched(buyLot, expectedLot)
          && IsLotMatched(sellLot, expectedLot));
  }

//+------------------------------------------------------------------+
//| Rollback Position ของ Hedge ที่เปิดไม่สมบูรณ์                       |
//| พยายามปิดสูงสุด 3 รอบ และตรวจว่า Position หายจริง                 |
//+------------------------------------------------------------------+
bool RollbackHedgePair()
  {
   for(int attempt = 1; attempt <= HEDGE_RETRY_MAX; attempt++)
     {
      int buyCount  = CountSide(POSITION_TYPE_BUY);
      int sellCount = CountSide(POSITION_TYPE_SELL);

      if(buyCount == 0 && sellCount == 0)
        {
         Print("Hedge1: HEDGE ROLLBACK สำเร็จ | Basket ว่าง");
         return(true);
        }

      Print("Hedge1: HEDGE ROLLBACK รอบ ", attempt,
            " | Buy=", buyCount,
            " Sell=", sellCount);

      if(buyCount > 0)
         CloseOneSide(POSITION_TYPE_BUY, "HEDGE-ROLLBACK");

      if(sellCount > 0)
         CloseOneSide(POSITION_TYPE_SELL, "HEDGE-ROLLBACK");
     }

   int remainingBuy  = CountSide(POSITION_TYPE_BUY);
   int remainingSell = CountSide(POSITION_TYPE_SELL);

   //--- การปิดในรอบสุดท้ายอาจทำให้ Basket ว่างแล้ว
   if(remainingBuy == 0 && remainingSell == 0)
     {
      Print("Hedge1: HEDGE ROLLBACK สำเร็จหลังรอบสุดท้าย",
            " | Basket ว่าง");
      return(true);
     }

   Print("Hedge1: CRITICAL - HEDGE ROLLBACK ปิดไม่หมด",
         " | Buy=", remainingBuy,
         " Sell=", remainingSell);

   return(false);
}

//+------------------------------------------------------------------+
//| เปิดคู่ Hedge (Buy + Sell) แบบ Mirror-and-Verify                  |
//| ส่งสองฝั่งติดกัน -> ตรวจ Position จริง -> Rollback หากไม่สมมาตร   |
//+------------------------------------------------------------------+
bool BeginBasketCycle()
  {
   double baseline = 0.0;

   if(!TryGetClosedNet(baseline))
     {
      Print("Hedge1: CYCLE START BLOCKED",
            " | Closed history unavailable");
      return(false);
     }

   datetime startedAt = TimeCurrent();

   if(startedAt <= 0)
     {
      Print("Hedge1: CYCLE START BLOCKED",
            " | Server time unavailable");
      return(false);
     }

   string netName = HedgeStateGVName("RNET");
   string startName = HedgeStateGVName("CSTART");

   if(StringLen(netName) > 63 || StringLen(startName) > 63)
     {
      Print("Hedge1: CYCLE START BLOCKED",
            " | State key too long");
      return(false);
     }

   //--- ทำเครื่องหมายว่า State ยังไม่พร้อมก่อนเขียนฐานใหม่
   ResetLastError();

   if(GlobalVariableSet(startName, 0.0) == 0)
     {
      Print("Hedge1: CYCLE START FAILED",
            " | Invalidate state error=", GetLastError());
      return(false);
     }

   GlobalVariablesFlush();

   ResetLastError();

   if(GlobalVariableSet(netName, baseline) == 0)
     {
      Print("Hedge1: CYCLE START FAILED",
            " | Save baseline error=", GetLastError());
      return(false);
     }

   ResetLastError();

   if(GlobalVariableSet(startName, (double)startedAt) == 0)
     {
      Print("Hedge1: CYCLE START FAILED",
            " | Save start time error=", GetLastError());
      return(false);
     }

   GlobalVariablesFlush();

   Print("Hedge1: CYCLE START",
         " | Baseline=", DoubleToString(baseline, 2),
         " | Time=",
         TimeToString(startedAt, TIME_DATE | TIME_SECONDS));

   return(true);
  }

bool OpenHedgePair()
  {
   if(!g_engineReady)
      return(false);

   if(g_reportBlocksEntry)
     {
      Print("Hedge1: HEDGE ENTRY BLOCKED",
            " | WAIT_REPORT");
      return(false);
     }

   //--- One Basket Only: ห้ามเปิด Hedge ใหม่ ถ้ายังมี Position ของ EA ค้างอยู่
   int existingBuy  = CountSide(POSITION_TYPE_BUY);
   int existingSell = CountSide(POSITION_TYPE_SELL);

   if(existingBuy > 0 || existingSell > 0)
     {
      Print("Hedge1: ปฏิเสธการเปิด Hedge ใหม่ เพราะ Basket ยังไม่ว่าง",
            " | Buy=", existingBuy,
            " Sell=", existingSell);
      return(false);
     }

   double equity = 0.0;

   if(!TryGetVirtualEquity(equity))
     {
      Print("Hedge1: HEDGE ENTRY BLOCKED",
            " | CAPITAL_UNAVAILABLE");
      return(false);
     }

   if(equity <= 0.0)
     {
      Print("Hedge1: HEDGE ENTRY BLOCKED",
            " | CAPITAL_DEAD",
            " | Equity=", DoubleToString(equity, 2));
      return(false);
     }

   //--- ใช้ทุนที่ตรวจผ่านแล้ว ไม่อ่านทุนซ้ำในสูตร Lot
   double lot = GetEffectiveLotForEquity(equity);

   if(!MathIsValidNumber(lot) || lot <= 0.0)
     {
      Print("Hedge1: HEDGE ENTRY BLOCKED",
            " | INVALID_LOT",
            " | Equity=", DoubleToString(equity, 2));
      return(false);
     }

   //--- บันทึกฐาน Cycle ก่อนส่ง Order แรก
   if(!BeginBasketCycle())
      return(false);

   //--- เปิด Buy และ Sell รอบแรก
   OpenOneOrder(POSITION_TYPE_BUY,  lot, "HEDGE");
   OpenOneOrder(POSITION_TYPE_SELL, lot, "HEDGE");

   //--- Retry เฉพาะฝั่งที่ Position ยังไม่เกิดจริง
   //--- หากมี Position เกิน 1 ไม้ จะไม่ Retry เพิ่ม เพื่อกัน Hedge ซ้อน
   for(int attempt = 1; attempt <= HEDGE_RETRY_MAX; attempt++)
     {
      int buyCount  = CountSide(POSITION_TYPE_BUY);
      int sellCount = CountSide(POSITION_TYPE_SELL);

      if(buyCount > 1 || sellCount > 1)
         break;

      if(buyCount == 1 && sellCount == 1)
         break;

      if(buyCount == 0)
        {
         Print("Hedge1: Retry เปิด Buy รอบ ", attempt);
         OpenOneOrder(POSITION_TYPE_BUY, lot, "HEDGE-RETRY");
        }

      if(sellCount == 0)
        {
         Print("Hedge1: Retry เปิด Sell รอบ ", attempt);
         OpenOneOrder(POSITION_TYPE_SELL, lot, "HEDGE-RETRY");
        }
     }

   //--- ตรวจ Position จริง ไม่ใช้แค่ผลลัพธ์จาก OrderSend
   if(IsExactHedgePair(lot))
     {
      g_emptySince = 0;

      Print("Hedge1: เปิดคู่ Hedge สำเร็จจริง",
            " | Buy=", CountSide(POSITION_TYPE_BUY),
            " Lot=", DoubleToString(GetSideVolume(POSITION_TYPE_BUY), 2),
            " | Sell=", CountSide(POSITION_TYPE_SELL),
            " Lot=", DoubleToString(GetSideVolume(POSITION_TYPE_SELL), 2));

      return(true);
     }

   //--- Position ไม่สมมาตร / Lot ไม่ตรง / Partial Fill / เปิดซ้อน
   int finalBuyCount  = CountSide(POSITION_TYPE_BUY);
   int finalSellCount = CountSide(POSITION_TYPE_SELL);

   double finalBuyLot  = GetSideVolume(POSITION_TYPE_BUY);
   double finalSellLot = GetSideVolume(POSITION_TYPE_SELL);

   Print("Hedge1: Hedge Pair ไม่สมบูรณ์ -> Rollback",
         " | Buy=", finalBuyCount,
         " Lot=", DoubleToString(finalBuyLot, 2),
         " | Sell=", finalSellCount,
         " Lot=", DoubleToString(finalSellLot, 2),
         " | ExpectedLot=", DoubleToString(lot, 2));

   RollbackHedgePair();
   return(false);
  }

//+------------------------------------------------------------------+
//| ประตูเปิดรอบใหม่อัตโนมัติ (Session + ทุน + Timeout + สเปรด)       |
//| เก็บเหตุผลไว้แสดงบน Panel                                        |
//+------------------------------------------------------------------+
bool CanOpenAuto(datetime sinceTime, string &reason)
  {
   if(g_reportBlocksEntry)
     { reason = "WAIT_REPORT"; return(false); }

   double equity = 0.0;

   if(!TryGetVirtualEquity(equity))
     { reason = "CAPITAL_UNAVAILABLE"; return(false); }

   if(equity <= 0.0)
     { reason = "CAPITAL_DEAD"; return(false); }
   if(IsAutoBlockedBySession())
     { reason = "SESSION_BLOCK"; return(false); }
   if(InpUseTimeout)
     {
      if(sinceTime == 0 || TimeCurrent() - sinceTime < InpTimeoutSeconds)
        { reason = "WAIT_TIMEOUT"; return(false); }
     }
   if(InpUseSpreadCheck)
     {
      if(GetSpreadPoints() > InpMaxSpreadPoints)
        { reason = "WAIT_SPREAD"; return(false); }
     }
   reason = "READY";
   return(true);
  }

//+------------------------------------------------------------------+
//| พยายามเปิดรอบใหม่เมื่อ Basket ว่าง                                |
//+------------------------------------------------------------------+
void TryOpenNewRound()
  {
   if(!InpReopenOnEmpty)
     { g_gateReason = "AUTO_OFF"; return; }

   if(g_lastOpenFail > 0 && TimeCurrent() - g_lastOpenFail < HEDGE_FAIL_COOLDOWN)
     { g_gateReason = "COOLDOWN"; return; }

   string reason = "";
   if(!CanOpenAuto(g_emptySince, reason))
     { g_gateReason = reason; return; }

   Print("Hedge1: AUTO READY -> เปิด Hedge ใหม่ | Spread=",
         DoubleToString(GetSpreadPoints(), 1),
         " / Max=", InpMaxSpreadPoints,
         " | Timeout=", InpTimeoutSeconds,
         " sec | Lot=", DoubleToString(GetEffectiveLot(), 2));

   if(OpenHedgePair())
      g_lastOpenFail = 0;
   else
      g_lastOpenFail = TimeCurrent();
  }

//--- Strict One Basket: ไม่มีระบบเปิดคืนขาที่หาย
//--- การเปิดรอบใหม่ทำผ่าน TryOpenNewRound() เมื่อ Basket ว่างเท่านั้น

//+------------------------------------------------------------------+
//| หัวใจหลักของ Engine เรียกทุก Tick (หลัง Protect ทำงานเสร็จ)        |
//+------------------------------------------------------------------+
void EngineOnTick()
  {
   if(!g_engineReady)
      return;

   int buys  = CountSide(POSITION_TYPE_BUY);
   int sells = CountSide(POSITION_TYPE_SELL);

   if(buys + sells == 0)
     {
      //--- เริ่มนับ Timeout เมื่อ Basket ว่าง
      if(g_emptySince == 0)
         g_emptySince = TimeCurrent();

      TryOpenNewRound();
     }
   else
     {
      //--- มี Position ค้างอย่างน้อยหนึ่งไม้ = Basket ยังไม่ว่าง
      //--- ไม่เปิดขาที่หาย และไม่เปิดคู่ Hedge เพิ่ม
      g_emptySince = 0;

      if(buys > 0 && sells > 0)
         g_gateReason = "BASKET_RUNNING";
      else
         g_gateReason = "WAIT_BASKET_EMPTY";
     }
  }

//+------------------------------------------------------------------+
//| Strict Manual Entry: ห้ามเปิด BUY / SELL เดี่ยว                    |
//| HEDGE เปิดได้เฉพาะ Basket ว่าง ตามกฎ OpenHedgePair()               |
//| คำสั่งปิดยังใช้ได้ ไม่ถูก Session/Timeout บล็อก                   |
//+------------------------------------------------------------------+
bool ManualBuy()
  {
   Print("Hedge1: STRICT_BASKET BLOCKED MANUAL BUY",
         " | Use HEDGE OPEN (B+S)");
   return(false);
  }

bool ManualSell()
  {
   Print("Hedge1: STRICT_BASKET BLOCKED MANUAL SELL",
         " | Use HEDGE OPEN (B+S)");
   return(false);
  }

bool ManualHedge()
  {
   if(!g_engineReady)
      return(false);

   //--- รีเฟรช Report Gate ก่อน Manual Entry
   //--- Manual ยังข้าม Auto Session/Timeout/Spread ตามกติกาเดิม
   ReportOnTick();

   return(OpenHedgePair());
  }

bool ManualCloseBuy()
  {
   return(CloseOneSide(POSITION_TYPE_BUY, "CLOSE-BUY") > 0);
  }

bool ManualCloseSell()
  {
   return(CloseOneSide(POSITION_TYPE_SELL, "CLOSE-SELL") > 0);
  }
bool ManualCloseAll()
  {
   int c = CloseOneSide(POSITION_TYPE_BUY,  "CLOSE-ALL")
         + CloseOneSide(POSITION_TYPE_SELL, "CLOSE-ALL");
   return(c > 0);
  }

//+------------------------------------------------------------------+
//| ข้อมูลสำหรับ Panel: เวลา Timeout คงเหลือ (วินาที)                |
//+------------------------------------------------------------------+
int GetTimeoutRemaining()
  {
   if(!InpUseTimeout || g_emptySince == 0)
      return(0);

   int remain = InpTimeoutSeconds
                - (int)(TimeCurrent() - g_emptySince);

   if(remain < 0)
      remain = 0;

   return(remain);
  }

//--- ข้อความสถานะล่าสุดว่าทำไมยังไม่เปิดรอบใหม่ (สำหรับ Panel)
string GetEngineGateText() { return(g_gateReason); }

#endif // HEDGE1_ENGINE_MQH