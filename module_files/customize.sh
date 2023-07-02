SKIPUNZIP=0
# 通用部分
# SKIPUNZIP: 解压方式。0=自动，1=手动
# MODPATH (path): 当前模块的安装目录
# TMPDIR (path): 可以存放临时文件的目录
# ZIPFILE (path): 当前模块的安装包文件
# ARCH (string): 设备的 CPU 构架，有如下几种arm, arm64, x86, or x64
# IS64BIT (bool): 是否是 64 位设备
# API (int): 当前设备的 Android API 版本 (如: Android 13.0 上为 33)

# For Magisk
# MAGISK_VER (string): 当前安装的 Magisk 的版本字符串 (如: 26.1)
# MAGISK_VER_CODE (int): 当前安装的 Magisk 的版本代码 (如: 26100)
# BOOTMODE (bool): 如果模块被安装在 Magisk 应用程序中则值为true

# For KernelSU
# KSU (bool): 标记此脚本运行在 KernelSU 环境下，此变量的值将永远为 true，你可以通过它区分 Magisk。
# KSU_VER (string): KernelSU 当前的版本名字 (如: v0.4.0)
# KSU_VER_CODE (int): KernelSU 用户空间当前的版本号 (如: 10672)
# KSU_KERNEL_VER_CODE (int): KernelSU 内核空间当前的版本号 (如: 10672)
# BOOTMODE (bool): 此变量在 KernelSU 中永远为 true

if [[ $KSU == true ]]; then
  ui_print "- KernelSU 用户空间当前的版本号: $KSU_VER_CODE"
  ui_print "- KernelSU 内核空间当前的版本号: $KSU_KERNEL_VER_CODE"
else
  ui_print "- Magisk 版本: $MAGISK_VER_CODE"
  if [ "$MAGISK_VER_CODE" -lt 26000 ]; then
    ui_print "*********************************************"
    ui_print "! 请安装 Magisk 26.0+"
    abort "*********************************************"
  fi
fi
rm -rf /data/system/package_cache

if [[ $KSU == true ]]; then
  mkdir -p "$MODPATH""$2"
  rm -rf "$MODPATH""$2"
  replace() {
    if [[ "$1" == "file" ]]; then
      remove $1 $2
    elif [[ "$1" == "directory" ]]; then
      setfattr -n trusted.overlay.opaque -v y "$MODPATH""$2"
    fi
  }
  remove() {
    mknod "$MODPATH""$2" c 0 0
  }
else
  replace() {
    mkdir -p "$MODPATH""$2"
    if [[ "$1" == "file" ]]; then
      rm -rf "$MODPATH""$2"
      touch "$MODPATH""$2"
      chown root:root "$MODPATH""$2"
      chmod 0644 "$MODPATH""$2"
    elif [[ "$1" == "directory" ]]; then
      touch "$MODPATH""$2"/.replace
      chown root:root "$MODPATH""$2"/.replace
      chmod 0644 "$MODPATH""$2"/.replace
    fi
  }
  remove() {
    replace $1 $2
  }
fi

# 用法: 函数名 类型 地址
# 函数名: replace 或 (推荐使用) remove
# replace 功能: 替换掉系统的某个目录,使其成为空目录
# replace 可用类型为 file (仅针对 Magisk ) 或 directory
# remove 功能: 删掉系统原来目录某个文件或者文件夹
# remove 可用类型为 file 或 directory
# 地址: 你要替换的地址
# 例子:
# remove file /system/product/app/AnalyticsCore/AnalyticsCore.apk
# remove directory /system/product/app/AnalyticsCore
# replace directory /system/product/app/AnalyticsCore
# 仅针对 Magisk
# replace file /system/product/app/AnalyticsCore/AnalyticsCore.apk
