//+------------------------------------------------------------------+
//|                                             Hedge1_Session.mqh   |
//|  Sessions 3 ช่วง: true = หยุดเปิดไม้ใหม่ช่วงนั้น (เวลาเซิร์ฟเวอร์) |
//|  หมายเหตุ: ปุ่ม Manual กดได้เสมอ ไม่ถูก Session บล็อก (จัดการฝั่ง Engine)
//+------------------------------------------------------------------+
#ifndef HEDGE1_SESSION_MQH
#define HEDGE1_SESSION_MQH

#include "Hedge1_Inputs.mqh"

//--- ธงกันพิมพ์ log เตือนซ้ำกระหน่ำ (พิมพ์ครั้งเดียวต่อ session)
bool g_sessionWarned[3] = {false, false, false};

//+------------------------------------------------------------------+
//| แปลงเวลา "HH:MM" เป็นนาทีต่อวัน (0-1440) ถ้ารูปแบบผิดคืน -1        |
//+------------------------------------------------------------------+
int ParseTimeToMinutes(string hhmm)
  {
   string parts[];
   if(StringSplit(hhmm, ':', parts) != 2)
      return(-1);
   int h = (int)StringToInteger(parts[0]);
   int m = (int)StringToInteger(parts[1]);
   if(h < 0 || h > 24 || m < 0 || m > 59)
      return(-1);
   if(h == 24 && m != 0)   // อนุญาตให้พิมพ์ 24:00 ได้อย่างเดียว
      return(-1);
   return(h * 60 + m);
  }

//+------------------------------------------------------------------+
//| เวลาเซิร์ฟเวอร์ปัจจุบันเป็นนาทีต่อวัน (0-1439)                   |
//+------------------------------------------------------------------+
int CurrentServerMinutes()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   return(dt.hour * 60 + dt.min);
  }

//+------------------------------------------------------------------+
//| ตรวจว่าอยู่ในช่วงเวลาที่กำหนดหรือไม่                              |
//| - เริ่ม = จบ       : ไม่ถือว่าบล็อก                                |
//| - เริ่ม < จบ       : ช่วงปกติในวันเดียวกัน                          |
//| - เริ่ม > จบ       : ช่วงข้ามเที่ยงคืน (เช่น 22:00-03:00) เผื่อใช้อนาคต |
//+------------------------------------------------------------------+
bool IsInWindow(int nowMin, int startMin, int endMin)
  {
   if(startMin == endMin)
      return(false);
   if(startMin < endMin)
      return(nowMin >= startMin && nowMin < endMin);
   return(nowMin >= startMin || nowMin < endMin);
  }

//+------------------------------------------------------------------+
//| ตรวจค่าเวลาของ 1 session ว่าใช้ได้ไหม (ถ้าใช้ไม่ได้จะเตือนครั้งเดียว) |
//+------------------------------------------------------------------+
bool GetSessionWindow(int idx, bool enabled, string startStr, string endStr,
                      bool &isActive, int &startMin, int &endMin)
  {
   isActive = false;
   startMin = -1;
   endMin   = -1;
   if(!enabled)
      return(true);   // ปิดใช้งาน = ถือว่าโอเค ไม่บล็อก

   int s = ParseTimeToMinutes(startStr);
   int e = ParseTimeToMinutes(endStr);
   if(s < 0 || e < 0)
     {
      if(idx >= 0 && idx < 3 && !g_sessionWarned[idx])
        {
         g_sessionWarned[idx] = true;
         Print("Hedge1: Sessions ", idx + 1, " รูปแบบเวลาไม่ถูกต้อง (",
               startStr, " - ", endStr, ") จึงข้ามการตรวจช่วงนี้");
        }
      return(false);
     }
   startMin = s;
   endMin   = e;
   isActive = true;
   return(true);
  }

//+------------------------------------------------------------------+
//| true = ขณะนี้อยู่ในช่วงเวลาที่ถูกบล็อก (ระบบ Auto หยุดเปิดไม้ใหม่)   |
//| ไม้ที่เปิดค้างไว้ยังบริหารต่อปกติ (BE/TP/Cut Loss ไม่หยุด)         |
//+------------------------------------------------------------------+
bool IsAutoBlockedBySession()
  {
   int nowMin = CurrentServerMinutes();
   bool isActive = false;
   int s = 0, e = 0;

   if(!GetSessionWindow(0, InpSession1Block, InpSession1Start, InpSession1End, isActive, s, e))
      return(false);
   if(isActive && IsInWindow(nowMin, s, e))
      return(true);

   if(!GetSessionWindow(1, InpSession2Block, InpSession2Start, InpSession2End, isActive, s, e))
      return(false);
   if(isActive && IsInWindow(nowMin, s, e))
      return(true);

   if(!GetSessionWindow(2, InpSession3Block, InpSession3Start, InpSession3End, isActive, s, e))
      return(false);
   if(isActive && IsInWindow(nowMin, s, e))
      return(true);

   return(false);
  }

//+------------------------------------------------------------------+
//| สถานะ Session สำหรับแสดงบน Panel ("OPEN" / "BLOCK")               |
//+------------------------------------------------------------------+
string GetSessionStatusText()
  {
   return(IsAutoBlockedBySession() ? "BLOCK" : "OPEN");
  }

#endif // HEDGE1_SESSION_MQH