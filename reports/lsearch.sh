#! /bin/bash
# Edit all values in '<xxx>' greater/less-than 
	DOMCONTRL=<domain.controller.fqdn>
	OPTIONS="\n\tUsage-\nsyntax =  command [last-name|uid] -[i|n]\n[-i]\tUID\t\tUser ID- username\n[-n]\tLast Name\tUser's last name\n\tExample\tsh lsearch.sh smiller -i\n\t\tsh lsearch.sh miller -n\n"
if [ "`echo $1`" == "" ]; then
        echo -e $OPTIONS
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
	echo -e $OPTIONS
    exit 0
        ;;
esac
ldapsearch -h $DOMCONTRL -D "cn=<VALUE>,ou=accounts,o=<DOMAIN>" -w <VALUE> -LLL "($NMA=$1)" cn fullname
exit 0
