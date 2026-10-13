//+------------------------------------------------------------------+
//|                                              Hedge1_Engine.mqh   |
//| เครื่องจักร: เปิด Hedge, Timeout, สเปรด, เปิดฝั่งที่หาย,         |
//| ปิดไม้, ปุ่ม Manual, Mirror-and-Verify (สมมาตรสองฝั่ง 100%)      |
//| ใช้ OrderSend ตรงทั้งหมด ไม่พึ่งไลบรารี CTrade (ใช้ได้ทุก MT5)   |
//+------------------------------------------------------------------+
#ifndef HEDGE1_ENGINE_MQH
#define HEDGE1_ENGINE_MQH

#include "Hedge1_Inputs.mqh"
#include "Hedge1_Capital.mqh"
#include "Hedge1_Session.mqh"
#include "Hedge1_Utils.mqh"

bool     g_engineReady = false;

datetime g_emptySince       = 0;  // เวลาที่พอร์ตว่างล่าสุด (นับ Timeout รอบใหม่)
datetime g_buyMissingSince  = 0;  // เวลาที่ฝั่ง Buy หายไป (รอเปิดคืนตาม Timeout)
datetime g_sellMissingSince = 0;  // เวลาที่ฝั่ง Sell หายไป
datetime g_lastOpenFail     = 0;  // เวลาที่เปิดไม้ล้มเหลวล่าสุด (พักกันลูปรัว)

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
     }
   else
     {
      req.type  = ORDER_TYPE_SELL;
      req.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
     }

   if(!OrderSend(req, res))
     {
      Print("Hedge1: [", tag, "] ส่งคำสั่งเปิดออเดอร์ล้มเหลว retcode=", res.retcode,
            " (", res.comment, ") error=", GetLastError());
      return(false);
     }

   if(res.retcode != TRADE_RETCODE_DONE && res.retcode != TRADE_RETCODE_DONE_PARTIAL
      && res.retcode != TRADE_RETCODE_PLACED)
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
      Print("Hedge1: [", tag, "] ปิดไม้ #", ticket, " ล้มเหลว retcode=", res.retcode,
            " (", res.comment, ") error=", GetLastError());
      return(false);
     }
   Print("Hedge1: [", tag, "] ปิดไม้ #", ticket, " สำเร็จ ราคา ",
         DoubleToString(res.price, _Digits));
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
      Print("Hedge1: [", tag, "] แก้ SL ไม้ #", ticket, " ล้มเหลว retcode=", res.retcode,
            " (", res.comment, ") error=", GetLastError());
      return(false);
     }
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
//| เปิดคู่ Hedge (Buy + Sell) แบบ Mirror-and-Verify                  |
//| ส่งสองฝั่งติดกัน -> ตรวจ -> retry ฝั่งที่พลาด                    |
//| ถ้ายังไม่สมมาตร -> rollback ปิดฝั่งที่เปิดสำเร็จ เพื่อคงความสมดุล |
//+------------------------------------------------------------------+
bool OpenHedgePair()
  {
   if(!g_engineReady)
      return(false);

   //--- กฎสำคัญ: ห้ามเปิด Hedge ใหม่หากยังมีไม้ของ Magic นี้บน Symbol นี้อยู่
   int existingBuy  = CountSide(POSITION_TYPE_BUY);
   int existingSell = CountSide(POSITION_TYPE_SELL);

   if(existingBuy > 0 || existingSell > 0)
     {
      Print("Hedge1: ปฏิเสธการเปิด Hedge ใหม่ เพราะ Basket ยังไม่ว่าง | Buy=",
            existingBuy, " Sell=", existingSell);
      return(false);
     }

   double lot = GetEffectiveLot();
   bool okBuy  = OpenOneOrder(POSITION_TYPE_BUY,  lot, "HEDGE");
   bool okSell = OpenOneOrder(POSITION_TYPE_SELL, lot, "HEDGE");

   //--- retry ฝั่งที่ไม่สำเร็จ
   for(int i = 0; i < HEDGE_RETRY_MAX && !(okBuy && okSell); i++)
     {
      if(!okBuy)
         okBuy = OpenOneOrder(POSITION_TYPE_BUY, lot, "HEDGE-RETRY");
      if(!okSell)
         okSell = OpenOneOrder(POSITION_TYPE_SELL, lot, "HEDGE-RETRY");
     }

   if(okBuy && okSell)
     {
      g_emptySince       = 0;
      g_buyMissingSince  = 0;
      g_sellMissingSince = 0;
      Print("Hedge1: เปิดคู่ Hedge สำเร็จ lot=", DoubleToString(lot, 2));
      return(true);
     }

   //--- rollback: ปิดฝั่งที่เปิดสำเร็จ ไม่ปล่อยให้พอร์ตเหลือฝั่งเดียวโดยไม่ตั้งใจ
   if(okBuy)
      CloseOneSide(POSITION_TYPE_BUY, "HEDGE-ROLLBACK");
   if(okSell)
      CloseOneSide(POSITION_TYPE_SELL, "HEDGE-ROLLBACK");

   Print("Hedge1: เปิดคู่ Hedge ล้มเหลว ทำ rollback เรียบร้อย");
   return(false);
  }

//+------------------------------------------------------------------+
//| ประตูเปิดรอบใหม่อัตโนมัติ (Session + ทุน + Timeout + สเปรด)       |
//| เก็บเหตุผลไว้แสดงบน Panel                                        |
//+------------------------------------------------------------------+
bool CanOpenAuto(datetime sinceTime, string &reason)
  {
   if(IsCapitalDead())
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

//+------------------------------------------------------------------+
//| พยายามเปิดคืนฝั่งที่โดนปิด (เช่น Sell โดน Cut Loss)               |
//+------------------------------------------------------------------+
void TryReopenMissingSide(int buys, int sells)
  {
   if(!InpReopenClosedSide)
     { g_gateReason = "SIDE_REOPEN_OFF"; return; }

   if(buys > 0 && sells > 0)
     { g_gateReason = "RUNNING"; return; }   // ครบสองฝั่งแล้ว ทำงานปกติ

   if(g_lastOpenFail > 0 && TimeCurrent() - g_lastOpenFail < HEDGE_FAIL_COOLDOWN)
     { g_gateReason = "COOLDOWN"; return; }

   ENUM_POSITION_TYPE missing = POSITION_TYPE_BUY;
   datetime since = 0;
   if(buys == 0)
     { missing = POSITION_TYPE_BUY;  since = g_buyMissingSince; }
   else
     { missing = POSITION_TYPE_SELL; since = g_sellMissingSince; }

   string reason = "";
   if(!CanOpenAuto(since, reason))
     { g_gateReason = reason; return; }

   double lot = GetEffectiveLot();
   if(OpenOneOrder(missing, lot, "REOPEN"))
     {
      g_lastOpenFail = 0;
      g_gateReason  = "RUNNING";
     }
   else
      g_lastOpenFail = TimeCurrent();
  }

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
      g_buyMissingSince  = 0;
      g_sellMissingSince = 0;
      if(g_emptySince == 0)
         g_emptySince = TimeCurrent();
      TryOpenNewRound();
     }
   else
     {
      //--- กฎ 1 Basket เท่านั้น:
      //--- เมื่อยังเหลือ Buy หรือ Sell อย่างน้อย 1 ไม้ ถือว่า Basket ยังไม่ว่าง
      //--- ห้าม Reopen ฝั่งที่หาย และห้ามเปิด Hedge ชุดใหม่เด็ดขาด
      g_emptySince       = 0;
      g_buyMissingSince  = 0;
      g_sellMissingSince = 0;

      if(buys > 0 && sells > 0)
         g_gateReason = "BASKET_RUNNING";
      else
         g_gateReason = "WAIT_BASKET_EMPTY";
     }
  }

//+------------------------------------------------------------------+
//| ปุ่ม Manual ทั้งหมด (กดได้เสมอ ไม่ถูก Session/Timeout บล็อก)     |
//+------------------------------------------------------------------+
bool ManualBuy()        { return(OpenOneOrder(POSITION_TYPE_BUY,  GetEffectiveLot(), "MANUAL")); }
bool ManualSell()       { return(OpenOneOrder(POSITION_TYPE_SELL, GetEffectiveLot(), "MANUAL")); }
bool ManualHedge()      { return(OpenHedgePair()); }
bool ManualCloseBuy()  { return(CloseOneSide(POSITION_TYPE_BUY,   "CLOSE-BUY")   > 0); }
bool ManualCloseSell() { return(CloseOneSide(POSITION_TYPE_SELL, "CLOSE-SELL")  > 0); }
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
   if(!InpUseTimeout)
      return(0);
   datetime since = 0;
   if(g_emptySince > 0)
      since = g_emptySince;
   else if(g_buyMissingSince > 0)
      since = g_buyMissingSince;
   else if(g_sellMissingSince > 0)
      since = g_sellMissingSince;
   if(since == 0)
      return(0);
   int remain = InpTimeoutSeconds - (int)(TimeCurrent() - since);
   if(remain < 0)
      remain = 0;
   return(remain);
  }

//--- ข้อความสถานะล่าสุดว่าทำไมยังไม่เปิดรอบใหม่ (สำหรับ Panel)
string GetEngineGateText() { return(g_gateReason); }

#endif // HEDGE1_ENGINE_MQH