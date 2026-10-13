//+------------------------------------------------------------------+
//|                                              HedgeUI_Theme.mqh   |
//| UI_THEME: HEDGE_DARK_NEON_V1                                    |
//| Dark Trading Dashboard Theme for MetaTrader 5 EA Panels          |
//+------------------------------------------------------------------+
#ifndef HEDGE_UI_THEME_MQH
#define HEDGE_UI_THEME_MQH

//====================================================================
//  1. FONT STANDARD
//====================================================================

//--- Font หลักของ Panel ทั้งหมด
#define HUI_FONT             "Arial Bold"

//--- ขนาด Font: Normal Mode
#define HUI_FONT_HEADER      10
#define HUI_FONT_NORMAL       9
#define HUI_FONT_IMPORTANT   10
#define HUI_FONT_BUTTON       9
#define HUI_FONT_FOOTER       9

//--- ขนาด Font: Compact Mode
#define HUI_FONT_HEADER_C     9
#define HUI_FONT_NORMAL_C     8
#define HUI_FONT_IMPORTANT_C  9
#define HUI_FONT_BUTTON_C     8
#define HUI_FONT_FOOTER_C     8

//====================================================================
//  2. PANEL COLORS
//====================================================================

//--- พื้นหลังและขอบ
#define HUI_BG               C'18,18,18'       // #121212 พื้นหลัง Dark
#define HUI_BORDER           C'51,51,51'       // #333333 ขอบ Panel
#define HUI_HEADER           C'255,215,0'      // #FFD700 Header / Footer ทอง
#define HUI_TEXT             clrWhite          // สีขาวสำหรับค่าปกติ/ค่า 0
#define HUI_LABEL            C'225,225,225'    // Label ทั่วไป ขาวอมเทาสว่าง

//====================================================================
//  3. STATUS / FINANCIAL COLORS
//====================================================================

//--- ค่าสำคัญ
#define HUI_CYAN             C'0,255,255'      // Effective Lot
#define HUI_GREEN            C'0,255,125'      // Equity / Profit / ON / OPEN
#define HUI_RED              C'255,85,75'      // Loss / OFF / BLOCK
#define HUI_YELLOW           C'255,215,0'      // Active Position > 0

//--- จำนวน Position แยกตามฝั่ง
#define HUI_BUY_TEXT         C'80,165,255'     // Buy > 0
#define HUI_SELL_TEXT        C'255,95,90'      // Sell > 0

//====================================================================
//  4. BUTTON COLORS
//====================================================================

//--- ปุ่มเปิด Buy
#define HUI_BTN_BUY          C'30,86,160'      // #1E56A0
#define HUI_FRAME_BUY        C'30,86,160'

//--- ปุ่มเปิด Sell
#define HUI_BTN_SELL         C'217,83,79'      // #D9534F
#define HUI_FRAME_SELL       C'217,83,79'

//--- ปุ่ม Close Buy: น้ำเงินเข้ม + กรอบฟ้าสว่าง
#define HUI_BTN_CLOSE_BUY    C'18,55,96'
#define HUI_FRAME_CLOSE_BUY  C'53,135,235'

//--- ปุ่ม Close Sell: แดงเข้ม + กรอบแดงสว่าง
#define HUI_BTN_CLOSE_SELL   C'112,38,42'
#define HUI_FRAME_CLOSE_SELL C'245,92,86'

//--- ปุ่ม Refill
#define HUI_BTN_REFILL       C'64,64,64'
#define HUI_FRAME_REFILL     C'51,51,51'

//--- ปุ่ม Hedge Open
#define HUI_BTN_HEDGE        C'106,27,154'
#define HUI_FRAME_HEDGE      C'106,27,154'

//--- ปุ่ม Close All
#define HUI_BTN_CLOSE_ALL    C'184,134,11'
#define HUI_FRAME_CLOSE_ALL  C'51,51,51'

//====================================================================
//  5. PANEL DIMENSIONS
//====================================================================

//--- Normal Mode
#define HUI_PANEL_X          8
#define HUI_PANEL_Y          28
#define HUI_PANEL_W_NORMAL   430
#define HUI_PANEL_H_NORMAL   360
#define HUI_PANEL_H_MIN      36

//--- Responsive Breakpoints
#define HUI_PANEL_COMPACT_AT 520
#define HUI_PANEL_MIN_AT     330

//--- ขนาดกรอบหนารอบปุ่ม CLOSE BUY / CLOSE SELL
#define HUI_CLOSE_FRAME_PAD  3

//====================================================================
//  6. PANEL RULES (COMMENT FOR FUTURE DEVELOPERS)
//====================================================================

/*
UI_THEME: HEDGE_DARK_NEON_V1 (LOCKED)

FONT:
- ใช้ Arial Bold ทุก Label และ Button
- Header 10 px / Normal 9 px / Important 10 px
- Compact ลดลงเล็กน้อย แต่ต้องอ่านง่าย

COLOR RULES:
- Positive Value      = HUI_GREEN
- Negative Value      = HUI_RED
- Zero / Neutral      = HUI_TEXT
- Effective Lot       = HUI_CYAN
- Virtual Equity      = HUI_GREEN เมื่อ > 0, HUI_RED เมื่อ <= 0
- Closed Net          = HUI_GREEN เมื่อ > 0, HUI_RED เมื่อ < 0, HUI_TEXT เมื่อ = 0
- Open Floating       = HUI_GREEN เมื่อ > 0, HUI_RED เมื่อ < 0, HUI_TEXT เมื่อ = 0
- Cycle Loss          = HUI_RED เมื่อ < 0, HUI_TEXT เมื่อ = 0

POSITION COLOR RULES:
- Active > 0          = HUI_YELLOW
- Active = 0          = HUI_TEXT
- Buy > 0             = HUI_BUY_TEXT
- Buy = 0             = HUI_TEXT
- Sell > 0            = HUI_SELL_TEXT
- Sell = 0            = HUI_TEXT

STATUS COLOR RULES:
- Session OPEN        = HUI_GREEN ทั้งแถว
- Session BLOCK/CLOSE = HUI_RED ทั้งแถว
- Spread Check ON     = HUI_GREEN ทั้งแถว
- Spread Check OFF    = HUI_RED ทั้งแถว
- Timeout ON          = HUI_GREEN ทั้งแถว
- Timeout OFF         = HUI_RED ทั้งแถว

BUTTON RULES:
- BUY                 = น้ำเงิน
- SELL                = แดง
- CLOSE BUY           = น้ำเงินเข้ม + กรอบฟ้าหนาขนาด HUI_CLOSE_FRAME_PAD
- CLOSE SELL          = แดงเข้ม + กรอบแดงหนาขนาด HUI_CLOSE_FRAME_PAD
- REFILL              = เทา
- HEDGE OPEN          = ม่วง
- CLOSE ALL           = มัสตาร์ด

LAYOUT:
- Normal: 430 x 360 px
- Compact: เมื่อความกว้างกราฟ < 520 px
- Auto Minimize: เมื่อความกว้างกราฟ < 330 px
- Footer อยู่ด้านขวาใต้ปุ่ม CLOSE ALL
- Panel ต้องมีปุ่ม - / + สำหรับ Minimize
*/

#endif // HEDGE_UI_THEME_MQH