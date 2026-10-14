# START PROMPT — รับช่วงโปรเจกต์ Hedge 1.0 MT5

คุณกำลังรับช่วงต่อโปรเจกต์ Hedge 1.0 MT5
ให้ใช้เอกสารและ Source ที่แนบเป็นฐาน ไม่เริ่มออกแบบระบบใหม่

## 1. อ่านข้อมูลก่อนทำงาน

อ่านเอกสารเหล่านี้ก่อน:

1. HANDOFF_Hedge1_Phase4.md
2. BASELINE_MANIFEST_Hedge1.md
3. CONSOLIDATED_TEST_PLAN.md
4. TEST_CHECKLIST_Hedge1.md

จากนั้นอ่าน Source ของโฟลเดอร์ EA_Hegde ให้ครบ
หากเอกสารบางไฟล์ยังไม่ได้แนบ ให้ระบุเฉพาะรายการที่ขาด
ไม่เดาเนื้อหาและไม่ขอไฟล์ที่มีอยู่แล้วซ้ำโดยไม่จำเป็น

Repository:

https://github.com/vhpknn/EA_4_Hegde_Buy_Sell_Both

Branch ที่ตรวจไว้ล่าสุด:

audit/phase-2-3-trailing-restart-strict-basket

Logic Baseline:

9900a1e364b7aac01a8f6e3984ce451f34553259

ชื่อ Commit:

EA_Hegde_Phase 4 complete - final audit fixes

ห้ามเลือก main โดยอัตโนมัติ เพราะในการตรวจครั้งก่อน
main ยังเป็นรุ่นเก่ากว่า Baseline นี้

หากคุณเข้าถึง GitHub ได้ ให้อ่าน Source จาก Commit ที่ระบุ
หากเข้าถึงไม่ได้ ให้ขอ Source ที่จำเป็นจากผู้ใช้
ห้ามอ้างว่าอ่านโค้ดแล้วทั้งที่ยังไม่ได้อ่าน

หาก Working Copy ใหม่กว่าหรือต่างจาก Baseline
ให้ตรวจ Diff และระบุ Source ที่ใช้จริงก่อนทำงาน

## 2. Source ที่อยู่ในขอบเขต

EA_Hegde/Hedge1.0.mq5

EA_Hegde/include/Hedge1_Inputs.mqh
EA_Hegde/include/Hedge1_Utils.mqh
EA_Hegde/include/Hedge1_Capital.mqh
EA_Hegde/include/Hedge1_Session.mqh
EA_Hegde/include/Hedge1_Engine.mqh
EA_Hegde/include/Hedge1_Protect.mqh
EA_Hegde/include/Hedge1_Panel.mqh
EA_Hegde/include/Hedge1_Report.mqh

รวม Source 9 ไฟล์

ห้ามรวมกลยุทธ์จาก EA โฟลเดอร์อื่นใน Repository โดยพลการ
ห้ามเปลี่ยนชื่อ Path ที่สะกด Hegde โดยไม่ตรวจ Include

## 3. สถานะปัจจุบัน

ผู้ใช้รายงานว่า:

- Patch ถึง Phase 4F และสามจุดแก้จาก Final Audit วางแล้ว
- Compile ผ่าน 0 errors / 0 warnings

การตรวจ Source ที่บันทึกไว้:

- ตรวจ Source รวมที่ Commit 393d9a0
- ตรวจ Diff ของสามจุดแก้สุดท้ายที่ Commit 9900a1e
- ตรวจ Hash ของโมดูลประกอบตาม Baseline Manifest

ยังไม่มี:

- ผล Short Test ที่ส่งมาให้ตรวจ
- ผล Long Run ข้ามวันที่ส่งมาให้ตรวจ
- หลักฐานว่า Runtime ครบทุกกรณี
- การอนุมัติใช้เงินจริงหรือ Production-ready
- การรับรองว่าไม่มีบั๊กทั้งหมด

ห้ามแปลง Compile ผ่าน เป็นทดสอบผ่าน

มี Comment-only edits สองจุดที่เคยเสนอหลัง Baseline
แต่ยังไม่ยืนยันว่าผู้ใช้วางแล้วหรือไม่
ให้ตรวจสถานะจริง ไม่เดาว่ามี Logic เปลี่ยนเพิ่ม

## 4. งานที่ต้องทำต่อ

งานปัจจุบันคือเตรียมชุดทดสอบให้ครบก่อนเริ่มรัน

ต้องทำให้ครบ:

1. ยืนยัน Source/Working Diff ที่จะใช้เป็น Baseline ทดสอบ

2. เก็บ Specification ของ Symbol Demo จริง:
   - ชื่อ Symbol รวม Suffix
   - Digits
   - Tick Size
   - Stops Level
   - Volume Min/Max/Step
   - Bid/Ask หรือ Spread สดเมื่อเชื่อมต่อปกติ

3. ยืนยัน Magic สำหรับ Short และ Long
   ที่ยังไม่เคยใช้กับ History/State ของชุดอื่น

4. ทำ Preset .set ที่เหมาะกับข้อจำกัด Broker จริง

5. ทำ Checklist, ผลที่คาดหวัง และหลักฐานที่ต้องเก็บให้ครบ

6. เตรียมขั้นตอนกรณี Failure/Recovery ที่ควบคุมได้
   โดยไม่เปลี่ยน Logic ของ EA เงียบ ๆ เพื่อให้ผลดูผ่าน

7. เมื่อเตรียมครบ จึงรัน:
   - Short Test ครบชุด
   - Long Run ข้ามวัน
   - เก็บหลักฐานและตรวจผลเป็นรอบใหญ่

อย่าเริ่มสั่งให้ผู้ใช้เปิด Order ทีละฟีเจอร์
ก่อนเตรียมชุดทดสอบทั้งหมดเสร็จ

## 5. Workflow ที่ผู้ใช้ยืนยันแล้ว

### ทำงานเป็นขอบเขต Phase

- ทำ Patch ตามขอบเขตที่ตกลงให้ครบทุกไฟล์ก่อน Market Test
- Compile หลังชุด Patch ที่เกี่ยวข้องได้
- ไม่วน Patch → Test → Patch ทีละฟีเจอร์
- ไม่เพิ่มงานนอกขอบเขตกลางรอบ
- ไม่เปลี่ยนกลยุทธ์หรือเพิ่มฟีเจอร์โดยไม่ได้รับคำสั่ง

### ทดสอบแบบรวม

ผู้ใช้ต้องการ:

```text
ทำงานพัฒนาให้ครบ
→ เตรียม Short Test ทั้งชุด
→ รันทดสอบระยะสั้น
→ รันยาวข้ามวัน
→ เก็บหลักฐานรวม
→ ตรวจผลเป็นรอบใหญ่
```

Checklist แบ่งหมวดได้
แต่ไม่ใช่ให้ผู้ใช้หยุดส่งผลและรอคุณหลังทุกข้อ

หากเกิดเหตุผิดปกติร้ายแรง ให้หยุดและเก็บหลักฐาน
ไม่ฝืนรันเพื่อให้ครบเวลา

### Commit และเอกสาร

- ไม่ขอ Commit + Push หลังทุก Patch ย่อย
- รวมเมื่อจบ Phase ใหญ่หรือ Milestone ที่เหมาะสม
- ไม่อัปเดต Ledger/เอกสารทุกครั้งที่มี FIND/REPLACE
- หากต้องส่งต่องานหรือบริบทคลาดเคลื่อน
  ให้ใช้ Commit/Diff/ไฟล์จริงกู้สถานะ

### Step Target

ก่อนสั่ง Compile หรือ Test ทุกครั้ง
ต้องระบุ Step Target ที่ชัดเจนเพียงหนึ่งเป้าหมาย

รักษาขอบเขตนั้นจนจบ
ไม่เพิ่มเป้าหมายใหม่ระหว่างดำเนินการ

### Environment Pause

ถ้าปัญหาเป็น:

- Path หรือ Include
- เปิดไฟล์ผิดโฟลเดอร์
- Source กับไฟล์ที่ Compile คนละชุด
- History หรือไฟล์ขาด
- บัญชี/Symbol ไม่ตรง
- Broker limits ไม่ผ่าน

ให้หยุดแก้ Logic และแก้สภาพแวดล้อมก่อน
ห้ามไล่แก้โค้ดตาม Error จากไฟล์ผิดชุด

## 6. รูปแบบ Patch บังคับ

หากได้รับอนุญาตให้แก้โค้ด ต้องใช้ Jigsaw Patch Rule:

ระบุไฟล์ที่จะแก้ และให้บล็อกเดิมจริงครบตามขอบเขต

FIND:
```text
[โค้ดเดิมจริงที่มีอยู่ใน Source]
```

REPLACE:
```text
[โค้ดใหม่ครบทั้งบล็อกที่จะวางแทน]
```

ห้าม:

- ใช้ Pseudocode แทน FIND
- เดาตำแหน่ง
- ให้ผู้ใช้เดาปีกกาปิด
- วางฟังก์ชันซ้ำ
- ใช้ Source คนละเวอร์ชัน
- ส่ง Patch ที่ยังไม่ตรวจ แล้วเตือนท้ายว่าอาจผิด
- รับประกัน Compile/Runtime ผ่านก่อนมีหลักฐานจริง

หาก FIND ไม่ตรง ให้หาฐาน Source ที่ถูกต้องก่อน
ไม่ส่งโค้ดคล้าย ๆ ให้ผู้ใช้ฝืนวาง

## 7. กติกากลยุทธ์ที่ห้ามเปลี่ยนเอง

### One Basket

- ใช้บัญชี Hedging
- Scope คือ Symbol + Magic ของ EA
- เปิดคู่ใหม่เมื่อ Basket ใน Scope นี้ว่างเท่านั้น
- เปิด Buy 1 + Sell 1 พร้อม Verify Volume
- เปิดคู่ไม่ครบหรือ Volume ไม่ตรง ให้ Rollback
- เมื่อขาหนึ่งปิด อีกขายังให้ Protection จัดการต่อ
- ไม่เปิดขาที่หายกลับมา
- ไม่เพิ่ม Close Whole Basket policy เอง

### Manual ปัจจุบัน

รุ่นนี้เป็น Strict Manual B:

- BUY เดี่ยวถูก Block
- SELL เดี่ยวถูก Block
- HEDGE OPEN ใช้ OpenHedgePair()
- HEDGE OPEN ข้าม Auto Session/Timeout/Spread checks
- แต่ไม่ข้าม Basket-empty, Capital และ Report gates
- คำสั่ง Close และ Protection ยังทำงาน

อย่านำกติกา Manual ของโปรเจกต์เก่ามาปน

### Trailing ปัจจุบัน

มีเฉพาะ Armed Trailing A:

```text
Arm = Cut Loss + Trailing Pullback
```

- เริ่มติดตามหลัง Arm
- เก็บ Best ที่ดีขึ้น
- Restore หลัง Restart
- ปิด Position ฝั่งนั้นเมื่อ Pullback ครบ
- ปิดไม่สำเร็จไม่ลบ Best

ยังไม่มี Trailing From Entry B

### ฟีเจอร์อนาคต

เคยคุยไว้ แต่ไม่ได้ Implement ใน Baseline นี้:

- Manual Override A / Strict B แบบเลือกโหมด
- Trailing From Entry B
- กลยุทธ์ใหม่อื่น ๆ

ห้ามเพิ่มในช่วงทดสอบรุ่นนี้โดยไม่ได้รับคำสั่ง

## 8. ข้อจำกัดที่ต้องรักษาไว้ในแผนทดสอบ

- หนึ่ง Instance ต่อ Symbol + Magic
- ไม่มี Cross-instance Lock
- Namespace มี Account Login แต่ไม่มี Broker Server
- Trailing ผูกกับ Ticket; service-operation Ticket changes
  ยังไม่รองรับครบ
- CSV Completion ตรวจโครงสร้าง/Marker ไม่ใช่ Checksum ทั้งไฟล์
- Broker rules และ Fill จริงต้องยืนยันใน Runtime
- Tester Agent State กับ Terminal State เป็นคนละสภาพแวดล้อม
- Accounting ใช้ Profit + Swap + Commission ของ Symbol + Magic
  ไม่ใช่ทุกค่าธรรมเนียมของทั้งบัญชี
- เคสที่ไม่เกิดหรือไม่มีหลักฐานเป็น NOT_COVERED ไม่ใช่ PASS
- Preset ระยะสั้นยังเป็น Draft จนกว่าจะมี Specification จริง

## 9. การใช้ Source และหลักฐานอย่างประหยัดเวลา

- อ่าน Source ฐานครบครั้งแรก
- จากนั้นใช้ Commit + Diff + Patch ที่ยืนยันแล้ว
- ไม่ขอ Source ทั้งโปรเจกต์ซ้ำทุกครั้ง
- ไม่ตรวจ GitHub ซ้ำเมื่อไม่มีเหตุให้สถานะเปลี่ยน
- หากมีความคลาดเคลื่อน ขอเฉพาะส่วนที่จำเป็น
- AI เป็นผู้ช่วยอ่าน Log/CSV และเติมผล Checklist
  ไม่ให้ผู้ใช้ต้องตรวจทุกช่องเอง
- หากผลทดสอบต้องแก้ ให้รวมเป็นชุดแก้
  ไม่ Patch ระหว่างรันแล้วอ้างว่าผลหลายเวอร์ชันเป็นชุดเดียวกัน

## 10. รูปแบบคำตอบแรกของคุณ

หลังอ่านข้อมูล ให้ตอบเฉพาะ:

1. คุณอ่าน Source จาก Commit/ไฟล์ใดจริง
2. Baseline และ Working Diff ที่ตรวจพบ
3. สถานะ Compile แยกจาก Runtime
4. Step Target ของงานเตรียมทดสอบถัดไปหนึ่งเป้าหมาย
5. ข้อมูลจำเป็นที่ยังขาด โดยไม่ขอสิ่งที่มีแล้วซ้ำ

ยังไม่ส่ง Patch ใหม่
ยังไม่สั่งเปิด Order
ยังไม่เริ่มทดสอบทีละฟีเจอร์
ยังไม่ประกาศว่า Production-ready

หากยังอ่าน Source ไม่ได้ ให้บอกอย่างตรงไปตรงมา
และระบุวิธีรับ Source ที่จำเป็นก่อนทำงานต่อ