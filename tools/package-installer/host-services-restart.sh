#!/bin/bash

SCRIPTDIR="$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"
source "${SCRIPTDIR}/host-services-stop.sh"
source "${SCRIPTDIR}/host-services-status.sh"


services_restart() {
    ### Stop all Qubes related running serivces
    ##sudo systemctl stop kvmchand-host.service
    ##sudo systemctl stop qubes-db-dom0.service
    ##sudo systemctl stop qubesd.service
    ##sudo systemctl stop qubes-qrexec-policy-daemon.service
    ####sudo systemctl stop qubes-qmemman.service
    ##sudo systemctl stop qubes-core.service

    ### Cleanup
    ##sudo rm -f /var/run/qubesd.*
    ##sudo rm -f /var/run/qubes/policy.sock
    ##sudo rm -f /var/run/qubes/qubesdb.*
    ##sudo rm -f /var/run/qubes/qrexec.*
    ##sudo rm -f /tmp/kvmchand/ivshmem_socket=
    ##sudo rm -f /tmp/kvmchand/localhandler_socket=

    # Stop all Qubes related running serivces
    services_stop

    # Start all Qubes related serivces
    sudo systemctl start kvmchand-host.service
    sudo systemctl start qubes-db-dom0.service
    sudo systemctl start qubesd.service
    sudo systemctl start qubes-qrexec-policy-daemon.service
    sudo systemctl start qubes-core.service

    # Confirm running active status of all Qubes related serivces
    services_status

    ### Confirm running active status of all Qubes related serivces
    ##sudo systemctl status kvmchand-host.service --no-pager
    ##sudo systemctl status qubes-db-dom0.service --no-pager
    ##sudo systemctl status qubesd.service --no-pager
    ##sudo systemctl status qubes-qrexec-policy-daemon.service --no-pager
    ####sudo systemctl status qubes-qmemman.service --no-pager
    ##sudo systemctl status qubes-core.service --no-pager
}

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0
if (( ! SOURCED )); then
    services_restart
fi

