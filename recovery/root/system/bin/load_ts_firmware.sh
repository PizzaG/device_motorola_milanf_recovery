#!/system/bin/sh

touch_class_path=/sys/class/touchscreen
touch_path=/sys/class/touchscreen/primary
firmware_path=/vendor/firmware
firmware_file=csot_novatek_ts_fw.bin
device=$(getprop ro.boot.device)

wait_for_poweron()
{
	local wait_nomore
	local readiness
	local count
	wait_nomore=60
	count=0
	while true; do
		readiness=$(cat $touch_path/poweron)
		if [ "$readiness" == "1" ]; then
			break;
		fi
		count=$((count+1))
		[ $count -eq $wait_nomore ] && break
		sleep 1
	done
	if [ $count -eq $wait_nomore ]; then
		return 1
	fi
	return 0
}
cd $firmware_path
touch_product_string=$(ls $touch_class_path)
if [[ -d /sys/class/touchscreen/ft8009 ]]; then
       echo "novatek"
       firmware_file="csot_novatek_ts_fw.bin"
       touch_path=/sys$(cat $touch_class_path/$touch_product_string/path | awk '{print $1}')
       wait_for_poweron
       echo $firmware_file > $touch_path/doreflash
       echo 1 > $touch_path/forcereflash
       sleep 5
       echo 1 > $touch_path/reset
elif [[ -d /sys/class/touchscreen/primary ]]; then
        echo "novatek"
        cfirmware_file="csot_novatek_ts_fw.bin"
        echo 1 > /proc/nvt_update
fi

sleep 10

svc usb setFunctions mtp
mount -o rw /system_root
mount -o rw /system_ext
mount -o rw /product
mount -o rw /vendor

return 0
