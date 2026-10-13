# UI Theme — HEDGE_DARK_NEON_V1

## วิธีใช้กับ EA ใหม่

1. คัดลอกไฟล์ `HedgeUI_Theme.mqh` ไปไว้ในโฟลเดอร์ local ของ EA ใหม่ เช่น:

```text
MQL5/Experts/<ชื่อโปรเจกต์>/include/HedgeUI_Theme.mqh
```

2. ในไฟล์ Panel ของ EA ใหม่ ให้ include:

```cpp
#include "HedgeUI_Theme.mqh"
```

3. ใส่ข้อความนี้ไว้ต้น Blueprint / Prompt ทุกโปรเจกต์:

```text
UI_THEME: HEDGE_DARK_NEON_V1 (LOCKED)
ใช้ธีม Panel ตามไฟล์ HedgeUI_Theme.mqh
ห้ามเปลี่ยนสี Font ปุ่ม หรือ Layout หลัก เว้นแต่ระบุชัดเจน
```

## เป้าหมายภาพรวม

- Dark dashboard สำหรับ EA / Trading
- พื้นหลังดำเกือบสนิท
- ข้อมูลสำคัญใช้ Neon Cyan / Neon Green
- สีแดงใช้สำหรับ Sell, ขาดทุน, Block หรือ Off
- สีเหลืองใช้สำหรับจำนวน Active Position และคำสั่ง Close All
- Font เป็น Arial Bold เพื่อให้อ่านง่ายบนกราฟ
- Panel ต้อง Responsive และมีปุ่ม Minimize `- / +`

## Font

| ส่วน | Font | ขนาดปกติ | Compact |
|---|---|---:|---:|
| Header | Arial Bold | 10 | 9 |
| Label ปกติ | Arial Bold | 9 | 8 |
| Value ปกติ | Arial Bold | 9 | 8 |
| Value สำคัญ | Arial Bold | 10 | 9 |
| Button | Arial Bold | 9 | 8 |
| Footer | Arial Bold | 9 | 8 |

## สีหลัก

| Token | สี | ใช้กับ |
|---|---|---|
| HUI_BG | #121212 | พื้นหลัง Panel |
| HUI_BORDER | #333333 | ขอบ Panel |
| HUI_HEADER | #FFD700 | Header / Footer |
| HUI_TEXT | #FFFFFF | ค่า 0 / ปกติ |
| HUI_LABEL | #E1E1E1 | Label ทั่วไป |
| HUI_CYAN | #00FFFF | Effective Lot |
| HUI_GREEN | #00FF7D | Virtual Equity / กำไร / ON / OPEN |
| HUI_RED | #FF554B | ขาดทุน / BLOCK / OFF |
| HUI_YELLOW | #FFD700 | Active Position > 0 |
| HUI_BUY_TEXT | #50A5FF | Buy > 0 |
| HUI_SELL_TEXT | #FF5F5A | Sell > 0 |

## สีปุ่ม

| ปุ่ม | พื้น | กรอบ |
|---|---|---|
| BUY | น้ำเงิน #1E56A0 | น้ำเงิน #1E56A0 |
| SELL | แดง #D9534F | แดง #D9534F |
| CLOSE BUY | น้ำเงินเข้ม #123760 | ฟ้าสว่าง #3587EB หนา 3 px |
| CLOSE SELL | แดงเข้ม #70262A | แดงสว่าง #F55C56 หนา 3 px |
| REFILL | เทาเข้ม #404040 | เทา #333333 |
| HEDGE OPEN | ม่วง #6A1B9A | ม่วง #6A1B9A |
| CLOSE ALL | มัสตาร์ด #B8860B | เทาเข้ม #333333 |

## กฎสีของข้อมูล

```text
ค่าบวก      = Neon Green
ค่าติดลบ    = Red
ค่า 0       = White
ค่าคงที่    = White
Effective Lot = Cyan
Virtual Equity = Green เมื่อ > 0, Red เมื่อ <= 0
Closed Net    = Green เมื่อ > 0, Red เมื่อ < 0, White เมื่อ = 0
Open Floating = Green เมื่อ > 0, Red เมื่อ < 0, White เมื่อ = 0
Cycle Loss    = Red เมื่อ < 0, White เมื่อ = 0
```

## กฎสี Active

```text
Active > 0 = Yellow
Active = 0 = White

Buy > 0 = Blue
Buy = 0 = White

Sell > 0 = Red
Sell = 0 = White
```

## กฎสี Status

```text
Session OPEN  = Green ทั้งแถว
Session BLOCK = Red ทั้งแถว

Spread Check ON  = Green ทั้งแถว
Spread Check OFF = Red ทั้งแถว

Timeout ON  = Green ทั้งแถว
Timeout OFF = Red ทั้งแถว
```

> สี ON หมายถึงระบบย่อยเปิดใช้งาน ไม่ได้แปลว่าเงื่อนไขผ่านเสมอไป เช่น Spread Check ON แต่ Spread อาจยังเกิน Max Spread ได้

## Layout

```text
Normal Mode:
- Panel width: 430 px
- Panel height: 360 px
- ด้านซ้าย: Status / Lot & Capital / Positions
- ด้านขวา: ปุ่ม Manual
- Footer: ใต้ CLOSE ALL ฝั่งขวา

Compact Mode:
- ใช้เมื่อความกว้างกราฟ < 520 px
- ลดความกว้าง Panel และ Font เล็กน้อย

Auto Minimize:
- ใช้เมื่อความกว้างกราฟ < 330 px
- เหลือ Header และปุ่ม +
```

## Footer

Footer อยู่ใต้ปุ่ม CLOSE ALL ฝั่งขวา และใช้สีทอง:

```text
Hedge 1.0
[1000 RR 1:2]
```

## กฎการเปลี่ยนธีม

- ใช้ `HEDGE_DARK_NEON_V1` เป็นค่าเริ่มต้นของ EA ทุกตัว
- หากจะเปลี่ยน ให้สร้างเวอร์ชันใหม่ เช่น `HEDGE_DARK_NEON_V2`
- ห้ามแก้ V1 เฉพาะ EA ตัวเดียวโดยไม่บันทึก เพราะจะทำให้ธีมแต่ละโปรเจกต์ไม่เหมือนกัน
- ทุกโปรเจกต์เก็บไฟล์ Theme ไว้ใน `include/` ของตัวเอง เพื่อไม่ปะปนกับ EA อื่น
