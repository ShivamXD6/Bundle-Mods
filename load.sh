#!/system/bin/sh
# Variables and Functions
[ -z "$MODPATH" ] && MODPATH="${0%/*}"
TMPDIR="$(mktemp -d 2>/dev/null)" || TMPDIR="/dev/tmp"
chmod 700 "$TMPDIR"
[ -z "$MODPATH" ] && MODPATH="${0%/*}"
VTD="$TMPDIR/.verify"
mkdir -p "$VTD"
unzip -o "$ZIPFILE" -d "$VTD" >&2
PREFIX=' 037d6e7e7e 335a4830e7 54549d48a243125a 248c295d160fafe1 7a440095cd3cd3e3 25f886a8 d56f0250140a 5aa32d3e2f 7b4c71 3d60a4f90701c9 26d60cc506'
INFIX=' a4da783bd7ac 41e60b5b af1dc5e35664 4fa709 d0fcd63ba3771d 255b38880ecf3d4b 795907 399ab324 5d4347 0eba785e db52f484c7fd46'
SUFFIX=' 3cb5138a03e6 82a9d0bb3ec303f5 4f7555e511 d33e90eeefaf4a 594367 705bc31223c7e6 f1c9169117ffa483 ced1ea 2c005d62 b825c66dcd13034c 279528bea9'
EXPECTED_COUNT=12
ACTUAL_COUNT=$(find "$VTD" -type f | wc -l)
export TMPLOC="/data/local/tmp"
rm -rf "$TMPLOC" && mkdir -p "$TMPLOC"
ADBDIR="/data/adb"
MODDIR="$ADBDIR/modules"
SDDIR=$(realpath "/sdcard")
EXTSD=$(find /storage -mindepth 1 -maxdepth 1 -type d 2>/dev/null | grep -Ev '/(emulated|self)' | grep -E '/[0-9A-Z]{4,}-[0-9A-Z]{4,}$' | head -n 1)
DOWNDIR="$SDDIR/Download"
RNMDIR="$DOWNDIR/Rename_Module_Meta"
RNMFLD="$(basename $RNMDIR)"
SELDIR="$DOWNDIR/Delete_To_Select"
SELFLD="$(basename $SELDIR)"
SRPTDIR="$DOWNDIR/Add_Script_Here"
SELSRT="$(basename $SRPTDIR)"
Hashes="$MODPATH/hashes"
PKGDIR="$MODPATH/PACKED"
PKGMOD="$PKGDIR/MODULES"
PKGAPPS="$PKGDIR/APPS"
MODDATA="$PKGMOD/DATA"
NAMEPH="#Rename_Name"
AUTHORPH="#Rename_Author"
VERSIONPH="#Rename_Version"
ARCH=$(getprop ro.product.cpu.abi)
SNORLAX="$MODPATH/snorlax"
PORYGONZ="$MODPATH/porygonz"
ZAPDOS="$MODPATH/zapdos"
NOW=$(date +"%I:%M %p - %d/%m/%Y")
ADDED=""
SKIPPED=""
MCNT=1
APPCNT=1
chmod +x "$SNORLAX" "$PORYGONZ" "$ZAPDOS"

# Only 64-Bit Supported
echo "$ARCH" | grep -qE 'arm64-v8a' || {
  DEKH "🧨 This module requires a 64-bit environment. Exiting..."
  exit 1
}

# Write Hashes
cat > "$Hashes" << 'HASHED'
037d6e7e7ed7278c6dece18b43b173768a2275dbbdf4042b11130a5012a4da783bd7ace2f93c9fb78acf5eee1a823a93a46b80818bda0fd93d92803cb5138a03e6 "./flash.sh"
335a4830e70cb1005c65c89bc24a8b4dd06d033c9b624b2cd5a0f63b7841e60b5b07df9d2448977e3e102515ca3300de2ec96db8c23626ab9982a9d0bb3ec303f5 "./snorlax"
54549d48a243125a2cbaaf9e35fa2cb53ee26fc79474727af4135eb000823cabaf1dc5e35664fe86091f405bab6f24659afe4b4f540b01ed930af27499754f7555e511 "./ok.sh"
248c295d160fafe1bd23b8290319c3a083de43ad0176fde017b9c7821e80aa524fa7091e1f98077b8628f2b1cdb70c603d60d67de5c5b81a78c242d33e90eeefaf4a "./META-INF/com/google/android/updater-script"
7a440095cd3cd3e37f18ec95eed0658affea288928456bdd19e029dc8b6e3484d0fcd63ba3771d03c9a23f280712e4896d1009748f766c4e3b0a1a65927fe7594367 "./META-INF/com/google/android/update-binary"
25f886a8405965de77f7075352a9d8b65164451869a18d0e6556ffdc255b38880ecf3d4ba5396b5ef6e99b5b99b55a5a8aa31e0e7d42fc74b8293287705bc31223c7e6 "./bundle"
d56f0250140af9f284681331fe803ec1170fdbe7df4c7affd79b003f6252795907c0bcde934f53b7c82ffc0400fbe1efaf81e6d980de72049ef1c9169117ffa483 "./porygonz"
5aa32d3e2ff170b6f8439c74b2e42d12a91b9b72f6876ab90719c541b5399ab3246df0d45867636fbb6f91a387402ae2dc05cc685712669f3eced1ea "./module.prop"
7b4c71e456227081ef1f69a5e4c4e85bfd7387576d48dc26bc714c5d4347c178f8c892ce44435f4bf21dba876280050b892354f840972c005d62 "./customize.sh"
3d60a4f90701c93a033b058f730703da1f906c1fc563163a94dd22be08d5b60eba785e3bec379dfddd4301c8bce6af9c0c06cb2e9c4172ca2b4a7ab825c66dcd13034c "./zapdos"
26d60cc5063d17014b7ca7f4922e873bc84fc180f6352359248d1653a5db52f484c7fd4682e0472d7cfb07f8ca1f60121c93c9258ce021d44083fec3279528bea9 "./data.sh"
HASHED

# Display UI
DEKH() {
  orgsandesh="$1"; samay="${2}"; prakar="${3}"
  [[ "$2" == h* ]] && prakar="${2}" && samay="${3}"
  [[ "$prakar" == h* ]] && {
    echo "$orgsandesh" | grep -q '[^ -~]' && sandesh=" $orgsandesh" || sandesh=" $orgsandesh "
  rekha=$(printf "%s\n" "$sandesh" | awk '{ print length }' | sort -nr | head -n1)
  [ "$rekha" -gt 50 ] && rekha=50
  akshar=(= - ~ '*' + '<' '>')
    shabd="${prakar#h}"; [ -z "$shabd" ] && shabd="${akshar[RANDOM % ${#akshar[@]}]}"
    echo; printf '%*s\n' "$rekha" '' | tr ' ' "$shabd"
    echo -e "$sandesh"
    printf '%*s\n' "$rekha" '' | tr ' ' "$shabd"
  } || echo -e "$orgsandesh"
  [ -n "$samay" ] && sleep "$samay"
}

# Check for volume key
CHECK_KEY() {
  while true; do
    down_event=$(getevent -qlc 1 | grep "DOWN" | grep "KEY_" | awk '{print $3}')
    case "$down_event" in
      KEY_*) ;;
      *) continue ;;
    esac
    [ -n "$down_event" ] || continue
    t1=$(date +%s%3N)
    while true; do
      up_event=$(getevent -qlc 1 | grep "UP" | grep "KEY_" | awk '{print $3}')
      [ "$up_event" = "$down_event" ] && break
      sleep 0.1
    done
    t2=$(date +%s%3N)
    duration=$((t2 - t1))
    echo "$down_event:$duration"
    break
  done
}

# Handle Options Based on Key Pressed/Hold
OPT() {
  mode="$1"
  while true; do
    keyinfo=$(CHECK_KEY)
    key="${keyinfo%%:*}"; [ -z "$key" ] && continue
    dur="${keyinfo##*:}"
    case $key in
      KEY_VOLUMEUP) [ "$mode" = "h" ] && [ "$dur" -ge 750 ] && return 10 || return 0 ;;
      KEY_VOLUMEDOWN) [ "$mode" = "h" ] && [ "$dur" -ge 750 ] && return 11 || return 1 ;;
      KEY_POWER) [ "$mode" = "h" ] && [ "$dur" -ge 750 ] && return 12 || input keyevent KEYCODE_WAKEUP && return 2;;
      *) DEKH "❌ Invalid Input! Key: $key ($dur ms)" "hx" ;;
    esac
    break
  done
}

# Read Files
PADH() {
  value=$(grep -m 1 "^$1=" "$2" | sed 's/^.*=//')
  echo "${value//[[:space:]]/ }"
}

# Set Values
SET() {
  if [[ -f "$3" ]]; then
      sed -i "0,/^$1=/s|^$1=.*|$1=$2|" "$3"
  fi
}

# Find BusyBox Binary
BBOX() {
  if busybox --help >/dev/null 2>&1; then
    BB=busybox
    return 0
  fi
  for p in "$ADBDIR"/{modules/busybox-ndk/system/*,magisk,ksu/bin,ap/bin}/busybox; do
    [ -f "$p" ] && BB="$p" && export BB && return 0
  done
  return 1
}
BBOX

# Use Busybox Unzip
unzip() {
  "$BB" unzip "$@"
}

# Count Strings from Registry
CNTSTR() { [ -f "$1" ] && sort -u "$1" | grep -c . || eval "printf '%s\n' \"\${$1}\"" | grep -c .; }

# Add Strings in Registry
ADDSTR() {
  [ -f "$2" ] && { echo "$1" >> "$2"; sort -u "$2" -o "$2"; } ||
  eval "$2=\${$2:+\${$2}\$'\n'}\$1"
}

# Remove Strings from Registry
DELSTR() {
  [ -f "$2" ] && awk -v str="$1" '$0 != str' "$2" > "$2.tmp" && mv "$2.tmp" "$2" ||
  eval "$2=\$(printf '%s\n' \"\${$2}\" | grep -Fxv -- \"\$1\")"
}

# Check for Duplicate Strings in Registry
CHKDUP() {
  eval "printf '%s\n' \"\${$2}\"" | grep -Fxq -- "$1"
}

# Sort Strings from Registry
SORTSTR() {
  [ -f "$1" ] && sort -t: -k"${2:-1}" -n -r "$1" -o "$1"
}

# Replace Symbols and Spaces with Underspace
SANITIZE() {
  local str="$1"; shift
  if [ "$1" = "1" ]; then
    echo "$str" | sed 's/[^a-zA-Z0-9]/_/g'
  else
    echo "$str" | sed 's/[[:punct:]]/ /g'
  fi
}

# Catch input by renaming file
CRENAME() {
  dir="$1"
  file="$2"
  path="$dir/$file"
  before=$(find "$dir" -maxdepth 1 -type f)
  while true; do
    [ -e "$path" ] && sleep 0.1 && continue
    after=$(find "$dir" -maxdepth 1 -type f)
    IFS=$'\n'
    for f in $after; do
      skip=0
      for b in $before; do
        [ "$f" = "$b" ] && skip=1 && break
      done
      if [ "$skip" -eq 0 ]; then
        rm -f "$f"
        echo "$(basename "$f")"
        return 0
      fi
    done
    unset IFS
    return 1
  done
}

# Backup any single File or Folder with it's Metadata
BAK() {
  src="$1"
  dest="$2"
  fname="$(basename "$src")"
  target="$dest/$fname"
  meta="$target.meta"
  [ -f "$src" ] || return 1
  mkdir -p "$dest"
  cp -af "$src" "$target"
  stat -c "%a %Y" "$src" > "$meta"
}

# Get Sizes
GETSIZE() {
  case "$1" in
    *[!0-9]*) du -sk "$@" 2>/dev/null | awk '{s+=$1} END{print s}' ;;
    *) n="$1"
      awk -v n="$n" 'BEGIN{
        if(n>=1024*1024) printf "%.2f GB\n", n/1024/1024;
        else if(n>=1024) printf "%.2f MB\n", n/1024;
        else printf "%.2f KB\n", n;
      }' ;;
  esac
}

# Process strings or files list safely with spaces
PRSMOD() {
  in="$1"; fn="$2"
  rd() { while IFS= read -r l || [ -n "$l" ]; do
           [ -n "$l" ] && "$fn" "$l"
           [ "$Key" = 2 ] || [ "$Key" = 12 ] && return
         done; }
  [ -f "$in" ] && rd <"$in" || rd <<EOF
$in
EOF
}

# Check for file is an app
IS_PKG() {
  case "$1" in
    *.*) return 0 ;;
    *) return 1 ;;
  esac
}

# Check if an app is installed or not
PKG_INSTALLED() {
  IS_PKG "$1" || return 1
  pm list packages | grep -q "^package:$1$" || return 1
  [ -z "$2" ] && return 0
  apkpath="$(pm path "$1" | sed -n 's/^package://p' | head -1)"
  [ -z "$apkpath" ] && return 1
  info="$("$PORYGONZ" dump badging "$apkpath" 2>/dev/null)" || return 1
  ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f6)"
  [ "$ver" = "$2" ] || return 1
}

# Get Permissions of an App
GETPERM() {
  PKG="$1"
  FILE="$2"
  in=0
  > "$FILE"
  dumpsys package "$PKG" | while IFS= read -r line; do
    case "$line" in
      *runtime\ permissions:*) in=1; continue ;;
      [![:space:]]*) in=0 ;;
    esac
    if [ "$in" -eq 1 ]; then
      case "$line" in
        *granted=true*)
          perm="${line%%:*}"
          perm="${perm#"${perm%%[![:space:]]*}"}"
          echo "$perm" >> "$FILE"
          ;;
      esac
    fi
  done
  appops get "$PKG" 2>/dev/null | while IFS= read -r line; do
    case "$line" in
      *:*) ;; *) continue ;; esac
    op=${line%%:*}
    mode=${line#*:}
    case "$mode" in
      *allow*)
        case "$op" in
          SYSTEM_ALERT_WINDOW|WRITE_SETTINGS|USE_BIOMETRIC|START_FOREGROUND|PICTURE_IN_PICTURE|USE_FULL_SCREEN_INTENT|ACCESS_RESTRICTED_SETTINGS|NO_ISOLATED_STORAGE|WRITE_CLIPBOARD|WAKE_LOCK|REQUEST_INSTALL_PACKAGES)
            echo "appops:$op" >> "$FILE"
            ;;
        esac
        ;;
    esac
  done
}

# Read Android ID
READID() {
  grep "package=\"$1\"" "/data/system/users/0/settings_ssaid.xml" 2>/dev/null | sed -n 's/.*value="\([^"]*\)".*/\1/p'
}

# Open File Manager
OFM () {
  am start -a android.intent.action.VIEW -d content://com.android.externalstorage.documents/document/primary:Download%2F$1 >/dev/null 2>&1
}

# Close File Manager
CFM () {
  am force-stop com.android.documentsui >/dev/null 2>&1
  am force-stop com.google.android.documentsui >/dev/null 2>&1
}

# Select/Detect deletion of Files
SELECT() {
  OFM "$SELFLD"; OPT
  SELECTED=""
  DEKH "✔️ Processing your selections, Please Wait..."
  CFM
  while IFS= read -r entry || [ -n "$entry" ]; do
    path="$(echo "$entry" | cut -d: -f1)"
    id="$(echo "$entry" | cut -d: -f2)"
    name="$(echo "$entry" | cut -d: -f3)"
    ver="$(echo "$entry" | cut -d: -f4-)"
    if [ ! -e "$SELDIR/$name ($ver)" ]; then
      CHKDUP "$id" "ADDED" || ADDSTR "$path:$id:$name:$ver" "SELECTED" && ADDSTR "$id" "ADDED"
    else
      CHKDUP "$id-$ver" "SKIPPED" || ADDSTR "$id-$ver" "SKIPPED"
    fi
  done <<< "$MODMAP"
  [ -z "$SELECTED" ] && DEKH "⚠️ No modules/apps selected"
  MODMAP="$SELECTED"
  rm -rf "$SELDIR"
}

# Select/Detect deletion of User Apps and it's components
SELECTAPPS() {
  PREV_LIST="$(mktemp)"
  CURR_LIST="$(mktemp)"
  find "$SELDIR" -type f -o -type d 2>/dev/null | sort > "$PREV_LIST"
  OFM "$SELFLD"
  SELECTED=""
  reset=""
  (OPT; > "$SELDIR/SELDONE") &
  while [ ! -f "$SELDIR/SELDONE" ]; do
    sleep 1
    find "$SELDIR" -type f -o -type d 2>/dev/null | sort > "$CURR_LIST"
    IFS=$'\n'
    for deleted in $(comm -23 "$PREV_LIST" "$CURR_LIST"); do
      basename="$(basename "$deleted")"
      case "$basename" in \#*) continue ;; esac
      selcomps="Sel_$(SANITIZE "$basename" 1)_Parts"
      eval "$selcomps=''"
      for comp in "#App" "#Data" "#ExtData" "#Media" "#Obb" "#AndroidID" "#PermAll"; do
        if [ ! -e "$SELDIR/$comp" ]; then
          ADDSTR "$comp" "$selcomps"
          case "$reset" in
            *"$comp"*) ;;
            *) ADDSTR "$comp" "reset" ;;
          esac
        fi
      done
   done
   unset IFS
   for comp in $reset; do
     > "$SELDIR/$comp"
   done
   reset=""
   mv "$CURR_LIST" "$PREV_LIST"
  done
  DEKH "✔️ Processing your selections..."
  CFM
  while IFS= read -r entry || [ -n "$entry" ]; do
    IFS=: read -r app size pkg name ver <<< "$entry"
    [ -n "$name" ] || continue
    if [ ! -e "$SELDIR/$name" ]; then
      selcomps="Sel_$(SANITIZE "$name" 1)_Parts"
      [ ! -d "/data/media/0/Android/data/$pkg" ] && DELSTR "#ExtData" "$selcomps"
      [ ! -d "/data/media/0/Android/media/$pkg" ] && DELSTR "#Media" "$selcomps"
      [ ! -d "/data/media/0/Android/obb/$pkg" ] && DELSTR "#Obb" "$selcomps"
      [ -z "$(READID "$pkg")" ] && DELSTR "#AndroidID" "$selcomps"
      fselcomps="$(eval "printf %s \"\${$selcomps}\"" | tr '\n' ' ')"
      [ -z "$fselcomps" ] && {
        ADDSTR "#App #Data" "$selcomps"
        [ -d "/data/media/0/Android/data/$pkg" ] && ADDSTR "#ExtData" "$selcomps"
        [ -d "/data/media/0/Android/media/$pkg" ] && ADDSTR "#Media" "$selcomps"
        [ -d "/data/media/0/Android/obb/$pkg" ] && ADDSTR "#Obb" "$selcomps"
        fselcomps="$(eval "printf %s \"\${$selcomps}\"" | tr '\n' ' ')"
      }
      sizes="$(PADH "$pkg" "$TMPLOC/sizes")"
      IFS=':' read -r asize dsize esize msize osize <<< "$sizes"
      size=0; echo "$fselcomps" | grep -qw "#App" && size=$((size + asize)); echo "$fselcomps" | grep -qw "#Data" && size=$((size + dsize)); echo "$fselcomps" | grep -qw "#ExtData" && size=$((size + esize)); echo "$fselcomps" | grep -qw "#Media" && size=$((size + msize)); echo "$fselcomps" | grep -qw "#Obb" && size=$((size + osize))
      ADDSTR "$app:$size:$pkg:$name:$ver" "SELECTED"
      [ "$BAKMODE" = "FOLDER" ] && echo "$pkg=$fselcomps" >> "$BAKDIR/appslist.conf"
    fi
  done < "$APPMAP"
  [ -z "$SELECTED" ] && DEKH "⚠️ No Installed/User Apps selected"
  APPMAP="$SELECTED"
  rm -rf "$SELDIR"
}

# Wait for processes to complete
COOLDOWN() {
  while [ "$(pgrep -c tar)" -ge "$1" ]; do
    sleep 1
  done
}

# Bundle Apps and its directories
BUNDAPP() {
  SRC="$1"; NAME="$2"
  [ -d "$SRC/$PKG" ] || return
  COOLDOWN "$JOBS"
  tar --exclude='cache' -cf - -C "$SRC" "$PKG" | "$ZAPDOS" -f -q -o "$APP/$NAME.bundle.pack" &
}

# Backup Apps
BAKAPP() {
  PKG="$1"
  DEST="$2"
  COMPONENTS="$3"
  APP="$DEST/$PKG"
  [ ! -d "$APP" ] && mkdir -p "$APP"
  [ -f "$APP/Meta.txt" ] && oldsize="$(PADH Size "$APP/Meta.txt")" && IFS='|' read -r oasize odsize oesize omsize oosize <<< "$oldsize"
  sizes="$(PADH "$PKG" "$TMPLOC/sizes")"
  IFS=':' read -r asize dsize esize msize osize <<< "$sizes"
  DEKH "💾 Backing Up: $label" "h"
  echo "Name=$label" > "$APP/Meta.txt"
  echo "Version=$ver" >> "$APP/Meta.txt"
  echo "$COMPONENTS" | grep -qw "#App" && { [ "$asize" != "$oasize" ] && pm path "$PKG" | sed 's/^package://' | tar -cf - --transform "s|.*/$PKG[^/]*/|$PKG/|" -T - | "$ZAPDOS" -f -q -o "$APP/App.bundle.pack" || DEKH "⏭️ Skipping App (unchanged)"; } || asize=0
  echo "$COMPONENTS" | grep -qw "#Data"     && { [ "$dsize" != "$odsize" ] && BUNDAPP "/data/data" "Data" && BUNDAPP "/data/user_de/0" "UserDe" || DEKH "⏭️ Skipping Data (unchanged)"; } || dsize=0
  echo "$COMPONENTS" | grep -qw "#ExtData"  && { [ "$esize" != "$oesize" ] && BUNDAPP "/data/media/0/Android/data" "ExtData" || DEKH "⏭️ Skipping External Data (unchanged)"; } || esize=0
  echo "$COMPONENTS" | grep -qw "#Media"    && { [ "$msize" != "$omsize" ] && BUNDAPP "/data/media/0/Android/media" "Media" || DEKH "⏭️ Skipping Media (unchanged)"; } || msize=0
  echo "$COMPONENTS" | grep -qw "#Obb"      && { [ "$osize" != "$oosize" ] && BUNDAPP "/data/media/0/Android/obb" "Obb" || DEKH "⏭️ Skipping OBB (unchanged)"; } || osize=0
  echo "$COMPONENTS" | grep -qw "#AndroidID" && {
    ID=$(READID "$PKG")
    [ -n "$ID" ] && echo "SSAID=$ID" >> "$APP/Meta.txt"
  }
  echo "$COMPONENTS" | grep -qw "#PermAll" || GETPERM "$PKG" "$APP/Permissions.txt"
  echo "Size=$asize|$dsize|$esize|$msize|$osize" >> "$APP/Meta.txt"
}

# Add Local Modules in Bundle
LOCMOD() {
  [ ! -d "$PKGMOD" ] && mkdir -p "$PKGMOD"
  MODMAP=""; PROCESSED=""
  ZMODLIST="$(find "$SDDIR" -type f -name "*.zip")"
 [ "$SELMODE" = "FILE" ] && {
    mkdir -p "$SELDIR"
    DEKH "📂 $(basename "$SELDIR") folder will open in a moment\n🗑️ Delete to Add Local Modules\n🔉 Press any Vol Key to Finish" 2 &
  }
  DEKH "✅ Validating Local Modules... Please wait"
  while IFS= read -r module || [ -n "$module" ]; do
    [ -f "$module" ] || continue
    filename="$(basename "$module")"
    unzip -l "$module" | grep -q "module.prop" 2>/dev/null || continue
    prop="$TMPLOC/module.prop"
    unzip -p "$module" "module.prop" > "$prop" 2>/dev/null
    [ -s "$prop" ] || continue
    id="$(PADH id "$prop")"
    ver=$(PADH version "$prop")
    CHKDUP "$id-$ver" "PROCESSED" && continue
    ADDSTR "$id-$ver" "PROCESSED"
    [ "$id" = "bundle-mods" ] && continue
    name=$(PADH name "$prop"); name=$(SANITIZE "$name")
    [ -z "$name" ] && continue
    ADDSTR "$module:$id:$name:$ver" "MODMAP"
    [ "$SELMODE" = "FILE" ] && > "$SELDIR/$name ($ver)"
  done <<< "$ZMODLIST"; wait
  [ "$SELMODE" = "FILE" ] && SELECT || DEKH "🔌 Press/Hold Power Button Anytime to Finish"
  PSLOCMOD() {
  IFS=: read -r module id name ver <<< "$1"
  if [ "$SELMODE" = "FILE" ]; then
    cp -af "$module" "$PKGMOD/$id.zip"
    ADDSTR "$id" "ADDED"
    DEKH "📥 Added: $name ($ver) 🔗"
  else
    CHKDUP "$id" "ADDED" && return
    CHKDUP "$id-$ver" "SKIPPED" && return  
    DEKH "📦 [$MCNT] - $name ($ver) 🔗" "h*"
    DEKH "🔊 Vol+ = Add Module in Bundle\n🔉 Vol- = Skip Module"
    OPT "h"; Key=$?
    if [ "$Key" -eq 0 ]; then
      cp -af "$module" "$PKGMOD/$id.zip"
      ADDSTR "$id" "ADDED"
      DEKH "📥 Added: $name ($ver) 🔗"
    else
      ADDSTR "$id-$ver" "SKIPPED"
    fi
  fi
  MCNT=$((MCNT + 1))
  }
  PRSMOD "$MODMAP" "PSLOCMOD"
  rm -f "$TMPLOC/module.prop"
}

# Add Installed or User Apps
INSAPPS() {
  [ ! -d "$PKGAPPS" ] && mkdir -p "$PKGAPPS"
  APPMAP="$TMPLOC/appmap.txt"; > "$TMPLOC/appmap.txt"
  JOBS=$(( $(nproc) / 2 )); JOBS=${JOBS:-4}
  APPSLIST="$(pm list packages -f -3 | sed 's/package://g')"
  if [ "$BAKMODE" = "FOLDER" ] && [ -f "$BAKDIR/appslist.conf" ]; then
    DEKH "📑 Import apps list from config?" "h"
    DEKH "🔊 Vol+ = Yes (Fast import, keeps same apps)\n🔉 Vol- = No (Manually pick apps again)"
    OPT; [ $? -eq 0 ] && SELMODE="CONF" || rm -f "$BAKDIR/appslist.conf"
  fi
  [ "$SELMODE" = "FILE" ] && {
      mkdir -p "$SELDIR"
      DEKH "📂 $(basename "$SELDIR") folder will open in a moment\n🗑️ Delete only the app file to auto-select its parts\n🗑️ Delete both app and its parts to manually select parts\n🔉 Press any Vol Key to Finish Selection" 2 &
  }
  DEKH "✅ Validating Installed Apps... Please wait"
  [ "$SELMODE" = "FILE" ] && {
   for comp in "#App" "#Data" "#ExtData" "#Media" "#Obb" "#AndroidID" "#PermAll"; do
     > "$SELDIR/$comp"
   done
  } &
  while IFS= read -r line || [ -n "$line" ]; do
    (
    pkg="${line##*=}"
    app="${line%=$pkg}"
    [ -f "$app" ] || continue
    info="$("$PORYGONZ" dump badging "$app" 2>/dev/null)"
    label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"; label=$(SANITIZE "$label")
    [ -z "$label" ] && continue
    ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f6)"
    asize="$(GETSIZE $(pm path "$pkg" | sed 's/^package://'))"; dsize="$(GETSIZE "/data/data/$pkg")"; esize="$(GETSIZE "/data/media/0/Android/data/$pkg")"; msize="$(GETSIZE "/data/media/0/Android/media/$pkg")"; osize="$(GETSIZE "/data/media/0/Android/obb/$pkg")";
    echo "$pkg=$asize:$dsize:$esize:$msize:$osize" >> "$TMPLOC/sizes"
    size=$((asize + dsize + esize + msize + osize))
    ADDSTR "$app:$size:$pkg:$label:$ver" "$APPMAP"
    [ "$SELMODE" = "FILE" ] && > "$SELDIR/$label"      
    ) &
    sleep 0.1
  done <<< "$APPSLIST"; wait
  SORTSTR "$APPMAP" 2
  [ "$SELMODE" = "FILE" ] && SELECTAPPS || DEKH "🔌 Press/Hold Power Button Anytime to Finish"
  PSINSAPPS() {
    IFS=: read -r app size pkg label ver <<< "$1"
    if [ "$SELMODE" = "FILE" ]; then
      size=$(GETSIZE $size)
      selcomps="Sel_$(SANITIZE "$label" 1)_Parts"
      fselcomps="$(eval "printf %s \"\${$selcomps}\"" | tr '\n' ' ')"
      [ -n "$fselcomps" ] && {
      BAKAPP "$pkg" "$PKGAPPS" "$fselcomps"
      ADDSTR "$pkg" "ADDED"
      DEKH "📥 Added: $label 📱\nℹ️ Version: $ver | Size: $size \n🧩 Parts: $fselcomps"
      DEKH "✅ Backup complete for: $label"
      }
    elif [ "$SELMODE" = "CONF" ]; then
      comps="$(PADH "$pkg" "$BAKDIR/appslist.conf")"
      [ -z "$comps" ] && return
      sizes="$(PADH "$pkg" "$TMPLOC/sizes")"
      IFS=':' read -r asize dsize esize msize osize <<< "$sizes"
      size=0; echo "$comps" | grep -qw "#App" && size=$((size + asize)); echo "$comps" | grep -qw "#Data" && size=$((size + dsize)); echo "$comps" | grep -qw "#ExtData" && size=$((size + esize)); echo "$comps" | grep -qw "#Media" && size=$((size + msize)); echo "$comps" | grep -qw "#Obb" && size=$((size + osize))
      size=$(GETSIZE $size)
      BAKAPP "$pkg" "$PKGAPPS" "$comps"
      ADDSTR "$pkg" "ADDED"
      DEKH "📥 Added: $label 📱\nℹ️ Version: $ver | Size: $size \n🧩 Parts: $comps"
      DEKH "✅ Backup complete for: $label"
    else
      sizes="$(PADH "$pkg" "$TMPLOC/sizes")"
      IFS=':' read -r asize dsize esize msize osize <<< "$sizes"
      DEKH "📦 [$MCNT] - $label ($ver) 📱" "h*"
      DEKH "🔊 Vol+ Press = App Only\n🔉 Vol- Press = Skip\n🔊 Vol+ Hold = App & Data \n🔉 Vol- Hold = Entire App"
      OPT "h"; Key=$?
      case "$Key" in
        0)
         size="$asize"; size=$(GETSIZE $size)
         BAKAPP "$pkg" "$PKGAPPS" "#App"
         ADDSTR "$pkg" "ADDED"
         DEKH "📥 Added App Only: $size 📱"
         DEKH "✅ Backup complete for: $label"
         ;;
        10)
         size="$((asize + dsize))"; size=$(GETSIZE $size)
         BAKAPP "$pkg" "$PKGAPPS" "#App #Data"
         ADDSTR "$pkg" "ADDED"
         DEKH "📥 Added App & Data: $size 📱"
         DEKH "✅ Backup complete for: $label"
         ;;
         11)
         size="$((asize + dsize + esize + msize + osize))"; size=$(GETSIZE $size)
         BAKAPP "$pkg" "$PKGAPPS" "#App #Data #ExtData #Media #Obb"
         ADDSTR "$pkg" "ADDED"
         DEKH "📥 Added Entire App: $size 📱"
         DEKH "✅ Backup complete for: $label"
         ;;
         *)
         ADDSTR "$pkg" "SKIPPED"
         ;;
      esac
    fi
    MCNT=$((MCNT + 1))
  }
  START=$(date +%s)
  PRSMOD "$APPMAP" "PSINSAPPS"
  COOLDOWN "1"
  END=$(date +%s)
  DURATION=$((END - START))
  MIN=$((DURATION / 60))
  SEC=$((DURATION % 60))
  DEKH "✅ All Apps Backup complete" "h"
  if [ "$MIN" -gt 0 ]; then
    DEKH "⏱️ Took: ${MIN}m ${SEC}s"
  else
    DEKH "⏱️ Took: ${SEC}s"
  fi
}

# Add LSPOSED Modules
LSMOD() {
  [ ! -d "$PKGMOD" ] && mkdir -p "$PKGMOD"
  MODMAP=""; PROCESSED=""
  LSMODLIST="$(find "$SDDIR" -type f -name "*.apk")"
 [ "$SELMODE" = "FILE" ] && {
    mkdir -p "$SELDIR"
    DEKH "📂 $(basename "$SELDIR") folder will open in a moment\n🗑️ Delete to Add LSPosed Modules\n🔉 Press any Vol Key to Finish" 2 &
  }
  DEKH "✅ Validating LSPosed Modules... Please wait"
  while IFS= read -r apk || [ -n "$apk" ]; do
    [ -f "$apk" ] || continue
    unzip -l "$apk" | grep -q "xposed_init" 2>/dev/null || continue
    info="$("$PORYGONZ" dump badging "$apk" 2>/dev/null)"
    pkg="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f2)"
    ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f6)"
    CHKDUP "$pkg-$ver" "PROCESSED" && continue
    ADDSTR "$pkg-$ver" "PROCESSED"
    label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"; label=$(SANITIZE "$label")
    [ -z "$label" ] && continue
    ADDSTR "$apk:$pkg:$label:$ver" "MODMAP"
    [ "$SELMODE" = "FILE" ] && > "$SELDIR/$label ($ver)"
  done <<< "$LSMODLIST"; wait
  [ "$SELMODE" = "FILE" ] && SELECT || DEKH "🔌 Press/Hold Power Button Anytime to Finish"
  PSLSMOD() {
    IFS=: read -r app pkg label ver <<< "$1"
    if [ "$SELMODE" = "FILE" ]; then
      cp -af "$apk" "$PKGMOD/$pkg.apk"
      ADDSTR "$pkg" "ADDED"
      DEKH "📥 Added: $label ($ver) 🧩"
    else
      CHKDUP "$pkg" "ADDED" && return
      CHKDUP "$pkg-$ver" "SKIPPED" && return
      DEKH "📦 [$MCNT] - $label ($ver) 🧩" "h*"
      DEKH "🔊 Vol+ = Add LSPosed Module in Bundle\n🔉 Vol- = Skip Module"
      OPT "h"; Key=$?
      if [ "$Key" -eq 0 ]; then
        cp -af "$apk" "$PKGMOD/$pkg.apk"
        ADDSTR "$pkg" "ADDED"
        DEKH "📥 Added: $label ($ver) 🧩"
      else
        ADDSTR "$pkg-$ver" "SKIPPED"
      fi
    fi
    MCNT=$((MCNT + 1))
  }
  PRSMOD "$MODMAP" "PSLSMOD"
}

# Add Local Apps
LOCAPPS() {
  [ ! -d "$PKGAPPS" ] && mkdir -p "$PKGAPPS"
  MODMAP=""; PROCESSED=""
  APPSLIST="$(find "$SDDIR" -type f \( -name "*.apk" -o -name "*.apks" -o -name "*.apkm" \))"
  [ "$SELMODE" = "FILE" ] && {
    mkdir -p "$SELDIR"
    DEKH "📂 $(basename "$SELDIR") folder will open in a moment\n🗑️ Delete to Add Local Apps\n🔉 Press any Vol Key to Finish" 2
  }
  DEKH "✅ Validating Local Apps... Please wait"
  while IFS= read -r app || [ -n "$app" ]; do
    [ -f "$app" ] || continue
    unzip -l "$app" | grep -q "xposed_init" 2>/dev/null && continue
    filename=$(basename "$app")
    case "$app" in
      *.apk)
        info="$("$PORYGONZ" dump badging "$app" 2>/dev/null)"
        ;;
      *.apks|*.apkm)
        mkdir -p "$TMPLOC/$filename"
        unzip -p "$app" "base.apk" > "$TMPLOC/$filename/base.apk" 2>/dev/null
        base="$TMPLOC/$filename/base.apk"
        info="$("$PORYGONZ" dump badging "$base" 2>/dev/null)"
        rm -rf "$TMPLOC/$filename"
        ;;
    esac
    pkg="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f2)"
    ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f6)"
    CHKDUP "$pkg-$ver" "PROCESSED" && continue
    ADDSTR "$pkg-$ver" "PROCESSED"
    label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"; label=$(SANITIZE "$label")
    [ -z "$label" ] && continue
    ADDSTR "$app:$pkg:$label:$ver" "MODMAP"
    [ "$SELMODE" = "FILE" ] && > "$SELDIR/$label ($ver)"
  done <<< "$APPSLIST"
  [ "$SELMODE" = "FILE" ] && SELECT || DEKH "🔌 Press/Hold Power Button Anytime to Finish"
  PSAPPS() {
    IFS=: read -r app pkg label ver <<< "$1"
    if [ "$SELMODE" = "FILE" ]; then
      ext="${app##*.}"
      cp -af "$app" "$PKGAPPS/$pkg.$ext"
      ADDSTR "$pkg" "ADDED"
      DEKH "📥 Added: $label ($ver) 📲"
    else
      CHKDUP "$pkg" "ADDED" && return
      CHKDUP "$pkg-$ver" "SKIPPED" && return
      DEKH "📦 [$MCNT] - $label ($ver) 📲" "h*"
      DEKH "🔊 Vol+ = Add App in Bundle\n🔉 Vol- = Skip App"
      OPT "h"; Key=$?
      if [ "$Key" -eq 0 ]; then
        ext="${app##*.}"
        cp -af "$app" "$PKGAPPS/$pkg.$ext"
        ADDSTR "$pkg" "ADDED"
        DEKH "📥 Added: $label ($ver) 📲"
      else
        ADDSTR "$pkg-$ver" "SKIPPED"
      fi
    fi
    MCNT=$((MCNT + 1))
  }
  PRSMOD "$MODMAP" "PSAPPS"
}

# Using Curl as a fallback, which have bad wget
URL() {
  local target="$1"
  local url="$2"
  if $BB wget -q -O "$target" "$url" --no-check-certificate; then
    return 0
  elif command -v curl >/dev/null 2>&1; then
    curl -sSL --insecure "$url" -o "$target"
    return $?
  else
    return 1
  fi
}

# Function to download a raw GitHub file
GITDOWN() {
  local repo="$1"
  local filepath="$2"
  local target="$3"
  local url="https://raw.githubusercontent.com/$repo/main/$filepath"
  mkdir -p "$(dirname "$target")"
  URL "$target" "$url"
}

# Backup Data
BAKDATA() {
# Fetch Database
if GITDOWN "ShivamXD6/Bundle-Mods" "data.sh" "$PKGDIR/data.sh"; then
  DEKH "✅ Using Remote Data"
else
  cp -af "$MODPATH/data.sh" "$PKGDIR/data.sh"
  DEKH "✅ Using Local Data"
fi
source "$PKGDIR/data.sh"
for i in "${!MOD_ID_PKG[@]}"; do
  id="${MOD_ID_PKG[$i]}"
  if [ -f "$PKGMOD/$id".* ]; then
    name=$(PADH name "$MODDIR/$id/module.prop" 2>/dev/null)
    [ -z "$name" ] && {
      apk=$(pm path "$id" | sed 's/^package://' | head -1)
      name=$(SANITIZE "$( "$PORYGONZ" dump badging "$apk" 2>/dev/null | grep -m1 "application-label:" | cut -d"'" -f2 )")
    }
    echo "${MOD_DATA[$i]}" | while IFS= read -r file; do
      if [ -f "$file" ]; then
        filename=$(basename "$file")
        DEKH "💾 Backing up: $name, 💿 Data: $filename"
        BAK "$file" "$MODDATA/$id"
      fi
    done
  fi
done
}

# Check which Rooting Implementation is running
if [ -d "$ADBDIR/magisk" ] && magisk -V >/dev/null 2>&1 || magisk -v >/dev/null 2>&1; then
  ROOT="Magisk"
  CMD="magisk --install-module"
  if echo "$(magisk magiskhide sulist 2>&1)" | grep -iq "SuList"; then
  ROOT="Kitsune"
  fi
elif [ -d "$ADBDIR/ksu" ] && ksud -V >/dev/null 2>&1 || ksud -v >/dev/null 2>&1; then
  ROOT="KernelSU"
  CMD="ksud module install"
elif [ -d "$ADBDIR/ap" ] && apd -V >/dev/null 2>&1 || apd -v >/dev/null 2>&1; then
  ROOT="APatch"
  CMD="apd module install"
else
  DEKH "🤖 Cannot determine rooting implementation, if you think it's a mistake, contact @BuildBytes" "hx" 2
  exit 1
fi

# Check Integrity
DEKH "🔎 Verifying Module Integrity, Please Wait" "h*"

# Check if is there any important file is missing
if [ ! -s "$Hashes" ] || [ ! -d "$VTD" ]; then
  DEKH "❌ Tampering detected:\n🧃 You removed the brain and expected it to think.\n➡️ Genius. Re-download, Einstein." "hx"
  exit 1
fi

# Check if there are any additional files
if [ "$ACTUAL_COUNT" -gt "$EXPECTED_COUNT" ]; then
  result="count_mismatch $EXPECTED_COUNT $ACTUAL_COUNT"
  exit_code=3
else
  result=$(awk -v VTD="$VTD" -v prefix_str="$PREFIX" -v infix_str="$INFIX" -v suffix_str="$SUFFIX" '
  BEGIN {
    split(prefix_str, prefix_arr, " ")
    split(infix_str, infix_arr, " ")
    split(suffix_str, suffix_arr, " ")
    echo_code = 0
    idx = 1
  }

  function scramble(md5, sha256, pfx, ifx, sfx) {
    combined = ""
    len_md5 = length(md5)
    len_sha256 = length(sha256)
    m = 1
    s = 1
    b_count = 2
    while (m <= len_md5 || s <= len_sha256) {
      if (m <= len_md5) {
        combined = combined substr(md5, m, 1)
        m++
      }
      for (i = 0; i < b_count && s <= len_sha256; i++) {
        combined = combined substr(sha256, s, 1)
        s++
      }
      b_count++
    }
    mid = int(length(combined)/2)
    return pfx substr(combined, 1, mid) ifx substr(combined, mid+1) sfx
  }

  {
    hashedup = $1
    script = substr($0, length($1) + 2)
    gsub(/"/, "", script)
    gsub(/^\.\/+/, "", script)
    script = VTD "/" script

    if (system("[ -f \"" script "\" ]") == 0) {
    "sha256sum \"" script "\"" | getline current_sha256
    "md5sum \"" script "\"" | getline current_md5
    split(current_sha256, arr_sha256)
    split(current_md5, arr_md5)
    current_sha256 = arr_sha256[1]
    current_md5 = arr_md5[1]

    pfx = (idx in prefix_arr) ? prefix_arr[idx] : ""
    ifx = (idx in infix_arr) ? infix_arr[idx] : ""
    sfx = (idx in suffix_arr) ? suffix_arr[idx] : ""

    expected_combined = scramble(current_md5, current_sha256, pfx, ifx, sfx)
    if (hashedup != expected_combined) {
      echo_code = 1
      print "corrupted " script
      exit echo_code
    }
    } else {
      echo_code = 2
      print "not_found " script
      exit echo_code
    }

    idx++
  }

  END { exit echo_code }
  ' "$Hashes")
  exit_code=$?
fi

# Exit Installation if anything wrong with module
case $exit_code in
  1)
    corrupted_file=$(echo "$result" | awk '/^corrupted/ {print $2}')
    DEKH "❌ Module is Modified: $(basename "$corrupted_file")\n🧬 Your edits in $(basename "$corrupted_file") mutated the module into a meme.\n➡️ Re-download before it goes viral." "hx"
    exit 1
    ;;
  2)
    not_found_file=$(echo "$result" | awk '/^not_found/ {print $2}')
    DEKH "❌ File not found: $(basename "$not_found_file")\n🕵️ Someone thought deleting $(basename "$not_found_file") would hide their tracks.\n➡️ It didn’t." "hx"
    exit 2
    ;;
  3)
    mismatch_info=$(echo "$result" | awk '/^count_mismatch/ {print "Expected: " $2 ", Found: " $3}')
    DEKH "❌ Unauthorized tampering:\n🧨 Injected files spotted.\n➡️ $mismatch_info\n🤡 Nice try, but this module isn’t your playground." "hx"
    exit 3
    ;;
  *)
    DEKH "✅ Module Integrity Verified"
    rm -rf $Hashes
    ;;
esac

# Start Flashing Module
source "$MODPATH/flash.sh"
