from pathlib import Path
from datetime import datetime
import hashlib
import json
import locale
import re
import uuid

SOURCE_SHA = "1a3b38f04b991c70fa86195d7d01360955ec4ccd"


def ask_path(message):
    value = input(message).strip().strip('"')
    return Path(value).expanduser().resolve()


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def decode_text(data, prefix=None):
    sample = prefix if prefix is not None else data

    if sample.startswith(b"\xff\xfe"):
        return data.decode("utf-16-le", errors="replace").lstrip("\ufeff")

    if sample.startswith(b"\xfe\xff"):
        return data.decode("utf-16-be", errors="replace").lstrip("\ufeff")

    if b"\x00" in sample[:200]:
        return data.decode("utf-16-le", errors="replace").lstrip("\ufeff")

    try:
        return data.decode("utf-8-sig")
    except UnicodeDecodeError:
        return data.decode(
            locale.getpreferredencoding(False),
            errors="replace"
        )


def read_inputs(data):
    values = {}

    for line in decode_text(data).splitlines():
        line = line.strip()

        if not line or line.startswith((";", "#")) or "=" not in line:
            continue

        key, value = line.split("=", 1)
        values[key.strip()] = value.split("||", 1)[0].strip()

    return values


def log_snapshot(folder):
    result = {}

    if folder.is_dir():
        for path in folder.glob("*.log"):
            stat = path.stat()
            result[path.name] = {
                "size": stat.st_size,
                "mtime_ns": stat.st_mtime_ns
            }

    return result


def matching_reports(folder, symbol, magic):
    result = []

    if folder.is_dir():
        for path in folder.rglob("*.csv"):
            if (
                path.name.startswith(symbol + "_")
                and f"_{magic}_FROM_" in path.name
            ):
                result.append(path)

    return sorted(result)


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

    if not (terminal / "MQL5").is_dir():
        raise ValueError("Select the MT5 Data Folder containing MQL5.")

    if not preset.is_file() or preset.suffix.lower() != ".set":
        raise ValueError("Preset .set file not found.")

    preset_data = preset.read_bytes()
    inputs = read_inputs(preset_data)
    magic = inputs.get("InpMagicNumber", "")

    if not magic.isdigit() or int(magic) <= 0:
        raise ValueError("Invalid or missing InpMagicNumber in preset.")

    print(f"\nPreset : {preset.name}")
    print(f"Symbol : {symbol}")
    print(f"Magic  : {magic}")
    print(f"Source : {SOURCE_SHA} (reference, not binary verification)")
    print("\nStart capture BEFORE attaching/loading the EA.")

    print(f"MT5 Data Folder: {terminal}")
    print(f"Preset File    : {preset}")
    print("This selects an evidence label; it does not load the EA.")
    print("Confirm the same preset and Magic on the MT5 chart.")

    if input("1 = Start capture | 0 = Cancel: ").strip() != "1":
        print("Cancelled.")
        return

    output_root = (Path.cwd() / "Hedge1_Test_Evidence").resolve()

    if output_root == terminal or terminal in output_root.parents:
        raise ValueError(
            "Run this script outside the MT5 Data Folder."
        )

    started = datetime.now().astimezone()
    label = re.sub(r"[^A-Za-z0-9_.-]+", "_", preset.stem)
    run_id = (
        f"{label}_M{magic}_"
        f"{started:%Y%m%d_%H%M%S}_{uuid.uuid4().hex[:6]}"
    )
    output = output_root / run_id
    output.mkdir(parents=True, exist_ok=False)
    (output / "preset.set").write_bytes(preset_data)

    folders = {
        "Experts": terminal / "MQL5" / "Logs",
        "Journal": terminal / "Logs"
    }
    before = {
        name: log_snapshot(folder)
        for name, folder in folders.items()
    }

    report_folder = terminal / "MQL5" / "Files"
    reports_before = {
        str(path.relative_to(report_folder))
        for path in matching_reports(report_folder, symbol, magic)
    }

    metadata = {
        "run_id": run_id,
        "source_reference": SOURCE_SHA,
        "source_binary_verified_by_script": False,
        "preset": str(preset),
        "preset_sha256": sha256(preset_data),
        "preset_inputs": inputs,
        "symbol_label": symbol,
        "magic_from_preset": int(magic),
        "actual_chart_inputs_verified_by_script": False,
        "terminal_data_folder": str(terminal),
        "start_local": started.isoformat(),
        "log_baseline": before,
        "errors": [],
        "logs": [],
        "reports": [],
        "limitations": [
            "Session grouping; not reliable per-line Magic filtering.",
            "Other EAs or terminal activity may appear in session logs.",
            "Only bytes already written to disk can be captured.",
            "No automatic position/history/state snapshot.",
            "Raw daily logs can include activity outside this session."
        ]
    }

    metadata_path = output / "metadata.json"

    def save_metadata():
        metadata_path.write_text(
            json.dumps(metadata, ensure_ascii=False, indent=2),
            encoding="utf-8"
        )

    metadata["status"] = "CAPTURE_STARTED"
    save_metadata()

    print(f"\nEvidence folder:\n{output}")
    print("\nNow load the matching preset and run your test.")
    print("At the end: stop auto reopening, finish positions safely,")
    print("remove the test EA, and allow logs to be written to disk.")
    print("Do NOT delete original log files.")
    input("\nPress ENTER when the session is finished: ")

    for name, folder in folders.items():
        sections = []

        for path in sorted(folder.glob("*.log")):
            previous = before[name].get(path.name)
            current = path.stat()

            if previous and (
                current.st_size == previous["size"]
                and current.st_mtime_ns == previous["mtime_ns"]
            ):
                continue

            try:
                raw = path.read_bytes()
                offset = previous["size"] if previous else 0
                rewritten = bool(
                    previous
                    and (
                        len(raw) < offset
                        or len(raw) == offset
                    )
                )

                if rewritten:
                    offset = 0

                destination = output / "raw_logs" / name / path.name
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_bytes(raw)

                text = decode_text(raw[offset:], prefix=raw[:200])
                sections.append(
                    f"===== {path.name} | offset={offset}"
                    f" | rewritten={rewritten} =====\n{text}\n"
                )

                metadata["logs"].append({
                    "kind": name,
                    "source": str(path),
                    "bytes_copied": len(raw),
                    "baseline_offset": offset,
                    "rewritten_or_truncated": rewritten,
                    "sha256": sha256(raw)
                })
            except OSError as error:
                metadata["errors"].append(f"{path}: {error}")

        (output / f"{name}.session.txt").write_text(
            "\n".join(sections),
            encoding="utf-8"
        )

    for path in matching_reports(report_folder, symbol, magic):
        try:
            relative = path.relative_to(report_folder)
            raw = path.read_bytes()
            destination = output / "reports" / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(raw)

            metadata["reports"].append({
                "source": str(path),
                "existed_before_session": str(relative) in reports_before,
                "sha256": sha256(raw)
            })
        except OSError as error:
            metadata["errors"].append(f"{path}: {error}")

    metadata["end_local"] = datetime.now().astimezone().isoformat()
    metadata["status"] = "EXPORTED_NOT_RUNTIME_PASS"
    save_metadata()

    print(f"\nExport complete:\n{output}")
    print(f"Log files copied: {len(metadata['logs'])}")
    print(f"Report files copied: {len(metadata['reports'])}")
    print(f"Read errors: {len(metadata['errors'])}")
    print("Review metadata.json. Export complete does not mean test PASS.")

    if not metadata["logs"]:
        print("WARNING: No log changes found. Check folder/buffering.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as error:
        print(f"\nERROR: {error}")