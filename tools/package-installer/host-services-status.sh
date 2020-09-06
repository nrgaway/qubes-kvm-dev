#!/bin/bash

services_status() {
    # Confirm running active status of all Qubes related serivces
    sudo systemctl status kvmchand-host.service --no-pager
    sudo systemctl status qubes-db-dom0.service --no-pager
    sudo systemctl status qubesd.service --no-pager
    sudo systemctl status qubes-qrexec-policy-daemon.service --no-pager
    ##sudo systemctl status qubes-qmemman.service --no-pager
    sudo systemctl status qubes-core.service --no-pager
}

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0
if (( ! SOURCED )); then
    services_status
fi

