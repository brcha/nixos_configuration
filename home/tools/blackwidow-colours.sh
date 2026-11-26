# Sets a custom colour scheme on Razer BlackWidow 2019 keyboards.
# Usage: blackwidow-colours [selector=RRGGBB]...
#   selectors: fKeys | letters | modK | posK | numK | other
#   for example `blackwidow-colours fKeys=FF0000` makes F1 to F12 red

kbd=${BLACKWIDOW_SYSFS:-/sys/bus/hid/drivers/razerkbd}

fKeys='\xff\xa2\x00'   # warm yellow: F keys and Esc
letters='\x00\xff\x80' # seafoam green
modK='\xff\x22\x00'    # orange red: modifiers, and hjkl
posK='\xff\xa2\x00'    # navigation: Home, End, Page Up and Down
numK='\x00\x80\xff'    # sky blue: number row and keypad
other='\xff\xa2\x00'   # Print Screen, Scroll Lock, Pause
none='\x00\x00\x00'    # positions with no key on this keyboard

usage() {
  echo "Usage: blackwidow-colours [selector=RRGGBB]..." >&2
  echo "Selectors: fKeys | letters | modK | posK | numK | other" >&2
  exit 1
}

while [ $# -gt 0 ]; do
  selector=${1%%=*}
  hex=${1#*=}
  [[ $hex =~ ^[0-9A-Fa-f]{6}$ ]] || usage
  colour="\\x${hex:0:2}\\x${hex:2:2}\\x${hex:4:2}"
  case $selector in
    fKeys) fKeys=$colour ;;
    letters) letters=$colour ;;
    modK) modK=$colour ;;
    posK) posK=$colour ;;
    numK) numK=$colour ;;
    other) other=$colour ;;
    *) usage ;;
  esac
  shift
done

shopt -s nullglob
# The key matrix below is the BlackWidow 2019 layout (USB product 1532:0241)
for frame in "$kbd"/0003:1532:0241.*/matrix_custom_frame; do
  echo "Setting colours on $(dirname "$frame")"
  # Each write sets one row: row number, first column, last column, then 22 RGB triples
  echo -n -e "\x00\x00\x15$none$fKeys$none$fKeys$fKeys$fKeys$fKeys$fKeys$fKeys$fKeys$fKeys$fKeys$fKeys$fKeys$fKeys$other$other$other$none$none$none$none" >"$frame"
  echo -n -e "\x01\x00\x15$none$numK$numK$numK$numK$numK$numK$numK$numK$numK$numK$numK$numK$numK$numK$posK$posK$posK$numK$numK$numK$numK" >"$frame"
  echo -n -e "\x02\x00\x15$none$modK$letters$letters$letters$letters$letters$letters$letters$letters$letters$letters$letters$letters$modK$posK$posK$posK$numK$numK$numK$numK" >"$frame"
  echo -n -e "\x03\x00\x15$none$modK$letters$letters$letters$letters$letters$letters$letters$letters$letters$letters$letters$letters$modK$none$none$none$numK$numK$numK$none" >"$frame"
  echo -n -e "\x04\x00\x15$none$modK$letters$letters$letters$letters$letters$letters$letters$letters$letters$letters$letters$none$modK$none$modK$none$numK$numK$numK$numK" >"$frame"
  echo -n -e "\x05\x00\x15$none$modK$fKeys$modK$letters$letters$letters$letters$none$none$modK$letters$fKeys$fKeys$modK$modK$modK$modK$none$numK$numK$none" >"$frame"
  echo -n 1 >"$(dirname "$frame")/matrix_effect_custom"
done
