#!/bin/bash
# vim: set ts=4 sw=4 sts=4 et :
#
# Overides for `functions.sh`

source "$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"/lib_utils.sh

if ! is_declared color; then
    source "$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"/functions.sh
fi

# ------------------------------------------------------------------------------
# Display messages in color
# ------------------------------------------------------------------------------
# Only output text under certain conditions
output() {
    ## CHANGE:  Don't strip spaces
    #echo "${white}OUTPUT OVERRIDE${reset}"
    if [ "${VERBOSE}" -ge 1 ] && [[ -z ${TEST} ]]; then
        # Don't echo if -x is set since it will already be displayed via true
        [[ ${-/x} != $- ]] || echo -e "${@}"
    fi
}

#outputc() {
#    color=${1}
#    shift
#    output "${!color}"$@"${reset}" || :
#}

#info() {
#    output "${bold}${blue}INFO: "$@"${reset}" || :
#}

#debug() {
#    output "${bold}${green}DEBUG: "$@"${reset}" || :
#}

#warn() {
#    output "${stout}${yellow}WARNING: "$@"${reset}" || :
#}

#error() {
#    output "${bold}${red}ERROR: "$@"${reset}" || :
#}

##if ! is_declared color; then
##    source "$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"/functions.sh
##fi

# ------------------------------------------------------------------------------
# Formatting utils
# ------------------------------------------------------------------------------
strip () {
    echo -e $(echo -e ""$@"")
}


pad () {
    local width=$1
    shift 1 || shift $(($#))
    local string="$@"
    local padding=""

    width=$(( width - ${#string} ))
    for (( i=0; i<${width}; i++ )); do
        padding+=" "
    done
    echo "${padding}${string}"
}


#format_kwargs() {
#    local -n lines="$1"
#    local keywords=()
#    local values=()
#    local width=0
#    local line keyword value
#
#    for line in "${lines[@]}"; do
#        keywords+=("$(strip "${line%%:*}")")
#        values+=("$(strip "${line#*:}")")
#    done
#
#    for keyword in "${keywords[@]}"; do
#        width=$(max $width ${#keyword})
#    done
#
#    for (( index=0; index<${#keywords[@]}; index++ )); do
#        output "${bold}$(pad $width "${keywords[index]}")${reset}: "${values[index]}""
#    done
#}

format_kwargs() {
    local keywords=()
    local values=()
    local width=0
    local line keyword value

    for line in "${@}"; do
        keywords+=("$(strip "${line%%:*}")")
        values+=("$(strip "${line#*:}")")
    done

    for keyword in "${keywords[@]}"; do
        width=$(max $width ${#keyword})
    done

    for (( index=0; index<${#keywords[@]}; index++ )); do
        output "${bold}$(pad $width "${keywords[index]}")${reset}: "${values[index]}""
    done
}

lines () {
    for line in "${@}"; do
      #echo -e "$line\n"
      echo -e "$line"
    done
}
