#!/bin/bash

#Convert the current date to seconds
current_date=$(date +%s)
#Store the hostname in a variable
host=`hostname`
#Again taking today's date to use in file name
today_date=$(date +%F)
#getting the list of all the users from /etc/shadow and storing it in a file
cat /etc/shadow | cut -d: -f1,8 | sed s'/.$//' > /tmp/expirelist.txt
#get the total number of accounts
total_number_of_accounts= `cat /tmp/expirelist.txt | wc -l`
#defining a variable where the file name will be stored which will contain the list of accounts which are going to expire in 10 days
file="/var/tmp/$today_date-expiring_soon_passwd_list.csv"

