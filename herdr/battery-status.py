"""Show macOS battery percentage and charging state in Herdr."""
import re
import subprocess


def battery_status(output):
    match = re.search(r"(\d+)%;\s*([^;\n]+)", output)
    if not match:
        return ""
    percent, state = match.groups()
    state = state.strip()
    if state == "discharging":
        return f"{percent}%"
    return f"{percent}% {state}"


def main():
    try:
        result = subprocess.run(
            ["/usr/bin/pmset", "-g", "batt"],
            capture_output=True, text=True, check=True, timeout=1,
        )
        status = battery_status(result.stdout)
        if status:
            print(status)
    except (OSError, subprocess.SubprocessError):
        return


if __name__ == "__main__":
    main()
