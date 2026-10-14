# AI HANDOFF — Hedge 1.0 MT5

วันที่จัดทำ: 14 ตุลาคม 2026

เอกสารนี้ใช้ส่งต่อโปรเจกต์ Hedge 1.0 ให้ AI ตัวใหม่
ไม่ใช่ Handoff ของ HedgeDrift Core หรือ EA โปรเจกต์อื่น

## 1. Source และ Baseline ที่ใช้รับช่วง

Repository:

https://github.com/vhpknn/EA_4_Hegde_Buy_Sell_Both

Branch ที่ตรวจล่าสุด:

audit/phase-2-3-trailing-restart-strict-basket

Logic Baseline Commit:

9900a1e364b7aac01a8f6e3984ce451f34553259

ชื่อ Commit:

EA_Hegde_Phase 4 complete - final audit fixes

ขอบเขต Source คือโฟลเดอร์ EA_Hegde เท่านั้น

ในการตรวจล่าสุด main ยังอยู่ที่ Commit เก่ากว่า:

45dded382331f8f8468abc7c0298dde057354cb6

ห้ามใช้ main โดยอัตโนมัติแทน Baseline ที่ระบุ

หาก Branch มี Commit ใหม่กว่านี้ ให้ตรวจ Diff และยืนยันขอบเขต
ก่อนเปลี่ยนฐานการทำงาน ห้ามเดาว่า HEAD ใหม่มีพฤติกรรมเหมือนเดิม

ชื่อโฟลเดอร์และ Repository ใช้คำว่า Hegde ในบางตำแหน่ง
ห้ามเปลี่ยนชื่อ Path เพื่อแก้การสะกดโดยไม่ได้ตรวจ Include

ค่า #property version ของไฟล์หลักยังเป็น 1.00
ให้ใช้ Commit และ Diff เป็นหลักฐานรุ่น ไม่ใช้เลขนี้ตัดสินว่าไฟล์เก่า

## 2. สถานะการยืนยัน

สิ่งที่ยืนยันแล้ว:

- ผู้ใช้รายงาน Compile ผ่าน 0 errors / 0 warnings
- ตรวจ Source รวมที่ Commit 393d9a0 แล้ว
- ตรวจ Diff ของสามจุดแก้สุดท้ายที่ Commit 9900a1e แล้ว
- โมดูลอื่นคง SHA เดิมตามชุดที่ตรวจไว้ ไม่ได้ย้อนกลับเป็น Source เก่า

สามจุดแก้สุดท้าย:

1. Capital ตรวจผลการอ่าน History Property
2. SL ที่หายยังเข้าบล็อกติดตั้งได้ แม้กำไรเลย BE Trigger
3. Rollback ตรวจ Basket ว่างหลังรอบปิดสุดท้าย ก่อนแจ้ง CRITICAL

สิ่งที่ยังไม่ยืนยัน:

- ยังไม่มีผล Short Test ส่งมาให้ตรวจ
- ยังไม่มีผล Long Run ข้ามวันส่งมาให้ตรวจ
- ยังไม่มีหลักฐานว่าทุกกรณีทำงานถูกต้องใน Runtime
- ยังไม่ได้อนุมัติใช้เงินจริงหรือประกาศ Production-ready
- ยังไม่ได้ตรวจพิสูจน์ความตรงกันของ Binary .ex5 กับ Source โดยอิสระ

ห้ามแปลงคำว่า Compile ผ่าน เป็นคำว่า ทดสอบผ่าน
ห้ามรับรองว่าไม่มีบั๊กทั้งหมด

## 3. Working Copy ที่อาจต่างจาก Baseline

หลัง Commit 9900a1e มีการเสนอแก้ Comment สองจุด:

1. หัว Hedge1.0.mq5:
   เปลี่ยนคำอธิบายลำดับ Engine/Report ให้ตรงกับ
   Protect → Report → Engine → Panel
   และไม่กล่าวถึงการเปิดขาที่หาย

2. หัว Hedge1_Report.mqh:
   เปลี่ยนคำอธิบายชื่อ CSV เป็น
   Symbol_Account_Magic_FROM_PeriodStart.csv

ยังไม่มีการยืนยันว่าผู้ใช้วาง Comment สองจุดนี้แล้วหรือไม่

ให้ตรวจ Working Copy จริง หากมีเพียงสองข้อความนี้ต่าง
อย่าเรียกว่าเป็นการเปลี่ยน Logic

## 4. กฎการทำงานของผู้ใช้

### 4.1 ทำงานเป็น Phase ใหญ่

- ทำ Patch ตามขอบเขตที่ตกลงให้ครบทุกไฟล์ก่อน Market Test
- Compile หลังชุด Patch ที่เกี่ยวข้องได้
- ไม่หยุดเปิด Order ทดสอบหลังแก้แต่ละจุด
- ไม่วน Patch → Test → Patch ทีละฟีเจอร์โดยไม่ปิดขอบเขต
- ไม่เพิ่มฟีเจอร์หรือเปลี่ยนกลยุทธ์โดยไม่ได้รับคำสั่ง

### 4.2 Commit และเอกสาร

- ไม่สั่ง Commit + Push ทุก Patch ย่อย
- รวบรวมเมื่อจบ Phase ใหญ่หรือ Milestone ที่เหมาะสม
- ไม่อัปเดตเอกสาร Ledger ทุกครั้งที่แก้ FIND/REPLACE
- หากส่งต่องานหรือบริบทคลาดเคลื่อน ให้ใช้ Commit/Diff/ไฟล์ปัจจุบัน
  เพื่อกู้สถานะ ไม่อาศัยความจำหรือเดา Source

### 4.3 Step Target

ก่อนสั่ง Compile หรือ Test ต้องระบุ Step Target
ที่ชัดเจนเพียงหนึ่งเป้าหมาย และไม่เพิ่มขอบเขตกลางรอบ

### 4.4 Environment Pause

หากปัญหาเกิดจาก:

- เปิดไฟล์ผิดโฟลเดอร์
- Source กับไฟล์ที่ Compile คนละชุด
- Include/Path ผิด
- ไฟล์หรือ History ขาด
- บัญชีหรือ Symbol ไม่ตรง
- ข้อจำกัด Broker ไม่ผ่าน

ให้หยุดแก้ Logic และแก้สภาพแวดล้อมก่อน
ห้ามไล่แก้โค้ดตาม Error ที่เกิดจากไฟล์ผิดชุด

### 4.5 ไม่ขอ Source ซ้ำโดยไม่จำเป็น

อ่าน Source ฐานให้ครบครั้งแรก
จากนั้นใช้ Commit + Diff + Patch ที่ยืนยันแล้ว

ขอเฉพาะไฟล์หรือบล็อกที่มีความคลาดเคลื่อนจริง
ไม่ขอ Source ทั้งโปรเจกต์ใหม่ทุกครั้งที่แก้จุดเล็ก

## 5. Jigsaw Patch Rule

ทุกการแก้โค้ดต้องระบุไฟล์และใช้รูปแบบนี้:

FIND:
```text
[โค้ดเดิมจริงที่มีอยู่ในไฟล์]
```

REPLACE:
```text
[โค้ดใหม่ครบทั้งบล็อกที่จะวางแทน]
```

ข้อกำหนด:

- FIND ต้องตรงกับ Source ที่ผู้ใช้กำลังแก้
- ไม่ใช้ Pseudocode แทนโค้ดเดิม
- ระบุขอบเขตให้ชัด ไม่ให้ผู้ใช้เดาปีกกา
- ไม่วางฟังก์ชันใหม่ซ้ำกับฟังก์ชันเดิม
- ไม่เปลี่ยนไฟล์หรือชื่อฟังก์ชันเพิ่มนอกขอบเขตโดยพลการ
- ถ้า Source ไม่ตรง ให้หาฐานที่ถูกต้องก่อนส่ง Patch
- ไม่ส่ง Patch ที่ยังไม่ตรวจ แล้วค่อยเตือนท้ายข้อความว่าอาจผิด
- ไม่รับประกันผล Compile หรือ Runtime ก่อนมีหลักฐานจริง

## 6. โครงสร้างโปรเจกต์

EA_Hegde/
├── Hedge1.0.mq5
└── include/
    ├── Hedge1_Inputs.mqh
    ├── Hedge1_Utils.mqh
    ├── Hedge1_Capital.mqh
    ├── Hedge1_Session.mqh
    ├── Hedge1_Engine.mqh
    ├── Hedge1_Protect.mqh
    ├── Hedge1_Panel.mqh
    └── Hedge1_Report.mqh

หน้าที่:

- Main:
  Lifecycle, Input validation และลำดับโมดูล

- Inputs:
  Inputs และ BE enum

- Utils:
  หน่วย Point, การแปลงราคา, Spread และ State namespace กลาง

- Capital:
  อ่านยอดสุทธิ/REFILL/ทุนพร้อมสถานะ, Auto-Lot และ Volume validation

- Session:
  เวลา HH:MM และตรวจแต่ละ Session อย่างอิสระ

- Engine:
  ส่งคำสั่ง, เปิดคู่, Verify/Rollback, Entry Gates และเริ่ม Cycle

- Protect:
  Cut Loss, Break-even, RR, Armed Trailing และ Trail State

- Panel:
  แสดงข้อมูล, ปุ่ม, Cycle แบบอ่านค่า และสถานะ N/A

- Report:
  Report Gate, CSV Write, Completion และ Recovery

## 7. กติกากลยุทธ์ปัจจุบัน

### 7.1 One Basket

- ใช้บัญชี MT5 แบบ Hedging
- ขอบเขต Basket คือ Symbol + Magic ของ EA
- ไม่ใช่กฎห้ามทุก Position ของทั้งบัญชี
- เปิดคู่ใหม่ได้เมื่อ Basket ในขอบเขตนี้ว่างเท่านั้น
- เปิดคู่เป็น Buy 1 + Sell 1 พร้อมตรวจ Volume จริง
- ถ้าเปิดคู่ไม่ครบหรือ Volume ไม่ตรง ให้ Rollback
- เมื่อขาหนึ่งปิด อีกขาคงให้ Protection จัดการต่อ
- ไม่เปิดขาที่หายกลับมา
- ไม่เพิ่มนโยบายปิดทั้ง Basket ตามขาแรกในรุ่นนี้

### 7.2 Manual

รุ่นปัจจุบันเป็น Strict Manual B แบบกำหนดไว้ในโค้ด:

- BUY เดี่ยวถูก Block
- SELL เดี่ยวถูก Block
- Panel แสดง BUY LOCKED / SELL LOCKED
- HEDGE OPEN เปิดคู่ผ่าน OpenHedgePair()
- HEDGE OPEN ข้าม Auto Session/Timeout/Spread checks
- แต่ไม่ข้าม Basket-empty, Capital และ Report gates
- คำสั่ง Close ยังใช้ได้

อย่าเอากติกา “Manual ข้ามทุกเงื่อนไข” จากโปรเจกต์เก่ามาแทน

### 7.3 Protection

ลำดับ:

Cut Loss → RR → Armed Trailing → Break-even

- Cut Loss ไม่คลาย SL ที่ป้องกันไว้ดีกว่าแล้ว
- SL ที่หายต้องเข้าบล็อกพยายามติดตั้งได้แม้เลย BE Trigger
- คำสั่ง Broker ยังต้องตรวจผลจริง
- ปิดไม่สำเร็จต้องไม่ลบ Trailing Best
- RR ที่ปิดก่อน ไม่ใช่หลักฐานว่า Trailing เสีย

### 7.4 Trailing

มีเฉพาะ Armed Trailing A:

Arm = Cut Loss Points + Trailing Pullback

- เริ่มติดตามหลังถึง Arm
- Best เพิ่มเฉพาะค่าที่ดีขึ้น
- ปิด Position ฝั่งนั้นเมื่อย่อครบ Pullback
- เก็บ Best ผ่าน Global Variable
- Restore ได้แม้กำไรปัจจุบันย่อต่ำกว่า Arm

ยังไม่มี Trailing From Entry B ในรุ่นนี้

### 7.5 หน่วยและทุน

- หน่วย Point กำหนดโดย InpPointDigits
- ไม่ควรถือว่าเท่ากับ native point ของ Broker เสมอ
- ระยะราคาเป็น Points ไม่ใช่กำไร/ขาดทุนเป็นเงินของ Position
- ยอดสุทธิของ EA ใช้ Profit + Swap + Commission
  ของ Symbol + Magic ที่ตรงกัน
- ไม่ใช่ยอดรวมทุกค่าธรรมเนียมที่อาจมีในทั้งบัญชี
- ทุน ≤ 0 หรืออ่านทุนไม่สำเร็จ ต้อง Block การเปิดคู่ใหม่
- Protection และ Close ไม่ถูก Capital Gate หยุด

## 8. State และ Migration

Trail Key:

H1T3_<login>_<symbol>_<magic>_D<pointdigits>_<ticket>

Money/Report/Cycle Key:

H1S_<login>_<symbol>_<magic>_<suffix>

Suffix ที่ใช้:

- REFILL
- RPD
- RNET
- CSTART

RTOT รุ่นเก่าไม่ใช้งานแล้ว
ไม่ลบ State เก่าแบบเหมารวม

Inputs การนำเข้า:

- InpTrailImportLegacy:
  ประกาศอยู่ใน Protect ไม่ใช่ Inputs
  ห้ามเพิ่มชื่อซ้ำ

- InpStateImportLegacy:
  ประกาศอยู่ใน Inputs
  นำเข้า State เก่าเมื่อยืนยันเจ้าของและ Basket ว่างเท่านั้น

ปิดโหมดนำเข้าหลังใช้ตามกรณีที่ตั้งใจ
ห้ามเปลี่ยน Namespace/Magic/Point Digits ระหว่างถือ State เดิม
โดยไม่มีแผน Migration

## 9. Cycle และ Report

### Cycle

- Engine บันทึก RNET ก่อนส่ง Order แรก
- CSTART เป็นเครื่องหมายว่าฐาน Cycle พร้อม
- Panel อ่านค่า ไม่ตัดสินเริ่ม Cycle จากจำนวน Position
- Cycle Loss แสดงเฉพาะผลขาดทุนที่บันทึกเป็นดีลแล้ว
- ไม่รวมกำไรลอยตัว
- ถ้าไม่มีฐานที่เชื่อถือได้ แสดง N/A ไม่เดาย้อนหลัง

### Report

- ตรวจเมื่อครบกำหนดและ Basket ว่าง
- Report ทำก่อน Engine เปิดรอบใหม่
- Report ที่ค้างหรือผิดพลาด Block การเปิดคู่ใหม่
- Protection ของ Position เดิมยังทำงาน
- ใช้ช่วงเวลา [Start, End)
- ดีลตรง End อยู่ในรายงานรอบถัดไป
- เขียน Temp ก่อน ตรวจ Write/Flush/Size/Close แล้วจึงย้ายเป็น CSV
- ไม่เขียนทับไฟล์ปลายทางที่มีอยู่แล้ว
- ชื่อไฟล์ระบุ Symbol, Account, Magic และเวลาเริ่มรอบ
- REPORT_COMPLETE เป็น Metadata ไม่ใช่แถวกำไร
- Recovery อ่าน End เดิมแล้วส่งกลับให้ ReportOnTick บันทึก
- ClosedTrades เป็นจำนวนดีลปิด ไม่ใช่ Position ที่ไม่ซ้ำ

## 10. ข้อจำกัดที่ต้องบันทึก ไม่ใช่ซ่อนเป็นคำว่า “ผ่าน”

- ใช้หนึ่ง Instance ต่อ Symbol + Magic ก่อน
- ยังไม่มี Lock ข้ามหลาย Instance
- Namespace มี Account Login แต่ไม่มี Broker Server
- Trailing ผูกกับ Ticket
  กรณี service operation เปลี่ยน Ticket ยังไม่รองรับครบ
- CSV Completion ตรวจโครงสร้าง/Marker ไม่ใช่ Checksum ทั้งไฟล์
- Stops Level, Freeze Level, Tick Size, Volume และ Fill จริง
  ต้องตรวจใน Runtime กับ Broker ที่ใช้
- Global Variables ของ Tester Agent กับ Terminal เป็นคนละสภาพแวดล้อม
- การรันเงียบหรือรันข้ามคืน ไม่พิสูจน์ว่าครบทุกฟีเจอร์
- เคสที่ไม่เกิดหรือไม่มีหลักฐานต้องเป็น NOT_COVERED ไม่ใช่ PASS

## 11. งานปัจจุบันที่ AI ใหม่ต้องทำต่อ

เตรียมชุดทดสอบให้ครบก่อนเริ่มรัน:

1. รับ Specification ของ Symbol Demo จริง:
   - ชื่อ Symbol รวม Suffix
   - Digits
   - Tick Size
   - Stops Level
   - Volume Min/Max/Step
   - Bid/Ask หรือ Spread สดเมื่อเชื่อมต่อปกติ

2. ยืนยัน Magic สำหรับ Short/Long ที่ยังไม่เคยใช้

3. ทำ Preset .set ที่พร้อมใช้งาน
   ปัจจุบันยังไม่ได้ส่ง Preset ที่รับรองกับ Broker นี้

4. ทำ Checklist, ผลที่คาดหวัง, หลักฐาน
   และขั้นตอน Fault Fixture ให้ครบก่อนเริ่ม

5. รัน Short Test ครบชุด แล้ว Long Run ข้ามวัน

6. เก็บหลักฐานรวมแล้วตรวจเป็นรอบใหญ่
   ไม่หยุดส่งผลให้ AI หลังแต่ละฟีเจอร์

## 12. โครงค่าทดสอบที่วางไว้ ยังเป็น Draft

Short:

- Cut Loss = 70 × k
- BE Trigger = 120 × k
- BE Step = 10 × k
- Pullback = 50 × k

ยังไม่ได้เลือก k เพราะขาด Specification/Spread จริง

กรณีเน้น Trailing:

- RR = 0
- Trailing = true
- BE_TRAILING
- BE Percent = 20

กรณีเน้น RR:

- RR = 200
- Trailing = false
- BE_OFF
- ยังคง Trigger สำหรับคำนวณ RR

Long reference:

- Cut Loss = 700
- BE Trigger = 1200
- BE Percent = 20
- BE Step = 100
- Pullback = 500
- RR = 200
- Timeout = 300
- Spread Check = true
- Max Spread = 25

อย่าเพิ่ม Spread limit เพียงเพื่อบังคับให้เกิดเทรด

Report Test อาจใช้ ReportDays = 1
แต่ต้องมีเวลา Server/Tick ครบเงื่อนไขและโอกาส Basket ว่าง
การข้ามเที่ยงคืนอย่างเดียวไม่เพียงพอ

บันทึก Preset ปกติที่ใช้ ReportDays = 5 แยกไว้

## 13. แผนการเก็บหลักฐาน

Short Test วางไว้ 26 กรณี
Long Run วางไว้ 8 กรณี

ทั้งหมดเริ่มต้นเป็น NOT_RUN

หลักฐาน:

- Source SHA และผล Compile
- Preset ที่โหลดจริง
- Tester date range/model/settings
- Experts / Journal
- ภาพ Position / History / Panel ที่จำเป็น
- CSV
- State snapshots สำหรับกรณี Recovery

แยก Short/Long และ Tester/Demo ให้ชัด

AI ผู้รับช่วงเป็นผู้ช่วยอ่านหลักฐานและเติมผล Checklist
ไม่ให้ผู้ใช้ต้องเปิด CSV ไล่ตรวจทุกช่องเอง

หากพบเหตุผิดปกติร้ายแรงให้หยุดรันและเก็บหลักฐาน
ไม่ปล่อยต่อเพื่อให้ครบเวลาและไม่อ้างว่าผ่าน

## 14. สิ่งที่ยังไม่ทำในรุ่นนี้

เก็บไว้เป็นงานอนาคต:

- Manual Override A / Strict B แบบเลือกโหมด
- Trailing From Entry B
- โหมดกลยุทธ์ใหม่อื่น ๆ

แนวคิด enum และ Inputs สำหรับโหมดเหล่านี้เคยคุยไว้
แต่ไม่ได้หมายความว่าถูก Implement แล้ว

ห้ามเพิ่มระหว่างช่วงทดสอบ Baseline นี้โดยไม่ได้รับคำสั่ง

## 15. คำตอบแรกที่ต้องการจาก AI ผู้รับช่วง

ให้ตอบ:

1. Baseline และ Source ที่อ่านจริง
2. สถานะ Compile แยกจากสถานะ Runtime
3. Working Diff ที่พบจริงถ้ามี
4. เป้าหมายเตรียมทดสอบถัดไปเพียงหนึ่งเป้าหมาย
5. ข้อมูล Broker/Identity ที่ยังขาด

ยังไม่ส่ง Patch ใหม่
ยังไม่สั่งเปิด Order
ยังไม่ประกาศ Production-ready

## 16. เอกสารนี้ไม่แทน Source Code

AI ใหม่ต้องอ่าน Source ทั้ง 9 ไฟล์จาก Commit ที่ระบุ
ผ่าน GitHub หรือจากไฟล์ปัจจุบันที่ผู้ใช้ส่งให้

อย่าใช้ Source เก่าที่แนบก่อน Patch เป็นรุ่นล่าสุด
อย่าส่งเฉพาะ .ex5 เพื่อขอแก้โค้ด

โปรเจกต์อื่นใน Repository ไม่อยู่ในขอบเขตนี้
ห้ามรวมกลยุทธ์จากโฟลเดอร์อื่นโดยอัตโนมัติ