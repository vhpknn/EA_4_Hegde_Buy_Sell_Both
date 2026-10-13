# HANDOFF — EA Hedge 1.0 (MT5)

## 1. ภาพรวมโปรเจกต์

โปรเจกต์: EA Hedge 1.0  
แพลตฟอร์ม: MetaTrader 5 (MT5)  
ประเภทบัญชีที่ต้องใช้: Hedging Account เท่านั้น  
กลยุทธ์หลัก: เปิด Hedge 1 Basket โดยเปิด Buy + Sell พร้อมกัน  
เป้าหมาย: ควบคุมความเสี่ยงด้วย Cut Loss, Break-even, Trailing TP, RR, Virtual Capital และ Auto Re-entry หลัง Basket ว่าง

> ห้ามใช้บัญชี Netting เพราะระบบต้องถือ Buy และ Sell ของ Symbol เดียวกันพร้อมกัน

---

## 2. โครงสร้างไฟล์

```text
MQL5/
└── Experts/
    └── Hedge1.0/
        ├── Hedge1.0.mq5
        │
        └── include/
            ├── Hedge1_Inputs.mqh
            ├── Hedge1_Utils.mqh
            ├── Hedge1_Capital.mqh
            ├── Hedge1_Session.mqh
            ├── Hedge1_Engine.mqh
            ├── Hedge1_Protect.mqh
            ├── Hedge1_Panel.mqh
            └── Hedge1_Report.mqh
```

## 3. หน้าที่แต่ละไฟล์

| ไฟล์ | หน้าที่ |
|---|---|
| `Hedge1.0.mq5` | ไฟล์ EA หลัก: เรียก OnInit, OnTick, OnChartEvent, OnDeinit |
| `Hedge1_Inputs.mqh` | Input ทั้งหมดของ EA |
| `Hedge1_Utils.mqh` | แปลง Points เป็นราคา, อ่าน Spread, จัดรูปแบบเงิน/ข้อความ |
| `Hedge1_Capital.mqh` | Virtual Capital, Refill, Closed Net, สูตร Auto Lot |
| `Hedge1_Session.mqh` | Session Block ตามเวลา Server |
| `Hedge1_Engine.mqh` | เปิด Hedge, เปิด/ปิด Manual, Timeout, Spread Gate, Basket Logic |
| `Hedge1_Protect.mqh` | Cut Loss, Break-even, RR, Trailing TP |
| `Hedge1_Panel.mqh` | Panel, ปุ่ม Manual, Responsive Layout, Minimize |
| `Hedge1_Report.mqh` | สร้าง CSV Report ตามรอบวัน |

---

# 4. สถานะการ Compile

สถานะล่าสุดที่ยืนยันแล้ว:

```text
0 errors, 0 warnings
1581 ms elapsed
cpu='X64 Regular'
```

ปัญหาที่เคยแก้แล้ว:

- ตัดการใช้ `CTrade` และ `Trade.mqh` ออก
- ใช้ `OrderSend()` ตรงใน Engine
- แก้ปัญหา MT5/Trade.mqh เวอร์ชันไม่ตรงกับ Compiler
- แก้ปัญหา `{` และ `#ifdef/#endif` ไม่สมดุลใน:
  - `Hedge1_Engine.mqh`
  - `Hedge1_Protect.mqh`
- Panel Responsive เวอร์ชันใหม่ Compile ผ่านแล้ว

---

# 5. กติกาหลักของระบบ

## 5.1 Hedge 1 Basket เท่านั้น

กติกาที่ต้องยึดเป็นหลัก:

```text
ระบบมี Hedge ได้เพียง 1 Basket ต่อ Symbol + Magic Number

1 Basket =
Buy 1 ไม้
+
Sell 1 ไม้
```

ระบบต้องทำงานตามนี้:

```text
หากยังมี Buy หรือ Sell อย่างน้อย 1 ไม้
= Basket ยังไม่ว่าง
= ห้ามเปิด Hedge ชุดใหม่
= ห้ามเปิดไม้เพิ่มอัตโนมัติ

เมื่อ Buy = 0 และ Sell = 0
= Basket ว่างจริง
= เริ่มนับ Timeout
= รอ Spread ผ่าน
= จึงเปิด Hedge รอบใหม่
```

ตัวอย่างที่ถูกต้อง:

```text
เปิด Hedge:
Buy 0.01
Sell 0.01

หากราคาไปขึ้น:
Sell ถูก Cut Loss
Buy ยังเปิดอยู่

ผลที่ต้องการ:
- ห้ามเปิด Sell ใหม่
- ห้ามเปิด Buy ใหม่
- รอให้ Buy ปิดก่อน
- เมื่อ Buy = 0 และ Sell = 0
- จึงเริ่ม Timeout สำหรับรอบใหม่
```

สถานะ Engine ที่ควรเห็นบน Panel/Log:

```text
BASKET_RUNNING
= มี Buy + Sell ครบ

WAIT_BASKET_EMPTY
= เหลือออเดอร์เพียงฝั่งเดียว
= ห้ามเปิดเพิ่ม

WAIT_TIMEOUT
= Basket ว่างแล้ว แต่ยังรอเวลา

WAIT_SPREAD
= Timeout ผ่านแล้ว แต่ Spread ยังเกินกำหนด

READY
= Basket ว่าง + Timeout ผ่าน + Spread ผ่าน
= พร้อมเปิด Hedge รอบใหม่
```

---

## 5.2 Timeout และ Spread Gate

กติกา Auto Entry:

```text
Basket ต้องว่าง
AND
Timeout ต้องครบ
AND
Spread ต้องไม่เกินค่าที่ตั้งไว้
```

ตัวอย่าง:

```text
Timeout = 60 วินาที
Max Spread = 25 Points

Basket ว่าง
→ รอ 60 วินาที
→ หาก Spread = 24
→ เปิด Hedge ได้

Basket ว่าง
→ รอครบ 60 วินาที
→ หาก Spread = 36
→ ห้ามเปิด
→ รอจน Spread <= 25
```

Log ที่ผ่านการทดสอบแล้ว:

```text
AUTO READY -> เปิด Hedge ใหม่
| Spread=24.0 / Max=25
| Timeout=60 sec
| Lot=0.01
```

ผลหมายถึง:

```text
Spread 24 <= 25
Timeout ผ่านแล้ว
ระบบจึงเปิด Buy + Sell ได้ถูกต้อง
```

---

# 6. หน่วย Point ของ XAUUSD

ค่าที่ใช้ปัจจุบัน:

```text
InpPointDigits = 2
1 Point = $0.01
100 Points = $1.00
500 Points = $5.00
700 Points = $7.00
1000 Points = $10.00
```

สูตรแปลง:

```text
ราคาเคลื่อนที่ = Points × 0.01
```

ตัวอย่าง:

```text
700 Points  = ราคาทองเคลื่อน $7.00
1200 Points = ราคาทองเคลื่อน $12.00
1500 Points = ราคาทองเคลื่อน $15.00
```

---

# 7. Cut Loss

Cut Loss เป็น SL จริงที่ถูกตั้งไว้บน Server ของโบรกเกอร์

ตัวอย่างเมื่อกำหนด:

```text
Cut Loss = 700 Points
```

เปิด Hedge ที่ราคา 4195.00:

```text
Buy เปิดที่ 4195.00
Buy SL = 4188.00
= ขาดทุนสูงสุดประมาณ -700 Points

Sell เปิดที่ 4195.00
Sell SL = 4202.00
= ขาดทุนสูงสุดประมาณ -700 Points
```

เหตุผลที่ต้องตั้ง SL ให้ทั้งสองฝั่งทันที:

```text
- ป้องกันไม้ผิดทาง
- แม้ MT5 ปิด
- แม้ EA หยุด
- แม้ VPS/Internet มีปัญหา
- SL ยังอยู่ที่โบรกเกอร์
```

---

# 8. Auto Break-even 20%

ค่าหลัก:

```text
Break-even Trigger = 1000 Points
Break-even Percent = 20%
Break-even Step = 100 Points
Mode = Trailing
```

หลักการ:

```text
เมื่อไม้กำไรถึง +1000 Points
ระบบย้าย SL ไปล็อกกำไร +200 Points
```

สูตร:

```text
Lock Profit = กำไรสูงสุด × 20%
```

ตัวอย่าง Buy:

| กำไรสูงสุด | SL ล็อกกำไร |
|---:|---:|
| +1000 Points | +200 Points |
| +1100 Points | +220 Points |
| +1500 Points | +300 Points |
| +1800 Points | +360 Points |
| +1900 Points | +380 Points |
| +2000 Points | +400 Points |

Break-even ทำหน้าที่เป็น:

```text
SL สำรอง
+
ระบบล็อกกำไร
+
ป้องกันกรณีราคากลับตัวแรง
+
ป้องกัน Gap / EA หยุด / Network หลุด
```

---

# 9. Trailing TP แบบใหม่

## 9.1 กติกาที่ตกลงล่าสุด

Trailing TP ต้องไม่เริ่มทำงานทันทีตั้งแต่กำไรเป็นบวก

Trailing TP จะเริ่มทำงานเมื่อ:

```text
Trailing Arm Level
=
Cut Loss Points
+
Trailing Pullback Points
```

ตัวอย่าง:

```text
Cut Loss = 700 Points
Trailing Pullback = 500 Points

Trailing Arm Level
= 700 + 500
= +1200 Points
```

ดังนั้น:

```text
กำไรต่ำกว่า +1200
= Trailing TP ยังไม่ทำงาน

กำไรถึง +1200
= Trailing TP ถูก Arm
= ถ้าราคาย่อกลับ 500 Points จะปิดไม้
```

## 9.2 ตารางตัวอย่าง Cut Loss 700 / Trailing 500

| กำไรสูงสุด | Trailing ทำงานหรือไม่ | จุดปิดเมื่อราคาย่อ |
|---:|---|---:|
| +500 | ยังไม่ Arm | ไม่มี |
| +700 | ยังไม่ Arm | ไม่มี |
| +1000 | ยังไม่ Arm | ไม่มี |
| +1199 | ยังไม่ Arm | ไม่มี |
| +1200 | Arm แล้ว | +700 |
| +1500 | ทำงานแล้ว | +1000 |
| +1800 | ทำงานแล้ว | +1300 |
| +1900 | ทำงานแล้ว | +1400 |
| +2500 | ทำงานแล้ว | +2000 |

ตัวอย่าง:

```text
Buy ได้กำไรสูงสุด +1800 Points
Trailing TP = +1300 Points

ถ้าราคาย่อลงจนกำไรเหลือ +1300 Points
→ EA ปิด Buy
```

## 9.3 สถานะ Patch Trailing TP

ต้องตรวจสอบว่าได้ใส่ Patch ล่าสุดในไฟล์นี้แล้วหรือไม่:

```text
MQL5/Experts/Hedge1.0/include/Hedge1_Protect.mqh
```

Patch ใหม่ต้องมี logic นี้:

```cpp
double trailingArmPoints = InpCutLossPoints + InpTrailingPullback;
```

และต้องเริ่ม `TrailUpsert()` เฉพาะเมื่อ:

```cpp
if(profPts >= trailingArmPoints)
```

หากยังใช้ logic เก่า:

```cpp
TrailUpsert(ticket, profPts);
```

โดยไม่มีเงื่อนไข Arm Level แปลว่า Trailing TP ยังเริ่มเร็วเกินไป และต้องแก้

---

# 10. RR และความสัมพันธ์กับ Trailing TP

หากต้องการให้ไม้มีโอกาสวิ่งถึง Trailing TP:

```text
Cut Loss = 700
Trailing Pullback = 500
Trailing Arm = +1200
```

RR ต้องสูงกว่า +1200 Points

ค่าแนะนำ:

```text
Break-even Trigger = 1000
RR Percent = 200%
RR Target = +2000 Points
```

สูตร:

```text
RR Target
=
Break-even Trigger × RR Percent

1000 × 200%
=
+2000 Points
```

เหตุผล:

```text
หาก RR = 100%
→ ปิดกำไรที่ +1000
→ Trailing Arm อยู่ +1200
→ Trailing TP ไม่มีโอกาสทำงาน

หาก RR = 200%
→ ปิดกำไรที่ +2000
→ Trailing TP มีช่วงทำงานตั้งแต่ +1200 ถึงก่อน +2000
```

Input ที่ควรใช้:

```text
InpRRPercent = 200.0
InpTradeComment = "Hedge 1.0 [1000 RR 1:2]"
```

---

# 11. สูตร Virtual Capital และ Auto Lot

ค่าหลัก:

```text
Initial Capital = $50
Lot Step Money = $50
Base Lot = 0.01
Lot Increment = 0.01
Max Lot Step = 4
```

สูตร:

```text
Virtual Equity
=
Initial Capital
+
Total Refill
+
Closed Net

Lot
=
Base Lot
+
(floor(Virtual Equity / LotStepMoney) - 1)
× Lot Increment
```

มีเพดาน:

```text
Max Lot Step = 4
Max Lot = 0.04
```

ตัวอย่าง:

| Virtual Equity | Lot ตามสูตร | Lot จริงหลัง Max |
|---:|---:|---:|
| $50 | 0.01 | 0.01 |
| $80 | 0.01 | 0.01 |
| $100 | 0.02 | 0.02 |
| $120 | 0.02 | 0.02 |
| $180 | 0.03 | 0.03 |
| $230 | 0.04 | 0.04 |
| $300 | 0.06 | 0.04 |
| $500 | 0.10 | 0.04 |

กติกาเพิ่มเติม:

```text
Virtual Equity <= $0
→ หยุดเปิด Auto Order
→ รอกด REFILL
```

---

# 12. Panel และปุ่ม Manual

Panel เวอร์ชันล่าสุดมี:

```text
BUY
SELL
CLOSE BUY
CLOSE SELL
REFILL
HEDGE OPEN (B+S)
CLOSE ALL
```

กติกา:

```text
Manual BUY / SELL / HEDGE OPEN
= กดได้แม้ Session Block

Auto Entry
= ต้องผ่าน Session + Timeout + Spread + Basket Empty

Protect
= Cut Loss / Break-even / RR / Trailing
= ทำงานต่อแม้ Session Block
```

## 12.1 Panel Responsive

Panel เวอร์ชันใหม่รองรับ:

```text
กราฟกว้างปกติ
→ แสดง Panel เต็ม

กราฟแคบ
→ ลดขนาด Panel / Font / Button

กราฟแคบมาก
→ Auto Minimize เหลือ Header
```

ปุ่ม `-` และ `+`:

```text
-
= ซ่อนรายละเอียด

+
= แสดงรายละเอียดทั้งหมด
```

## 12.2 สีปุ่ม Close

สถานะล่าสุดที่ต้องตรวจว่าทำ Patch แล้วหรือไม่:

```text
CLOSE BUY
= พื้นน้ำเงินเข้ม
= กรอบฟ้าน้ำเงินหนา

CLOSE SELL
= พื้นแดงเข้ม
= กรอบแดงหนา

CLOSE ALL
= สีมัสตาร์ด/ทอง
= คำสั่งความเสี่ยงสูง ปิดทุกไม้
```

---

# 13. CSV Report

เงื่อนไขสร้าง Report:

```text
Enable Report = true
ครบจำนวนวันตาม InpReportDays
AND
Basket ว่าง
```

ค่าเริ่มต้น:

```text
InpReportDays = 5
```

หากครบ 5 วัน แต่ Basket ยังไม่ว่าง:

```text
ไม่สร้าง CSV ทันที
รอจน Basket ว่าง
แล้วจึงสร้าง Report
จากนั้นเริ่มนับรอบ 5 วันใหม่
```

ตำแหน่งไฟล์:

```text
MQL5/Files/
```

รูปแบบชื่อไฟล์:

```text
Symbol_Magic_YYYYMMDD_HHMM.csv
```

ตัวอย่าง:

```text
XAUUSD_9875_20261013_1200.csv
```

---

# 14. จุดที่ต้องตรวจทุกครั้ง

## ก่อน Attach EA

```text
[ ] บัญชีเป็น Hedging ไม่ใช่ Netting
[ ] Symbol ถูกต้อง เช่น XAUUSD
[ ] Magic Number ไม่ชนกับ EA ตัวอื่น
[ ] Point Digits ถูกต้อง
[ ] Max Spread ตรงกับโบรกเกอร์
[ ] Cut Loss / BE / RR / Trailing ตั้งตามแผน
[ ] ตรวจ RR ว่าไม่ปิดก่อน Trailing Arm
```

## หลัง Attach EA

```text
[ ] Panel แสดง Symbol และ Magic ถูกต้อง
[ ] Virtual Equity เริ่มจากทุนที่ตั้ง
[ ] Effective Lot ถูกต้อง
[ ] Spread แสดงค่า
[ ] Timeout แสดงค่า
[ ] Session Status แสดง OPEN หรือ BLOCK ถูกต้อง
[ ] ไม่มีออเดอร์เก่าที่ Magic เดียวกันค้างอยู่
```

## การเทส Auto Hedge

```text
[ ] Basket ว่าง
[ ] รอ Timeout ครบ
[ ] Spread <= Max Spread
[ ] Log ขึ้น AUTO READY
[ ] เปิด Buy 1 ไม้
[ ] เปิด Sell 1 ไม้
[ ] Lot เท่ากัน
[ ] ไม่มี Hedge ชุดที่สอง
```

## การเทส Risk Protection

```text
[ ] เปิด Hedge แล้วมี SL ของ Cut Loss ทั้ง Buy/Sell
[ ] ฝั่งผิดทางโดน SL ตามจำนวน Points ที่ตั้ง
[ ] ฝั่งกำไรถึง BE Trigger แล้ว SL ย้ายไปกำไร
[ ] BE Trailing ขยับทุก 100 Points
[ ] Trailing TP ยังไม่ Arm ก่อนถึง Arm Level
[ ] Trailing TP Arm หลังถึง CutLoss + Pullback
[ ] RR ปิดที่เป้าหมายที่ตั้งไว้
```

---

# 15. กฎการแก้โค้ดในอนาคต

ใช้ Jigsaw Patch Rule:

```text
ไฟล์ใหม่
→ ส่ง Full Code ได้

ไฟล์เดิม
→ ใช้ FIND / REPLACE เท่านั้น

กรณีผู้ใช้พิมพ์ชัดเจนว่า:
"ขอ fullcode [ชื่อไฟล์]"
→ ส่ง Full Code ของไฟล์นั้นได้
```

ทุกครั้งก่อนแก้:

```text
1. ระบุ Path ของไฟล์
2. อธิบายปัญหาและผลกระทบ
3. ส่ง FIND / REPLACE ให้ตรงจุด
4. Compile
5. ตรวจ 0 errors, 0 warnings
6. เทสบน Demo ก่อน
```

---

# 16. ข้อควรระวังสำคัญ

```text
1. ห้ามเทสครั้งแรกบนเงินจริง
2. ห้ามใช้ Netting Account
3. ห้ามเปิดหลาย Chart ที่ใช้ Symbol + Magic เดียวกัน
4. ห้ามเปลี่ยน Magic Number ระหว่างมีออเดอร์ค้าง
5. หลังเปลี่ยน Input / Compile ใหม่ EA อาจ OnDeinit และ OnInit ใหม่
6. ตรวจ Journal / Experts ทุกครั้งที่เปิด Hedge
7. หาก Spread สูง ห้ามคาดหวังว่า Auto Hedge จะเปิดทันที
8. หาก RR ต่ำกว่า Trailing Arm, Trailing TP จะไม่มีโอกาสทำงาน
9. หาก Virtual Equity <= 0 ระบบต้องหยุด Auto Entry
10. Basket ต้องว่างจริงก่อนเริ่ม Auto รอบใหม่
```

---

# 17. Log ที่ควรใช้ตรวจ Audit

## เปิด Hedge สำเร็จ

```text
Hedge1: AUTO READY -> เปิด Hedge ใหม่
| Spread=24.0 / Max=25
| Timeout=60 sec
| Lot=0.01

Hedge1: เปิดคู่ Hedge สำเร็จ lot=0.01
```

## Spread ยังไม่ผ่าน

```text
WAIT_SPREAD
```

## Basket ยังไม่ว่าง

```text
WAIT_BASKET_EMPTY
```

## Trailing TP เริ่มทำงาน

```text
Hedge1: Trailing TP ARMED #123456
| Profit=1200 pts
| Arm=1200 pts
| Exit if retrace to 700 pts
```

## Trailing TP ปิดไม้

```text
Hedge1: Trailing TP CLOSE #123456
| Best=1800 pts
| Current=1300 pts
| Pullback=500 pts
```

---

# 18. สถานะงานล่าสุด

## ทำแล้ว

```text
[✓] Blueprint หลัก
[✓] Modular MT5 EA 9 ไฟล์
[✓] Compile 0 errors / 0 warnings
[✓] Hedge Account Validation
[✓] Virtual Capital
[✓] Auto Lot
[✓] Refill
[✓] Session Block
[✓] Timeout Gate
[✓] Spread Gate
[✓] Cut Loss SL
[✓] Break-even
[✓] RR
[✓] Trailing TP เวอร์ชันเดิม
[✓] CSV Report
[✓] Panel
[✓] Responsive Panel
[✓] Footer ฝั่งขวา
```

## ต้องตรวจ/ยืนยันก่อนใช้งานจริง

```text
[ ] ใส่ Patch กติกา 1 Basket เท่านั้นครบแล้วหรือไม่
[ ] ยืนยันว่า Auto ไม่ Reopen ฝั่งที่ถูก SL
[ ] ใส่ Patch Armed Trailing TP แล้วหรือไม่
[ ] ตั้ง RR = 200% หากต้องการให้ Trailing TP ทำงาน
[ ] เปลี่ยน Comment/Footer เป็น RR 1:2 หาก RR = 200%
[ ] ใส่ Patch ปุ่ม CLOSE BUY / CLOSE SELL แบบกรอบหนาแล้วหรือไม่
[ ] Test Strategy Tester
[ ] Test Demo อย่างน้อยหลายรอบ Hedge
[ ] เก็บ Experts/Journal Log เป็นหลักฐาน Audit
```