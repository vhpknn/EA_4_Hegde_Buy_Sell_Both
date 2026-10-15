3. วิธีใช้กับแต่ละ Preset
ก่อนเริ่มรอบ
แก้ Magic ใน .set ตามตารางใหม่ เช่น Preset 01=99901

เปิด MT5 → File → Open Data Folder แล้วคัดลอก Path

เปิด Terminal ใน VS Code ที่โฟลเดอร์ Script ซึ่งอยู่นอก MT5 Data Folder

รัน:
run.bat
หรือ
powershell
python Hedge1_CollectSession.py


กรอก:

MT5 Data Folder

Path ของไฟล์ Preset

Symbol: กด Enter ใช้ XAUUSD

ตรวจว่าโปรแกรมแสดง Preset/Magic ถูก แล้วพิมพ์ START

จึงไปแนบ EA และโหลด Preset บนกราฟจริง

การเริ่มเก็บก่อนแนบ EA จะช่วยเก็บข้อความ Init ตั้งแต่ต้นรอบด้วย

เมื่อจบรอบ
เก็บภาพ Inputs, Trade/History และหลักฐานเฉพาะกรณี

จบรอบเทรดตามขั้นตอนเดิม: หยุด Auto Reopen แล้วปิด Position ใน Scope ให้ครบ

ถอด EA ของรอบนั้น

รอให้ Log ถูกเขียนลงไฟล์ก่อนกลับมากด Enter ใน Python

ตรวจข้อความ Export และจำนวนไฟล์ที่เก็บได้

จึง Clear Experts และเริ่ม Script รอบถัดไป

Experts และ Journal เก็บแยกกันที่ MQL5/Logs และ Logs ตามลำดับ ซึ่ง Script จะอ่านทั้งสองตำแหน่งครับ

4. ส่งอะไรให้ผมตรวจ
เริ่มส่งชุดเล็กนี้ก่อน:

text
Experts.session.txt
Journal.session.txt
metadata.json
ภาพ Inputs / Trade / History ตามกรณี
CSV ที่เกี่ยวข้อง ถ้ามี
เก็บ raw_logs ไว้เป็นต้นฉบับสำรอง เพราะอาจมีข้อความจากก่อนเริ่มรอบหรือจาก EA อื่น ไม่ต้องส่งทั้งหมดทันที และควรตรวจข้อมูลบัญชีหรือข้อมูลส่วนตัวก่อนแชร์

Script ไม่เก็บภาพหน้าจอ, History Report หรือ Global Variables ให้อัตโนมัติ และไม่สร้างข้อความที่ EA ไม่เคย Log ไว้ ดังนั้นยังไม่ใช่เครื่องมือ Telemetry แบบครบทุกเหตุการณ์ แต่ช่วยรวมหลักฐานที่มีอยู่และแยกแต่ละ Preset/Magic ได้โดยไม่เปลี่ยน EA ครับ

ผมยังไม่ได้ทดสอบ Script นี้กับไฟล์ Log ในเครื่องคุณ จึงให้ทดลองเก็บรอบแรกกับ Preset 01 ก่อน หากอ่าน Log ไม่ได้หรือไม่มีข้อมูล ให้ตรวจ Collector/Path ก่อน ไม่แก้ Logic การเทรดตามปัญหานั้นครับ