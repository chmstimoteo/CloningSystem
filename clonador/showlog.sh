#!/bin/bash

clear

cd /

for c in `cat /proc/cmdline` ; do
	case $c in
		"CLONE")
			log="logClone1.txt"			
			;;
		"CHOOSE_IMAGE")
			log="logClone1.txt"
			;;
		"CREATE_IMAGE")
			log="logCreate.txt" 
			;;
		"LOAD_GUI")
			;;
		*)
			;;
	esac
done


while [ ! -e $log ]; do sleep 1; done

tail -f -n 45 $log
