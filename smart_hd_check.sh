#! /bin/bash

# Drives in RAID sdd1[1] sdf1[6] sdg1[4] sde1[2] sda1[5] sdb1[0]
# Attributes to check
# Western Dig:
#       Reallocated_Sector_Ct
#       Temperature_Celsius
#       Reallocated_Event_Count
#       Current_Pending_Sector
#       Offline_Uncorrectable
#       Spin_Retry_Count
# Seagate:
#       Runtime_Bad_Block
#       Reported_Uncorrect
#       UDMA_CRC_Error_Count
#TODAY=$(date +%Y%m%d)
SMARTLOG=""
RAIDDRIVES="sda sdb sdd sde sdf sdg"
SYSDRIVES="sdc"

for DEV in $(echo ${RAIDDRIVES});do
   SMARTLOG="/root/scripts/logs/${DEV}.tmp"
   echo "----------------------------------------------"
   echo "  Checking: ${DEV} Saving to log: ${SMARTLOG}"
   echo "----------------------------------------------"
   /usr/sbin/smartctl -a /dev/${DEV} > ${SMARTLOG}
   /bin/egrep "Device Model|Reallocated|Temperature|Current_Pending_Sector|Uncorrect|Bad_Block|Error_Count" ${SMARTLOG}
   echo "------------------END-------------------------"
done

for DEV in $(echo ${SYSDRIVES});do
   SMARTLOG="/root/scripts/logs/${DEV}.tmp"
   echo "----------------------------------------------"
   echo "  Checking: ${DEV} Saving to log: ${SMARTLOG}"
   echo "----------------------------------------------"
   /usr/sbin/smartctl -a /dev/${DEV} > ${SMARTLOG}
   /bin/egrep "Device Model|Reallocated|Temperature|Current_Pending_Sector|Uncorrect|Bad_Block|Error_Count" ${SMARTLOG}
   echo "------------------END-------------------------"
done
