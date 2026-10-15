

Preset 1 — Manual / ปุ่ม / Restart
ชื่อไฟล์: SHORT_01_MANUAL.set

ใช้กับ Demo สำหรับปุ่มเปิดคู่ ป้องกันการเปิดซ้ำ คำสั่งปิด REFILL และ Restart โดยปิด Auto Reopen


Preset 2 — เปิดคู่ / Cut Loss
ชื่อไฟล์: SHORT_02_CUT.set

ใช้กับ Tester สำหรับ Entry และ Cut Loss โดยปิด BE, RR และ Trailing TP เปิด Auto Reopen และปิด Timeout เพื่อแยกตรวจ Protection

Preset 3 — BE Fixed
ชื่อไฟล์: SHORT_03_BE_FIXED.set

ใช้กับ Tester สำหรับ BE แบบล็อกตามสัดส่วนของ Trigger โดยตั้ง InpBreakEvenMode=1 และปิด RR/Trailing TP

Preset 4 — BE Trailing
ชื่อไฟล์: SHORT_04_BE_TRAILING.set

ใช้กับ Tester สำหรับ BE แบบเลื่อนตาม Step โดยตั้ง InpBreakEvenMode=2 และปิด Trailing TP เพื่อไม่ให้สับสนระหว่าง “BE เลื่อน SL” กับ “Trailing TP ปิด Position”

Preset 5 — Armed Trailing
ชื่อไฟล์: SHORT_05_ARMED_TRAILING.set

ใช้กับ Tester สำหรับ Armed Trailing โดยตั้ง RR=0 เพื่อไม่ให้ RR แย่งปิด และเปิด BE Trailing ตามโปรไฟล์ที่วางไว้ หาก Position ปิดด้วย BE ก่อนเกิด Trailing Pullback ต้องแยกผลตามเหตุที่เกิดจริงครับ

Preset 6 — RR
ชื่อไฟล์: SHORT_06_RR.set

ใช้กับ Tester สำหรับ RR โดยปิด BE และ Trailing TP แต่คง BE Trigger=120 เพราะ RR ใช้ค่านี้คำนวณเป้า เมื่อ RR=200 เป้าที่คำนวณได้คือ 240 Points ครับ

Preset 7 — Auto / Timeout / Spread / Cycle
ชื่อไฟล์: SHORT_07_AUTO_TIMEOUT.set

ใช้กับ Tester สำหรับการเปิดรอบใหม่อัตโนมัติ โดยเปิด Timeout=300 วินาที และ Spread Check=25 การผ่าน Timeout อย่างเดียวไม่พอ ต้องผ่าน Gate อื่นด้วย และหากยังมี Position ค้างต้องไม่เปิดคู่ใหม่ครับ

Preset 8 — Session ช่วงเวลาถูกต้อง
ชื่อไฟล์: SHORT_08_SESSION.set

ใช้กับ Tester สำหรับ Session โดยเปิดช่วง Block ของ Session 1 เวลา 01:00–04:00 ตามเวลา Server ส่วน Session 2–3 ปิดไว้ การตรวจต้องครอบคลุมทั้งช่วง Block/Open และ Protection ของ Position เดิมต้องไม่หยุดตาม Session Gate ครับ

Preset 9 — Session แรกเวลาผิด / ตรวจ Session ถัดไป
ชื่อไฟล์: SHORT_09_SESSION_INVALID_FIRST.set

ตั้ง Session 1 เป็น 99:00 โดยเจตนา เพื่อให้ระบบข้ามช่วงที่รูปแบบผิด แล้วตรวจ Session 2 ที่ถูกต้องต่อ โดย Session 2 Block เวลา 07:00–12:00 ตามเวลา Server กรณีนี้ต่างจาก Invalid Inputs ที่ต้องถูกปฏิเสธตอน Init ครับ

Preset 10 — Report ใน Tester
ชื่อไฟล์: SHORT_10_REPORT_TESTER.set

เปิด Auto Reopen และ ReportDays=1 สำหรับทดสอบ CSV บนข้อมูลย้อนหลัง ช่วงวันที่ต้องยาวพอให้รายงานถึงกำหนด และต้องมีช่วง Basket ว่าง การเปิด Report ใน Inputs อย่างเดียวไม่ถือว่าทดสอบรายงานผ่านครับ

Preset 11 — Report บน Demo
ชื่อไฟล์: SHORT_11_REPORT_DEMO.set

เปิด ReportDays=1 แต่ปิด Auto Reopen เพื่อใช้กับกรณี Manual Report Gate, Recovery และ Report Failure ตาม Fixture ที่เตรียมไว้ ตัว Preset นี้ไม่ได้สร้างเหตุ Recovery หรือ Failure ให้อัตโนมัติ และไม่ควรนำ CSV/State จาก Tester มาใช้แทนหลักฐาน Demo ครับ


Preset 12 — Capital Zero
ชื่อไฟล์: SHORT_12_CAPITAL_ZERO.set

ตั้งทุนเริ่มต้นเสมือนเป็น 0 เพื่อทดสอบ Capital Gate ใน Tester โดยต้องตรวจว่า Scope ที่ใช้ไม่มี Closed Net หรือ REFILL เดิมทำให้ทุนเสมือนกลับเป็นบวก ค่า InpInitialCapital=0 เพียงอย่างเดียวไม่ได้รับรองว่า Virtual Equity เป็น 0 ครับ

อย่าโหลดไฟล์นี้ต่อจากการรันชุดอื่นแล้วสรุปว่าทุนศูนย์ทันที และอย่าลบ State เหมารวมเพื่อเตรียมกรณีนี้

Preset 13 — Auto-Lot
ชื่อไฟล์: SHORT_13_AUTOLOT.set

ใช้กับ Tester สำหรับสูตรบันได Lot โดยเปิด InpAutoLot=true ไฟล์นี้เป็นค่าตั้งต้นของกรณี S16 ไม่ได้ครอบคลุมหลายระดับทุนและเพดานครบด้วยการรันค่าเดียว ต้องใช้ Variant ที่บันทึกไว้ในแผนก่อนรันครับ

Preset 14 — Missing SL
ชื่อไฟล์: SHORT_14_MISSING_SL.set

ใช้กับ Demo Fixture สำหรับตรวจกรณี SL หาย โดยปิด Auto Reopen, RR และ Trailing TP เพื่อแยกตรวจ Cut Loss/BE ใช้ BE Trailing เป็นค่าตั้งต้น ส่วน BE Fixed เป็น Variant ของกรณีนี้ครับ

การโหลด Preset ไม่ทำให้ SL หายเอง และยังไม่ต้องลบ SL หรือสร้าง Fixture จนกว่าจะเริ่มตามขั้นตอนที่กำหนด กรณีกำไรเลย Trigger ต้องมีหลักฐานราคาจริงประกอบครับ


Preset 15 — Invalid BE Step
ชื่อไฟล์: SHORT_15_INVALID_BE_STEP.set

ใช้กับ Tester สำหรับ S01 โดยเปิด BE Trailing แต่ตั้ง InpBreakEvenStep=0 ผิดโดยเจตนา ผลที่คาดหวังคือ Init ถูกปฏิเสธก่อนเปิด Order ไม่ใช่ EA เริ่มทำงานได้ครับ

Preset 16 — Invalid Trailing Pullback
ชื่อไฟล์: SHORT_16_INVALID_PULLBACK.set

ใช้กับ Tester สำหรับ S01 โดยเปิด Trailing TP แต่ตั้ง InpTrailingPullback=0 ผิดโดยเจตนา ผลที่คาดหวังคือ Init ถูกปฏิเสธก่อนเปิด Order เช่นเดียวกันครับ