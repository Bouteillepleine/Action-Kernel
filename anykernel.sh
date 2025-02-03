### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=MKSU With SUSFS by Ryhoaca &TanakaLun
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    5.1*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print " " "  -> ksu_supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

# boot install
if [ -L "/dev/block/bootdevice/by-name/init_boot_a" -o -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot # for devices with init_boot ramdisk
    flash_boot # for devices with init_boot ramdisk
else
    dump_boot # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk
    write_boot # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
fi
## end boot install
KSUD_FILE="/data/adb/ksud"
MAGISK_DB_FILE="/data/adb/magisk.db"
MODULE_ZIP="$AKHOME/ksu_module_susfs_1.5.2+.zip"
if [ -f "$KSUD_FILE" ]; then
    ui_print " "
    ui_print "  -> 检测到KernelSU，正在安装 SUSFS 模块..."
    /data/adb/ksudmodule install "$MODULE_ZIP"
    if [ $? -eq 0 ]; then
        ui_print "  -> SUSFS 模块安装成功！"
    else
        ui_print "  -> SUSFS 模块安装失败！"
    fi
fi
if [ -f "$MAGISK_DB_FILE" ]; then
    ui_print " "
    ui_print "  -> 检测到Magisk，正在安装 SUSFS 模块..."
    magisk --install-module "$MODULE_ZIP"
    if [ $? -eq 0 ]; then
        ui_print "  -> SUSFS 模块安装成功！"
##end module install
        ui_print "  -> 正在清理 /data/adb 目录下的 magisk 相关文件..."
        find /data/adb -name "*magisk*" -exec rm -rf {} +
        if [ $? -eq 0 ]; then
            ui_print "  -> magisk 相关文件清理完成！"
        else
            ui_print "  -> magisk 相关文件清理失败！"
        fi
    else
        ui_print "  -> SUSFS 模块安装失败！"
    fi
fi

ui_print " "
ui_print "  -> 脚本执行完毕！"
##end clear magisk
SUSFS_DIR="/data/adb/susfs4ksu"
CONFIG_FILE="$SUSFS_DIR/config.sh"
TARGET_STRING="sus_su=2"
if [ ! -d "$SUSFS_DIR" ]; then
    ui_print " "
    ui_print "  -> 未找到 susfs4ksu 文件夹，正在创建..."
    mkdir -p "$SUSFS_DIR"
    if [ $? -eq 0 ]; then
        ui_print "  -> susfs4ksu 文件夹创建成功！"
    else
        ui_print "  -> susfs4ksu 文件夹创建失败！"
        abort "  -> 脚本中止。"
    fi
fi
if [ ! -f "$CONFIG_FILE" ]; then
    ui_print " "
    ui_print "  -> 未找到 config.sh 文件，正在创建..."
    touch "$CONFIG_FILE"
    if [ $? -eq 0 ]; then
        ui_print "  -> config.sh 文件创建成功！"
    else
        ui_print "  -> config.sh 文件创建失败！"
        abort "  -> 脚本中止。"
    fi
fi
if ! grep -q "$TARGET_STRING" "$CONFIG_FILE"; then
    ui_print " "
    ui_print "  -> 未找到 '$TARGET_STRING'，正在添加到 config.sh 文件末尾..."
    echo "$TARGET_STRING" >> "$CONFIG_FILE"
    if [ $? -eq 0 ]; then
        ui_print "  -> '$TARGET_STRING' 添加成功！"
    else
        ui_print "  -> '$TARGET_STRING' 添加失败！"
        abort "  -> 脚本中止。"
    fi
else
    ui_print " "
    ui_print "  -> '$TARGET_STRING' 已存在，无需添加。"
fi

ui_print " "
ui_print "  -> 脚本执行完毕！"
##end set susfs4ksu