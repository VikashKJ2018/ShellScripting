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
total_number_of_accounts=`cat /tmp/expirelist.txt | wc -l`

#defining a variable where the file name will be stored which will contain the list of accounts which are going to expire in 10 days
file="/var/tmp/$today_date-expiring_soon_passwd_list.csv"

#starting the for loop which will check each account mentioned in the expirelist.txt

for ((i=1; i<=$total_number_of_accounts; i++)) #this will iterate from 1 to the total_number_of_accounts calculated at line 16
        do
        
        user_name=`head -n $i /tmp/expirelist.txt | tail -n 1`
        
        user_id_passwd_expire=$(chage -l $user_name | awk '/^Password expires/ { print $4,$5,$6 }' | grep -v "never") #checking the date   when the userid is going to expire
        
        if [[ ! -z $user_id_passwd_expire ]]
        
        then
                remaining_time_before_expiration_in_seconds=`expr $passexp -$currentdate`
                
                remaining_days=`expr remaining_time_before_expiration_in_seconds / 86400` #converting the expiration time from seconds to days
                
                if ((remaining_days > 0 && remaining_days < 10))
                
                then
                
                echo "$user_name,"",$remaining_days" >> $file
                
                fi
        
        fi
        
done


#Sending the mail with attachment
if [ -f "$file" ]
then
        {
        echo "Password expiration alert on $host"
        echo "To:vikashkj20100917@gmail.com"
        echo "List of local accounts which are going to expire in less than 10 days"
        cat $file
        uuencode $file $today_date-expiring_soon_passwd_list.csv
        } | /usr/lib/sendmail -t
        sleep 10s
        rm -rf $file #once the file has been sent the script will sleep for 10 secs and then delete the file
else
        mail -s "Password expiration alert on $host" vikashkj20100917@gmail.com <<< "No Password is expiring in next 10 days"
fi
