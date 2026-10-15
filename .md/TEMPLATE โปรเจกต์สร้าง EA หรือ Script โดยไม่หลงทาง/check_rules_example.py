"""ตัวอย่างตัวตรวจกฎจาก Journal (MT5) - เริ่มต้นสำหรับ Hedge1.4 Short Test
ค่าราคาแปลงเป็นจำนวนเต็ม Points (XAUUSD: 1 Point = 0.01) เพื่อเลี่ยงปัญหาทศนิยม
"""
import re, sys, json

POINT = 0.01
CUT_LOSS_PTS = 70      # R-CUT-01
LOCK_STEP_PTS = 2      # R-BE-02: 20% ของ Step 10 Points = 2 Points
MIN_LOCK_PTS = 24      # R-BE-02: กำไร 120 -> ล็อก 24

RE_FILL = re.compile(r"order #(\d+) (buy|sell) [\d.]+ / [\d.]+ (\w+) at ([\d.]+) done")
RE_MOD  = re.compile(r"modify #(\d+) (buy|sell) [\d.]+ (\w+) -> sl: ([\d.]+), tp: [\d.]+ done")
RE_TIME = re.compile(r"^\w{2}\d(\d{2}:\d{2}:\d{2}\.\d{3})")

def pts(x): return round(float(x) / POINT)

def parse(lines):
    fills, mods = {}, {}
    for ln in lines:
        t = RE_TIME.match(ln); t = t.group(1) if t else "?"
        m = RE_FILL.search(ln)
        if m:
            fills[m[1]] = dict(side=m[2], fill=pts(m[4]), t=t)
            continue
        m = RE_MOD.search(ln)
        if m:
            mods.setdefault(m[1], []).append(dict(sl=pts(m[4]), t=t, line=ln.strip()))
    return fills, mods

def check(lines):
    fills, mods = parse(lines)
    results = []
    for tk, f in fills.items():
        seq = mods.get(tk, [])
        sign = 1 if f["side"] == "buy" else -1          # buy: SL ต่ำกว่า Fill, sell: สูงกว่า
        if not seq:
            continue
        # R-CUT-01: การปรับ SL ครั้งแรกหลัง Fill ต้องเท่ากับ Fill -/+ 70 Points
        exp = f["fill"] - sign * CUT_LOSS_PTS
        first = seq[0]
        results.append(("R-CUT-01", tk, f["side"], first["sl"] == exp,
                        f"คาดหวัง {exp} จริง {first['sl']}", first["line"]))
        # R-BE-01: SL ห้ามขยับไปทางเสี่ยงกว่าเดิม
        for a, b in zip(seq, seq[1:]):
            ok = (b["sl"] - a["sl"]) * sign >= 0
            results.append(("R-BE-01", tk, f["side"], ok,
                            f"{a['sl']} -> {b['sl']}", b["line"]))
        # R-BE-02: เมื่อ SL ผ่านราคาเข้าไปฝั่งกำไร ล็อกต้องเป็นผลคูณของ 2 Points และ >= 24
        for m in seq:
            lock = (m["sl"] - f["fill"]) * sign
            if lock > 0:
                ok = lock % LOCK_STEP_PTS == 0 and lock >= MIN_LOCK_PTS
                results.append(("R-BE-02", tk, f["side"], ok, f"lock={lock}", m["line"]))
    return results

if __name__ == "__main__":
    lines = open(sys.argv[1], encoding="utf-8", errors="ignore").read().splitlines()
    res = check(lines)
    bad = [r for r in res if not r[3]]
    print(json.dumps({"checked": len(res), "failed": len(bad)}, ensure_ascii=False))
    for r in bad:
        print("FAIL", r[:5]); print("   หลักฐาน:", r[5])