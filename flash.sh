#!/system/bin/sh
# Module Info UI
DEKH "$(PADH "name" "$MODPATH/module.prop")" "h#" 1
DEKH "🌟 Made By $(PADH "author" "$MODPATH/module.prop")" 0.5
DEKH "⚡ Version - $(PADH "version" "$MODPATH/module.prop")" 0.5
DEKH "💻 Architecture - $ARCH" 0.5
DEKH "🎲 Rooting Implementation - $ROOT" 0.5
DEKH "📝 $(PADH "description" "$MODPATH/module.prop")" 0.5

# Create Base of Module Pack
DEKH "⚒️ Building Module Package" "h"
mkdir -p "$PKGDIR/MODULES"
touch "$PKGDIR/flash.sh"
cp -af "$VTD/META-INF" "$PKGDIR/META-INF"
cp -af "$VTD/customize.sh" "$PKGDIR/customize.sh"
cp -af "$VTD/bundle" "$PKGDIR/load"
cp -af "$VTD/module.prop" "$PKGDIR/module.prop"
cat > "$PKGDIR/flash.sh" << 'FINISH'
# Module Info UI
DEKH "$(PADH "name" "$MODPATH/module.prop")" "h#" 1
DEKH "🗃️ Powered By Bundle Mods" 0.5
DEKH "🌟 Bundled By $(PADH "author" "$MODPATH/module.prop")" 0.5
DEKH "⚡ Version - $(PADH "version" "$MODPATH/module.prop")" 0.5
DEKH "🎲 Rooting Implementation - $ROOT" 0.5
DEKH "📝 $(PADH "description" "$MODPATH/module.prop")" 0.5
SHOWMODS

# Install Modules
DEKH "⏬ Installing Modules" "h"
INSTALLMOD
DEKH "📦 All Modules Installed" "h"
DEKH "🔗 Do you want to join @BuildBytes for more stuffs like that?" "h#" 1
DEKH "🔊 Vol+ = Yes\n🔉 Vol- = No\n"
OPT
if [ $? -eq 0 ]; then
am start -a android.intent.action.VIEW -d https://telegram.me/BuildBytes >/dev/null 2>&1
else
  DEKH "😔 It's okay... not everyone recognizes brilliance.\nI’ll just sit here, unloved, like a flawless script ignored by a clueless user."
fi
# Remove Bundle-Pack
(
sleep 1
rm -rf "$MODPATH"
rm -rf "$MODDIR/bundle-mods"
)&
FINISH

# Start Searching for Modules
DEKH "🧭 Choose Scan Mode for ZIP Modules:" "h"
DEKH "🔊 Vol+ = Quickly Scan in Downloads\n🔉 Vol- = Deep Scan in Internal Storage"
OPT
if [ $? -eq 0 ]; then
  SCANDIR=$DOWNDIR
fi

# Add ZIP Modules
DEKH "🔎 Looking for ZIP Modules 🖇️" "h"
DEKH "$SCANDIR"
ZIPMOD

# Add Installed Modules
if find "$MODDIR" -mindepth 1 -maxdepth 1 -type d ! -name 'bundle-mods' | grep -q .; then
  DEKH "🔎 Looking for Installed Modules 🗂️" "h"
  DEKH "⚠️ Check their compatibility, or add a zip file instead."
  INSMOD
fi

# Check if the user is Chhota Bheem
ADDCNT=$(CNTMODS "ADDED")
SKPCNT=$(CNTMODS "SKIPPED")
# Example 1:
[ "$ADDCNT" -eq 0 ] && DEKH "🤡 This bundle pack is as empty as your love life." "hx" 1 && exit 10

# Example 2:
[ "$ADDCNT" -lt 2 ] && DEKH "🫥 Your bundle has less content than your last relationship." "h" 1

# Example 3:
[ "$SKPCNT" -gt 10 ] && DEKH "😔 You skipped $SKPCNT modules. Commitment issues detected." "h" 1

# Customize Module Name and Author
DEKH "🎨 Do you want to change the bundle name and author?" "h" 1
DEKH "🔊 Vol+ = Yes\n🔉 Vol- = No"
OPT
if [ $? -eq 0 ]; then
  echo
  DEKH "ℹ️ Follow Instructions :-\n- Rename below files:\n- '$NAMEPH'\n- '$AUTHORPH'\n➡️ in $DOWNDIR" 3
  am start -a android.intent.action.VIEW -d content://com.android.externalstorage.documents/document/primary:Download >> /dev/null;
  touch "$DOWNDIR/$NAMEPH"
  CUSNAME=$(CRENAME "$DOWNDIR" "$NAMEPH") || CUSNAME="🧰 Modules Pack - $(getprop ro.product.model) - $(RAND)"
  DEKH "✅ Pack Name set to: $CUSNAME"
  touch "$DOWNDIR/$AUTHORPH"
  CUSAUTHOR=$(CRENAME "$DOWNDIR" "$AUTHORPH") || CUSAUTHOR="Unknown"
  DEKH "✅ Pack Author set to: $CUSAUTHOR"
  am force-stop com.android.documentsui && sleep 1
else
  CUSNAME="🧰 Modules Pack - $(getprop ro.product.model) - $(RAND)"
  CUSAUTHOR="Unknown"
  DEKH "✅ Using Default Values: \n$CUSNAME by $CUSAUTHOR"
fi

# Modify Module Prop
SET name "$CUSNAME" "$PKGDIR/module.prop"
SET author "$CUSAUTHOR" "$PKGDIR/module.prop"
SET description "Bundled $ADDCNT Modules in $(getprop ro.product.model), Android - $(getprop ro.build.version.release)" "$PKGDIR/module.prop"
SET version "$(PADH "version" "$MODPATH/module.prop") [$NOW]" "$PKGDIR/module.prop"

# Bundle Modules
PACKFILE="$DOWNDIR/$CUSNAME.zip"
cd "$PKGDIR"
$ZIP -qr "$PACKFILE" .

# Finalised and Cleanup
DEKH "📦 Your Bundled Module is Ready" "h"
DEKH "📊 Summary:" "h"
DEKH "✅ Modules Added: $ADDCNT"
DEKH "⏩ Modules Skipped: $SKPCNT"
DEKH "📁 Output File: $PACKFILE"
DEKH "🔗 Do you want to join @BuildBytes for more stuffs like that?" "h#" 1
DEKH "🔊 Vol+ = Yes\n🔉 Vol- = No\n"
OPT
if [ $? -eq 0 ]; then
am start -a android.intent.action.VIEW -d https://telegram.me/BuildBytes >/dev/null 2>&1
else
  DEKH "😔 It's okay... not everyone recognizes brilliance.\nI’ll just sit here, unloved, like a flawless script ignored by a clueless user."
fi

# Remove Bundle-Mods
(
sleep 1
rm -rf "$MODPATH"
rm -rf "$MODDIR/bundle-mods"
rm -rf "$VTD"
)&