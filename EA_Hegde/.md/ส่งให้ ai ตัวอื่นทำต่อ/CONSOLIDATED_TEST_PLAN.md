# CONSOLIDATED TEST PLAN — Hedge 1.0 MT5

วันที่จัดทำ: 14 ตุลาคม 2026

ใช้ร่วมกับ:

- HANDOFF_Hedge1_Phase4.md
- BASELINE_MANIFEST_Hedge1.md
- START_PROMPT_NEXT_AI.md
- TEST_CHECKLIST_Hedge1.md

## 1. Baseline และสถานะเริ่มต้น

Logic Baseline:

```text
9900a1e364b7aac01a8f6e3984ce451f34553259
```

ผู้ใช้รายงาน:

```text
0 errors
0 warnings
```

สถานะ Runtime:

```text
Short Test: ยังไม่มีผลส่งมาให้ตรวจ
Long Run: ยังไม่มีผลส่งมาให้ตรวจ
Production approval: ยังไม่มี
```

อาจมี Comment-only edits สองจุดหลัง Baseline
ให้ตรวจ Working Diff ตาม Baseline Manifest

ห้ามถือว่า Compile ผ่านเท่ากับทดสอบผ่าน
ห้ามถือว่าเอกสารนี้เป็นหลักฐานการรันจริง

## 2. เป้าหมายและ Workflow ที่ตกลงแล้ว

ผู้ใช้ต้องการทำงานพัฒนาให้ครบก่อน
แล้วทดสอบเป็นสองชุดใหญ่:

```text
ปิดงานพัฒนาและตรวจ Source
→ เตรียม Preset / Checklist / หลักฐานให้ครบ
→ Short Test แบบรวม
→ Long Run ข้ามวัน
→ เก็บและตรวจผลเป็นรอบใหญ่
```

ห้ามเปลี่ยนกลับเป็น:

```text
แก้หนึ่งจุด
→ เปิด Order ทดสอบ
→ ขอผลจากผู้ใช้
→ แก้อีกจุด
→ ทดสอบอีกครั้ง
```

การแบ่ง Checklist เป็นหมวดมีไว้จัดระเบียบ
ไม่ใช่ให้ผู้ใช้หยุดส่งผลและรอคำตอบหลังทุกกรณี

## 3. กติกาควบคุมเวอร์ชันระหว่างทดสอบ

- ใช้ Source Baseline เดียวตลอดชุดที่กำหนด
- เปลี่ยน Inputs ตามกรณีทดสอบได้เมื่อเตรียมไว้ในแผน
- ไม่เปลี่ยน Logic เงียบ ๆ ระหว่างรัน
- ไม่ Compile แทรกระหว่างกรณีโดยไม่ประกาศเปลี่ยนชุดทดสอบ
- ไม่รวมหลักฐานหลาย Source เวอร์ชันแล้วเรียกว่าผลชุดเดียว
- ไม่ Commit + Push หลังทุกกรณี
- บันทึกรวมเมื่อจบ Milestone ที่เหมาะสม

ถ้าพบบั๊กที่ต้องแก้:

1. เก็บหลักฐานและระบุ Source ที่เกิดเหตุ
2. แยกผลที่ทำไปแล้วออกจากผลหลังแก้
3. รวมข้อแก้เป็นชุดตามขอบเขต
4. Compile และกำหนดขอบเขตทดสอบซ้ำ
5. ไม่ประกาศว่ากรณีเดิมผ่านโดยไม่มีการตรวจซ้ำที่จำเป็น

ก่อน Compile หรือเริ่มชุด Test ที่ได้รับอนุมัติ
ต้องระบุ Step Target เพียงหนึ่งเป้าหมาย

## 4. ขอบเขตสภาพแวดล้อม

ใช้ Demo Hedging account สำหรับงานที่เกี่ยวกับบัญชีจริง

ใช้หนึ่ง Instance ต่อ Symbol + Magic
ไม่ใช้การรันหลาย Instance ใน Scope เดียวกัน
เป็นเงื่อนไขตั้งต้นของการทดสอบ Baseline นี้

ไม่ใช้เงินจริงสำหรับชุดทดสอบนี้

แยกสภาพแวดล้อมหลักฐานเป็น:

### 4.1 Strategy Tester

เหมาะกับงานที่ต้องใช้ Tick และเวลาย้อนหลัง เช่น:

- Cut Loss
- Break-even
- RR
- Armed Trailing
- Auto Entry
- Timeout
- Session
- Cycle ระหว่างหลายรอบ
- Report ที่ต้องครอบคลุมหลายวัน

ระบุในหลักฐาน:

- Symbol
- Timeframe
- Date range
- Tick model
- Preset ที่ใช้
- Source ที่ทดสอบ

ใช้ Every tick based on real ticks เมื่อมีข้อมูลเหมาะสม
หากต้องใช้โมเดลอื่น ให้บันทึกข้อจำกัดของหลักฐาน
ไม่อ้างว่าเป็นข้อมูล Real Ticks ทั้งที่ไม่ได้ใช้

### 4.2 Demo chart

ใช้ยืนยันงานที่เกี่ยวกับการใช้งานจริง เช่น:

- ปุ่ม HEDGE / BUY LOCKED / SELL LOCKED
- คำสั่งปิด
- REFILL
- Restart และ Lifecycle
- Terminal State
- Migration และ Recovery
- Failure fixture ที่เตรียมไว้สำหรับ Demo

อย่าใช้ State ที่แก้ใน Terminal ผ่าน F3
ไปอ้างว่าเปลี่ยน State ของ Tester Agent แล้ว

Tester และ Demo ต้องมีป้ายกำกับหลักฐานแยกกัน

## 5. ข้อมูลที่ต้องมี ก่อนสร้าง Preset พร้อมใช้งาน

ข้อมูลต่อไปนี้ยังต้องยืนยันจาก Symbol Demo จริง:

- ชื่อ Symbol รวม Suffix
- Digits
- Tick Size
- Stops Level
- Volume Min
- Volume Max
- Volume Step
- Bid/Ask หรือ Spread สดเมื่อเชื่อมต่อปกติ
- Account mode เป็น Hedging
- หน่วย InpPointDigits ที่ผู้ใช้ตั้งใจใช้
- Magic สำหรับ Short และ Long ที่ยืนยันว่าไม่เคยใช้

ห้ามเดาว่า:

- Symbol ทุก Broker ใช้ชื่อเดียวกัน
- Native point เท่ากับหน่วย Point ของ EA
- Cut Loss 70 Points ผ่าน Broker เสมอ
- Base Lot ที่ตั้งจะตรงกับ Volume ที่ Broker รองรับเสมอ
- Magic ตัวอย่างเป็นเลขที่ไม่เคยใช้จริง

หากข้อมูลไม่ครบ ให้หยุดที่ขั้นเตรียม Preset
ไม่สร้างไฟล์ที่อ้างว่าพร้อมรันโดยไม่มีเงื่อนไข

## 6. Preflight ก่อนเริ่มชุดทดสอบ

ต้องตรวจให้ครบ:

| รายการ | เงื่อนไข |
|---|---|
| Source | ตรง Baseline หรือมี Diff ที่ตรวจแล้ว |
| Compile | มีผลของ Source ชุดที่จะใช้จริง |
| Account | Demo และ Hedging |
| Symbol | ตรงกับ Specification ที่ตรวจ |
| EA Instance | หนึ่ง Instance ต่อ Symbol + Magic |
| Preset | โหลดไฟล์ที่ถูกต้องและบันทึกค่าที่ใช้จริง |
| History | ไม่มีข้อมูลเก่าของชุดอื่นปนโดยไม่ตั้งใจ |
| State | Magic/Account/Symbol และ Migration ถูกต้อง |
| Connection | สภาพการเชื่อมต่อถูกบันทึกและเหมาะกับกรณีทดสอบ |
| Evidence | เตรียมวิธีเก็บ Log/ภาพ/CSV แล้ว |

หากผิดจาก Path, ไฟล์, History, Account หรือ Broker limits
ให้ใช้ Environment Pause

แก้สภาพแวดล้อมก่อน
ไม่เปลี่ยน Logic เพื่อแก้ Error จากการใช้ไฟล์ผิดชุด

## 7. Preset Design — Short Test

ยังเป็น Draft จนกว่าจะมีข้อมูล Broker ครบ

### 7.1 โครงระยะตั้งต้น

ให้ k เป็นสเกลที่เลือกหลังตรวจข้อจำกัดจริง:

| Input | Draft |
|---|---:|
| Cut Loss | 70 × k |
| Break-even Trigger | 120 × k |
| Break-even Step | 10 × k |
| Trailing Pullback | 50 × k |
| Break-even Percent | 20 |

จากสูตรปัจจุบัน:

```text
Trailing Arm = Cut Loss + Pullback
             = 120 × k
```

อย่าบังคับ k = 1 หากระยะไม่ผ่าน Broker

ตัวเลขนี้เป็นระยะราคาในหน่วยของ EA
ไม่ใช่จำนวนเงินกำไรหรือขาดทุนต่อ Position

### 7.2 กรณีเน้น Trailing

```text
RR Percent = 0
Trailing TP = true
Break-even Mode = BE_TRAILING
Break-even Percent = 20
```

เป้าหมายคือไม่ให้ RR แย่งปิดก่อน
จนตีความผล Trailing ผิด

### 7.3 กรณีเน้น RR

```text
RR Percent = 200
Trailing TP = false
Break-even Mode = BE_OFF
Break-even Trigger = 120 × k
```

ยังต้องคง Trigger เพราะ RR ใช้ Trigger คำนวณเป้า

เป้า RR ตาม Draft:

```text
RR Target = 240 × k
```

### 7.4 Fixed Lot และ Auto-Lot

เริ่มกรณีที่ต้องแยก Logic การเปิด/ปิด
ด้วย Volume ที่ยืนยันตาม Specification

จากนั้นทดสอบ Auto-Lot เป็นกรณีที่เตรียมไว้ในชุดเดียวกัน

ไม่เปลี่ยน Source เพื่อสลับกรณี
ใช้ Inputs/Preset ที่ระบุไว้ก่อนเริ่ม

### 7.5 Auto และ Manual

กรณี Auto/Tester:

```text
InpReopenOnEmpty = true
```

เฉพาะโปรไฟล์และช่วงที่ต้องตรวจ Auto Entry

กรณี Manual/Lifecycle:

```text
InpReopenOnEmpty = false
```

เพื่อไม่ให้ Auto เปิดรอบใหม่แทรกระหว่างการตรวจที่ตั้งใจ

เปลี่ยนโปรไฟล์เมื่อ Basket ว่าง
ยกเว้นกรณี Restart ที่กำหนดไว้โดยเฉพาะ

### 7.6 Report

กรณีตรวจ Report:

```text
InpEnableReport = true
InpReportDays = 1
```

ช่วงย้อนหลังต้องยาวพอให้ถึงเงื่อนไขจริง
และต้องมีโอกาส Basket ว่าง

ไม่ตีความว่ารันครบไม่กี่นาทีของเวลาจริง
เท่ากับครบหนึ่งวันในข้อมูลที่จำลอง

### 7.7 Legacy Import

ค่าตั้งต้น:

```text
InpTrailImportLegacy = false
InpStateImportLegacy = false
```

เปิดเฉพาะกรณี Migration ที่เตรียมไว้
และยืนยันเจ้าของ State ตามเงื่อนไขใน Handoff

ไม่เปิดไว้เพียงเพื่อให้ระบบหา State อะไรก็ได้มาใช้

## 8. ขอบเขต Short Test — 26 กรณี

รายละเอียดรายกรณีอยู่ใน TEST_CHECKLIST_Hedge1.md

ครอบคลุม:

- Invalid Inputs
- Hedge Entry
- Duplicate Hedge
- Locked BUY/SELL
- Close Buttons
- Cut Loss
- BE Fixed
- BE Trailing
- Missing SL
- Armed Trailing
- RR
- Restart
- Cleanup
- Capital Gate
- REFILL
- Auto-Lot
- Timeout
- Spread
- Session
- Cycle
- CSV Generation
- Report Recovery
- Report Failure
- Open Failure / Rollback
- Close / Modify Rejection
- Legacy Import

ให้จัดลำดับการรันทั้งหมดก่อนเริ่ม
ไม่เปลี่ยนเป็นการขอผู้ใช้ตอบกลับหลังทุกกรณี

## 9. Restart และ State Test

กรณีที่ต้องพิสูจน์ Restore เดิม
ต้องคง Identity และหน่วยที่เกี่ยวข้อง:

- Account
- Symbol
- Magic
- InpPointDigits
- ระยะ Protection ที่กำลังตรวจ

ห้ามเปลี่ยนหลายกติกาพร้อม Restart
แล้วสรุปว่า Restore ของกติกาเดิมถูกต้อง

หลักฐานที่ต้องเก็บตามกรณี:

- State ก่อน Restart
- Inputs ก่อนและหลัง
- Position Ticket ที่เกี่ยวข้อง
- Experts Log หลัง Restart
- ผลการทำงานหลัง Restore

หากใช้ State fixture ที่สร้างขึ้นเพื่อทดสอบ
ต้องระบุว่าเป็น fixture

ห้ามอ้างว่าเป็น Best ที่ราคาตลาดวิ่งถึงจริง
หากไม่มีหลักฐานการวิ่งถึงจุดนั้น

## 10. Failure และ Fault Fixture

บางกรณีไม่สามารถยืนยันจากการรันปกติที่ไม่มี Error

ตัวอย่าง:

- เปิดอีกฝั่งไม่สำเร็จ
- Partial Fill
- Close ถูกปฏิเสธ
- Modify ถูกปฏิเสธ
- Global Variable Save ล้มเหลว
- CSV Write ล้มเหลว
- ไฟล์รายงานผิดรูปแบบ
- Report เสร็จแต่ State ยังไม่อัปเดต

ก่อนทำ Fault Test ต้องเตรียม:

1. วิธีสร้างเหตุ
2. ขอบเขต Demo/ไฟล์/State ของชุดทดสอบ
3. ผลที่คาดหวัง
4. วิธีคืนสภาพ
5. หลักฐานที่จะพิสูจน์เส้นทางที่เกิดจริง

ไม่ทำลาย State หรือไฟล์ของชุดอื่น
ไม่ใช้เงินจริง
ไม่ปรับ Logic เงียบ ๆ เพื่อทำให้ผลดูผ่าน

ถ้ายังสร้างเหตุไม่ได้หรือไม่มีหลักฐาน
ให้ระบุ NOT_COVERED

FileOpen ล้มเหลว ไม่ใช่หลักฐานว่าได้ทดสอบ
Partial FileWrite ล้มเหลวแล้ว

ต้องระบุเส้นทางที่ทดสอบได้จริงให้ตรง

## 11. การจบ Short Test

หลังรันครบชุดที่เตรียมไว้:

- เก็บผลและหลักฐานรวม
- ไม่ถือว่าทุกข้อผ่านจากการไม่มี Error
- ระบุกรณีไม่เกิดหรือทำไม่ได้
- ระบุเหตุที่บล็อกจากสภาพแวดล้อม
- หากมีปัญหาร้ายแรง ให้หยุดและจัดขอบเขตแก้ก่อนรันต่อ

ไม่ปล่อย Long Run ต่อเพียงเพื่อให้ครบแผน
หากมีความผิดปกติด้าน Exposure หรือข้อมูลที่ยังไม่ควบคุม

การตรวจผลยังเป็นรอบรวม
ไม่กลับไปให้ผู้ใช้ส่งผลทีละฟีเจอร์

## 12. Preset Design — Long Run

ใช้ Source เดียวกับชุดที่ล็อกไว้
ไม่เพิ่มฟีเจอร์ระหว่างรัน

ค่าระยะอ้างอิง:

```text
Cut Loss = 700
Break-even Trigger = 1200
Break-even Percent = 20
Break-even Step = 100
Trailing Pullback = 500
RR Percent = 200

Auto Reopen = true
Timeout = 300
Spread Check = true
Max Spread = 25
```

ต้องตรวจว่าค่าอ้างอิงใช้กับ Symbol จริงได้
ก่อนถือว่า Preset พร้อมรัน

อย่าเพิ่ม Max Spread เพียงเพื่อบังคับให้เกิด Order

กรณีตรวจ Report ในรอบข้ามวัน:

```text
ReportDays = 1
```

เก็บ Preset ปกติที่ใช้ ReportDays = 5 แยกไว้

Session:

- ใช้เวลา Server
- เลือกช่วงที่ทำให้การรันครอบคลุม Block/Open
- บันทึก Inputs จริงก่อนเริ่ม
- ไม่สลับเวลาไปมาตลอดการรันโดยไม่ระบุเหตุ

Legacy Import:

```text
false
```

ยกเว้นงานนำเข้าที่ได้รับการเตรียมและตรวจแล้ว

## 13. ระยะเวลาและความครอบคลุม Long Run

วางแผนประมาณ 24–48 ชั่วโมงตามสภาพตลาดและข้อมูล

แต่เกณฑ์ไม่ได้มีเพียงเวลาที่เปิดโปรแกรมไว้:

- มี Tick ให้ EA ทำงาน
- มีรอบ Basket จริงตามเงื่อนไข
- มี Session boundary ที่ต้องตรวจ
- Report ถึงกำหนดจริง
- มีโอกาส Basket ว่างสำหรับ Report
- มีหลักฐาน Protection/State ตามเหตุที่เกิด

การข้ามเที่ยงคืนในเวลาท้องถิ่นอย่างเดียว
ไม่ยืนยันว่าครบรอบ Report

การมี Order จำนวนน้อยเพราะ Spread Gate
อาจเป็นการทำงานตามกติกา
แต่ไม่ใช่หลักฐานว่าฟีเจอร์ที่ไม่เกิดผ่านแล้ว

ไม่เปลี่ยนกติกาเพียงเพื่อผลิตผลทดสอบที่ดูดี

## 14. ขอบเขต Long Run — 8 กรณี

1. Multiple Rounds
2. Session Boundaries
3. Protection Events ที่เกิดจริง
4. State และ Restart
5. Accounting
6. Report Maturity
7. Connection Events ที่เกิดจริง
8. Run Health

รายละเอียดรายกรณีอยู่ใน TEST_CHECKLIST_Hedge1.md

เหตุที่ไม่เกิดต้องเป็น NOT_COVERED
ไม่ใช่ PASS จากการรันครบชั่วโมง

## 15. เงื่อนไขหยุดและเก็บหลักฐาน

หยุดรันเมื่อเกิดเหตุร้ายแรงที่อยู่นอกการควบคุมของ Fixture เช่น:

- เริ่ม Basket ใหม่ทั้งที่ Basket เดิมยังค้าง
- Exposure ไม่ตรงกับกติกาและไม่อยู่ในขั้นเปิดคู่/Rollback ที่กำหนด
- SL หายและระบบไม่พยายามจัดการตามกรณีที่ตรวจ
- ข้อมูลทุนหรือ State ผิดจนไม่อาจเชื่อผลต่อได้
- มีการเปลี่ยน Source โดยไม่บันทึก
- ใช้บัญชีจริงหรือสภาพแวดล้อมผิดจากแผน
- ไม่สามารถยืนยันได้ว่ากำลังรันไฟล์ที่ตั้งใจ

การเหลือขาเดียวหลัง SL/RR/Trailing
ไม่ใช่ความผิดปกติโดยตัวมันเอง
เพราะระบบปัจจุบันให้ขาที่เหลืออยู่ต่อภายใต้ Protection

ต้องแยกเหตุที่คาดไว้ใน Fault Fixture
ออกจากเหตุผิดปกติที่เกิดโดยไม่ได้เตรียม

## 16. หลักฐานที่ต้องเก็บ

### ชุดข้อมูลอ้างอิง

- Source SHA
- Working Diff ถ้ามี
- Compile Result
- Preset ที่โหลดจริง
- Account mode
- Symbol Specification
- เวลาเริ่ม/จบและ Time basis ที่ใช้

### Tester

- Date range
- Timeframe
- Tick model
- Tester Journal
- CSV ที่สร้าง
- ภาพหรือข้อมูลของเหตุสำคัญ

### Demo

- Experts Log
- Journal Log
- ภาพ Trade / History / Panel ที่จำเป็น
- CSV
- State snapshots ของกรณีที่ต้องพิสูจน์

แยกที่มาของหลักฐาน:

```text
SHORT / TESTER
SHORT / DEMO
LONG / DEMO
```

นี่เป็นป้ายกำกับการจัดหลักฐาน
ไม่ใช่การกำหนด Absolute Path บนเครื่องผู้ใช้

## 17. หน้าที่ผู้ใช้และ AI ผู้ตรวจ

ผู้ใช้:

- ใช้ Source/Preset ตามชุดที่ยืนยัน
- ดำเนินการตามชุดทดสอบที่เตรียมครบ
- เก็บหลักฐานรวม
- แจ้งเหตุผิดปกติร้ายแรงและหยุดเมื่อจำเป็น

AI ผู้ตรวจ:

- เตรียมขั้นตอนและเกณฑ์ให้ครบก่อนเริ่ม
- อ่าน Log/CSV/ภาพรวม
- ตรวจว่าหลักฐานตรงกับ Source/Inputs/กรณี
- เติมผล Checklist
- ไม่ให้ผู้ใช้ต้องเปิด CSV ไล่ตรวจทุกช่องเอง
- ไม่ประกาศผลเกินหลักฐาน

## 18. ป้ายผลทดสอบ

### PASS

มีหลักฐานตรงกับผลที่คาดหวัง
และอยู่ในขอบเขต Source/Inputs/Environment ที่ระบุ

### FAIL

มีหลักฐานว่าพฤติกรรมไม่ตรงกับเกณฑ์ของกรณี

### NOT_COVERED

เหตุไม่เกิด ยังไม่ได้ทำ หรือไม่มีหลักฐานเพียงพอ

### ENVIRONMENT_BLOCKED

กรณีดำเนินต่อไม่ได้เพราะ Path, ไฟล์, History,
Account, Symbol, Connection หรือ Broker constraints

ห้ามแปลง NOT_COVERED หรือ ENVIRONMENT_BLOCKED เป็น PASS

## 19. ข้อจำกัดที่ต้องอยู่ในรายงานผล

- หนึ่ง Instance ต่อ Symbol + Magic
- ไม่มี Cross-instance Lock
- Namespace ยังไม่รวม Broker Server
- Ticket-change service operations ยังไม่รองรับครบ
- CSV Completion ไม่ใช่ Checksum ทั้งไฟล์
- Accounting เป็น Profit + Swap + Commission ของ Scope EA
- Broker rules และ Fill ต้องยืนยันจากการรันจริง
- Source/Binary equivalence ยังไม่ได้พิสูจน์โดยอิสระ
- ผล Compile ไม่แทน Runtime evidence

หากกรณีทดสอบต้องขยายออกนอกข้อจำกัดนี้
ให้ตกลงขอบเขตพัฒนาใหม่ก่อน
ไม่เปลี่ยน Logic แทรกระหว่างชุดเดิม

## 20. เกณฑ์ปิดงานและรับช่วงต่อ

เมื่อได้ผล Short และ Long:

1. ตรวจ Source/Inputs/Environment ของหลักฐาน
2. เติม Checklist ตามหลักฐานจริง
3. สรุป PASS/FAIL/NOT_COVERED/ENVIRONMENT_BLOCKED
4. แยกบั๊กจากข้อจำกัดและสภาพแวดล้อม
5. รวมข้อแก้ที่จำเป็นเป็นชุด
6. กำหนดขอบเขต Retest
7. บันทึก Milestone เมื่อจบก้อนงาน
8. ไม่อนุมัติ Production เพียงเพราะ Compile หรือรันครบเวลา

## 21. งานถัดไปทันที

ยังไม่เริ่มเปิด Order

ต้องเก็บ Specification/Spread และยืนยัน Test Magic
เพื่อสร้าง Preset พร้อมใช้งานและขั้นตอนทั้งชุดให้ครบก่อน

หลังเตรียมครบ:
Short Test แบบรวม → Long Run ข้ามวัน → ตรวจหลักฐานรวม