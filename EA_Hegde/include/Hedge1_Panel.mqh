//+------------------------------------------------------------------+
//|                                              Hedge1_Panel.mqh    |
//|  Responsive Panel: ข้อมูล 2 ฝั่ง + ปุ่ม Manual + Minimize        |
//|  รองรับกราฟขนาดเล็ก / ปรับ layout เมื่อย่อหรือขยายหน้าต่าง       |
//+------------------------------------------------------------------+
#ifndef HEDGE1_PANEL_MQH
#define HEDGE1_PANEL_MQH

#include "Hedge1_Inputs.mqh"
#include "Hedge1_Capital.mqh"
#include "Hedge1_Session.mqh"
#include "Hedge1_Engine.mqh"
#include "Hedge1_Protect.mqh"
#include "Hedge1_Utils.mqh"

//--- Prefix ป้องกันชนกับ Object ของ EA/Indicator ตัวอื่น
#define PANEL_PREFIX "H1P_"

//--- สีตาม Blueprint
#define COL_BG       C'18,18,18'
#define COL_BORDER   C'51,51,51'
#define COL_HEADER   C'255,215,0'
#define COL_TEXT     clrWhite

//--- ป้ายชื่อข้อมูลทั่วไป: สว่างกว่า Silver เดิม อ่านง่ายบนพื้นดำ
#define COL_DIM      C'225,225,225'

//--- สี Neon สำหรับข้อมูลสำคัญตามภาพตัวอย่าง
#define COL_CYAN     C'0,255,255'
#define COL_EQUITY   C'0,255,125'
#define COL_PROFIT   C'0,255,125'

//--- สีแดง/ส้มสำหรับขาดทุนหรือสถานะเตือน
#define COL_WARN     C'255,85,75'

//--- สีสถานะจำนวน Position
#define COL_ACTIVE   C'255,215,0'
#define COL_BUY_TEXT C'80,165,255'
#define COL_SELL_TEXT C'255,95,90'

#define COL_BUY      C'30,86,160'
#define COL_SELL     C'217,83,79'
#define COL_HEDGE         C'106,27,154'
#define COL_MUSTARD       C'184,134,11'
#define COL_GRAY          C'64,64,64'

//--- สีเฉพาะปุ่มปิดฝั่ง Buy/Sell: ลดสีส้ม เพิ่มการแยกสีให้ชัดเจน
#define COL_CLOSE_BUY_BG    C'18,55,96'
#define COL_CLOSE_BUY_FRAME C'53,135,235'

#define COL_CLOSE_SELL_BG    C'112,38,42'
#define COL_CLOSE_SELL_FRAME C'245,92,86'

//--- สถานะ Panel
bool g_panelReady         = false;
bool g_panelMinimized     = false;
bool g_panelAutoMinimized = false;
bool g_panelCompact       = false;

//--- ขนาด/ตำแหน่งที่คำนวณตามขนาดกราฟ
int g_panelX       = 10;
int g_panelY       = 28;
int g_panelW       = 390;
int g_panelHFull   = 344;
int g_panelHMin    = 36;
int g_panelBtnX    = 232;
int g_panelBtnW    = 146;
int g_panelNameX   = 14;
int g_panelValueX  = 118;
int g_panelFont    = 8;
int g_panelHeadFont= 9;

//+------------------------------------------------------------------+
//| สร้างชื่อ Object ของ Panel                                       |
//+------------------------------------------------------------------+
string PName(string id)
  {
   return(PANEL_PREFIX + id);
  }

//+------------------------------------------------------------------+
//| อ่านความกว้างของกราฟเป็น Pixel                                   |
//+------------------------------------------------------------------+
int PanelChartWidth()
  {
   long width = 0;
   if(!ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0, width))
      return(900);
   return((int)width);
  }

//+------------------------------------------------------------------+
//| ตรวจว่า Panel อยู่ในโหมดซ่อนรายละเอียดหรือไม่                    |
//+------------------------------------------------------------------+
bool PanelIsMinimized()
  {
   return(g_panelMinimized || g_panelAutoMinimized);
  }

//+------------------------------------------------------------------+
//| คำนวณ Layout ตามความกว้างของกราฟ                                 |
//| >=520 px : Normal 390 px                                         |
//| 330-519  : Compact ลดความกว้าง/Font                              |
//| <330 px  : Auto Minimize เพื่อไม่ให้ Panel ล้นจอ                  |
//+------------------------------------------------------------------+
bool PanelRefreshLayoutMetrics()
  {
   int chartW = PanelChartWidth();

   bool oldCompact = g_panelCompact;
   bool oldAutoMin = g_panelAutoMinimized;
   int  oldW       = g_panelW;

   g_panelCompact       = (chartW < 520);
   g_panelAutoMinimized = (chartW < 330);

   if(!g_panelCompact)
     {
      //--- Normal Mode: ขยาย Panel เพื่อให้ตัวหนังสือฝั่งซ้ายอ่านสบาย
      g_panelW        = 430;
      g_panelHFull    = 360;

      //--- ขยับฝั่งปุ่มไปขวา และขยายปุ่มเล็กน้อย
      g_panelBtnX     = 252;
      g_panelBtnW     = 168;

      //--- เพิ่มพื้นที่ให้ชื่อและค่าฝั่งซ้าย
      g_panelNameX    = 14;
      g_panelValueX   = 132;

      //--- Font ปกติและ Header ใหญ่ขึ้น
      g_panelFont     = 9;
      g_panelHeadFont = 10;
     }
   else
     {
      //--- เว้นขอบซ้าย/ขวา 8 px เสมอ แต่ไม่เล็กกว่า 300 px
      g_panelW        = chartW - 16;
      if(g_panelW < 300)
         g_panelW = 300;
      if(g_panelW > 360)
         g_panelW = 360;

      g_panelHFull    = 360;
      g_panelBtnX     = 184;
      g_panelBtnW     = g_panelW - g_panelBtnX - 10;
      g_panelNameX    = 12;
      g_panelValueX   = 104;

      //--- Compact ยังต้องอ่านได้ ไม่ลดเล็กเกินไป
      g_panelFont     = 8;
      g_panelHeadFont = 9;
     }

   g_panelX = 8;
   g_panelY = 28;

   return(oldCompact != g_panelCompact ||
          oldAutoMin != g_panelAutoMinimized ||
          oldW != g_panelW);
  }

//+------------------------------------------------------------------+
//| ลบ Object เฉพาะของ Panel นี้                                     |
//+------------------------------------------------------------------+
void PanelDeleteObjects()
  {
   ObjectsDeleteAll(0, PANEL_PREFIX, -1, -1);
  }

//+------------------------------------------------------------------+
//| สร้าง/อัปเดต Label                                                |
//+------------------------------------------------------------------+
void PanelLabel(string id,
                string text,
                int x,
                int y,
                color clr,
                int fontSize = 8,
                string font = "Arial Bold")
  {
   string name = PName(id);

   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);

   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| สร้างกรอบสีหนารอบปุ่ม เพื่อแยก Buy / Sell ให้เห็นชัด              |
//+------------------------------------------------------------------+
void PanelFrame(string id,
                int x,
                int y,
                int w,
                int h,
                color frameColor)
  {
   string name = PName(id);

   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);

   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, frameColor);
   ObjectSetInteger(0, name, OBJPROP_COLOR, frameColor);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 5);
  }

//+------------------------------------------------------------------+
//| สร้าง/อัปเดต Button                                               |
//+------------------------------------------------------------------+
void PanelButton(string id,
                 string text,
                 int x,
                 int y,
                 int w,
                 int h,
                 color bg,
                 color border,
                 int fontSize = 9)
  {
   string name = PName(id);

   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);

   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, border);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, name, OBJPROP_STATE, false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 10);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| เลือกสีตามสถานะตัวเลข                                            |
//| บวก = เขียว / ลบ = แดง / ศูนย์ = ขาว                            |
//+------------------------------------------------------------------+
color PanelSignColor(double value)
  {
   if(value > 0.0)
      return(COL_PROFIT);

   if(value < 0.0)
      return(COL_WARN);

   return(COL_TEXT);
  }

//+------------------------------------------------------------------+
//| อัปเดตข้อความและสี Label                                         |
//+------------------------------------------------------------------+
void PanelSet(string id, string text, color clr)
  {
   string name = PName(id);
   if(ObjectFind(0, name) < 0)
      return;

   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//| ซ่อน/แสดง Object บนกราฟจริง                                      |
//| ใช้ Timeframes = 0 เพื่อซ่อนจริง ไม่ใช่แค่ซ่อนจาก Object List     |
//+------------------------------------------------------------------+
void PanelSetVisible(string id, bool show)
  {
   string name = PName(id);
   if(ObjectFind(0, name) < 0)
      return;

   ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES,
                    show ? OBJ_ALL_PERIODS : 0);
  }

//+------------------------------------------------------------------+
//| เปลี่ยนข้อความ Footer ให้ขึ้นบรรทัดใหม่ก่อน [ ... ]              |
//+------------------------------------------------------------------+
string PanelFooterText()
  {
   string footer = InpTradeComment;

   int bracketPos = StringFind(footer, "[");
   if(bracketPos > 0)
     {
      string leftPart  = StringSubstr(footer, 0, bracketPos);
      string rightPart = StringSubstr(footer, bracketPos);
      StringTrimRight(leftPart);
      footer = leftPart + "\n" + rightPart;
     }

   return(footer);
  }

//+------------------------------------------------------------------+
//| กำไรลอยตัวรวมของ EA นี้                                           |
//+------------------------------------------------------------------+
double GetFloatingPL()
  {
   double sum = 0.0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;

      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;

      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;

      sum += PositionGetDouble(POSITION_PROFIT);
      sum += PositionGetDouble(POSITION_SWAP);
     }

   return(sum);
  }

//+------------------------------------------------------------------+
//| Cycle Loss: ขาดทุนปิดแล้วในรอบ Basket ปัจจุบัน                   |
//+------------------------------------------------------------------+
double GetCycleLoss()
  {
   int total = CountSide(POSITION_TYPE_BUY) + CountSide(POSITION_TYPE_SELL);

   string gvTotal = "HEDGE1_" + IntegerToString(InpMagicNumber) + "_RTOT";
   string gvNet   = "HEDGE1_" + IntegerToString(InpMagicNumber) + "_RNET";

   int previousTotal = 0;
   if(GlobalVariableCheck(gvTotal))
      previousTotal = (int)GlobalVariableGet(gvTotal);

   //--- จาก Basket ว่าง -> มีไม้ = เริ่ม Cycle ใหม่
   if(previousTotal == 0 && total > 0)
      GlobalVariableSet(gvNet, GetClosedNet());

   GlobalVariableSet(gvTotal, total);

   if(!GlobalVariableCheck(gvNet))
      return(0.0);

   double cycleNet = GetClosedNet() - GlobalVariableGet(gvNet);

   //--- แสดงเฉพาะขาดทุน ถ้ากำไรให้แสดง 0
   if(cycleNet < 0.0)
      return(cycleNet);

   return(0.0);
  }

//+------------------------------------------------------------------+
//| ใช้สถานะ Minimize / Responsive กับ Object ทุกตัว                 |
//+------------------------------------------------------------------+
void PanelApplyVisibility()
  {
   bool showDetail = !PanelIsMinimized();

   string detailObjects[] =
     {
      "S1",
      "N_SESS", "V_SESS",
      "N_SPRD", "V_SPRD",
      "N_TIME", "V_TIME",

      "S2",
      "N_BASE", "V_BASE",
      "N_STEP", "V_STEP",
      "N_LOT",  "V_LOT",
      "N_EQ",   "V_EQ",
      "N_NET",  "V_NET",
      "N_CYC",  "V_CYC",

      "S3",
      "N_FLOAT", "V_FLOAT",

      "N_ACT",
      "V_ACT_TOTAL",
      "V_ACT_BUY",
      "V_ACT_SELL",

      "N_CUT",   "V_CUT",

      "B_BUY",
      "B_SELL",

      "F_CLBUY",
      "B_CLBUY",

      "F_CLSELL",
      "B_CLSELL",

      "B_REFILL",
      "B_HEDGE",
      "B_CLALL",
      "FOOT"
     };

   for(int i = 0; i < ArraySize(detailObjects); i++)
      PanelSetVisible(detailObjects[i], showDetail);

   string bg = PName("BG");
   if(ObjectFind(0, bg) >= 0)
     {
      ObjectSetInteger(0, bg, OBJPROP_YSIZE,
                       showDetail ? g_panelHFull : g_panelHMin);
     }

   string minButton = PName("MIN");
   if(ObjectFind(0, minButton) >= 0)
      ObjectSetString(0, minButton, OBJPROP_TEXT,
                      showDetail ? "-" : "+");

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| สร้าง Panel ตาม Layout ปัจจุบัน                                   |
//+------------------------------------------------------------------+
void PanelBuild()
  {
   PanelDeleteObjects();
   PanelRefreshLayoutMetrics();

   int px = g_panelX;
   int py = g_panelY;

   int nameX  = px + g_panelNameX;
   int valueX = px + g_panelValueX;
   int btnX   = px + g_panelBtnX;
   int btnW   = g_panelBtnW;

   int labelFont = g_panelFont;
   int sectionFont = (g_panelCompact ? 7 : 7);
   int buttonFont = (g_panelCompact ? 8 : 9);

   //--- พื้นหลัง
   string bg = PName("BG");
   ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bg, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, px);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, py);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE, g_panelW);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE, g_panelHFull);
   ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, COL_BG);
   ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bg, OBJPROP_COLOR, COL_BORDER);
   ObjectSetInteger(0, bg, OBJPROP_BACK, false);
   ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bg, OBJPROP_HIDDEN, true);

   //--- Header
   PanelLabel("HDR",
              "Hedge 1.0 | " + _Symbol + " [" + IntegerToString(InpMagicNumber) + "]",
              px + 12,
              py + 10,
              COL_HEADER,
              g_panelHeadFont,
              "Arial Bold");

   PanelButton("MIN",
               "-",
               px + g_panelW - 30,
               py + 6,
               22,
               18,
               COL_GRAY,
               COL_BORDER,
               9);

   //--- STATUS
   PanelLabel("S1", "STATUS", nameX, py + 35, COL_DIM, sectionFont, "Arial Bold");

   PanelLabel("N_SESS", "Session:",      nameX,  py + 52, COL_DIM, labelFont);
   PanelLabel("V_SESS", "-",             valueX, py + 52, COL_TEXT, labelFont);

   PanelLabel("N_SPRD", "Spread:",       nameX,  py + 70, COL_DIM, labelFont);
   PanelLabel("V_SPRD", "-",             valueX, py + 70, COL_TEXT, labelFont);

   PanelLabel("N_TIME", "Refill Timer:", nameX,  py + 88, COL_DIM, labelFont);
   PanelLabel("V_TIME", "-",             valueX, py + 88, COL_TEXT, labelFont);

   //--- LOT & CAPITAL
   PanelLabel("S2", "LOT & CAPITAL", nameX, py + 111, COL_DIM, sectionFont, "Arial Bold");

   PanelLabel("N_BASE", "Base Lot:",        nameX,  py + 128, COL_DIM, labelFont);
   PanelLabel("V_BASE", "-",                valueX, py + 128, COL_TEXT, labelFont);

   PanelLabel("N_STEP", "Lot Step:",        nameX,  py + 146, COL_DIM, labelFont);
   PanelLabel("V_STEP", "-",                valueX, py + 146, COL_TEXT, labelFont);

   //--- 3 ค่าหลัก: ทั้งชื่อและตัวเลขเป็น Bold + Neon ตามภาพตัวอย่าง
   PanelLabel("N_LOT", "Effective Lot:",    nameX,  py + 164, COL_CYAN, labelFont + 1, "Arial Bold");
   PanelLabel("V_LOT", "-",                 valueX, py + 164, COL_CYAN, labelFont + 1, "Arial Bold");

   PanelLabel("N_EQ", "Virtual Equity:",    nameX,  py + 182, COL_EQUITY, labelFont + 1, "Arial Bold");
   PanelLabel("V_EQ", "-",                  valueX, py + 182, COL_EQUITY, labelFont + 1, "Arial Bold");

   PanelLabel("N_NET", "Closed Net:",       nameX,  py + 200, COL_PROFIT, labelFont + 1, "Arial Bold");
   PanelLabel("V_NET", "-",                 valueX, py + 200, COL_PROFIT, labelFont + 1, "Arial Bold");

   PanelLabel("N_CYC", "Cycle Loss:",       nameX,  py + 218, COL_DIM, labelFont);
   PanelLabel("V_CYC", "-",                 valueX, py + 218, COL_TEXT, labelFont);

   //--- POSITIONS
   PanelLabel("S3", "POSITIONS", nameX, py + 241, COL_DIM, sectionFont, "Arial Bold");

   PanelLabel("N_FLOAT", "Open Floating:", nameX,  py + 258, COL_DIM, labelFont);
   PanelLabel("V_FLOAT", "-",              valueX, py + 258, COL_TEXT, labelFont);

   //--- Active / Buy / Sell แยก Label เพื่อใช้คนละสีได้
   PanelLabel("N_ACT",       "Active:",    nameX,            py + 276, COL_DIM, labelFont);
   PanelLabel("V_ACT_TOTAL", "-",          valueX,           py + 276, COL_TEXT, labelFont, "Arial Bold");
   PanelLabel("V_ACT_BUY",   "-",          valueX + 22,      py + 276, COL_TEXT, labelFont, "Arial Bold");
   PanelLabel("V_ACT_SELL",  "-",          valueX + 72,      py + 276, COL_TEXT, labelFont, "Arial Bold");

   PanelLabel("N_CUT", "Cut Loss Limit:",  nameX,  py + 294, COL_DIM, labelFont);
   PanelLabel("V_CUT", "-",                valueX, py + 294, COL_TEXT, labelFont);

   //--- ปุ่มเปิดไม้เดี่ยวถูกล็อกใน Strict Basket Mode
   PanelButton("B_BUY",
               "BUY LOCKED",
               btnX, py + 51, btnW, 26,
               COL_GRAY, COL_BORDER, buttonFont);

   PanelButton("B_SELL",
               "SELL LOCKED",
               btnX, py + 83, btnW, 26,
               COL_GRAY, COL_BORDER, buttonFont);

   ObjectSetInteger(0, PName("B_BUY"),
                    OBJPROP_COLOR, COL_DIM);

   ObjectSetInteger(0, PName("B_SELL"),
                    OBJPROP_COLOR, COL_DIM);

   ObjectSetString(0, PName("B_BUY"),
                   OBJPROP_TOOLTIP,
                   "Strict Basket: single BUY blocked. Use HEDGE OPEN (B+S).");

   ObjectSetString(0, PName("B_SELL"),
                   OBJPROP_TOOLTIP,
                   "Strict Basket: single SELL blocked. Use HEDGE OPEN (B+S).");

   //--- CLOSE BUY: กรอบน้ำเงินหนา 3 px + พื้นน้ำเงินเข้ม
   PanelFrame("F_CLBUY",
              btnX - 3, py + 112, btnW + 6, 32,
              COL_CLOSE_BUY_FRAME);

   PanelButton("B_CLBUY",
               "CLOSE BUY",
               btnX, py + 115, btnW, 26,
               COL_CLOSE_BUY_BG, COL_CLOSE_BUY_BG, buttonFont);

   //--- CLOSE SELL: กรอบแดงหนา 3 px + พื้นแดงเข้ม
   PanelFrame("F_CLSELL",
              btnX - 3, py + 144, btnW + 6, 32,
              COL_CLOSE_SELL_FRAME);

   PanelButton("B_CLSELL",
               "CLOSE SELL",
               btnX, py + 147, btnW, 26,
               COL_CLOSE_SELL_BG, COL_CLOSE_SELL_BG, buttonFont);

   PanelButton("B_REFILL",
               "REFILL $" + DoubleToString(InpRefillAmount, 0),
               btnX, py + 179, btnW, 26,
               COL_GRAY, COL_BORDER, buttonFont);

   PanelButton("B_HEDGE",
               "HEDGE OPEN (B+S)",
               btnX, py + 211, btnW, 26,
               COL_HEDGE, COL_HEDGE, buttonFont);

   PanelButton("B_CLALL",
               "CLOSE ALL",
               btnX, py + 243, btnW, 26,
               COL_MUSTARD, COL_BORDER, buttonFont);

   //--- Footer ย้ายไปฝั่งขวา ใต้ปุ่ม CLOSE ALL
   PanelLabel("FOOT",
              PanelFooterText(),
              btnX + 4,
              py + 280,
              COL_HEADER,
              (g_panelCompact ? 8 : 9),
              "Arial Bold");

   g_panelReady = true;
   PanelApplyVisibility();
   PanelUpdate();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| เริ่ม Panel                                                       |
//+------------------------------------------------------------------+
void PanelInit()
  {
   g_panelReady = false;
   PanelBuild();
  }

//+------------------------------------------------------------------+
//| ตรวจว่าต้อง Rebuild Panel หรือไม่ เมื่อกราฟถูกย่อ/ขยาย            |
//+------------------------------------------------------------------+
void PanelCheckResponsiveLayout()
  {
   if(!g_panelReady)
      return;

   if(PanelRefreshLayoutMetrics())
      PanelBuild();
  }

//+------------------------------------------------------------------+
//| อัปเดตข้อมูลใน Panel                                              |
//+------------------------------------------------------------------+
void PanelUpdate()
  {
   if(!g_panelReady)
      return;

   //--- STATUS
   //--- สีทั้งแถว: เขียว = ระบบเปิด/พร้อมใช้งาน, แดง = ปิดหรือถูก Block

   //--- Session: OPEN = เขียว / BLOCK = แดง
   string sessionStatus = GetSessionStatusText();
   color sessionColor = (sessionStatus == "OPEN") ? COL_PROFIT : COL_WARN;

   PanelSet("N_SESS", "Session:", sessionColor);
   PanelSet("V_SESS", sessionStatus, sessionColor);

   //--- Spread Check: ON = เขียว / OFF = แดง
   string spreadText = DoubleToString(GetSpreadPoints(), 0)
                       + " / Trigger "
                       + IntegerToString(InpMaxSpreadPoints)
                       + (InpUseSpreadCheck ? " (ON)" : " (OFF)");

   color spreadStatusColor = InpUseSpreadCheck ? COL_PROFIT : COL_WARN;

   PanelSet("N_SPRD", "Spread:", spreadStatusColor);
   PanelSet("V_SPRD", spreadText, spreadStatusColor);

   //--- Timeout / Refill Timer: ON = เขียว / OFF = แดง
   string timerText = IntegerToString(GetTimeoutRemaining())
                      + " / "
                      + IntegerToString(InpTimeoutSeconds)
                      + " sec"
                      + (InpUseTimeout ? " (ON)" : " (OFF)");

   color timerStatusColor = InpUseTimeout ? COL_PROFIT : COL_WARN;

   PanelSet("N_TIME", "Refill Timer:", timerStatusColor);
   PanelSet("V_TIME", timerText, timerStatusColor);

   //--- LOT & CAPITAL
   double equity = GetVirtualEquity();

   int steps = 1;
   if(InpLotStepMoney > 0.0)
      steps = (int)MathFloor(equity / InpLotStepMoney);

   if(steps < 1)
      steps = 1;

   PanelSet("V_BASE", DoubleToString(InpBaseLot, 2), COL_TEXT);

   PanelSet("V_STEP",
            "+" + DoubleToString(InpLotIncrement, 2)
            + " / $"
            + DoubleToString(InpLotStepMoney, 0)
            + " (step "
            + IntegerToString(steps)
            + ")",
            COL_TEXT);

   //--- Effective Lot = Cyan เด่น
   PanelSet("V_LOT", DoubleToString(GetEffectiveLot(), 2), COL_CYAN);

   //--- Virtual Equity = เขียวสด
   //--- Virtual Equity: บวกเขียว / ลบแดง / ศูนย์ขาว
   color equityColor = PanelSignColor(equity);

   PanelSet("N_EQ", "Virtual Equity:", equityColor);
   PanelSet("V_EQ", "$" + DoubleToString(equity, 2), equityColor);

   //--- Closed Net = เขียวเมื่อกำไร / แดงเมื่อขาดทุน
   double closedNet = GetClosedNet();

   //--- Closed Net เขียวเมื่อกำไร / แดงเมื่อขาดทุน ทั้งชื่อและตัวเลข
   color closedNetColor = (closedNet >= 0.0) ? COL_PROFIT : COL_WARN;

   PanelSet("N_NET", "Closed Net:", closedNetColor);
   PanelSet("V_NET", FormatMoney(closedNet), closedNetColor);

   //--- Cycle Loss = แดงเมื่อขาดทุน
   double cycleLoss = GetCycleLoss();

   //--- Cycle Loss: ลบแดง / 0 ขาว
   PanelSet("V_CYC",
            FormatMoney(cycleLoss),
            PanelSignColor(cycleLoss));

   //--- POSITIONS
   double floatingPL = GetFloatingPL();

   //--- Floating: บวกเขียว / ลบแดง / ศูนย์ขาว
   PanelSet("V_FLOAT",
            FormatMoney(floatingPL),
            PanelSignColor(floatingPL));

   int buys  = CountSide(POSITION_TYPE_BUY);
   int sells = CountSide(POSITION_TYPE_SELL);
   int activeTotal = buys + sells;

   //--- Active: มีออเดอร์ = เหลือง / ไม่มี = ขาว
   PanelSet("V_ACT_TOTAL",
            IntegerToString(activeTotal),
            (activeTotal > 0) ? COL_ACTIVE : COL_TEXT);

   //--- Buy: มี Buy = น้ำเงิน / ไม่มี = ขาว
   PanelSet("V_ACT_BUY",
            "Buy:" + IntegerToString(buys),
            (buys > 0) ? COL_BUY_TEXT : COL_TEXT);

   //--- Sell: มี Sell = แดง / ไม่มี = ขาว
   PanelSet("V_ACT_SELL",
            "Sell:" + IntegerToString(sells),
            (sells > 0) ? COL_SELL_TEXT : COL_TEXT);

   PanelSet("V_CUT", FormatPoints(InpCutLossPoints), COL_TEXT);

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| จัดการ Event ของกราฟและปุ่ม                                      |
//+------------------------------------------------------------------+
void PanelOnChartEvent(int id,
                       long lparam,
                       double dparam,
                       string sparam)
  {
   //--- เมื่อย่อ/ขยายกราฟ หรือเปลี่ยน Template ให้คำนวณ Layout ใหม่
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      PanelCheckResponsiveLayout();
      PanelUpdate();
      return;
     }

   if(id != CHARTEVENT_OBJECT_CLICK)
      return;

   if(StringFind(sparam, PANEL_PREFIX) != 0)
      return;

   bool handled = true;

   if(sparam == PName("B_BUY"))
      ManualBuy();

   else if(sparam == PName("B_SELL"))
      ManualSell();

   else if(sparam == PName("B_CLBUY"))
      ManualCloseBuy();

   else if(sparam == PName("B_CLSELL"))
      ManualCloseSell();

   else if(sparam == PName("B_CLALL"))
      ManualCloseAll();

   else if(sparam == PName("B_HEDGE"))
      ManualHedge();

   else if(sparam == PName("B_REFILL"))
     {
      AddRefill();

      Print("Hedge1: REFILL +$",
            DoubleToString(InpRefillAmount, 2),
            " | Virtual Equity=$",
            DoubleToString(GetVirtualEquity(), 2));
     }

   else if(sparam == PName("MIN"))
     {
      //--- ถ้าจอเล็กมาก Auto Minimize จะเป็นตัวบังคับ
      //--- แต่ผู้ใช้ยังสามารถกดย่อ/ขยายเองได้เมื่อจอมีพื้นที่พอ
      if(!g_panelAutoMinimized)
         g_panelMinimized = !g_panelMinimized;

      PanelApplyVisibility();
     }

   else
      handled = false;

   if(handled)
     {
      if(ObjectFind(0, sparam) >= 0)
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);

      PanelUpdate();
      ChartRedraw();
     }
  }

//+------------------------------------------------------------------+
//| ปิด Panel และลบ Object ทั้งหมด                                   |
//+------------------------------------------------------------------+
void PanelDeinit()
  {
   PanelDeleteObjects();
   g_panelReady = false;
   ChartRedraw();
  }

#endif // HEDGE1_PANEL_MQH