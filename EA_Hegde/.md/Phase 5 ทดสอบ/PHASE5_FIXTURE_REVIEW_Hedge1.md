# PHASE 5 — FIXTURE REVIEW & RESTORATION PACK

วันที่: 14 ตุลาคม 2026
Source: 1a3b38f04b991c70fa86195d7d01360955ec4ccd
สถานะ: ตรวจแบบแผนและวิธีคืนสภาพแล้ว ไม่ใช่การทดลองบน Terminal/Broker
ใช้แทนข้อเสนอ Fixture เบื้องต้นที่ขัดกับเอกสารนี้
ยังไม่เปิด Order ไม่แก้ State/ไฟล์จริง ไม่เพิ่ม Logic/fault injection เข้า Baseline

## 1. กติกาก่อนใช้ Fixture

1. Demo เท่านั้น หนึ่ง Instance ต่อ Symbol+Magic ไม่ใช้ข้อมูลของชุดอื่น
2. ยืนยัน identity/Spec/Inputs และผ่าน Preflight ก่อนใช้ขั้นตอนด้านล่าง
3. สำรองชื่อและค่าของ keys/ไฟล์เฉพาะที่จะเปลี่ยน เก็บว่า key เคยมีหรือสร้างใหม่
4. แต่ละ fixture ระบุ Case IDs, owner, ก่อน/หลัง, เวลา, restore plan; ไม่มีข้อมูลครบไม่ดำเนินการ
5. ไม่มีเหตุ API fail/retcode ที่พิสูจน์ได้ ห้ามสรุปว่าทดสอบ failure path แล้ว
6. ไม่เปลี่ยน account/symbol/magic/pointdigits ระหว่าง restore test
7. ไม่ย้อน snapshot เงิน/Cycle/Report ทับเหตุธุรกรรมใหม่โดยไม่ reconcile
8. หยุด EA หรือ AutoTrading ไม่ใช่การปิด Position; ห้ามใช้แทนวิธีคุม exposure

## 2. Namespace ที่ต้อง resolve ก่อนใช้

Trail: H1T3_<login>_<symbol>_<magic>_D<pointdigits>_<ticket>
General: H1S_<login>_<symbol>_<magic>_<suffix> (REFILL/RPD/RNET/CSTART)
Legacy Trail: HEDGE1_<symbol>_<magic>_TRAIL_<ticket>
Legacy General: HEDGE1_<magic>_<suffix> (REFILL/RPD/RNET)
Report: Symbol_Account_Magic_FROM_PeriodStart.csv
ต้องคำนวณชื่อรายงานจาก Start ตามโค้ดจริง ไม่เดาชื่อจากภาพ/เวลาท้องถิ่น
Namespace ไม่มี Broker Server และ Legacy General ไม่มี Account/Symbol การยืนยันเจ้าของจึงเป็นข้อกำหนดภายนอก ไม่ใช่โค้ดยืนยันให้ครบเอง

## 3. รายการ Fixture

### F09 — S09-A–D / Missing SL

- เงื่อนไขก่อนเริ่ม: Demo เท่านั้น; Position ของ Scope ทดสอบ; P-MAN ปิด Auto Reopen, RR=0, Trailing=false; กำหนด BE mode; บันทึกราคาและ Ticket
- วิธีสร้างเหตุ: หลัง Preflight ใช้การแก้ SL ผ่าน Terminal เฉพาะ Position ทดสอบให้เป็น 0 แยก BUY/SELL ก่อนและหลัง Trigger ห้ามทำตอนนี้; เริ่มหนึ่ง subcase ต่อเหตุการณ์ที่เก็บหลักฐานได้
- ผลที่คาดหวัง: เห็น SL=0 แล้ว EA พยายามติดตั้งตามลำดับ Cut Loss/BE; ไม่คลาย SL เดิมที่ดีกว่า; ตรวจผล Broker ไม่ใช่เพียงข้อความ intent
- วิธีคืนสภาพ: หากติดตั้งกลับไม่ได้ให้จบ Position ทดสอบด้วยวิธีปิดที่ Broker ยอมรับ ไม่ปล่อยค้างไม่มี SL; เก็บหลักฐานก่อน; ไม่ปิด AutoTrading เหมารวมเป็นวิธีคืนสภาพ
- หลักฐาน: Ticket, Inputs, ราคาเข้า/Bid/Ask, SL ก่อนหลัง, Experts/retcodes; แยก BE_FIXED/BE_TRAILING
- ขอบเขตความครอบคลุม: ขั้นตอนออกแบบแล้ว แต่ยังไม่ทดลอง; EA อาจติดตั้งกลับเร็วและภาพไม่ทัน ต้องใช้หลักฐานประกอบ

### F09E — S09-E / Cut Loss rejection แล้ว SELL BE

- เงื่อนไขก่อนเริ่ม: SELL SL=0 หลัง Trigger และยังไม่ปิดจากเหตุอื่น
- วิธีสร้างเหตุ: ยังไม่มีวิธีสร้างการปฏิเสธ Cut Loss Modify ที่ควบคุมได้โดยไม่แก้ Baseline; ไม่ใช้การใส่ Inputs ผิดหรือหยุดตลาดเป็นตัวแทนอัตโนมัติ
- ผลที่คาดหวัง: เมื่อ CUTLOSS-SL ล้มเหลวและ SL ยัง 0 ขั้น BREAK-EVEN ต้องยังพยายามส่งคำสั่ง
- วิธีคืนสภาพ: ถ้าเหตุเกิดโดยธรรมชาติให้เก็บหลักฐานและจัดการ Position; ถ้าสร้างไม่ได้ไม่รัน fault นี้
- หลักฐาน: สองเส้นทางต่อเนื่องบน Ticket เดียวกัน: CUTLOSS rejection และ BE attempt; SL/ราคา/Inputs
- ขอบเขตความครอบคลุม: เส้นทางยังไม่มี fixture ควบคุม; NOT_RUN ตอนนี้ และ NOT_COVERED หากจบชุดโดยไม่มีหลักฐาน

### F13 — S13 / Cleanup

- เงื่อนไขก่อนเริ่ม: Demo Scope แยก; สำรองเฉพาะ Trail Keys; ไม่เปลี่ยน identity; History พร้อม
- วิธีสร้างเหตุ: A: มี Position เปิดพร้อม State; B: ถอด EA ของ Scope นี้แล้วปิด Position ก่อนแนบกลับ; C: สร้าง Control Key ของ Ticket ที่ตรวจแล้วว่าไม่ตรง live ticket/identifier หรือ history ในสภาพแวดล้อมนี้
- ผลที่คาดหวัง: A เก็บ State, B ลบเมื่อยืนยันปิดครบ, C เก็บเพราะยืนยันไม่ได้; State Scope อื่นไม่เปลี่ยน
- วิธีคืนสภาพ: สำรองผลก่อน; ลบเฉพาะ Control Key ที่สร้างเองหลังตรวจว่าไม่มี Position ใช้; State ที่ Cleanup ลบถูกต้องไม่ต้องคืนเพื่อทำให้ค่าดูเหมือนเดิม
- หลักฐาน: State inventory ก่อนหลัง, History, Ticket/Identifier, Cleanup logs; ต้องมี Tick/การเชื่อมต่อและผ่านเวลาสแกนเมื่อทดสอบ orphan
- ขอบเขตความครอบคลุม: ไม่ใช้ C พิสูจน์ API property read failure; property failure และ service ticket change ยังไม่มี controlled fixture

### F14 — S14 / Capital Gate

- เงื่อนไขก่อนเริ่ม: Tester หรือ Demo identity ใหม่ที่ไม่ปน History/REFILL; P-CAP และ Manual variant
- วิธีสร้างเหตุ: ทุนเริ่มต้น 0 กับ Scope สะอาดตรวจ Block Auto/Manual; สำหรับ Protection/Close ต้องใช้ lifecycle scenario แยกที่มี Position อยู่ก่อนและทุน <=0 โดยเปลี่ยนเฉพาะ Input ที่ระบุในแผน ไม่เปลี่ยน identity
- ผลที่คาดหวัง: CAPITAL_DEAD ไม่เปิดคู่ แต่ Protect/Close ยังทำงาน; History read failure แยกจากยอดศูนย์
- วิธีคืนสภาพ: จบ Position ทดสอบก่อนคืนโปรไฟล์; เก็บ Inputs/history/state ที่ใช้จริง; ห้ามลบประวัติเพื่อทำให้ทุนดูศูนย์
- หลักฐาน: Inputs, Trade/History, Gate log, SL/Close result และ accounting scope
- ขอบเขตความครอบคลุม: เงื่อนไขทุนศูนย์ควบคุมได้เมื่อ isolation ผ่าน; Capital read failure ยังไม่ควบคุม

### F15 — S15 / REFILL

- เงื่อนไขก่อนเริ่ม: Demo P-MAN; บันทึก REFILL ก่อนเริ่ม; ห้ามใช้ Scope อื่น
- วิธีสร้างเหตุ: กด REFILL และ Restart ด้วย Inputs/identity เดิม; ไม่ทำลาย Global Variables เพื่อบังคับ Save fail
- ผลที่คาดหวัง: แสดง SAVED เมื่อ Save สำเร็จ ยอดคงอยู่หลัง Restart; failure path ต้องมี failure จริง
- วิธีคืนสภาพ: ไม่ย้อนยอดที่ใช้ไปใน Cycle ต่อมาโดยไม่ตรวจบัญชี; สำหรับ fixture ให้เก็บผลและเลิกใช้ Scope หลังจบ หรือคืนเฉพาะ snapshot ที่ยังไม่มีเหตุธุรกรรมใหม่
- หลักฐาน: REFILL ก่อนหลัง, Experts, Panel, Restart evidence
- ขอบเขตความครอบคลุม: Normal path วางขั้นตอนแล้ว; GlobalVariable Save fail ยังไม่มี controlled fixture

### F22 — S22 / Report Recovery

- เงื่อนไขก่อนเริ่ม: Demo P-REP-D; Basket ว่าง; CSV สมบูรณ์ที่สร้างบน Demo scope นี้จริง; Start/End/RPD สำรองครบ
- วิธีสร้างเหตุ: หยุด EA Scope นี้ก่อนแก้; ตั้ง RPD กลับเป็น Start ของ CSV รอบที่เสร็จแล้วในชุดทดสอบ; ReportDays ต้องทำให้ถึง due; แนบ EA ด้วย identity เดิมและ Auto Reopen=false
- ผลที่คาดหวัง: Recover Completed Report ใช้ End ที่อยู่ใน marker เดิม; บันทึก RPD=End เดิม ไม่เขียนรายงานรอบเดิมใหม่
- วิธีคืนสภาพ: เก็บก่อนหลัง แล้วใช้ RPD ที่ recover ถูกต้องต่อ; ไม่ย้อน snapshot เก่าทับรอบใหม่; ห้ามใช้ CSV Tester แทน Demo
- หลักฐาน: CSV เดิมและ metadata, RPD ก่อนหลัง, Experts; หากเทียบ bytes ต้องเก็บไฟล์ต้นฉบับก่อน
- ขอบเขตความครอบคลุม: ออกแบบ recovery จาก State จำลองได้ ไม่ได้พิสูจน์ว่าเคยเกิด State Save fail จริง

### F23 — S23 / Invalid existing CSV และ Manual Gate

- เงื่อนไขก่อนเริ่ม: Demo P-REP-D; Basket ว่าง; identity เฉพาะ; RPD เป็น timestamp บวกที่ถึง due; ไม่ใช้บัญชีจริง
- วิธีสร้างเหตุ: หยุด EA และสำรอง RPD/ไฟล์; เลือก Start ของ fixture โดยไม่ชนรอบจริง; สร้างไฟล์ผิดรูปแบบด้วยชื่อปลายทางที่ตรง Symbol_Account_Magic_FROM_Start.csv; แนบกลับ; ตรวจ Gate แล้วกด Manual HEDGE ตาม run plan
- ผลที่คาดหวัง: REPORT EXISTS BUT INVALID; ไม่เขียนทับไฟล์; WAIT_REPORT ไม่เปิดคู่; การจัดการ Position ที่มีอยู่ต้องตรวจแยก เพราะ Report ทำเมื่อ Basket ว่าง
- วิธีคืนสภาพ: เก็บไฟล์ปลอมเป็นหลักฐานแล้วนำออกเฉพาะชื่อที่สร้างเอง; ให้ Report retry/complete ก่อนเดินต่อ; คืน RPD เดิมได้เฉพาะถ้ายังไม่มี report/cycle ใหม่ มิฉะนั้น reconcile ช่วงเวลารายงาน
- หลักฐาน: ชื่อและเนื้อหาไฟล์ก่อนหลัง, RPD, Inputs, log, Trade/History
- ขอบเขตความครอบคลุม: ครอบคลุม invalid-existing-file ไม่ใช่ FileWrite partial/flush failure หรือ stale-gate timing

### F23S — S23-S / Stale Report Gate

- เงื่อนไขก่อนเริ่ม: Demo identity เฉพาะ Basket ว่าง; Auto Reopen=false; ต้องพิสูจน์ว่าธง Gate ยังเก่า
- วิธีสร้างเหตุ: อาจใช้ปรับ RPD ระหว่าง EA ทำงานแล้วกด Manual ก่อน OnTick ถัดไป แต่มี race กับ Tick และ Baseline ไม่มี log ยืนยันค่าธงก่อน refresh จึงยังไม่รับรองวิธีนี้เป็น controlled fixture
- ผลที่คาดหวัง: Report refresh ก่อน Order แรก; หาก Report ล้มเหลวห้ามเปิด
- วิธีคืนสภาพ: ไม่แก้ State ขณะมี Position ค้างเพื่อบังคับเหตุ; หากทดลองภายหลังต้องสำรอง/คืนตาม F23; ไม่มี timeline ที่พิสูจน์ได้ให้จบเป็น NOT_COVERED
- หลักฐาน: RPD/event/tick timeline ที่พิสูจน์เหตุได้; การ Block จากธง true อยู่แล้วไม่พอ
- ขอบเขตความครอบคลุม: ช่องว่างหลักฐานเฉพาะ timing; ไม่เพิ่ม logging/fault code เข้า Baseline รอบนี้

### F24 — S24 / Open failure และ Rollback

- เงื่อนไขก่อนเริ่ม: Demo เท่านั้น; ต้องมี retcode และ Position history จริง
- วิธีสร้างเหตุ: ยังไม่มี fixture ที่รับรองบน Broker นี้; ไม่ใช้ทุนต่ำ/เพิ่ม Lot เพื่อหวังให้ขาเดียวผ่าน เพราะไม่มีหลักฐานว่าจะสร้าง failure เฉพาะขาได้
- ผลที่คาดหวัง: เปิดไม่ครบ/Volume ผิด -> Verify/Rollback; ตรวจจำนวนจริงหลังรอบสุดท้าย; เหลือ Position ต้องเก็บเป็นเหตุสำคัญ
- วิธีคืนสภาพ: หากเกิดจริงใช้การปิด Position Scope นี้ที่ยืนยันผลได้และหยุดหากควบคุม exposure ไม่ได้; ไม่ตัด AutoTrading แล้วถือว่าปิด Position แล้ว
- หลักฐาน: Open/retry/rollback retcodes, Ticket/Volume, Trade/History/Experts; partial และ complete reject แยกกัน
- ขอบเขตความครอบคลุม: Observe-only ใน Baseline นี้ เว้นแต่ยืนยัน fixture เพิ่มก่อนเริ่ม; ไม่รับประกัน coverage

### F25 — S25 / Close-Modify rejection

- เงื่อนไขก่อนเริ่ม: Demo P-FAULT; Trail State ของ Position ทดสอบ; ต้องมีคำสั่งของ EA ที่ถูกปฏิเสธจริง
- วิธีสร้างเหตุ: เก็บเหตุ rejection ที่เกิดจริง; ไม่ใช้ Manual Modify ของ Terminal มาแทน RawPositionModify ของ EA และไม่เลือกเปิด Position ทิ้งไว้ข้ามตลาดปิดเพื่อบังคับ Close reject
- ผลที่คาดหวัง: Close fail แล้ว Best คงอยู่; Modify reject ไม่อ้าง success; partial close ต้องมีหลักฐาน Position ที่เหลือ
- วิธีคืนสภาพ: เก็บ State/retcode แล้วจบ Position เมื่อ Broker รับคำสั่ง; หากยังคุมไม่ได้หยุดชุดและไม่เริ่ม Long Run
- หลักฐาน: Ticket, Best ก่อนหลัง, retcodes EA, SL/volume ก่อนหลัง, Inputs
- ขอบเขตความครอบคลุม: Observe-only; missing SL ที่ติดกลับสำเร็จไม่พิสูจน์ Modify rejection

### F26G — S26 / General Legacy Import

- เงื่อนไขก่อนเริ่ม: Demo identity ที่ยืนยันเจ้าของ; Basket ว่าง; keys เก่า HEDGE1_<magic>_REFILL/RPD/RNET ไม่มี account/symbol จึงห้ามเดาเจ้าของ; fixture ต้องติดป้ายว่า synthetic
- วิธีสร้างเหตุ: สำรองเฉพาะ legacy keys ที่เกี่ยวข้อง; สร้างค่าถูกต้องเฉพาะ Scope ที่ไม่ชนชุดอื่น; เปิด InpStateImportLegacy=true และ InpTrailImportLegacy=false; แยก new-key-absent/new-key-present
- ผลที่คาดหวัง: นำเข้าเฉพาะเมื่อ key ใหม่ไม่มี; key ใหม่มีแล้วไม่ถูก overwrite; legacy RNET อย่างเดียวไม่รับรอง cycle restore เพราะยังต้องมี CSTART
- วิธีคืนสภาพ: ปิด Import หลังจบ; ลบ synthetic legacy keys ที่สร้างเองเท่านั้น; ไม่ลบ legacy keys จริงแบบเหมารวม; เก็บ new keys/retire identity แทนย้อนข้อมูลที่เกิด Cycle ใหม่
- หลักฐาน: รายการ keys/ค่าก่อนหลัง, owner confirmation, Inputs, migration logs
- ขอบเขตความครอบคลุม: ขั้นตอนออกแบบแล้ว รอ resolved identity; synthetic ไม่ใช่หลักฐานย้าย State จริงของผู้ใช้

### F26T — S26 / Trail Legacy Import

- เงื่อนไขก่อนเริ่ม: Demo Position ที่ยังเปิดเป็นของ EA; Account/Symbol/Magic/PointDigits เดิม; General Import=false; Best ต้องมีเจ้าของยืนยันหรือระบุ synthetic
- วิธีสร้างเหตุ: Key เก่า HEDGE1_<symbol>_<magic>_TRAIL_<ticket>; ตรวจ old/new key ก่อน; เปิด InpTrailImportLegacy เฉพาะ scenario; new-key-present แยกจาก new-key-absent; เตรียมราคาปัจจุบันให้ไม่เกิด close จาก Best ที่ใส่โดยไม่ตั้งใจ
- ผลที่คาดหวัง: Restore old best เฉพาะ own live Position; new key ไม่ถูกทับ; เมื่อ migration save สำเร็จโค้ดลบ legacy trail key; save failure เป็นเส้นทางแยก
- วิธีคืนสภาพ: ปิด Import โดยคงค่าที่เกี่ยวข้อง; เก็บหลักฐานการย้าย/ลบ old key; ไม่ย้อน Best ต่ำลงหรือเปลี่ยน namespace ขณะ Position ยังเปิด; คืน/ลบ synthetic keys หลังยืนยันไม่มี Position ใช้
- หลักฐาน: Ticket, old/new Best, PointDigits, Inputs, Migration/Restore logs
- ขอบเขตความครอบคลุม: Trail Import ต้องมี Position อยู่ ต่างจาก General Import ที่ต้อง Basket ว่าง; migration-save failure ยังไม่มี controlled fixture

## 4. Correction จากข้อเสนอเดิม

- S24: ยกเลิกเสนอเพิ่ม Lot/ใช้ Margin ต่ำเพื่อหวังให้เหลือขาเดียวโดยไม่มีวิธียืนยันเฉพาะทาง
- S25: ยกเลิกเสนอผิด Stops Level ใน Manual Terminal เป็นหลักฐานแทน Modify path ของ EA
- S26: General Import กับ Trail Import แยกกัน; General ต้อง Basket ว่าง แต่ Trail ใช้ own live Position
- S22: คืน RPD ด้วย snapshot จำลองพิสูจน์ Recovery ได้ แต่ไม่พิสูจน์ว่าการบันทึก State เคยล้มเหลวจริง
- S23: malformed existing file ไม่เท่ากับ partial write/flush fail; stale Gate ต้อง timeline เพิ่ม
- S13: unknown history ไม่เท่ากับ property read failure

## 5. Coverage gaps ที่ต้องประกาศก่อนรัน

S09-E, S13 property-read failure, S14 History-read failure, S15 GV-save failure,
S23 partial-write/flush/state-save failure/stale-gate timing, S24 broker-specific failure และ S25 rejection
ยังไม่มีวิธีสร้างเหตุที่รับรองได้ใน Baseline นี้
ไม่ตัดออกจาก Checklist; สถานะตอนเตรียมยัง NOT_RUN
เมื่อจบรันถ้าไม่มีหลักฐานให้ NOT_COVERED ไม่รับรองทั้ง case จากผล normal path
NOT_COVERED ไม่ใช่การอนุมัติ Production และไม่ใช่ผู้ใช้ยอมรับความเสี่ยงโดยอัตโนมัติ

## 6. Restoration record template

Fixture ID / Case ID:
Account/Symbol/Magic/PointDigits:
Source / Preset:
เวลา / Server time:
Keys/Files/Positions ที่อนุญาตให้เปลี่ยน:
ก่อน (รวม missing/existing):
สิ่งที่สร้าง/เปลี่ยนจริง:
หลักฐานก่อนหลัง:
มี transaction/report/cycle ใหม่หลัง snapshot หรือไม่:
วิธีคืนที่ไม่ย้อนทับเหตุใหม่:
Position คงเหลือและ SL:
การคืนสภาพสำเร็จ/ยังค้าง:
Coverage ที่พิสูจน์ได้:

## 7. จุดจบงานเตรียมส่วนนี้

Checklist + run-order/profile design + fixture review มีเอกสารแล้ว
การตรวจเป็น desk review ไม่ใช่ environment validation; fixture ที่ใช้งานได้จริงต้องยืนยันหลัง Preflight
ไม่มีเหตุให้เปิด Phase พัฒนาใหม่เพื่อบังคับ fault ทุกเส้นทางให้เกิด
ถัดไปเพียงก้อนเดียว: รับ Specification/Spread/identity, finalize .set และ Preflight แล้วจึงเริ่ม Short Test
