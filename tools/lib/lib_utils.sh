#!/bin/bash
# vim: set ts=4 sw=4 sts=4 et :
#
# lib_utils.sh 0.1.0


##
## UTILS
##

__all__=(
    as_array
    contains
    is_declared
    is_set
    min
    max
    toggle_verbose
    quote
)

# Set 'true'/'false' if not already defined
if [ -z ${false+x} ]; then
    declare -ir false=0 true=1
fi

################################################################################
## GENERAL UTILS
################################################################################

# ==============================================================================
# DEBUG - FORMAT DEBUG MESSAGE AND OUTPUT TO CONSOLE
# ==============================================================================
as_array() {
    # Array parameter may be passed as array name or args.
    #   as_array local_var array[@]
    #   as_array local_var "${array[@]}"
    #   as_array local_var "${@:2}"
    #
    # NOTE:  Caller array name CAN NOT be 'shared_array' to prevent a name
    #        conflict.
    #
    # $1: Array name used by caller.
    # ${@:2}: Array or args.

    # The 'shared_array' variable references the name provided by the caller.
    # Even though the scope is local, the 'shared_array' variable scope is
    # avialable to the caller which can access the it using the name it
    # provided, even if a new 'shared_array' is created within this function.
    local name=$1
    local -n shared_array=$name
    shift 1 || shift $(($#))
    local __args=("${@}")

    # The length of __args is greater than zero
    if(( ${#__args[@]} )); then

        # Existing array name reference
        # The shell variable varname is set (has been assigned a value)
        # myArray[@]
        if [[ -v ${__args[0]} ]]; then
            (( DEBUG_UTILS )) && show_arg "ARRAY FROM NAME-REF"

            # Append '[@]' if array name does not end with it.
            # Example: 'myArray' becomes 'myArray[@]'
            [[ "${__args[0]}" =~ (.*)\[@\]$ ]] || __args[0]="${__args[0]}[@]"

            # Use name reference ('myArray[@]')
            shared_array=("${!__args[0]}")

        # Populate array using passed __args
        else
            shared_array=("${@}")
        fi

    # The length of __args[0] is zero
    else
        shared_array=()
    fi
}

# ==============================================================================
# CONTAINS - ELEMENT IN
# ==============================================================================
contains () {
    # $1: Value to search for.
    # $(@:2}: Array or args to be searched for 'value' match.
    local value="$1"
    shift 1 || shift $(($#))
    local __args=("${@}")
    local item _contains_array

    as_array _contains_array "${__args[@]}"
    for item in "${_contains_array[@]}"; do
        [[ "$item" == "$value" ]] && return 0;
    done
    return 1
}

# ==============================================================================
# Check if variable or array is declared
# ==============================================================================
is_declared() {
    { [[ -n ${!1+x} ]] || declare -p $1 &>/dev/null;}
}

# ==============================================================================
# Check if variable or array is set
# ==============================================================================
is_set() {
    ! { [[ -z ${!1+x} ]] && ! declare -p $1 &>/dev/null;}
}

# ==============================================================================
# Return min value
# ==============================================================================
##min () {
##    local max=$1
##    local value=$2
##    dc -e "[${max}]sM ${value}d ${max}<Mp"
##}
min () {
    local min=${1:-0}
    shift 1 || shift $(($#))

    for value in "$@"; do
        min=$(( min < value ? min : value ))
    done
    echo $min
}

# ==============================================================================
# Return max value
# ==============================================================================
##max () {
##    local min=$1
##    local value=$2
##    dc -e "[${min}]sM ${value}d ${min}>Mp"
##}
max () {
    local max=${1:-0}
    shift 1 || shift $(($#))

    for value in "$@"; do
        max=$(( max > value ? max : value ))
    done
    echo $max
}

# ==============================================================================
# Return single quoted string
# ==============================================================================
quote () {
    printf "'%s'" "$@"
}

# ==============================================================================
# toggle verbose on/off
# ==============================================================================
# Don't re-initialize if already defined to prevent over-writing values
if ! is_declared _VERBOSE_LAST; then
    _VERBOSE_LAST=
    export _VERBOSE_LAST
fi

toggle_verbose () {
    local verbose="$VERBOSE"

    if ! is_declared VERBOSE; then
        return 0
    fi

    if [ "${VERBOSE}" -ge 1 ]; then
        VERBOSE=0
        _VERBOSE_LAST="$verbose"

    elif [ -z "${_VERBOSE_LAST}" ]; then
        # If `_VERBOSE_LAST` is empty, that would indicate that `VERBOSE` has
        # never been toggled, so it's a good indicator that the initial value of
        # `VERBOSE` is set to 0.
        return 0

    else
        VERBOSE="$_VERBOSE_LAST"
        _VERBOSE_LAST="$verbose"
    fi
}

