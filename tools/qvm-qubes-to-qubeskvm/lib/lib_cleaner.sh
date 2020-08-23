#!/bin/bash
# vim: set ts=4 sw=4 sts=4 et :
#
# lib_cleaner.sh 0.1.0

source "$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"/lib_utils.sh

##echo ""
##echo "========================================================================="
##echo "----> lib_cleaner: toggle on VERBOSE: VERBOSE=$VERBOSE"
toggle_verbose  # Hide 'Currently runnig script...' message


source "$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"/lib_functions.sh
##lib_functions="$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"/lib_functions.sh
##source "$lib_functions"


##echo "----> lib_cleaner: toggle off VERBOSE: VERBOSE=$VERBOSE"
toggle_verbose

# Don't re-initialize `CLEANERS` if already defined to prevent over-writing
# values
if ! is_declared CLEANERS; then
    output "Defining $(quote CLEANERS) array"
    CLEANERS=()
    export CLEANERS
fi

# ==============================================================================
# Cleaner
# ==============================================================================
cleaner () {
    output ""
    outputc "bold" "--- CLEANER ---------------------------------------------------------"
    for cleaner in ${CLEANERS[@]}; do
        info "Calling cleaner $(quote $cleaner)"
        ${cleaner}  # Call cleaner
    done
}
