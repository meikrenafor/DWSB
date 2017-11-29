#!/bin/bash

####################################################################################

#
# Checks is specified file exist.
#
# @arg1 - path to file
#
# @return 0 (true) | 1 (false)
#
fileExists () {
	if [ -f "$1" ]; then return 0; else return 1; fi
}

#
# Checks is specified folder exist.
#
# @arg1 - path to folder
#
# @return 0 (true) | 1 (false)
#
folderExists () {
	if [ -d "$1" ]; then return 0; else return 1; fi
}

#
# Checks is specified variable exist.
#
# @arg1 - variable
#
# @return 0 (true) | 1 (false)
#
variableExists () {
	if [[ ! "$1" = "" ]]; then return 0; else return 1; fi
}

#
# Checks if array contains specified element.
#
# @arg1 - needle
# @arg2 - haystack
#
# @return 0 (true) | 1 (false)
#
arrayContains () {
	if [[ " ${2//|/ } " =~ " $1 " ]]; then return 0; else return 1; fi
}

#
# Prints user message.
#
# @arg1 - message to print
# @arg2 - emit carriage return (true) or not (false)
# @arg3 - add -e flag to echo command (true - by default) or raw print (false)
#
# @return nothing
#
printMessage () {
	message="$1";

	returnCarriage=true;
	smartPrint=true;

	# check arg2
	variableExists "$2";
	if [[ "$?" -eq 0 ]]; then
		arrayContains "$2" 'true|false';
		if [[ "$?" -eq 0 ]]; then
			returnCarriage="$2";
		fi
	fi

	# check arg3
	variableExists "$3";
	if [[ "$?" -eq 0 ]]; then
		arrayContains "$3" 'true|false';
		if [[ "$?" -eq 0 ]]; then
			smartPrint="$3";
		fi
	fi

	# build eval string
	evalString='echo';

	# check smart print
	if [[ "${smartPrint}" = true ]]; then
		evalString="${evalString} -e";
	fi

	# check carriage return
	if [[ "${returnCarriage}" = false ]]; then
		evalString="${evalString} -n";
	fi

	# add message itself
	evalString="${evalString} \"${message}\"";

	eval "${evalString}";
}

####################################################################################

# file exists

file='dwsb.log';
fileExists "${file}";

if [[ "$?" -eq 0 ]]; then
        printMessage "\tFile exists.";
fi

# folder exists

folder='www-review.kic.com';
folderExists "${folder}";

if [[ "$?" -eq 0 ]]; then
	printMessage "\tFolder exists.";
fi

# array contains

site='kic';
siteValues='kic|dlsg|imageaccess';
arrayContains "${site}" "${siteValues}"

if [[ "$?" -eq 0 ]]; then
	printMessage "\tArray contains.";
fi

####################################################################################

# build array from string (normalize)
array=(${siteValues//|/ });

# loop over array elements
for i in "${!array[@]}"; do
	printMessage "${i} => ${array[i]}; " false;
done

# loop example with counter
offsetCount=5; # offset substitution count
offsetValue='\t'; # offset building block
offsetSubString=''; # result substring
offsetDirection=''; # l - left or R - right

counter=0;
while [  "${counter}" -lt "${offsetCount}" ]; do
	offsetSubString="${offsetSubString}${offsetValue}";
	let counter=counter+1;
done

printMessage "${offsetSubString}";

fileExists "${offsetCount}";
if [[ "$?" -eq 0 ]]; then
	printMessage "\toffsetCount";
fi
