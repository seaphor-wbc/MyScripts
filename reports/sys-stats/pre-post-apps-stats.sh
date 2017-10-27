#!/bin/bash
##	Usage <scriptname> <listname> <Option [pre|post|apps] >
#
#######################################
##	Global Variables
#######################################
#
#	set -x
	PWD=`pwd`
	PDATE=`date +%Y-%b`
	CDATE=`date +%Y-%b-%d`
	TDATE=`date +%Y-%b-%d-%H:%M`
	PROGNAME=$(basename $0)
	FILE=`cat $1`
	OWNER=$USER
	APPA="UnDefinedApp"
	APPB="UnDefinedApp"
	APPC="UnDefinedApp"
	APPD="UnDefinedApp"
	APPE="UnDefinedApp"
case $2 in
"pre")
	APPCHK=false
	PRECHK=true
	PSTCHK=false
	THISCHK="Before"
	WRKDIR="$PWD/$PDATE-patching"
	WRKFIL="$WRKDIR/IT-$i-stats.txt"
	;;
"post")
	APPCHK=false
	PRECHK=false
	PSTCHK=true
	THISCHK="After"
	WRKDIR="$PWD/$PDATE-patching"
	WRKFIL="$WRKDIR/IT-$i-stats.txt"
	;;
*)
	APPCHK=false
	PRECHK=false
	PSTCHK=false
	echo -e "\n\n\tUsage -- $PROGNAME <listname> <Option [pre|post] >\n\n"
	exit $?
        ;;
esac
#
#######################################
##	Set Owner & Working Directory
#######################################
#
if $PRECHK; then
	if [[ ! -d $WRKDIR ]]; then
		mkdir $WRKDIR
	else
		rm -rf $WRKDIR/*
	fi
fi
#
if $PSTCHK; then
	if [[ ! -d $WRKDIR ]]; then
		echo -e "\n\n\tUsage $PROGNAME <listname> <Option [pre|post] >\nRun the pre first\n"
		exit $?
	fi
fi
	TSAR="$WRKDIR/tmpsar.txt"
chown -R $OWNER: $WRKDIR
#
#######################################
##	Functions
#######################################
#
function chk_stats_pre
{
	touch $WRKDIR/$i-prefile.sh
	if [[ "`ssh $i rpm -qa | grep sysstat`" == "" ]]; then
		ssh $i cat /etc/*release > tmp.txt
		if [[ "`cat tmp.txt | grep -i suse`" != "" ]]; then
			if [[ "`echo $UID`" == 0 ]]; then
				INSTAL="zypper in -y sysstat"
			else
				INSTAL="sudo zypper in -y sysstat"
			fi
			rm tmp.txt
		else
			if [[ "`cat tmp.txt | grep -i redhat`" != "" ]]; then
				if [[ "`echo $UID`" == 0 ]]; then
					INSTAL="yum install -y sysstat"
				else
					INSTAL="sudo yum install -y sysstat"
				fi
				rm tmp.txt
			fi
		fi
		ssh $i $INSTAL
	fi
	echo -e "\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n$i-$THISCHK-stats-$TDATE\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=" >> $WRKDIR/IT-$i-stats.txt
	echo -e "Server\tBefore/After\tCPU-Usage\t\t\tCPU Load\tMem-System\tSwap\t\t\tDisk/Partition Usage\t\tApplications Status" >> $WRKDIR/IT-$i-stats.txt
	echo -e "Hostname\tBefore/After\t%system\t%iowait\t%idle\tldavg-15\t%memused\tTotal\tUsed\tFree\tUse%\tMounted On\tApp\tStatus" >> $WRKDIR/IT-$i-stats.txt
# prevara is column-A hostname
	prevara=$i
	echo "prevara=$prevara" >> $WRKDIR/$i-prefile.sh
# prevarb is column-B CPU Usage- %system
	prevarb="`ssh $i sar -u 1 1 | sed -e '/^$/d' | tail -n1 | awk '{print $5}'`"
	echo "prevarb=$prevarb" >> $WRKDIR/$i-prefile.sh
# prevarc is column-C CPU Usage- %iowait value
	prevarc="`ssh $i sar -u 1 1 | sed -e '/^$/d' | tail -n1 | awk '{print $6}'`"
	echo "prevarc=$prevarc" >> $WRKDIR/$i-prefile.sh
# prevard is column-D CPU Usage- %idle value
	prevard="`ssh $i sar -u 1 1 | sed -e '/^$/d' | tail -n1 | awk '{print $8}'`"
	echo "prevard=$prevard" >> $WRKDIR/$i-prefile.sh
# prevare is column-E Load Avg Last 15 Min
	prevare="`ssh $i sar -q 1 1 | tail -n 2 | head -n 1 | sed 's/\ /\n/g' | sed '/^$/d' | tail -n1`"
	echo "prevare=$prevare" >> $WRKDIR/$i-prefile.sh
# prevarf is column-F Memory Usage System
	prevarf="`ssh $i sar -r 1 1 | sed -e '/^$/d' | tail -n 1 | awk '{print $4}'`"
	echo "prevarf=$prevarf" >> $WRKDIR/$i-prefile.sh
# prevarg is column-G Swap- Total size
	prevarg="`ssh $i free -m | tail -n 1 | awk '{print $2}'`"
	echo "prevarg=$prevarg" >> $WRKDIR/$i-prefile.sh
# prevarh is column-H Swap- In-Use
	prevarh="`ssh $i free -m | tail -n 1 | awk '{print $3}'`"
	echo "prevarh=$prevarh" >> $WRKDIR/$i-prefile.sh
# prevari is column-I Swap- Free
	prevari="`ssh $i free -m | tail -n 1 | awk '{print $4}'`"
	echo "prevari=$prevari" >> $WRKDIR/$i-prefile.sh
#
###	Disk Partitions
#
	prevarj="`ssh $i df -hl | grep -v tmpfs | grep -v udev | awk '{print $5}' | grep -Eo '[0-9]{1,9}' | tr '\n' ' '`"
	echo "prevarj='$prevarj'" >> $WRKDIR/$i-prefile.sh
# prevark is column-K Disk/Partition Mounted On
	prevark="`ssh $i df -hl | grep -v tmpfs | awk '{print $6}' | grep -v ^/dev$ | grep -v Mounted | tr '\n' ' '`"
	echo "prevark='$prevark'" >> $WRKDIR/$i-prefile.sh
#
###	Applications and Status
#
# prevarl is column-L Application A Status- 
	prevarl="$APPA"
	echo "prevarl=$prevarl" >> $WRKDIR/$i-prefile.sh
# prevarm is column-M Application A Status- 
	if [[ "`ssh $i pgrep $APPA`" != "" ]]; then
		prevarm="Running"
	else
		prevarm="'NOT Running'"
	fi
	echo "prevarm=$prevarm" >> $WRKDIR/$i-prefile.sh
#
# prevarn is column-N Application B Status
	prevarn="$APPB"
	echo "prevarn=$prevarn" >> $WRKDIR/$i-prefile.sh
# prevaro is column-O Application B Status-
	if [[ "`ssh $i pgrep $APPB`" != "" ]]; then
		prevaro="Running"
	else
		prevaro="'NOT Running'"
	fi
	echo "prevaro=$prevaro" >> $WRKDIR/$i-prefile.sh
#
# prevarp is column-P Application C Status-
	prevarp=""
	echo "prevarp=$prevarp" >> $WRKDIR/$i-prefile.sh
# prevarq is column-Q Application Status- ILMT Application Status
	if [[ "`ssh $i pgrep $APPC`" != "" ]]; then
		prevarq="Running"
	else
		prevarq="'NOT Running'"
	fi
	echo "prevarq=$prevarq" >> $WRKDIR/$i-prefile.sh
#
# prevarr is column-R Application D Status-
	prevarr="$APPD"
	echo "prevarr=$prevarr" >> $WRKDIR/$i-prefile.sh
# prevars is column-S Application Status- SNMP Application Status
	if [[ "`ssh $i pgrep $APPD`" != "" ]]; then
		prevars="Running"
	else
		prevars="'NOT Running'"
	fi
	echo "prevars=$prevars" >> $WRKDIR/$i-prefile.sh
#
# prevart is column-T Application E Status-
	prevart="$APPE"
	echo "prevart=$prevart" >> $WRKDIR/$i-prefile.sh
# prevaru is column-U Application E Status-
	if [[ "`ssh $i pgrep $APPE`" != "" ]]; then
		prevaru="Running"
	else
		prevaru="'NOT Running'"
	fi
	echo "prevaru=$prevaru" >> $WRKDIR/$i-prefile.sh
#
	chmod -x $WRKDIR/$i-prefile.sh
	cp -r $WRKDIR /tmp/.
}
#
function chk_stats_post
{
	touch $WRKDIR/$i-postfile.sh
	echo -e "$i $THISCHK Stats $TDATE" >> $WRKDIR/$i-postfile.sh
# postvara is column-A hostname
	postvara=$i
	echo "postvara=$postvara" >> $WRKDIR/$i-postfile.sh
# postvarb is column-B CPU Usage- %system
	postvarb="`ssh $i sar -u 1 1 | sed -e '/^$/d' | tail -n1 | awk '{print $5}'`"
	echo "postvarb=$postvarb" >> $WRKDIR/$i-postfile.sh
# postvarc is column-C CPU Usage- %iowait value
	postvarc="`ssh $i sar -u 1 1 | sed -e '/^$/d' | tail -n1 | awk '{print $6}'`"
	echo "postvarc=$postvarc" >> $WRKDIR/$i-postfile.sh
# postvard is column-D CPU Usage- %idle value
	postvard="`ssh $i sar -u 1 1 | sed -e '/^$/d' | tail -n1 | awk '{print $8}'`"
	echo "postvard=$postvard" >> $WRKDIR/$i-postfile.sh
# postvare is column-E Load Avg Last 15 Min
	postvare="`ssh $i sar -q 1 1 | tail -n 2 | head -n 1 | sed 's/\ /\n/g' | sed '/^$/d' | tail -n1`"
	echo "postvare=$postvare" >> $WRKDIR/$i-postfile.sh
# postvarf is column-F Memory Usage System
	postvarf="`ssh $i sar -r 1 1 | sed -e '/^$/d' | tail -n 1 | awk '{print $4}'`"
	echo "postvarf=$postvarf" >> $WRKDIR/$i-postfile.sh
# postvarg is column-G Swap- Total size
	postvarg="`ssh $i free -m | tail -n 1 | awk '{print $2}'`"
	echo "postvarg=$postvarg" >> $WRKDIR/$i-postfile.sh
# postvarh is column-H Swap- In-Use
	postvarh="`ssh $i free -m | tail -n 1 | awk '{print $3}'`"
	echo "postvarh=$postvarh" >> $WRKDIR/$i-postfile.sh
# postvari is column-I Swap- Free
	postvari="`ssh $i free -m | tail -n 1 | awk '{print $4}'`"
	echo "postvari=$postvari" >> $WRKDIR/$i-postfile.sh
#
###	Disk Partitions
#
	postvarj="`ssh $i df -hl | grep -v tmpfs | grep -v udev | awk '{print $5}' | grep -Eo '[0-9]{1,9}' | tr '\n' ' '`"
	echo "postvarj='$postvarj'" >> $WRKDIR/$i-postfile.sh
# postvark is column-K Disk/Partition Mounted On
	postvark="`ssh $i df -hl | grep -v tmpfs | awk '{print $6}' | grep -v ^/dev$ | grep -v Mounted | tr '\n' ' '`"
	echo "postvark='$postvark'" >> $WRKDIR/$i-postfile.sh
#
###	Applications and Status
#
# postvarl is column-L Application A Status-
	postvarl="$APPA"
	echo "postvarl=$postvarl" >> $WRKDIR/$i-postfile.sh
# postvarm is column-M Application A Status-
	if [[ "`ssh $i pgrep $APPA`" != "" ]]; then
		postvarm="Running"
	else
		postvarm="NOT Running"
	fi
	echo "postvarm=$postvarm" >> $WRKDIR/$i-postfile.sh
#
# postvarn is column-N Application B Sataus-
	postvarn="$APPB"
	echo "postvarn=$postvarn" >> $WRKDIR/$i-postfile.sh
# postvaro is column-O Application B Status-
	if [[ "`ssh $i pgrep $APPB`" != "" ]]; then
		postvaro="Running"
	else
		postvaro="NOT Running"
	fi
	echo "postvaro=$postvaro" >> $WRKDIR/$i-postfile.sh
#
# postvarp is column-P Application C Status- 
	postvarp="$APPC"
	echo "postvarp=$postvarp" >> $WRKDIR/$i-postfile.sh
# postvarq is column-Q Application C Status-
	if [[ "`ssh $i pgrep $APPC`" != "" ]]; then
		postvarq="Running"
	else
		postvarq="NOT Running"
	fi
	echo "postvarq=$postvarq" >> $WRKDIR/$i-postfile.sh
#
# postvarr is column-R Application D Status-
	postvarr="$APPD"
	echo "postvarr=$postvarr" >> $WRKDIR/$i-postfile.sh
# postvars is column-S Application D Status-
	if [[ "`ssh $i pgrep $APPD`" != "" ]]; then
		postvars="Running"
	else
		postvars="NOT Running"
	fi
	echo "postvars=$postvars" >> $WRKDIR/$i-postfile.sh
#
# postvart is column-T Application E Status-
	postvart="$APPE"
	echo "postvart=$postvart" >> $WRKDIR/$i-postfile.sh
# postvaru is column-U Application E Status- 
	if [[ "`ssh $i pgrep $APPE`" != "" ]]; then
		postvaru="Running"
	else
		postvaru="NOT Running"
	fi
	echo "postvaru=$postvaru" >> $WRKDIR/$i-postfile.sh
#
	chmod -x $WRKDIR/$i-postfile.sh
}
#
#################
#
if $PRECHK; then
	for i in $FILE
	do
	chk_stats_pre
	done
fi
#################
##	POST
#################
if $PSTCHK; then
	for i in $FILE
	do
		chk_stats_post
	done
#
	echo -e "\tStatistics Comparison Before and After Patching on $TDATE\n" > $WRKDIR/$CDATE-patching-Comp.txt
	echo -e "Server\t\tCPU-Usage\t\t\tCPU Load\tMem-System\tSwap\t\t\tDisk/Partition Usage\t\tApplications Status" >> $WRKDIR/$CDATE-patching-Comp.txt
	echo -e "Hostname\tBefore/After\t%system\t%iowait\t%idle\tldavg-15\t%memused\tTotal\tUsed\tFree\tUse%\tMounted On\tApp\tStatus\tApp\tStatus\tApp\tStatus\tApp\tStatus\tApp\tStatus\tApp\tStatus" >> $WRKDIR/$CDATE-patching-Comp.txt
#
	for i in $FILE
        do
		source $WRKDIR/$i-prefile.sh
		source $WRKDIR/$i-postfile.sh
		echo -e "$prevara\tBefore\t$prevarb\t$prevarc\t$prevard\t$prevare\t$prevarf\t$prevarg\t$prevarh\t$prevari\t$prevarj\t$prevark\t$prevarl\t$prevarm\t$prevarn\t$prevaro\t$prevarp\t$prevarq\t$prevarr\t$prevars\t$prevart\t$prevaru\t$prevarv\t$prevarw\t$prevarx\t$prevary\t$prevarz\n$postvara\tAfter\t$postvarb\t$postvarc\t$postvard\t$postvare\t$postvarf\t$postvarg\t$postvarh\t$postvari\t$postvarj\t$postvark\t$postvarl\t$postvarm\t$postvarn\t$postvaro\t$postvarp\t$postvarq\t$postvarr\t$postvars\t$postvart\t$postvaru\t$postvarv\t$postvarw\t$postvarx\t$postvary\t$postvarz" >> $WRKDIR/$CDATE-patching-Comp.txt
		echo -e "###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###\t###" >> $WRKDIR/$CDATE-patching-Comp.txt
	done
#
	cp $WRKDIR/$CDATE-patching-Comp.txt $WRKDIR/$CDATE-patching-Comp.csv
	chown -R $OWNER: $WRKDIR/*
	if [[ -f $WRKDIR/tmp.txt ]]; then
		rm $WRKDIR/tmp.txt
	fi
	mv $WRKDIR $PWD/$CDATE-patching
	chown -R $OWNER: *
	tar -czvf $PWD/$CDATE-patching.tar.gz $PWD/$CDATE-patching
	chown $OWNER: *
function snd_mail
{
	SUBJECT="testing $CDATE"
	FROMA=myemail@mydomain.com
        EMAILMSGZ=$PWD/tmp.txt
	EMAILG=myemail@mydomain.com
	ATTACHA="$PWD/$CDATE-patching/$CDATE-patching-Comp.csv"
touch $EMAILMSGZ
echo $CDATE > $EMAILMSGZ
	/usr/bin/mailx -a $ATTACHA -s "$SUBJECT" "$EMAILG" -f $FROMA < $EMAILMSGZ
	rm $EMAILMSGZ
}
	snd_mail
	exit $?
fi
#
##############
exit $?
##############
###
#
