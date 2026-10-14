BASELINE MANIFEST — Hedge 1.0 MT5 (แก้ไขครั้งที่ 2)
วันที่จัดทำ: 14 ตุลาคม 2026 (อัปเดตหลังตรวจ Commit 18c4769)

เอกสารนี้ระบุ Source Baseline และ Hash ที่ตรวจไว้ ใช้คู่กับ HANDOFF_Hedge1_Phase4.md

1. ข้อมูลโปรเจกต์
Project: Hedge 1.0 MT5

Repository: vhpknn/EA_4_Hegde_Buy_Sell_Both

URL: https://github.com/vhpknn/EA_4_Hegde_Buy_Sell_Both

Branch: audit/phase-2-3-trailing-restart-strict-basket

โฟลเดอร์ในขอบเขต: EA_Hegde

ห้ามเปลี่ยนการสะกด Hegde ใน Path โดยพลการ

2. Commit ที่เกี่ยวข้อง
บทบาท	Short SHA	Full SHA	Commit message
Logic Baseline	9900a1e	9900a1e364b7aac01a8f6e3984ce451f34553259	EA_Hegde_Phase 4 complete - final audit fixes
Test Source (ใช้ Compile และทดสอบ)	18c4769	18c47690e00772643f17c43e90ad37c4e21943f3	EA_Hegde_ปิดงาน Phase 4
ก่อน Final Audit Fixes	393d9a0	393d9a0e8266fc268e83aea88b75431426b43446	EA_Hegde_Phase 4F
Commit 18c4769 แก้เฉพาะ Comment และเอกสาร ไม่เปลี่ยน Logic
(ไฟล์ที่เปลี่ยน: Hedge1.0.mq5 [Comment หัวไฟล์], Hedge1_Report.mqh [Comment หัวไฟล์],
.md/error.txt, EA_Hegde/.md/Phase ที่เหลือ.md [เพิ่มใหม่])

3. สถานะการยืนยัน
รายการ	สถานะ
ผู้ใช้รายงาน Compile	0 errors / 0 warnings
ตรวจ Diff สามจุดสุดท้าย	ตรวจที่ Commit 9900a1e
ตรวจ Diff 18c4769	ตรวจแล้ว: Comment/เอกสารเท่านั้น
เทียบ Git blob SHA ของ 18c4769 กับ Manifest	ตรง 7 จาก 9 ไฟล์; 2 ไฟล์ต่างเฉพาะ Comment
Short Test	ยังไม่มีผล
Long Run ข้ามวัน	ยังไม่มีผล
Source/Binary equivalence	ไม่ได้ตรวจพิสูจน์โดยอิสระ
Production approval	ยังไม่มี
Zero-bug guarantee	ไม่มี
Compile ผ่านไม่เท่ากับ Runtime ผ่าน / Hash ตรงไม่เท่ากับทุกพฤติกรรมถูกต้อง

4. ชนิดของ Hash
เป็น Git blob SHA จาก GitHub get_file_contents ไม่ใช่ SHA ของ Commit, SHA256, MD5
ห้ามนำ SHA256/MD5 ในเครื่องมาเทียบตรง ๆ ถ้าไม่ตรงให้ตรวจ Diff จริงก่อน

5. Source Manifest — 9 ไฟล์
Repository Path	Git blob @9900a1e	Git blob @18c4769 (Test Source)	สถานะ
EA_Hegde/Hedge1.0.mq5	d33b626ef7317da55ceba7266c13eafce26cbfc3	fabae9eb4eb5b2548d80881d9df7c007c405e79e	Comment-only
include/Hedge1_Inputs.mqh	805aa8032a6ceba3cf554b8392e5042ac1b70b5e	805aa8032a6ceba3cf554b8392e5042ac1b70b5e	เท่าเดิม
include/Hedge1_Utils.mqh	a720582aad0711a01d8bbe9ea7efa5846ceeebf6	a720582aad0711a01d8bbe9ea7efa5846ceeebf6	เท่าเดิม
include/Hedge1_Capital.mqh	74762fb076332fb6da7a00b9974e52632c3882c9	74762fb076332fb6da7a00b9974e52632c3882c9	เท่าเดิม
include/Hedge1_Session.mqh	d3fba4cbeccb1cdeab41e99e78a68b1ee5df4d9b	d3fba4cbeccb1cdeab41e99e78a68b1ee5df4d9b	เท่าเดิม
include/Hedge1_Engine.mqh	9df7a9646c26c98f9c3ab9e44fa3c5ac0758f20e	9df7a9646c26c98f9c3ab9e44fa3c5ac0758f20e	เท่าเดิม
include/Hedge1_Protect.mqh	74c91fc2bfe09748cbbea72aa595c9133606086f	74c91fc2bfe09748cbbea72aa595c9133606086f	เท่าเดิม
include/Hedge1_Panel.mqh	6ce9e3199c192abf6a4de73dcd7154812fe81222	6ce9e3199c192abf6a4de73dcd7154812fe81222	เท่าเดิม
include/Hedge1_Report.mqh	3794aeea008651ac87ccc3505dbf519c9cadfba1	b28eab494d4cbe808ee4b1b30bdf0e60f197f1ab	Comment-only
หมายเหตุ: Hash ของ Hedge1.0.mq5 @9900a1e และ Report @9900a1e ยกมาจาก Manifest ฉบับเดิม
Hash @18c4769 ได้จาก GitHub โดยตรง

6. Binary Reference — ไม่ใช่ Source สำหรับแก้ไข
Path: EA_Hegde/Hedge1.0.ex5

Git blob SHA ที่บันทึกไว้ (Manifest เดิม): 864c5c99dbbc0d1210455c2c0bd4d7c5e3cf3a21

ยังไม่ได้ตรวจซ้ำที่ 18c4769 และไม่ได้พิสูจน์ Source/Binary equivalence

ต้องอ่าน .mq5 และ .mqh เป็นฐานเสมอ ไม่ใช้ .ex5 อย่างเดียว

7. สามจุดแก้ Final Audit (Commit 9900a1e)
7.1 Capital — Hedge1_Capital.mqh
ก่อน b459e53d3b274508d02b82b44f5086d2e2e0df9a → หลัง 74762fb076332fb6da7a00b9974e52632c3882c9

ตรวจผลอ่าน DEAL_MAGIC, DEAL_SYMBOL, DEAL_PROFIT, DEAL_SWAP, DEAL_COMMISSION และค่าตัวเลขก่อนรวมยอด

อ่านไม่ได้ให้คืน false ไม่ยอมรับ 0 เป็นยอดสุทธิจริง

นิยามยอดสุทธิไม่เปลี่ยน: Profit + Swap + Commission ของ Symbol + Magic

7.2 Engine — Hedge1_Engine.mqh
ก่อน b21c6d0f4646f9d1e93c973571bd4d002fe8ea24 → หลัง 9df7a9646c26c98f9c3ab9e44fa3c5ac0758f20e

หลัง Rollback รอบสุดท้ายตรวจจำนวน Position อีกครั้ง; Buy 0 และ Sell 0 คืน true ไม่แจ้ง CRITICAL ผิด

OpenHedgePair ยังคืน false สำหรับการเปิดคู่ที่ล้มเหลว

7.3 Protect — Hedge1_Protect.mqh
ก่อน 36abe4327ed14f2a27a39f703cedd09892380262 → หลัง 74c91fc2bfe09748cbbea72aa595c9133606086f

SL เป็น 0 เข้าบล็อกติดตั้ง Cut Loss SL ได้แม้กำไรเลย BE Trigger

ยังตรวจ cutSLDifferent และ cutSLImproves ไม่คลาย SL เดิม

ไม่เปลี่ยนสูตร Cut Loss, BE, RR, Trailing

8. Comment-only edits (ยืนยันแล้ว)
Commit 18c4769 มี Comment-only edits ตามที่เสนอไว้ทั้งสองจุด:

Hedge1.0.mq5: หัวไฟล์ระบุลำดับ Protect → Report → Engine → Panel

Hedge1_Report.mqh: หัวไฟล์ระบุชื่อรายงาน Symbol_Account_Magic_FROM_PeriodStart.csv

ตรวจ Diff แล้วว่าต่างเฉพาะ Comment จึงไม่ต้องย้อนทิ้งเพื่อให้ Hash ตรง
และตรวจ OnTick ใน Hedge1.0.mq5 แล้วว่าลำดับเรียกจริงตรงกับ Comment

9. main
ตอนตรวจครั้งก่อน main อยู่ที่ 45dded382331f8f8468abc7c0298dde057354cb6 ซึ่งเก่ากว่า Baseline
เป็นสถานะ ณ เวลานั้น ไม่ใช่การรับรองว่ายังอยู่ที่เดิม

10. กติกาตรวจ Source ก่อนทำงาน
อ่าน HANDOFF_Hedge1_Phase4.md

อ่าน Source ทั้ง 9 ไฟล์จาก Test Source (18c4769) หรือ Working Copy ที่ผู้ใช้ยืนยัน

ตรวจว่า Source ที่อ่านกับไฟล์ที่ผู้ใช้ Compile อยู่ในชุดเดียวกัน

ตรวจ Diff เฉพาะเมื่อมีการเปลี่ยนหรือสถานะคลาดเคลื่อน

ไม่อ่าน main เก่าแล้วสรุปว่า Patch ในเครื่องผู้ใช้หาย

ไม่ส่ง FIND จาก Source คนละรุ่น

ไม่ขอ Source ทั้งชุดซ้ำทุก Patch ย่อย

หาก Source ใหม่กว่า 18c4769 ให้ระบุ Commit/ไฟล์ที่ใช้จริงและตรวจการเปลี่ยนแปลงก่อน

ไม่ประกาศ Production-ready จาก Hash หรือ Compile เพียงอย่างเดียว

11. ขั้นตอนถัดไปที่อนุมัติไว้
ยังไม่เพิ่มกลยุทธ์ใหม่ งานถัดไป: เตรียมชุดทดสอบ (Spec Symbol Demo, Spread/Bid/Ask,
Magic Short/Long ที่ไม่เคยใช้, Preset .set, Checklist/หลักฐาน) → Short Test รวม →
Long Run ข้ามวัน → ตรวจผลรวม ห้ามย้อนไปสั่ง Market Test หลังทุก Patch

12. เอกสารร่วมชุด
HANDOFF_Hedge1_Phase4.md, BASELINE_MANIFEST_Hedge1.md, START_PROMPT_NEXT_AI.md,
CONSOLIDATED_TEST_PLAN.md, TEST_CHECKLIST_Hedge1.md
เอกสารทั้งชุดไม่แทน Source Code