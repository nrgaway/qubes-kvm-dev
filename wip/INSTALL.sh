#!/bin/bash
# vim: set ts=4 sw=4 sts=4 et :
declare -ir false=0 true=1
DEBUG=false
DRYRUN=false
#DEBUG=true
#DRYRUN=true


# COMPONENTS
#   List of components to install including version number.  If the version
#   number is omitted, the distribution version will be installed.
#   Example:
#       LIBVIRT=
#       #LIBVIRT=6.4.0-1
COMPONENTS=(
#    core_libvirt=6.4.0-1
    vmm_xen=4.13.1-4
#    libkvmchan=4.1.0-1
#    core_vchan_kvm=4.1.0-1
#    core_qubesdb=4.1.7-1
    core_qrexec=4.1.8-1
    linux_utils=4.1.10-1
    #python_cffi=
    #python_xcffib=
    python_quamash=0.6.1-1
    #python_objgraph=
    #python_hid=
    #python_u2flib_host=
    #python_qasync=
    core_admin=4.1.14-1
    core_admin_client=4.1.7-1
    core_admin_addon_whonix=4.0.2-1
    core_admin_linux=4.1.6-1
    #core_agent_linux=
    ####intel_microcode=
    ####linux_firmware=
    #linux_kernel=
    artwork=4.1.7-1
    #grub2=
    #grub2_theme=
    #gui_common=
    gui_daemon=4.1.7-1
    #gui_agent_linux=
    ####gui_agent_xen_hvm_stubdom=
    ####seabios=
    ####vmm_xen_stubdom_legacy=
    ####vmm_xen_stubdom-linux=
    app_linux_split_gpg=2.0.47-1
    #app_thunderbird=
    #app_linux_pdf_converter=
    app_linux_img_converter=1.2.9-1
    app_linux_input_proxy=1.0.18-1
    app_linux_usb_proxy=1.0.28-1
    #app_linux_snapd_helper=
    #app_shutdown_idle=
    #app_yubikey=
    #app_u2f=
    mgmt_salt=4.1.7-1
    mgmt_salt_base=4.1.2-1
    mgmt_salt_base_topd=4.1.1-1
    mgmt_salt_base_config=4.1.0-1
    mgmt_salt_dom0_qvm=4.1.3-1
    mgmt_salt_dom0_virtual_machines=4.1.5-1
    mgmt_salt_dom0_update=4.1.3-1
    ####infrastructure=
    ####meta_packages=
    manager=4.1.10-1
    desktop_linux_common=4.1.3-1
    #desktop_linux_kde=
##  desktop_linux_xfce4=4.0.3-2
##  desktop_linux_xfce4_xfwm4=4.14.2-1
    #desktop_linux_i3=
    #desktop_linux_i3_settings_qubes=
    #desktop_linux_awesome=
    desktop_linux_manager=4.1.5-1
    #grubby_dummy=
    #linux_pvgrub2=
    linux_gbulb=0.6.1-1
    linux_scrypt=1.2.1-3
    #linux_template_builder=
    ####installer_qubes_os=
    ####qubes_release=
    ####pykickstart=
    ####blivet=
    ####lorax=
    ####lorax_templates=
    ####pungi=
    ####anaconda=
    ####anaconda_addon=
    ####linux_yum=
    ####linux_deb=
    ####tpm_extra=
    ####trousers_changer=
    ####antievilmaid=
)

RPMDIR="qubes-packages-mirror-repo/dom0-fc32/rpm"

vmm_xen=(
    xen
    xen-hypervisor
    xen-libs
    xen-licenses
    xen-runtime
    python3-xen
)
core_libvirt=(
    libvirt-bash-completion
    libvirt-client
    libvirt-daemon
    libvirt-daemon-config-network
    libvirt-daemon-driver-interface
    libvirt-daemon-driver-libxl
    libvirt-daemon-driver-network
    libvirt-daemon-driver-nodedev
    libvirt-daemon-driver-nwfilter
    libvirt-daemon-driver-qemu
    libvirt-daemon-driver-secret
    libvirt-daemon-driver-storage
    libvirt-daemon-driver-storage-core
    libvirt-daemon-driver-storage-disk
    libvirt-daemon-driver-storage-gluster
    libvirt-daemon-driver-storage-iscsi
    libvirt-daemon-driver-storage-iscsi-direct
    libvirt-daemon-driver-storage-logical
    libvirt-daemon-driver-storage-mpath
    libvirt-daemon-driver-storage-rbd
    libvirt-daemon-driver-storage-scsi
    libvirt-daemon-driver-storage-sheepdog
    libvirt-daemon-driver-storage-zfs
    libvirt-daemon-kvm
    #libvirt-daemon-qemu
    libvirt-daemon-xen
    libvirt-libs
    python3-libvirt
    # UNUSED:
    #libvirt
    #libvirt-admin
    #libvirt-daemon-config-nwfilter
    #libvirt-devel
    #libvirt-docs
)
### Additional depends installed when installing libvirt packages.  Adding the
### 'qemu' config options within libvirt spec added both 'libvirt-daemon-qemu' and
### 'libvirt-daemon-driver-qemu' packages which is likely what triggered the deps.
###
### NOTE:  Just dont install 'libvirt-daemon-qemu' to prevent depends install.
##LIBVIRT_DEPENDS=(
##    SLOF
##    edk2-aarch64
##    openbios
##    qemu
##    qemu-system-aarch64
##    qemu-system-aarch64-core
##    qemu-system-alpha
##    qemu-system-alpha-core
##    qemu-system-arm
##    qemu-system-arm-core
##    qemu-system-cris
##    qemu-system-cris-core
##    qemu-system-lm32
##    qemu-system-lm32-core
##    qemu-system-m68k
##    qemu-system-m68k-core
##    qemu-system-microblaze
##    qemu-system-microblaze-core
##    qemu-system-mips
##    qemu-system-mips-core
##    qemu-system-moxie
##    qemu-system-moxie-core
##    qemu-system-nios2
##    qemu-system-nios2-core
##    qemu-system-or1k
##    qemu-system-or1k-core
##    qemu-system-ppc
##    qemu-system-ppc-core
##    qemu-system-riscv
##    qemu-system-riscv-core
##    qemu-system-s390x
##    qemu-system-s390x-core
##    qemu-system-sh4
##    qemu-system-sh4-core
##    qemu-system-sparc
##    qemu-system-sparc-core
##    qemu-system-tricore
##    qemu-system-tricore-core
##    qemu-system-unicore32
##    qemu-system-unicore32-core
##    qemu-system-xtensa
##    qemu-system-xtensa-core
##    qemu-user
##)
####vmm-xen=()
libkvmchan=( libkvmchan )
core_vchan_kvm=( qubes-libvchan-kvm )
core_qubesdb=(
    qubes-db
    qubes-db-dom0
    qubes-db-libs
    python3-qubesdb
)
core_qrexec=(
    qubes-core-qrexec
    qubes-core-qrexec-dom0
    qubes-core-qrexec-libs
)
linux_utils=(
    qubes-utils
    qubes-utils-libs
    python3-qubesimgconverter
)
#VM: python_cffi=()
#VM: python_xcffib=()
python_quamash=(
    python3-Quamash
)
#VM: python_objgraph=()
#VM: python_hid=()
#VM: python_u2flib_host=()
#VM: python_qasync=()
core_admin=(
    qubes-core-dom0
)
core_admin_client=(
    qubes-core-admin-client
    python3-qubesadmin
)
core_admin_addon_whonix=(
    qubes-core-admin-addon-whonix
)
core_admin_linux=(
    qubes-core-dom0-linux
    qubes-core-dom0-linux-kernel-install
)
#VM: core_agent_linux=()
####intel_microcode=()
####linux_firmware=()
#linux_kernel=()
artwork=(
    qubes-artwork
)
#grub2=()
#grub2_theme=()
#VM: gui_common=()
gui_daemon=(
    qubes-audio-daemon
    qubes-audio-dom0
    qubes-gui-daemon
    qubes-gui-dom0
)
#VM: gui_agent_linux=()
####gui_agent_xen_hvm_stubdom=()
####seabios=()
####vmm_xen_stubdom_legacy=()
####vmm_xen_stubdom_linux=()
app_linux_split_gpg=(
    qubes-gpg-split-dom0
)
#VM: app_thunderbird=()
#VM: app_linux_pdf_converter=()
app_linux_img_converter=(
    qubes-img-converter-dom0
)
app_linux_input_proxy=(
    qubes-input-proxy
)
app_linux_usb_proxy=(
    qubes-usb-proxy-dom0
)
#VM: app_linux_snapd_helper=()
#VM: app_shutdown_idle=()
#VM: app_yubikey=()
#VM: app_u2f=()
mgmt_salt=(
    qubes-mgmt-salt
    qubes-mgmt-salt-admin-tools
    qubes-mgmt-salt-config
    qubes-mgmt-salt-dom0
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
mgmt_salt_dom0_qvm=(
    qubes-mgmt-salt-dom0-qvm
)
mgmt_salt_dom0_virtual_machines=(
    qubes-mgmt-salt-dom0-virtual-machines
)
mgmt_salt_dom0_update=(
    qubes-mgmt-salt-dom0-update
)
####infrastructure=()
####meta_packages=()
manager=(
    qubes-manager
)
desktop_linux_common=(
    qubes-desktop-linux-common
    qubes-menus
)
#desktop_linux_kde=()
desktop_linux_xfce4=(
    xfce4-settings-qubes
)
desktop_linux_xfce4_xfwm4=(
    xfwm4
)
#desktop_linux_i3=()
#desktop_linux_i3_settings_qubes=()
#desktop_linux_awesome=()
desktop_linux_manager=(
    qubes-desktop-linux-manager
)
#grubby_dummy=()
#linux_pvgrub2=()
linux_gbulb=(
    python3-gbulb
)
linux_scrypt=(
    scrypt
)
#linux_template_builder=()
####installer_qubes_os=()
####qubes_release=()
####pykickstart=()
####blivet=()
####lorax=()
####lorax_templates=()
####pungi=()
####anaconda=()
####anaconda_addon=()
####linux_yum=()
####linux_deb=()
####tpm_extra=()
####trousers_changer=()
####antievilmaid=()


# ==============================================================================
# Format RPM package names
# ==============================================================================
function rpm_package() {
    local name="$1"
    local version="$2"
    local package="${name}-${version}"*".rpm"
    echo $package
}


# ==============================================================================
# Install RPM packages
# ==============================================================================
function install_packages() {
    mode="$1"
    shift 1 || shift $(($#))
    local packages=("${@}")

    #for package in "${packages[@]}"; do
    #    echo "$package"
    #done
    #echo "$mode"
    if (( DRYRUN )); then
        echo "DRYRUN enabled"
        echo sudo dnf "$mode" "${packages[@]}"
    else
        sudo dnf "$mode" "${packages[@]}"
    fi
}


# ==============================================================================
# Generate RPM package list
# ==============================================================================
pushd "${RPMDIR}" >/dev/null 2>&1
    packages=()
    for component in "${COMPONENTS[@]}"; do
        echo $component
        component_name="${component%%=*}"
        component_version="${component##*=}"
        if [ "$component_name" == "$component_version" ]; then
            component_version=""
        fi

        if (( DEBUG )); then
            echo "COMPONENT NAME:    $component_name"
            echo "COMPONENT VERSION: $component_version"
        fi

        declare -n component_packages="$component_name"
        for component_package in ${component_packages[@]}; do
            if (( DEBUG )); then
                echo "COMPONENT PACKAGE: $component_package"
            fi

            if [ ! -z $component_version ]; then
                package="$(rpm_package $component_package $component_version)"


                if [ ! -e "$package" ]; then
                    echo "ERROR: ${package@Q} does not exist!  Exiting..."
                    exit 1
                fi
            else
                package="$component_package"
            fi
            echo "$package"
            packages+=("$package")
        done
    done

    install_packages install "${packages[@]}"
    install_packages reinstall "${packages[@]}"

popd >/dev/null 2>&1

