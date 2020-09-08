#!/bin/bash
# vim: set ts=4 sw=4 sts=4 et :

SCRIPTDIR="$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"
source "${SCRIPTDIR}/package-installer.sh"

RPMDIR="${RPMDIR:-"/rpm"}"
CONFDIR="/share"

#DEBUG=true
#DRYRUN=true
#DEBUGINFO=true

#-------------------------------------------------------------------------------
# COMPONENTS
#   List of components to install including optional version number.  If the
#   version number is omitted, it will automatically be determined.
#   Example:
#       core-vchan-libkvmchan
#       #core-vchan-libkvmchan==4.1.0-1
COMPONENTS=(
    #### QUBES-KVM-VM-DEPENDENCIES
    kvm
    core-vchan-libkvmchan
    core-vchan-kvm
    core-qubesdb
    core-qrexec

    core-agent-linux
    gui-agent-linux
    linux-gbulb                             # Required by: qubes-core-qrexec
    linux-utils

    #### QUBES-KVM-VM-RECOMMENDED
    app-linux-split-gpg
    app-linux-img-converter
    app-linux-pdf-converter
    app-linux-input-proxy
    mgmt-salt
    app-linux-usb-proxy
    app-thunderbird

    #### QUBES-KVM-VM-GUIVM
    gui-daemon
    core-admin-client
    artwork
    desktop-linux-common
    python-xcffib                           # Required by: core-admin-client, ++

    #### BUILT, BUT UNINSTALLED PACKAGES
    ##python-cffi                           # debian-jessie only
    #python-quamash
    #python-objgraph
    ##python-hid                            # debian
    #python-u2flib-host
    #python-qasync
    #linux-kernel                           # Currently only Dom0
    #gui-common
    #app-linux-snapd-helper
    #app-shutdown-idle
    #app-u2f
    #mgmt-salt-base
    #mgmt-salt-base-topd
    #mgmt-salt-base-config
    ##meta-packages                         # XEN ONLY
    #manager
    #desktop-linux-kde
    #desktop-linux-xfce4
    #desktop-linux-xfce4-xfwm4
    #desktop-linux-i3
    #desktop-linux-i3-settings-qubes
    #desktop-linux-awesome
    #grubby-dummy
    #linux-scrypt
)


# --- QUBES-KVM-VM-DEPENDENCIES ------------------------------------------------
kvm=(
    qubes-kvm-vm                            # REQUIRED
    qubes-kvm-vm-config                     # REQUIRED
#   qubes-kvm-vm-guivm
    #qubes-kvm-vm-dependencies
    #qubes-kvm-vm-recommended
)
core_vchan_libkvmchan=(
    libkvmchan-vm                           # REQUIRED
    libkvmchan                              # REQUIRED DEPEND
    libkvmchan-libs                         # REQUIRED DEPEND
    #libkvmchan-devel
)
core_vchan_kvm=(
    qubes-libvchan-kvm                      # REQUIRED
    #qubes-libvchan-kvm-devel
)
core_agent_linux=(
    ### Requires: qubes-utils (linux-utils)
    ###           qubes-utils-libs (linux-utils)
    ###           python3-qubesdb (core-qubesdb)
    ###           qubes-core-qrexec-vm (core-qrexec)
    ###           qubes-libvchan (core-vchan-kvm)
    ###           qubes-db-vm (core-qubesdb)
    ###           python3-dnf-plugins-qubes-hooks (core-agent-linux)
    qubes-core-agent                        # REQUIRED
    qubes-core-agent-systemd                # REQUIRED
    qubes-core-agent-dom0-updates           # RECOMMENDED
    qubes-core-agent-nautilus               # RECOMMENDED
    qubes-core-agent-networking             # RECOMMENDED
    qubes-core-agent-network-manager        # RECOMMENDED
    qubes-core-agent-passwordless-root      # RECOMMENDED
    python3-dnf-plugins-qubes-hooks
    #qubes-core-agent-thunar
    #python2-dnf-plugins-qubes-hooks
    #qubes-core-agent-sysvinit
)
gui_agent_linux=(
    qubes-gui-agent                         # REQUIRED
    pulseaudio-qubes                        # RECOMMENDED
    #qubes-gui-agent-xfce
)

# --- REQUIRED DEPENDENCIES ----------------------------------------------------
core_qubesdb=(
    ### Requires: qubes-libvchan-kvm
    ### Required by: gui-agent, gui-daemon
    qubes-db-vm
    qubes-db
    qubes-db-libs
    python3-qubesdb
    #qubes-db-devel
)
core_qrexec=(
    ### Requires: python3-gbulb
    ### Required by: core-agent-linux, gui-daemon
    qubes-core-qrexec-vm
    qubes-core-qrexec
    qubes-core-qrexec-libs
    #qubes-core-qrexec-devel
)
linux_utils=(
    ### Requires: python3-qubesimgconverter
    ### Required by: qubes-core-agent, gui-daemon, app-linux-img-converter
    qubes-utils
    qubes-utils-libs
    python3-qubesimgconverter
    qubes-kernel-vm-support
    #qubes-utils-devel
)
linux_gbulb=(
    ### Required by: qubes-core-qrexec
    python3-gbulb
)

# --- QUBES-KVM-VM-RECOMMENDED -------------------------------------------------
app_linux_split_gpg=(
    qubes-gpg-split                         # RECOMMENDED
    #qubes-gpg-split-tests
)
app_linux_img_converter=(
    ### Requires: qubes-utils, python3-qubesimgconverter
    qubes-img-converter                     # RECOMMENDED
)
app_linux_pdf_converter=(
    qubes-pdf-converter                     # RECOMMENDED
)
app_linux_input_proxy=(
    qubes-input-proxy-sender                # RECOMMENDED
    #qubes-input-proxy
)
mgmt_salt=(
    qubes-mgmt-salt-vm-connector            # RECOMMENDED
    #qubes-mgmt-salt
    #qubes-mgmt-salt-admin-tools
    #qubes-mgmt-salt-config
    #qubes-mgmt-salt-shared-formulas
    #qubes-mgmt-salt-vm
    #qubes-mgmt-salt-vm-formulas
)
app_linux_usb_proxy=(
    qubes-usb-proxy                         # RECOMMENDED
)
app_thunderbird=(
    thunderbird-qubes                       # RECOMMENDED
)

# --- QUBES-KVM-VM-GUIVM -------------------------------------------------------
gui_daemon=(
    ### Requires: qubes-libvchan-kvm
    ###           python3-xcffib
    ###           qubes-utils
    ###           qubes-core-qrexec
    ###           python3-qubesimgconverter
    qubes-gui-daemon                        # REQUIRED
    #qubes-audio-daemon
    ##qubes-gui-dom0
    ##qubes-audio-dom0
)
core_admin_client=(
    ### Requires: python3-qubesadmin, python3-xcffib
    qubes-core-admin-client                 # REQUIRED
    python3-qubesadmin
)
artwork=(
    qubes-artwork                           # REQUIRED
    ##qubes-artwork-anaconda
    ##qubes-artwork-efi
    ##qubes-artwork-plymouth
)
desktop_linux_common=(
    ### NOTE: Requires are for qubes-desktop-linus-common, not qubes-menus
    ### Requires: python3-qubesimgconverter
    ###           python3-qubesadmin
    ###           qubes-manager
    #qubes-desktop-linux-common
    qubes-menus                             # REQUIRED
)
#python_xcffib=(
#    # Required by: qubes-gui-daemon, core-admin-client
#)

# --- BUILT, BUT NOT INSTALLED PACKAGES ----------------------------------------
#python_cffi=(
#    # NOTE: debian-jessie only
#)
python_quamash=(
    python3-Quamash
)
python_objgraph=(
    python3-objgraph
    python-objgraph-doc
)
#python_hid=(
#    # NOTE: debian?
#)
python_u2flib_host=(
    python3-u2flib-host
)
python_qasync=(
    python3-qasync
)
#linux_kernel=(
#    # NOTE: Currently only Dom0
#)
gui_common=(
    qubes-gui-common-devel
)
app_linux_snapd_helper=(
    qubes-snapd-helper
)
app_shutdown_idle=(
    qubes-idle
)
app_u2f=(
    qubes-u2f
)
mgmt_salt_base=(
    qubes-mgmt-salt-base
)
mgmt_salt_base_topd=(
    qubes-mgmt-salt-base-topd
)
mgmt_salt_base_config=(
    qubes-mgmt-salt-base-config
)
#### XEN ONLY
##meta_packages=(
##    qubes-vm-dependencies
##    qubes-vm-guivm
##    qubes-vm-meta-packages
##    qubes-vm-recommended
##    qubes-repo-contrib
##)
manager=(
    qubes-manager
)
desktop_linux_kde=(
    kde-settings-qubes
    plasma-breeze-qubes
)
desktop_linux_xfce4=(
    xfce4-settings-qubes
)
desktop_linux_xfce4_xfwm4=(
    xfwm4
)
desktop_linux_i3=(
    i3
    i3-doc
    #i3-devel
    #i3-devel-doc
)
desktop_linux_i3_settings_qubes=(
    i3-settings-qubes
)
desktop_linux_awesome=(
    awesome
    awesome-doc
)
grubby_dummy=(
    grubby-dummy
)
linux_scrypt=(
    scrypt
)


################################################################################
# Call `install_packages` if this file was not 'sourced'
(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0
if (( ! SOURCED )); then
    install_packages "$RPMDIR" COMPONENTS "${@}"
fi
