#property strict
#property script_show_inputs

void OnStart()
  {
   long stops = 0;
   long freeze = 0;

   ResetLastError();

   if(!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL, stops))
     {
      Print("H1 PREFLIGHT: stops read failed | error=",
            GetLastError());
      return;
     }

   ResetLastError();

   if(!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL, freeze))
     {
      Print("H1 PREFLIGHT: freeze read failed | error=",
            GetLastError());
      return;
     }

   double point = 0.0;

   if(!SymbolInfoDouble(_Symbol, SYMBOL_POINT, point)
      || !MathIsValidNumber(point)
      || point <= 0.0
      || stops < 0
      || freeze < 0)
     {
      Print("H1 PREFLIGHT: invalid symbol properties");
      return;
     }

   MqlTick tick;

   if(!SymbolInfoTick(_Symbol, tick)
      || !MathIsValidNumber(tick.bid)
      || !MathIsValidNumber(tick.ask)
      || tick.bid <= 0.0
      || tick.ask < tick.bid)
     {
      Print("H1 PREFLIGHT: quote unavailable | error=",
            GetLastError());
      return;
     }

   long mode = AccountInfoInteger(ACCOUNT_MARGIN_MODE);

   Print("H1 PREFLIGHT | Symbol=", _Symbol,
         " | StopsLevel=", stops,
         " | FreezeLevel=", freeze,
         " | NativePoint=", DoubleToString(point, 8));

   Print("H1 PREFLIGHT | Bid=", DoubleToString(tick.bid, _Digits),
         " | Ask=", DoubleToString(tick.ask, _Digits),
         " | NativeSpreadPts=",
         DoubleToString((tick.ask - tick.bid) / point, 2),
         " | EA_D2_SpreadPts=",
         DoubleToString((tick.ask - tick.bid) / 0.01, 2),
         " | TickTime=",
         TimeToString(tick.time, TIME_DATE | TIME_SECONDS));

   Print("H1 PREFLIGHT | Hedging=",
         (mode == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING
          ? "true"
          : "false"),
         " | TradeMode=",
         AccountInfoInteger(ACCOUNT_TRADE_MODE));

   Print("H1 PREFLIGHT | Planning buffer=10 native points "
         "(informational only). No orders or state changes.");
  }