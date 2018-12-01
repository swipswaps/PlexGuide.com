#!/bin/bash
#
# Title:      PlexGuide (Reference Title File)
# Author(s):  Admin9705 - Deiteq
# URL:        https://plexguide.com - http://github.plexguide.com
# GNU:        General Public License v3.0
################################################################################

# FUNCTIONS START ##############################################################
source /opt/plexguide/menu/functions/functions.sh

rclonestage () {
mkdir -p /root/.config/rclone/
chown -R 1000:1000 /root/.config/rclone/
cp ~/.config/rclone/rclone.conf /root/.config/rclone/ 1>/dev/null 2>&1
}

defaultvars () {
  touch /var/plexguide/rclone.gdrive
  touch /var/plexguide/rclone.gcrypt
}

bandwidth () {
echo ""
read -p 'TYPE a SERVER SPEED from 1 - 1000 | Press [ENTER]: ' typed < /dev/tty
if [[ "$typed" -ge "1" && "$typed" -le "1000" ]]; then echo "$typed" > /var/plexguide/move.bw && bwpassed;
else badinput && bandwidth; fi
}

bwpassed () {
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅️  PASSED: Bandwidth Limit Set!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 3
}

question1 () {
variable /var/plexguide/move.bw "10"
speed=$(cat /var/plexguide/move.bw)

cat /root/.config/rclone/rclone.conf 2>/dev/null | grep 'gcrypt' | head -n1 | cut -b1-8 > /var/plexguide/rclone.gcrypt
cat /root/.config/rclone/rclone.conf 2>/dev/null | grep 'gdrive' | head -n1 | cut -b1-8 > /var/plexguide/rclone.gdrive

# Declare Ports State
gdrive=$(cat /var/plexguide/rclone.gdrive)
gcrypt=$(cat /var/plexguide/rclone.gcrypt)

  if [ "$gdrive" != "" ] && [ "$gcrypt" == "" ]; then configure="GDrive" && message="Deploy PG Drives: GDrive";
elif [ "$gdrive" != "" ] && [ "$gcrypt" != "" ]; then configure="GDrive /w GCrypt" && message="Deploy PG Drives : GDrive /w GCrypt";
else configure="Not Configured" && message="Unable to Deploy : RClone is Unconfigured"; fi

# Menu Interface
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀  Welcome to PG Move                     📓 Reference: move.plexguide.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📂 Basic Information

Utilizes Google Drive only and limitation is a 750GB daily upload limit.
10MB BWLimit is the safe limit. Follow reference above for more info.

1 - Configure RClone : $configure
2 - Configure BWLimit: $speed MB
3 - $message
Z - Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

# Standby
read -p '🌍 Type Number | Press [ENTER]: ' typed < /dev/tty

  if [ "$typed" == "1" ]; then
    echo ""
    rclone config
    rclonestage
    question1
elif [ "$typed" == "2" ]; then
    bandwidth
    question1
elif [ "$typed" == "3" ]; then
    if [ "$configure" == "GDrive" ]; then
    echo '/mnt/gdrive=RO:' > /var/plexguide/unionfs.pgpath
    ansible-playbook /opt/plexguide/roles/menu-move/remove-service.yml
    ansible-playbook /opt/plexguide/pg.yml --tags menu-move --skip-tags encrypted
    question
    elif [ "$configure" == "GDrive /w GCrypt" ]; then
    echo '/mnt/gcrypt=RO:/mnt/gdrive=RO:' > /var/plexguide/unionfs.pgpath
    ansible-playbook /opt/plexguide/roles/menu-move/remove-service.yml
    ansible-playbook /opt/plexguide/pg.yml --tags menu-move
    quesiton1
    else
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔️  WARNING! WARNING! WARNING! You Need to Configure: gdrive
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  sleep 4
  question1
  fi
elif [[ "$typed" == "z" || "$typed" == "Z" ]]; then
  exit
else
  badinput
  question1
fi
}

question1
