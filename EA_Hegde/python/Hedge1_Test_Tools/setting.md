ได้ครับ ทำเป็น **Config + เมนูตัวเลข** ได้เลยครับ ตั้ง Path ครั้งเดียว หลังจากนั้นใช้แบบนี้:

```text
ดับเบิลคลิก run.bat
→ กดหมายเลข Preset
→ ตรวจ Path / Symbol / Magic
→ กด 1 ยืนยันเริ่มเก็บ
→ ทำการทดสอบใน MT5
→ กลับมากด Enter เพื่อ Export
```

รอบนี้แก้เฉพาะเครื่องมือเก็บ Log ไม่แก้ EA และใช้ `run.bat` เดิมได้ครับ

## 1. โครงสร้างโฟลเดอร์

จัดไฟล์แบบนี้:

```text
Hedge1_Test_Tools/
├── run.bat
├── Hedge1_CollectSession.py
├── collector_config.json
└── Presets/
    ├── SHORT_01_MANUAL.set
    ├── SHORT_02_CUT.set
    └── ...
```

ถ้า Preset อยู่ที่อื่นอยู่แล้ว ไม่จำเป็นต้องย้าย แค่ระบุ Path ของโฟลเดอร์นั้นใน Config

## 2. สร้าง `collector_config.json`

วางไว้ข้าง `Hedge1_CollectSession.py` แล้วใส่:

```json
{
  "mt5_data_folder": "C:/YOUR_MT5_DATA_FOLDER",
  "preset_folder": "./Presets",
  "symbol": "XAUUSD",
  "preset_pattern": "SHORT_*.set"
}
```

แก้ค่าดังนี้:

| ค่า | ใส่อะไร |
|---|---|
| `mt5_data_folder` | Path ที่ได้จาก MT5 → File → Open Data Folder |
| `preset_folder` | โฟลเดอร์ที่เก็บ `.set` |
| `symbol` | `XAUUSD` |
| `preset_pattern` | คง `SHORT_*.set` เพื่อแสดงเฉพาะ Short Test |

ใช้ `/` ใน Path ตามตัวอย่างได้ และไม่ใส่ Comment ในไฟล์ JSON ส่วน `./Presets` ในโค้ดใหม่นี้จะอ้างอิงจากโฟลเดอร์ของ Python Script ไม่ใช่โฟลเดอร์ที่เปิด Terminal ครับ การอ่าน JSON และค้นไฟล์ตาม Pattern ใช้ Standard Library ของ Python ไม่ต้องติดตั้งแพ็กเกจเพิ่ม [docs.python](https://docs.python.org/3/library/pathlib.html)

ตัวอย่างกรณี Preset อยู่คนละไดรฟ์:

```json
{
  "mt5_data_folder": "C:/Users/YOUR_NAME/AppData/Roaming/MetaQuotes/Terminal/YOUR_TERMINAL_ID",
  "preset_folder": "D:/YourProject/Set_File",
  "symbol": "XAUUSD",
  "preset_pattern": "SHORT_*.set"
}
```

Path ข้างบนเป็นตัวอย่าง ต้องเปลี่ยนเป็น Path จริงของคุณครับ

## 3. แก้ Python — เพิ่มเมนูและอ่าน Config

ไฟล์: `Hedge1_CollectSession.py`

สำรองไฟล์เดิมไว้ก่อน แล้วแก้ตามสองบล็อกนี้ ไม่ต้องเปลี่ยนส่วนเก็บ Log ด้านล่าง

### จุดที่ 1 — แทนส่วนถาม Path ด้วย Config และเมนู

FIND:

```python
def main():
    print("Hedge1 - Session Evidence Collector")
    print("Read-only access to MT5 files. No trade commands.\n")

    terminal = ask_path("MT5 Data Folder: ")
    preset = ask_path("Preset .set file: ")
    symbol = input("Symbol [XAUUSD]: ").strip() or "XAUUSD"
```

REPLACE:

```python
def select_session_from_config():
    script_dir = Path(__file__).resolve().parent
    config_path = script_dir / "collector_config.json"
    config = json.loads(config_path.read_text(encoding="utf-8-sig"))

    if not isinstance(config, dict):
        raise ValueError("Config must be a JSON object.")

    def config_path_value(key):
        value = config.get(key, "")

        if not isinstance(value, str) or not value.strip():
            raise ValueError(f"Missing config value: {key}")

        path = Path(value).expanduser()

        if not path.is_absolute():
            path = script_dir / path

        return path.resolve()

    terminal = config_path_value("mt5_data_folder")
    preset_folder = config_path_value("preset_folder")
    symbol = config.get("symbol", "XAUUSD")
    pattern = config.get("preset_pattern", "SHORT_*.set")

    if not isinstance(symbol, str) or not symbol.strip():
        raise ValueError("Invalid symbol in config.")

    symbol = symbol.strip()

    if not isinstance(pattern, str) or not pattern.strip():
        raise ValueError("Invalid preset_pattern in config.")

    if not (terminal / "MQL5").is_dir():
        raise ValueError(f"Invalid MT5 Data Folder: {terminal}")

    if not preset_folder.is_dir():
        raise ValueError(f"Preset folder not found: {preset_folder}")

    presets = sorted(
        (p for p in preset_folder.glob(pattern) if p.is_file()),
        key=lambda p: p.name.lower()
    )

    if not presets:
        raise ValueError(f"No preset files match: {pattern}")

    print(f"MT5 Data Folder: {terminal}")
    print(f"Preset Folder  : {preset_folder}")
    print(f"Symbol         : {symbol}")
    print("\nSelect preset:")

    for number, path in enumerate(presets, 1):
        print(f"{number:2d}. {path.name}")

    print(" 0. Exit")

    while True:
        choice = input("Preset number: ").strip()

        if choice == "0":
            return None

        if not choice.isdigit() or not 1 <= int(choice) <= len(presets):
            print("Invalid selection. Try again.")
            continue

        preset = presets[int(choice) - 1]
        values = read_inputs(preset.read_bytes())
        magic = values.get("InpMagicNumber", "")

        if not magic.isdigit() or int(magic) <= 0:
            raise ValueError(f"Invalid Magic in preset: {preset.name}")

        match = re.match(
            r"SHORT_(\d{2})_",
            preset.name,
            re.IGNORECASE
        )

        if match and 1 <= int(match.group(1)) <= 16:
            expected = 99900 + int(match.group(1))

            if int(magic) != expected:
                raise ValueError(
                    f"Magic mismatch: {preset.name} has {magic}; "
                    f"expected {expected}. Fix the .set file first."
                )

        return terminal, preset, symbol


def main():
    print("Hedge1 - Session Evidence Collector")
    print("Read-only access to MT5 files. No trade commands.\n")

    selection = select_session_from_config()

    if selection is None:
        print("Cancelled.")
        return

    terminal, preset, symbol = selection
```

โค้ดนี้ใช้ `Path`, `json`, `re` และ `read_inputs()` ที่มีอยู่ใน Script เดิมแล้ว ไม่ต้องเพิ่ม Import ซ้ำ

### จุดที่ 2 — เปลี่ยนการยืนยันจาก START เป็นเลข 1

FIND:

```python
    if input("Type START to begin: ").strip().upper() != "START":
        print("Cancelled.")
        return
```

REPLACE:

```python
    print(f"MT5 Data Folder: {terminal}")
    print(f"Preset File    : {preset}")
    print("This selects an evidence label; it does not load the EA.")
    print("Confirm the same preset and Magic on the MT5 chart.")

    if input("1 = Start capture | 0 = Cancel: ").strip() != "1":
        print("Cancelled.")
        return
```

## 4. หน้าจอที่ได้

ตัวอย่าง:

```text
MT5 Data Folder: C:\...\Terminal\...
Preset Folder  : D:\...\Set_File
Symbol         : XAUUSD

Select preset:
 1. SHORT_01_MANUAL.set
 2. SHORT_02_CUT.set
 3. SHORT_03_BE_FIXED.set
 ...
16. SHORT_16_INVALID_PULLBACK.set
 0. Exit

Preset number: 1

Preset : SHORT_01_MANUAL.set
Symbol : XAUUSD
Magic  : 99901

1 = Start capture | 0 = Cancel: 1
```

หมายเลขเมนูเรียงตามชื่อไฟล์ที่พบ หากบางไฟล์ยังไม่มี หมายเลขเมนูอาจเลื่อนได้ ให้ตรวจชื่อไฟล์ที่แสดง ไม่จำหมายเลขอย่างเดียว

## 5. ป้องกันการใช้ Magic เก่าให้ด้วย

ก่อนเริ่ม Script จะตรวจตามตารางที่เราตกลง:

```text
SHORT_01_* → 99901
SHORT_02_* → 99902
...
SHORT_16_* → 99916
```

ถ้าไฟล์ยังเป็น `99999` จะหยุดพร้อมแจ้ง เช่น:

```text
Magic mismatch: SHORT_01_MANUAL.set has 99999;
expected 99901. Fix the .set file first.
```

Script ตรวจได้เฉพาะค่าในไฟล์ ไม่สามารถยืนยันว่า Magic นี้ไม่เคยใช้ หรือโหลดบนกราฟตรงกันแล้ว จึงยังต้องตรวจ Panel/Inputs ใน MT5 ก่อนเริ่มแต่ละรอบ

ผมทดสอบส่วนเมนูด้วยไฟล์จำลองแล้ว ทั้ง Path แบบ Relative, Preset UTF-16, เลือกหมายเลขผิด, ออกด้วย 0 และการปฏิเสธ Magic เก่า แต่ยังไม่ได้ทดสอบการอ่าน Log บนเครื่องคุณครับ

หลังแก้สองจุดและตั้ง Config แล้ว ใช้ `run.bat` เดิมได้ทันที รอบต่อไปไม่ต้องพิมพ์ Path หรือ Symbol ซ้ำครับ