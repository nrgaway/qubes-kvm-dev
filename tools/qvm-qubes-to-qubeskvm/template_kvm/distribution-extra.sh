#!/bin/bash
# vim: set ts=4 sw=4 sts=4 et :


resolv () {
    local mode="$1"
    local chroot_resolv="${INSTALLDIR}/etc/resolv.conf"
    local chroot_resolv_orig="${INSTALLDIR}/etc/resolv.conf.orig"

    # Set chroot 'resolv.conf' to host '/etc/resolv.conf' to enable network
    if [ $mode == "set" ]; then
        if [ ! -f "$chroot_resolv_orig" ]; then
            mv "$chroot_resolv" "$chroot_resolv_orig"
            cp /etc/resolv.conf "$chroot_resolv"
        fi

    # Restore chroot '/etc/resolv.conf'
    else
        if [ -f "$chroot_resolv_orig" ]; then
            rm -f "$chroot_resolv"
            mv "$chroot_resolv_orig" "$chroot_resolv"
        fi
    fi
}


mount_dev () {
    local mode=${1:-mount}
    local mounted

    mountpoint "${INSTALLDIR}/dev" >/dev/null && mounted=1 || mounted=0
    if [ $mode == mount ]; then
        if (( ! mounted )); then
            echo "Mounting /dev..."
            chroot "${INSTALLDIR}" mount -t devtmpfs none /dev
        fi
    else
        if (( mounted )); then
            echo "Un-mounting /dev..."
            sync
            chroot "${INSTALLDIR}" umount /dev
        fi
    fi
}
umount_dev () { mount_dev umount; }


mount_proc () {
    local mode=${1:-mount}
    local mounted

    mountpoint "${INSTALLDIR}/proc" >/dev/null && mounted=1 || mounted=0
    if [ $mode == mount ]; then
        if (( ! mounted )); then
            echo "Mounting /proc..."
            mount -t proc proc "${INSTALLDIR}/proc"
        fi
    else
        if (( mounted )); then
            echo "Un-mounting /proc..."
            sync
            chroot "${INSTALLDIR}" umount /proc
        fi
    fi
}
umount_proc () { mount_proc umount; }


mount_sys () {
    local mode=${1:-mount}
    local mounted

    mountpoint "${INSTALLDIR}/sys" >/dev/null && mounted=1 || mounted=0
    if [ $mode == mount ]; then
        if (( ! mounted )); then
            echo "Mounting /sys..."
            chroot "${INSTALLDIR}" mount -t sysfs sys /sys
        fi
    else
        if (( mounted )); then
            echo "Un-mounting /sys..."
            sync
            chroot "${INSTALLDIR}" umount /sys
        fi
    fi
}
umount_sys () { mount_sys umount; }

