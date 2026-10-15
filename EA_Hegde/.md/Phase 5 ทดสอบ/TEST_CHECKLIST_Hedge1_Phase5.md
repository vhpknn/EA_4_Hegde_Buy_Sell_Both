# TEST CHECKLIST — Hedge 1.0 MT5 / Source 1a3b38f

วันที่จัดทำ: 14 ตุลาคม 2026

ใช้ร่วมกับ:

- HANDOFF_Hedge1_Phase4.md
- BASELINE_MANIFEST_Hedge1.md
- START_PROMPT_NEXT_AI.md
- CONSOLIDATED_TEST_PLAN.md

## 1. Baseline และสถานะ

Test Source สำหรับชุดนี้:

```text
1a3b38f04b991c70fa86195d7d01360955ec4ccd
```

Logic Baseline เดิม (อ้างอิงย้อนหลัง): `9900a1e364b7aac01a8f6e3984ce451f34553259`
ชุดปัจจุบันรวม Logic fixes ที่ commit 1a3b38f ไม่ใช่ Comment-only update.

ผู้ใช้รายงาน Compile ผ่าน:

```text
0 errors
0 warnings
```

สถานะการทดสอบ:

```text
Short Test: ยังไม่มีผลส่งมาให้ตรวจ
Long Run: ยังไม่มีผลส่งมาให้ตรวจ
```

รายการในเอกสารนี้:

- Short Test: 26 กรณี
- Long Run: 8 กรณี
- รวม: 34 กรณี

สถานะเริ่มต้นทุกกรณีคือ NOT_RUN

ห้ามตีความว่ารายการที่จัดเตรียมแล้ว
เป็นรายการที่รันหรือผ่านแล้ว

## 2. กติกาการใช้ Checklist

1. เตรียม Preset, ขั้นตอน, ผลที่คาดหวัง และหลักฐาน
   ให้ครบก่อนเริ่มชุดทดสอบ

2. ใช้ Source เวอร์ชันที่ล็อกไว้

3. เปลี่ยน Inputs ตามกรณีที่เตรียมไว้ได้
   แต่ไม่เปลี่ยน Logic เงียบ ๆ ระหว่างรัน

4. ไม่ให้ผู้ใช้หยุดส่งผลและรอ AI หลังทุกข้อ

5. เก็บหลักฐานเป็นชุด Short และ Long
   แล้วตรวจผลเป็นรอบใหญ่

6. AI ผู้ตรวจเป็นผู้ช่วยอ่านหลักฐานและเติมผล
   ผู้ใช้ไม่ต้องเปิด CSV ไล่ตรวจทุกช่องเอง

7. หากเกิดเหตุผิดปกติร้ายแรง
   ให้หยุดและเก็บหลักฐาน ไม่ฝืนรันเพื่อให้ครบเวลา

8. กรณีที่ไม่เกิดหรือไม่มีหลักฐาน
   ต้องไม่เป็น PASS

9. ถ้าปัญหาเกิดจาก Path, ไฟล์, History, Account
   หรือ Broker limits ให้แก้สภาพแวดล้อมก่อน Logic

## 3. ป้ายสถานะ

### NOT_RUN

สถานะเริ่มต้น ยังไม่มีผลการรันสำหรับกรณีนั้น

### PASS

มีหลักฐานว่าผลตรงเกณฑ์
ใน Source/Inputs/Environment ที่ระบุ

### FAIL

มีหลักฐานว่าผลไม่ตรงเกณฑ์

### NOT_COVERED

เหตุไม่เกิด ยังไม่ได้ดำเนินการครบ
หรือหลักฐานไม่เพียงพอ

### ENVIRONMENT_BLOCKED

ดำเนินต่อไม่ได้เพราะสภาพแวดล้อม
เช่น ไฟล์ผิดชุด, History ขาด, Account/Symbol ไม่ตรง
หรือ Broker constraints ไม่ผ่าน

เมื่อปิดรอบรายงานผล
กรณีที่ยังไม่มีผลต้องอธิบายเหตุ
ไม่เปลี่ยน NOT_RUN เป็น PASS โดยอัตโนมัติ

## 4. Preflight — ไม่ใช่ผล Runtime

ตรวจความพร้อมก่อนเริ่มทั้งชุด:

- [ ] Source ที่ใช้ตรง Baseline หรือมี Diff ที่ตรวจแล้ว
- [ ] Compile เป็น Source ชุดที่จะรันจริง
- [ ] Account เป็น Demo Hedging
- [ ] Symbol รวม Suffix ถูกต้อง
- [ ] Specification ของ Broker ถูกบันทึก
- [ ] หน่วย InpPointDigits ยืนยันแล้ว
- [ ] Volume และระยะ Protection ผ่านการตรวจตาม Specification
- [ ] Magic สำหรับทดสอบยืนยันว่าไม่ปนชุดอื่น
- [ ] หนึ่ง Instance ต่อ Symbol + Magic
- [ ] Preset สำหรับทุกกรณีจัดเตรียมครบ
- [ ] History สำหรับ Tester พร้อม
- [ ] วิธีเก็บ Experts/Journal/CSV/ภาพจัดเตรียมแล้ว
- [ ] Fault Fixture มีขอบเขตและวิธีคืนสภาพ
- [ ] ข้อจำกัดของรุ่นนี้อยู่ในแผน
- [ ] ยังไม่ใช้เงินจริง

การตรวจ Preflight ผ่าน
ไม่ใช่หลักฐานว่า S01–S26 หรือ L01–L08 ผ่าน

## 5. Short Test — กลุ่ม Inputs และ Entry

| ID | กรณี | สภาพแวดล้อม | ผลที่คาดหวัง | หลักฐานหลัก | สถานะ |
|---|---|---|---|---|---|
| S01 | Invalid Inputs | Tester / Demo เมื่อ Basket ว่าง | ค่าที่ไม่รองรับ เช่น BE Step=0 ในโหมดเลื่อนตาม หรือ Pullback=0 เมื่อเปิด Trailing ถูกปฏิเสธก่อนเปิด Order | Inputs และ Journal/Experts | NOT_RUN |
| S02 | Hedge Entry | Tester / Demo | เปิด Buy 1 + Sell 1, Volume ทั้งสองฝั่งเท่ากันและตรง Effective Lot, มี SL ทั้งสองไม้, CYCLE START เกิดก่อนส่ง Order | Inputs, Trade, Experts | NOT_RUN |
| S03 | Duplicate Hedge | Demo | กด HEDGE ขณะ Basket ค้างแล้วไม่มีคู่ใหม่ และฐาน Cycle ไม่ถูกรีเซ็ต | Trade, Experts, State ก่อน/หลัง | NOT_RUN |
| S04 | Locked BUY / SELL | Demo | กด BUY LOCKED และ SELL LOCKED แล้วไม่มี Order ใหม่ มี Log BLOCKED | Experts และ Trade | NOT_RUN |
| S05 | Close Buttons | Demo | CLOSE BUY / CLOSE SELL / CLOSE ALL ทำงานตามขอบเขต Symbol + Magic และผล Broker ที่ตรวจได้ | Trade, History, Experts | NOT_RUN |

### หมายเหตุการตรวจ Entry

- ตรวจขอบเขต Symbol + Magic ของ EA ไม่ใช่ทั้งบัญชี
- ตรวจ Volume ที่เกิดจริง ไม่ดูเพียงค่าที่กรอกใน Inputs
- แยกการเปิดคู่ที่ยังอยู่ระหว่าง Verify/Rollback
  ออกจากการเริ่ม Basket ใหม่ซ้อนกับ Basket เดิม
- หาก Position ปิดก่อนถ่ายภาพ ให้ใช้ Log/History ประกอบ
- Invalid Stops หรือ Invalid Volume ต้องตรวจ Specification/Inputs
  ก่อนสรุปว่าเป็นบั๊ก Logic

## 6. Short Test — กลุ่ม Protection

| ID | กรณี | สภาพแวดล้อม | ผลที่คาดหวัง | หลักฐานหลัก | สถานะ |
|---|---|---|---|---|---|
| S06 | Cut Loss | Tester / Demo | Position ปิดตาม SL; EA ไม่เปิดขาที่หายกลับมา; ขาที่เหลือยังอยู่ภายใต้ Protection | History, Experts, Position snapshots | NOT_RUN |
| S07 | BE Fixed | Tester / Demo | เมื่อถึง Trigger ล็อกตามสัดส่วนของ Trigger; ไม่เลื่อนตามราคาต่อแบบ BE Trailing; ไม่คลาย SL ย้อนกลับ | Inputs, SL ก่อน/หลัง, Experts | NOT_RUN |
| S08 | BE Trailing | Tester / Demo | เมื่อถึง Trigger และผ่าน Step เลื่อน SL เฉพาะทิศที่ดีขึ้น; ย่อต่ำกว่า Trigger แล้ว Cut Loss ไม่คลาย SL กลับ | Inputs, SL หลายจุด, Experts | NOT_RUN |
| S09 | Missing SL | Demo Fixture ที่เตรียมไว้ | เมื่อ SL หาย ระบบพยายามติดตั้งได้ รวมถึงกรณีกำไรเลย BE Trigger; ตรวจ Buy และ Sell ตามขอบเขตกรณี | Position/SL, Inputs, Experts | NOT_RUN |
| S10 | Armed Trailing | Tester / Demo | ก่อน Arm ไม่เริ่ม Track; หลัง Arm Best เพิ่มเฉพาะค่าที่ดีขึ้น; เมื่อ Pullback ครบพยายามปิดตามกติกา | Inputs, ARMED/CLOSE logs, History | NOT_RUN |
| S11 | RR | Tester | ในกรณีแยก RR ระบบคำนวณเป้าจาก BE Trigger × RR Percent และปิดด้วยเหตุ RR | Inputs, Experts, History | NOT_RUN |

### หมายเหตุ Protection

สำหรับ S10 ให้ใช้กรณีที่ RR ไม่แย่งปิดก่อน
เช่น RR=0 ตามโปรไฟล์ที่เตรียมไว้

สำหรับ S11 ให้แยก RR จาก Trailing
ตามโปรไฟล์ที่เตรียมไว้

- ราคา Trigger ไม่ใช่ราคาที่รับประกันว่า Fill จะตรงทุกครั้ง
- ตรวจผลคำสั่ง Broker และราคาปิดจริงประกอบ
- ไม่สรุปว่า Trailing เสียเมื่อ RR ปิดก่อน
- กรณี S09 ต้องมีหลักฐานของเงื่อนไขที่ต้องการตรวจจริง
- ถ้าใช้ Fixture ให้ระบุว่าเป็น Fixture
  ไม่อ้างว่าเกิดจากราคาตลาดโดยธรรมชาติ
- ถ้าไม่มีหลักฐานว่ากำไรเลย Trigger
  ห้ามอ้างว่าครอบคลุม Missing SL หลัง Trigger แล้ว

## 7. Short Test — กลุ่ม State และ Capital

| ID | กรณี | สภาพแวดล้อม | ผลที่คาดหวัง | หลักฐานหลัก | สถานะ |
|---|---|---|---|---|---|
| S12 | Restart / Restore | Demo | Restart โดยคง Identity/หน่วย/ระยะที่เกี่ยวข้องแล้ว Restore Best และ Cycle เดิม ไม่เริ่มนับใหม่ผิดจังหวะ | Inputs ก่อน/หลัง, State, Experts, Ticket | NOT_RUN |
| S13 | Cleanup หลัง EA ไม่ได้ทำงาน | Demo Fixture | State ของ Position ที่ปิดไปถูกลบเฉพาะเมื่อยืนยันประวัติได้; ไม่แตะ State อื่น; กรณียืนยันไม่ได้ต้องไม่เดาลบ | State ก่อน/หลัง, History, Experts | NOT_RUN |
| S14 | Capital Gate | Tester / Demo Fixture | ทุน 0/ติดลบ Block Auto และ HEDGE; ข้อมูลทุนอ่านไม่ได้ Block ด้วยเหตุเหมาะสม; Protection/Close ของไม้ค้างไม่ถูก Capital Gate หยุด | Inputs, State, Trade, Experts | NOT_RUN |
| S15 | REFILL | Demo | Save สำเร็จจึงแสดง REFILL SAVED; ยอดคงอยู่หลัง Restart; Save ล้มเหลวไม่แสดงว่าสำเร็จ | State, Inputs, Experts, Panel | NOT_RUN |
| S16 | Auto-Lot / Volume | Tester / Demo Fixture | สูตรบันไดและเพดานถูกต้อง; Volume หลัง Normalize ตรงกติกา; Lot ที่ไม่รองรับไม่ถูกส่งเปิดคู่ | Specification, Inputs, Panel, Trade, Experts | NOT_RUN |

### หมายเหตุ State และ Capital

- แยก Terminal State ออกจาก Tester Agent State
- ห้ามเปลี่ยน Account/Symbol/Magic/Point Digits
  แล้วอ้างว่าเป็นการ Restore Identity เดิม
- อย่าลบ State ของชุดอื่นเพื่อเตรียม Fixture
- การอ่านประวัติสำเร็จแต่ยอดเป็น 0
  ต้องแยกจากการอ่านประวัติไม่สำเร็จ
- REFILL Save สำเร็จไม่ได้แปลว่าข้อมูลทุนส่วนอื่นอ่านสำเร็จเสมอ
- การที่ Lot เปิดไม่ได้เพราะ Broker minimum/step/cap
  ต้องแยกจากความผิดพลาดของสูตรที่ตกลงไว้
- กรณีที่ไม่เกิดต้องระบุข้อจำกัดของความครอบคลุม

## 8. Short Test — กลุ่ม Auto Gates และ Cycle

| ID | กรณี | สภาพแวดล้อม | ผลที่คาดหวัง | หลักฐานหลัก | สถานะ |
|---|---|---|---|---|---|
| S17 | Timeout | Tester / Demo | Basket ว่างแล้วไม่เปิดก่อนครบเวลา; เมื่อผ่านเวลาและ Gate อื่นจึงเปิดได้; มีขาค้างไม่เริ่มคู่ใหม่ | Inputs, Timestamped Experts, History | NOT_RUN |
| S18 | Spread Gate | Tester / Demo Fixture | Auto ถูก Block เมื่อไม่ผ่านและอนุญาตเมื่อผ่านตาม Inputs; ไม่ใช้ Manual HEDGE มาอ้างว่าผ่าน Auto Spread Gate | Inputs, Spread/Bid/Ask, Experts | NOT_RUN |
| S19 | Session | Tester | Block/Open ถูกต้องตามเวลา Server; Session เวลาผิดไม่ข้ามช่วงถัดไปที่ถูกต้อง; Protection ไม่หยุดตาม Auto Session Gate | Inputs, Server timestamps, Experts, History | NOT_RUN |
| S20 | Cycle Baseline | Tester / Demo | ฐานบันทึกก่อน Order แรก; ปิดแล้วเปิดรอบใหม่โดยไม่พึ่ง Panel เห็นช่วงว่าง; Commission ฝั่งเปิดไม่ถูกตัดออกจากฐานโดยผิดจังหวะ | CYCLE START log, RNET/CSTART, History, Panel | NOT_RUN |

### หมายเหตุ Auto และ Cycle

- Manual HEDGE ข้าม Auto Session/Timeout/Spread checks
  แต่ไม่ข้าม Basket-empty, Capital หรือ Report gates
- หลังขาหนึ่งปิด การเหลือขาเดียวไม่ใช่บั๊กโดยตัวมันเอง
- ต้องตรวจการเปิดรอบใหม่ ไม่ใช่เพียงจำนวน Position ปลายทาง
- Panel ต้องไม่เป็นผู้สร้างหรือรีเซ็ตฐาน Cycle
- Cycle Loss แสดงเฉพาะผลขาดทุนที่บันทึกเป็นดีลแล้ว
  ไม่รวมกำไรลอยตัว
- ถ้าไม่มีฐาน Cycle ที่เชื่อถือได้ การแสดง N/A
  ไม่ใช่ผลขาดทุนเป็น 0

## 9. Short Test — กลุ่ม Report และ Failure

| ID | กรณี | สภาพแวดล้อม | ผลที่คาดหวัง | หลักฐานหลัก | สถานะ |
|---|---|---|---|---|---|
| S21 | CSV Generation | Tester | เมื่อครบ Report period และ Basket ว่าง มี Header/Daily/TOTAL/REPORT_COMPLETE; ช่วง [Start,End) ไม่ทับกัน; ยอดเทียบประวัติได้ตามนิยาม EA | CSV, Inputs, Journal, History | NOT_RUN |
| S22 | Report Recovery | Demo Fixture | ไฟล์รอบเดิมที่สมบูรณ์และ RPD ค้างถูก Recover; ใช้ End เดิม; ไม่สร้างรายงานรอบเดิมใหม่โดยไม่จำเป็น | CSV, RPD, Experts, Restart evidence | NOT_RUN |
| S23 | Report Failure | Demo Fault Fixture | การเขียน/ตรวจ Completion ที่ล้มเหลวไม่ปลด Report Gate; ไฟล์ปลายทางผิดรูปแบบไม่ถูกเขียนทับ; Protection ยังทำงาน | CSV/Temp, State, Experts, Trade | NOT_RUN |
| S24 | Open Failure / Rollback | Demo Fault Fixture | เปิดคู่ไม่ครบหรือ Volume ไม่ตรงแล้ว Verify/Rollback; ตรวจ Position จริงหลังรอบสุดท้าย; ไม่มี Log CRITICAL ผิดเมื่อ Basket ว่าง | Broker retcodes, Experts, Trade, History | NOT_RUN |
| S25 | Close / Modify Rejection | Demo Fault Fixture | ปิดไม่สำเร็จแล้ว Best ไม่หาย; Modify ไม่สำเร็จไม่ถูกอ้างว่าสำเร็จ; ตรวจการทำงานต่อจาก State เดิมตามกรณี | Retcodes, State ก่อน/หลัง, SL/Trade, Experts | NOT_RUN |
| S26 | Legacy Import | Demo Fixture | นำเข้าเฉพาะ State ที่ยืนยันเจ้าของตามเงื่อนไข; Key ใหม่ไม่ถูกเขียนทับด้วยข้อมูลเก่า; General import ทำเมื่อ Basket ว่าง; ปิดโหมดนำเข้าหลังใช้ | Inputs, State ก่อน/หลัง, Migration logs | NOT_RUN |

### หมายเหตุ Report

- REPORT_COMPLETE เป็น Metadata ไม่ใช่แถวกำไร
- ไม่รวม Metadata หรือ TOTAL ซ้ำเข้าไปในยอดรวมแถววันที่
- ClosedTrades นับดีลปิด ไม่ใช่จำนวน Position ที่ไม่ซ้ำ
- ยอดสุทธิใช้ Profit + Swap + Commission ของ Symbol + Magic
- ต้องกำหนดวิธีเทียบและ Precision ของตัวเลขก่อนตัดสินผล
- ไม่ถือว่า FileOpen ผ่านเป็นหลักฐานว่า FileWrite ผ่าน
- FileOpen ล้มเหลวไม่เท่ากับทดสอบ Partial FileWrite แล้ว
- Completion Marker ไม่ใช่ Checksum ทั้งไฟล์
- กรณีไม่เกิดต้องเป็น NOT_COVERED

### หมายเหตุ Failure

ต้องบันทึกว่าเหตุเกิดจาก:

- Broker rejection จริง
- Fixture ที่เตรียมไว้
- สภาพแวดล้อมที่ผิด
- หรือเหตุที่ยังไม่พิสูจน์

ไม่แก้ Logic ของ EA เงียบ ๆ เพื่อทำให้ Failure เกิด
แล้วนำผลไปอ้างว่าเป็น Baseline เดิม

Fixture ต้องมีวิธีคืนสภาพ
และใช้เฉพาะ Demo/ไฟล์/State ของชุดทดสอบ

## 10. Long Run — 8 กรณี

| ID | กรณี | ผลที่คาดหวัง | หลักฐานหลัก | สถานะ |
|---|---|---|---|---|
| L01 | Multiple Rounds | มีหลายรอบ Basket ตาม Gate โดยไม่มีคู่ใหม่ซ้อนกับ Basket เดิมหรือเปิดขาที่หายกลับมา | Experts, History, Preset | NOT_RUN |
| L02 | Session Boundaries | ครอบคลุม Block/Open ตามเวลา Server; Entry ถูกกั้นตามกติกาและ Protection ไม่หยุด | Inputs, Server timestamps, Experts | NOT_RUN |
| L03 | Observed Protection Events | Cut/BE/Trailing/RR ที่เกิดจริงตรงกับกติกา; เหตุไม่เกิดไม่ถูกนับว่าผ่าน | Experts, History, SL snapshots | NOT_RUN |
| L04 | State / Restart | State คงอยู่และ Restore ถูกต้องในขอบเขตที่รองรับ; บันทึกเหตุ Ticket เปลี่ยนเป็นข้อจำกัด ไม่อ้างว่าครอบคลุมแล้ว | State, Ticket, Inputs, Experts | NOT_RUN |
| L05 | Accounting | Virtual Equity/Cycle/Closed Net เทียบกับ Profit+Swap+Commission ของ Symbol+Magic ได้ตามนิยามและช่วงที่ระบุ | History, CSV, State, Panel | NOT_RUN |
| L06 | Report Maturity | ครบเวลา Server/Tick ตาม ReportDays และมีช่วง Basket ว่างจนสร้าง Report จริง; ไม่ถือว่าข้ามเที่ยงคืนอย่างเดียวเพียงพอ | RPD, CSV, Experts, Inputs | NOT_RUN |
| L07 | Connection Events | เมื่อเกิดการหลุด/กลับมาจริง มีเวลาและผลกระทบชัดเจน; ไม่อ้างว่า Client-side Protection ทำงานระหว่างไม่มี Tick จากหลักฐานที่ไม่มี | Journal, Experts, Timeline | NOT_RUN |
| L08 | Run Health | ตรวจ Log ซ้ำ, Position/ไฟล์ค้าง, ความผิดปกติและความครอบคลุมจริง ไม่ตัดสินจากเวลารันอย่างเดียว | Logs, File inventory, History | NOT_RUN |

### หมายเหตุ Long Run

- ใช้ Demo และ Source ที่ล็อกไว้
- ไม่เพิ่มฟีเจอร์หรือเปลี่ยน Logic ระหว่างรัน
- ใช้หนึ่ง Instance ต่อ Symbol + Magic
- รันประมาณ 24–48 ชั่วโมงตามแผนและสภาพข้อมูล
- เวลาเปิดโปรแกรมไว้ไม่ใช่เกณฑ์ผ่านเพียงอย่างเดียว
- ต้องมี Tick/Session/Report/รอบ Basket ตามกรณีที่ต้องตรวจ
- หาก Spread Gate ทำให้ไม่มี Order
  อาจเป็นการทำงานตามกติกา แต่ไม่พิสูจน์ Protection ที่ไม่เกิด
- ไม่เพิ่ม Spread limit เพียงเพื่อผลิตผลให้ดูว่าครบ
- หากเกิดความผิดปกติร้ายแรง ให้หยุดและเก็บหลักฐาน

## 11. Template บันทึกผลรายกรณี

AI ผู้ตรวจใช้ Template นี้หลังอ่านหลักฐานรวม
ผู้ใช้ไม่จำเป็นต้องกรอกทุกช่องเองระหว่างรัน

```text
Case ID:
ชื่อกรณี:

Source SHA:
Working Diff ที่เกี่ยวข้อง:
Preset / Inputs:
Environment:
Account mode:
Symbol:
ช่วงเวลา / Time basis:

ผลที่คาดหวัง:
เหตุการณ์ที่เกิดจริง:

หลักฐาน:
- Experts / Journal:
- Trade / History / Panel:
- State:
- CSV:

Result:
PASS / FAIL / NOT_COVERED / ENVIRONMENT_BLOCKED

เหตุผล:
ข้อจำกัดของหลักฐาน:
ข้อแก้ที่จำเป็น ถ้ามี:
ขอบเขต Retest ถ้ามี:
```

## 12. ข้อมูลประกอบชุดทดสอบ

ให้เก็บร่วมกับหลักฐาน:

```text
Baseline Source:
Compile result:
Actual loaded Presets:
Actual Symbol specification:
Short/Long Magic identities:
Tester settings and date range:
Demo run start/end:
Known interruptions:
Uncommitted changes:
```

แยกหลักฐานตามที่มา:

```text
SHORT / TESTER
SHORT / DEMO
LONG / DEMO
```

เป็นป้ายกำกับการจัดหลักฐาน
ไม่ใช่ Absolute Path ที่บังคับใช้บนเครื่องผู้ใช้

## 13. สรุปผล Short Test

| ประเภท | จำนวน |
|---|---:|
| PASS | รอผล |
| FAIL | รอผล |
| NOT_COVERED | รอผล |
| ENVIRONMENT_BLOCKED | รอผล |
| NOT_RUN | 26 |

ข้อความสรุป:

```text
ยังไม่มีหลักฐาน Runtime ส่งมาให้ตรวจ
ยังไม่สรุปว่า Short Test ผ่าน
```

## 14. สรุปผล Long Run

| ประเภท | จำนวน |
|---|---:|
| PASS | รอผล |
| FAIL | รอผล |
| NOT_COVERED | รอผล |
| ENVIRONMENT_BLOCKED | รอผล |
| NOT_RUN | 8 |

ข้อความสรุป:

```text
ยังไม่มีหลักฐาน Runtime ส่งมาให้ตรวจ
ยังไม่สรุปว่า Long Run ผ่าน
```

## 15. เกณฑ์ปิดรอบตรวจผล

ก่อนสรุปผล ต้องตรวจ:

- หลักฐานมาจาก Source เวอร์ชันที่ระบุ
- Inputs/Preset ที่ใช้จริงมีบันทึก
- Environment ตรงกับกรณี
- ไม่มีการรวมผลหลายเวอร์ชันโดยไม่แยก
- PASS มีหลักฐานเพียงพอ
- FAIL มีเหตุและขอบเขตชัดเจน
- NOT_COVERED ไม่ถูกซ่อน
- ENVIRONMENT_BLOCKED ไม่ถูกแก้ด้วย Logic โดยพลการ
- ข้อจำกัดของ Baseline อยู่ในรายงาน
- หากต้องแก้ มีชุดแก้และขอบเขต Retest

## 16. ข้อจำกัดที่ต้องรักษาไว้

- ยังไม่มี Cross-instance Lock
- Namespace ยังไม่รวม Broker Server
- Trailing แบบ Ticket-based ยังไม่รองรับ Ticket-change service operations ครบ
- CSV Completion ไม่ใช่ Checksum ทั้งไฟล์
- Accounting ไม่ใช่ทุกค่าธรรมเนียมของทั้งบัญชี
- Source/Binary equivalence ไม่ได้ตรวจโดยอิสระ
- Compile ผ่านไม่แทนผล Runtime
- ยังไม่มี Production approval

ไม่ขยายขอบเขตกลยุทธ์เพื่อแก้ข้อจำกัดเหล่านี้
โดยไม่ได้รับคำสั่งใหม่

## 17. งานถัดไปก่อนเริ่มรัน

ยังต้องเตรียม:

1. Specification / Spread ของ Symbol Demo จริง
2. Magic สำหรับ Short/Long ที่ยืนยันว่าไม่ปนชุดอื่น
3. Preset .set ที่ตรวจข้อจำกัดแล้ว
4. ลำดับกรณีทั้งชุด
5. Fault Fixture และวิธีคืนสภาพ
6. วิธีเก็บหลักฐาน

เมื่อเตรียมครบ:

```text
Short Test ทั้งชุด
→ Long Run ข้ามวัน
→ ส่งหลักฐานรวม
→ AI ตรวจและเติม Checklist เป็นรอบใหญ่
```

ไม่กลับไปทดสอบหลังทุก Patch
และไม่ให้ผู้ใช้รอคำตอบหลังทุกฟีเจอร์
## 18. รายละเอียดเพิ่มสำหรับ Patch ปิด Phase 4 ที่ 1a3b38f

ขั้นนี้เป็นการปรับ Checklist เท่านั้น ไม่ใช่การรันหรือผล PASS
คงกรณีหลัก Short 26 กรณี และ Long 8 กรณีเดิม รายการย่อยทั้งหมดเริ่ม NOT_RUN
Specification / Spread / Magic เลื่อนไปยืนยันครั้งเดียวก่อนสร้าง .set ฉบับพร้อมรันและ Preflight
ยังไม่เปิด Order ไม่แก้ Logic และไม่ Commit หลังขั้นเตรียมย่อยนี้

### S09 — Missing SL และ BE เมื่อ SL เป็น 0

| รายการย่อย | เงื่อนไข | ผลที่คาดหวัง | หลักฐาน | สถานะ |
|---|---|---|---|---|
| S09-A | BUY ไม่มี SL ก่อน Trigger | พยายามติดตั้ง Cut Loss SL; ตรวจผล Broker จริง | Inputs, ราคาเข้า/Bid/Ask/SL, Experts | NOT_RUN |
| S09-B | SELL ไม่มี SL ก่อน Trigger | พยายามติดตั้ง Cut Loss SL; ตรวจผล Broker จริง | Inputs, ราคาเข้า/Bid/Ask/SL, Experts | NOT_RUN |
| S09-C | BUY ไม่มี SL หลังถึง Trigger และเปิด BE | พยายามติดตั้ง SL ตามลำดับ Cut Loss → BE หากไม่มีเหตุปิดแทรก | Inputs, ราคาตามเวลา, SL, retcodes | NOT_RUN |
| S09-D | SELL ไม่มี SL หลังถึง Trigger และเปิด BE | พยายามติดตั้ง SL ตามลำดับ Cut Loss → BE หากไม่มีเหตุปิดแทรก | Inputs, ราคาตามเวลา, SL, retcodes | NOT_RUN |
| S09-E | SELL ไม่มี SL หลัง Trigger; Cut Loss Modify ถูกปฏิเสธก่อนหน้าและ SL ยังเป็น 0 | ขั้น BE ยังพยายามส่ง Modify ไม่ถูกข้ามเพราะเปรียบเทียบ newSL กับ 0 | CUTLOSS-SL rejection ตามด้วย BREAK-EVEN request/result, Ticket เดียวกัน | NOT_RUN |

กรณี S09-E เป็น Fault path วิธีทำให้เกิดยังไม่รับรอง ห้ามใช้ S09-D ที่ Cut Loss สำเร็จแทนหลักฐาน S09-E
หลีกเลี่ยง RR/Trailing ที่ปิดก่อนถึงขั้น BE ด้วยโปรไฟล์ที่เตรียมไว้ ไม่เปลี่ยน Source
ทดสอบทั้ง BE_FIXED และ BE_TRAILING ตามความครอบคลุมที่บันทึก
หากพิสูจน์เพียงคำสั่งถูกส่ง แต่ Broker ปฏิเสธ ต้องแยกจากการติดตั้งสำเร็จ

### S13 — Cleanup ต้องยืนยันก่อนลบ State

| รายการย่อย | เงื่อนไข | ผลที่คาดหวัง | หลักฐาน | สถานะ |
|---|---|---|---|---|
| S13-A | Position ยังเปิด | ไม่ลบ Trail State | Ticket/Identifier และ State ก่อน/หลัง | NOT_RUN |
| S13-B | Position ปิดครบและอ่านประวัติยืนยันได้ | ลบ State ใน Scope ตาม Cleanup | History/State ก่อนหลัง/Experts | NOT_RUN |
| S13-C | Ticket ไม่มีประวัติให้ยืนยัน | เก็บ State ไม่เดาว่าปิดครบ | Fixture inventory, State ก่อน/หลัง | NOT_RUN |
| S13-D | เกิดการอ่าน Position Identifier หรือ History Property ล้มเหลวจริง | ไม่ยืนยันว่าปิดครบ ไม่ลบ State | หลักฐาน API failure ที่ระบุได้และ State ก่อน/หลัง | NOT_RUN |

S13-C ไม่ใช่หลักฐานทดแทน S13-D การตัดการเชื่อมต่อแล้ว Cleanup ไม่ทำงานก็ไม่พิสูจน์ Property read failure
หากสร้าง S13-D บน Baseline เดิมไม่ได้ ให้รายงาน NOT_COVERED; ไม่เติม fault injection ใน Source แล้วอ้างว่าเป็นเวอร์ชันเดิม

### S21 / S23 — Report Gate ก่อน Manual HEDGE

เพิ่มการตรวจบน Demo นอกเหนือจาก S21 ใน Tester เดิม

| รายการย่อย | เงื่อนไข | ผลที่คาดหวัง | หลักฐาน | สถานะ |
|---|---|---|---|---|
| S21-M | Basket ว่าง รายงานถึงกำหนดและจัดการได้ ก่อน Manual เปิดคู่ | Report และบันทึก RPD สำเร็จก่อนส่ง Order แรก; จากนั้นเปิดได้หาก Gate อื่นผ่าน | RPD, CSV, Timeline Experts/History | NOT_RUN |
| S23-M | Basket ว่าง รายงานถึงกำหนด แต่ไฟล์ปลายทางผิดรูปแบบหรือ Report ล้มเหลว | Manual HEDGE ไม่เปิดคู่ขณะ Report ค้าง | CSV/State, WAIT_REPORT log, Trade/History | NOT_RUN |
| S23-S | สภาพที่ค่าธง Gate เก่ายังไม่รีเฟรช แต่รอบรายงานถึงกำหนดก่อนกด Manual | Manual ตรวจ Report ใหม่ก่อน OpenHedgePair; ไม่ใช้ค่าธงเก่าเปิดก่อนรายงาน | Timeline ที่พิสูจน์ลำดับ Tick/Event, RPD/CSV, Order history | NOT_RUN |

S23-S ยังต้องออกแบบ Fixture และหลักฐาน ห้ามนำการกดตอนธง WAIT_REPORT เป็น true อยู่แล้วมาสรุปว่าครอบคลุม stale-gate path
Manual ยังคงข้าม Auto Session/Timeout/Spread และไม่ข้าม Basket-empty/Capital/Report
เหตุผิดปกติที่สร้างเพื่อ Fixture ต้องจำกัดอยู่ในบัญชี Demo และ Scope ทดสอบเท่านั้น

### กติกาสรุปความครอบคลุม

รายกรณีหลักต้องระบุผลรายการย่อยที่จำเป็นด้วย ถ้าผ่านบางเส้นทางแต่ไม่มีหลักฐานเส้นทาง Fault
ให้บันทึกว่า normal path ผ่านและ fault path NOT_COVERED ห้ามสรุปว่าทั้งกรณีผ่านครบ
ใช้ Result ตามหลักฐาน ไม่บังคับให้ทุกกรณีเป็น PASS เพื่อให้แผนดูครบ

### จุดจบขั้นเตรียมแรก

- Source reference อัปเดตเป็น 1a3b38f
- รายละเอียดเพิ่มครอบคลุม Patch ทั้งสามจุด
- คงจำนวนกรณีหลักเดิม
- ไม่มีผล Runtime; ทุกกรณียังคง NOT_RUN
- งานถัดไป: จัดลำดับรันและ Profile Inputs ทั้งชุด โดยยังไม่กำหนดค่าที่ต้องอาศัย Broker
