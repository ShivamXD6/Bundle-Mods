#!/system/bin/sh
# Setup Environment (Variables & Functions)
TMPDIR="$(mktemp -d 2>/dev/null)" || TMPDIR="/dev/tmp"
chmod 700 "$TMPDIR"
[ -z "$MODPATH" ] && MODPATH="${0%/*}"
ADBDIR="/data/adb"
export TMPLOC="/data/local/tmp"
rm -rf "$TMPLOC" && mkdir -p "$TMPLOC"
MODDIR="$ADBDIR/modules"
MUPDIR="$ADBDIR/modules_update"
SDDIR=$(realpath "/sdcard")
EXTSD=$(find /storage -mindepth 1 -maxdepth 1 -type d 2>/dev/null | grep -Ev '/(emulated|self)' | grep -E '/[0-9A-Z]{4,}-[0-9A-Z]{4,}$' | head -n 1)
PKGMOD="$MODPATH/MODULES"
PKGAPPS="$MODPATH/APPS"
MODDATA="$PKGMOD/DATA"
ARCH=$(getprop ro.product.cpu.abi)
JOBS=$(nproc); JOBS=${JOBS:-4}
PORYGONZ="$MODPATH/porygonz"
ZAPDOS="$MODPATH/zapdos"
OLDIFS=$IFS
MACNT=0
chmod +x "$PORYGONZ" "$ZAPDOS"

# Only 64-Bit Supported
echo "$ARCH" | grep -qE 'arm64-v8a' || {
  DEKH "🧨 This module requires a 64-bit environment. Exiting..."
  exit 1
}

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
  return 0
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

# Add Strings in Registry
ADDSTR() {
  [ -f "$2" ] && { echo "$1" >> "$2"; sort -u "$2" -o "$2"; } ||
  eval "$2=\${$2:+\${$2}\$'\n'}\$1"
}

# Sort Strings from Registry
SORTSTR() {
  [ -f "$1" ] && sort -t: -k"${2:-1}" -n -r "$1" -o "$1"
}

# Replace Symbols with Spaces or Spaces with Underspace
SANITIZE() {
  local str="$1"; shift
  if [ "$1" = "1" ]; then
    echo "$str" | sed 's/[^a-zA-Z0-9]/_/g'
  else
    echo "$str" | sed 's/[[:punct:]]/ /g'
  fi
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
  info="$("$PORYGONZ" dump badging "$apkpath" 2>/dev/null)"
  ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f6)"
  [ "$ver" = "$2" ] || return 1
}

# Change Android ID
CHANID() {
  sed -i "/package=\"$1\"/s/\(value=\"\)[^\"]*\(.*defaultValue=\"\)[^\"]*/\1$2\2$2/" "/data/system/users/0/settings_ssaid.xml"
}

# Set Permissions for an app
SETPERM() {
  PKG="$1"
  FILE="$2"
  while IFS= read -r perm; do
    case "$perm" in
      appops:*)
        op="${perm#appops:}"
        appops set "$PKG" "$op" allow 2>/dev/null &
        ;;
      android.permission.*)
        pm grant "$PKG" "$perm" 2>/dev/null &
        ;;
    esac
  done < "$FILE"
}

# Process strings or files list safely with spaces
PRSMOD() {
  in="$1"; fn="$2"; TMPFILE="$TMPLOC/tmp_list.txt"
  [ -f "$in" ] && [ "${in##*.}" = "txt" ] && cp -f "$in" "$TMPFILE" || printf "%s\n" "$in" > "$TMPFILE"
  while IFS= read -r l || [ -n "$l" ]; do
    [ -z "$l" ] || "$fn" "$l"
    [ "$Key" = 2 ] || [ "$Key" = 12 ] && break
  done < "$TMPFILE"
}

# Wait for processes to complete
COOLDOWN() {
  while [ "$(jobs -p | wc -l)" -ge "$1" ]; do
    sleep 0.1
  done
}

# Unbundle Apps and It's directories
UNBUNDAPP() {
  FILE="$1"; DEST="$2"
  [ -f "$FILE" ] || return
  COOLDOWN "$((JOBS - 2))"
  "$ZAPDOS" -d -q -c "$FILE" | tar -xf - -C "$DEST" &
}

# Delete GMS Files
DELGMS() {
  pkg="$1"
  appdir="/data/data/$pkg"
  files="
databases/com.google.android.datatransport.events
databases/com.google.android.datatransport.events-journal
no_backup/com.google.android.gms.appid-no-backup
shared_prefs/com.google.android.gms.appid.xml
shared_prefs/com.google.android.gms.measurement.prefs.xml
"
  printf '%s\n' "$files" | while IFS= read -r f; do
    [ -f "$appdir/$f" ] && rm -f "$appdir/$f"
  done
}

# Fix Per PKG Ownerships and Notification Delay
FIXOWN() {
  ADGID=$(stat -c '%g' "/data/media/0/Android/data")
  AMGID=$(stat -c '%g' "/data/media/0/Android/media")
  AOGID=$(stat -c '%g' "/data/media/0/Android/obb")
  while IFS='|' read -r PKG UID CUID; do
   (
    [ -d "/data/data/$PKG" ] && chown -R "$UID:$UID" "/data/data/$PKG"
    [ -d "/data/user_de/0/$PKG" ] && chown -R "$UID:$UID" "/data/user_de/0/$PKG"
    [ -d "/data/media/0/Android/data/$PKG" ] && chown -R "$UID:$ADGID" "/data/media/0/Android/data/$PKG"
    [ -d "/data/media/0/Android/media/$PKG" ] && chown -R "$UID:$AMGID" "/data/media/0/Android/media/$PKG"
    [ -d "/data/media/0/Android/obb/$PKG" ] && chown -R "$UID:$AOGID" "/data/media/0/Android/obb/$PKG"
    DELGMS "$PKG"
    pm enable "$PKG" > /dev/null 2>&1
   ) &
    COOLDOWN "$JOBS"
  done < "$TMPLOC/.ownerships"
  rm -f "$TMPLOC/.ownerships"
  settings put global verifier_verify_adb_installs 1
}

# Restore Apps
RSTAPP() {
  PKG="$1"
  APP="$2"
  mkdir -p "$TMPLOC/$PKG"
  DEKH "🔁 Restoring: $label"
  "$ZAPDOS" -d -q -c "$APP/App.bundle.pack" | tar -xf - -C "$TMPLOC/$PKG"
  andid="$(PADH SSAID "$APP/Meta.txt")"
  oldsize="$(PADH Size "$APP/Meta.txt")"
  if ! PKG_INSTALLED "$PKG" "$ver"; then
    apks=$(find $TMPLOC/$PKG/data/app/*/*/*.apk | sort)
    [ ! -f "$APP/Permissions.txt" ] && all="-g"
    if pm install $all --dexopt-compiler-filter skip $apks > /dev/null 2>&1; then
      pm compile "$PKG" > /dev/null 2>&1 &
    else
      pm install $all $apks > /dev/null 2>&1 || return 1
    fi
    pm disable "$PKG" > /dev/null 2>&1
    dsize=0; esize=0; msize=0; osize=0
  else
    DEKH "⏭️ Skipping App (unchanged)"
    dsize="$(GETSIZE "/data/data/$pkg")"; esize="$(GETSIZE "/data/media/0/Android/data/$pkg")"; msize="$(GETSIZE "/data/media/0/Android/media/$pkg")"; osize="$(GETSIZE "/data/media/0/Android/obb/$pkg")"
  fi
  IFS='|'; set -- $oldsize; oasize=${1:-0}; odsize=${2:-0}; oesize=${3:-0}; omsize=${4:-0}; oosize=${5:-0}; IFS=$OLDIFS
  UID=$(stat -c '%u' "/data/data/$PKG")
  [ -f "$APP/Data.bundle.pack" ] && { [ "$dsize" != "$odsize" ] && UNBUNDAPP "$APP/Data.bundle.pack" "/data/data" && UNBUNDAPP "$APP/UserDe.bundle.pack" "/data/user_de/0" || DEKH "⏭️ Skipping Data (unchanged)"; }
  [ -f "$APP/ExtData.bundle.pack" ] && { [ "$esize" != "$oesize" ] && UNBUNDAPP "$APP/ExtData.bundle.pack" "/data/media/0/Android/data" || DEKH "⏭️ Skipping External Data (unchanged)"; }
  [ -f "$APP/Media.bundle.pack" ] && { [ "$msize" != "$omsize" ] && UNBUNDAPP "$APP/Media.bundle.pack" "/data/media/0/Android/media" || DEKH "⏭️ Skipping Media (unchanged)"; }
  [ -f "$APP/Obb.bundle.pack" ] && { [ "$osize" != "$oosize" ] && UNBUNDAPP "$APP/Obb.bundle.pack" "/data/media/0/Android/obb" || DEKH "⏭️ Skipping OBB (unchanged)"; }
  cp -af "$APP/Permissions.txt" "$TMPLOC/$PKG"
  [ -n "$andid" ] && CHANID "$PKG" "$andid"
  [ -f "$APP/Permissions.txt" ] && SETPERM "$PKG" "$TMPLOC/$PKG/Permissions.txt"
  echo "$PKG|$UID" >> "$TMPLOC/.ownerships"
  DEKH "✅ Restore complete for: $label"
}

# Fetch and Display All Modules or Apps
FETCHMODS() {
  [ -d "$PKGMOD" ] && {
    ZMODLIST="$(find "$PKGMOD" -type f -name "*.zip")"
    LSMODLIST="$(find "$PKGMOD" -type f -name "*.apk")"
  }
  [ -d "$PKGAPPS" ] && {
    UAPPSLIST="$(find "$PKGAPPS" -type d -mindepth 1 -maxdepth 1)"
    APPSLIST="$(find "$PKGAPPS" -type f \( -name "*.apk" -o -name "*.apks" -o -name "*.apkm" \))"
  }
  FPMODLIST=""
  FZMODLIST=""
  FUAPPSLIST="$TMPLOC/uappslist.txt"
  FLSMODLIST=""
  FAPPSLIST=""
  PSSHOWZIP() {
    type="🖇️"
    unzip -l "$1" | grep -q "module.prop" || return
    unzip -p "$1" "module.prop" > "$TMPLOC/module.prop" 2>/dev/null
    [ -s "$TMPLOC/module.prop" ] || return
    id=$(PADH id "$TMPLOC/module.prop")
    ver=$(PADH version "$TMPLOC/module.prop")
    [ -d "$MODDIR/$id" ] && {
      currver=$(PADH version "$MODDIR/$id/module.prop")
      [ "$currver" = "$ver" ] && return
    }
    label=$(PADH name "$TMPLOC/module.prop"); label=$(SANITIZE "$label")
    unzip -l "$1" | awk '{print $NF}' | grep -q '^lib/' && ADDSTR "$1:$id:$label:$ver" "FPMODLIST" && type="⚡" || ADDSTR "$1:$id:$label:$ver" "FZMODLIST"
    rm -f $TMPLOC/module.prop
  }
  PSSHOWUAPPS() {
   (
    pkg="$(basename "$1")"
    label="$(PADH Name "$1/Meta.txt")"; label=$(SANITIZE "$label")
    ver="$(PADH Version "$1/Meta.txt")"
    sizes="$(PADH Size "$1/Meta.txt")"
    IFS='|' read -r asize dsize esize msize osize <<< "$sizes"
    size=$((asize + dsize + esize + msize + osize))
    ADDSTR "$1:$size:$pkg:$label:$ver" "$FUAPPSLIST"
   ) &
   COOLDOWN "$JOBS"
  }
  PSSHOWLSMOD() {
    unzip -l "$1" | grep -q "xposed_init" 2>/dev/null || return
    info="$("$PORYGONZ" dump badging "$1" 2>/dev/null)"
    pkg="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f2)"
    ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f6)"
    PKG_INSTALLED "$pkg" "$ver" && return 1
    label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"; label=$(SANITIZE "$label")
    ADDSTR "$1:$pkg:$label:$ver" "FLSMODLIST"
  }
  PSSHOWAPPS() {
    unzip -l "$1" | grep -q "xposed_init" 2>/dev/null && return
    name=$(basename "$1")
    case "$1" in
      *.apk)
        info="$("$PORYGONZ" dump badging "$1" 2>/dev/null)" ;;
      *.apks|*.apkm)
        mkdir -p "$TMPLOC/$name"
        unzip -q "$1" -d "$TMPLOC/$name" 2>/dev/null
        base="$TMPLOC/$name/base.apk"
        info="$("$PORYGONZ" dump badging "$base" 2>/dev/null)"
    esac
    pkg="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f2)"
    ver="$(echo "$info" | grep -m1 "package: name=" | cut -d"'" -f6)"
    PKG_INSTALLED "$pkg" "$ver" && return 1
    label="$(echo "$info" | grep -m1 "application-label:" | cut -d"'" -f2)"; label=$(SANITIZE "$label")
    ADDSTR "$1:$name:$pkg:$label:$ver" "FAPPSLIST"
  }
  [ -n "$ZMODLIST" ] && PRSMOD "$ZMODLIST" "PSSHOWZIP"
  [ -n "$UAPPSLIST" ] && > "$FUAPPSLIST" && PRSMOD "$UAPPSLIST" "PSSHOWUAPPS"
  [ -n "$LSMODLIST" ] && PRSMOD "$LSMODLIST" "PSSHOWLSMOD"
  [ -n "$APPSLIST" ] && PRSMOD "$APPSLIST" "PSSHOWAPPS"
  wait
}

# Install Modules or Apps
INSTALL() {
  cd "$TMPLOC"
  PSZIPMOD() {
    MACNT=$((MACNT + 1))
    IFS=':'; set -- $1; path="$1"; id="$2"; label="$3"; ver="$4"; IFS=$OLDIFS
    DEKH "📦 [$MACNT] $label ($ver) $type" 1 "h"
    [ "$INSTYP" = "SELECT" ] && {
      DEKH "🔊 Vol+ = Install Module\n🔉 Vol- = Skip Module"
      OPT "h"; Key=$?; [ "$Key" -eq 1 ] && return
    }
    cp -af "$path" "$TMPLOC/$id.zip"
    su -c "$CMD '$TMPLOC/$id.zip'" || DEKH "❌ Failed to install $label ($ver)" "hx" 1
    rm -f "$TMPLOC/$id.zip"
  }
  PSUAPPS() {
    MACNT=$((MACNT + 1))
    IFS=':'; set -- $1; app="$1"; size="$2"; pkg="$3"; label="$4"; ver="$5"; IFS=$OLDIFS
    size=0; comps=""
    sizes="$(PADH Size "$app/Meta.txt")"
    IFS='|'; set -- $sizes; asize=${1:-0}; dsize=${2:-0}; esize=${3:-0}; msize=${4:-0}; osize=${5:-0}; IFS=$OLDIFS
    for f in App Data ExtData Media Obb; do
    file="$app/$f.bundle.pack"
    [ -f "$file" ] && {
      ADDSTR "#$f" "comps"
        case "$f" in
          App) size=$((size + asize)) ;;
          Data) size=$((size + dsize)) ;;
          ExtData) size=$((size + esize)) ;;
          Media) size=$((size + msize)) ;;
          Obb) size=$((size + osize)) ;;
        esac
    }
    done
    size=$(GETSIZE $size)
    DEKH "📦 [$MACNT] $label📱" "h"
    DEKH "ℹ️ Version: $ver | Size: $size"
    cmp=""; for c in $comps; do cmp="${cmp:+$cmp | }$c"; done; DEKH "🧩 Parts: $cmp"
    [ "$INSTYP" = "SELECT" ] && {
      DEKH "🔊 Vol+ = Restore App\n🔉 Vol- = Skip App"
      OPT "h"; Key=$?; [ "$Key" -eq 1 ] && return
    }
    RSTAPP "$pkg" "$app" || DEKH "❌ Failed to install $label (v$ver)" "hx" 1
  }
  PSLSMOD() {
    MACNT=$((MACNT + 1))
    IFS=':'; set -- $1; path="$1"; pkg="$2"; label="$3"; ver="$4"; IFS=$OLDIFS
    DEKH "📦 [$MACNT] $label (v$ver) 🧩" 1 "h"
    [ "$INSTYP" = "SELECT" ] && {
      DEKH "🔊 Vol+ = Install LSPosed Module\n🔉 Vol- = Skip LSPosed Module"
      OPT "h"; Key=$?; [ "$Key" -eq 1 ] && return
    }
    cp -af "$path" "$TMPLOC/$pkg.apk"
    DEKH "⏬ Installing $label"
    pm install "$TMPLOC/$pkg.apk" >/dev/null 2>&1 || DEKH "❌ Failed to install $label (v$ver)" "hx" 1
    rm -f "$TMPLOC/$pkg.apk"
  }
  PSAPPS() {
    MACNT=$((MACNT + 1))
    IFS=':'; set -- $1; path="$1"; name="$2"; pkg="$3"; label="$4"; ver="$5"; IFS=$OLDIFS
    DEKH "📦 [$MACNT] $label (v$ver) 📲" 1 "h"
    [ "$INSTYP" = "SELECT" ] && {
      DEKH "🔊 Vol+ = Install Local App\n🔉 Vol- = Skip Local App"
      OPT "h"; Key=$?; [ "$Key" -eq 1 ] && return
    }
    case "$path" in
    *.apk)
      cp -af "$path" "$TMPLOC/$pkg.apk"
      DEKH "⏬ Installing $label"
      if pm install --dexopt-compiler-filter skip $pkg.apk > /dev/null 2>&1; then
        pm compile "$pkg" > /dev/null 2>&1 &
      else
        pm install $pkg.apk > /dev/null 2>&1 || DEKH "❌ Failed to install $label (v$ver)" "hx" 1
      fi
      rm -f $TMPLOC/$pkg.apk
      ;;
    *.apks|*.apkm)
      apks=$(find "$TMPLOC/$name" -name "*.apk" | sort)
      DEKH "⏬ Installing $label"
      if pm install --dexopt-compiler-filter skip $apks > /dev/null 2>&1; then
        pm compile "$pkg" > /dev/null 2>&1 &
      else
        pm install $apks > /dev/null 2>&1 || DEKH "❌ Failed to install $label (v$ver)" "hx" 1
      fi
      rm -f "$TMPLOC/$name"
      ;;
    esac
  }
  [ -n "$FPMODLIST" ] && { type="⚡"; PRSMOD "$FPMODLIST" "PSZIPMOD"; }
  [ -n "$FZMODLIST" ] && { type="🖇️"; PRSMOD "$FZMODLIST" "PSZIPMOD"; }
  [ -s "$FUAPPSLIST" ] && {
    SORTSTR "$FUAPPSLIST" 2
    settings put global verifier_verify_adb_installs 0
    PRSMOD "$FUAPPSLIST" "PSUAPPS"; FIXOWN
    DEKH "🔂 Finishing: $(jobs -p | wc -c) Remaining Processes..." && COOLDOWN 1
  }
  [ -n "$FLSMODLIST" ] && PRSMOD "$FLSMODLIST" "PSLSMOD"
  [ -n "$FAPPSLIST" ] && PRSMOD "$FAPPSLIST" "PSAPPS"
  DEKH "✅ Installation Complete, Everything is Installed" "h"
}

# Restore Modules Data if any
RSTDATA() {
  source "$MODPATH/data.sh"
  DEKH "💾 Restoring Modules Data" 1 "h"
  for i in "${!MOD_ID_PKG[@]}"; do
    id="${MOD_ID_PKG[$i]}"
    name=$(PADH name "$MODDIR/$id/module.prop" 2>/dev/null)
    [ -z "$name" ] && {
      apk=$(pm path "$id" | sed 's/^package://' | head -1)
      name=$(SANITIZE "$( "$PORYGONZ" dump badging "$apk" 2>/dev/null | grep -m1 "application-label:" | cut -d"'" -f2 )")
    }
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
if [ -d "$ADBDIR/magisk" ] && magisk -V >/dev/null 2>&1; then
  ROOT="Magisk"
  CMD="magisk --install-module"
elif [ -d "$ADBDIR/ksu" ] && ksud -V >/dev/null 2>&1; then
  ROOT="KernelSU"
  CMD="ksud module install"
elif [ -d "$ADBDIR/ap" ] && apd -V >/dev/null 2>&1; then
  ROOT="APatch"
  CMD="apd module install"
else
  DEKH "🤖?? Cannot determine rooting implementation, if you think it's a mistake, report on @BuildBytes" "hx"
  ROOT="Unknown"
fi

# Start Flashing Module
source "$MODPATH/flash.sh"
