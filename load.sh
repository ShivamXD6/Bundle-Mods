#!/system/bin/sh
# Variables and Functions
[ -z "$MODPATH" ] && MODPATH="${0%/*}"
TMPDIR="$(mktemp -d 2>/dev/null)" || TMPDIR="/dev/tmp"
chmod 700 "$TMPDIR"
[ -z "$MODPATH" ] && MODPATH="${0%/*}"
VTD="$TMPDIR/.verify"
mkdir -p "$VTD"
unzip -o "$ZIPFILE" -d "$VTD" >&2
PREFIX=' 8ec8edaf922f2b57 8219ca25dff4 11cf60910a641f a7a9c42f3db26c15 989344 3a9e4b7b 3599de87a9aeec 55e1a35c 5105b63bfe65f60f cda4daa5a6 26f7e2c81e74b972'
INFIX=' 3cce6a371e99d55f a12c2f151e 40ab31 a1a870de7d26b7 62d54ac0 24d9796f 713578 0c2900dfcd403a 80c18652 bc0b83a1f5e0a000 4e56cd45265e37'
SUFFIX=' 73563a982bece375 eba545b4c844 bd032c2f714971 0766e0 a28fb0ae 08684246e5 241c7b889d4d05 5ecbe9 ae9790368d9fc9 afb3e342 8fb4173f33'
EXPECTED_COUNT=12
ACTUAL_COUNT=$(find "$VTD" -type f | wc -l)
export TMPLOC="/data/local/tmp"
mkdir -p "$TMPLOC"
ADBDIR="/data/adb"
MODDIR="$ADBDIR/modules"
SDDIR=$(realpath "/sdcard")
DOWNDIR="$SDDIR/Download"
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
8ec8edaf922f2b576d3044d482c5a3340d373329641a64ae73538550128d60c53cce6a371e99d55ff7d81d21bc6738a040676dd4d72957efe9dc377a9832e04173563a982bece375 "./zip32"
8219ca25dff4b97d7d21e525758174399e69021d55bed4783b52f83161cfa12c2f151e99c45ba59f29ca3aea32e431da15d50f87de25cea601d848eba545b4c844 "./zip"
11cf60910a641f6e9c2c8917a39c68de524000651c81e5b4fca88ef38b483340ab3107cba5e8781b376d2bc3b29766446fd1137d8bcd7bbb7ef9bd032c2f714971 "./customize.sh"
a7a9c42f3db26c15fbc4a109f1f0f133b569293d2c35866da41e506ded3899cea1a870de7d26b799672dd44673e186bf9181eafa856fcea5b2210d4e9dd53a0766e0 "./bundle"
989344f9f284681331fe803ec1170fdbe7df4c7affd79b003f625262d54ac0c0bcde934f53b7c82ffc0400fbe1efaf81e6d980de72049ea28fb0ae "./aapt"
3a9e4b7b1eb488d62043e3c9dddbec5316d0d15761f348e79f18e48124d9796fe62a610654f2602abadaed1dbf307b57220916652601574008684246e5 "./module.prop"
3599de87a9aeec17a9b7208584c92c5ff43f768580409212a46d6ba522b09571357809a7d4aaac665676e1e8658f19855ad28abf42913bfc1509241c7b889d4d05 "./aapt32"
55e1a35cbd23b8290319c3a083de43ad0176fde017b9c7821e80aa520c2900dfcd403a1e1f98077b8628f2b1cdb70c603d60d67de5c5b81a78c2425ecbe9 "./META-INF/com/google/android/updater-script"
5105b63bfe65f60f7d3c324633a133bcc6a0a3fc00d762ea65a66a542f7d614680c18652146d09389e0863517a334777ba4ee1c0660ba3ae993aa9b6ae9790368d9fc9 "./META-INF/com/google/android/update-binary"
cda4daa5a63d17014b7ca7f4922e873bc84fc180f6352359248d1653a5bc0b83a1f5e0a00082e0472d7cfb07f8ca1f60121c93c9258ce021d44083fec3afb3e342 "./data.sh"
26f7e2c81e74b9728140df191bb025cdb42b224eacb97dcb9ddef17fbfb09e8a4e56cd45265e3706c320051c0847441da84931b8d492d5d656773ffe0006ae8fb4173f33 "./flash.sh"
HASHED

# Display UI
DEKH() {
  orgsandesh="$1"; samay="${2:-0.2}"; prakar="${3}"
  [[ "$2" == h* ]] && prakar="${2}" && samay="${3:-0.2}"
  echo "$orgsandesh" | grep -q '[^ -~]' && sandesh=" $orgsandesh" || sandesh=" $orgsandesh "
  rekha=$(printf "%s\n" "$sandesh" | awk '{ print length }' | sort -nr | head -n1)
  [ "$rekha" -gt 50 ] && rekha=50
  akshar=(= - ~ '*' + '<' '>')
  [[ "$prakar" == h* ]] && {
    shabd="${prakar#h}"; [ -z "$shabd" ] && shabd="${akshar[RANDOM % ${#akshar[@]}]}"
    echo; printf '%*s\n' "$rekha" '' | tr ' ' "$shabd"
    echo -e "$sandesh"
    printf '%*s\n' "$rekha" '' | tr ' ' "$shabd"
  } || echo -e "$orgsandesh"
  sleep "$samay"
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

# Random 6-10 digits string
RAND() {
  len=$((RANDOM % 3 + 3))
  head -c "$len" /dev/urandom | xxd -p
}

# Count Strings from Registry
CNTMODS() {
  eval "printf '%s\n' \"\${$1}\"" | grep -c '.'
}

# Add Strings in Registry
ADDSTR() {
  eval "$2=\${$2:+\${$2}\$'\n'}\$1"
}

# Check for Duplicate Strings in Registry
CHKDUP() {
  eval "printf '%s\n' \"\${$2}\"" | grep -Fxq -- "$1"
}

# Remove Strings from Registry
DELSTR() {
  eval "$2=\$(printf '%s\n' \"\${$2}\" | grep -Fxv -- \"\$1\")"
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

# Show Progress Bar Dynamically
PROGRESS() {
  cur=$1 total=$2
  w=30 p=$((cur * 100 / total)) f=$((p * w / 100))
  bar="$(printf '%*s' "$f" | tr ' ' '#')$(printf '%*s' $((w - f)) | tr ' ' '-')"
  now=$(date +%s)
  [ -z "$start" ] && start=$now
  [ -z "$last" ] && last=0
  delay=$(( total < 25 ? 1 : total < 50 ? 2 : total < 100 ? 3 : total < 200 ? 4 : 5 ))
  interval=$((now - last))
  [ "$cur" -ne "$total" ] && [ "$interval" -lt "$delay" ] && return
  printf "\r[%s] %3d%% (%d/%d)" "$bar" "$p" "$cur" "$total"
  [ "$cur" -eq "$total" ] && echo && echo
  last=$now
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

# Backup multiple Files and Folders with their Metadata
BAKBULK() {
  src="$1"
  dest="$2"
  rootname="$(basename "$src")"
  rootdest="$dest/$rootname"
  metafile="$dest/${rootname}.meta"
  mkdir -p "$rootdest"
  total=$(find "$src" -mindepth 1 | wc -l)
  count=0
  find "$src" -mindepth 1 | while IFS= read -r item; do
    rel="${item#$src/}"
    target="$rootdest/$rel"
    dir="$(dirname "$target")"
    [ -d "$dir" ] || mkdir -p "$dir"
    [ -f "$item" ] && cp -af "$item" "$target"
    [ -d "$item" ] && mkdir -p "$target"
    perm=$(stat -c "%a" "$item")
    time=$(stat -c "%Y" "$item")
    echo "$rel $perm $time" >> "$metafile"
    count=$((count + 1))
    PROGRESS "$count" "$total"
  done
  echo ". $(stat -c "%a" "$src") $(stat -c "%Y" "$src")" >> "$metafile"
}

# Process list safely with spaces (Mod List & Function)
PRSMOD() {
  TMPFILE="$TMPLOC/list.txt"
  echo "$1" > "$TMPFILE"
  while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    "$2" "$line"
  done < "$TMPFILE"
  rm -f "$TMPFILE"
}

# Check for file is an app
IS_PKG() {
  case "$1" in
    *.*) return 0 ;;
    *) return 1 ;;
  esac
}

# Check if app is installed or not
PKG_INSTALLED() {
  IS_PKG "$1" || return 1
  pm list packages | grep -q "^package:$1$"
}

# Add Custom Script
CUS_SCRIPT() {
  TYP="$1"
  mkdir -p "$SRPTDIR"
  DEKH "📂 Opening folder: '$SELSRT'" 1
  DEKH "📜 Copy your $TYP script here." 1
  DEKH "🔉 Press any Volume Key to skip." 2
  am start -a android.intent.action.VIEW -d content://com.android.externalstorage.documents/document/primary:Download%2F$SELSRT >/dev/null 2>&1
  while true; do
    Key=124
    [ -f "$SRPTDIR"/*.sh ] && break
    timeout 1 OPT h && Key=$?
    [ "$Key" -lt 124 ] && break
    sleep 1
  done
  am force-stop com.android.documentsui >/dev/null 2>&1
  am force-stop com.google.android.documentsui >/dev/null 2>&1
  sleep 1
  SCRIPT=$(ls "$SRPTDIR"/*.sh 2>/dev/null | head -n 1)
  if [ -n "$SCRIPT" ]; then
    cp -af "$SCRIPT" "$PKGDIR/$TYP.sh"
    DEKH "✅ $TYP script added: $(basename "$SCRIPT")" 1
  else
    DEKH "👀 No $TYP script detected. Skipping..." 1
  fi
  rm -rf "$SRPTDIR"
}

# Select or Detect deletion of Files
SELECT() {
  am start -a android.intent.action.VIEW -d content://com.android.externalstorage.documents/document/primary:Download%2F$SELFLD >/dev/null 2>&1
  OPT
  SELECTED=""
  DEKH "✔️ Processing your selections..."
  while IFS= read -r entry || [ -n "$entry" ]; do
    id="$(echo "$entry" | cut -d: -f2)"
    name="$(echo "$entry" | cut -d: -f3)"
    ver="$(echo "$entry" | cut -d: -f4-)"
    if [ ! -e "$SELDIR/$name ($ver)" ]; then
      CHKDUP "$id" "SELECTED" || ADDSTR "$id" "SELECTED"
    else
      CHKDUP "$id-$ver" "SKIPPED" || ADDSTR "$id-$ver" "SKIPPED"
    fi
  done <<< "$MODMAP"
  [ -z "$SELECTED" ] && DEKH "⚠️ No modules/apps selected"
  am force-stop com.android.documentsui
  am force-stop com.google.android.documentsui
  sleep 1
  rm -rf "$SELDIR"
}

# Add Local Modules in Bundle
LOCMOD() {
  [ ! -d "PKGMOD" ] && mkdir -p "PKGMOD"
  MODMAP=""
  [ "$SELMODE" = "FILE" ] && mkdir -p "$SELDIR"
  DEKH "✅ Validating Local Modules... Please wait"
  ZMODLIST="$(find "$SDDIR" -type f -name "*.zip")"
  while IFS= read -r module || [ -n "$module" ]; do
    [ -f "$module" ] || continue
    filename="$(basename "$module")"
    unzip -l "$module" | grep -q "module.prop" 2>/dev/null || continue
    prop="$TMPLOC/module.prop"
    unzip -p "$module" "module.prop" > "$prop" 2>/dev/null
    [ -s "$prop" ] || continue
    modid="$(PADH id "$prop")"
    [ "$modid" = "bundle-mods" ] && continue
    modname="$(PADH name "$prop")"
    modver="$(PADH version "$prop")"
    ADDSTR "$module:$modid:$modname:$modver" "MODMAP"
    [ "$SELMODE" = "FILE" ] && touch "$SELDIR/$modname ($modver)"
  done <<< "$ZMODLIST"
  [ "$SELMODE" = "FILE" ] && DEKH "📂 Opening $(basename "$SELDIR") folder" 1 && DEKH "🗑️ Delete to ADD Local Modules" 1 && DEKH "🔉 Press any Vol Key to Finish" 2 && SELECT
  PSLOCMOD() {
  entry="$1"
  module="$(echo "$entry" | cut -d: -f1)"
  modid="$(echo "$entry" | cut -d: -f2)"
  modname="$(echo "$entry" | cut -d: -f3)"
  modver="$(echo "$entry" | cut -d: -f4-)"
  CHKDUP "$modid" "ADDED" && return
  CHKDUP "$modid-$modver" "SKIPPED" && return
  if [ "$SELMODE" = "FILE" ]; then
    CHKDUP "$modid" "SELECTED" || return
    cp -af "$module" "$PKGMOD/$(basename "$module")"
    ADDSTR "$modid" "ADDED"
    DEKH "📥 Added: $modname ($modver) 🔗"
  else
    DEKH "\n📦 [$MCNT] - $modname ($modver) 🔗"
    DEKH "🔊 Vol+ = Add Module in Bundle\n🔉 Vol- = Skip Module"
    OPT
    if [ $? -eq 0 ]; then
      cp -af "$module" "$PKGMOD/$modname"
      ADDSTR "$modid" "ADDED"
      DEKH "📥 Added: $modname ($modver) 🔗"
    else
      ADDSTR "$modid-$modver" "SKIPPED"
    fi
  fi
  MCNT=$((MCNT + 1))
  }
  PRSMOD "$MODMAP" "PSLOCMOD"
  rm -f "$TMPLOC/module.prop"
}

# Add LSPOSED Modules
LSMOD() {
  [ ! -d "$PKGMOD" ] && mkdir -p "$PKGMOD"
  MODMAP=""
  LSMODLIST="$(find "$SDDIR" -type f -name "*.apk")"
  [ "$SELMODE" = "FILE" ] && mkdir -p "$SELDIR"
  DEKH "✅ Validating LSPosed Modules... Please wait"
  while IFS= read -r apk || [ -n "$apk" ]; do
    [ -f "$apk" ] || continue
    unzip -l "$apk" | grep -q "xposed_init" 2>/dev/null || continue
    info="$("$AAPT" dump badging "$apk" 2>/dev/null)"
    pkg="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f2)"
    label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"
    ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f4)"
    ADDSTR "$apk:$pkg:$label:$ver" "MODMAP"
    [ "$SELMODE" = "FILE" ] && touch "$SELDIR/$label ($ver)"
  done <<< "$LSMODLIST"
  [ "$SELMODE" = "FILE" ] && DEKH "📂 Opening $(basename "$SELDIR") folder" 1 && DEKH "🗑️ Delete to ADD LSPosed Modules" 1 && DEKH "🔉 Press any Vol Key to Finish" 2 && SELECT
  PSLSMOD() {
    entry="$1"
    apk="$(echo "$entry" | cut -d: -f1)"
    pkg="$(echo "$entry" | cut -d: -f2)"
    label="$(echo "$entry" | cut -d: -f3)"
    ver="$(echo "$entry" | cut -d: -f4-)"
    CHKDUP "$pkg" "ADDED" && return
    CHKDUP "$pkg-$ver" "SKIPPED" && return
    if [ "$SELMODE" = "FILE" ]; then
      CHKDUP "$pkg" "SELECTED" || return
      cp -af "$apk" "$PKGMOD/$label.apk"
      ADDSTR "$pkg" "ADDED"
      DEKH "📥 Added: $label ($ver)🧩"
    else
      DEKH "\n📦 [$MCNT] - $label ($ver)🧩"
      DEKH "🔊 Vol+ = Add LSPosed Module in Bundle\n🔉 Vol- = Skip Module"
      OPT
      if [ $? -eq 0 ]; then
        cp -af "$apk" "$PKGMOD/$label.apk"
        ADDSTR "$pkg" "ADDED"
        DEKH "📥 Added: $label ($ver)🧩"
      else
        ADDSTR "$pkg" "SKIPPED"
      fi
    fi
    MCNT=$((MCNT + 1))
  }
  PRSMOD "$MODMAP" "PSLSMOD"
}

# Add Local Apps
LOCAPPS() {
  [ ! -d "$PKGAPPS" ] && mkdir -p "$PKGAPPS"
  MODMAP=""
  APPSLIST="$(find "$SDDIR" -type f \( -name "*.apk" -o -name "*.apks" -o -name "*.apkm" \))"
  [ "$SELMODE" = "FILE" ] && mkdir -p "$SELDIR"
  DEKH "✅ Validating Apps... Please wait"
  while IFS= read -r app || [ -n "$app" ]; do
    [ -f "$app" ] || continue
    unzip -l "$app" | grep -q "xposed_init" 2>/dev/null && continue
    filename=$(basename "$app")
    case "$app" in
      *.apk)
        info="$("$AAPT" dump badging "$app" 2>/dev/null)"
        ;;
      *.apks|*.apkm)
        mkdir -p "$TMPLOC/$filename"
        unzip -p "$app" "base.apk" > "$TMPLOC/$filename/base.apk" 2>/dev/null
        base="$TMPLOC/$filename/base.apk"
        info="$("$AAPT" dump badging "$base" 2>/dev/null)"
        rm -rf "$TMPLOC/$filename"
        ;;
    esac
    pkg="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f2)"
    label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"
    ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f4)"
    ADDSTR "$app:$pkg:$label:$ver" "MODMAP"
    [ "$SELMODE" = "FILE" ] && touch "$SELDIR/$label ($ver)"
  done <<< "$APPSLIST"
  [ "$SELMODE" = "FILE" ] && DEKH "📂 Opening $(basename "$SELDIR") folder" 1 && DEKH "🗑️ Delete to ADD an App" 1 && DEKH "🔉 Press any Vol Key to Finish" 2 && SELECT
  PSAPPS() {
    entry="$1"
    app="$(echo "$entry" | cut -d: -f1)"
    pkg="$(echo "$entry" | cut -d: -f2)"
    label="$(echo "$entry" | cut -d: -f3)"
    ver="$(echo "$entry" | cut -d: -f4-)"
    CHKDUP "$pkg" "ADDED" && return
    CHKDUP "$pkg-$ver" "SKIPPED" && return
    if [ "$SELMODE" = "FILE" ]; then
      CHKDUP "$pkg" "SELECTED" || return
      ext="${app##*.}"
      cp -af "$app" "$PKGAPPS/$label.$ext"
      ADDSTR "$pkg" "ADDED"
      DEKH "📥 Added: $label ($ver)📱"
    else
      DEKH "\n📦 [$MCNT] - $label ($ver)📱"
      DEKH "🔊 Vol+ = Add App in Bundle\n🔉 Vol- = Skip App"
      OPT
      if [ $? -eq 0 ]; then
        ext="${app##*.}"
        cp -af "$app" "$PKGAPPS/$label.$ext"
        ADDSTR "$pkg" "ADDED"
        DEKH "📥 Added: $label ($ver)📱"
      else
        ADDSTR "$pkg" "SKIPPED"
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
  if busybox wget -q -O "$target" "$url" --no-check-certificate; then
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
  CHKDUP "$id" "ADDED" && continue
    name=$(PADH name "$MODDIR/$id/module.prop" 2>/dev/null)
    name=${name:-$id}
    DEKH "${MOD_DATA[$i]}" | while IFS= read -r file; do
      if [ -f "$file" ]; then
        filename=$(basename "$file")
        DEKH "💾 Backing up: $name, 💿 Data: $filename"
        BAK "$file" "$MODDATA/$id"
        ADDSTR "$id" "ADDED"
      fi
    done
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
