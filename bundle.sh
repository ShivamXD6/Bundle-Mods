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
PKGMOD="$MODPATH/MODULES"
PKGAPPS="$MODPATH/APPS"
MODDATA="$PKGMOD/DATA"
ARCH=$(getprop ro.product.cpu.abi)
[ -d "$PKGMOD" ] && {
ZMODLIST=$(find "$PKGMOD" -type f -name "*.zip")
LSMODLIST=$(find "$PKGMOD" -type f -name "*.apk")
}
[ -d "$PKGAPPS" ] && APPSLIST="$(find "$PKGAPPS" -type f \( -name "*.apk" -o -name "*.apks" -o -name "*.apkm" \))"
PMODLIST=""
INSTALLED=""
chmod +x "$MODPATH/aapt" "$MODPATH/aapt32"

# Display UI
DEKH() {
  orgsandesh="$1"; samay="${2:-0.2}"; prakar="${3}"
  [[ "$2" == h* ]] && prakar="${2}" && samay="${3:-0.5}"
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
    [ -n "$down_event" ] || continue
    t1=$(date +%s%3N)
    while true; do
      up_event=$(getevent -qlc 1 | grep "UP" | grep "KEY_" | awk '{print $3}')
      [ "$up_event" = "$down_event" ] && break
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
    key="${keyinfo%%:*}"
    dur="${keyinfo##*:}"
    case $key in
      KEY_VOLUMEUP) [ "$mode" = "h" ] && [ "$dur" -ge 500 ] && return 10 || return 0 ;;
      KEY_VOLUMEDOWN) [ "$mode" = "h" ] && [ "$dur" -ge 500 ] && return 11 || return 1 ;;
      KEY_POWER) [ "$mode" = "h" ] && [ "$dur" -ge 500 ] && return 12 || return 2 ;;
      *) DEKH "❌ Invalid Input! Key: $key ($dur ms)" "hx" ;;
    esac
    break
  done
}

# Pick Binary whichever works
PICKBIN() {
  "$1" --help >/dev/null 2>&1 && echo "$1" || echo "$2"
}

ZIP=$(PICKBIN "$MODPATH/zip32" "$MODPATH/zip")
AAPT=$(PICKBIN "$MODPATH/aapt32" "$MODPATH/aapt")

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
  fname="$(basename "$src")"
  meta="$src.meta"
  [ -f "$meta" ] || return 1
  [ -e "$dest" ] && rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  if grep -q "^symlink=" "$meta"; then
    link=$(cut -d= -f2 < "$meta")
    ln -s "$link" "$dest"
  elif [ -f "$src" ]; then
    cp "$src" "$dest"
    read perm uid gid time < "$meta"
    chmod "$perm" "$dest"
    chown "$uid:$gid" "$dest"
    touch -d "@$time" "$dest"
  fi
}

# Restore multiple Files and Folders with their Metadata 
RSTBULK() {
  src="$1"
  dest="$2"
  rootname="$(basename "$src")"
  rootdest="$dest/$rootname"
  metadir="${src}.meta"
  mkdir -p "$rootdest"
  total=$(find "$src" -mindepth 1 | wc -l)
  count=0
  find "$src" -mindepth 1 | while IFS= read -r item; do
    rel="${item#$src/}"
    target="$rootdest/$rel"
    grep -q "^$rel ->" "$metadir/symlinks.txt" 2>/dev/null && continue
    if [ -f "$item" ]; then
      cp "$item" "$target"
    elif [ -d "$item" ]; then
      mkdir -p "$target"
    fi
    count=$((count + 1))
    PROGRESS "$count" "$total"
  done
  [ -f "$metadir/symlinks.txt" ] && while IFS= read -r line; do
    rel="${line%% ->*}"
    link="${line#*-> }"
    ln -s "$link" "$rootdest/$rel"
  done < "$metadir/symlinks.txt"
  [ -f "$metadir/permissions.txt" ] && while IFS= read -r line; do
    set -- $line
    chmod "$2" "$rootdest/$1"
  done < "$metadir/permissions.txt"
  [ -f "$metadir/ownership.txt" ] && while IFS= read -r line; do
    set -- $line
    chown "$2:$3" "$rootdest/$1"
  done < "$metadir/ownership.txt"
  [ -f "$metadir/timestamps.txt" ] && while IFS= read -r line; do
    set -- $line
    touch -d "@$2" "$rootdest/$1"
  done < "$metadir/timestamps.txt"
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
