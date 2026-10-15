เริ่ม **Preflight** ครับ รอบนี้มีเป้าหมายเดียว: ตรวจว่า Strategy Tester เลือก EA และโหลด `.set` ถูกชุดก่อนเริ่ม Short Test ยังไม่กด Start ไม่เปิด Order บน Demo และไม่แก้ Source เพิ่มครับ

## 1. ข้อมูลที่ตรวจครบแล้ว — ไม่ต้องส่งซ้ำ

| รายการ | สถานะ |
|---|---|
| Source | `1a3b38f` — ตรวจ Patch แล้ว |
| Compile EA | คุณรายงาน `0 errors / 0 warnings` |
| บัญชี | Demo Hedging — ยืนยันจาก Script |
| Symbol | XAUUSD |
| Native Point / Tick Size | 0.01 / 0.01 |
| Stops Level / Freeze Level | 0 / 0 |
| `InpPointDigits` | 2 |
| Short / Long Magic | 99999 / 99998 — คุณยืนยันไม่ปนข้อมูลเดิม |
| Max Spread | คง 25 |
| Preset | คุณบันทึกครบ 18 ไฟล์แล้ว |

สิ่งที่ยังต้องตรวจคือไฟล์ EA ที่เลือกในเครื่อง ค่าที่โหลดจาก `.set` และ Settings ของ Tester การเตรียมครบยังไม่ใช่ผล Runtime ผ่านครับ 
## 2. เปิดหน้าตั้งค่า Tester

ใน MT5 เปิด `View → Strategy Tester` แล้วเลือกโหมดทดสอบครั้งเดียว ไม่ใช่ Optimization

ตั้งค่าดังนี้:

| ช่อง | ค่าที่ใช้ในขั้นเตรียม |
|---|---|
| Expert | `Hedge1.0.ex5` จากโฟลเดอร์ชุดที่คุณ Compile สำหรับ `1a3b38f` |
| Symbol | `XAUUSD` |
| Timeframe | `H1` ตามรูปแบบที่วางไว้ |
| Modeling | `Every tick based on real ticks` |
| Optimization | `Disabled` |
| Visual mode | เปิด |
| Forward | ปิด ถ้ามีช่องนี้ |

Visual Testing ใช้ดูการทำงานบนข้อมูลย้อนหลัง และต้องปิด Optimization เพื่อใช้ Visualization ครับ 

อย่าเลือก EA จากเลข Version `1.00` เพียงอย่างเดียว เพราะโปรเจกต์นี้ยังใช้เลขดังกล่าว ให้ตรวจโฟลเดอร์และชุดไฟล์ที่ Compile จริงครับ 
### ช่องที่ต้องบันทึกค่าจริง

- ช่วงวันที่เริ่ม–จบ: เลือกช่วงย้อนหลังหลายวันที่มีข้อมูล โดยยังไม่เริ่มรัน
- Deposit และ Currency
- Leverage
- Execution delay ถ้ามี

Deposit และ Leverage ใน Tester มีผลต่อสภาพบัญชีจำลองและ Margin จึงต้องบันทึกแยกจาก `InpInitialCapital=50` ซึ่งเป็นทุนเสมือนของ EA ไม่ต้องตั้ง Deposit เป็น 50 เพียงเพื่อให้ตัวเลขตรงกันครับ [metatrader5](https://www.metatrader5.com/en/terminal/help/algotrading/testing)

## 3. โหลด Preset หนึ่งไฟล์เพื่อยืนยันรูปแบบ

ไปแท็บ `Inputs` แล้วใช้คำสั่ง `Load` โหลด:

```text
SHORT_02_CUT.set
```

ใช้ไฟล์นี้ตรวจการโหลดเท่านั้น ยังไม่กด Start การจัดการ Input parameters ทำในแท็บ Inputs ของ Strategy Tester ครับ [metatrader5](https://www.metatrader5.com/en/terminal/help/start_advanced/start)

ตรวจคอลัมน์ `Value` ให้ตรงกับรายการนี้:

| Input | ค่าที่ต้องเห็น |
|---|---:|
| `InpPointDigits` | 2 |
| `InpInitialCapital` | 50.0 |
| `InpBaseLot` | 0.01 |
| `InpAutoLot` | false |
| `InpReopenOnEmpty` | true |
| `InpUseTimeout` | false |
| `InpUseSpreadCheck` | true |
| `InpMaxSpreadPoints` | 25 |
| `InpCutLossPoints` | 70 |
| `InpBreakEvenMode` | `BE_OFF` หรือ 0 |
| `InpRRPercent` | 0.0 |
| `InpUseTrailingTP` | false |
| `InpMagicNumber` | 99999 |
| `InpTradeComment` | `H1 02_CUT` |
| `InpEnableReport` | false |
| `InpStateImportLegacy` | false |
| `InpTrailImportLegacy` | false |

หากโหลดแล้วค่าไม่เปลี่ยนหรือบางค่าหาย ให้หยุดที่การตรวจไฟล์ `.set` ก่อน ไม่แก้ Logic ของ EA ตามปัญหาการโหลดไฟล์ครับ 
## 4. หลักฐานที่ส่งครั้งเดียวสำหรับ Preflight รอบนี้

ส่งมาเป็นชุดเดียวได้เลย:

1. ภาพแท็บ Settings ของ Tester
2. ภาพแท็บ Inputs หลังโหลด `SHORT_02_CUT.set` โดยเลื่อนถ่ายให้เห็นกลุ่ม Lot/Entry, Protection และ Magic/System ตามตารางข้างบน

ถ้าส่งภาพไม่ได้ ใช้ข้อความนี้แทน:

```text
Expert และโฟลเดอร์ที่เลือก:
Symbol / Timeframe:
ช่วงวันที่:
Modeling:
Optimization / Visual / Forward:
Deposit / Currency:
Leverage:
Execution delay:

โหลด SHORT_02_CUT.set แล้ว:
ค่าตามตารางตรงทั้งหมด / มีค่าที่ไม่ตรงดังนี้…
```

นี่เป็นการตรวจความพร้อมครั้งเดียวก่อนชุดทดสอบ ไม่ใช่ให้คุณเริ่มทดสอบแล้วส่งผลทีละฟีเจอร์ครับ หลังตรวจชุดนี้แล้วจึงไปขั้นเริ่ม Short Test ตามลำดับที่เตรียมไว้ โดยไม่แตะ Preset Long Run ตอนนี้