#####################################
# Bundling Modules Data Instructions:
# 1. If a Module has more then 1 data file, use \n to separate it's data file in that single string.
# 2. Use ModuleID (OR PKG name for LSPOSED modules), don't use random names.
# 3. Keep Modules and Data Sequences Intact.
# 4. If 2 modules have same IDs/PKGs don't repeat ID/PKG.
DEKH "💾 Data Loaded...."

# Modules IDs
## Enter ModulesID OR PKG Names here
## Use this format:
## "ModuleID OR PKG" # No. - Module Name
MOD_ID_PKG=(
"youtube-jhc" # 1 - YouTube ReVanced
"tricky_store" # 2 - Tricky Store/OSS/Addon
"playintegrityfix" # 3 - Play Integrity Fix/Fork/Inject
"com.tsng.hidemyapplist" # 4 - Hide My App List (HMA)
"com.google.android.hmal" # 5 - Hide My App List (HMAL)
"org.frknkrc44.hma_oss" # 6 - Hide My App List (OSS)
)

# Modules Data
## Enter path of file of module data.
## Use this format:
## "data_1\ndata_2\ndata_n" # No. - Module Name
MOD_DATA=(
"/data/data/com.google.android.youtube/shared_prefs/revanced_prefs.xml" # 1 - Youtube Revanced - Settings
"/data/adb/tricky_store/keybox.xml\n/data/adb/tricky_store/target.txt\n/data/adb/tricky_store/security_patch.txt" # 2 - Tricky Store & Addon
"/data/adb/modules/playintegrityfix/custom.pif.json" # 3 - Play Integrity Fix/Fork/Inject
"/data/data/com.tsng.hidemyapplist/files/config.json" # 4 - Hide My App List (HMA)
"/data/data/com.google.android.hmal/files/config.json" # 5 - Hide My App List (HMAL)
"/data/data/org.frknkrc44.hma_oss/files/config.json" # 6 - Hide My App List (OSS)
)

#####################################
# Custom Data (You can fill any custom data similarly for your Custom Scripts here)
## Data Can be Variable, Functions or Arrays
