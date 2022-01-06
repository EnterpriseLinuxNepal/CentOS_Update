#!/bin/bash
yum install -y https://buildlogs.centos.org/centos/6/upg/x86_64/Packages/openscap-1.0.8-1.0.1.el6.centos.x86_64.rpm

echo ""
echo "Clearing Old Repositories"
echo " "
sleep 1
mkdir -p /etc/yum.repos.d/old
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/old/
cat > /etc/yum.repos.d/CentOS-Base.repo << EOF

[base]
name=CentOS-\$releasever - Base
# mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=os&infra=\$infra
# baseurl=http://mirror.centos.org/centos/\$releasever/os/\$basearch/
baseurl=https://vault.centos.org/7.0.1406/os/x86_64/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

# released updates
[updates]
name=CentOS-\$releasever - Updates
# mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=updates&infra=\$infra
# baseurl=http://mirror.centos.org/centos/\$releasever/updates/\$basearch/
baseurl=https://vault.centos.org/7.0.1406/updates/x86_64/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

# additional packages that may be useful
[extras]
name=CentOS-\$releasever - Extras
# mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=extras&infra=\$infra
# baseurl=http://mirror.centos.org/centos/\$releasever/extras/\$basearch/
baseurl=https://vault.centos.org/7.0.1406/extras/x86_64/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

EOF

echo "removing all YUM cache"
echo " "

yum clean all

echo "Creating a New CentOS Upgrade Repository"
echo " "

sleep 1

cat > /etc/yum.repos.d/upgrade.repo << EOF
[centos-upgrade]
name=centos-upgrade
baseurl=https://buildlogs.centos.org/centos/\$releasever/upg/\$basearch/
enabled=1
gpgcheck=0

EOF

echo "Installing the pre-upgrade assistant tool"
echo " "

sleep 1

yum install -y redhat-upgrade-tool preupgrade-assistant-*

echo "Running the pre-upgrade assistant tool"
echo " "

sleep 1
preupg -l
yes | preupg -s CentOS6_7

echo "Importing CentOS 7 GPG key"
echo " "

sleep 1

rpm --import http://vault.centos.org/7.0.1406/os/x86_64/RPM-GPG-KEY-CentOS-7

mkdir -p /var/tmp/system-upgrade/base/ /var/tmp/system-upgrade/extras/ /var/tmp/system-upgrade/updates/
echo http://mirror.centos.org/centos/7/os/x86_64/ >> /var/tmp/system-upgrade/base/mirrorlist.txt
echo http://mirror.centos.org/centos/7/extras/x86_64/ >> /var/tmp/system-upgrade/extras/mirrorlist.txt
echo http://mirror.centos.org/centos/7/updates/x86_64/ >> /var/tmp/system-upgrade/updates/mirrorlist.txt

echo "Disable SELinux"

sed -i s/^SELINUX=.*$/SELINUX=permissive/ /etc/sysconfig/selinux

echo "Upgrading CentOS 6 to 7"
echo " "

sleep 1
# centos-upgrade-tool-cli --network=7 --instrepo=http://vault.centos.org/7.0.1406/os/x86_64/
centos-upgrade-tool-cli --force --network=7 --instrepo=http://vault.centos.org/7.0.1406/os/x86_64/ --cleanup-post

echo "rebooting the system"
echo " "

sleep 5
reboot

