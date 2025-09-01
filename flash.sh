#!/system/bin/sh

# Module Info UI
DEKH "$(PADH "name" "$MODPATH/module.prop")" "h#" 1
DEKH "🌟 Made By $(PADH "author" "$MODPATH/module.prop")"
DEKH "⚡ Version - $(PADH "version" "$MODPATH/module.prop")"
DEKH "💻 Architecture - $ARCH"
DEKH "🎲 Rooting Implementation - $ROOT"
DEKH "📝 $(PADH "description" "$MODPATH/module.prop")"

# Create Base of Module Pack
DEKH "⚒️ Building Module Package" "h"
mkdir -p "$PKGDIR/MODULES"
mkdir -p "$PKGDIR/APPS"
touch "$PKGDIR/flash.sh"
cp -af "$VTD/META-INF" "$PKGDIR/META-INF"
cp -af "$VTD/customize.sh" "$PKGDIR/customize.sh"
cp -af "$VTD/bundle" "$PKGDIR/load"
cp -af "$VTD/aapt" "$PKGDIR/aapt"
cp -af "$VTD/aapt32" "$PKGDIR/aapt32"
cp -af "$VTD/module.prop" "$PKGDIR/module.prop"
cat > "$PKGDIR/flash.sh" << 'FINISH'
# Module Info UI
DEKH "$(PADH "name" "$MODPATH/module.prop")" "h#" 1
DEKH "🗃️ Powered By Bundle Mods"
DEKH "🌟 Packed By $(PADH "author" "$MODPATH/module.prop")"
DEKH "⚡ Version - $(PADH "version" "$MODPATH/module.prop")"
DEKH "🎲 Rooting Implementation - $ROOT"
DEKH "📝 $(PADH "description" "$MODPATH/module.prop")"
DEKH "✅ Validating your Modules.. Please Wait..."
SHOWMODS

# Check for any pre installation script 
if [ -f "$MODPATH/Pre-Install.sh" ]; then
  DEKH "📃 Found Pre-Install script in pack. Executing..." 1
  source "$MODPATH/Pre-Install.sh"
elif [ -f "$DOWNDIR/Pre-Install.sh" ]; then
  DEKH "📃 Found Pre-Install script in Download. Executing..." 1
  source "$DOWNDIR/Pre-Install.sh"
fi

# Install Modules
DEKH "⏬ Installing Modules" "h"
INSTALL

# Check for any post installation script 
if [ -f "$MODPATH/Post-Install.sh" ]; then
  DEKH "📃 Found Post-Install script in pack. Executing..." 1
  source "$MODPATH/Post-Install.sh"
elif [ -f "$DOWNDIR/Post-Install.sh" ]; then
  DEKH "📃 Found Post-Install script in Download. Executing..." 1
  source "$DOWNDIR/Post-Install.sh"
fi

DEKH "🔗 Do you want to join @BuildBytes for more stuffs like that?" "h#" 1
DEKH "🔊 Vol+ = Yes\n🔉 Vol- = No\n"
OPT
if [ $? -ne 1 ]; then
  am start -a android.intent.action.VIEW -d https://telegram.me/BuildBytes >/dev/null 2>&1
else
  DEKH "😔 It's okay... not everyone recognizes brilliance.\nI’ll just sit here, unloved, like a flawless script ignored by a clueless user."
fi
DEKH "📦 Everything from Pack Installed Successfully" "h"
# Remove Bundle-Pack
(
sleep 0.1
rm -rf "$MODPATH"
rm -rf "$MODDIR/bundle-mods"
)&
FINISH

# Select Method you want to use for selection
DEKH "🧠 How You Want to Select Modules:" "h"
DEKH "🔊 Vol+ = Delete Placeholder files to Select\n🔉 Vol- = Use Volume Keys to Select"
OPT
[ $? -eq 0 ] && SELMODE="FILE"

# Add Local Modules
LOCAL() {
  DEKH "👀 Looking for Local Modules 🖇️" "h"
  DEKH "🔎 Deep Scanning in:$SDDIR"
  LOCMOD 
  return 0
}

# Add LSPOSED Modules
LSPOSED() {
  DEKH "👀 Looking for Local LSPosed Modules 🧩" "h"
  DEKH "🔎 Deep Scanning in:$SDDIR"
  LSMOD
  return 0
}

# Add Local Apps
APPS() {
  DEKH "👀 Looking for Local Apps 📱" "h"
  DEKH "🔎 Deep Scanning in:$SDDIR"
  LOCAPPS 
  return 0
}

# Let them select what they want to bundle
BUNDLE_KEYS=("Local Modules" "LSPosed Modules" "Local Apps" "Finish Bundling")

BUNDLE_FUNCS() {
  case "$1" in
    "Local Modules") LOCAL ;;
    "LSPosed Modules") LSPOSED ;;
    "Local Apps") APPS ;;
    "Finish Bundling") return 1 ;;
  esac
}

while true; do
  [ "${#BUNDLE_KEYS[@]}" -eq 1 ] && [ "${BUNDLE_KEYS[0]}" = "Finish Bundling" ] && break
  DEKH "📦 Select what to bundle:" "h" 1
  keymap=()
  for i in "${!BUNDLE_KEYS[@]}"; do
    label="${BUNDLE_KEYS[i]}"
    case "$i" in
      0) DEKH "🔊 Vol+ = $label"; keymap[0]="$label" ;;
      1) DEKH "🔉 Vol- = $label"; keymap[1]="$label" ;;
      2) DEKH "🔊 Vol+ Hold = $label"; keymap[10]="$label" ;;
      3) DEKH "🔊 Vol- Hold = $label"; keymap[11]="$label" ;;
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
ADDCNT=$(CNTMODS "ADDED")
SKPCNT=$(CNTMODS "SKIPPED")

# Example 1:
[ "$ADDCNT" -eq 0 ] && DEKH "🤡 This bundle/pack is as empty as your love life." "hx" 1 && exit 10

# Check for Modules data if is there any to backup
DEKH "💾 Searching for Modules Data" "h" 1
BAKDATA

# Example 2:
[ "$ADDCNT" -le 2 ] && DEKH "🫥 Your bundle/pack has less content than your last relationship." "h" 1

# Calculate Percentage
TOTALCNT=$((SKPCNT + ADDCNT))
ADDPRCN=$((ADDCNT * 100 / TOTALCNT))
SKIPPRCN=$((SKPCNT * 100 / TOTALCNT))

# Example 3:
[ "$SKIPPRCN" -ge 90 ] && DEKH "😔 Looks like you have Commitment issues." "h" 1

# Customize Module Name and Author
DEKH "🎨 Do you want to change the bundle/pack name and author?" "h" 1
DEKH "🔊 Vol+ = Yes\n🔉 Vol- = No"
OPT
if [ $? -eq 0 ]; then
  DEKH "\nℹ️ Follow Instructions :-\n- Rename below files:\n- '$NAMEPH'\n- '$AUTHORPH'\n➡️ in $DOWNDIR" 3
  am start -a android.intent.action.VIEW -d content://com.android.externalstorage.documents/document/primary:Download >> /dev/null;
  touch "$DOWNDIR/$NAMEPH"
  CUSNAME=$(CRENAME "$DOWNDIR" "$NAMEPH") || CUSNAME="🧰 Modules Pack - $(getprop ro.product.model) - $(RAND)"
  DEKH "✅ Pack Name set to: $CUSNAME"
  touch "$DOWNDIR/$AUTHORPH"
  CUSAUTHOR=$(CRENAME "$DOWNDIR" "$AUTHORPH") || CUSAUTHOR="Unknown"
  DEKH "✅ Pack Author set to: $CUSAUTHOR"
  am force-stop com.android.documentsui
  am force-stop com.google.android.documentsui 
  sleep 1
else
  CUSNAME="🧰 Modules Pack - $(getprop ro.product.model) - $(RAND)"
  CUSAUTHOR="Unknown"
  DEKH "✅ Using Default Values: \n$CUSNAME by $CUSAUTHOR"
fi

# Add Custom Script
DEKH "📃 Add a custom script to your module pack?" "h" 1
DEKH "ℹ️ It can run before and/or after installation."
DEKH "🔉 Vol+ = Add Pre & Post scripts\n🔉 Vol- = Skip Scripts\n🔊 Vol+ Hold = Add Pre only\n🔉 Vol- Hold = Add Post only"
OPT h
KEY="$?"
case "$KEY" in
  0)  CUS_SCRIPT "Pre-Install"; CUS_SCRIPT "Post-Install" ;;
  10) CUS_SCRIPT "Pre-Install" ;;
  11) CUS_SCRIPT "Post-Install" ;;
  *)  DEKH "🚫 Skipping script addition." 1 ;;
esac

# Modify Module Prop
SET name "$CUSNAME" "$PKGDIR/module.prop"
SET author "$CUSAUTHOR" "$PKGDIR/module.prop"
SET description "Packed $ADDCNT Mods/Apps in $(getprop ro.product.model), (A$(getprop ro.build.version.release))" "$PKGDIR/module.prop"
SET version "$(PADH "version" "$MODPATH/module.prop") [$NOW]" "$PKGDIR/module.prop"

# Bundle Pack
DEKH "🗜️ Compressing your Bundle Pack." "h"
PACKFILE="$DOWNDIR/$CUSNAME.zip"
cd "$PKGDIR"
$ZIP -qr "$PACKFILE" .

DEKH "🔗 Do you want to join @BuildBytes for more stuffs like that?" "h#" 1
DEKH "🔊 Vol+ = Yes\n🔉 Vol- = No\n"
OPT
if [ $? -ne 1 ]; then
  am start -a android.intent.action.VIEW -d https://telegram.me/BuildBytes >/dev/null 2>&1
else
  DEKH "😔 It's okay... not everyone recognizes brilliance.\nI’ll just sit here, unloved, like a flawless script ignored by a clueless user."
fi

# Finalised and Cleanup
DEKH "📦 Your Bundled Pack is Ready" "h"
DEKH "📊 Summary:" "h"
DEKH "✅ Mods/Apps Added: $ADDCNT (~$ADDPRCN%)"
DEKH "⏩ Mods/Apps Skipped: $SKPCNT (~$SKIPPRCN%)"
DEKH "📁 Output File: $PACKFILE"

# Remove Bundle-Mods
(
sleep 0.1
rm -rf "$MODPATH"
rm -rf "$MODDIR/bundle-mods"
rm -rf "$VTD"
)&
