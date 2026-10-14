AUDIT_FUNCTION_INDEX — Hedge 1.0 MT5
Baseline: 9900a1e364b7aac01a8f6e3984ce451f34553259.

Scope: 1 main source + 8 include files. Project-defined function definitions: 100. Inputs file has no function definitions. Includes and project-level direct call relationships are indexed here; Native MQL5 APIs are not counted as project functions. This index records source structure, not executed runtime evidence.

Direct callers/callees use IDs in this document. A call in a conditional branch remains a potential source call; it does not prove the branch ran. A dash means no direct project caller/callee identified within these nine files, not proof the function should be deleted.

INPUTS — include/Hedge1_Inputs.mqh
No functions (0). Defines inputs and ENUM_BE_MODE: BE_OFF=0, BE_FIXED=1, BE_TRAILING=2. InpStateImportLegacy is here; InpTrailImportLegacy is declared in Protect, so do not count it as a function or duplicate it.

MAIN — Hedge1.0.mq5
ไฟล์เจ้าของ: EA_Hegde/Hedge1.0.mq5

Direct includes: include/Hedge1_Inputs.mqh, include/Hedge1_Utils.mqh, include/Hedge1_Capital.mqh, include/Hedge1_Session.mqh, include/Hedge1_Engine.mqh, include/Hedge1_Protect.mqh, include/Hedge1_Panel.mqh, include/Hedge1_Report.mqh

นิยามฟังก์ชัน: 4 ตัว

ID	Signature	หน้าที่	Direct callers	Direct project callees
MAIN-01	int OnInit()	ตรวจ Inputs และเริ่มโมดูล	MT5 event dispatcher	PRO-04, UTIL-02, ENG-01, REP-02, UI-17, UTIL-03
MAIN-02	void OnDeinit(const int reason)	Flush State และลบ Panel	MT5 event dispatcher	UI-21
MAIN-03	void OnTick()	Protect → Report → Engine → Panel	MT5 event dispatcher	PRO-16, ENG-02, REP-08, ENG-17, UI-19
MAIN-04	void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)	ส่ง Event ให้ Panel	MT5 event dispatcher	UI-20
UTIL — include/Hedge1_Utils.mqh
ไฟล์เจ้าของ: EA_Hegde/include/Hedge1_Utils.mqh

Direct includes: Hedge1_Inputs.mqh

นิยามฟังก์ชัน: 8 ตัว

ID	Signature	หน้าที่	Direct callers	Direct project callees
UTIL-01	string HedgeStateGVName(string suffix)	สร้าง Key เงิน/Report/Cycle	UTIL-02, CAP-01, ENG-13, UI-14, REP-01	—
UTIL-02	bool HedgeStateInit()	ตรวจ/นำเข้า State ตามสิทธิ์	MAIN-01	UTIL-01
UTIL-03	double HedgePoint()	หน่วยราคาตาม Point Digits	MAIN-01, UTIL-04, UTIL-05, ENG-03, PRO-13	—
UTIL-04	double PointsToPrice(double points)	แปลง Points เป็นระยะราคา	ENG-03, PRO-16	UTIL-03
UTIL-05	double PriceToPoints(double priceDiff)	แปลงระยะราคาเป็น Points	UTIL-06	UTIL-03
UTIL-06	double GetSpreadPoints()	อ่าน Spread ในหน่วย EA	ENG-15, ENG-16, UI-19	UTIL-05
UTIL-07	string FormatMoney(double v)	จัดข้อความยอดเงิน	UI-19, REP-07	—
UTIL-08	string FormatPoints(double pts)	จัดข้อความระยะ Points	UI-19	—
CAP — include/Hedge1_Capital.mqh
ไฟล์เจ้าของ: EA_Hegde/include/Hedge1_Capital.mqh

Direct includes: Hedge1_Inputs.mqh, Hedge1_Utils.mqh

นิยามฟังก์ชัน: 12 ตัว

ID	Signature	หน้าที่	Direct callers	Direct project callees
CAP-01	string RefillGVName()	Key ของยอด REFILL	CAP-04, CAP-06	UTIL-01
CAP-02	bool TryGetClosedNet(double &net)	อ่าน Net พร้อมสถานะสำเร็จ	CAP-03, CAP-07, ENG-13, UI-14, UI-19	—
CAP-03	double GetClosedNet()	Wrapper Net; error คืน 0	—	CAP-02
CAP-04	bool TryGetTotalRefill(double &total)	อ่าน REFILL พร้อมสถานะ	CAP-05, CAP-06, CAP-07	CAP-01
CAP-05	double GetTotalRefill()	Wrapper REFILL; error คืน 0	—	CAP-04
CAP-06	bool AddRefill()	เติมและบันทึกทุนเสมือน	UI-20	CAP-04, CAP-01
CAP-07	bool TryGetVirtualEquity(double &equity)	อ่านทุนเสมือนพร้อมสถานะ	CAP-08, CAP-11, CAP-12, ENG-14, ENG-15, UI-19, UI-20	CAP-04, CAP-02
CAP-08	double GetVirtualEquity()	Wrapper Equity; error คืน 0	—	CAP-07
CAP-09	double NormalizeVolume(double lot)	ตรวจ/ปรับ Volume ตาม Symbol	CAP-10	—
CAP-10	double GetEffectiveLotForEquity(double equity)	คำนวณ Lot จากทุนที่ตรวจแล้ว	CAP-11, ENG-14, UI-19	CAP-09
CAP-11	double GetEffectiveLot()	อ่านทุนแล้วคำนวณ Lot	ENG-01, ENG-16	CAP-07, CAP-10
CAP-12	bool IsCapitalDead()	ทุนหมด/อ่านไม่ได้คืน true	—	CAP-07
SES — include/Hedge1_Session.mqh
ไฟล์เจ้าของ: EA_Hegde/include/Hedge1_Session.mqh

Direct includes: Hedge1_Inputs.mqh

นิยามฟังก์ชัน: 6 ตัว

ID	Signature	หน้าที่	Direct callers	Direct project callees
SES-01	int ParseTimeToMinutes(string hhmm)	ตรวจ HH:MM และแปลงเป็นนาที	SES-04	—
SES-02	int CurrentServerMinutes()	นาทีปัจจุบันตาม Server	SES-05	—
SES-03	bool IsInWindow(int nowMin, int startMin, int endMin)	ตรวจช่วงปกติ/ข้ามเที่ยงคืน	SES-05	—
SES-04	bool GetSessionWindow(int idx, bool enabled, string startStr, string endStr, bool &isActive, int &startMin, int &endMin)	ตรวจหนึ่ง Session; เตือนเวลาผิด	SES-05	SES-01
SES-05	bool IsAutoBlockedBySession()	ตรวจ Session ทั้งสาม	SES-06, ENG-15	SES-02, SES-04, SES-03
SES-06	string GetSessionStatusText()	ข้อความ OPEN/BLOCK	UI-19	SES-05
ENG — include/Hedge1_Engine.mqh
ไฟล์เจ้าของ: EA_Hegde/include/Hedge1_Engine.mqh

Direct includes: Hedge1_Inputs.mqh, Hedge1_Capital.mqh, Hedge1_Session.mqh, Hedge1_Utils.mqh

นิยามฟังก์ชัน: 25 ตัว

ID	Signature	หน้าที่	Direct callers	Direct project callees
ENG-01	void EngineInit()	ตั้ง Ready และ Log Lot	MAIN-01	CAP-11
ENG-02	int CountSide(ENUM_POSITION_TYPE type)	นับ Position ตามฝั่งใน Scope	MAIN-03, ENG-11, ENG-12, ENG-14, ENG-17, UI-19, REP-08	—
ENG-03	bool OpenOneOrder(ENUM_POSITION_TYPE dir, double lot, string tag)	ส่ง Order หนึ่งฝั่งพร้อม SL	ENG-14	ENG-04, UTIL-04, UTIL-03
ENG-04	ENUM_ORDER_TYPE_FILLING GetSymbolFilling()	เลือก Filling จาก Symbol flags	ENG-03, ENG-06	—
ENG-05	bool IsTradeRetcodeDone(uint retcode)	ตรวจ retcode DONE	ENG-06, ENG-07	—
ENG-06	bool RawPositionClose(ulong ticket, string tag)	ส่งปิดด้วย Ticket; ตรวจ retcode	ENG-08, PRO-14	ENG-04, ENG-05
ENG-07	bool RawPositionModify(ulong ticket, double newSL, double keepTP, string tag)	ส่ง SLTP; คง TP; ตรวจ retcode	PRO-15	ENG-05
ENG-08	int CloseOneSide(ENUM_POSITION_TYPE dir, string tag)	ปิด Position ฝั่งที่ระบุ	ENG-12, ENG-21, ENG-22, ENG-23	ENG-06
ENG-09	double GetSideVolume(ENUM_POSITION_TYPE dir)	รวม Volume ของฝั่ง	ENG-11, ENG-14	—
ENG-10	bool IsLotMatched(double actualLot, double expectedLot)	เทียบ Lot ด้วย tolerance	ENG-11	—
ENG-11	bool IsExactHedgePair(double expectedLot)	ตรวจ Buy1/Sell1 และ Lot	ENG-14	ENG-02, ENG-09, ENG-10
ENG-12	bool RollbackHedgePair()	ปิดคู่ที่เปิดไม่ครบ/ผิด Volume	ENG-14	ENG-02, ENG-08
ENG-13	bool BeginBasketCycle()	บันทึกฐานก่อน Order แรก	ENG-14	CAP-02, UTIL-01
ENG-14	bool OpenHedgePair()	Gate → เปิดคู่ → Verify/Rollback	ENG-16, ENG-20	ENG-02, CAP-07, CAP-10, ENG-13, ENG-03, ENG-11, ENG-09, ENG-12
ENG-15	bool CanOpenAuto(datetime sinceTime, string &reason)	ตรวจ Report/ทุน/Session/เวลา/Spread	ENG-16	CAP-07, SES-05, UTIL-06
ENG-16	void TryOpenNewRound()	Auto/Cooldown/Gates ก่อนเปิด	ENG-17	ENG-15, UTIL-06, CAP-11, ENG-14
ENG-17	void EngineOnTick()	เปิดรอบใหม่เฉพาะ Basket ว่าง	MAIN-03	ENG-02, ENG-16
ENG-18	bool ManualBuy()	Block การเปิด Buy เดี่ยว	UI-20	—
ENG-19	bool ManualSell()	Block การเปิด Sell เดี่ยว	UI-20	—
ENG-20	bool ManualHedge()	เรียก Guard กลางเปิดคู่	UI-20	ENG-14
ENG-21	bool ManualCloseBuy()	สั่งปิดฝั่ง Buy	UI-20	ENG-08
ENG-22	bool ManualCloseSell()	สั่งปิดฝั่ง Sell	UI-20	ENG-08
ENG-23	bool ManualCloseAll()	สั่งปิดทั้งสองฝั่งใน Scope	UI-20	ENG-08
ENG-24	int GetTimeoutRemaining()	คำนวณเวลารอที่เหลือ	UI-19	—
ENG-25	string GetEngineGateText()	คืน g_gateReason	—	—
PRO — include/Hedge1_Protect.mqh
ไฟล์เจ้าของ: EA_Hegde/include/Hedge1_Protect.mqh

Direct includes: Hedge1_Inputs.mqh, Hedge1_Engine.mqh, Hedge1_Utils.mqh

นิยามฟังก์ชัน: 16 ตัว

ID	Signature	หน้าที่	Direct callers	Direct project callees
PRO-01	string TrailGVPrefix()	Namespace ของ Trail State	PRO-02, PRO-04, PRO-12	—
PRO-02	string TrailGVName(ulong ticket)	Key ของ Ticket	PRO-05, PRO-06, PRO-07	PRO-01
PRO-03	string TrailLegacyGVName(ulong ticket)	Key รุ่นเก่าสำหรับนำเข้า	PRO-05	—
PRO-04	bool ProtectInit()	ตรวจ Account/ความยาว Key	MAIN-01	PRO-01
PRO-05	double TrailLoadBest(ulong ticket, bool &found)	อ่าน Best/นำเข้าแบบ opt-in	PRO-09, PRO-16	PRO-02, PRO-03
PRO-06	bool TrailSaveBest(ulong ticket, double bestPts)	ตรวจ/Save Best และ Flush	PRO-09	PRO-02
PRO-07	void TrailDeleteBest(ulong ticket)	ลบ Persistent Trail Key	PRO-10	PRO-02
PRO-08	int TrailFind(ulong ticket)	ค้น index ใน g_trail	PRO-09, PRO-10, PRO-16	—
PRO-09	void TrailUpsert(ulong ticket, double profitPts)	Restore/เพิ่ม Best/บันทึก	PRO-16	PRO-08, PRO-05, PRO-06
PRO-10	void TrailRemove(ulong ticket)	ลบ Track และ Persistent Key	PRO-12, PRO-16	PRO-08, PRO-07
PRO-11	bool TrailConfirmedClosed(ulong ticket)	ยืนยันปิดครบจากประวัติ	PRO-12	—
PRO-12	void TrailCleanup()	เก็บกวาด State ที่ยืนยันได้	PRO-16	PRO-11, PRO-10, PRO-01
PRO-13	double GetProfitPoints(ENUM_POSITION_TYPE dir, double entry)	ระยะกำไร Buy-Bid/Sell-Ask	PRO-16	UTIL-03
PRO-14	bool ClosePositionByTicket(ulong ticket, string reason)	Wrapper ปิด Position	PRO-16	ENG-06
PRO-15	bool ModifySL(ulong ticket, double newSL, double keepTP, string tag)	Wrapper แก้ SL/คง TP	PRO-16	ENG-07
PRO-16	void ProtectOnTick()	Cut Loss → RR → Trail → BE	MAIN-03	PRO-12, PRO-13, UTIL-04, PRO-15, PRO-14, PRO-10, PRO-08, PRO-05, PRO-09
UI — include/Hedge1_Panel.mqh
ไฟล์เจ้าของ: EA_Hegde/include/Hedge1_Panel.mqh

Direct includes: Hedge1_Inputs.mqh, Hedge1_Capital.mqh, Hedge1_Session.mqh, Hedge1_Engine.mqh, Hedge1_Protect.mqh, Hedge1_Utils.mqh

นิยามฟังก์ชัน: 21 ตัว

ID	Signature	หน้าที่	Direct callers	Direct project callees
UI-01	string PName(string id)	ชื่อ Object ด้วย H1P_ prefix	UI-06, UI-07, UI-08, UI-10, UI-11, UI-15, UI-16, UI-20	—
UI-02	int PanelChartWidth()	อ่านความกว้างกราฟ	UI-04	—
UI-03	bool PanelIsMinimized()	สถานะย่อของ Panel	UI-15	—
UI-04	bool PanelRefreshLayoutMetrics()	คำนวณ Layout และตรวจเปลี่ยน	UI-16, UI-18	UI-02
UI-05	void PanelDeleteObjects()	ลบ Object ตาม Panel prefix	UI-16, UI-21	—
UI-06	void PanelLabel(string id, string text, int x, int y, color clr, int fontSize = 8, string font = "Arial Bold")	สร้าง/อัปเดต Label	UI-16	UI-01
UI-07	void PanelFrame(string id, int x, int y, int w, int h, color frameColor)	สร้างกรอบปุ่ม	UI-16	UI-01
UI-08	void PanelButton(string id, string text, int x, int y, int w, int h, color bg, color border, int fontSize = 9)	สร้าง/อัปเดต Button	UI-16	UI-01
UI-09	color PanelSignColor(double value)	สีบวก/ลบ/ศูนย์	UI-19	—
UI-10	void PanelSet(string id, string text, color clr)	อัปเดตข้อความและสี Label	UI-19	UI-01
UI-11	void PanelSetVisible(string id, bool show)	แสดง/ซ่อน Object	UI-15	UI-01
UI-12	string PanelFooterText()	จัด Comment เป็น Footer	UI-16	—
UI-13	double GetFloatingPL()	รวม floating Profit+Swap ใน Scope	UI-19	—
UI-14	bool TryGetCycleLoss(double &loss)	อ่านฐาน/Net; ไม่เขียน State	UI-19	UTIL-01, CAP-02
UI-15	void PanelApplyVisibility()	ใช้สถานะย่อกับ Objects	UI-16, UI-20	UI-03, UI-11, UI-01
UI-16	void PanelBuild()	ประกอบ Panel/ปุ่มทั้งหมด	UI-17, UI-18	UI-05, UI-04, UI-01, UI-06, UI-08, UI-07, UI-12, UI-15, UI-19
UI-17	void PanelInit()	เริ่ม Panel	MAIN-01	UI-16
UI-18	void PanelCheckResponsiveLayout()	Rebuild เมื่อ Layout เปลี่ยน	UI-20	UI-04, UI-16
UI-19	void PanelUpdate()	อ่านข้อมูลและแสดงผล	MAIN-03, UI-16, UI-20	SES-06, UI-10, UTIL-06, ENG-24, CAP-07, CAP-10, UI-09, CAP-02, UTIL-07, UI-14, UI-13, ENG-02, UTIL-08
UI-20	void PanelOnChartEvent(int id, long lparam, double dparam, string sparam)	รับปุ่ม/resize และ dispatch	MAIN-04	UI-18, UI-19, UI-01, ENG-18, ENG-19, ENG-21, ENG-22, ENG-23, ENG-20, CAP-06, CAP-07, UI-15
UI-21	void PanelDeinit()	ลบ Panel เมื่อหยุด	MAIN-02	UI-05
REP — include/Hedge1_Report.mqh
ไฟล์เจ้าของ: EA_Hegde/include/Hedge1_Report.mqh

Direct includes: Hedge1_Inputs.mqh, Hedge1_Capital.mqh, Hedge1_Engine.mqh, Hedge1_Utils.mqh

นิยามฟังก์ชัน: 8 ตัว

ID	Signature	หน้าที่	Direct callers	Direct project callees
ID	Signature	หน้าที่	Direct callers	Direct project callees
REP-01	string ReportGVName()	Key RPD	REP-02, REP-08	UTIL-01
REP-02	void ReportInit()	เริ่ม State/ตรวจ Report due	MAIN-01	REP-01
REP-03	bool ReportWriteRow(int fh, string a, string b, string c, string d, string e, ulong &expectedBytes)	เขียน/ตรวจ bytes หนึ่งแถว	REP-07	—
REP-04	void ReportAbortTemp(int fh, string tempName, string stage)	Log/ปิด/ลบ Temp เมื่อ abort	REP-07	—
REP-05	bool ReportReadRow(int fh, string &fields[])	อ่าน CSV แถวละห้า fields	REP-06	—
REP-06	bool ReportReadCompletion(string fname, datetime periodStart, datetime &savedEnd)	ตรวจ Header/TOTAL/Marker/Identity	REP-07	REP-05
REP-07	bool GenerateReportCSV(datetime periodStart, datetime &periodEnd)	สร้าง CSV หรือ Recover End เดิม	REP-08	REP-06, REP-03, REP-04, UTIL-07
REP-08	void ReportOnTick()	Report due/flat/retry และ Gate	MAIN-03	ENG-02, REP-01, REP-07
