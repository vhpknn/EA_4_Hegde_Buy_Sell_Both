Preset 17 — Long Run / ReportDays=1
ชื่อไฟล์: LONG_01_OVERNIGHT_DRAFT.set

ใช้สำหรับ Long Run เพื่อให้มีโอกาสตรวจ Report รอบหนึ่งวัน เปิด Auto-Lot, Auto Reopen, Timeout=300 และ Session 1 Block เวลา 01:00–04:00 ตามเวลา Server

ระยะ Protection ใช้ค่าอ้างอิง Long Run เดิม ส่วน Report ต้องครบระยะเวลาจริงและมีช่วง Basket ว่าง ไม่ถือว่าข้ามเที่ยงคืนแล้วรายงานต้องเกิดทันทีครับ

Preset 18 — Long Run / ReportDays=5
ชื่อไฟล์: LONG_02_NORMAL_REPORT5_DRAFT.set

เก็บเป็นโปรไฟล์อ้างอิงรอบรายงานปกติห้าวัน ค่าทั้งหมดเหมือนไฟล์ 17 ยกเว้น InpReportDays=5

สำหรับ Long Run ชุดทดสอบที่วางไว้ ให้ใช้ไฟล์ 17 เป็นตัวเลือกหลักสำหรับตรวจ Report ส่วนไฟล์ 18 เก็บแยก ไม่สลับสองไฟล์ระหว่างรันโดยไม่บันทึกการเปลี่ยน Inputs ครับ