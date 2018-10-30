#!/bin/bash

#// Variables
pretty=True
sleeptime=10
outputdir="."
url="https://haveibeenpwned.com/api/v2/breachedaccount/"

#// functions
function validemailaddress {
	#// return 1 if email address appears valid else return 0
	local result=0
	if [[ "$1" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$ ]]; then 
		result=1
	else
		result=0
	fi
	echo $result
}

function fileexist {
	#// return 1 if file exist 0 if file is not found
	local result=0
	if ! [[ -f "$1" ]]; then
		result=0
	else
		result=1
	fi
	echo $result
}

function direxist {
	#// return 1 if directory exist 0 if directory is not found
	local result=0
	if ! [[ -d "$1" ]]; then
		result=0
	else
		result=1
	fi
	echo $result
}

#// Variables
if [ $# -eq 0 ] ; then
  echo "syntax: pwned.sh [email_file_list]"
  exit 1
else
	inputfile=$1
	
	if [ $# -eq 2 ] ; then
		outputdir=$2
		if [ $(direxist $outputdir) -eq 0 ]; then
			echo Warning: unable to access directory $outputdir
			exit 1
		fi
	fi

	if [ $(fileexist $inputfile) -eq 0 ]; then
		echo Warning: unable to access file $inputfile
		exit 1
	fi

	#/ main loop
	for i in $(cat $inputfile);do
		
		#// sanitize inputs
		input=`echo $i`

		if [ "$(validemailaddress $input)" -eq 0 ]; then
			echo Warning: $input does not appear to be valid.
		else
			result="$(curl "$url$input")"
			output=`echo $i`
			echo Writting $output
			
			if [ $pretty == "True" ]; then
				#// output pretty
				echo $result | python -m json.tool > $outputdir/$output.json
			else
				#// output raw
				echo $result > $outputdir/$output.json
			fi
		fi
			#// delay between queries to be polite
			sleep $sleeptime
	done
fi
