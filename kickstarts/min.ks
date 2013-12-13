install
url --url http://192.168.1.9:8080/6.4/os/x86_64/
repo --name=updates --baseurl=http://192.168.1.9:8080/6.4/updates/x86_64/
repo --name=puppet --baseurl=http://192.168.1.9:8080/6.4/products/x86_64/
repo --name=puppet-deps --baseurl=http://192.168.1.9:8080/6.4/dependencies/x86_64/
lang en_US.UTF-8
%include /tmp/network.ks
# Bogus password, change to something sensible!
rootpw password123
firewall --disabled
authconfig --enableshadow --enablemd5
selinux --disabled
timezone --utc America/New_York
bootloader --location=mbr --driveorder=xvda --append="console=hvc0"
services --enabled=puppet
shutdown

# Partitioning
zerombr
clearpart --all --initlabel --drives=xvda
part /boot --fstype ext3 --size=100 --ondisk=xvda
part pv.2 --size=4096 --grow --ondisk=xvda
volgroup VG_BASE --pesize=32768 pv.2
logvol / --fstype ext3 --name=LV_ROOT --vgname=VG_BASE --size=1024 --grow
logvol swap --fstype swap --name=LV_SWAP --vgname=VG_BASE --size=256 --grow --maxsize=512

%packages --nobase
openssh-clients
openssh-server
yum
at
acpid
vixie-cron
cronie-noanacron
crontabs
logrotate
ntp
ntpdate
tmpwatch
rsync
mailx
which
wget
puppet
-postfix
-prelink
-selinux-policy-targeted
-sendmail
%end

%pre
#!/bin/sh
for x in `cat /proc/cmdline`; do
        case $x in SERVERNAME*)
	        eval $x
		echo "network --device eth0 --bootproto dhcp --hostname ${SERVERNAME}.ark-net.org" > /tmp/network.ks
                ;;
	        esac;
	done
%end


%post --log=/root/post_install.log
echo
echo "################################"
echo "# Running Post Configuration   #"
echo "################################"
echo hvc0 >> /etc/securetty
sed -i 's/ACTIVE_CONSOLES.*$/ACTIVE_CONSOLES=\/dev\/hvc0/' /etc/sysconfig/init
sed -i 's/HWADDR=.*//' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i 's/UUID=.*//' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i 's/\[2345\]/\[\]/' /etc/init/serial.conf
%end
