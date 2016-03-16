#! /bin/bash

#####################################################################
#Script name: backup_raid.sh                                        #
#Params: NONE                                                       #
#Returns: 0 if successful, 1 if mount error, 2 if USB un-attached   #
#Abstract: This script will backup the raid defined in variable     #
#       RAID. The directories to backup are defined in the          #
#       variable BD<N>DIRS where <N> is the number                  #
#       corresponding to the physical backup disk. Physical         #
#       backup disks are defined in the variable BKUPDRIVES.        #
#####################################################################

# Intialize Variables Backup Script
RSYNCEMAIL="/tmp/.rsync_status_email"
RSYNCLOG="/root/scripts/logs/rsync.log.$(date +%Y%m%d%H%m%S)"
RAIDMNT="/storage"
# Where is the backup drive mounted
BKUPDRIVEMNT="/backup/mhddfs-backup"

# Create boilerplate email TO, FROM, SUBJECT
# Change TO and FROM to your needs
echo "To: EMAIL@email.com" > ${RSYNCEMAIL}
echo "From: SERVER@home.net" >> ${RSYNCEMAIL}
echo "Subject: Rsync Status Update" >> ${RSYNCEMAIL}

# Mount backup mhddfs fuse pool
# check if usb drives are attached
# if drives are attached, and not already mounted at BKUPDRIVEMNT
# Assumes you have mhddfs mount in /etc/fstab (ubuntu)
if [ -z "$(mount -l -t fuse.mhddfs)" ]; then
    echo "Running mount -a to remount drives"
    mount -a
    # test if mount failed and exit if it did
    if [ $? -ne 0 ]; then
        echo "Error occurred during backup drive mount" >> ${RSYNCEMAIL}
        /usr/sbin/ssmtp -t < ${RSYNCEMAIL}
        echo "Error occurred during backup drive mount"
        echo "Exiting and canceling backup"
        exit 1
    fi
fi

# Backup dont honor deletes for these directories
BKUPDIRSARCH="Pictures Public Users Backups"
for BDIR in ${BKUPDIRSARCH}; do
    echo "======================================"
    echo " Archiving: ${BDIR}"
    echo "======================================"
    rsync -avh ${RAIDMNT}/${BDIR} ${BKUPDRIVEMNT} --log-file=${RSYNCLOG}
    echo "Archive backup Complete for Directory: ${BDIR}" >> ${RSYNCEMAIL}
done

# Backup but honor deletes for these directories
BKUPDIRSMIRROR="Books Videos Videos_HD Anime"
for BDIR in ${BKUPDIRSMIRROR}; do
    echo "======================================"
    echo " Mirroring: ${BDIR}"
    echo "======================================"
    rsync -avh --delete --dirs ${RAIDMNT}/${BDIR} ${BKUPDRIVEMNT} --log-file=${RSYNCLOG}
    echo "Mirror backup Complete for Directory: ${BDIR}" >> ${RSYNCEMAIL}
done

echo "Free Space Remaining on Backup Drive" >> ${RSYNCEMAIL}
/bin/df -hl ${BKUPDRIVEMNT} >> ${RSYNCEMAIL}

# Send Complete Email.
echo "Backup Complete" >> ${RSYNCEMAIL}
/usr/sbin/ssmtp -t < ${RSYNCEMAIL}

exit 0
