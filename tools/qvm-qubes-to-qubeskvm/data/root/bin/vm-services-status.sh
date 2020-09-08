#!/bin/bash
# vim: set ts=4 sw=4 sts=4 et :

##qubes-test.service
##qubes-test.service.d-30_qubes-kvm.conf.in
##qubes-db.service.d/_qubes-kvm.conf
##qubes-misc-post.service.d/_qubes-kvm.conf
##qubes-mount-dirs.service.d/_qubes-kvm.conf
##qubes-qrexec-agent.service.d/_qubes-kvm.conf
##qubes-rootfs-resize.service.d/qubes-kvm.conf
##qubes-sysinit.service.d/qubes-kvm.conf
##qubes-test.service.in/_qubes-kvm.conf.in

                                                # enabled  |  vendor  | active  | other-vm
services=(
    kvmchand.service                            # enabled  | disabled | active
    qubes-db.service                            # enabled  | enabled  | active
    qubes-early-vm-config.service               # enabled  | enabled  | active
    qubes-firewall.service                      # disabled | enabled  | dead    | vendor=disabled
    qubes-gui-agent.service                     # disabled | enabled  | dead    | enabled, vendor=disabled, ACTIVE
    qubes-iptables.service                      # disabled | enabled  | dead    | vendor=disabled
    qubes-misc-post.service                     # enabled  | enabled  | active
    qubes-mount-dirs.service                    # enabled  | enabled  | FAILED
    qubes-network.service                       # disabled | enabled  | dead    | vendor=disabled
    qubes-qrexec-agent.service                  # enabled  | enabled  | active
    qubes-rootfs-resize.service                 # enabled  | enabled  | FAILED
    qubes-sync-time.service                     # enabled  | enabled  | active
    qubes-sync-time.timer                       # enabled  | enabled  | active
    qubes-sysinit.service                       # enabled  | enabled  | FAILED
    qubes-update-check.service                  # static   | disabled | dead
    qubes-update-check.timer                    # enabled  | enabled  | CON-FAIL
    qubes-updates-proxy-forwarder.socket        # disabled | enabled  | dead    | vendor=disabled
    qubes-updates-proxy.service                 # disabled | enabled  | dead    | vendor=disabled

    qubes-hypervisor.service                    # enabled  | disabled | inactive| NOT FOUND
    qubes-test.service                          # generated           | dead    | NOT FOUND

##  qubes-updates-proxy-forwarder@.service      # enabled  | enabled  | active
##  qubes-input-sender-keyboard-mouse@.service  # enabled  | enabled  | active
##  qubes-input-sender-keyboard@.service        # enabled  | enabled  | active
##  qubes-input-sender-mouse@.service           # enabled  | enabled  | active
##  qubes-input-sender-tablet@.service          # enabled  | enabled  | active
)

for service in "${services[@]}"; do
    echo ""
    sudo systemctl status "$service" --no-pager
done

