#! /bin/bash
###
# # Edit all values in '<xxx>' greater/less-than
##############################
##	Example Usage
#
	DOMAIN="Need to complete this with your info"
	VALUE="Need to complete this with your info"
    OPTIONS="\n\tUsage-\n$(tput setaf 6) This script's main purpose is to scan a single host and report What Groups are allowed to log in via ssh, and then discover What users are in those Groups, and then Discover those users' Real Names. The Secondary use for this script is to discover Either a single User's real name [-i] OR a single User's username based based on the user's Real last name [-n].$(tput sgr 0)\n$(tput setaf 1) You will need to edit this script and change your local Infrastructure's values for Domain, Environment/s, and authentication to the Domain Controller/s.$(tput sgr 0)\n\n\tsyntax =\n   command Name [last-name|uid|$(tput setaf 6)file$(tput sgr 0)] UID|Real -[i|n] Environment -[p|s|u] $(tput setaf 6)['Optional hostname']$(tput sgr 0)\n[-i]\tUID\t\tUser ID- username\n[-n]\tLast Name\tUser's last name\n[-p]\tEnvironment\tProduction\n[-s]\tEnvironment\tSandbox\n[-u]\tEnvironment\tNon-Prod\n\tExample\t$(tput setaf 5)sh allowedusers.sh smiller -i -p$(tput sgr 0)\n\t\t$(tput setaf 5)sh allowedusers.sh miller -n -p$(tput sgr 0)\n\tUsing the $(tput setaf 6)'file'$(tput sgr 0) option instead of 'user'\n\tREQUIREs a hostname to be scanned like so-\n\t\t $(tput setaf 5)sh allowedusers.sh$(tput sgr 0) $(tput setaf 6)file$(tput sgr 0) $(tput setaf 5)-i -p$(tput sgr 0) $(tput setaf 6)<hostname>$(tput sgr 0)\n"

if [ "`echo $1`" == "" ]; then
        echo -e $OPTIONS
	exit 0
fi
if [[ "`echo $1`" == "file" ]]; then
  if [[ "`echo $4`" == "" ]]; then
    echo -e "\n$(tput setaf 1)\tUsing the$(tput sgr 0) $(tput setaf 6)'file'$(tput sgr 0)$(tput setaf 1) option instead of 'user'\n\tREQUIREs a hostname to be scanned like so-$(tput sgr 0)\n\t\t $(tput setaf 5)sh allowedusers.sh$(tput sgr 0) $(tput setaf 6)file$(tput sgr 0) $(tput setaf 5)-i -p$(tput sgr 0) $(tput setaf 6)<hostname>$(tput sgr 0)\n"
    exit 0
  fi
fi
case "$2" in
"-n")
        NMA=sn
        ;;
"-i")
        NMA=cn
        ;;
"*")
	echo -e $OPTIONS
	exit 0
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
	echo -e $OPTIONS
	exit 0
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
