//+------------------------------------------------------------------+
//|                                                   Hedge1.0.mq5   |
//|  EA Hedge 1.0 - Virtual Capital + Tactical Hedging                |
//|  โครงสร้าง: 1 ไฟล์ = 1 หน้าที่ (แบบชิป IC) ประกอบผ่าน include   |
//|  ลำดับการทำงานต่อ Tick:                                          |
//|    1) Protect  - บริหารไม้ที่เปิดค้าง (Cut Loss/BE/RR/Trailing)  |
//|    2) Engine   - เปิดรอบใหม่/เปิดฝั่งที่หาย (Session/Timeout)     |
//|    3) Report   - ตรวจสร้าง CSV ราย 5 วัน                          |
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

   if(InpBreakEvenTrigger <= 0 && InpBreakEvenMode != BE_OFF)
     {
      Alert("Hedge 1.0: Break-even Trigger ต้องมากกว่า 0 ถ้าเปิดใช้ Break-even");
      return(INIT_FAILED);
     }

   //--- ตรวจ Trailing State Key ก่อนเริ่ม Engine
   if(!ProtectInit())
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
   ProtectOnTick();   // 1) Cut Loss, Break-even, RR, Trailing TP (ทำตลอด แม้ Session บล็อก)
   EngineOnTick();    // 2) เปิดรอบใหม่ / เปิดฝั่งที่โดนปิด (เช็ค Session/ทุน/Timeout/สเปรด)
   ReportOnTick();    // 3) ตรวจครบ 5 วัน + Basket ว่าง = สร้าง CSV
   PanelUpdate();     // 4) รีเฟรชข้อมูลบนจอ
  }

//+------------------------------------------------------------------+
//| รับ event จากกราฟ (ปุ่มบน Panel)                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam,
                  const double &dparam, const string &sparam)
  {
   PanelOnChartEvent(id, lparam, dparam, sparam);
  }