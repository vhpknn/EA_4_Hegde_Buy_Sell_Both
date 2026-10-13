EA Hedge 1.0 — คู่มือใช้งานแบบเข้าใจง่าย
EA นี้ทำอะไร
EA Hedge 1.0 เป็น Expert Advisor สำหรับ MT5 ที่เปิดคำสั่ง Buy และ Sell พร้อมกัน เรียกว่า Hedge 1 Basket แล้วปล่อยให้ตลาดเลือกทิศทาง

ฝั่งที่ผิดทางถูกจำกัดความเสียหายด้วย Cut Loss

ฝั่งที่ถูกทางใช้ Break-even, Trailing TP และ RR Target เพื่อรักษา/ปิดกำไร

เมื่อทุกคำสั่งปิดหมด (Basket ว่าง) EA จะรอ Timeout และรอ Spread ผ่าน ก่อนเริ่ม Hedge รอบใหม่

EA นี้ต้องใช้บัญชี MT5 แบบ Hedging เท่านั้น ไม่รองรับ Netting Account

โครงสร้างโปรเจกต์
text
MQL5/
└── Experts/
    └── Hedge1.0/
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
ให้ Compile ที่ไฟล์ Hedge1.0.mq5 เท่านั้น

เริ่มใช้งาน
1. Compile
เปิด Hedge1.0.mq5 ด้วย MetaEditor

กด F7

ผลที่ต้องการคือ 0 errors, 0 warnings

2. เตรียมกราฟ
เปิดกราฟ Symbol ที่ต้องการ เช่น XAUUSD

ตรวจสอบว่าบัญชีเป็นแบบ Hedging

ลาก EA Hedge1.0 ลงบนกราฟ

เปิดปุ่ม Algo Trading / Auto Trading ของ MT5

ตรวจว่า Panel แสดง Symbol และ Magic Number ถูกต้อง

3. เริ่มจาก Demo
ควรทดสอบใน Demo Account ก่อนเสมอ โดยทดสอบทีละระบบ: Refill, Manual Buttons, Timeout, Spread, Cut Loss, Break-even, Trailing TP และ Report

คำศัพท์สำคัญ
คำ	ความหมาย
Basket	กลุ่มคำสั่งของ EA ใน Symbol + Magic Number เดียวกัน
Hedge	เปิด Buy และ Sell พร้อมกัน
Point	หน่วยระยะราคาที่ EA ใช้คำนวณ
Cut Loss	SL จำกัดขาดทุนของแต่ละไม้
Break-even	ย้าย SL มาล็อกกำไร/กันทุนเมื่อราคาไปทางที่ถูก
Trailing TP	ปิดกำไรเมื่อราคาย่อจากกำไรสูงสุดตามระยะที่กำหนด
RR	เป้าหมายกำไรต่อไม้
Virtual Equity	ทุนจำลองสำหรับคำนวณ Lot ไม่ใช่ Balance จริงของบัญชี
การตั้งค่า Point ของทอง
ตัวอย่างสำหรับ XAUUSD ที่ใช้ราคา 2 ตำแหน่ง:

text
InpPointDigits = 2
1 Point = $0.01
100 Points = $1.00
500 Points = $5.00
1000 Points = $10.00
หากโบรกเกอร์แสดงราคาคนละรูปแบบ ต้องตรวจ Point Digits ให้ถูกก่อนใช้งานจริง

หลักการ 1 Basket
EA ใช้กฎสำคัญที่สุด:

text
มี Buy หรือ Sell ค้างอยู่แม้เพียง 1 ไม้
= Basket ยังไม่ว่าง
= ห้าม Auto เปิดไม้เพิ่ม

Buy = 0 และ Sell = 0
= Basket ว่างจริง
= เริ่มขั้นตอนเปิดรอบใหม่
ลำดับเปิดรอบใหม่:

text
Basket ว่าง
→ รอ Timeout
→ ตรวจ Spread
→ ถ้า Spread ผ่าน
→ เปิด Buy 1 ไม้ + Sell 1 ไม้
ตัวอย่าง:

text
Buy ยังเปิดอยู่
Sell ถูก Cut Loss ไปแล้ว

ผลที่ถูกต้อง:
EA รอให้ Buy ปิดก่อน
ไม่เปิด Sell ใหม่
ไม่เปิด Hedge ชุดใหม่
Timeout และ Spread
Timeout
กำหนดเวลาขั้นต่ำหลัง Basket ว่างก่อน EA จะเริ่มเปิดรอบใหม่

ตัวอย่าง:

text
InpUseTimeout = true
InpTimeoutSeconds = 300
หมายถึง Basket ว่างแล้วต้องรอ 300 วินาที

Spread
กำหนด Spread สูงสุดที่ยอมรับได้ก่อนเปิด Auto Hedge

ตัวอย่าง:

text
InpUseSpreadCheck = true
InpMaxSpreadPoints = 25
ผลคือ:

text
Spread <= 25 Points → ผ่าน
Spread > 25 Points  → รอ
หากเปิด Timeout และ Spread พร้อมกัน ต้องผ่านทั้งสองเงื่อนไข

Cut Loss
Cut Loss คือ Stop Loss จริงที่ส่งไปอยู่กับโบรกเกอร์หลังเปิดคำสั่ง

ตัวอย่าง:

text
InpCutLossPoints = 700
สำหรับ Point Digits = 2:

text
700 Points = $7.00
หากเปิด Hedge ที่ 4195.00:

text
Buy SL  = 4188.00
Sell SL = 4202.00
Cut Loss ถูกตั้งทั้ง Buy และ Sell เพื่อจำกัดไม้ที่ผิดทาง แม้ EA หรืออินเทอร์เน็ตมีปัญหา SL ก็ยังอยู่บน Server ของโบรกเกอร์

Auto Break-even 20%
Break-even เริ่มทำงานเมื่อไม้กำไรถึง Trigger ที่กำหนด

ตัวอย่าง:

text
Break-even Trigger = 1000 Points
Break-even Percent = 20%
Break-even Step    = 100 Points
Mode               = Trailing
เมื่อกำไรถึง +1000 Points:

text
SL จะย้ายไปล็อกกำไร +200 Points
เพราะ 1000 × 20% = 200
หากกำไรวิ่งต่อ:

กำไรสูงสุด	จุดล็อกกำไรของ SL
+1000	+200
+1500	+300
+1800	+360
+1900	+380
+2000	+400
Break-even เป็น SL สำรองสำหรับล็อกกำไร ไม่ใช่ Trailing TP

Armed Trailing TP
Trailing TP ของระบบนี้จะไม่เริ่มทันทีที่กำไรเป็นบวก

สูตร:

text
Trailing Arm Level = Cut Loss Points + Trailing Pullback
ตัวอย่าง:

text
Cut Loss = 700 Points
Trailing Pullback = 500 Points
Trailing Arm Level = 1200 Points
ตารางการทำงาน:

กำไรสูงสุด	Trailing TP	จุดปิดเมื่อราคาย่อ
+700	ยังไม่ Arm	ไม่มี
+1199	ยังไม่ Arm	ไม่มี
+1200	เริ่ม Arm	+700
+1500	ทำงานแล้ว	+1000
+1800	ทำงานแล้ว	+1300
+1900	ทำงานแล้ว	+1400
ตัวอย่าง:

text
Buy เคยกำไรสูงสุด +1800 Points
Trailing TP อยู่ที่ +1300 Points

หากราคาย่อจนกำไรเหลือ +1300 Points
EA ปิด Buy เพื่อเก็บกำไร
RR Target
RR คือเป้าหมายกำไรต่อไม้

ตัวอย่าง:

text
Break-even Trigger = 1000 Points
RR = 200%
RR Target = +2000 Points
ข้อสำคัญ:

text
หาก RR = 100%
ไม้จะปิดที่ +1000 Points
Trailing Arm ที่ +1200 จะไม่มีโอกาสทำงาน

หากต้องการใช้ Armed Trailing ตามตัวอย่าง
แนะนำ RR = 200%
ตัวอย่าง Comment ที่ควรตรงกับการตั้งค่า:

text
Hedge 1.0 [1000 RR 1:2]
Virtual Capital และ Auto Lot
Virtual Capital คือทุนจำลองที่ EA ใช้คำนวณ Lot โดยไม่ใช้ Balance จริงตรง ๆ

สูตร:

text
Virtual Equity = Initial Capital + Total Refill + Closed Net
ตัวอย่างการตั้งค่า:

text
Initial Capital = $50
Base Lot = 0.01
Lot Step Money = $50
Lot Increment = 0.01
Max Lot Step = 4
ตัวอย่าง Lot:

Virtual Equity	Lot ตามสูตร	Lot หลัง Max 0.04
$50	0.01	0.01
$100	0.02	0.02
$150	0.03	0.03
$200	0.04	0.04
$300	0.06	0.04
หาก Virtual Equity <= 0:

text
EA หยุดเปิด Auto Order
รอกด REFILL เพื่อเพิ่มทุนเสมือน
ปุ่มบน Panel
ปุ่ม	หน้าที่
BUY	เปิด Buy แบบ Manual ด้วย Lot ปัจจุบัน
SELL	เปิด Sell แบบ Manual ด้วย Lot ปัจจุบัน
CLOSE BUY	ปิด Buy ทั้งหมดของ Symbol + Magic นี้
CLOSE SELL	ปิด Sell ทั้งหมดของ Symbol + Magic นี้
REFILL	เพิ่ม Virtual Capital ตามจำนวนที่ตั้ง
HEDGE OPEN (B+S)	เปิด Buy + Sell พร้อมกันเมื่อ Basket ว่าง
CLOSE ALL	ปิด Buy และ Sell ทั้งหมดของ EA นี้
- / +	ย่อ / ขยาย Panel
Manual Buttons กดได้แม้ช่วง Session Block แต่ Auto Entry จะถูกบล็อกตาม Session, Timeout และ Spread

Session Block
Session ใช้สำหรับกำหนดช่วงเวลาที่ไม่ให้ EA เปิด Auto Order ใหม่ โดยอ้างอิงเวลา Server ของโบรกเกอร์

text
Session = true
→ Auto Entry หยุดในช่วงเวลานั้น

Session = false
→ ไม่บล็อกช่วงเวลานั้น
ข้อสำคัญ:

text
Session Block หยุดเฉพาะการเปิด Auto Order ใหม่
Cut Loss / Break-even / RR / Trailing TP
ยังทำงานกับไม้ที่เปิดค้างอยู่ตามปกติ
Panel และสถานะสำคัญ
สถานะ	ความหมาย
OPEN	Session ไม่บล็อก Auto Entry
BLOCK	Session กำลังบล็อก Auto Entry
BASKET_RUNNING	มี Buy + Sell อยู่ครบ Basket
WAIT_BASKET_EMPTY	ยังมีไม้ค้างอยู่ จึงห้ามเปิดใหม่
WAIT_TIMEOUT	Basket ว่างแล้ว แต่รอเวลาอยู่
WAIT_SPREAD	Timeout ผ่านแล้ว แต่ Spread ยังสูงเกินกำหนด
READY	พร้อมเปิด Hedge รอบใหม่
CAPITAL_DEAD	Virtual Equity <= 0 ต้อง Refill
CSV Report
เมื่อเปิด Report ระบบจะสร้าง CSV เมื่อ:

text
ครบจำนวนวันตาม InpReportDays
และ Basket ว่าง
ไฟล์อยู่ที่:

text
MQL5/Files/
ตัวอย่างชื่อไฟล์:

text
XAUUSD_998874_20261013_1200.csv
วิธีทดสอบก่อนใช้จริง
Test 1: Spread Gate
text
ตั้ง Max Spread = 25
ถ้า Spread = 36
EA ต้องไม่เปิด Auto Hedge

ถ้า Spread ลดเหลือ 24
และ Timeout ผ่าน
EA จึงเปิด Hedge ได้
Test 2: 1 Basket Only
text
เปิด Hedge 1 คู่
ให้ฝั่งหนึ่งถูก SL

EA ต้องไม่เปิดฝั่งที่หายกลับทันที
EA ต้องรอให้ไม้ที่เหลือปิด
Basket ต้องว่างจริงก่อนเริ่มรอบใหม่
Test 3: Break-even
text
ตั้ง Trigger = 1000
ตั้ง Percent = 20

เมื่อกำไรถึง +1000
SL ต้องย้ายไปกำไร +200
Test 4: Trailing TP
text
Cut Loss = 700
Trailing Pullback = 500

กำไรต้องถึง +1200 ก่อน Trailing จึง Arm
หากพีค +1800 และย่อถึง +1300
EA ต้องปิดกำไร
Test 5: Auto Lot
text
Initial Capital = $50
กด Refill 5 ครั้ง = +$50
Virtual Equity = $100
Lot ต้องเปลี่ยนจาก 0.01 เป็น 0.02
Checklist ก่อน Live
text
[ ] ใช้บัญชี Hedging
[ ] ทดสอบ Demo แล้ว
[ ] Compile 0 errors, 0 warnings
[ ] ตรวจ Point Digits ถูกต้อง
[ ] ตรวจ Spread ของโบรกเกอร์ในเวลาจริง
[ ] ตรวจ Cut Loss
[ ] ตรวจ Break-even
[ ] ตรวจ Armed Trailing TP
[ ] RR สูงกว่า Trailing Arm หากต้องการใช้ Trailing
[ ] ตรวจว่า Basket เปิดได้เพียง 1 ชุด
[ ] ตรวจ Magic Number ไม่ชนกับ EA อื่น
[ ] ตรวจ CSV Report และ Experts Log
คำเตือนความเสี่ยง
EA ช่วยกำหนดกติกาและควบคุมคำสั่งตามระบบ แต่ไม่สามารถรับประกันผลกำไรได้

ปัจจัยที่ยังมีผลต่อผลลัพธ์:

Spread ขยายช่วงข่าวหรือช่วง rollover

Slippage ตอนส่งคำสั่งหรือปิดคำสั่ง

Commission และ Swap

Gap ของราคา

การเชื่อมต่อ Internet / VPS / Server ของโบรกเกอร์

กฎ Stop Level หรือ Freeze Level ของโบรกเกอร์

ควรใช้ Demo และเก็บ Log/CSV เพื่อตรวจพฤติกรรมก่อนใช้งานเงินจริงเสมอ