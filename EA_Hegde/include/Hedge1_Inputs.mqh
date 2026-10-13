//+------------------------------------------------------------------+
//|                                              Hedge1_Inputs.mqh   |
//|  EA Hedge 1.0 - input ทั้งหมด ตาม Blueprint หัวข้อ 1-5          |
//+------------------------------------------------------------------+
#ifndef HEDGE1_INPUTS_MQH
#define HEDGE1_INPUTS_MQH

//--- โหมด Auto Break-even (3 ตัวเลือก ตาม Blueprint)
enum ENUM_BE_MODE
  {
   BE_OFF      = 0,   // false (ปิดใช้งาน)
   BE_FIXED    = 1,   // ไม่เลื่อน (ตั้ง SL ครั้งเดียว แล้วหยุด)
   BE_TRAILING = 2    // เลื่อนตาม (SL ขยับตามราคา)
  };

//====================== 1. Virtual Capital Auto-Lot ==============
input group "=== 1. Virtual Capital Auto-Lot ==="
input int    InpPointDigits     = 2;      // ทศนิยมตำแหน่ง Point ของคู่เงินตาม Broker (เช่น XAUUSD 2 ตำแหน่ง: 1 Point = $0.01)
input double InpInitialCapital  = 50.0;   // ทุนเริ่มต้นจำลองต่อบอท ($)
input double InpRefillAmount    = 10.0;   // กดปุ่ม REFILL หนึ่งครั้ง เพิ่มทุนเสมือน ($)
input double InpBaseLot         = 0.01;   // ขนาด Lot เริ่มต้น
input bool   InpAutoLot         = true;   // เปิดระบบคำนวณ Lot อัตโนมัติ
input double InpLotStepMoney    = 50.0;   // ขึ้นบันไดเพิ่ม Lot ทุกๆ ($)
input double InpLotIncrement   = 0.01;   // ขนาด Lot ที่เพิ่มขึ้นบันได
input int    InpMaxLotStep      = 4;      // Lot สูงสุดที่อนุญาต คูณ 0.01 (เช่น 4 = ไม่เกิน 0.04 / 0 = ไม่จำกัด)

//====================== 2. Tactical Hedging & Auto Refill =========
input group "=== 2. Tactical Hedging & Auto Refill ==="
input bool   InpReopenOnEmpty   = true;   // เปิดออเดอร์รอบใหม่อัตโนมัติเมื่อ Basket ว่าง
input bool   InpReopenClosedSide= false;  // ไม่ใช้ในโหมด 1 Basket: ต้องรอ Basket ว่างก่อนจึงเปิดรอบใหม่
input bool   InpUseTimeout      = true;   // ใช้ Timeout บังคับเปิดรอบใหม่
input int    InpTimeoutSeconds  = 300;    // Timeout บังคับเปิดรอบใหม่ (วินาที)
input bool   InpUseSpreadCheck  = true;   // ใช้ตรวจสเปรดก่อนเปิด
input int    InpMaxSpreadPoints = 25;     // สเปรดสูงสุดที่ยอมให้เปิด (Points)
input int    InpDeviationPoints = 10;     // ค่าเบี่ยงเบนราคาสูงสุดตอนส่งคำสั่ง (Points)

//====================== 3. Profit Protection & TP Controls =========
input group "=== 3. Profit Protection & TP Controls ==="
input int    InpCutLossPoints   = 1000;   // ตัดขาดทุนรายไม้เมื่อผิดทาง (Points)
input ENUM_BE_MODE InpBreakEvenMode = BE_TRAILING; // เปิดใช้งาน Auto Break-even แบบสัดส่วน
input double InpBreakEvenPct    = 20.0;   // % ของ Trigger (ล็อกกำไรตามสัดส่วน)
input int    InpBreakEvenTrigger= 1000;  // เริ่มกันทุนเมื่อราคาบวกถึง (Points)
input int    InpBreakEvenStep   = 100;    // ขยับเลื่อน SL ทุกๆ (Points) - ใช้เฉพาะโหมดเลื่อนตาม
input double InpRRPercent       = 200.0;  // เป้ากำไรต่อ Order R:R (% ของ Break-even Trigger) | 200%=ปิดที่ +2000 Points
input bool   InpUseTrailingTP   = true;   // เปิดระบบ Trailing TP ตามราคาที่ดีที่สุด
input int    InpTrailingPullback= 500;    // ระยะย้อนกลับจากราคาดีที่สุดก่อนปิด (Points)

//====================== 4. Sessions (ช่วงเวลาหยุดเทรด) ============
input group "=== 4. Sessions ช่วงเวลาหยุดเทรด (true = หยุดช่วงนี้) ==="
input bool   InpSession1Block   = false;  // Sessions 1: เปิดใช้ช่วงหยุดนี้
input string InpSession1Start   = "01:00";// เวลาเริ่ม (เซิร์ฟเวอร์)
input string InpSession1End     = "04:00";// เวลาจบ (เริ่มวันใหม่)
input bool   InpSession2Block   = false;  // Sessions 2: เปิดใช้ช่วงหยุดนี้
input string InpSession2Start   = "07:00";// เวลาเริ่ม (เซิร์ฟเวอร์)
input string InpSession2End     = "12:00";// เวลาจบ
input bool   InpSession3Block   = false;  // Sessions 3: เปิดใช้ช่วงหยุดนี้
input string InpSession3Start   = "21:00";// เวลาเริ่ม (เซิร์ฟเวอร์)
input string InpSession3End     = "24:00";// เวลาจบ (ปิดรอบวัน)

//====================== 5. System Identity & Blackbox =============
input group "=== 5. System Identity & Blackbox ==="
input long   InpMagicNumber     = 998874;                  // รหัสประจำตัว Magic Number
input string InpTradeComment    = "Hedge 1.0 [1000 RR 1:2]";// คอมเมนต์ประจำตัว (แสดงบน Panel)
input bool   InpEnableReport    = true;   // สรุปรายงานกำไรขาดทุนเป็นไฟล์ CSV
input int    InpReportDays      = 5;      // สร้าง CSV ทุกกี่วัน (เมื่อ Basket ว่าง)

#endif // HEDGE1_INPUTS_MQH