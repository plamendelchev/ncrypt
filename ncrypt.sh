#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

cypher='aes-256-cbc'

## Format
# ncrypt file.txt
# ncrypt file.txt.ncrypt
# ncrypt -v file.txt.ncrypt
##

check_arguments() {
	if [[ ! -f ${@: -1} ]]; then
		echo 'kp we :@'
		exit 1
	fi

	case "$#" in
		1)
			if [[ ! $1 =~ .ncrypt$ ]]; then
				mode='encrypt'
				input_file="$1"
			elif [[ $1 =~ .ncrypt$ ]]; then
				mode='decrypt'
				input_file="$1"
			fi
			;;
		2)
			if [[ $1 == '-v' ]] && [[ $2 =~ .ncrypt$ ]]; then
				mode='view'
				input_file="$2"
			else
				echo 'kp we :@'
				exit 1
			fi
			;;
		*)
			echo "kp we :@"
			exit 1
	esac
}

get_abs_path() {
	echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

get_name() {
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
	local output_file="$(get_abs_path ${input_file}).ncrypt"
	file_exists "${output_file}"
	openssl enc -"${cypher}" -in "${input_file}" -out "${output_file}" 
	echo -e "\nEncrypted and saved to ${output_file}"
}

decrypt() {
	local output_file="$(echo $(get_abs_path ${input_file}) | sed 's/.ncrypt$//')"
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
