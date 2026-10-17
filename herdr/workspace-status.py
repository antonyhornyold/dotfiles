"""Display the workspace selected by Herdr's tab-bar status context."""
import json
import os
import subprocess


def main():
    workspace_id = os.environ.get("HERDR_ACTIVE_WORKSPACE_ID")
    if not workspace_id:
        return
    try:
        result = subprocess.run(
            [os.environ.get("HERDR_BIN_PATH") or "herdr", "workspace", "get", workspace_id],
            capture_output=True, text=True, check=True, timeout=1,
        )
        workspace = json.loads(result.stdout)["result"]["workspace"]
        print(" ".join(workspace["label"].splitlines()))
    except (OSError, subprocess.SubprocessError, ValueError, KeyError, TypeError):
        return


if __name__ == "__main__":
    main()
