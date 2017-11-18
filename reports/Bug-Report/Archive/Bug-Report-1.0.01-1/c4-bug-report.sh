#!/bin/bash

###################################################################################
#####			GNU/GPL Info						###
###################################################################################
function gpl_info
{
  echo -e "\n$(tput setaf 14)
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
$(tput sgr 0)\n"
}
#
###################################################
###	Define Standard Variables	###
###################################################
#
        JVER="Bug-Report-1.0.01-1"
        PCHLVL="1.0.01-1"
        PCHDAT="18 November, 2017"
	PROGNAME=$(basename $0)
	CUSTOM=false
    USAGE="\n\n$(tput setaf 3) $PROGNAME -[OPTION] <filename>.csv$(tput sgr 0) \n"
	TDATE=`date +%a\ %b\ %d\ %Y`
	JDATE=`date +%y%m%d-%H.%M.%S`
	WDATE="`date +%U\ %Y`"
case $3 in
	"-V")
		NOSLEEP=true
	;;
	*)
		NOSLEEP=false
	;;
esac
#
###################################################
###	Define Help and Options		###
###################################################
#
	HELP=false
    OPTIONS="\n$(tput setaf 3)Options-Usage:$(tput sgr 0)
    \n\n$(tput setaf 6) $PROGNAME -[OPTION] <Filename>.csv$(tput sgr 0)
    \n\n\t$(tput setaf 6) Or$(tput sgr 0)
    \n\n$(tput setaf 6) $PROGNAME -[OPTION] <Filename>.csv -V$(tput sgr 0)
    \n$(tput setaf 3)-Examples:	\n\t $PROGNAME -a testreport.csv$(tput sgr 0)
    \n\n$(tput setaf 14)-Options:
	\n[-h]\tHelp\t\tShows this list
	\n[-a]\tAdd Entry\tAdd a Bug report 
	\n[-m]\tMail Report\tAdd a Bug report and Email it
	\n[-o]\tJust Mail\tJust Email The Bug report
	\n[-r]\tRead Report\tTo View the Report in less
	\n[-e]\tEdit Report\tEdit the Report with vi
	\n[-v]\tScript Version\tBug-Report Script Version and Release Date
	\n[-d]\tDescription\tBug-Report Script Description
	\n[-z]\tShow ChangeLog\tBug-Report Script Change Log
	\n[-l]\tShow C4 Logo\tDisplays the C4 Logo with Version
	\n[-g]\tGPL Info\tGNU/GPL License Information
	\n[-V]\tNo Pauses\tStop all pauses, faster inputs$(tput sgr 0) \n"
	DESCRIPT="\n\t$(tput setaf 14)This srript was originally desined for my work as advocate with Codeweavers Crossover Linux, and then for use of my team as QA Director for Valiance Online with SilverHelm Studios.\nIt could easily be modified for use with any QA-type bug reporting by adjusting the Variable Values and Options Menu.\nThe out put is kept in a hidden directory in the user's Home directory because some projects are more confidential- [~/.Per/]\nThe output was also specifically designed in a format that could be simply imported to the running Master Bug Report SpreadSheet and all fields and columns would line up and match.\n\tPlease feel free to send me questions, suggestions, or any issues with the script at...$(tput sgr 0)\n\t$(tput setaf 5)seaphor@woodbeeco.com$(tput sgr 0)"
#
###################################################
###     Check for correct command structure
###	Set Script Variables
###################################################
#
if [[ "`ls ~/bin/ | grep $PROGNAME`" == "" ]]; then
	if [[ -a $PWD/$PROGNAME ]]; then
		cp $PROGNAME ~/bin/$PROGNAME
	else
      echo -e "\n\t$(tput setaf 3)Run this script from the directory it's in the first time\n\tDoing so will copy it to your ~/bin/ directory\n\tand then you can run it from anywhere... exiting...$(tput sgr 0)\n"
		exit $?
	fi
fi
#	Variables
	JSLOC=~/bin/$PROGNAME
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
  echo -e "\n\t$(tput setaf 3) Do you want to enter bug report? ....\n [y/n]$(tput sgr 0)"
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
  echo -e "\n\n\t$(tput setaf 3) Do *NOT* use a '#' symobol in any of the input... it is the CSV Deliminator$(tput sgr 0)"
        sleep 2
        echo -e "\n\t$(tput setaf 14)Type the Release Version...$(tput sgr 0)"
	read CAA
    echo -e "\n\t$(tput setaf 14)Type the Priority...\n[1-5]$(tput sgr 0)"
	read CAB
    echo -e "\n\t$(tput setaf 14)Category Type...$(tput sgr 0)\n$(tput setaf 4)[c]\tCharacter Creator$(tput sgr 0)\n$(tput setaf 5)[e]\tEnhancement Request$(tput sgr 0)\n$(tput setaf 6)[g]\tGame Play, Movement, Missions$(tput sgr 0)\n[m]\t$(tput setaf 10)Map$(tput sgr 0)\n$(tput setaf 11)[p]\tPowers & Powersets$(tput sgr 0)\n$(tput setaf 12)[u]\tUI & Menus$(tput sgr 0)\n$(tput setaf 1)[s]\tBug, issue, or enhancement request with this script$(tput sgr 0)\n"
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
	"s")
		CAC="Script Request Bug or Issue"
		;;
	*)
		CAC="FAILED Input!"
		;;
	esac
#
echo -e "\n\t$(tput setaf 14)Type the Short Description...$(tput sgr 0)"
	read CAD
    echo -e "\n\t$(tput setaf 14)Type the Details- Long Description...$(tput sgr 0)"
	read CAE
    echo -e "\n\t$(tput setaf 14)Type the STR & Additional Notes...$(tput sgr 0)"
	read CAF
	CAG=false
    echo -e "\n\t$(tput setaf 14)Type the Identified By...\n[Leave Blank for $CAG]$(tput sgr 0)\n"
	read CAGA
#	if [ "`echo $CAG`" == "" ]; then
	if [ "`echo $CAGA`" != "" ]; then
		CAG=$CAGA
#	else
		echo -e "\n\t$(tput setaf 14)Do you want to set $CAGA as the default ID?...\n[y/n]$(tput sgr 0)\n"
		read DEFID
	fi
    echo -e "\n\t$(tput setaf 14)Type the Date, or leave empty for auto...\n[$JDATE]$(tput sgr 0)\n"
	read CAH
	if [ "`echo $CAH`" == "" ]; then
		CAH="$JDATE"
	fi
    echo -e "\n\t$(tput setaf 14)Type the Status...\n[o]\tOpen (Default)\n[c]\tClosed\n[f]\tFixed\n[r]\tRetest\n[Open]$(tput sgr 0)\n"
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
	unset -f {CAA,CAB,CAC,CAD,CAE,CAF,CAGA,CAH,CAI} 2>&1 > /dev/null
	if [[ "$DEFID" == "y" ]]; then
		sed -i s/CAG\=false/CAG\=$CAG/g $PROGNAME
	else
		unset -f CAG
	fi
	bug_more
}
function display_logo
{
echo "$(tput setaf 14)############################################################" #RQH-01
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
echo "#.C4.##################################################.C4.#$(tput sgr 0)" #RQH-26
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
		clear
                echo -e $OPTIONS
                exit $?
        fi
        ;;
"-r")
	if [[ "`echo $2`" == "" ]]; then
		printf "\n$(tput setaf 1)The -r Option requires You must provide the filename$(tput sgr 0)\n\t$(tput setaf 3)$PROGNAME -r testreport.csv$(tput sgr 0)\n"
		exit $?
	else
		cat $BREPRT | sed 's/#/\t/g' | less
		exit $?
	fi
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
"-d")
    clear
    echo -e $DESCRIPT
    exit $?
    ;;
*)
	clear
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
		FROMA=false
		EMAIL=false
		if [ "`echo $FROMA`" == "false" ]; then
			echo -e "\n\tYour 'Default' emails have not been set, \n\tafter this instance has exited either manually edit the script Mail settings\n\tor edit the following command with your info (remove all '<>' and edit its contents)-\n\nexport FROMA=<yourdefault_FROM_emsiladdress>\nexport EMAIL=<yourdefault_TO_emsiladdress>\nsed -i s/FROMA=<false>/FROMA=$FROMA/g $PROGNAME\nsed -i s/EMAIL=<false>/EMAIL=$EMAIL/g $PROGNAME \n"
			sleep 2
			echo -e "\n\n\t Do you want this script to add the entries for you when its finished?\n [y/n]"
			read DOEDIT
			if [ "$DOEDIT" == "y" ]; then
				DOEDITA=true
			fi
			if ! $NOSLEEP; then
				sleep 3
			fi
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
	sed -i s/FROMA\=false/FROMA\=$FROMA/g $PROGNAME ; sed -i s/EMAIL\=false/EMAIL\=$EMAIL/g $PROGNAME
fi
#
echo -e "\n\n\n\t$(tput setaf 6)When you open the $2 with your spreadsheet application\n\tuse only the Pound (#) as the deliminator, and as long as you didn't\n\tuse the Pound symbol in any of your inputs it will be fomatted correctly \n\tfor the official Bug-Report.$(tput sgr 0)"
echo -e "\t$(tput setaf 4)I hope you find this script useful, and if you have any feedback, issues, or requests, please send them to my email in the GPL [$PROGNAME -g]...\nThanks,$(tput sgr 0)"
echo -e "\t$(tput setaf 5)C4$(tput sgr 0)"
#
#echo -e "\n"
if ! $NOSLEEP; then
	sleep 12
fi
display_logo
#echo -e "\n"
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
##@	Patch-Level-1.0.00-3  PCHDAT="14 October, 2017"
##@	  	Added 's' Category Option for script bug
##@		fixed redundant check for sript path
##@		general cleanup
##@	Patch-Level-1.0.01-1  PCHDAT="14 October, 2017"
##@		Fixed annoying unset issue with 'not a valid identifier'
##@		Fixed logic for 'Default id'
##@		Added colors to request for input
##@		Added -V option to ignore sleeps/pauses
##@		Added -d option for Description
##@		Fixed -r option with check for $2 filename
##@		Fixed static variable from testing
##@		
##@		
##@		
