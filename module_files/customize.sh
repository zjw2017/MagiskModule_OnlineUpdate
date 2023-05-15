SKIPUNZIP=0
# SKIPUNZIP：自动解压。0=自动，1=手动
# MAGISK_VER(string)：当前安装的 Magisk 的版本字符串 (例如:26.1)
# MAGISK_VER_CODE(int)：当前安装的 Magisk 的版本代码 (例如:26100)
# BOOTMODE(bool)：如果模块被安装在 Magisk 应用程序中则值为true
# MODPATH(path)：模块文件的安装路径
# TMPDIR(path)：可以临时存放文件的地方
# ZIPFILE（路径）：您的模块的安装 zip
# ARCH（字符串）：设备的 CPU 架构。值为arm, arm64, x86, 或x64
# IS64BIT(bool)：如果$ARCH是arm64或者x64则值为true
# API(int)：设备的 API 级别（Android 版本）（例如21，对于 Android 5.0）
if [ "$API" -ge 31 ]; then
  ui_print "- Android SDK version: $API"
else
  ui_print "*********************************************"
  ui_print "! Unsupported Android SDK version $API"
  abort "*********************************************"
fi
ui_print "- Magisk version: $MAGISK_VER_CODE"
if [ "$MAGISK_VER_CODE" -lt 24000 ]; then
  ui_print "*********************************************"
  ui_print "! Please install Magisk 24.0+"
  abort "*********************************************"
fi
rm -rf /data/system/package_cache