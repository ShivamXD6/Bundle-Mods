#!/system/bin/sh
# Setup Environment (Variables & Functions)
[ -z "$MODPATH" ] && MODPATH="${0%/*}"
TMPDIR="$(mktemp -d 2>/dev/null)" || TMPDIR="/dev/tmp"
chmod 700 "$TMPDIR"
[ -z "$MODPATH" ] && MODPATH="${0%/*}"
ADBDIR="/data/adb"
export TMPLOC="/data/local/tmp"
mkdir -p "$TMPLOC"
MODDIR="$ADBDIR/modules"
MUPDIR="$ADBDIR/modules_update"
SDDIR=$(realpath "/sdcard")
EXTSD=$(find /storage -mindepth 1 -maxdepth 1 -type d 2>/dev/null | grep -Ev '/(emulated|self)' | grep -E '/[0-9A-Z]{4,}-[0-9A-Z]{4,}$' | head -n 1)
PKGMOD="$MODPATH/MODULES"
PKGAPPS="$MODPATH/APPS"
MODDATA="$PKGMOD/DATA"
ARCH=$(getprop ro.product.cpu.abi)
PORYGONZ="$MODPATH/porygonz"
ZAPDOS="$MODPATH/zapdos"
chmod +x "$PORYGONZ" "$ZAPDOS"

# Only 64-Bit Supported
echo "$ARCH" | grep -qE 'arm64-v8a' || {
  DEKH "🧨 This module requires a 64-bit environment. Exiting..."
  exit 1
}

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

# Read Files
PADH() {
  value=$(grep -m 1 "^$1=" "$2" | sed 's/^.*=//')
  echo "${value//[[:space:]]/ }"
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

# Restore any single File or Folder with it's Metadata
RST() {
  src="$1"
  dest="$2"
  meta="$src.meta"
  [ -f "$meta" ] || return 1
  [ -f "$src" ] || return 1
  destdir="$(dirname "$dest")"
  [ ! -d "$destdir" ] && mkdir -p "$destdir" && own=1
  cp -af "$src" "$dest"
  read perm time < "$meta"
  [ "$own" -eq 1 ] && owndir="$(dirname "$destdir")" || owndir="$destdir"
  uid=$(stat -c "%u" "$owndir")
  gid=$(stat -c "%g" "$owndir")
  chmod "$perm" "$dest"
  chown "$uid:$gid" "$dest"
  touch -d "@$time" "$dest"
}

# Restore multiple Files and Folders with their Metadata 
RSTBULK() {
  src="$1"
  dest="$2"
  metafile="${src}.meta"
  mkdir -p "$dest"
  uid=$(stat -c "%u" "$dest")
  gid=$(stat -c "%g" "$dest")
  total=$(find "$src" -mindepth 1 | wc -l)
  count=0
  find "$src" -mindepth 1 | while IFS= read -r item; do
    rel="${item#$src/}"
    target="$dest/$rel"
    [ -f "$item" ] && cp -af "$item" "$target"
    [ -d "$item" ] && mkdir -p "$target"
    chown "$uid:$gid" "$target"
    count=$((count + 1))
    PROGRESS "$count" "$total"
  done
  [ -f "$metafile" ] && while IFS= read -r line; do
    set -- $line
    path="$1" perm="$2" time="$3"
    [ -z "$path" ] || [ -z "$perm" ] || [ -z "$time" ] && continue
    target="$dest/$path"
    [ -e "$target" ] || continue
    chmod "$perm" "$target"
    touch -d "@$time" "$target"
  done < "$metafile"
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

# Fetch and Display All Modules
SHOWMODS() {
  mcnt=1
  DEKH "🚀 Preparing to install the following:" "h"
  PSSHOWZIP() {
    type="🖇️"
    unzip -l "$1" | awk '{print $NF}' | grep -q '^lib/' && ADDSTR "$1" "PMODLIST" && type="⚡"
    unzip -l "$1" | grep -q "module.prop" || return
    unzip -p "$1" "module.prop" > "$TMPLOC/module.prop" 2>/dev/null
    [ -s "$TMPLOC/module.prop" ] || return
    modname=$(PADH name "$TMPLOC/module.prop")
    modver=$(PADH version "$TMPLOC/module.prop")
    DEKH "📦 [$mcnt] $modname ($modver) $type"
    mcnt=$((mcnt + 1))
    rm -f $TMPLOC/module.prop
  }
  PSSHOWLSMOD() {
    info="$("$AAPT" dump badging "$1" 2>/dev/null)"
    label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"
    ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f4)"
    DEKH "📦 [$mcnt] $label ($ver) 🧩"
    mcnt=$((mcnt + 1))
  }
  PSSHOWAPPS() {
    filename=$(basename "$1")
    case "$1" in
      *.apk)
        info="$("$AAPT" dump badging "$1" 2>/dev/null)" ;;
      *.apks|*.apkm)
        mkdir -p "$TMPLOC/$filename"
        unzip -p "$1" "base.apk" > "$TMPLOC/$filename/base.apk" 2>/dev/null
        base="$TMPLOC/$filename/base.apk"
        info="$("$AAPT" dump badging "$base" 2>/dev/null)"
        rm -rf "$TMPLOC/$filename" ;;
    esac  
    label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"
    ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f4)"
    DEKH "📦 [$mcnt] $label ($ver) 📱"
    mcnt=$((mcnt + 1))
  }
  [ -d "$PKGMOD" ] && {
  PRSMOD "$ZMODLIST" "PSSHOWZIP"
  PRSMOD "$LSMODLIST" "PSSHOWLSMOD"
  }
  [ -d "$PKGAPPS" ] && PRSMOD "$APPSLIST" "PSSHOWAPPS"
  DEKH "❓ Do you want to continue with installation?" "h"
  DEKH "🔊 Vol+ = Yes\n🔉 Vol- = No"
  OPT
  [ $? -eq 0 ] || exit 1  
}

# Install Modules or Apps
INSTALL() {
  mcnt=1
  cd $TMPLOC
  PSZIPMOD() {
    filename=$(basename "$1")
    unzip -l "$1" | grep -q "module.prop" || return
    unzip -p "$1" "module.prop" > "$TMPLOC/module.prop" 2>/dev/null
    [ -s "$TMPLOC/module.prop" ] || return
    modid=$(PADH id "$TMPLOC/module.prop")
    CHKDUP "$modid" "INSTALLED" && return
    modname=$(PADH name "$TMPLOC/module.prop")
    modver=$(PADH version "$TMPLOC/module.prop")
    DEKH "📦 [$mcnt] $modname ($modver) $type" 1 "h*"
    cp -af "$1" "$TMPLOC/$modid.zip"
    su -c "$CMD '$TMPLOC/$modid.zip'" 2>/dev/null || DEKH "❌ Failed to install $modname ($modver)" "hx" 1
    mcnt=$((mcnt + 1))
    ADDSTR "$modid" "INSTALLED"
    rm -f $TMPLOC/module.prop $TMPLOC/$modid.zip
  }
  PSLSMOD() {
    filename=$(basename "$1")
    unzip -l "$1" | grep -q "xposed_init" 2>/dev/null || return
    info="$("$AAPT" dump badging "$1" 2>/dev/null)"
    pkg="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f2)"
    CHKDUP "$pkg" "INSTALLED" && return
    label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"
    ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f4)"
    DEKH "📦 [$mcnt] $label ($ver) 🧩" 1 "h*"
    cp -af "$1" "$TMPLOC/$filename"
    pm install $filename >/dev/null 2>&1 && DEKH "✅ Installed $label ($ver) 🧩" || DEKH "❌ Failed to install $label ($ver)" "hx" 1
    mcnt=$((mcnt + 1))
    ADDSTR "$pkg" "INSTALLED"
    rm -f $TMPLOC/$pkg.apk
  }
  PSAPPS() {
    filename=$(basename "$1")
    unzip -l "$1" | grep -q "xposed_init" 2>/dev/null && return
    case "$1" in
    *.apk)
      info="$("$AAPT" dump badging "$1" 2>/dev/null)"
      pkg="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f2)"
      CHKDUP "$pkg" "INSTALLED" && return
      label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"
      ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f4)"
      DEKH "📦 [$mcnt] $label ($ver) 📱" 1 "h*"
      cp -af "$1" "$TMPLOC/$filename"
      pm install $filename >/dev/null 2>&1 && DEKH "✅ Installed $label ($ver) 📱" || DEKH "❌ Failed to install $label ($ver)" "hx" 1
      rm -f $TMPLOC/$pkg.apk
      ;;
    *.apks|*.apkm)
      unzip -q "$1" -d "$TMPLOC/$filename" 
      base="$TMPLOC/$filename/base.apk"
      info="$("$AAPT" dump badging "$base" 2>/dev/null)"
      pkg="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f2)"
      CHKDUP "$pkg" "INSTALLED" && return
      label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"
      ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f4)"
      DEKH "📦 [$mcnt] $label ($ver) 📱" 1 "h*"
      apks=$(find "$TMPLOC/$filename" -name "*.apk" | sort)
      pm install -i '$pkg' $apks >/dev/null 2>&1 && DEKH "✅ Installed $label ($ver) 📱" || DEKH "❌ Failed to install $label ($ver)" "hx" 1
      rm -f $TMPLOC/$filename
      ;;
    esac
    mcnt=$((mcnt + 1))
    ADDSTR "$pkg" "INSTALLED"
  }
  [ -d "$PKGMOD" ] && {
  type="⚡"; PRSMOD "$PMODLIST" "PSZIPMOD"
  type="🖇️"; PRSMOD "$ZMODLIST" "PSZIPMOD"
  PRSMOD "$LSMODLIST" "PSLSMOD"
  }
  [ -d "$PKGAPPS" ] && PRSMOD "$APPSLIST" "PSAPPS"
}

# Restore Modules Data if any
RSTDATA() {
  source "$MODPATH/data.sh"
  DEKH "💾 Restoring Modules Data" 1 "h"
  for i in "${!MOD_ID_PKG[@]}"; do
    id="${MOD_ID_PKG[$i]}"
    name=$(PADH name "$MODDIR/$id/module.prop" 2>/dev/null)
    name=${name:-$id}
    if PKG_INSTALLED "$id" || [ -d "$MODDIR/$id" ]; then
      DEKH "${MOD_DATA[$i]}" | while IFS= read -r file; do
        fname="$(basename "$file")"
        src="$MODDATA/$id/$fname"
        [ -f "$src" ] || continue
        DEKH "🔁 Restoring: $name, 💿 Data: $fname"
        RST "$src" "$file"
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
  DEKH "🤖?? Cannot determine rooting implementation, if you think it's a mistake, contact @ShastikXD" "hx"
  exit 1
fi
# Start Flashing Module
source "$MODPATH/flash.sh"
