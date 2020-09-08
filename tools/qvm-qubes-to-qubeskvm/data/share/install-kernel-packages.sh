#!/bin/bash
# vim: set ts=4 sw=4 sts=4 et :

SCRIPTDIR="$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"
source "${SCRIPTDIR}/package-installer.sh"

RPMDIR="${RPMDIR:-"/rpm"}"
CONFDIR="/share"

##DEBUG=true
##DRYRUN=true
##DEBUGINFO=true
INSTALL_MODES=('install')

COMPONENTS=(linux-kernel)
linux_kernel=(
    kernel
    kernel-core
    kernel-modules
    kernel-modules-extra
    kernel-devel
)

################################################################################
# Call `install_packages` if this file was not 'sourced'
(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0
if (( ! SOURCED )); then
    install_packages "$RPMDIR" COMPONENTS "${@}"
fi
