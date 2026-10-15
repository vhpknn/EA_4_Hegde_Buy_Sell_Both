# SHORT TEST RUN ORDER & INPUT PROFILES — Hedge 1.0

วันที่: 14 ตุลาคม 2026
Source: 1a3b38f04b991c70fa86195d7d01360955ec4ccd
Compile: ผู้ใช้รายงาน 0 errors / 0 warnings
สถานะ: PREPARATION / DRAFT INPUT PROFILES — ไม่ใช่ .set พร้อมรัน
เอกสารนี้จัดลำดับและโปรไฟล์สำหรับทั้งชุด ไม่สั่งเริ่มทดสอบตอนนี้
อ้างอิง: CONSOLIDATED_TEST_PLAN.md และ TEST_CHECKLIST_Hedge1_Phase5.md

## 1. สิ่งที่ยังไม่กำหนด

Symbol/Account identity, InpPointDigits, Lot/ทุนที่ใช้จริง, k, Magic, Tick model,
Date range, TimeoutSeconds, Spread limit, Session windows, Deviation ต้องยืนยันก่อนสร้าง .set
ไม่ใช้ค่า Default จาก EA เป็นการรับรองความพร้อมโดยอัตโนมัติ

โครงระยะอ้างอิงเดิม: CutLoss=70k, Trigger=120k, Step=10k, Pullback=50k, BE%=20
k ยังไม่เลือก ระยะต้องเป็นจำนวนที่ Input ชนิด int รับได้ และผ่าน Broker preflight
InpPointDigits กำหนดหน่วยระยะของ EA ไม่ถือว่าเท่ากับ native point เสมอ

## 2. โปรไฟล์ที่เสนอ

ค่าต่อไปนี้เป็นการแยกเหตุเพื่อทดสอบ ไม่เปลี่ยน Source หรือกลยุทธ์
BE: InpBreakEvenMode; RR: InpRRPercent; Trail: InpUseTrailingTP;
Auto: InpReopenOnEmpty; Report: InpEnableReport; AutoLot: InpAutoLot

| Profile | วัตถุประสงค์ | BE | RR | Trail | Auto | Report | AutoLot | Cases |
|---|---|---|---:|---|---|---|---|---|
| P-CUT | Cut Loss / Entry | BE_OFF | 0 | false | true | false | false | S02,S06 |
| P-FIX | BE Fixed | BE_FIXED | 0 | false | true | false | false | S07 |
| P-BET | BE Trailing | BE_TRAILING | 0 | false | true | false | false | S08 |
| P-ARM | Armed Trailing | BE_TRAILING | 0 | true | true | false | false | S10 |
| P-RR | RR แยกจาก Trailing | BE_OFF | 200 | false | true | false | false | S11 |
| P-MAN | ปุ่ม / Lifecycle | BE_TRAILING | 0 | true | false | false | false | S02-S05,S09,S12,S13,S15 |
| P-AUTO | Auto Gates / Cycle | BE_TRAILING | 0 | true | true | false | false | S17-S20 |
| P-REP-T | Report ใน Tester | BE_TRAILING | 0 | true | true | true | false | S21 |
| P-REP-D | Report บน Demo | BE_TRAILING | 0 | true | false | true | false | S21-M,S22,S23 |
| P-CAP | Capital / Auto-Lot | BE_TRAILING | 0 | true | true | false | true | S14,S16 |
| P-FAULT | Trade Failure | BE_TRAILING | 0 | true | false | false | false | S24,S25 |
| P-LEG | Legacy Import | BE_TRAILING | 0 | true | false | false | false | S26 |

ทุกโปรไฟล์ปิด InpTrailImportLegacy และ InpStateImportLegacy ยกเว้น variant ของ P-LEG ที่อนุมัติ
โปรไฟล์ Report ใช้ InpReportDays=1; ค่า Report ใน profile อื่นปิดเพื่อแยกเหตุเฉพาะกรณี
จึงห้ามใช้ profile ที่ปิด Report มาอ้างว่าผ่าน Report Gate
P-CAP: AutoLot=true สำหรับ S16; S14 จะใช้ Fixed Lot variant ได้เพื่อแยก Capital Gate
P-MAN: ปิด Auto Reopen; สำหรับ Missing SL ให้ปิด Trailing และใช้ BE mode ของ subcase
P-LEG ไม่เปิด import ทั้งสองแบบเหมารวม: เลือกตามกรณี General State หรือ Trail State
BE_FIXED=1, BE_TRAILING=2, BE_OFF=0 ตาม Source ที่อ่านก่อนหน้า

## 3. ลำดับเป็นก้อนงาน (ไม่ต้องรอ AI หลังแต่ละ Case)

1. Tester: Invalid Inputs → Entry/Cut Loss → BE Fixed → BE Trailing → Armed Trailing → RR
2. Tester: Capital/Auto-Lot → Timeout → Spread → Session → Cycle → CSV
3. Demo: Entry/ปุ่ม/ปิด → REFILL → Restart
4. Demo fixtures: Missing SL → Cleanup → Report baseline/recovery/failure
5. Demo fault fixtures: Open Failure → Close/Modify Rejection
6. Demo migration: Legacy Import เป็นก้อนสุดท้าย คืนสภาพและปิด Import

ตารางต่อไปเรียงตาม Case ID เพื่อค้นหาง่าย ไม่ใช่ลำดับรันแทนหกก้อนด้านบน

## 4. Mapping ครบ S01–S26

| Case | Environment | Profile / Variant | เงื่อนไขสำคัญ |
|---|---|---|---|
| S01 | Tester | P-CUT + Invalid variant | ใช้ Inputs ผิดโดยตั้งใจครั้งละหนึ่งเงื่อนไข เช่น BE_TRAILING + Step=0; Trailing=true + Pullback=0; ไม่ใช้สำหรับเปิด Order |
| S02 | Tester + Demo | P-CUT / P-MAN | Buy1+Sell1, Volume เท่ากัน, SL ทั้งสองขา, CYCLE START ก่อน Order แรก |
| S03 | Demo | P-MAN | กด HEDGE ขณะ Basket ค้าง; ไม่เพิ่มคู่และไม่รีเซ็ต Cycle |
| S04 | Demo | P-MAN | BUY/SELL LOCKED ต้องไม่มี Order ใหม่ |
| S05 | Demo | P-MAN | ตรวจ CLOSE BUY, CLOSE SELL, CLOSE ALL เป็นสถานการณ์ที่จัดไว้แยกกัน |
| S06 | Tester | P-CUT | ปิดตาม SL; ไม่เปิดขาที่หายกลับ; ขาที่เหลือยังถูกบริหาร |
| S07 | Tester | P-FIX | ไม่มี RR/Trailing แย่งปิด; ตรวจ SL เมื่อถึง Trigger วิ่งต่อและย่อ |
| S08 | Tester | P-BET | ไม่มี RR/Trailing แย่งปิด; ตรวจหลาย Step และ SL ไม่คลายกลับ |
| S09 | Demo fixture | P-MAN + BE Fixed/Trailing variants | ปิด Trailing ระหว่างแยกตรวจ Missing SL; RR=0; แยก S09-A ถึง E; ยังไม่อนุมัติวิธีลบ SL |
| S10 | Tester | P-ARM | RR=0; ตรวจ Arm/Best/Pullback; BE อาจปิดก่อน จึงบันทึก coverage ตามเหตุจริง |
| S11 | Tester | P-RR | RR=200, BE_OFF, Trailing=false; คง BE Trigger ไว้ |
| S12 | Demo | P-MAN | Restore Best/Cycle; คง Account/Symbol/Magic/PointDigits/ระยะและค่า Inputs เดิมก่อนหลัง Restart |
| S13 | Demo fixture | P-MAN | แยก live/closed/unknown/property-read failure; ไม่ลบ State ของชุดอื่น |
| S14 | Tester + Demo fixture | P-CAP / P-MAN | ทุน <=0 Block Auto/Manual; ทดสอบทุนอ่านไม่ได้แยก; Protection/Close ต้องไม่ถูก Gate หยุด |
| S15 | Demo | P-MAN | REFILL และ Restart; Save failure เป็นรายการย่อยแยก ไม่ใช้ผล Save success แทน |
| S16 | Tester | P-CAP | เทียบ Fixed/Auto-Lot, หลายระดับทุนและเพดาน; ต้องรอ Broker volume constraints ก่อนเลือกค่า |
| S17 | Tester | P-AUTO | Timeout=true; เก็บเวลาที่ Basket ว่างและ Order ถัดไป; Session ปิดในกรณีแยก Timeout; Spread policy ต้องระบุ |
| S18 | Tester / Demo auto | P-AUTO | SpreadCheck=true; เก็บ Bid/Ask และหน่วย EA; ใช้ Auto ไม่ใช้ Manual พิสูจน์ Gate |
| S19 | Tester | P-AUTO | ใช้ Session variants ตามเวลา Server; กรณี Session แรกผิดต้องยังตรวจ Session ถัดไปที่ถูกต้อง |
| S20 | Tester | P-AUTO | หลาย Cycle; เก็บ RNET/CSTART และดีล Commission ฝั่งเปิดก่อน/หลัง |
| S21 | Tester + Demo | P-REP-T / P-REP-D | ReportDays=1; Tester range ต้องครบ Period และ Basket ว่าง; เพิ่มลำดับ Report ก่อน Manual บน Demo |
| S22 | Demo fixture | P-REP-D | ต้องมี CSV ที่สมบูรณ์จาก Demo scope เดียวกัน; ห้ามเอา CSV Tester มาปน; RPD recovery ยังรอออกแบบ fixture |
| S23 | Demo fixture | P-REP-D | แยกไฟล์ผิดรูปแบบ/write failure/stale gate; ไม่สร้าง false coverage จาก FileOpen failure |
| S24 | Demo fault fixture | P-FAULT | ต้องพิสูจน์ open failure/partial/volume mismatch ที่เกิดจริง; ไม่ถือว่าทุก subpath ครอบคลุม |
| S25 | Demo fault fixture | P-FAULT | ใช้ State/Position ของชุดนี้; Close failure ต้องรักษา Best; Modify failure ไม่อ้างสำเร็จ |
| S26 | Demo fixture | P-LEG | State import ทำเมื่อ Basket ว่าง; Trail import ต้อง Position ที่ยังเปิดและยืนยันเจ้าของ; แยกสองรอบตาม namespace จริง; ปิด import หลังใช้ |

## 5. กติกาเปลี่ยนโปรไฟล์และแยก State

- เปลี่ยนโปรไฟล์บน Demo เมื่อ Basket ว่าง ยกเว้น lifecycle/restart/migration ที่ออกแบบไว้เฉพาะ
- S12 ต้องคง identity และ Inputs เดิม ห้ามใช้เปลี่ยนโปรไฟล์เป็น Restart evidence
- ไม่ลบหรือย้อน State เหมารวมเพื่อให้หลาย case เริ่มใหม่ ให้กำหนด isolation ต่อ scenario ตอน Preflight
- Magic Short/Long จะยืนยันก่อนรัน และอาจต้องจัด identity ย่อยสำหรับ Capital/Recovery/Migration เพื่อไม่ปน History
- Terminal State และ Tester Agent State แยกกัน; ไม่ใช้ F3 ของ Terminal เป็นหลักฐานเปลี่ยน Tester State
- Report recovery บน Demo ต้องใช้ CSV/State ของ Demo scope เดียวกัน
- หนึ่ง EA instance ต่อ Symbol + Magic; ห้ามใช้หลาย instance แทน fault fixture
- ไม่ Compile หรือเปลี่ยน Source แทรกระหว่างกรณี

## 6. หลักฐานขั้นต่ำที่จัดตามก้อนงาน

แต่ละ run เก็บ Source SHA + Preset ที่โหลดจริง + Case IDs + เวลาเริ่ม/จบ + environment
Tester: settings/date range/tick model, Journal, History/deals ที่เทียบได้, CSV, SL snapshots ตามกรณี
Demo: Experts/Journal, Trade/History/Panel, State snapshots เฉพาะกรณี, CSV
เหตุสำคัญต้องระบุ Ticket/เวลา เพื่อผูกหลักฐานเข้ากับเหตุ ไม่ตัดสินจากภาพปลายทางอย่างเดียว
ผู้ใช้เก็บหลักฐานรวม AI ช่วยอ่านและเติม Checklist ไม่ให้ตรวจ CSV ทุกช่องเอง

## 7. เงื่อนไขความครอบคลุมและการหยุด

ทุก Case ยัง NOT_RUN ไม่ใช่ PASS หลังเขียนแผน
เหตุที่ไม่เกิด/ไม่มีหลักฐานให้ NOT_COVERED; สิ่งแวดล้อมบล็อกให้ ENVIRONMENT_BLOCKED
ถ้าเกิดคู่ซ้อน, exposure ผิดนอก fixture, State/ทุนผิดจนเชื่อไม่ได้ หรือ Source ผิดชุด ให้หยุดและเก็บหลักฐาน
การเหลือขาเดียวหลังขาหนึ่งปิดตามกติกา ไม่ใช่ข้อผิดพลาดโดยตัวมันเอง
Fault fixture ต้องผ่านการตรวจวิธีสร้างเหตุและคืนสภาพก่อนเริ่ม ห้ามทดลองทำลาย State กลางรัน

## 8. สถานะสิ้นขั้นนี้

จัด Profile design และ mapping 26 cases แล้ว; ยังไม่มี executable .set และยังไม่เปิด Order
ขั้นถัดไป: ตรวจ Fixture/วิธีคืนสภาพ/coverage limits ให้ครบในก้อนเดียว
จากนั้นจึงเก็บ Specification/Spread/Magic เพื่อ finalize .set และ Preflight ก่อน Short Test
