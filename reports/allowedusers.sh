#! /bin/bash
###
#!/bin/bash
### Colors ###################
	RED='\e[0;31m'
	LTRED='\e[1;31m'
	BLUE='\e[0;34m'
	LTBLUE='\e[1;34m'
	GREEN='\e[0;32m'
	LTGREEN='\e[1;32m'
	ORANGE='\e[0;33m'
	YELLOW='\e[1;33m'
	CYAN='\e[0;36m'
	LTCYAN='\e[1;36m'
	PURPLE='\e[0;35m'
	LTPURPLE='\e[1;35m'
	GRAY='\e[1;30m'
	LTGRAY='\e[0;37m'
	WHITE='\e[1;37m'
	NC='\e[0m'
##############################
##	Example Usage
#	printf "${LTCYAN}\n\tExample text in Light Cyan...${NC}\n\t${CYAN}Example query in Cyan?\n\t[y/n]\n${NC}"
#
	DOMAIN="Need to complete this with your info"
	VALUE="Need to complete this with your info"
	OPTIONS="\n\tUsage-\n${CYAN}This script's main purpose is to scan a single host and report What Groups are allowed to log in via ssh, and then discover What users are in those Groups, and then Discover those users' Real Names. The Secondary use for this script is to discover Either a single User's real name [-i] OR a single User's username based based on the user's Real last name [-n].${NC}\n${RED} You will need to edit this script and change your local Infrastructure's values for Domain, Environment/s, and authentication to the Domain Controller/s.${NC}\n\n\tsyntax =\n   command Name [last-name|uid|${CYAN}file${NC}] UID|Real -[i|n] Environment -[p|s|u] ['Optional hostname']\n[-i]\tUID\t\tUser ID- username\n[-n]\tLast Name\tUser's last name\n[-p]\tEnvironment\tProduction\n[-s]\tEnvironment\tSandbox\n[-u]\tEnvironment\tNon-Prod\n\tExample\t${PURPLE}sh allowedusers.sh smiller -i -p${NC}\n\t\t${PURPLE}sh allowedusers.sh miller -n -p${NC}\n\tUsing the ${CYAN}'file'${NC} option instead of 'user'\n\tREQUIREs a hostname to be scanned like so-\n\t\t ${PURPLE}sh allowedusers.sh${NC} ${CYAN}file${NC} ${PURPLE}-i -p${NC} ${CYAN}<hostname>${NC}\n"
if [ "`echo $1`" == "" ]; then
        echo -e $OPTIONS | less
	exit 0
fi
case "$2" in
"-n")
        NMA=sn
        ;;
"-i")
        NMA=cn
        ;;
"*")
	echo -e $OPTIONS | less
        ;;
esac

case "$3" in
"-p")
        ENV=$PROD.DC.FQDN
        ;;
"-u")
        ENV=$NONPROD.DC.FQDN
        ;;
"-s")
        ENV=$SANDBX.DC.FQDN
        ;;
"*")
	echo -e $OPTIONS | less
        ;;
esac
if [[ "`echo $1`" != "file" ]]; then
  ldapsearch -h $ENV -D "cn=VALUE,ou=accounts,o=DOMAIN" -w VALUE -LLL "($NMA=$1)" cn fullname
  exit $?
else
  ssh $4 grep AllowG /etc/ssh/sshd_config | sed -e 's/\ /\n/g' > allowedgroups.txt
  for i in `cat allowedgroups.txt`; do echo -e "\n$i" >> group-mems.txt; ssh $4 getent group $i >> group-mems.txt; done
  echo -e "\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n" >> group-mems.txt
  cat group-mems.txt | awk -F: '{print $4}' | sed -e 's/,/\n/g' | sed '/^\s*$/d' >> memlist.txt
  for n in `cat memlist.txt`; do echo -e "\n$n" >> group-mems.txt ; ldapsearch -h $ENV -D "cn=VALUE,ou=accounts,o=DOMAIN" -w VALUE -LLL "($NMA=$n)" cn fullname | grep fullname >> group-mems.txt ; done
fi
#
mv group-mems.txt $4-group-mems.txt
rm allowedgroups.txt memlist.txt
#
exit 0
