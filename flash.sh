# Module Info UI
DEKH "$(PADH "name" "$MODPATH/module.prop")" "h#" 1
DEKH "🗃️ Powered By Bundle Mods v2"
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

# Restore Data
RSTDATA

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
