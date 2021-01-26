#!/bin/bash

# temp files
menufile="/tmp/inputmenu.txt"
outputfile='/tmp/outputcontent.txt'
eventfile='/tmp/eventfile.txt'
user='/tmp/username.txt'
password='/tmp/password.txt'
confirmation='/tmp/confirmation.txt'
tmpdate='/tmp/tmpdate.txt'

# find out the user's name  
pc_name=$USER
DIR="/home/$pc_name/users/" 

# check if directory exists
if [ ! -d "$DIR" ]; then
	mkdir "$DIR"
fi

# trap and delete temporary files when any signals received (SIGINT, SIGTERM, SIGHUP) are received.
trap "rm $menufile; rm $outputfile; rm $eventfile; rm $user; rm $password; rm $confirmation; exit" SIGINT SIGTERM SIGHUP

# main function
function main() {
	# greet user
	beep; dialog --ascii-lines --colors --infobox "\Z2Hello CST1500" 3 17
	# sleep for 1 sec
	sleep 1
	# function call
	account_creation

}

# function for guage (loading /exit)
function gauge {
	for i in $(seq 0 10 100)  #seq is used to generate number from start to last in a sequence
         do 
		 sleep 0.115
		 echo $i | dialog --title "Loading" --colors --gauge "$1" 6 60 0;
         done
}

# function for creating user acccount
function account_creation() {
 dialog --colors \
 	--title "Account" \
 	--ok-label "Yes" \
 	--no-label "Login" \
   	--yesno "\Zb\Z2Do you want to create an account?" 5 46
   response=$? # variable to store what user has pressed. 0 represents Yes. 1 represents Login.
   # choose between yes and no
   case $response in
      # create a user account
      0) dialog --colors --title "USERNAME"  --inputbox "\Zb\Z5Enter your username" \
      		8 60 2>$user
      		userut=$?
      		case $userut in
      		0) 	# check if the username already exists
	      		if [ -d "$DIR$(<$user)" ]; then 
		 		beep; dialog --colors --ascii-lines --title "Account Exists" \
		 		 --infobox "\Zb\Z1Account of name $(<$user) already exits" 5 25; sleep 2.5
		 		 
		 		dialog --colors --yes-label "Login" --no-label "Sign Up" --yesno "What do you want to do?" 0 0 
		 		optionretval=$?
		 		case $optionretval in
		 		0)  function_login ;;
		 		1) account_creation ;;
		 		esac
	 		else 
	 			# if username does not exist, create an account 
	 			mkdir "$DIR$(<$user)"
		      		retval=$?
		      		case $retval in
		      		0) 	# prompt the user to enter password
					dialog --colors --insecure --title "PASSWORD" --passwordbox "\Zb\Z6Enter your password" \
			       	8 60 2>$password
			       	
			       	# create textfile name password and eventdata
			       	touch "$DIR$(<$user)/password"
			       	touch "$DIR$(<$user)/eventdata"
			       	
			       	# store the password entered in the text file
			       	echo "$(<$password)" > "$DIR$(<$user)/password"
			       	
				       returnval=$?
				       case $returnval in 
				 	0) # verify the password
				 	   verification "Please re-enter your password"
					   sleep 1 ;;
					1) account_creation ;;
					esac
			       	;;
			       	
			       1) account_creation ;;
			       esac 
		       fi ;;
		       
		 1) account_creation ;;
		esac
		     
        ;;
         
        
      1) function_login 
       ;;
   esac
}

# function to log in
function function_login {
	# redirect to login dialog 
      		dialog --colors --title "LOG IN"  --inputbox "\Zb\Z5Username:" \
      		8 60 2>$user 
      		# check if user already exists
      		if [ -d "$DIR$(<$user)" ]; then
	      		reponse=$?
	      		case $reponse in 
	      		0) 	# verify the password
	      			verification "Password:" ;;
	      		1) account_creation ;;
	      		esac
	      	else 	
	      		beep; dialog --colors --title "Wrong Username" --infobox "\Zu\Z1User does not exist" 3 24
	       	sleep 1
	       	account_creation
	       fi
}

# function to verify matching password
function verification() {
       dialog --colors --insecure --title "PASSWORD" --passwordbox "\Zb\Z0$1" \
              8 60 2>$confirmation
       response=$?
       case $response in 
       0)       # function to verify if password entered matched reenter password
       	if [ "$(cat "$DIR$(<$user)/password")" = "$(cat $confirmation)" ]; then
	       	dialog --title "WELCOME" --colors --infobox "\Zb\Z0You have been logged in as $(<$user)" 3 45
			sleep 1.25
			
			# function call 
			gauge "\Zr\Z3Redirecting you to the main menu..." ; main_menu
		else
			
	       	beep; dialog --colors --infobox "\Zu\Z1Wrong password" 3 20
	       	sleep 1
	       	# reprompt the user to enter the password
	       	verification "Please re-enter the password"
        	fi
        	;;
        	
        1) 	account_creation ;;
        
       esac
	
}

# function to display the main menu
function main_menu() {
	# create a menu to display the main menu
	dialog --clear --colors --title "\Zb\Z0Coursework 2" \
		--menu "\Z2Make your choice:" 13 45 15 \
		Date/Time "\Z3To see current date and time" \
		Calendar "\Z4To see current calendar" \
		Delete "\Z5To delete selected file" \
		Exit "\Z6To Exit this shell script" 2>$menufile


	# copy the content of inputfile into the variable menuchoice	
	menuchoice=$(<$menufile)

	# make decision to call which function
	# make use of case loop
	case $menuchoice in
		Date/Time) function_DateTime ;;
		Calendar) function_Calendar ;;
		Delete) function_Delete ;;
		Exit) function_Exit;;	
	esac
}

# function to display the Date/Time
function function_DateTime() {
	dialog --title "Date and Time" --colors --msgbox "\Z2Today is $(date '+%A %W %Y'). \
	Time is $(date '+%X')." 10 25
	response=$?
	case $response in 
	   0) gauge "\Zr\Z3Redirecting you to the main menu..." ; main_menu ;;
	esac 

}

# function to display the Calendar
function function_Calendar() {
    dialog --cancel-label "Main Menu"  --calendar "Calendar" 0 0 2>$outputfile
    response=$?
    case $response in
    	0) # ask user if want to view old event/reminder 
    	dialog --title "Event/Reminder" --ok-label "Yes" --cancel-label "Add new" --no-label "Add new" --extra-button --extra-label "Main menu" \
    	--yesno "Do you want to view old events for $(<$outputfile)?" 5 50
    	retval=$?
	    	case $retval in
	    	 0) # function call to loop through file
	    	 fileloop
	    	 if [ -s "$tmpdate" ] 
	    	 then
		    	# display old events/reminder
		    	old_Event
			
		else
			dialog --msgbox "There is no event for $(<$outputfile)" 5 40
			outputval=$?
			case $outputval in
				0) function_Calendar ;;
			esac
		fi
		;;
	    	1) eventReminder ;;
	    	3) gauge "\Zr\Z3Redirecting you to the main menu..." ;  main_menu;;
		esac
	;;
	1) gauge "\Zr\Z3Redirecting you to the main menu..." ;  main_menu;;
    esac
}

# function for event or reminder
function eventReminder() {
	# append the date to the eventfile in a nextline
	echo -n "$(<$outputfile):">>$eventfile
	dialog --title "$(<$outputfile)" \
               --inputbox "Enter an event or reminder " \
                 8 60 2>>$eventfile
        res=$?       
        # keep a space between the date and the event/reminder
        echo " ">>$eventfile

        case $res in 
             0) # store the content permanently
                echo "$(<$eventfile)" >> "$DIR$(<$user)/eventdata"
                [ -f $eventfile ] && rm $eventfile	
              	#  function call 
                fileloop
                old_Event
		;;
             1) function_Calendar ;;
       esac               
}

# function to loop through file
function fileloop() {	    	 
	# redirect the content of eventdata to line
	# read each line and check if the date matches the first 10 characters in line
	# read until EOF
	cat $DIR$(<$user)/eventdata | while read line || [[ -n $line ]];
	do
		date="${line:0:10}"
		if [ "$(cat $outputfile)" = "$date" ]; then
			echo "${line:11:50}">>$tmpdate

		fi
	done
}

# function to display old events
function old_Event() {
	dialog --title "Displaying event or reminder for $(<$outputfile)" \
		--msgbox "$(<$tmpdate)" 0 0
	[ -f $tmpdate ] && rm $tmpdate
	reponse=$?
	case $reponse in 
		0) function_Calendar ;;
	esac
}

# function to exit the shell script
function function_Exit() {
   echo "Bye Bye :)" >$outputfile
   dialog --title "Exit" \
   	   --colors \
   	  --yesno "\Zb\Z2Are you sure you want to exit?" 5 50
   response=$?
   case $response in
      0) beep; dialog --colors --ascii-lines --infobox "\Z2Bye-Bye" 3 12 ; sleep 1 
         gauge "\Zr\Z3Redirecting you to the terminal..." ; clear ; exit ;;
      1) gauge "\Zr\Z3Redirecting you to the main menu..." ; main_menu ;;
   esac
}

function function_Delete() {

	FILENAME=$(zenity --file-selection --text="Enter file to be deleted:")
	retval=$?
	case $retval in 
	0)
		dialog --backtitle "Recycle bin" --title "DELETE" --colors \
		--yesno "\Zu\Z1Are you sure you want to move $FILENAME to recycle bin?" 7 70
		response=$?
		
		case $response in 
		0)	
			if [[ -f $FILENAME ]];then
				# deleting screen
				gauge "\Zu\Z1Recycling..." ; trash-put $FILENAME
				beep; dialog --colors --infobox "\Z2Successfully deleted" 3 30 ; sleep 1 
				gauge "\Zr\Z3Redirecting you to the main menu..." ; main_menu
				
			elif [[ -d $FILENAME ]]; then
				dialog --msgbox "Specified path is a directory not a file" 0 0
				gauge "\Zr\Z3Redirecting you to the main menu..." ;  main_menu
			else
				dialog --msgbox "Specified path does not exist" 0 0 
				gauge "\Zr\Z3Redirecting you to the main menu..." ; main_menu
			fi 
		;;
		
		1) gauge "\Zr\Z3Redirecting you to the main menu..." ; main_menu ;; 
		255) gauge "\Zr\Z3Redirecting you to the main menu..." ; main_menu ;;
		esac
	;;
	
	1) 	main_menu;;
	esac
}

# call the main function
main

# delete temporary files
[ -f $menufile ] && rm $menufile
[ -f $outputfile ] && rm $outputfile
[ -f $eventfile ] && rm $eventfile
[ -f $user ] && rm $user
[ -f $password ] && rm $password
[ -f $confirmation ] && rm $confirmation
