#!/bin/sh

# TODO:
#   - MAYBE RENAME THIS SCRIPT and call hypervisor.sh


hypervisor_info_path="/var/run/qubes-service/hypervisor"


# Hypervisor name not set
if [ ! -f "$hypervisor_info_path" ]; then
    # Need to create the 'qubes-service' directory early since it is normally
    # created by '/usr/lib/qubes/init/qubes-sysinit.sh' executed from the
    # qubes-sysinit.service after being notified qubes-db.service has been
    # started, and the qubes-db.service starts after the kvmchand.service.
    mkdir -p /var/run/qubes-service

    # Use systemd to detect hypervisor
    if "$(which systemd-detect-virt 2>/dev/null)"; then
        hypervisor_name="$(systemd-detect-virt --vm)"
    elif [[ $(cat /sys/hypervisor/type 2>/dev/null) == 'xen' ]]; then
        hypervisor_name="xen"
    elif [ -e /sys/devices/virtual/misc/kvm ]; then
        hypervisor_name="kvm"
    fi

    if [ ! -z $hypervisor_name ]; then
        echo "$hypervisor_name" > "$hypervisor_info_path"
        touch "${hypervisor_info_path}-${hypervisor_name}"
        ##systemd-notify --status="Sleeping for 10 seconds"
        ##sleep 10
        systemd-notify --ready --status="Detected ${hypervisor_name} hypervisor"
    fi
else
    hypervisor_name="$(cat "$hypervisor_info_path")"
fi


# Return hypervisor name or match result if 'name' provided
hypervisor () {
    local name="$1"

    if [ ! -z $hypervisor_name ]; then
        if [ -z "$name" ]; then
            echo "$hypervisor_name"
            exit 0
        fi
        if [ "$name" == "$hypervisor_name" ]; then
            exit 0
        fi
    fi
    exit 1
}


(return 0 2>/dev/null) && sourced=1 || sourced=0
if (( ! sourced )); then
    hypervisor "$1"
fi

