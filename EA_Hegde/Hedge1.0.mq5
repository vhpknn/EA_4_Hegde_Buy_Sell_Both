//+------------------------------------------------------------------+
//|                                                   Hedge1.0.mq5   |
//|  EA Hedge 1.0 - Virtual Capital + Tactical Hedging                |
//|  โครงสร้าง: 1 ไฟล์ = 1 หน้าที่ (แบบชิป IC) ประกอบผ่าน include   |
//|  ลำดับการทำงานต่อ Tick:                                          |
//|    1) Protect  - บริหารไม้ที่เปิดค้าง (Cut Loss/BE/RR/Trailing)  |
//|    2) Report   - ตรวจรายงานเมื่อ Basket ว่าง ก่อนเปิดรอบใหม่      |
//|    3) Engine   - เปิดคู่ใหม่เมื่อ Basket ว่างและผ่าน Entry Gates   |
//|    4) Panel    - รีเฟรชหน้าจอ                                     |
//+------------------------------------------------------------------+
#property copyright   "Hedge 1.0 Project"
#property version     "1.00"
#property description "EA Hedge 1.0 - XAUUSD Hedge (Buy+Sell) with Virtual Capital"
#property description "Cut Loss / Auto Break-even / R:R / Trailing TP / Sessions / CSV Report"

#include "include/Hedge1_Inputs.mqh"
#include "include/Hedge1_Utils.mqh"
#include "include/Hedge1_Capital.mqh"
#include "include/Hedge1_Session.mqh"
#include "include/Hedge1_Engine.mqh"
#include "include/Hedge1_Protect.mqh"
#include "include/Hedge1_Panel.mqh"
#include "include/Hedge1_Report.mqh"

//+------------------------------------------------------------------+
//| เริ่มระบบ                                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- ตรวจว่าบัญชีเป็นโหมด Hedging (Netting จะถือ Buy+Sell พร้อมกันไม่ได้)
   long marginMode = AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(marginMode != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Alert("Hedge 1.0: บัญชีนี้เป็นโหมด Netting - ต้องเป็นบัญชี Hedging เท่านั้น "
            "เพราะ EA ต้องเปิด Buy+Sell พร้อมกัน");
      return(INIT_FAILED);
     }

   //--- ตรวจค่า input พื้นฐานกันพลาดตั้งแต่ต้น
   if(InpPointDigits < 0 || InpPointDigits > 8)
     {
      Alert("Hedge 1.0: ตั้ง InpPointDigits ได้แค่ 0-8 เท่านั้น");
      return(INIT_FAILED);
     }
   if(InpLotIncrement <= 0.0 || InpLotStepMoney <= 0.0)
     {
      Alert("Hedge 1.0: ค่า Lot Step / เงินต่อบันได ต้องมากกว่า 0");
      return(INIT_FAILED);
     }
   if(InpCutLossPoints <= 0)
     {
      Alert("Hedge 1.0: Cut Loss Points ต้องมากกว่า 0 เสมอ");
      return(INIT_FAILED);
     }

   //--- Trigger ใช้ทั้ง Break-even และ RR
   if(InpBreakEvenTrigger <= 0
      && (InpBreakEvenMode != BE_OFF || InpRRPercent > 0.0))
     {
      Alert("Hedge 1.0: Break-even Trigger ต้องมากกว่า 0 ถ้าเปิดใช้ BE หรือ RR");
      return(INIT_PARAMETERS_INCORRECT);
     }

   //--- ป้องกันหารด้วยศูนย์ใน BE แบบเลื่อนตาม
   if(InpBreakEvenMode == BE_TRAILING && InpBreakEvenStep <= 0)
     {
      Alert("Hedge 1.0: Break-even Step ต้องมากกว่า 0");
      return(INIT_PARAMETERS_INCORRECT);
     }

   //--- 0% อนุญาตให้ใช้ล็อกที่ราคาเข้า
   //--- ไม่รับ 100% ขึ้นไป ซึ่งตั้ง SL ถึงหรือเลยราคาปัจจุบัน
   if(InpBreakEvenMode != BE_OFF
      && (!MathIsValidNumber(InpBreakEvenPct)
          || InpBreakEvenPct < 0.0
          || InpBreakEvenPct >= 100.0))
     {
      Alert("Hedge 1.0: Break-even Percent ต้องอยู่ในช่วง 0 ถึงน้อยกว่า 100");
      return(INIT_PARAMETERS_INCORRECT);
     }

   //--- RR = 0 หมายถึงปิด RR
   if(!MathIsValidNumber(InpRRPercent) || InpRRPercent < 0.0)
     {
      Alert("Hedge 1.0: RR Percent ต้องเป็นตัวเลขตั้งแต่ 0 ขึ้นไป");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(InpUseTrailingTP && InpTrailingPullback <= 0)
     {
      Alert("Hedge 1.0: Trailing Pullback ต้องมากกว่า 0");
      return(INIT_PARAMETERS_INCORRECT);
     }

   //--- Timeout = 0 อนุญาต แต่ห้ามติดลบ
   if(InpUseTimeout && InpTimeoutSeconds < 0)
     {
      Alert("Hedge 1.0: Timeout Seconds ต้องไม่ติดลบ");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(InpUseSpreadCheck && InpMaxSpreadPoints < 0)
     {
      Alert("Hedge 1.0: Max Spread Points ต้องไม่ติดลบ");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(InpDeviationPoints < 0)
     {
      Alert("Hedge 1.0: Deviation Points ต้องไม่ติดลบ");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(InpEnableReport && InpReportDays <= 0)
     {
      Alert("Hedge 1.0: Report Days ต้องมากกว่า 0");
      return(INIT_PARAMETERS_INCORRECT);
     }

   //--- ไม่ใช้ Magic 0 ซึ่งอาจปะปนกับ Position แบบ Manual ภายนอก
   if(InpMagicNumber <= 0)
     {
      Alert("Hedge 1.0: Magic Number ต้องมากกว่า 0");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(!MathIsValidNumber(InpBaseLot) || InpBaseLot <= 0.0)
     {
      Alert("Hedge 1.0: Base Lot ต้องเป็นตัวเลขมากกว่า 0");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(!MathIsValidNumber(InpLotIncrement)
      || !MathIsValidNumber(InpLotStepMoney)
      || InpLotIncrement <= 0.0
      || InpLotStepMoney <= 0.0)
     {
      Alert("Hedge 1.0: Lot Increment และ Lot Step Money ต้องเป็นตัวเลขมากกว่า 0");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(InpMaxLotStep < 0)
     {
      Alert("Hedge 1.0: Max Lot Step ต้องไม่ติดลบ");
      return(INIT_PARAMETERS_INCORRECT);
     }

   //--- ทุนเริ่มต้น 0 อนุญาตสำหรับทดสอบทุนหมดและ REFILL
   if(!MathIsValidNumber(InpInitialCapital)
      || InpInitialCapital < 0.0)
     {
      Alert("Hedge 1.0: Initial Capital ต้องเป็นตัวเลขตั้งแต่ 0 ขึ้นไป");
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(!MathIsValidNumber(InpRefillAmount)
      || InpRefillAmount <= 0.0)
     {
      Alert("Hedge 1.0: Refill Amount ต้องเป็นตัวเลขมากกว่า 0");
      return(INIT_PARAMETERS_INCORRECT);
     }

   //--- ตรวจ Trailing State Key ก่อนเริ่ม Engine
   if(!ProtectInit())
      return(INIT_FAILED);

   //--- ตรวจ REFILL / Report / Cycle State และนำเข้าหากอนุญาต
   if(!HedgeStateInit())
      return(INIT_FAILED);

   //--- สตาร์ทแต่ละโมดูล
   EngineInit();    // ตั้งค่าการส่งออเดอร์ (Magic/Deviation/Filling)
   ReportInit();    // เริ่มนับรอบรายงาน CSV
   PanelInit();     // สร้าง Panel + ปุ่มทั้งหมด

   Print("Hedge1: เริ่มระบบสำเร็จ | ", _Symbol,
         " | Point=", DoubleToString(HedgePoint(), _Digits),
         " | ทุนเริ่มต้น=$", DoubleToString(InpInitialCapital, 2));
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| ปิดระบบ                                                            |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- คง State ของ Position ที่ยังเปิดไว้
   GlobalVariablesFlush();

   PanelDeinit();   // ลบวัตถุ Panel ออกจากกราฟ
   Print("Hedge1: ปิดระบบแล้ว (เหตุผล ", reason, ")");
  }

//+------------------------------------------------------------------+
//| ทำงานทุก Tick - ลำดับสำคัญ: บริหารไม้เดิมก่อน แล้วค่อยเปิดใหม่      |
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- 1) บริหาร Position เดิมก่อนเสมอ
   ProtectOnTick();

   //--- เริ่มนับ Timeout เมื่อพบ Basket ว่าง
   //--- ไม่รอให้ Report เสร็จก่อนเริ่มจับเวลาว่าง
   if(CountSide(POSITION_TYPE_BUY)
      + CountSide(POSITION_TYPE_SELL) == 0)
     {
      if(g_emptySince == 0)
         g_emptySince = TimeCurrent();
     }

   //--- 2) ให้ Report ตรวจช่วง Basket ว่างก่อนเปิดรอบใหม่
   ReportOnTick();

   //--- 3) เปิดได้เมื่อผ่าน Report/ทุน/Session/Timeout/Spread
   EngineOnTick();

   //--- 4) แสดงสถานะหลังจัดการรอบนี้
   PanelUpdate();
  }

//+------------------------------------------------------------------+
//| รับ event จากกราฟ (ปุ่มบน Panel)                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam,
                  const double &dparam, const string &sparam)
  {
   PanelOnChartEvent(id, lparam, dparam, sparam);
  }