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
	elif [[ $# -eq 2 ]] && [[ $1 == '-d' ]] && [[ -f $2 ]]; then
		mode='decrypt'
		input_file="$2"
	else
		echo "kp we :@"
		exit 1
	fi
}

get_file_path() {
	local file="$1"
	echo "$(cd "$(dirname "${file}")" && pwd)/$(basename "${file}")"
}

encrypt() {
	local output_file="$(get_file_path ${input_file}).ncrypt"
	openssl enc -"${cypher}" -in "${input_file}" -out "${output_file}" 
	echo -e "\nEncrypted and saved to ${output_file}"
}

decrypt() {
	local output_file="$(echo $(get_file_path ${input_file}) | sed 's/.ncrypt$//')"
	openssl enc -d -"${cypher}" -in "${input_file}" -out "${output_file}"
	echo -e "\nDecripted and saved to ${output_file}"
}

init() {
	if [[ $1 == 'decrypt' ]]; then
		decrypt
	elif [[ $1 == 'encrypt' ]]; then
		encrypt
	fi
}

main() {
	check_arguments "$@"
	init "${mode}"
}

main "$@"
