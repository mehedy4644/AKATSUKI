#!/data/data/com.termux/files/usr/bin/bash

# Colors
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;96m"
RESET="\033[0m"

pkg update -y && pkg upgrade -y
pkg install root-repo -y
pkg install git tsu python wpa-supplicant pixiewps iw -y

# =========================================================
# CHECK DIRECTORY AND CLONE
# =========================================================

if [ ! -d "0" ] && [ ! -f "0.py" ]; then
    git clone https://github.com/mehedy4644/0
    cd 0 || exit
elif [ -d "0" ]; then
    cd 0 || exit
fi

chmod +x 0.py

# =========================================================
# PATHS
# =========================================================

BIN_DIR="$PREFIX/bin"
ZERO_BIN="$BIN_DIR/0"
ONE_BIN="$BIN_DIR/1"
SCRIPT_DIR="$(pwd)"
REPORTS_DIR="$SCRIPT_DIR/reports"

# =========================================================
# CREATE REPORTS DIRECTORY AND STORAGE FILE
# =========================================================

mkdir -p "$REPORTS_DIR"

# Create stored.csv if it does not exist
if [ ! -f "$REPORTS_DIR/stored.csv" ]; then
    printf '"Date";"BSSID";"ESSID";"WPS PIN";"WPA PSK"\n' \
        > "$REPORTS_DIR/stored.csv"
fi

# =========================================================
# 0 COMMAND
# =========================================================

cat > "$ZERO_BIN" <<EOF
#!/data/data/com.termux/files/usr/bin/bash

cd "$SCRIPT_DIR" || exit

# =========================================================
# UPDATE
# =========================================================

if [ "\$1" == "update" ]; then
    echo -e "\033[1;32m[+] Fetching latest updates from MSR's GitHub...\033[0m"

    git reset --hard HEAD > /dev/null 2>&1
    git pull origin main

    chmod +x 0.py

    # Make sure storage file still exists
    mkdir -p "$REPORTS_DIR"

    if [ ! -f "$REPORTS_DIR/stored.csv" ]; then
        printf '"Date";"BSSID";"ESSID";"WPS PIN";"WPA PSK"\n' \
            > "$REPORTS_DIR/stored.csv"
    fi

    exit 0
fi


# =========================================================
# HELP
# =========================================================

if [ "\$1" == "help" ]; then
    python help.py
    exit 0
fi


# =========================================================
# FIX
# =========================================================

if [ "\$1" == "fix" ]; then
    bash fix.sh
    exit 0
fi


# =========================================================
# CONTACT
# =========================================================

if [ "\$1" == "contact" ]; then
    python contact.py
    exit 0
fi


# =========================================================
# MENU
# =========================================================

if [ "\$1" == "menu" ]; then
    sudo python 0.py
    exit 0
fi


# =========================================================
# OLD
# =========================================================

if [ "\$1" == "old" ]; then
    sudo python w1.py -i wlan0 -K
    exit 0
fi


# =========================================================
# RUN
# =========================================================

if [ -z "\$1" ]; then
    sudo python 0.py -i wlan0 -K
else
    sudo python 0.py "\$@"
fi
EOF

chmod +x "$ZERO_BIN"


# =========================================================
# 1 COMMAND
# =========================================================

cat > "$ONE_BIN" <<EOF
#!/data/data/com.termux/files/usr/bin/bash

cd "$SCRIPT_DIR" || exit

clear

python - <<'PY'
import csv
import os

GREEN = "\033[1;32m"
CYAN = "\033[1;96m"
YELLOW = "\033[1;33m"
RESET = "\033[0m"

# =========================================================
# BANNER
# =========================================================

lines = [
    ("\033[38;5;88m",  " █████╗ ██╗  ██╗ █████╗ ████████╗███████╗██╗   ██╗██╗  ██╗██╗"),
    ("\033[38;5;160m", "██╔══██╗██║ ██╔╝██╔══██╗╚══██╔══╝██╔════╝██║   ██║██║ ██╔╝██║"),
    ("\033[38;5;201m", "███████║█████╔╝ ███████║   ██║   ███████╗██║   ██║█████╔╝ ██║"),
    ("\033[38;5;129m", "██╔══██║██╔═██╗ ██╔══██║   ██║   ╚════██║██║   ██║██╔═██╗ ██║"),
    ("\033[38;5;99m",  "██║  ██║██║  ██╗██║  ██║   ██║   ███████║╚██████╔╝██║  ██╗██║"),
    ("\033[38;5;21m",  "╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝"),
]

RESET = "\033[0m"
import shutil
width = shutil.get_terminal_size().columns
art_width = max(len(text) for _, text in lines)

if width >= art_width:
    for color, text in lines:
        print(color + text.center(width) + RESET)
else:
    for color, text in lines:
        print(color + text + RESET)

print()

# =========================================================
# STORAGE
# =========================================================

reports_dir = "reports"
csv_file = os.path.join(reports_dir, "stored.csv")

# Create reports directory
os.makedirs(reports_dir, exist_ok=True)

# Create stored.csv with header
if not os.path.exists(csv_file):
    with open(csv_file, "w", encoding="utf-8", newline="") as f:
        writer = csv.writer(
            f,
            delimiter=";",
            quoting=csv.QUOTE_ALL
        )
        writer.writerow([
            "Date",
            "BSSID",
            "ESSID",
            "WPS PIN",
            "WPA PSK"
        ])

# =========================================================
# READ SAVED DATA
# =========================================================

found = False

try:
    with open(
        csv_file,
        "r",
        encoding="utf-8-sig",
        newline=""
    ) as f:

        reader = csv.DictReader(
            f,
            delimiter=";"
        )

        for i, row in enumerate(reader, 1):

            essid = (row.get("ESSID") or "").strip()
            password = (row.get("WPA PSK") or "").strip()

            # Skip completely empty rows
            if not essid and not password:
                continue

            found = True

            # Same alignment logic as __credentialPrint()
            width = max(
                len(essid),
                len(password)
            )

            print(
                f"{CYAN} [{i}]{RESET} "
                f"{GREEN}[✓] Wi-Fi NAME :{RESET}  "
                f"{GREEN}{essid:^{width}}{RESET}"
            )

            print(
                f"     {GREEN}[✓] PASSWORD   :{RESET}  "
                f"{CYAN}{password:^{width}}{RESET}"
            )

            print()

except Exception as e:
    print(
        f" [!] UNABLE TO READ STORED Wi-Fi DATA."
    )

# =========================================================
# NO DATA
# =========================================================

if not found:
    print(
        f" [!] NO STORED Wi-Fi DATA FOUND."
    )
    print()
PY
EOF

chmod +x "$ONE_BIN"


# =========================================================
# FINAL
# =========================================================

echo -e ""
echo -e "\033[1;32m  [✓] TYPE '0' TO GET STARTED.${RESET}"
echo -e "\033[1;32m  [✓] TYPE '1' TO VIEW CREACKED LIST.${RESET}"
echo -e ""
