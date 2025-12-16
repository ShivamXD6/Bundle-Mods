#!/system/bin/sh

# Module Info UI
DEKH "$(PADH "name" "$MODPATH/module.prop")" "h#"
DEKH "🌟 Made By $(PADH "author" "$MODPATH/module.prop")"
DEKH "⚡ Version - $(PADH "version" "$MODPATH/module.prop")"
DEKH "🎲 Rooting Implementation - $ROOT"
DEKH "📝 $(PADH "description" "$MODPATH/module.prop")" 1

# Check for any external media
if [ -n "$EXTSD" ]; then
  DEKH "💾 External Storage Found, What to do?" "h"
  DEKH "🔊 Vol+ = Backup in Internal Storage (fast)\n🔉 Vol- = Backup in $EXTSD (slow)"
  OPT; [ $? -eq 1 ] && SDDIR="$EXTSD"
fi

# Backup Storing Method
DEKH "📦 Choose your Backup Style:" "h"
DEKH "🔊 Vol+ = Keep folder separate (fast but messy)\n🔉 Vol- = Add into zip pacakge (neat but slow)"
OPT
[ $? -eq 0 ] && {
  BAKMODE="FOLDER"
  BAKDIR="$SDDIR/#Backup"
  [ ! -d "$BAKDIR" ] && BAKDIR="$(dirname "$(find "$SDDIR" -maxdepth 2 -type f -name '.bundle-mods' | head -n 1)")"; [ "$BAKDIR" = "." ] && BAKDIR="$SDDIR/#Backup" && mkdir -p "$BAKDIR"
  PKGMOD="$BAKDIR/MODULES"
  PKGAPPS="$BAKDIR/APPS"
  DOWNDIR="$SDDIR/Download"
  MODDATA="$PKGMOD/DATA"
  > "$BAKDIR/.bundle-mods"
}
[ ! -f "$ADBDIR/.bundle-ex" ] && NEWUSER=1

# Create Base of Module Pack
[ "$NEWUSER" -eq 1 ] && DEKH "⚒️ Building Module Package" "h"
mkdir -p "$PKGDIR"
touch "$PKGDIR/flash.sh"
cp -af "$VTD/META-INF" "$PKGDIR/META-INF"
cp -af "$VTD/customize.sh" "$PKGDIR/customize.sh"
cp -af "$VTD/bundle.sh" "$PKGDIR/load.sh"
cp -af "$VTD/porygonz" "$PKGDIR/porygonz"
cp -af "$VTD/snorlax" "$PKGDIR/snorlax"
cp -af "$VTD/zapdos" "$PKGDIR/zapdos"
cp -af "$VTD/module.prop" "$PKGDIR/module.prop"
cp -af "$VTD/service.sh" "$PKGDIR/service.sh"

cat > "$PKGDIR/flash.sh" << 'FINISH'
#!/system/bin/sh
# Module Info UI
DEKH "$(PADH "name" "$MODPATH/module.prop")" "h#"
DEKH "🗃️ Powered By Bundle Mods v5"
DEKH "🌟 Packed By $(PADH "author" "$MODPATH/module.prop")"
DEKH "⚡ Version - $(PADH "version" "$MODPATH/module.prop")"
DEKH "🎲 Rooting Implementation - $ROOT" 1

# Check for any pre installation script 
if [ -f "$MODPATH/Pre-Install.sh" ]; then
  DEKH "📃 Found Pre-Install script in pack. Executing..."
  source "$MODPATH/Pre-Install.sh"
elif [ -f "$BAKDIR/Pre-Install.sh" ]; then
  DEKH "📃 Found Pre-Install script in $BAKDIR. Executing..."
  source "$BAKDIR/Pre-Install.sh"
fi

# Check for Backup Mode
[ ! -d "$PKGMOD" ] && [ ! -d "$PKGAPPS" ] && BAKMODE="FOLDER"
[ "$BAKMODE" = "FOLDER" ] && {
  DEKH "🔎 Looking for Backups" "h"
  BAKDIR="$SDDIR/#Backup"
  [ ! -d "$BAKDIR" ] && BAKDIR="$(dirname "$(find "$SDDIR" -maxdepth 2 -type f -name '.bundle-mods' | head -n 1)")"; [ "$BAKDIR" = "." ] && BAKDIR="$SDDIR/#Backup"
  [ -n "$EXTSD" ] && {
    BAKEXT="$EXTSD/#Backup"
    [ ! -d "$BAKEXT" ] && BAKEXT="$(dirname "$(find "$EXTSD" -maxdepth 2 -type f -name '.bundle-mods' | head -n 1)")"; [ "$BAKEXT" = "." ] && BAKEXT="$EXTSD/#Backup"
    [ ! -d "$BAKDIR" ] && [ -d "$BAKEXT" ] && BAKDIR="$BAKEXT"
  }
  
  [ ! -d "$BAKDIR" ] && [ ! -d "$BAKEXT" ] && DEKH "❌ Can't find anything to install" "hx" && exit 1

  # Check if backup exists in both storage
  [ -d "$BAKDIR" ] && [ -d "$BAKEXT" ] && {
    DEKH "💾 Select a Backup Location to Restore from?" "h"
    DEKH "🔊 Vol+ = Restore from Internal Storage (fast)\n🔉 Vol- = Restore from $EXTSD (slow)"
    OPT; [ $? -eq 1 ] && {
      BAKDIR="$BAKEXT"
    }
  }
  
  # Update Vars for Backup Mode Folder
  PKGMOD="$BAKDIR/MODULES"
  PKGAPPS="$BAKDIR/APPS"
  MODDATA="$PKGMOD/DATA"
}
[ ! -f "$ADBDIR/.bundle-ex" ] && NEWUSER=1

# Installation Type Quick or Selective
DEKH "⏬ Select Installation Type?" "h"
DEKH "🔊 Vol+ = Quick Install (install all)\n🔉 Vol- = Selective Install (select & install)"
OPT; [ $? -eq 1 ] && {
  INSTYP="SELECT"
}

DEKH "✅ Validating your Mods/Apps..." "h"
FETCHMODS

# Install Modules
DEKH "⏬ Installing Mods/Apps" "h"
INSTALL

# Restore Data
[ -d "$PKGMOD" ] && RSTDATA

# Check for any post installation script 
if [ -f "$MODPATH/Post-Install.sh" ]; then
  DEKH "📃 Found Post-Install script in pack. Executing..."
  source "$MODPATH/Post-Install.sh"
elif [ -f "$BAKDIR/Post-Install.sh" ]; then
  DEKH "📃 Found Post-Install script in $BAKDIR. Executing..."
  source "$BAKDIR/Post-Install.sh"
fi

[ "$NEWUSER" -eq 1 ] && {
# Prompt to join Channel
DEKH "🔗 @BuildBytes is quietly building things worth exploring. Want to be there early?" "h#"
DEKH "🔊 Vol+ = Yes, I’m in. early, curious, and ahead\n🔉 Vol- = No, I’ll scroll past and miss it\n"
OPT
if [ $? -ne 1 ]; then
  am start -a android.intent.action.VIEW -d https://telegram.me/BuildBytes >/dev/null 2>&1
else
  DEKH "🫥 You passed.\nNo noise, no regret, just a silent skip over something built with intent.\nI’ll stay here, quietly excellent, waiting for those who notice before it’s popular."
fi
}
wait
DEKH "📦 Everything from Pack Installed Successfully" "h" 1

# Remove Bundle-Pack
(
sleep 0.2
touch "$ADBDIR/.bundle-ex"
rm -rf "$MODPATH" "$MODDIR/bundle-mods" 
)&
FINISH

# Selection Method
DEKH "☑️ Choose your Select Style:" "h"
DEKH "🔊 Vol+ = Delete temp. files to Select (fast)\n🔉 Vol- = Use Volume Keys to Select (slow)"
OPT
[ $? -eq 0 ] && SELMODE="FILE"

# Add Local Modules
LOCAL() {
  mkdir -p "$PKGMOD"
  DEKH "👀 Looking for Local Modules 🖇️" "h"
  DEKH "🔎 Deep Scanning in $SDDIR" 
  LOCMOD 
  return 0
}

# Add Installed / User Apps
UAPPS() {
  mkdir -p "$PKGAPPS"
  DEKH "👀 Looking for Installed Apps 📱" "h"
  INSAPPS
  return 0
}

# Add LSPOSED Modules
LSPOSED() {
  mkdir -p "$PKGMOD"
  DEKH "👀 Looking for Local LSPosed Modules 🧩" "h"
  DEKH "🔎 Deep Scanning in $SDDIR"
  LSMOD
  return 0
}

# Add Local Apps
APPS() {
  mkdir -p "$PKGAPPS"
  DEKH "👀 Looking for Local Apps 📱" "h"
  DEKH "🔎 Deep Scanning in $SDDIR"
  LOCAPPS 
  return 0
}

# Let them select what they want to bundle
BUNDLE_KEYS=("Local Modules" "Installed Apps" "LSPosed Modules" "Local Apps" "Finish Bundling")

BUNDLE_FUNCS() {
  case "$1" in
    "Local Modules") LOCAL ;;
    "Installed Apps") UAPPS ;;
    "LSPosed Modules") LSPOSED ;;
    "Local Apps") APPS ;;
    "Finish Bundling") return 1 ;;
  esac
}

while true; do
  [ "${#BUNDLE_KEYS[@]}" -eq 1 ] && [ "${BUNDLE_KEYS[0]}" = "Finish Bundling" ] && break
  DEKH "📦 Select what to bundle:" "h"
  keymap=()
  for i in "${!BUNDLE_KEYS[@]}"; do
    label="${BUNDLE_KEYS[i]}"
    case "$i" in
      0) DEKH "🔊 Vol+ Press = $label"; keymap[0]="$label" ;;
      1) DEKH "🔉 Vol- Press = $label"; keymap[1]="$label" ;;
      2) DEKH "🔊 Vol+ Hold = $label"; keymap[10]="$label" ;;
      3) DEKH "🔊 Vol- Hold = $label"; keymap[11]="$label" ;;
      4) DEKH "🔌 Power Button Press/Hold = $label"; keymap[2]="$label"; keymap[12]="$label";;
    esac
  done
  OPT "h"
  input=$?
  selected="${keymap[$input]}"
  BUNDLE_FUNCS "$selected" || break
  newlist=()
  for item in "${BUNDLE_KEYS[@]}"; do
    [ "$item" != "$selected" ] && newlist+=("$item")
  done
  BUNDLE_KEYS=("${newlist[@]}")
done

# Check if the user is Chhota Bheem
ADDCNT=$(CNTSTR "ADDED")
SKPCNT=$(CNTSTR "SKIPPED")

# Example 1:
[ "$ADDCNT" -eq 0 ] && DEKH "🤡 This bundle pack is as empty as your love life." "hx" && exit 10

# Check for Modules data if is there any to backup
[ -d "$PKGMOD" ] && DEKH "💾 Searching for Modules Data" "h" && BAKDATA

# Example 2:
[ "$ADDCNT" -le 2 ] && DEKH "🫥 Your bundle/pack has less content than your last relationship." "h"

# Calculate Percentage
TOTALCNT=$((SKPCNT + ADDCNT))
ADDPRCN=$((ADDCNT * 100 / TOTALCNT))
SKIPPRCN=$((SKPCNT * 100 / TOTALCNT))

# Example 3:
[ "$SKIPPRCN" -ge 90 ] && DEKH "😔 Looks like you have Commitment issues." "h"

# Customize Module Name and Author
DEKH "🎨 Do you want to change the bundle/pack name and author?" "h"
DEKH "🔊 Vol+ = Yes\n🔉 Vol- = No" 0.5
OPT
if [ $? -eq 0 ]; then
  DEKH "\nℹ️ Follow Instructions :-\n- Rename below files:\n- '$NAMEPH'\n- '$AUTHORPH'\n- '$VERSIONPH'\n📂 in $RNMDIR\n" 3
  mkdir -p "$RNMDIR"; OFM "$RNMFLD"
  touch "$RNMDIR/$NAMEPH"
  CUSNAME="$(CRENAME "$RNMDIR" "$NAMEPH")" || CUSNAME="🧰 Modules or Apps Package - $(getprop ro.product.model)"
  DEKH "✅ Pack Name set to: $CUSNAME"
  touch "$RNMDIR/$AUTHORPH"
  CUSAUTHOR="$(CRENAME "$RNMDIR" "$AUTHORPH")" || CUSAUTHOR="Unknown"
  DEKH "✅ Pack Author set to: $CUSAUTHOR"
  touch "$RNMDIR/$VERSIONPH"
  CUSVERSION="$(CRENAME "$RNMDIR" "$VERSIONPH")" || CUSVERSION="v5 ($NOW)"
  DEKH "✅ Pack Version set to: $CUSVERSION"
  CFM; rm -rf "$RNMDIR"; sleep 1
else
  CUSNAME="🧰 Modules or Apps Package - $(getprop ro.product.model)"
  CUSAUTHOR="Unknown"
  CUSVERSION="v5 ($NOW)"
  DEKH "✅ Using Default Values: \n$CUSNAME [$CUSVERSION] by $CUSAUTHOR"
fi

# Modify Module Prop
SET name "$CUSNAME" "$PKGDIR/module.prop"
SET author "$CUSAUTHOR" "$PKGDIR/module.prop"
SET description "Packed $ADDCNT Mods/Apps in $(getprop ro.product.model), (A$(getprop ro.build.version.release))" "$PKGDIR/module.prop"
SET version "$CUSVERSION" "$PKGDIR/module.prop"

# Bundle Pack
DEKH "✅ Finalizing your Bundle Pack." "h"
if [ "$BAKMODE" = "FOLDER" ]; then
  rm -f "$BAKDIR/"*.zip
  PACKFILE="$SDDIR/#Backup/$CUSNAME.zip"
  cmp=""
else
  PACKFILE="$DOWNDIR/$CUSNAME.zip"
  cmp="-0"
fi
cd "$PKGDIR"
$SNORLAX $cmp -qr "$PACKFILE" .

[ "$NEWUSER" -eq 1 ] && {
DEKH "🔗 @BuildBytes is quietly building things worth exploring. Want to be there early?" "h#"
DEKH "🔊 Vol+ = Yes, I’m in. early, curious, and ahead\n🔉 Vol- = No, I’ll scroll past and miss it\n"
OPT
if [ $? -ne 1 ]; then
  am start -a android.intent.action.VIEW -d https://telegram.me/BuildBytes >/dev/null 2>&1
else
  DEKH "🫥 You passed.\nNo noise, no regret, just a silent skip over something built with intent.\nI’ll stay here, quietly excellent, waiting for those who notice before it’s popular."
fi
}

# Finalised and Cleanup
DEKH "📦 Your Bundled Pack is Ready" "h"
DEKH "✅ Mods/Apps Added: $ADDCNT"
DEKH "👇 FLASH BELOW ZIP TO RESTORE 👇" "h#"
DEKH "📁 - $PACKFILE\n" 1

# Remove Bundle-Mods
(
sleep 0.2
rm -rf "$MODPATH" "$MODDIR/bundle-mods" "$VTD"
)&
