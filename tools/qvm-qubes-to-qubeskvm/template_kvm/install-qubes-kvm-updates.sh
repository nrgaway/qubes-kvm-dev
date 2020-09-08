#!/bin/bash -e
# vim: set ts=4 sw=4 sts=4 et :

##SCRIPTSDIR="$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"
source "${SCRIPTSDIR}/distribution.sh"
source "${SCRIPTSDIR}/distribution-extra.sh"
source "${SCRIPTSDIR}/install-kernel"
DATADIR="${ROOTDIR}/data"


#### '----------------------------------------------------------------------
info ' Trap ERR and EXIT signals and cleanup (umount)'
#### '----------------------------------------------------------------------
trap cleanup ERR
trap cleanup EXIT

#### '----------------------------------------------------------------------
info " Install developer utilities and directories"
#### '----------------------------------------------------------------------
# Create developer directories
mkdir -p "${INSTALLDIR}/share"
mkdir -p "${INSTALLDIR}/rpm"  ## XXX:  TEMP:  Changing from 'rpm' to 'pkgs'
mkdir -p "${INSTALLDIR}/pkgs"

# Install extra developer utilities in root directory
mv "${INSTALLDIR}/root" "${INSTALLDIR}/root.orig"
cp -rp "${INSTALLDIR}/root.orig" "${INSTALLDIR}/root"
cp -rpf "${DATADIR}/root/." "${INSTALLDIR}/root"
chown -R root:root "${INSTALLDIR}/root"


#### '----------------------------------------------------------------------
info " Reinstall Qubes packages"
#### '----------------------------------------------------------------------
# Set chroot 'resolv.conf' to host '/etc/resolv.conf' to enable network
resolv 'set'

# Disable Qubes repos and update
sed -i -e "s/enabled=1/enabled=0/" "${INSTALLDIR}/etc/yum.repos.d/qubes-r4.repo"
chroot "${INSTALLDIR}" dnf update -y

mount --bind "${DATADIR}/share" "${INSTALLDIR}/share"
mount --bind "${PACKAGEDIR}" "${INSTALLDIR}/pkgs"

echo "PACKAGEDIR: $PACKAGEDIR"
ls -l "${INSTALLDIR}/pkgs"

chroot "${INSTALLDIR}" sh -c "cd /share; RPMDIR=/pkgs ./install-vm-packages.sh"
##chroot "${INSTALLDIR}" sh -c "cd /share; RPMDIR=/pkgs ./install-vm-packages.sh core-vchan-libkvmchan core-qubesdb core-qrexec"

sync
umount "${INSTALLDIR}/share"
umount "${INSTALLDIR}/pkgs"

# Restore chroot '/etc/resolv.conf'
resolv 'unset'

# Disable Qubes repos again; package update may have re-enabled it
sed -i -e "s/enabled=1/enabled=0/" "${INSTALLDIR}/etc/yum.repos.d/qubes-r4.repo"


#### '----------------------------------------------------------------------
info " TEMP HACKS"
#### '----------------------------------------------------------------------
# TEMP HACK: Disable TemplateVM dnf.conf override preventing network access
cp "${DATADIR}/usr.lib.qubes.init.qubes-sysinit.sh" "${INSTALLDIR}/usr/lib/qubes/init/qubes-sysinit.sh"

# TEMP HACK:  Allows network access
# Removes condition: ConditionPathExists=/var/run/qubes-service/network-manager
# Removes pre-start: ExecStartPre=/usr/lib/qubes/network-manager-prepare-conf-dir
cp "${DATADIR}/lib.systemd.system.NetworkManager.service.d.30_qubes.conf" "${INSTALLDIR}/usr/lib/systemd/system/NetworkManager.service.d/30_qubes.conf"

# TEMP: Hypervisor script missing
cp "${DATADIR}/usr.lib.qubes.hypervisor.sh" "${INSTALLDIR}/usr/lib/qubes/hypervisor.sh"

# Softlink KVM modified files from selected directories within chroot root dir
if [ -e "${INSTALLDIR}/root/bin/link-matched" ]; then
    mount_proc; mount_sys; mount_dev
    chroot "${INSTALLDIR}" sh -c "cd /root; ./bin/link-matched"
    umount_dev; umount_sys; umount_proc
fi

# Enable console access
chroot "${INSTALLDIR}" systemctl enable serial-getty@ttyS0.service


#### '----------------------------------------------------------------------
info " Cloning EFI partition"
#### '----------------------------------------------------------------------
target_efi="${INSTALLDIR}/boot/efi"
source_efi="${SOURCEDIR}/efi"
if [ ! -d "${source_efi}" ]; then
    source_efi="${DATADIR}/boot.efi"
fi
rsync -aP --delete "${source_efi}/" "${target_efi}" || true


#### '----------------------------------------------------------------------
info " Update config"
#### '----------------------------------------------------------------------
mv "${INSTALLDIR}/etc/fstab" "${INSTALLDIR}/etc/fstab.orig" || true
cp "${DATADIR}/etc.fstab" "${INSTALLDIR}/etc/fstab"
chown root:root "${INSTALLDIR}/etc/fstab"
chmod 644 "${INSTALLDIR}/etc/fstab"


#### '----------------------------------------------------------------------
info " Install custom kernel"
#### '----------------------------------------------------------------------
install_kernel "${DIST}"


#### '----------------------------------------------------------------------
info " Update grub"
#### '----------------------------------------------------------------------
mv "${INSTALLDIR}/etc/default/grub" "${INSTALLDIR}/etc/default/grub.orig" || true
cp "${DATADIR}/etc.default.grub-fedora" "${INSTALLDIR}/etc/default/grub"
rm -f "${INSTALLDIR}/etc/grub2-efi.cfg"
chroot ${INSTALLDIR} ln -s /boot/efi/EFI/qubes/grub.cfg /etc/grub2-efi.cfg

mount_proc; mount_sys; mount_dev
chroot "${INSTALLDIR}" grub2-mkconfig -o /etc/grub2.cfg || RETCODE=1
chroot "${INSTALLDIR}" grub2-mkconfig -o /etc/grub2-efi.cfg || RETCODE=1
umount_dev; umount_sys; umount_proc


#### '----------------------------------------------------------------------
info ' Cleanup'
#### '----------------------------------------------------------------------
trap - ERR EXIT
trap
