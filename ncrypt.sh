#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

cypher='aes-256-cbc'

## Format
# ncrypt file.txt
# ncrypt -d file.ncrypt
# ncrypt -v file.ncrypt
##

check_arguments() {
	if [[ $# -eq 1 ]] && [[ -f $1 ]]; then
		mode='encrypt'
		input_file="$1"
	elif [[ $# -eq 2 ]] && [[ -f $2 ]] && [[ $1 == '-d' ]]; then
		mode='decrypt'
		input_file="$2"
	elif [[ $# -eq 2 ]] && [[ -f $2 ]] && [[ $1 == '-v' ]]; then
		mode='view'
		input_file="$2"
	else
		echo "kp we :@"
		exit 1
	fi
}

get_file_path() {
	echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

get_file_name() {
	echo "$(basename "$1")"
}

file_exists() {
	if [[ -e $1 ]]; then
		read -p 'The output file already exists. Overwrite? [Y/n] ' reply
		if [[ ${reply} =~ [Nn] ]]; then
			echo 'Existing program now we'
			exit 1
		else
			echo
		fi
	fi
}

encrypt() {
	local output_file="$(get_file_path ${input_file}).ncrypt"
	file_exists "${output_file}"
	openssl enc -"${cypher}" -in "${input_file}" -out "${output_file}" 
	echo -e "\nEncrypted and saved to ${output_file}"
}

decrypt() {
	local output_file="$(echo $(get_file_path ${input_file}) | sed 's/.ncrypt$//')"
	file_exists "${output_file}"
	openssl enc -d -"${cypher}" -in "${input_file}" -out "${output_file}"
	echo -e "\nDecripted and saved to ${output_file}"
}

view() {
	local result="$(openssl enc -d -"${cypher}" -in "${input_file}")"
	echo "${result}" | less
}


init() {
	case "$1" in
		encrypt) encrypt ;;
		decrypt) decrypt ;;
		view) view ;;
	esac
}

main() {
	check_arguments "$@"
	init "${mode}"
}

main "$@"
