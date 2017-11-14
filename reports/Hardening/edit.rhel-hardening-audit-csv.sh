#!/bin/bash
#
##
#########################################################
#                                                       #
###             rhel-hardening-audit-csv_1.0.sh		#
###     This script is for Auditing RHEL-7.0 based on   #
###     CIS_Red_Hat_Enterprise_Linux_7_Benchmark_v1.1.0 #
#                       #####                           #
##      Author/s ---                                    #
##      Shawn Miller- IT - Linux Systems Engineer	#
##      Final Working Rev. - 07 February 2016		#
##      The Wood-Bee Company				#
#                                                       #
#########################################################
#
###################################################################################
#####           rhel-hardening-audit-csv_1.0.sh
#####           07 February, 2016- Shawn Miller
#####   Objective- 1.	Full audit according to the RHEL Documentation
#####  			with Section Name/# and PASS/FAIL Results
#####   Objective- 2.	Full compatibility with SUSE-based OS
#####   Objective- 3. 	Option to automatically Remediate all FAILED 
#####  			audit results, and re-run audit scan/report
#####  
###################################################################################
#####                   GNU/GPL Info                                            ###
###################################################################################
#
function gpl_info
{
echo -e "\n
####c4#############################################################################
###                                                                             ###
##                      GNU/GPL Info                                            ###
##              Hardeningcsv ver. 0.1  RC-1					###
##      Released under GPL v2.0, See www.gnu.org for full license info          ###
##      Copyright (C) 2015  Shawn Miller                                        ###
##      Copyright (C) 2015  The Wood-Bee Company                                ###
##              EMAIL- shawn@woodbeeco.com                                      ###
##  This program is free software; you can redistribute it and/or modify        ###
##    it under the terms of the GNU General Public License as published by      ###
##    the Free Software Foundation; either version 2 of the License, or         ###
##    (at your option) any later version.                                       ###
##                                                                              ###
##    This program is distributed in the hope that it will be useful,           ###
##    but WITHOUT ANY WARRANTY; without even the implied warranty of            ###
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             ###
##    GNU General Public License for more details.                              ###
##                                                                              ###
####w#################################b######################################c#####\n"
}
#
###	Static Variables
#
	PROGNAME=$(basename $0)
	REVNUM="1.0.1-05"
	ARCH="`uname -p`"
	HOSTA="`hostname`"
	RDATE=`date +%Y-%b-%d-%H:%M`
	TDATE=`date +%Y-%b-%d`
	BRKNCMD="`grep wheel /etc/group | awk -F: '{print $4}'`"
	SINGLE=false
	REPFILE=/tmp/scan-report-$TDATE.csv
	touch $REPFILE
	SNDMAIL=false
	HRDTMPA=/tmp/hrdtmpa.txt
	HRDTMPB=/tmp/hrdtmpb.txt
	HRDTMPC=/tmp/hrdtmpc.txt
	HRDTMPD=/tmp/hrdtmpd.txt
#
###	Static functions
#
function snd_mail
{
        touch /tmp/mail.txt
        EMAILMSGZ=/tmp/mail.txt
        echo "Running Hardening Audit on $HOSTA for $RDATE" > $EMAILMSGZ
        SUBJECT="$HOSTA -- Hardening Audit $RDATE"
        EMAILG=shawn@woodbeeco.com,seaphor@woodbeeco.com
        FROMA=admin@$HOSTA
        /usr/bin/mailx -a $REPFILE -s "$SUBJECT" "$EMAILG" -f $FROMA < $EMAILMSGZ
	rm $EMAILMSGZ
}
#
###	Options/Usage
#
	USAGE="\n\tDescription --\thardeningcsv_1.0.sh\n\t\tThis script Is designed to audit a Red Hat Based OS according to the CIS Red Hat Enterprise Linux 7 Benchmark located at https://benchmarks.cisecurity.org/tools2/linux/CIS_Red_Hat_Enterprise_Linux_7_Benchmark_v1.1.0.pdf - This intended to provide information that points out where your Red Hat based OS needs 'Hardening', according to Official RHEL Hardening Standards.\n\n\tIt creates a '/tmp/scan-report.csv' file.\n\n\tUsage --\n\t\tcommand with NO options runs full audit\n\t\tcommand OPTION\n\tOptions --\n\t\t[help]\t\t\tPrints this Usage page\n\t\t[list]\t\t\tProvides the list of individual FUNCTION calls and exits\n\t\t[FUNCTION]\tExecutes the single FUNCTION called,\n\t\t\t\t\t\t- as one from the 'list' (see 'Examples' below)\n\t\t[mail]\t\t\tMails the report to set address- Edit the 'EMAILG in\n\t\t\t\t\t\tthe snd_mail section to who needs it\n\t\t[gpl]\t\t\tPrints the GNU/GPL License Information and exits\n\tExamples --\n\t\tsh hardeningRHcsv.sh ## Runs FULL audit\n\t\tsh hardeningRHcsv.sh list | grep -i root\n\t\tsh hardeningRHcsv.sh rootlogin_ssh\n\tTypical Use --\n\t\tsh hardeningRHcsv.sh\n\t\tgrep Fail /tmp/scan-report.csv > Remediation-List.csv\n\t\tpastebin Remediation-List.csv >> Remediation-List.csv\n\n\tAuthor/s --\n\t\tShawn Miller- 05 February 2016 - shawn@woodbeeco.com\n"
if [ "`echo $1`" != "" ]; then
	if [ "`echo $1`" == "help" ]; then
		echo -e $USAGE
		exit 0
	else
		if [ "`echo $1`" == "list" ]; then
			grep function $PROGNAME | grep -v 'PROG' | grep -v "[0-9]" | awk '{print $2}'
			exit 0
		else
			if [ "`echo $1`" == "gpl" ]; then
				gpl_info
				exit 0
			else
				if [ "`echo $1`" == "mail" ]; then
					SNDMAIL=true
				else
					if [ "`echo $1`" == "rev" ]; then
						echo $PROGNAME-$REVNUM
						exit 0
					else
						SINGLE=true
					fi
				fi
			fi
		fi
	fi
fi
###
################################################################################################
###	FUNCTIONS
################################################################################################
###
#
################################################################################################
###	1.0 Install Updates, Patches and Additional Security Software
################################################################################################
###	1.1 Checking for updates
######################################################
#
function patch_list
{
yum check-update > $HRDTMPA 
if [ "`grep $ARCH $HRDTMPA`" == "" ]; then
	echo -e "1.1.0,Patch-Updates,=,Pass" >> $REPFILE
else
	echo -e "1.1.0,Patch-Updates,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	1.1.1 Seperate Partition for /tmp
######################################################
function part_tmp
{
grep "[[:space:]]/tmp[[:space:]]" /etc/fstab > $HRDTMPA
if [ "`grep 'tmp' $HRDTMPA`" == "" ]; then
        echo -e "1.1.1,Seperate tmp,=,Fail" >> $REPFILE
else
        echo -e "1.1.1,Seperate tmp,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.1.2 Set nodev on Partition for /tmp
######################################################
function nodev_tmp
{
grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nodev > $HRDTMPA
mount | grep "[[:space:]]/tmp[[:space:]]" | grep nodev >> $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "1.1.2,Set nodev tmp,=,Fail" >> $REPFILE
else
        echo -e "1.1.2,Set nodev tmp,=,Pass" >> $REPFILE
fi
}
#
######################################################
###     1.1.3 Set nosuid on Partition for /tmp
######################################################
function nosuid_tmp
{
grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nosuid > $HRDTMPA
mount | grep "[[:space:]]/tmp[[:space:]]" | grep nosuid >> $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "1.1.3,Set nosuod tmp,=,Fail" >> $REPFILE
else
        echo -e "1.1.3,Set nosuid tmp,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.1.4 Set noexec option for /tmp Partition
######################################################
function noexec_tmp
{
grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep noexec > $HRDTMPA
mount | grep "[[:space:]]/tmp[[:space:]]" | grep noexec >> $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "1.1.4,Set noexec tmp,=,Fail" >> $REPFILE
else
        echo -e "1.1.4,Set noexec tmp,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.1.5 Create Separate Partition for /var
######################################################
function part_var
{
grep "[[:space:]]/var[[:space:]]" /etc/fstab > $HRDTMPA
if [ "`grep 'var' $HRDTMPA`" == "" ]; then
        echo -e "1.1.5,Seperate var,=,Fail" >> $REPFILE
else
        echo -e "1.1.5,Seperate var,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.1.6 Bind Mount the /var/tmp directory to /tmp
######################################################
function nobind_vartmp
{
grep -e "^/tmp[[:space:]]" /etc/fstab | grep /var/tmp > $HRDTMPA
mount | grep -e "^/tmp[[:space:]]" | grep /var/tmp >> $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "1.1.6,Bind tmp vartmp,=,Fail" >> $REPFILE
else
        echo -e "1.1.6,Bind tmp vartmp,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.1.7 Create Separate Partition for /var/log
######################################################
function part_varlog
{
grep "[[:space:]]/var/log[[:space:]]" /etc/fstab > $HRDTMPA
if [ "`grep 'var' $HRDTMPA`" == "" ]; then
        echo -e "1.1.7,Seperate varlog,=,Fail" >> $REPFILE
else
        echo -e "1.1.7,Seperate varlog,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.1.8 Create Separate Partition for /var/log/audit
######################################################
function part_varlogaud
{
grep "[[:space:]]/var/log/audit[[:space:]]" /etc/fstab > $HRDTMPA
if [ "`grep 'var' $HRDTMPA`" == "" ]; then
        echo -e "1.1.8,Sep varlogaudit,=,Fail" >> $REPFILE
else
        echo -e "1.1.8,Sep varlogaudit,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.1.9 Create Separate Partition for /home 
######################################################
function part_home
{
grep "[[:space:]]/home[[:space:]]" /etc/fstab > $HRDTMPA
if [ "`grep 'home' $HRDTMPA`" == "" ]; then
        echo -e "1.1.9,Seperate home,=,Fail- This is ONLY valid if the system was designed to support Local Users" >> $REPFILE
else
        echo -e "1.1.9,Seperate home,=,Pass- This is ONLY valid if the system was designed to support Local Users" >> $REPFILE
fi
}
#
######################################################
###	1.1.10 Add nodev Option to /home
######################################################
function nodev_home
{
grep "[[:space:]]/home[[:space:]]" /etc/fstab > $HRDTMPA
mount | grep /home > $HRDTMPA
if [ "`grep nodev $HRDTMPA`" == "" ]; then
        echo -e "1.1.10,Set nodev home,=,Fail- This is ONLY valid if the system was designed to support Local Users" >> $REPFILE
else
        echo -e "1.1.10,Set nodev home,=,Pass- This is ONLY valid if the system was designed to support Local Users" >> $REPFILE
fi
}
#
######################################################
###	1.1.11 Add nodev Option to /dev/shm Partition
######################################################
function nodev_devshm
{
grep /dev/shm /etc/fstab | grep nodev > $HRDTMPA
mount | grep /dev/shm | grep nodev >> $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "1.1.11,Set nodev shm,=,Fail" >> $REPFILE
else
        echo -e "1.1.11,Set nodev shm,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.1.12 Add nosuid Option to /dev/shm Partition 
######################################################
function nosuid_devshm
{
grep /dev/shm /etc/fstab | grep nosuid > $HRDTMPA
mount | grep /dev/shm | grep nosuid >> $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "1.1.12,Set nosuid shm,=,Fail" >> $REPFILE
else
        echo -e "1.1.12,Set nosuid shm,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.1.13 Add noexec Option to /dev/shm Partition
######################################################
function noexec_devshm
{
grep /dev/shm /etc/fstab | grep noexec > $HRDTMPA
mount | grep /dev/shm | grep noexec >> $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "1.1.13,Set noexec shm,=,Fail" >> $REPFILE
else
        echo -e "1.1.13,Set noexec shm,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.1.14 Set Sticky Bit on All World-Writable Directories
######################################################
function sticky_set
{
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "1.1.14,Set sticky shm,=,Fail" >> $REPFILE
else
        echo -e "1.1.14,Set sticky shm,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.2 Configure Software Updates
######################################################
###	1.2.1 Verify Red Hat GPG Key is Installed
######################################################
function redhat_gpg
{
rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey > $HRDTMPA
if [ "`grep redhat $HRDTMPA`" == "" ]; then
        echo -e "1.2.1,RedHat gpg key,=,Fail" >> $REPFILE
else
        echo -e "1.2.1,RedHat gpg key,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.2.2 Verify that gpgcheck is Globally Activated 
######################################################
function redhat_activegpg
{
grep gpgcheck /etc/yum.conf > $HRDTMPA
if [ "`grep 1 $HRDTMPA`" == "" ]; then
        echo -e "1.2.2,Verify gpg key,=,Fail" >> $REPFILE
else
        echo -e "1.2.2,Verify gpg key,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.3 Secure Boot Settings
######################################################
###	1.3.1 Set User/Group Owner on /boot/grub2/grub.cfg 
######################################################
function grub_owner
{
stat -L -c "%u %g" /boot/grub2/grub.cfg | egrep "0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "1.3.1,Set grub owner,=,Fail" >> $REPFILE
else
        echo -e "1.3.1,Set grub owner,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.3.2 Set Permissions on /boot/grub2/grub.cfg
######################################################
function grub_perms
{
stat -L -c "%a" /boot/grub2/grub.cfg | egrep ".00" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "1.3.2,Set grub perms,=,Fail" >> $REPFILE
else 
        echo -e "1.3.2,Set grub perms,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.3.3 Set Boot Loader Password
######################################################
function boot_pass
{
grep "^set superusers" /boot/grub2/grub.cfg > $HRDTMPA
grep "^password" /boot/grub2/grub.cfg >> $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "1.3.3,Grub boot pass,=,Fail" >> $REPFILE
else
        echo -e "1.3.3,Grub boot pass,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	1.4 Additional Process Hardening
######################################################
###	1.4.1 Restrict Core Dumps
######################################################
function core_dumps
{
grep "hard core" /etc/security/limits.conf > $HRDTMPA
sysctl fs.suid_dumpable > $HRDTMPB
if [ "`cat $HRDTMPA`" == "" ]; then
	PASSA="Fail"
else
	PASSA="Pass"
fi
if [ "`grep 0 $HRDTMPB`" == "" ]; then
	PASSB="Fail"
else
	PASSB="Pass"
fi
echo -e "1.4.1,Check coredump,=,$PASSA/$PASSB" >> $REPFILE
}
#
######################################################
###	1.4.2 Enable Randomized Virtual Memory Region Placement
######################################################
function rand_virtmem
{
sysctl kernel.randomize_va_space > $HRDTMPA
if [ "`grep 2 $HRDTMPA`" == "" ]; then
        echo -e "1.4.2,Rand virt mem,=,Fail" >> $REPFILE
else
        echo -e "1.4.2,Rand virt mem,=,Pass" >> $REPFILE
fi
}
#
################################################################################################
#	2.0 OS Services
################################################################################################
###	2.1 Remove Legacy Services
######################################################
###	2.1.1 Remove telnet-server
######################################################
function check_telnet
{
rpm -q telnet-server > $HRDTMPA
if [ "`grep 'not installed' $HRDTMPA`" == "" ]; then
        echo -e "2.1.1,Telnet servers,=,Fail" >> $REPFILE
else
        echo -e "2.1.1,Telnet servers,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.2 Remove telnet Clients
######################################################
function check_tnetcli
{
rpm -q telnet > $HRDTMPA
if [ "`grep 'not installed' $HRDTMPA`" == "" ]; then
        echo -e "2.1.2,Telnet clients,=,Fail" >> $REPFILE
else
        echo -e "2.1.2,Telnet clients,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.3 Remove rsh-server 
######################################################
function check_rsh
{
rpm -q rsh-server > $HRDTMPA
if [ "`grep 'not installed' $HRDTMPA`" == "" ]; then
        echo -e "2.1.3,Chk rhs server,=,Fail" >> $REPFILE
else
        echo -e "2.1.3,Chk rhs server,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.4 Remove rsh
######################################################
function check_rshpkg
{
rpm -q rsh > $HRDTMPA
if [ "`grep 'not installed' $HRDTMPA`" == "" ]; then
        echo -e "2.1.4,Chk rhs pakges,=,Fail" >> $REPFILE
else
        echo -e "2.1.4,Chk rhs pakges,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.5 Remove NIS Client 
######################################################
function check_niscli
{
rpm -q ypbind > $HRDTMPA
if [ "`grep 'not installed' $HRDTMPA`" == "" ]; then
        echo -e "2.1.5,Chk NIS ypbind,=,Fail" >> $REPFILE
else
        echo -e "2.1.5,Chk NIS ypbind,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.6 Remove NIS Server 
######################################################
function check_nissrv
{
rpm -q ypserv > $HRDTMPA
if [ "`grep 'not installed' $HRDTMPA`" == "" ]; then
        echo -e "2.1.6,Chk NIS ypserv,=,Fail" >> $REPFILE
else
        echo -e "2.1.6,Chk NIS ypserv,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.7 Remove tftp 
######################################################
function check_tftp
{
rpm -q tftp > $HRDTMPA
if [ "`grep 'not installed' $HRDTMPA`" == "" ]; then
        echo -e "2.1.7,Ch Tftp pakges,=,Fail" >> $REPFILE
else
        echo -e "2.1.7,Ch Tftp pakges,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.8 Remove tftp-server 
######################################################
function check_tftpsrv
{
rpm -q tftp-server > $HRDTMPA
if [ "`grep 'not installed' $HRDTMPA`" == "" ]; then
        echo -e "2.1.8,Ch Tftp Server,=,Fail" >> $REPFILE
else
        echo -e "2.1.8,Ch Tftp Server,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.9 Remove talk 
######################################################
function check_talk
{
rpm -q talk > $HRDTMPA
if [ "`grep 'not installed' $HRDTMPA`" == "" ]; then
        echo -e "2.1.9,Ch Talk pakges,=,Fail" >> $REPFILE
else
        echo -e "2.1.9,Ch Talk pakges,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.10 Remove talk server
######################################################
function check_talksrv
{
rpm -q talk-server > $HRDTMPA
if [ "`grep 'not installed' $HRDTMPA`" == "" ]; then
        echo -e "2.1.10,Ch Talk Server,=,Fail" >> $REPFILE
else
        echo -e "2.1.10,Ch Talk Server,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.11 Remove xinetd 
######################################################
function check_xintd
{
rpm -q xinetd > $HRDTMPA
if [ "`grep 'not installed' $HRDTMPA`" == "" ]; then
        echo -e "2.1.11,Checkif xinetd,=,Fail" >> $REPFILE
else
        echo -e "2.1.11,Checkif xinetd,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.12 Disable chargen-dgram 
######################################################
function chrgn_dgram
{
chkconfig --list chargen-dgram > $HRDTMPA 2>&1
if [ "`grep -i error $HRDTMPA`" == "" ]; then
        echo -e "2.1.12,Chargen dgram,=,Fail" >> $REPFILE
else
        echo -e "2.1.12,Chargen dgram,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.13 Disable chargen-stream 
######################################################
function chrgn_stream
{
chkconfig --list chargen-stream > $HRDTMPA 2>&1
if [ "`grep -i error $HRDTMPA`" == "" ]; then
        echo -e "2.1.13,Chargen stream,=,Fail" >> $REPFILE
else
        echo -e "2.1.13,Chargen stream,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.14 Disable daytime-dgram 
######################################################
function daytim_dgram
{
chkconfig --list daytime-dgram > $HRDTMPA 2>&1
if [ "`grep -i error $HRDTMPA`" == "" ]; then
        echo -e "2.1.14,Daytime dgram,=,Fail" >> $REPFILE
else
        echo -e "2.1.14,Daytime dgram,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.15 Disable daytime-stream 
######################################################
function daytim_stream
{
chkconfig --list daytime-stream > $HRDTMPA 2>&1
if [ "`grep -i error $HRDTMPA`" == "" ]; then
        echo -e "2.1.15,Daytime stream,=,Fail" >> $REPFILE
else
        echo -e "2.1.15,Daytime stream,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.16 Disable echo-dgram 
######################################################
function echo_dgram
{
chkconfig --list echo-dgram > $HRDTMPA 2>&1
if [ "`grep -i error $HRDTMPA`" == "" ]; then
        echo -e "2.1.16,Ch echo-dgram,=,Fail" >> $REPFILE
else
        echo -e "2.1.16,Ch echo-dgram,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.17 Disable echo-stream 
######################################################
function echo_stream
{
chkconfig --list echo-stream > $HRDTMPA 2>&1
if [ "`grep -i error $HRDTMPA`" == "" ]; then
        echo -e "2.1.17,Ch echo-stream,=,Fail" >> $REPFILE
else
        echo -e "2.1.17,Ch echo-stream,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	2.1.18 Disable tcpmux-server 
######################################################
function tcpmux_server
{
chkconfig --list tcpmux-server > $HRDTMPA 2>&1
if [ "`grep -i error $HRDTMPA`" == "" ]; then
        echo -e "2.1.18,tcpmux-server,=,Fail" >> $REPFILE
else
        echo -e "2.1.18,tcpmux-server,=,Pass" >> $REPFILE
fi
}
#
################################################################################################
###	3.0 Special Purpose Services
################################################################################################
###	3.1.1 Set Daemon umask 
######################################################
function daem_umask
{
grep umask /etc/sysconfig/init > $HRDTMPA
if [ "`grep '027' $HRDTMPA`" == "" ]; then
        echo -e "3.1.1,Daemon umask,=,Fail" >> $REPFILE
else
        echo -e "3.1.1,Daemon umask,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	3.1.2 Remove the X Window System 
######################################################
function check_xwin
{
ls -l /etc/systemd/system/default.target | grep graphical.target > $HRDTMPA
if [ "`cat $HRDTMPA`" != "" ]; then
	PASSC="Fail"
else
	PASSC="Pass"
fi
rpm -q xorg-x11-server-common > $HRDTMPB
if [ "`grep 'not installed' $HRDTMPB`" == "" ]; then
	PASSD="Fail"
else
	PASSD="Pass"
fi
echo -e "3.1.2,Gfx boot pkg,=,$PASSC/$PASSD" >> $REPFILE
}
#
######################################################
###	3.1.3 Disable Avahi Server 
######################################################
function check_avahi
{
systemctl is-enabled avahi-daemon > $HRDTMPA
if [ "`grep 'enabled' $HRDTMPA`" == "" ]; then
        echo -e "3.1.3,Avahi server,=,Fail" >> $REPFILE
else
        echo -e "3.1.3,Avahi server,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	3.1.4 Remove DHCP Server 
######################################################
function check_dhcp
{
rpm -q dhcp > $HRDTMPA
if [ "`grep 'not installed' $HRDTMPA`" == "" ]; then
        echo -e "3.1.4,Ch Dhcp server,=,Fail" >> $REPFILE
else
        echo -e "3.1.4,Ch Dhcp server,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	3.1.5 Configure Network Time Protocol (NTP) 
######################################################
function check_ntp
{
grep "restrict default" /etc/ntp.conf > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
	PASSE="Fail"
else
	if [ "`grep 'restrict default kod nomodify notrap nopeer noquery' $HRDTMPA`" == "" ]; then
		PASSE="Fail"
	else
		PASSE="Pass"
	fi
fi
grep "restrict -6 default" /etc/ntp.conf > $HRDTMPB
if [ "`cat $HRDTMPB`" == "" ]; then
	PASSF="Fail"
else
	if [ "`grep 'restrict -6 default kod nomodify notrap nopeer noquery'$HRDTMPB`" == "" ]; then
		PASSF="Fail"
	else
		PASSF="Pass"
	fi
fi
grep "^server" /etc/ntp.conf > $HRDTMPC
if [ "`grep 'time01' $HRDTMPC`" == "" ]; then
	PASSG="Fail"
else
	PASSG="Pass"
fi
grep "ntp:ntp" /etc/sysconfig/ntpd > $HRDTMPD
if [ "`cat $HRDTMPD`" == "" ]; then
	PASSH="Fail"
else
	PASSH="Pass"
fi
echo -e "3.1.5,Ch NTP server,=,$PASSE/$PASSF/$PASSG/$PASSH" >> $REPFILE
}
#
######################################################
###	3.1.6 Configure Mail Transfer Agent for Local-Only Mode 
######################################################
function local_mail
{
netstat -an | grep LIST | grep ":25[[:space:]]" > $HRDTMPA
if [ "`grep 'tcp' $HRDTMPA | grep 127.0.0.1:25 | grep LISTEN`" == "" ]; then
	echo -e "3.1.6,Ch Local Mail,=,Fail" >> $REPFILE
else
	echo -e "3.1.6,Ch Local Mail,=,Pass" >> $REPFILE
fi
}
#
################################################################################################
###	4.0 Network Configuration and Firewalls
################################################################################################
###	4.1 Modify Network Parameters 
######################################################
###	4.1.1 Disable IP Forwarding 
######################################################
function forward_ip
{
/sbin/sysctl net.ipv4.ip_forward > $HRDTMPA
if [ "`grep '0' $HRDTMPA`" == "" ]; then
	echo -e "4.1.1,Ch ip forward,=,Fail" >> $REPFILE
else
	echo -e "4.1.1,Ch ip forward,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	4.1.2 Disable Send Packet Redirects 
######################################################
function packet_snd
{
/sbin/sysctl net.ipv4.conf.all.send_redirects > $HRDTMPA
/sbin/sysctl net.ipv4.conf.default.send_redirects > $HRDTMPB
if [ "`grep '0' $HRDTMPA`" == "" ]; then
	PASSI="Fail"
else
	PASSI="Pass"
fi
if [ "`grep '0' $HRDTMPB`" == "" ]; then
	PASSJ="Fail"
else
	PASSJ="Pass"
fi
echo -e "4.1.2,Send packets,=,$PASSI/$PASSJ" >> $REPFILE
}
#
######################################################
###	4.2 Modify Network Parameters 
######################################################
###	4.2.1 Disable Source Routed Packet Acceptance 
######################################################
function packet_src
{
/sbin/sysctl net.ipv4.conf.all.accept_source_route > $HRDTMPA
/sbin/sysctl net.ipv4.conf.default.accept_source_route > $HRDTMPB
if [ "`grep '0' $HRDTMPA`" == "" ]; then
	PASSK="Fail"
else
	PASSK="Pass"
fi
if [ "`grep '0' $HRDTMPB`" == "" ]; then
	PASSL="Fail"
else
	PASSL="Pass"
fi
echo -e "4.2.1,Src routed-ac,=,$PASSK/$PASSL" >> $REPFILE
}
#
######################################################
###	4.2.2 Disable ICMP Redirect Acceptance 
######################################################
function icmp_redir
{
/sbin/sysctl net.ipv4.conf.all.accept_redirects > $HRDTMPA
/sbin/sysctl net.ipv4.conf.default.accept_redirects > $HRDTMPB
if [ "`grep '0' $HRDTMPA`" == "" ]; then
	PASSM="Fail"
else
	PASSM="Pass"
fi
if [ "`grep '0' $HRDTMPB`" == "" ]; then
	PASSN="Fail"
else
	PASSN="Pass"
fi
echo -e "4.2.2,Icmp routed,=,$PASSM/$PASSN" >> $REPFILE
}
#
######################################################
###	4.2.3 Log Suspicious Packets 
######################################################
function susp_pkts
{
/sbin/sysctl net.ipv4.conf.all.log_martians > $HRDTMPA
/sbin/sysctl net.ipv4.conf.default.log_martians > $HRDTMPB
if [ "`grep '1' $HRDTMPA`" == "" ]; then
	PASSO="Fail"
else
	PASSO="Pass"
fi
if [ "`grep '1' $HRDTMPB`" == "" ]; then
	PASSP="Fail"
else
	PASSP="Pass"
fi
echo -e "4.2.3,Suspicious pkts,=,$PASSO/$PASSP" >> $REPFILE
}
#
######################################################
###	4.2.4 Enable Ignore Broadcast Requests
######################################################
function ignor_bcst
{
/sbin/sysctl net.ipv4.icmp_echo_ignore_broadcasts > $HRDTMPA
if [ "`grep '1' $HRDTMPA`" == "" ]; then
	echo -e "4.2.4,Ignore Brdcsts,=,Fail" >> $REPFILE
else
	echo -e "4.2.4,Ignore Brdcsts,=,Pass" >> $REPFILE
fi
} 
#
######################################################
###	4.2.5 Enable Bad Error Message Protection 
######################################################
function bad_error
{
/sbin/sysctl net.ipv4.icmp_ignore_bogus_error_responses > $HRDTMPA
if [ "`grep '1' $HRDTMPA`" == "" ]; then
	echo -e "4.2.5,Bad error msgs,=,Fail" >> $REPFILE
else
	echo -e "4.2.5,Bad error msgs,=,Pass" >> $REPFILE
fi
} 
#
######################################################
###	4.2.6 Enable TCP SYN Cookies 
######################################################
function tcp_svn
{
/sbin/sysctl net.ipv4.tcp_syncookies > $HRDTMPA
if [ "`grep '1' $HRDTMPA`" == "" ]; then
	echo -e "4.2.6,Check tcp syn,=,Fail" >> $REPFILE
else
	echo -e "4.2.6,Check tcp syn,=,Pass" >> $REPFILE
fi
} 
#
######################################################
###	4.3 Install TCP Wrappers
######################################################
###	4.3.1 Verify Permissions on /etc/hosts.allow 
######################################################
function host_allow
{
/bin/ls -l /etc/hosts.allow > $HRDTMPA
if [ "`grep 'root root' $HRDTMPA`" == "" ]; then
	echo -e "4.3.1,Chk host allow,=,Fail" >> $REPFILE
else
	echo -e "4.3.1,Chk host allow,=,Pass" >> $REPFILE
fi
} 
#
######################################################
###	4.3.2 Verify Permissions on /etc/hosts.deny 
######################################################
function host_deny
{
/bin/ls -l /etc/hosts.deny > $HRDTMPA
if [ "`grep 'root root' $HRDTMPA`" == "" ]; then
	echo -e "4.3.2,Chk hosts deny,=,Fail" >> $REPFILE
else
	echo -e "4.3.2,Chk hosts deny,=,Pass" >> $REPFILE
fi
} 
#
######################################################
###	4.4 Enable firewalld 
######################################################
function enable_fwd
{
systemctl is-enabled firewalld > $HRDTMPA
if [ "`grep 'enabled' $HRDTMPA`" == "" ]; then
	echo -e "4.4.0,Chk firewalld,=,Fail" >> $REPFILE
else
	echo -e "4.4.0,Chk firewalld,=,Pass" >> $REPFILE
fi
} 
#
################################################################################################
###	5.0 Logging and Auditing
################################################################################################
###	5.1 Configure rsyslog
######################################################
###	5.1.1 Install the rsyslog package 
######################################################
function check_syslog
{
rpm -q rsyslog > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
	echo -e "5.1.1,Syslog installed,=,Fail" >> $REPFILE
else
	echo -e "5.1.1,Syslog installed,=,Pass" >> $REPFILE
fi
} 
#
######################################################
###	5.1.2 Activate the rsyslog Service
######################################################
function syslog_act
{
systemctl is-enabled rsyslog > $HRDTMPA
if [ "`grep 'enabled' $HRDTMPA`" == "" ]; then
	echo -e "5.1.2,Syslog activated,=,Fail" >> $REPFILE
else
	echo -e "5.1.2,Syslog activated,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	5.1.3 Create and Set Permissions on rsyslog Log Files
######################################################
function logfile_perms
{
	SLOGFILES="/var/log/messages
/var/log/secure
/var/log/maillog
/var/log/cron
/var/log/spooler
/var/log/boot.log"
for i in `echo $SLOGFILES`
do
stat -L -c "%a" $i | grep ".00" > $HRDTMPA
stat -L -c "%u %g" $i | egrep "0 0" > $HRDTMPB
if [ "`cat $HRDTMPA`" == "" ]; then
	PASSQ="Fail"
else
	PASSQ="Pass"
fi
if [ "`cat $HRDTMPB`" == "" ]; then
	PASSR="Fail"
else
	PASSR="Pass"
fi
echo -e "5.1.3,Syslog Permissions,=,$PASSQ/$PASSR-$i" >> $REPFILE
done
}
#
######################################################
###	5.1.4 Configure rsyslog to Send Logs to a Remote Log Host
######################################################
function remote_loghost
{
grep "^*.*[^I][^I]*@" /etc/rsyslog.conf > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
	echo -e "5.1.4,Syslog Remote-host,=,Fail" >> $REPFILE
else
	echo -e "5.1.4,Syslog Remote-host,=,Pass" >> $REPFILE
fi
}
#
################################################################################################
###	6.0 System Access, Authentication and Authorization
################################################################################################
###	6.1 Configure cron and anacron
######################################################
###	6.1.1 Enable anacron Daemon
######################################################
function anacron_inst
{
rpm -q cronie-anacron > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "6.1.1,Anacron Installed,=,Fail" >> $REPFILE
else
        echo -e "6.1.1,Anacron Installed,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.1.2 Enable crond Daemon
######################################################
function cron_enabled
{
systemctl is-enabled crond > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "6.1.2,Cron enabled,=,Fail" >> $REPFILE
else
        echo -e "6.1.2,Cron enabled,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.1.3 Set User/Group Owner and Permission on /etc/anacrontab
######################################################
function anacron_perms
{
stat -L -c "%a %u %g" /etc/anacrontab | egrep ".00 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "6.1.3,Anaron Permissions,=,Fail" >> $REPFILE
else
        echo -e "6.1.3,Anacron Permissions,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.1.4 Set User/Group Owner and Permission on /etc/crontab
######################################################
function cron_perms
{
stat -L -c "%a %u %g" /etc/crontab | egrep ".00 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "6.1.4,Cron Permissions,=,Fail" >> $REPFILE
else
        echo -e "6.1.4,Cron Permissions,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.1.5 Set User/Group Owner and Permission on /etc/cron.hourly
######################################################
function cronhour_perms
{
stat -L -c "%a %u %g" /etc/cron.hourly | egrep ".00 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "6.1.5,CronHourly Permissions,=,Fail" >> $REPFILE
else
        echo -e "6.1.5,CronHourly Permissions,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.1.6 Set User/Group Owner and Permission on /etc/cron.daily
######################################################
function cronday_perms
{
stat -L -c "%a %u %g" /etc/cron.daily | egrep ".00 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "6.1.6,CronDay Permissions,=,Fail" >> $REPFILE
else
        echo -e "6.1.6,CronDay Permissions,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.1.7 Set User/Group Owner and Permission on /etc/cron.weekly
######################################################
function cronweek_perms
{
stat -L -c "%a %u %g" /etc/cron.weekly | egrep ".00 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "6.1.7,CronWeek Permissions,=,Fail" >> $REPFILE
else
        echo -e "6.1.7,CronWeek Permissions,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.1.8 Set User/Group Owner and Permission on /etc/cron.monthly
######################################################
function cronmonth_perms
{
stat -L -c "%a %u %g" /etc/cron.monthly | egrep ".00 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "6.1.8,CronMonth Permissions,=,Fail" >> $REPFILE
else
        echo -e "6.1.8,CronMonth Permissions,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.1.9 Set User/Group Owner and Permission on /etc/cron.d
######################################################
function croncrond_perms
{
stat -L -c "%a %u %g" /etc/cron.d | egrep ".00 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "6.1.9,Cron cron.d Permissions,=,Fail" >> $REPFILE
else
        echo -e "6.1.9,Cron cron.d Permissions,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.1.10 Restrict at Daemon
######################################################
function allow_at
{
if [ -a /etc/at.deny ]; then
	stat -L /etc/at.deny > $HRDTMPA
	if [ "`cat $HRDTMPA`" != "" ]; then
		PASSS="Fail"
	else
		PASSS="Pass"
	fi
else
	PASSS="Pass"
fi
if [ -a /etc/at.allow ]; then
	stat -L -c "%a %u %g" /etc/at.allow | egrep ".00 0 0" > $HRDTMPB
	if [ "`cat $HRDTMPB`" == "" ]; then
		PASST="Fail"
	else
		PASST="Pass"
	fi
else
	PASST="Fail"
fi
echo -e "6.1.10,Cron AtDaemon Permissions,=,$PASSS/$PASST" >> $REPFILE
}
#
######################################################
###	6.1.11 Restrict at/cron to Authorized Users 
######################################################
function allowdeny_exist
{
echo "" > $HRDTMPA
if [ -f /etc/cron.deny ]; then
	echo fail > $HRDTMPA
fi
if [ -f /etc/at.deny ]; then
        echo fail > $HRDTMPA
fi
if [ "`grep fail $HRDTMPA`" != "" ]; then
        PASSU="Fail"
else
        PASSU="Pass"
fi
if [ -f /etc/cron.allow ]; then
        PASSV="Pass"
else
	PASSV="Fail"	
fi
if [ -f /etc/at.allow ]; then
        PASSW="Pass"
else
	PASSW="Fail"
fi
echo -e "6.1.11,Cron Allow Deny exist,=,$PASSU/$PASSV/$PASSW" >> $REPFILE
}
#
######################################################
###	6.2 Configure SSH
######################################################
###	6.2.1 Set SSH Protocol to 2 
######################################################
function proto_ssh
{
if [ "`grep "^Protocol" /etc/ssh/sshd_config`" != "Protocol 2" ]; then
        echo -e "6.2.1,Ssh Protocol,=,Fail" >> $REPFILE
else
        echo -e "6.2.1,Ssh Protocol,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.2.2 Set LogLevel to INFO 
######################################################
function loglvl_ssh
{
grep "^LogLevel" /etc/ssh/sshd_config > $HRDTMPA
if [ "`grep INFO $HRDTMPA`" == "" ]; then
        echo -e "6.2.2,Ssh LogLevel,=,Fail" >> $REPFILE
else
        echo -e "6.2.2,Ssh LogLevel,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.2.3 Set Permissions on /etc/ssh/sshd_config
######################################################
function dirperm_ssh
{
stat -L -c "%a %u %g" /etc/ssh/sshd_config | egrep ".00 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "6.2.3,Sshd config permissions,=,Fail" >> $REPFILE
else
        echo -e "6.2.3,Sshd config permissions,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.2.4 Disable SSH X11 Forwarding
######################################################
function x11fwd_ssh
{
grep "^X11Forwarding" /etc/ssh/sshd_config > $HRDTMPA
if [ "`grep -i no $HRDTMPA`" == "" ]; then
        echo -e "6.2.4,Ssh X11-Forward,=,Fail" >> $REPFILE
else
        echo -e "6.2.4,Ssh X11-Forward,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.2.5 Set SSH MaxAuthTries to 6 or Less 
######################################################
function maxauth_ssh
{
grep "^MaxAuthTries" /etc/ssh/sshd_config > $HRDTMPA
if [ "`cat $HRDTMPA | awk '{print $2}'`" -ge "6" ]; then
        echo -e "6.2.5,Ssh MaxAuthTries,=,Pass" >> $REPFILE
else
        echo -e "6.2.5,Ssh MaxAuthTries,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	6.2.6 Set SSH IgnoreRhosts to Yes
######################################################
function ignorerhost_ssh
{
grep "^IgnoreRhosts" /etc/ssh/sshd_config > $HRDTMPA
if [ "`grep -i yes $HRDTMPA`" == "" ]; then
        echo -e "6.2.6,Ssh IgnoreRhosts,=,Fail" >> $REPFILE
else
        echo -e "6.2.6,Ssh IgnoreRhosts,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.2.7 Set SSH HostbasedAuthentication to No
######################################################
function hostauth_ssh
{
grep "^HostbasedAuthentication" /etc/ssh/sshd_config > $HRDTMPA
if [ "`grep -i no $HRDTMPA`" == "" ]; then
        echo -e "6.2.7,Ssh HostbasedAuth,=,Fail" >> $REPFILE
else
        echo -e "6.2.7,Ssh HostbasedAuth,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.2.8 Disable SSH Root Login
######################################################
function rootlogin_ssh
{
grep "^PermitRootLogin" /etc/ssh/sshd_config | awk '{print $2}' > $HRDTMPA
if [ "`cat $HRDTMPA`" == "yes" ]; then
	echo -e "6.2.8,Ssh RootLogin,=,Fail" >> $REPFILE
else
        echo -e "6.2.8,Ssh RootLogin,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.2.9 Set SSH PermitEmptyPasswords to No 
######################################################
function emptypass_ssh
{
grep "^PermitEmptyPasswords" /etc/ssh/sshd_config > $HRDTMPA
if [ "`grep -i no $HRDTMPA`" == "" ]; then
        echo -e "6.2.9,Ssh EmptyPasswd,=,Fail" >> $REPFILE
else
        echo -e "6.2.9,Ssh EmptyPasswd,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.2.10 Do Not Allow Users to Set Environment Options 
######################################################
function usersetenv_ssh
{
grep PermitUserEnvironment /etc/ssh/sshd_config > $HRDTMPA
if [ "`grep -i no $HRDTMPA`" == "" ]; then
        echo -e "6.2.10,Ssh UserSetEnv,=,Fail" >> $REPFILE
else
        echo -e "6.2.10,Ssh UserSetEnv,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.2.11 Use Only Approved Cipher in Counter Mode
######################################################
function ciphers_ssh
{
grep "Ciphers" /etc/ssh/sshd_config > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "6.2.11,Ssh Ciphers,=,Fail" >> $REPFILE
else
        echo -e "6.2.11,Ssh Ciphers,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.2.12 Set Idle Timeout Interval for User Login
######################################################
function alive_ssh
{
grep "^ClientAliveInterval" /etc/ssh/sshd_config > $HRDTMPA
grep "^ClientAliveCountMax" /etc/ssh/sshd_config > $HRDTMPB
if [ "`cat $HRDTMPA | awk '{print $2}'`" != "" ]; then
	if [ "`cat $HRDTMPA | awk '{print $2}'`" -ge "301" ]; then
		PASSX="Pass"
	else
		PASSX="Fail"
	fi
else
	PASSX="Fail- No Output"
fi
if [ "`cat $HRDTMPB | awk '{print $2}'`" != "" ]; then
	if [ "`cat $HRDTMPB | awk '{print $2}'`" == "0" ]; then
		PASSY="Pass"
	else
		PASSY="Fail"
	fi
else
	PASSY="Fail- No Output"
fi
echo -e "6.2.12,Ssh IdleTime,=,$PASSX/$PASSY" >> $REPFILE
}
#
######################################################
###	6.2.13 Limit Access via SSH
######################################################
function alldeny_ssh
{
grep "^AllowUsers" /etc/ssh/sshd_config > $HRDTMPA
grep "^AllowGroups" /etc/ssh/sshd_config > $HRDTMPB
if [ "`cat $HRDTMPA`" == "" ] && [ "`cat $HRDTMPB`" == "" ]; then
        PASSZ="Fail"
fi
if [ "`cat $HRDTMPA`" == "" ] && [ "`cat $HRDTMPB`" != "" ]; then
        PASSZ="Pass-G"
fi
if [ "`cat $HRDTMPA`" != "" ] && [ "`cat $HRDTMPB`" == "" ]; then
        PASSZ="Pass-U"
fi
grep "^DenyUsers" /etc/ssh/sshd_config > $HRDTMPC
grep "^DenyGroups" /etc/ssh/sshd_config > $HRDTMPD
if [ "`cat $HRDTMPC`" == "" ] && [ "`cat $HRDTMPD`" == "" ]; then
        PASSAA="Fail"
fi
if [ "`cat $HRDTMPC`" == "" ] && [ "`cat $HRDTMPD`" != "" ]; then
        PASSAA="Pass-G"
fi
if [ "`cat $HRDTMPC`" != "" ] && [ "`cat $HRDTMPD`" == "" ]; then
        PASSAA="Pass-U"
fi
echo -e "6.2.13,Ssh AllowDenyUserGroup,=,$PASSZ/$PASSAA" >> $REPFILE
}
#
######################################################
###	6.2.14 Set SSH Banner 
######################################################
function banner_ssh
{
grep "^Banner" /etc/ssh/sshd_config > $HRDTMPA
if [ "`cat $HRDTMPA | awk '{print $2}'`" == "" ]; then
        echo -e "6.2.14,Ssh Banner,=,Fail" >> $REPFILE
else
        echo -e "6.2.14,Ssh Banner,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.3 Configure PAM
######################################################
###	6.3.1 Upgrade Password Hashing Algorithm to SHA-512
######################################################
function hashalgo_pam
{
authconfig --test | grep hashing | grep sha512 > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "6.3.1,Pam HashAlgorithm,=,Fail" >> $REPFILE
else
        echo -e "6.3.1,Pam HashAlgorithm,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	6.3.2 Set Password Creation Requirement Parameters Using pam_pwquality
######################################################
function passwdreq_pam
{
grep minlen /etc/security/pwquality.conf | sed -e 's/[^0-9]//g' > $HRDTMPA
if [ "`cat $HRDTMPA`" -ge "14" ]; then
	PASSBB="Pass-minlen"
else
	PASSBB="Fail-minlen"
fi
echo -e "6.3.2,Pam PasswdReqs,=,$PASSBB" >> $REPFILE
	PAMSEC="dcredit
ucredit
ocredit
lcredit"
for i in `echo $PAMSEC`
do
grep $i /etc/security/pwquality.conf | sed -e 's/[^0-9]//g' > $HRDTMPB
if [ "`cat $HRDTMPB`" -ge "2" ]; then
	PASSCC="Fail"
else
	PASSCC="Pass"
fi
echo -e "6.3.2,Pam PasswdReqs,=,$PASSCC-$i" >> $REPFILE
done
}
#
######################################################
###	6.3.3 Limit Password Reuse
######################################################
function maxreuse_pam
{
grep "remember" /etc/pam.d/system-auth | sed -e 's/[^0-9]//g' > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "6.3.3,Pam Max Reuse,=,Fail" >> $REPFILE
else
	if [ "`cat $HRDTMPA`" -ge "10" ]; then
		echo -e "6.3.3,Pam Max Reuse,=,Pass" >> $REPFILE
	else
		echo -e "6.3.3,Pam Max Reuse,=,Fail" >> $REPFILE
	fi
fi
}
#
######################################################
###	6.3.4 Restrict Access to the su Command
######################################################
function accessu_pam
{
grep pam_wheel.so /etc/pam.d/su | grep required > $HRDTMPA
if [ "`cat $HRDTMPA`" != "auth required pam_wheel.so use_uid" ]; then
        echo -e "6.3.4,Pam Access su,=,Fail" >> $REPFILE
fi
grep wheel /etc/group | awk -F: '{print $4}' > $HRDTMPB
if [ "`cat $HRDTMPB`" == "" ]; then
	echo -e "6.3.4,Pam Access su,=,Pass" >> $REPFILE
else
	echo -e "6.3.4,Pam Access su,=,Fail" >> $REPFILE
fi
}
#
################################################################################################
###	7.0 User Accounts and Environment
################################################################################################
###	7.1 Set Shadow Password Suite Parameters
######################################################
###	7.1.1 Set Password Expiration Days 
######################################################
function maxpassday_usr
{
grep PASS_MAX_DAYS /etc/login.defs | grep -v "#" | sed -e 's/[^0-9]//g' > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "7.1.1,Max Days Passwd,=,Fail-NOT Relevant using LDAP" >> $REPFILE
else
        if [ "`cat $HRDTMPA`" -ge "91" ]; then
                echo -e "7.1.1,Max Days Passwd,=,Fail-NOT Relevant using LDAP" >> $REPFILE
        else
                echo -e "7.1.1,Max Days Passwd,=,Pass-NOT Relevant using LDAP" >> $REPFILE
        fi
fi
}
#
######################################################
###	7.1.2 Set Password Change Minimum Number of Days
######################################################
function minpassday_usr
{
grep PASS_MIN_DAYS /etc/login.defs | grep -v "#" | sed -e 's/[^0-9]//g' > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "7.1.2,Min Days Passwd,=,Fail-NOT Relevant using LDAP" >> $REPFILE
else
        if [ "`cat $HRDTMPA`" -le "6" ]; then
                echo -e "7.1.2,Min Days Passwd,=,Fail-NOT Relevant using LDAP" >> $REPFILE
        else
                echo -e "7.1.2,Min Days Passwd,=,Pass-NOT Relevant using LDAP" >> $REPFILE
        fi
fi
}
#
######################################################
###	7.1.3 Set Password Expiring Warning Days
######################################################
function minpasswarn_usr
{
grep PASS_WARN_AGE /etc/login.defs | grep -v "#" | sed -e 's/[^0-9]//g' > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "7.1.3,Min Days Warn,=,Fail-NOT Relevant using LDAP" >> $REPFILE
else
        if [ "`cat $HRDTMPA`" -ge "2" ]; then
                echo -e "7.1.3,Min Days Warn,=,Pass-NOT Relevant using LDAP" >> $REPFILE
        else
                echo -e "7.1.3,Min Days Warn,=,Fail-NOT Relevant using LDAP" >> $REPFILE
        fi
fi
}
#
######################################################
###	7.1.4 Disable System Accounts
######################################################
function system_accts
{
egrep -v "^\+" /etc/passwd | awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<1000 && $7!="/sbin/nologin") {print}' > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
	echo -e "7.1.4,System accounts,=,Pass-NOT Relevant using LDAP" >> $REPFILE
else
	echo -e "7.1.4,System accounts,=,Fail-NOT Relevant using LDAP" >> $REPFILE
fi
}
#
######################################################
###	7.1.5 Set Default Group for root Account
######################################################
function root_grp
{
grep "^root:" /etc/passwd | cut -f4 -d: > $HRDTMPA
if [ "`cat $HRDTMPA`" == "0" ]; then
        echo -e "7.1.5,Root Group Account,=,Pass" >> $REPFILE
else
        echo -e "7.1.5,Root Group Account,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	7.1.6 Set Default umask for Users
######################################################
function defumask_set
{
grep "^umask 077" /etc/bashrc > $HRDTMPA
grep "^umask 077" /etc/profile.d/* > $HRDTMPB
if [ "`cat $HRDTMPA`" == "" ]; then
	if [ "`cat $HRDTMPB`" == "" ]; then
		echo -e "7.1.6,Default Umask,=,Fail" >> $REPFILE
	else
		echo -e "7.1.6,Default Umask,=,Pass" >> $REPFILE
	fi
else
echo -e "7.1.6,Default Umask,=,Pass" >> $REPFILE
fi
}
#
################################################################################################
###	8.0 Warning Banners
################################################################################################
###	8.1.1 Set Warning Banner for Standard Login Services
######################################################
function banner_perms
{
BANNERS="/etc/motd
/etc/issue
/etc/issue.net"
for i in `echo $BANNERS`
do
stat -L -c "%a %u %g" $i | egrep "644 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
	PASSDD="Fail"
else
	PASSDD="Pass"
fi
echo -e "8.1.1,Banner Permissions,=,$PASSDD-$i" >> $REPFILE
done
}
#
######################################################
###	8.1.2 Remove OS Information from Login Warning Banners
######################################################
function banner_kernel
{
BANNERS="/etc/motd
/etc/issue
/etc/issue.net"
for i in `echo $BANNERS`
do
egrep '(\\v|\\r|\\m|\\s)' $i > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        PASSEE="Pass"
else
        PASSEE="Fail"
fi
echo -e "8.1.2,Banner OS Content,=,$PASSEE-$i" >> $REPFILE
done
}
#
################################################################################################
###	9.0 System Maintenance
################################################################################################
###	9.1 Verify System File Permissions
######################################################
###	9.1.1 Verify Permissions on /etc/passwd
######################################################
function passwd_perm
{
stat -L -c "%a %u %g" /etc/passwd | egrep "644 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
	echo -e "9.1.1,Passwd Permissions,=,Fail" >> $REPFILE
else
	echo -e "9.1.1,Passwd Permissions,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	9.1.2 Verify Permissions on /etc/shadow
######################################################
function shadow_perm
{
stat -L -c "%a %u %g" /etc/shadow | egrep "0 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.1.2,Shadow Permissions,=,Fail" >> $REPFILE
else
        echo -e "9.1.2,Shadow Permissions,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	9.1.3 Verify Permissions on /etc/gshadow
######################################################
function gshadow_perm
{
stat -L -c "%a %u %g" /etc/gshadow | egrep "0 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.1.3,GShadow Permissions,=,Fail" >> $REPFILE
else
        echo -e "9.1.3,GShadow Permissions,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	9.1.4 Verify Permissions on /etc/group
######################################################
function group_perm
{
stat -L -c "%a %u %g" /etc/group | egrep "644 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.1.4,Group Permissions,=,Fail" >> $REPFILE
else
        echo -e "9.1.4,Group Permissions,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	9.1.5 Verify User/Group Ownership on /etc/passwd
######################################################
function passwdroot_perm
{
stat -L -c "%a %u %g" /etc/passwd | egrep "644 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.1.5,Passwd Ownership,=,Fail" >> $REPFILE
else
        echo -e "9.1.5,Passwd Ownership,=,Pass" >> $REPFILE
fi
}
#
######################################################
###     9.1.6 Verify User/Group Ownership on /etc/shadow 
######################################################
function shadowroot_perm
{
stat -L -c "%a %u %g" /etc/shadow | egrep "0 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.1.6,Shadow Ownership,=,Fail" >> $REPFILE
else
        echo -e "9.1.6,Shadow Ownership,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	9.1.7 Verify User/Group Ownership on /etc/gshadow 
######################################################
function gshadowroot_perm
{
stat -L -c "%a %u %g" /etc/gshadow | egrep "0 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.1.7,GShadow Ownership,=,Fail" >> $REPFILE
else
        echo -e "9.1.7,GShadow Ownership,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	9.1.8 Verify User/Group Ownership on /etc/group
######################################################
function grouproot_perm
{
stat -L -c "%a %u %g" /etc/group | egrep "644 0 0" > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.1.8,Group Ownership,=,Fail" >> $REPFILE
else
        echo -e "9.1.8,Group Ownership,=,Pass" >> $REPFILE
fi
}
#
######################################################
###	9.1.9 Find Un-owned Files and Directories
######################################################
function unowned_files
{
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.1.9,Un-Owned Files,=,Pass" >> $REPFILE
else
        echo -e "9.1.9,Un-Owned Files,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.1.10 Find Un-grouped Files and Directories
######################################################
function ungrouped_files
{
df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nogroup > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.1.10,Un-Grouped Files,=,Pass" >> $REPFILE
else
        echo -e "9.1.10,Un-Grouped Files,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2 Review User and Group Settings
######################################################
###	9.2.1 Ensure Password Fields are Not Empty
######################################################
function empty_passwd
{
/bin/cat /etc/shadow | /bin/awk -F: '($2 == "" ) { print $1 " does not have a password "}' > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.1,Un-Owned Files,=,Pass" >> $REPFILE
else
        echo -e "9.2.1,Empty Password,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.2 Verify No Legacy "+" Entries Exist in /etc/passwd File
######################################################
function legacy_passwd
{
/bin/grep '^+:' /etc/passwd > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.2,No Legacy Passwd,=,Pass" >> $REPFILE
else
        echo -e "9.2.2,No Legacy Passwd,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.3 Verify No Legacy "+" Entries Exist in /etc/shadow File
######################################################
function legacy_shadow
{
/bin/grep '^+:' /etc/shadow > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.3,No Legacy Shadow,=,Pass" >> $REPFILE
else
        echo -e "9.2.3,No Legacy Shadow,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.4 Verify No Legacy "+" Entries Exist in /etc/group File
######################################################
function legacy_group
{
/bin/grep '^+:' /etc/group > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.4,No Legacy Group,=,Pass" >> $REPFILE
else
        echo -e "9.2.4,No Legacy Group,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.5 Verify No UID 0 Accounts Exist Other Than root
######################################################
function root_zero
{
/bin/cat /etc/passwd | /bin/awk -F: '($3 == 0) { print $1 }' | grep -v root > $HRDTMPA
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.5,Only Root Zero,=,Pass" >> $REPFILE
else
        echo -e "9.2.5,Only Root Zero,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.6 Ensure root PATH Integrity
######################################################
function root_path
{
echo "" > $HRDTMPA
if [ "`echo $PATH | grep :: `" != "" ]; then
  echo "Empty Directory in PATH (::)" >> $HRDTMPA
fi

if [ "`echo $PATH | grep :$`" != "" ]; then
  echo "Trailing : in PATH" >> $HRDTMPA
fi

p=`echo $PATH | /bin/sed -e 's/::/:/' -e 's/:$//' -e 's/:/ /g'`
set -- $p
while [ "$1" != "" ]; do
  if [ "$1" = "." ]; then
    echo "PATH contains ." >> $HRDTMPA
    shift
    continue
  fi
  if [ -d $1 ]; then
    dirperm=`/bin/ls -ldH $1 | /bin/cut -f1 -d" "`
    if [ `echo $dirperm | /bin/cut -c6 ` != "-" ]; then
      echo "Group Write permission set on directory $1" >> $HRDTMPA
    fi
    if [ `echo $dirperm | /bin/cut -c9 ` != "-" ]; then
      echo "Other Write permission set on directory $1" >> $HRDTMPA
    fi
      dirown=`ls -ldH $1 | awk '{print $3}'`
      if [ "$dirown" != "root" ] ; then
        echo $1 is not owned by root >> $HRDTMPA
      fi
  else
    echo $1 is not a directory >> $HRDTMPA
  fi
  shift
done
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.6,Root Path,=,Pass" >> $REPFILE
else
        echo -e "9.2.6,Root Path,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.7 Check Permissions on User Home Directories
######################################################
function home_dirs
{
echo "" > $HRDTMPA
for dir in `/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' |\
  /bin/awk -F: '($8 == "PS" && $7 != "/sbin/nologin") { print $6 }'`; do
    dirperm=`/bin/ls -ld $dir | /bin/cut -f1 -d" "`
    if [ `echo $dirperm | /bin/cut -c6 ` != "-" ]; then
      echo "Group Write permission set on directory $dir" >> $HRDTMPA
    fi
    if [ `echo $dirperm | /bin/cut -c8 ` != "-" ]; then
      echo "Other Read permission set on directory $dir" >> $HRDTMPA
    fi
    if [ `echo $dirperm | /bin/cut -c9 ` != "-" ]; then
      echo "Other Write permission set on directory $dir" >> $HRDTMPA
    fi
    if [ `echo $dirperm | /bin/cut -c10 ` != "-" ]; then
      echo "Other Execute permission set on directory $dir" >> $HRDTMPA
    fi
done
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.7,Home Directories,=,Pass" >> $REPFILE
else
        echo -e "9.2.7,Home Directories,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.8 Check User Dot File Permissions
######################################################
function userdot_files
{
echo "" > $HRDTMPA
for dir in `/bin/cat /etc/passwd | /bin/egrep -v '(root|sync|halt|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin") { print $6 }'`; do
	for file in $dir/.[A-Za-z0-9]*; do
		if [ ! -h "$file" -a -f "$file" ]; then
			fileperm=`/bin/ls -ld $file | /bin/cut -f1 -d" "`
			if [ `echo $fileperm | /bin/cut -c6 ` != "-" ]; then
				echo "Group Write permission set on file $file" > $HRDTMPA
			fi
			if [ `echo $fileperm | /bin/cut -c9 ` != "-" ]; then
				echo "Other Write permission set on file $file" >> $HRDTMPA
			fi
		fi
	done
done
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.8,User Dot File Perms,=,Pass" >> $REPFILE
else
        echo -e "9.2.8,User Dot File Perms,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.9 Check Permissions on User .netrc Files
######################################################
function usernetrc_files
{
> $HRDTMPA
for dir in `/bin/cat /etc/passwd | /bin/egrep -v '(root|sync|halt|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin") { print $6 }'`; do
  for file in $dir/.netrc; do
    if [ ! -h "$file" -a -f "$file" ]; then
      fileperm=`/bin/ls -ld $file | /bin/cut -f1 -d" "`
      if [ `echo $fileperm | /bin/cut -c5 ` != "-" ]; then
        echo "Group Read set on $file" >> $HRDTMPA
      fi
      if [ `echo $fileperm | /bin/cut -c6 ` != "-" ]; then
        echo "Group Write set on $file" >> $HRDTMPA
      fi
      if [ `echo $fileperm | /bin/cut -c7 ` != "-" ]; then
        echo "Group Execute set on $file" >> $HRDTMPA
      fi
      if [ `echo $fileperm | /bin/cut -c8 ` != "-" ]; then
        echo "Other Read  set on $file" >> $HRDTMPA
      fi
      if [ `echo $fileperm | /bin/cut -c9 ` != "-" ]; then
        echo "Other Write set on $file" >> $HRDTMPA
      fi
      if [ `echo $fileperm | /bin/cut -c10 ` != "-" ]; then
        echo "Other Execute set on $file" >> $HRDTMPA
      fi
    fi
  done
done
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.9,User Netrc File Perms,=,Pass" >> $REPFILE
else
        echo -e "9.2.9,User Netrc File Perms,=,Fail" >> $REPFILE
fi
#echo -e "9.2.9,User Netrc File Perms,=,Fail-Provided Script does NOT funtion" >> $REPFILE
}
#
######################################################
###	9.2.10 Check for Presence of User .rhosts Files
######################################################
function userrhost_files
{
echo "" > $HRDTMPA
for dir in `/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' |\
  /bin/awk -F: '($7 != "/sbin/nologin") { print $6 }'`; do
  for file in $dir/.rhosts; do
    if [ ! -h "$file" -a -f "$file" ]; then
      echo ".rhosts file in $dir" >> $HRDTMPA
    fi
  done
done
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.10,User Rhosts File Perms,=,Pass" >> $REPFILE
else
        echo -e "9.2.10,User Rhosts File Perms,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.11 Check Groups in /etc/passwd
######################################################
function groups_passwd
{
echo "" > $HRDTMPA
for i in $(cut -s -d: -f4 /etc/passwd | sort -u ); do
  grep -q -P "^.*?:x:$i:" /etc/group
  if [ $? -ne 0 ]; then
    echo "Group $i is referenced by /etc/passwd but does not exist in /etc/group" >> $HRDTMPA
  fi
done
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.11,Chk Groups in Passwd,=,Pass" >> $REPFILE
else
        echo -e "9.2.11,Chk Groups in Passwd,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.12 Check That Users Are Assigned Valid Home Directories 
######################################################
function validuser_home
{
echo "" > $HRDTMPA
cat /etc/passwd | awk -F: '{ print $1 " " $3 " " $6 }' | while read user uid dir; do
  if [ $uid -ge 1000 -a ! -d "$dir" -a $user != "nfsnobody" ];
  then
    echo "The home directory ($dir) of user $user does not exist." >> $HRDTMPA
  fi
done
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.12,Valid User Home Dir,=,Pass" >> $REPFILE
else
        echo -e "9.2.12,Valid User Home Dir,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.13 Check User Home Directory Ownership
######################################################
function userowner_home
{
echo "" > $HRDTMPA
cat /etc/passwd | awk -F: '{ print $1 " " $3 " " $6 }' | while read user uid dir; do
if [ $uid -ge 1000 -a -d "$dir" -a $user != "nfsnobody" ]; then
  owner=$(stat -L -c "%U" "$dir")
  if [ "$owner" != "$user" ]; then
    echo "The home directory ($dir) of user $user is owned by $owner." >> $HRDTMPA
  fi
fi
done
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.13,User Home Dir Owner,=,Pass" >> $REPFILE
else
        echo -e "9.2.13,User Home Dir Owner,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.14 Check for Duplicate UIDs
######################################################
function duplicate_uids
{
echo "" > $HRDTMPA
echo "The Output for the Audit of Control 9.2.15 - Check for Duplicate UIDs is" /bin/cat /etc/passwd | /bin/cut -f3 -d":" | /bin/sort -n | /usr/bin/uniq -c |\
  while read x ; do
  [ -z "${x}" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    users=`/bin/gawk -F: '($3 == n) { print $1 }' n=$2 \
      /etc/passwd | /usr/bin/xargs`
    echo "Duplicate UID ($2): ${users}" >> $HRDTMPA
  fi
done
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.14,Chk Duplicate UIDs,=,Pass" >> $REPFILE
else
        echo -e "9.2.14,Chk Duplicate UIDs,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.15 Check for Duplicate GIDs
######################################################
function duplicate_gids
{
echo "" > $HRDTMPA
echo "# The Output for the Audit of Control 9.2.16 - Check for Duplicate GIDs is" > $HRDTMPA
/bin/cat /etc/group | /bin/cut -f3 -d":" | /bin/sort -n | /usr/bin/uniq -c |\
  while read x ; do
  [ -z "${x}" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    grps=`/bin/gawk -F: '($3 == n) { print $1 }' n=$2 \
      /etc/group | xargs`
    echo "Duplicate GID ($2): ${grps}" >> $HRDTMPA
  fi
done
if [ "`cat $HRDTMPA | grep -v '#'`" == "" ]; then
        echo -e "9.2.15,Chk Duplicate GIDs,=,Pass" >> $REPFILE
else
        echo -e "9.2.15,Chk Duplicate GIDs,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.16 Check That Reserved UIDs Are Assigned to System Accounts
######################################################
function reserved_uids
{
> $HRDTMPA
> $HRDTMPB
defUsers="root bin daemon adm lp sync shutdown halt mail news uucp operator games gopher ftp nobody nscd vcsa rpc mailnull smmsp pcap ntp dbus avahi sshd rpcuser nfsnobody haldaemon avahi-autoipd distcache apache oprofile webalizer dovecot squid named xfs gdm sabayon usbmuxd rtkit abrt saslauth pulse postfix tcpdump"
/bin/cat /etc/passwd |\
  /bin/awk -F: '($3 < 1000) { print $1" "$3 }' |\
  while read user uid; do
    found=0
    for tUser in ${defUsers}; do
      if [ ${user} = ${tUser} ]; then
        found=1
      fi
    done
    if [ $found -eq 0 ]; then
      echo "User $user has a reserved UID ($uid)." > $HRDTMPA
      if [ "`cat $HRDTMPA | sed -e 's/[(,),.]//g' | awk '{print $7}'`" -ge "500" ]; then
        > $HRDTMPA
      else
        echo "User $user has a reserved UID ($uid)." >> $HRDTMPB
        > $HRDTMPA
      fi
    fi
  done
if [ "`cat $HRDTMPB`" == "" ]; then
        echo -e "9.2.16,Chk Reserved UIDs,=,Pass" >> $REPFILE
else
        echo -e "9.2.16,Chk Reserved UIDs,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.17 Check for Duplicate User Names
######################################################
function duplicate_name
{
> $HRDTMPA
echo "The Output for the Audit of Control 9.2.18 - Check for Duplicate User Names is" cat /etc/passwd | cut -f1 -d":" | /bin/sort -n | /usr/bin/uniq -c |\
  while read x ; do
  [ -z "${x}" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    uids=`/bin/gawk -F: '($1 == n) { print $3 }' n=$2 \
      /etc/passwd | xargs`
    echo "Duplicate User Name ($2): ${uids}" > $HRDTMPA
  fi
done
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.17,Chk Duplicate User Names,=,Pass" >> $REPFILE
else
        echo -e "9.2.17,Chk Duplicate User Names,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.18 Check for Duplicate Group Names
######################################################
function duplicate_group
{
> $HRDTMPA
echo "The Output for the Audit of Control 9.2.19 - Check for Duplicate Group Names is" cat /etc/group | cut -f1 -d":" | /bin/sort -n | /usr/bin/uniq -c |\
  while read x ; do
  [ -z "${x}" ] && break
  set - $x
  if [ $1 -gt 1 ]; then
    gids=`/bin/gawk -F: '($1 == n) { print $3 }' n=$2 \
    /etc/group | xargs`
    echo "Duplicate Group Name ($2): ${gids}" > $HRDTMPA
  fi
done
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.18,Chk Duplicate Group Names,=,Pass" >> $REPFILE
else
        echo -e "9.2.18,Chk Duplicate Group Names,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.19 Check for Presence of User .netrc Files
######################################################
function netrcfiles_user
{
> $HRDTMPA
for dir in `/bin/cat /etc/passwd |\
  /bin/awk -F: '{ print $6 }'`; do
  if [ ! -h "$dir/.netrc" -a -f "$dir/.netrc" ]; then
    echo ".netrc file $dir/.netrc exists" > $HRDTMPA
  fi
done
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.19,Chk User .netrc Files,=,Pass" >> $REPFILE
else
        echo -e "9.2.19,Chk User .netrc Files,=,Fail" >> $REPFILE
fi
}
#
######################################################
###	9.2.20 Check for Presence of User .forward Files
######################################################
function userforward_files
{
> $HRDTMPA
for dir in `/bin/cat /etc/passwd |\
/bin/awk -F: '{ print $6 }'`; do
  if [ ! -h "$dir/.forward" -a -f "$dir/.forward" ]; then
    echo ".forward file $dir/.forward exists" > $HRDTMPA
  fi
done
if [ "`cat $HRDTMPA`" == "" ]; then
        echo -e "9.2.20,Chk User .forward Files,=,Pass" >> $REPFILE
else
        echo -e "9.2.20,Chk User .forward Files,=,Fail" >> $REPFILE
fi
}
#
###
################################################################################################
###	END OF FUNCTIONS
################################################################################################
###
#
echo "" > $REPFILE
echo -e "\n,Hardness Scan Report for $HOSTA on $RDATE\n" >> $REPFILE
echo -e "Section,Topic,=,State - [P|F]\n-----------,-------------------------,-------,---------------------" >> $REPFILE
if $SINGLE; then
	$1
	echo -e "\n\n########  END OF AUDIT  ############################\n" >> $REPFILE
	exit 0
fi
### RQH Calling FUNCTIONS
patch_list
part_tmp
nodev_tmp
nosuid_tmp
noexec_tmp
part_var
nobind_vartmp
part_varlog
part_varlogaud
part_home
nodev_home
nodev_devshm
nosuid_devshm
noexec_devshm
sticky_set
redhat_gpg
redhat_activegpg
grub_owner
grub_perms
boot_pass
core_dumps
rand_virtmem
check_telnet
check_tnetcli
check_rsh
check_rshpkg
check_niscli
check_nissrv
check_tftp
check_tftpsrv
check_talk
check_talksrv
check_xintd
chrgn_dgram
chrgn_stream
daytim_dgram
daytim_stream
echo_dgram
echo_stream
tcpmux_server
daem_umask
check_xwin
check_avahi
check_dhcp
check_ntp
local_mail
forward_ip
packet_snd
packet_src
icmp_redir
susp_pkts
ignor_bcst
bad_error
tcp_svn
host_allow
host_deny
enable_fwd
check_syslog
syslog_act
logfile_perms
remote_loghost
anacron_inst
cron_enabled
anacron_perms
cron_perms
cronhour_perms
cronday_perms
cronweek_perms
cronmonth_perms
croncrond_perms
allow_at
allowdeny_exist
proto_ssh
loglvl_ssh
dirperm_ssh
x11fwd_ssh
maxauth_ssh
ignorerhost_ssh
hostauth_ssh
rootlogin_ssh
emptypass_ssh
usersetenv_ssh
ciphers_ssh
alive_ssh
alldeny_ssh
banner_ssh
hashalgo_pam
passwdreq_pam
maxreuse_pam
accessu_pam
maxpassday_usr
minpassday_usr
minpasswarn_usr
system_accts
root_grp
defumask_set
banner_perms
banner_kernel
passwd_perm
shadow_perm
gshadow_perm
group_perm
passwdroot_perm
shadowroot_perm
gshadowroot_perm
grouproot_perm
unowned_files
ungrouped_files
empty_passwd
legacy_passwd
legacy_shadow
legacy_group
root_zero
root_path
home_dirs
userdot_files
usernetrc_files
userrhost_files
groups_passwd
validuser_home
userowner_home
duplicate_uids
duplicate_gids
reserved_uids
duplicate_name
duplicate_group
netrcfiles_user
userforward_files
#
rm /tmp/hrdtmp*.txt
echo -e "\n\n########  END OF AUDIT  ############################\n" >> $REPFILE
if $SNDMAIL; then
	snd_mail
fi
exit 0

###	for Objective 3
#grep echo $PROGNAME | grep REPFILE | grep -v 'print' | awk -F\" '{print $2}' | awk -F, '{print $1}' | sed -e 's/[^0-9,.]//g' | uniq
#	for i in `grep echo hardeningRHcsv.sh | grep REPFILE | grep -v grep | awk -F\" '{print $2}' | awk -F, '{print $1}' | sed -e 's/[^0-9,.]//g' | uniq`; do echo "#function $i" >> hardeningRHcsv.sh; done
#
#	grep function hardeningRHcsv.sh | grep -v "[!0-9]"
#
#function 1.1.0
#function 1.1.1
#function 1.1.2
#function 1.1.3
#function 1.1.4
#function 1.1.5
#function 1.1.6
#function 1.1.7
#function 1.1.8
#function 1.1.9
#function 1.1.10
#function 1.1.11
#function 1.1.12
#function 1.1.13
#function 1.1.14
#function 1.2.1
#function 1.2.2
#function 1.3.1
#function 1.3.2
#function 1.3.3
#function 1.4.1
#function 1.4.2
#function 2.1.1
#function 2.1.2
#function 2.1.3
#function 2.1.4
#function 2.1.5
#function 2.1.6
#function 2.1.7
#function 2.1.8
#function 2.1.9
#function 2.1.10
#function 2.1.11
#function 2.1.12
#function 2.1.13
#function 2.1.14
#function 2.1.15
#function 2.1.16
#function 2.1.17
#function 2.1.18
#function 3.1.1
#function 3.1.2
#function 3.1.3
#function 3.1.4
#function 3.1.5
#function 3.1.6
#function 4.1.1
#function 4.1.2
#function 4.2.1
#function 4.2.2
#function 4.2.3
#function 4.2.4
#function 4.2.5
#function 4.2.6
#function 4.3.1
#function 4.3.2
#function 4.4.0
#function 5.1.1
#function 5.1.2
#function 5.1.3
#function 5.1.4
#function 6.1.1
#function 6.1.2
#function 6.1.3
#function 6.1.4
#function 6.1.5
#function 6.1.6
#function 6.1.7
#function 6.1.8
#function 6.1.9
#function 6.1.10
#function 6.1.11
#function 6.2.1
#function 6.2.2
#function 6.2.3
#function 6.2.4
#function 6.2.5
#function 6.2.6
#function 6.2.7
#function 6.2.8
#function 6.2.9
#function 6.2.10
#function 6.2.11
#function 6.2.12
#function 6.2.13
#function 6.2.14
#function 6.3.1
#function 6.3.2
#function 6.3.3
#function 6.3.4
#function 7.1.1
#function 7.1.2
#function 7.1.3
#function 7.1.4
#function 7.1.5
#function 7.1.6
#function 8.1.1
#function 8.1.2
#function 9.1.1
#function 9.1.2
#function 9.1.3
#function 9.1.4
#function 9.1.5
#function 9.1.6
#function 9.1.7
#function 9.1.8
#function 9.1.9
#function 9.1.10
#function 9.2.1
#function 9.2.2
#function 9.2.3
#function 9.2.4
#function 9.2.5
#function 9.2.6
#function 9.2.7
#function 9.2.8
#function 9.2.9
#function 9.2.10
#function 9.2.11
#function 9.2.12
#function 9.2.13
#function 9.2.14
#function 9.2.15
#function 9.2.16
#function 9.2.17
#function 9.2.18
#function 9.2.19
#function 9.2.20
#
###
###CGLG		Change Log
###CGLG	08-Feb-2016	Beginning of Changelog- All is 'working' on RHEL- 
###CGLG			still debugging some minor issues- if script or command 
###CGLG			error the reuslt should be 'FAIL' to have manual investigation initiated
###CGLG			
###CGLG 08-Feb-2016	6.2.12- Added logic to check output before execution
###CGLG 08-Feb-2016      6.2.10- Added logic to check if files exist before execution
###CGLG	08-Feb-2016	------- Added 'mail' option to mail and attach the report, and added to Options
###CGLG	08-Feb-2016      ------- 1.0.1-02 - Added Revision Number to Options
###CGLG	03-Mar-2016	------- 1.0.1-03 - Fixed the 3.6.1 Local mail check part 1
###CGLG 09-Mar-2016	------- 1.0.1-03 - Fixed the 1.1.9 Check for seperate home partition
###CGLG 29-Jun-2016	Revision-1.0.1-04- General Clean Up, removing commented excess, etc.
###CGLG 14-Oct-2017     Revision-1.0.1-05- General Clean Up for github, replaced tmp*.txt with /tmp/<variable>
###CGLG 
###CGLG 
