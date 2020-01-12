#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

cypher='aes-256-cbc'

## Format
# ncrypt file.txt
# ncrypt file.txt.ncrypt
# ncrypt -v file.txt.ncrypt
# ncrypt -g pattern file.txt.ncrypt
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
		3)
			if [[ $1 == '-g' ]] && [[ $3 =~ .ncrypt$ ]]; then
				mode='search'
				pattern="$2"
				input_file="$3"
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

search () {
	local result="$(echo "$(openssl enc -d -"${cypher}" -in "${input_file}")" | grep -wi ${pattern})"

	if [[ -z ${result} ]]; then
		echo 'Pattern not found'
		exit 1
	else
		echo "${result}" | less
	fi
}

init() {
	case "$1" in
		encrypt) encrypt ;;
		decrypt) decrypt ;;
		view) view ;;
		search) search ;;
	esac
}

main() {
	check_arguments "$@"
	init "${mode}"
}

main "$@"
