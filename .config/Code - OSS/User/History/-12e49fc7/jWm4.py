import sys
from apply import apply_theme
from watch import watch

if len(sys.argv) == 1:
    print("Usa:\n  python main.py apply\n  python main.py watch")
    exit()

if sys.argv[1] == "apply":
    apply_theme()

elif sys.argv[1] == "watch":
    watch()
