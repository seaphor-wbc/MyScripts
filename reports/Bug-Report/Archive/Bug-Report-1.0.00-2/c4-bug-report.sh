#!/bin/bash

###################################################################################
#####			GNU/GPL Info						###
###################################################################################
function gpl_info
{
echo -e "\n
####c4#############################################################################
###										###
##			GNU/GPL Info 						###
##		Begins as C4-Bug-Report ver. 0.0.01  A-1			###
##		See the release notes at the bottom for current progress	###
##	Released under GPL v2.0, See www.gnu.org for full license info		###
##	Copyright (C) 2014  Shawn Miller					###
##	Copyright (C) 2014  The Wood-Bee Company				###
##		EMAIL- shawn@woodbeeco.com					###
##  This program is free software; you can redistribute it and/or modify	###
##    it under the terms of the GNU General Public License as published by	###
##    the Free Software Foundation; either version 2 of the License, or		###
##    (at your option) any later version.					###
##										###
##    This program is distributed in the hope that it will be useful,		###
##    but WITHOUT ANY WARRANTY; without even the implied warranty of		###
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the		###
##    GNU General Public License for more details.				###
##										###
##	Script Originally GPL licensed as version 0.0-1, February, 2013		###
##		Script Forked and GPL licensed as version 1.0.00-1,		###
##		October 24, 2015- For Silverhelm Studios			###
##										###
####w#################################b######################################c#####
\n"
}
#
###################################################
###	Define Standard Variables	###
###################################################
#
        JVER="Bug-Report-1.0.00-2"
        PCHLVL="1.0.00-2"
        PCHDAT="19 June, 2016"
	PROGNAME=$(basename $0)
	CUSTOM=false
	USAGE="\n\n$PROGNAME -[OPTION] <filename>.csv \n"
#	USAGE="\n\nc4-bug-report.sh -[OPTION] <filename> \n"
	TDATE=`date +%a\ %b\ %d\ %Y`
	JDATE=`date +%y%m%d-%H.%M.%S`
	WDATE="`date +%U\ %Y`"
#
###################################################
###	Define Help and Options		###
###################################################
#
	HELP=false
	OPTIONS="\nOptions-Usage:
	\n\n c4-bug-report.sh -[OPTION] <Filename>.csv
	\n-Examples:	\n\t\t c4-bug-report.sh -a testreport.csv
	\n\n-Options:
	\n[-h]  Help		\t\tShows this list
	\n[-a]  Add Entry	\t\tAdd a Bug report 
	\n[-m]  Mail Report	\tAdd a Bug report and Email it
	\n[-o]  Just Mail	\t\tJust Email The Bug report
	\n[-r]  Read Report	\tTo View the Report in less
	\n[-e]  Edit Report	\tEdit the Report with vi
	\n[-v]  Script Version	\tBug-Report Script Version and Release Date
	\n[-d]  Description	\tBug-Report Script Description
	\n[-z]  Show ChangeLog	\tBug-Report Script Change Log
    \n[-l]  Show C4 Logo    \tDisplays the C4 Logo with Version
	\n[-g]  GPL Info	\t\tGNU/GPL License Information \n"
#
###################################################
###     Check for correct command structure
###	Set Script Variables
###################################################
#
if [ ! -a ~/bin/c4-bug-report.sh ]; then
	cp $PROGNAME ~/bin/c4-bug-report.sh
	JSLOC=~/bin/c4-bug-report.sh
fi
#	Variables
	JSLOC=~/bin/c4-bug-report.sh
	MOBUGZ=false
	RPDEF=false
	RPCUST=false
	RMAIL=false
	JMAIL=false
	CHA="Release Vs."
	CHB="Priority"
	CHC="Category/Type"
	CHD="Short Description"
	CHE="Details- Long Description"
	CHF="STR & Additional Notes"
	CHG="Identified By"
	CHH="Date"
	CHI="Status"
#
###################################################
###	PATH Directory
###################################################
#
if [ ! -d ~/.Per ]; then
	mkdir ~/.Per 2> /dev/null
	REPDIR=~/.Per
else
	REPDIR=~/.Per
fi
#
if [ -a $REPDIR/$2 ]; then
	BREPRT=$REPDIR/$2
else
	touch $REPDIR/$2
	BREPRT=$REPDIR/$2
	echo -e "\n $CHA#$CHB#$CHC#$CHD#$CHE#$CHF#$CHG#$CHH#$CHI" > $BREPRT 
fi
#
###################################################
###	Functions
###################################################
#
function bug_more
{
	echo -e "\n\t Do you want to enter bug report? ....\n [y/n]"
	read MRBUGZ
	if [ "`echo $MRBUGZ`" == "y" ]; then
		MOBUGZ=true
		bug_line
	else
		MOBUGZ=false
	fi
}
#
function bug_line
{
        echo -e "\n\n\t Do *NOT* use a '#' symobol in any of the input... it is the CSV Deliminator"
        sleep 4
	echo -e "\n\tType the Release Version..."
	read CAA
	echo -e "\n\tType the Priority...\n[1-5]"
	read CAB
	echo -e "\n\tType the Category Type...\n[c]\tCharacter Creator\n[e]\tEnhancement Request\n[g]\tGame Play, Movement, Missions\n[m]\tMap\n[p]\tPowers & Powersets\n[u]\tUI & Menus\n"
	read CAC
	case "$CAC" in
	"c")
		CAC="Character Creator"
		;;
	"e")
		CAC="Enhancement Request"
		;;
	"g")
		CAC="Game Play Movement Missions"
		;;
	"m")
		CAC="Map"
		;;
	"p")
		CAC="Powers Powersets"
		;;
	"u")
		CAC="UI & Menus"
		;;
	*)
		CAC="FAILED Input!"
		;;
	esac
#
	echo -e "\n\tType the Short Description..."
	read CAD
	echo -e "\n\tType the Details- Long Description..."
	read CAE
	echo -e "\n\tType the STR & Additional Notes..."
	read CAF
	echo -e "\n\tType the Identified By...\n[Leave Blank for $CAG]\n"
	read CAG
	if [ "`echo $CAG`" == "" ]; then
		CAG=C4
	else
		echo -e "\n\tDo you want to set $CAG as the default ID?...\n[y/n]\n"
		read DEFID
		if [ "$DEFID" == "y" ]; then
			sed -i s/CAG=C4/CAG=$CAG/g $PROGNAME
		fi
	fi
	echo -e "\n\tType the Date, or leave empty for auto...\n[$JDATE]\n"
	read CAH
	if [ "`echo $CAH`" == "" ]; then
		CAH="$JDATE"
	fi
	echo -e "\n\tType the Status...\n[o]\tOpem (Default)\n[c]\tClosed\n[f]\tFixed\n[r]\tRetest\n[Open]\n"
	read CAI
	case $CAI in
	"o")
		CAI="Open"
		;;
	"c")
		CAI="Closed"
		;;
	"f")
		CAI="Fixed"
		;;
	"r")
		CAI="Retest"
		;;
	*)
		CAI="Open"
		;;
	esac
#
	echo -e "$CAA#$CAB#$CAC#$CAD#$CAE#$CAF#$CAG#$CAH#$CAI" >> $BREPRT 
	unset {$CAA,$CAB,$CAC,$CAD,$CAE,$CAF,$CAH,$CAI} 2>&1 > /dev/null
	bug_more
}
function display_logo
{
echo "" 
echo "############################################################" #RQH-01
echo "#.C4.##################################################.C4.#" #RQH-02
echo "##########******************************####################" #RQH-03
echo "########*                                *##################" #RQH-04
echo "######*       @######################|   *##################" #RQH-05
echo "#####*     @#########################|    *#################" #RQH-06
echo "####*     @##########################|_____    *############" #RQH-07
echo "###*     @#####|                     |#####|    *###########" #RQH-08
echo "###*     @#####|                     |#####|    *###########" #RQH-09
echo "###*     @#####|      OFFICIAL       |#####|    *###########" #RQH-10
echo "###*     @#####| $JVER |#####|    *###########" #RQH-11
echo "###*     @#####|      RELEASE        |#####|    *###########" #RQH-12
echo "###*     @#####|                     |#####|    *###########" #RQH-13
echo "###*     @#####|_____________________|#####|_______    *####" #RQH-14
echo "###*      @########################################|   *####" #RQH-15
echo "####*      @#######################################|   *####" #RQH-16
echo "#####*       @#####################################|   *####" #RQH-17
echo "######*                              |#####|           *####" #RQH-18
echo "################################*    |#####|    *###########" #RQH-19
echo "################################*    |#####|    *###########" #RQH-20
echo "#############     ####  ###  ###*    |#####|    *###########" #RQH-21
echo "############  #########  #  ####*    |#####|    *###########" #RQH-22
echo "############  ##########   #####*    |#####|    *###########" #RQH-23
echo "############  #########  #  ####*    |#####|    *###########" #RQH-24
echo "#############     ####  ###  ###*---------------*###########" #RQH-25
echo "#.C4.##################################################.C4.#" #RQH-26
echo "" 
}
#
###################################################
###	Main Logic				###
###################################################
#
case "$1" in
"-h")
        HELP=true
        if $HELP; then
                echo -e $OPTIONS
                exit $?
        fi
        ;;
"-r")
	cat $BREPRT | sed 's/#/\t/g' | less
	exit $?
	;;
"-z")
	grep '##@' $JSLOC | grep -v JSLOC
	exit $?
	;;
"-v")
	JREL=true
	if $JREL; then
		echo $JVER
		echo $PCHDAT
		exit $?
	fi
	;;
"-e")
	vi $BREPRT
	exit $?
	;;
"-g")
	JGPL=true
	if $JGPL; then
		gpl_info
		exit $?
	fi
	;;
"-a")
	bug_line
	;;
"-m")
	RMAIL=true
	bug_line
	;;
"-o")
	RMAIL=true
	;;
"-l")
    display_logo
    exit $?
    ;;
*)
	echo -e $OPTIONS
	echo $PROGNAME
	exit $?
	;;
esac
##
###
###################################################
###	Email Options- Starting Mail		###
###################################################
#
	DOEDITA=false
if $RMAIL; then
	echo -e "\n\t Do you want Default to/from or Custom? \n [d/c]"
	read TOFROM
	if [ "$TOFROM" == "c" ]; then
		echo -e "\n\tType the FROM email address..."
		read FROMA
		echo -e "\n\tType the TO email address..."
                read EMAIL
	fi
	if [ "$TOFROM" == "d" ]; then
		FROMA=woodbeeco@msn.com
		EMAIL=woodbeeco@msn.com
		if [ "`echo $FROMA`" == "false" ]; then
			echo -e "\n\tYour 'Default' emails have not been set, \n\tafter this instance has exited either manually edit the script Mail settings\n\tor edit the following command with your info (remove all '<>' and edit its contents)-\n\nexport FROMA=<yourdefault_FROM_emsiladdress>\nexport EMAIL=<yourdefault_TO_emsiladdress>\nsed -i s/FROMA=<false>/FROMA=$FROMA/g $PROGNAME\nsed -i s/EMAIL=<false>/EMAIL=$EMAIL/g $PROGNAME \n"
			sleep 5
			echo -e "\n\n\t Do you want this script to add the entries for you when its finished?\n [y/n]"
			read DOEDIT
			if [ "$DOEDIT" == "y" ]; then
				DOEDITA=true
			fi
			sleep 3
			echo -e "\n\tType the FROM email address..."
			read FROMA
			echo -e "\n\tType the TO email address..."
                	read EMAIL
		fi
	fi
	echo -e "\n\tType the SUBJECT For the email..."
	read SUBJECT
	echo -e "\n\tDo you want to type the body of the email? [a]\n\tOr, Do you already have a file that you want to cat for the body of the email? [b]\n\nEnter your choice [a/b]... "
	read BDYCHSE
	if [ "$BDYCHSE" == "b" ]; then
		echo -e "\n\tType the exact absolute path to the file to be used for the body of the email..."
		read CATFILE
		EMAILMESSAGEZ=$REPDIR/mailmsg
		cat $CATFILE > $EMAILMESSAGEZ
	fi
	if [ "$BDYCHSE" == "a" ]; then
		echo -e "\n\tBegin Typing the body now, a RETURN will end the input of the text-body..."
		read CATFILE
		EMAILMESSAGEZ=$REPDIR/mailmsg
		echo "$CATFILE" > $EMAILMESSAGEZ
	fi
#
##################################################################################
#####   Establish Mail and Execute
##################################################################################
#
	echo -e "\n\tAttaching the Report as a separate attachment... "
	ATTCHD=$BREPRT
	sudo /usr/bin/mailx -a $ATTCHD -s "$SUBJECT" "$EMAIL"  -f $FROMA < $EMAILMESSAGEZ 2>&1 > $REPDIR/mailtest.log
fi
#
##################################################################################
##      Ending All
##################################################################################
###
#
if $DOEDITA; then
	sed -i s/FROMA=woodbeeco@msn.com/FROMA=$FROMA/g $PROGNAME ; sed -i s/EMAIL=woodbeeco@msn.com/EMAIL=$EMAIL/g $PROGNAME
fi
#
echo -e "\n\n\n\tWhen you open the $2 with your spreadsheet application\n\tuse only the Pound (#) as the deliminator, and as long as you didnt use the Pound symbol in any of your inputs it will be fomatted correctly for the official Bug-Report.\n\n\tI hope you find this script useful, and if you have any feedback,
 issues, or requests, please send them to my email in the GPL ($PROGNAME -g)...\n\nThanks,\n\tC4\n"
#
echo -e "\n"
sleep 4
display_logo
echo -e "\n"
#
exit $?
#
##@
##@################################################
##@	END OF JOURNAL SCRIPT			###
##@################################################
##@
##@	Change-Logs
##@
##@	Patch-Level-0.0.01-1 (first Official Release)
##@		Have fully functional script as long as the propper Options are used.
##@
##@	Patch-Level-0.0.01-2
##@		Finalized, clean and working as original outline
##@
##@	Patch-Level-0.0.01-3 => 0.1.01-1
##@		All is working to satisfaction for basic report
##@		I am making this Beta-1
##@		For next patch I want an email option
##@		For next patch I want a custom directory option
##@
##@	Patch-Level-0.1.01-2
##@		Fixed Main Logic
##@		Fixed Options
##@		Cleaned up code
##@		Created Mail Options - NEEDS Testing!
##@		
##@	Patch-Level-0.1.02-1	PCHDAT="11 March, 2015"
##@		All Mail options tested and working
##@		Repeating options all fixed
##@		Few more tests, and I'll release for publit testing
##@		Once passes the Public, will rev to 1.0.00-1
##@		
##@	Patch-Level-0.1.02-2	PCHDAT="24 October, 2015"
##@		Adding entry for setting up the default emails
##@		Fixed the 'OPTIONS' output
##@		Added options to the bug info input for:
##@			Priority, ID-by, Status, and date
##@			and set some defaults
##@		Changed the csv deliminator from ',' to '#'
##@
##@	Patch-Level-1.0.00-1
##@            Script Forked and GPL licensed as version 1.0.00-1,
##@            October 24, 2015- For Silverhelm Studio
##@		
##@	Patch-Level-1.0.00-2  PCHDAT="19 June, 2016"
##@	  	Added '-l' Option to Show Logo and exit
##@		
##@		
##@		
##@		
