#!/bin/bash

# file to store the choice of the main menu
inputfile="/tmp/inputmenu.txt"

# function to display the result
function information_display() {

	dialog --title "$1" \
	--clear --ascii-lines --no-collapse --title "$1" \
	--msgbox "$output" ${2} ${3}
	response=$?
   	case $response in 
   		0) gauge "\Zr\Z3Redirecting you to the main menu..."; main ;;
   	esac  
}

# function to display the operating system type
function function_OS() {
	output=$(cat /etc/os-release)
	information_display "Operating System" 18 70  
}


# function to display the computer CPU information
function function_CPU {
	output=$(cat /proc/cpuinfo)
	information_display "Computer CPU information" 50 75

}

# function to display the memory information
function function_Memory {
	output=$(cat /proc/meminfo)
	information_display "Memory information" 60 35
}

# function to display the hard disck information
function function_HardDisk {
	output=$(sudo sfdisk -l)
	dialog --clear --ascii-lines --no-collapse --msgbox "$output" 70 90
	response=$?
   	case $response in 
   		0) gauge "\Zr\Z3Redirecting you to the main menu..."; main ;;
   	esac  
}

# function to display the file system
function function_FileSystem() {
	output=$(df -h)
	information_display "File System (Mounted)" 60 75
}


# function to exit the shell script
function function_Exit() {
   echo "Bye Bye :)" >$outputfile
   dialog --title "Exit" \
   	  --yesno "Are you sure you want to exit?" 7 50
   response=$?
   case $response in
      0) 
     	 dialog --ascii-lines --colors --infobox "\Z2Bye Bye" 3 12
         sleep 1
         clear
         exit ;;
      1) main ;;
   esac
}

# function for guage (loading /exit)
function gauge {
	for i in $(seq 0 10 100)  #seq is used to generate number from start to last in a sequence
         do 
		 sleep 0.115
		 echo $i | dialog --title "Loading" --colors --gauge "$1" 6 60 0;
         done
}

# main function
function main() {
 	clear 
	dialog --title "Menu" \
	--backtitle "Operating System Programming" \
	--clear \
	--cancel-label "Exit" \
	--menu "Make your choice" 0 0 0 \
	"1." "Your Operating System Type" \
	"2." "Computer CPU Information" \
	"3." "Memory Information" \
	"4." "Hard Disk Information" \
	"5." "File System (Mounted) " \
	2>$inputfile
	response=$?
	echo  "$response"
	case $response in 
	0) 	# copy the content of inputfile into the variable menuchoice	
		menuchoice=$(<$inputfile)

		# make decision to call which function
		# make use of case loop
		case $menuchoice in
			1.) function_OS ;;
			2.) function_CPU ;;
			3.) function_Memory ;;
			4.) function_HardDisk ;;
			5.) function_FileSystem ;;	
		esac
	;;
	1) function_Exit ;;
	
	esac 

}

dialog --ascii-lines --colors --infobox "\Z2HELLOO CST1500" 3 18; sleep 1
# call the main function
main
