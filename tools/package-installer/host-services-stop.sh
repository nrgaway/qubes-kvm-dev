#!/bin/bash


services_stop() {
    # Stop all Qubes related running serivces
    sudo systemctl stop kvmchand-host.service
    sudo systemctl stop qubes-db-dom0.service
    sudo systemctl stop qubesd.service
    sudo systemctl stop qubes-qrexec-policy-daemon.service
    ##sudo systemctl stop qubes-qmemman.service
    sudo systemctl stop qubes-core.service

    # Cleanup
    sudo rm -f /var/run/qubesd.*
    sudo rm -f /var/run/qubes/policy.sock
    sudo rm -f /var/run/qubes/qubesdb.*
    sudo rm -f /var/run/qubes/qrexec.*
    sudo rm -f /tmp/kvmchand/ivshmem_socket=
    sudo rm -f /tmp/kvmchand/localhandler_socket=

    # Only kill widget-wrapper if this script was called directly
    if (( ! SOURCED )); then
        sudo killall widget-wrapper
    fi
}

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0
if (( ! SOURCED )); then
    services_stop
fi

