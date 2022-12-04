SKIPUNZIP=0
SDK=$(getprop ro.system.build.version.sdk)
if [ "$SDK" -ge 28 ]; then
  ui_print "- Android SDK version: $SDK"
else
  ui_print "*********************************************************"
  ui_print "! Unsupported Android SDK version $SDK"
  abort "*********************************************************"
fi
ui_print "- Magisk version: $MAGISK_VER_CODE"
if [ "$MAGISK_VER_CODE" -lt 24000 ]; then
  ui_print "*********************************************************"
  ui_print "! Please install Magisk 24.0+"
  abort "*********************************************************"
fi

