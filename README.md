# Manual post installation (to be automated)

The following documentation is primarily for developers wishing to work or test adapting the Qubes code base for use with the KVM hypervisor.

All the Qubes packages build and template will start using `qvm-start` but there is still a long way to go before everything is fully functional.  Some manual configuration of the host and virtual machine template has to be performed.

This document will be updated periodically to include missing tasks.

At this point only Fedora 32 hosts and guest virtual machines are supported as packaging has not been completed for Debian, Ubuntu, or Arch.

**IMPORTANT NOTE:**

All current development is being tested on a Fedora 32 host with a BTRFS file-system being used for the Qubes storage which is located within the '/var/lib/qubes' directories.  All instructions are based on the storage backing being BTRFS and not LVM.  It's just easier to replace images for testing using BTRFS.  A separate BTRFS file-system can be created on an additional disk or partition or even as a large file and mounted to '/var/lib/qubes'.  Hey, but don't worry, LVM will work as things progress (most likely works now so give it a try if that's what you prefer).

#### Whats working

-   All installed Qubes host services install and run.  Logs will contain errors in relation to *Dom0* not being present as the original implementation of Qubes expected *Dom0* as a virtual machine.  These issues will be handled as required when implementing other features.
-   Qubes templates build and install with manual intervention.
-   Qubes virtual machines can be started with `qvm-start` and *libvirt* XML configurations are created on-the-fly.
-   Console access to virtual machines.
-   The `qubes-db` host-vm services communicates and provides expected responses to read operations within VM.
-   The `qrexec` host-vm services *sort-of* work.  Currently attempting to resolve any issues.
-   Qubes manager *kind of* works :)

#### Whats not working - Tasks to be completed next

This is a short list of known items that are currently not implemented which is be all means not complete.  Items will be added as discovered and removed once implemented.  All items listed are the tasks to be competed next.

-   There is no GUI access for templates build with Qubes builder.  Will need to install a desktop manager.
-   Qubes seamless GUI has not been implemented.
-   Qubes networking implementation (`sys-net`, `sys-firewall`) has not yet been implemented.  Currently networking is provided using *libvirt* from the host.

## VIRTUAL MACHINE

### WIP
-   GUI - INSTALL DESKTOP

    `$ sudo dnf groupinstall -y "Xfce Desktop"`


### NOTES

#### Updates
Prevent custom kernel with VFIO_NOIOMMU module included from updating.

```bash
$ sudo dnf update --exclude=kernel*
```



### TEMPLATE INSTALLATION FROM HOST

==**NOTE: TEMPLATE INSTALLATION FROM RPM HAS NOT BEEN TESTED RECENTLY**==

##### IMPORTANT

Ensure all host post-installation steps performed and reboot before attempting to install virtual machine template.

If template installation fails, first ensure all host related installation and configuration has been completed, and that all the host services are running except `qubes-qmemman.service` which should be disabled.  Most log errors can be ignored so long as the services started and listed as active.

```bash
$ sudo systemctl status kvmchand-host.service
$ sudo systemctl status qubes-db-dom0.service
$ sudo systemctl status qubesd.service  # Will have errors related to Dom0, that's okay
$ sudo systemctl status qubes-qrexec-policy-daemon.service
$ sudo systemctl status qubes-qmemman.service  # Should be disabled
$ sudo systemctl status qubes-core.service
```

#### Install template from rpm built with Qubes builder for KVM.

Example:

```bash
$ sudo dnf install qubes-template-fedora-32-4.0.1.noarch.rpm
```

If installation of template is successful, proceed to the TEMPLATE PREPARATION section below.

If the RPM installation script fails, be sure all host installation and configuration is complete.  Check to see if the root image extracted within the '/var/lib/qubes/vm-templates/fedora-32' directory.

##### Manually extract `root.img` image

If the `root.img` failed to extract, manually extract it `cat root.img.* > root.img` then check permissions.  

`-rw------- 1 root qubes 10737418240 Aug 21 18:08  root.img`

##### Manually running RPM script post installation step

You can then attempt running the script run during RPM post installation.

```bash
$ echo -ne ok | qubesd-query -c /var/run/qubesd.internal.sock dom0 internal.vm.volume.ImportEnd fedora-32 root
```

If running the post installation script also fails, backup, then update the '/var/lib/qubes/qubes.xml' file manually by adding the configuration for a template as provided below.

```xml
    <domain id="domain-1" class="TemplateVM">
      <properties>
        <property name="debug">True</property>
        <property name="installed_by_rpm">True</property>
        <property name="label">black</property>
        <property name="maxmem">0</property>
        
        <!-- 4G RAM -->
        <property name="memory">4000</property>
        <property name="name">fedora-32</property>
        <property name="qid">1</property>
        
        <!-- Create own "uuid" from shell using 'uuidgen' command -->        
        <property name="uuid">13921bd7-35aa-4c77-b7ac-eaa5eef27afd</property>

        <property name="virt_mode">hvm</property>
      </properties>
      <features/>
      <devices class="pci"/>
      <devices class="block"/>
      <devices class="usb"/>
      <tags>
        <tag name="created-by-dom0"/>
        <tag name="audiovm-dom0"/>
        <tag name="guivm-dom0"/>
      </tags>
      <volume-config>
        <volume name="root" pool="varlibqubes" vid="vm-templates/fedora-32/root" revisions_to_keep="1" rw="True" save_on_stop="True" size="10737418240"/>
        <volume name="private" pool="varlibqubes" vid="vm-templates/fedora-32/private" revisions_to_keep="0" rw="True" save_on_stop="True" size="2147483648"/>
        <volume name="volatile" pool="varlibqubes" vid="vm-templates/fedora-32/volatile" revisions_to_keep="1" rw="True" size="10737418240"/>
        <volume name="kernel" pool="linux-kernel" vid="5.6.16-1" revisions_to_keep="0"/>
      </volume-config>
    </domain>
```

#### Install template from image built with Qubes builder for KVM

Currently the Qubes builder for templates does not initialize and configure an `EFI` partition which is required for the Qubes-KVM implementation to be able to support additional features such as GPU pass-through and to be able to fully utilize the `Q35` machine with `OVMF`BIOS.

A conversion conversion utility is available with the `qubes-kvm-dev` [git repository](https://github.com/nrgaway/qubes-kvm-dev) located within the tools directory called `qvm-qubes-to-qubeskvm`.  It is a very basic conversion utility to covert either an image built with Qubes builder or raw image for a KVM virtual machine that copies data from the original image to one that can be used with Qubes-KVM.  It will create and configure missing `EFI`  partitions and add any missing configurations not yet incorporated into the Qubes template builder.

The primary purpose of the conversion utilities is to be able to be able to configure and test the templates without needing to modify code within the Qubes template builder.  It's much quicker than rebuilding a template for testing configuration changes.  When the template configurations seem complete, they will be added to the Qubes template builder but maintained for the conversion utility to allow converting raw KVM images.

==**TODO:**== Instructions on how to run

#### Install template from raw KVM image

Existing KVM virtual machine images  can be converted to the Qubes partition layout.  Currently most of the test development virtual machines are created using `virt-manager` generating a stock Fedora-32 image, then converted to the Qubes partition layout.

Only a raw image can be converted for use with Qubes.  Other containers such as `qcow` are not supported but can be converted to a raw image format with other tools such as `qemu-img`. It is expected the image will contain only one `root` partition and optionally an `EFI`, `boot` and `swap` partition.  Note if a `boot` partition is present, it must less than or equal to 1GB due to limited partition detection abilities of the conversion script.

The `EFI`, `boot` and `root` partitions are copied from the raw image maintaining partition and disk `UUID`.  An `EFI` and or `boot` partition will be automatically created if the original raw image did not contain one.  If a `boot` partition is created, the data from within the `root` boot directory is moved to the newly created partition.  A `private` image will also be created which will move the `home` and `/usr/local` directories to it.

Follow the same steps as listed in the "Install template from image built with Qubes builder for KVM" section above but set the `SOURCE_ROOT_IMG` location to the path of the raw image.

#### Set some sane preferences for VM

```bash
# Enable debug mode for template
$ qvm-prefs fedora-32 debug true

# Set virtual mode as 'hvm' (not 'pv' or 'pvh')
$ qvm-prefs fedora-32 virt_mode hvm

# Qubes networking VMs not yet implemented, so disable netvm
$ qvm-prefs fedora-32 netvm none
```

#### Starting virtual machine template

Once the template is installed, it's time to start up the guest virtual machine a complete any manual configurations required.  If you are lucky Qubes will start it.

`$ qvm-start fedora-32`

If there are errors preventing the guest virtual machine from starting it, it's mostly likely that further manual configuration is required within the guest VM.  Just be sure the host is properly configured.  The main host issues that would prevent VM from starting, assuming services are active, are permissions on the '/var/run/qubes' and /var/lib/qubes' directories.

#### Alternative startup method of virtual machine template

Can't start the VM with `qubes-start`?  No worries, just use `virsh` or `virt-manager`

Qubes may have already generated a libvirt XML configuration even though it did not start.  Just check to see if one exists in the libvirt directory:

`$ sudo ls /etc/libvirt/qemu/fedora-32.xml`

If the `fedora-32.xml` configuration exists, you skip to the next step, otherwise you can use the following libvirt XML configuration to start the virtual machine with `virsh` or `virt-manager`, just replace the existing XML within `virt-manager` configure section or from the command line with `sudo virsh edit fedora-32`.  Be warned though that this configuration will be overwritten the next  time you run `qvm-start fedora-32`.

==**TODO:**== ADD LIBVIRT XML CONFIGURATION

Before starting up the virtual machine template, you will need to copy both the `root.img`,`private.img` and `volatile.img` within the '/var/lib/qubes/vm-templates/fedora-32' directory to `dirty` images.  Qubes normally does this automatically, then backing up and replacing the originals with the dirty copy on shutdown (FYI: AppVM's don't replace the original root.img).  Below is a script you can place and run within the `Fedora-32` template directory.

**IMPORTANT**: Any changes made when starting the VM are saved to the dirty images.  Qubes will copy over the dirty images the next time you run `qvm-start fedora-32` and you will lose ALL changes if you do not replace the originals with the dirty images BEFORE running the `qvm-start fedora-32` command.  Running the script below also will take care of replacing the original images, so run it again after you power off the VM.

```bash
#!/bin/bash

# --- SYNC ORIGINAL IMAGES WITH CURRENT DIRTY IMAGES --------------------------- 
if [ -e "root-dirty.img" ]; then
    sudo cp -pf --reflink root-dirty.img root.img
fi
if [ -e "private-dirty.img" ]; then
    sudo cp -pf --reflink private-dirty.img private.img
fi

# --- REMOVE VOLATILE-DIRTY IMAGE ---------------------------------------------- 
sudo rm -f volatile-dirty.img

# --- UPDATE DIRTY IMAGES FROM ORIGINAL IMAGES --------------------------------- 
sudo cp -pf --reflink root.img root-dirty.img
sudo cp -pf --reflink private.img private-dirty.img
sudo truncate -s 10G volatile-dirty.img
sudo chown root:qubes volatile-dirty.img
sudo chmod 0600 volatile-dirty.img

# --- REMOVE ANY BACKUPS ------------------------------------------------------- 
sudo rm -f root.img.[0-9]*
```

#### Start virtual machine console

```bash
$ sudo virsh console fedora-32 --safe
# press <ENTER> a few times.
```



### TEMPLATE PREPARATION

#### /etc/defaut/grub
Add the following to '/etc/default/grub'

```
GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX rd.driver.pre=vfio-pci"
GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX console=ttyS0"
GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX audit=0"
```

Then update grub (Fedora)

```bash
$ sudo grub2-mkconfig -o /etc/grub2-efi.cfg
$ sudo grub2-mkconfig -o /etc/grub2.cfg.
```



#### Enable serial console

```bash
$ sudo systemctl enable serial-getty@ttyS0.service
symlink /etc/systemd/system/getty.target.wants/serial-getty@ttyS0.service → /usr/lib/systemd/system/serial-getty@.service

# Or just create symlink to enable serial console
ln -s /usr/lib/systemd/system/serial-getty@.service serial-getty@ttyS0.service
```



#### Confirm VFIO module loaded

```bash
$ ls -1d /sys/bus/pci/drivers/vfio-pci
/sys/bus/pci/drivers/vfio-pci
```



#### May need to update initramfs to include VFIO drivers.

```bash
$ sudo lsinitrd /boot/initramfs-$(uname -r).img | grep vfio
$ sudo dracut --force --add-drivers vfio-pci --kver $(uname -r)
```



#### Confirm ivshmem device exists in VM

Make sure the kernel you have installed supports the VFIO_NOIOMMU option. The one Fedora ships does not.

```bash
$ lspci
...
0001:00:00.0 RAM memory: Red Hat, Inc. Inter-VM shared memory (rev 01)
...
```



#### /ect/fstab

Ensure '/etc/fstab' has entries for `/dev/vd` not `/dev/xvd`.

```bash
/dev/mapper/dmroot  /                   ext4    defaults,discard,noatime 1 1
/dev/vda2           /boot               ext4    defaults 1 2
/dev/vda1           /boot/efi           vfat    umask=0077,shortname=winnt 0 2
/dev/vdb            /rw                 auto    noauto,defaults,discard,nosuid,nodev 1 2

#### TODO:  Enable swap
#/dev/vdc1          swap                swap    defaults 0 0

devpts              /dev/pts            devpts  gid=5,mode=620 0 0
proc                /proc               proc    defaults 0 0
sysfs               /sys                sysfs   defaults 0 0
tmpfs               /dev/shm            tmpfs   defaults,size=1G 0 0

#### MAKE SURE ITS COMMENTED OUT OR REMOVED
#xen                /proc/xen           xenfs   defaults 0 0

/rw/home            /home               none    noauto,bind,defaults,nosuid,nodev 0 0
/rw/usrlocal        /usr/local          none    noauto,bind,defaults 0 0
/dev/vdi            /mnt/removable      auto    noauto,user,rw 0 0

#### NOT REQUIRED:  DEVELOPER HOST SHARES
/rpm /rpm 9p  trans=virtio,version=9p2000.L,rw 0 0
/share /share 9p  trans=virtio,version=9p2000.L,rw 0 0
```



#### SYSTEMD

Check all systemd services to be sure none failed. You may need to disable (depending if feature enabled for the service) the following:

Services from `core-agent-linux`

```bash
$ sudo systemctl disable qubes-iptables.service
$ sudo systemctl disable qubes-network.service
$ sudo systemctl disable qubes-firewall.service
$ sudo systemctl disable qubes-updates-proxy.service
$ sudo systemctl disable qubes-updates-proxy-forwarder.socket
```

Services from `gui-agent-linux `

```bash
$ sudo systemctl disable qubes-gui-agent.service
```



#### /etc/dnf/dnf.conf

```bash
### QUBES BEGIN ###
# This part of configuration, until QUBES END, is automatically generated by
# /usr/lib/qubes/update-proxy-configs. All changes here will be overriden.
# If you want to override any option set here, set it again to desired value,
# below this section
proxy=http://127.0.0.1:8082/
### QUBES END ###
```



#### /etc/yum.repos.d/qubes-r4.repo

Disable Qubes repo in '/etc/yum.repos.d`

```
enabled=0
```



#### MISSING PACKAGES

```bash
passwd   # create 'user' password
```



#### BUILDING CUSTOM KERNEL WITHIN VIRTUAL MACHINE

```bash
# INSTALL DEPENDS
$ sudo dnf install fedpkg fedora-packager rpmdevtools ncurses-devel pesign grubby qt3-devel libXi-devel gcc-c++
$ sudo /usr/libexec/pesign/pesign-authorize

# CLONE FEDORA KERNEL REPO
$ fedpkg clone -a kernel
$ cd kernel
$ git checkout origin/f32
$ git branch f32
$ git checkout f32
$ sudo dnf builddep kernel.spec

# CONFIGURE
# Add VIFO modules to 'kernel-local'
kernel-local:
  CONFIG_VFIO=y
  CONFIG_VFIO_PCI=y
  CONFIG_VFIO_NOIOMMU=y
  CONFIG_VFIO_IOMMU_TYPE1=y

# Uncomment '# define buildid .local' within 'kernel.spec'
kernel.spec:
  #### ORIGINAL
  # define buildid .local
  
  #### UNCOMMENTED
  %define buildid .local

# BUILD
$ fedpkg --release f32 local

# INSTALL
$ cd x86_64
$ sudo dnf install --nogpgcheck kernel-[0-9]*.x86_64.rpm kernel-core-[0-9]*.x86_64.rpm kernel-modules-[0-9]*.x86_64.rpm kernel-modules-extra-[0-9]*.x86_64.rpm kernel-devel-[0-9]*.x86_64.rpm
$ sudo grub2-mkconfig -o /etc/grub2-efi.cfg
$ sudo grub2-mkconfig -o /etc/grub2.cfg
```

## HOST

#### /etc/passwd

Add user.

```bash
user
```



#### /etc/group

Add qubes and libvirt groups.

```bash
qubes: user  # Add qubes group with id of 101
libvirt: kvm, qemu, qubes  # May not need them all
```



#### /etc/qubes-release

```bash
$ sudo touch /etc/qubes-release
```



#### /etc/dnf/dnf.conf

Disable Qubes `dnf` configuration backing up the one installed by Qubes and replace it with the original.

```bash
$ sudo cp -p dnf.conf.qubes-orig dnf.conf.dist
$ sudo mv dnf.conf dnf.conf.qubes
$ sudo cp -p dnf.conf.dist dnf.conf
```



#### /etc/yum.repos.d/qubes-r4.repo (N/A)

Disable Qubes repository.

```bash
enabled=0
```



#### /var/run/qubes

==XXX:  FIX:  *** NEED TO RESET PERMISSIONS ON EVERY BOOT ***==

```bash
$ sudo chgrp -R qubes /var/run/qubes
$ sudo chmod -R g+rwX /var/run/qubes
```



#### /var/lib/qubes/*

Ensure permissions set correctly;

```bash
$ sudo chgrp -R qubes /var/lib/qubes
$ find /var/lib/qubes -type d | xargs sudo chmod 2770
$ find /var/lib/qubes -type f | xargs sudo chmod 0660
```



#### /var/lib/qubes/vm-kernels/* 

Make sure qubes kernel package is installed.  Example:

```bash
$ ls /var/lib/qubes/vm-kernels/
5.6.16-1

$ rpm -qa | grep kernel-latest-qubes-vm
kernel-latest-qubes-vm-5.7.10-1.qubes.x86_64
```



#### /var/lib/qubes/qubes.xml

Be sure the following configuration is in place before attempting to install a
template. Back it up first!

```xml
      <labels>
        <label id="label-1" color="0xcc0000">red</label>
        <label id="label-2" color="0xf57900">orange</label>
        <label id="label-3" color="0xedd400">yellow</label>
        <label id="label-4" color="0x73d216">green</label>
        <label id="label-5" color="0x555753">gray</label>
        <label id="label-6" color="0x3465a4">blue</label>
        <label id="label-7" color="0x75507b">purple</label>
        <label id="label-8" color="0x000000">black</label>
      </labels>
      <pools>
        <pool name="varlibqubes" dir_path="/var/lib/qubes" driver="file-reflink" revisions_to_keep="1"/>
        <pool name="linux-kernel" dir_path="/var/lib/qubes/vm-kernels" driver="linux-kernel"/>
      </pools>
      <properties>
        <property name="clockvm"></property>
        <property name="default_dispvm"></property>
        <property name="default_kernel">5.6.16-1</property>
        <property name="default_netvm"></property>
        <property name="default_pool_kernel">linux-kernel</property>
        <property name="default_template">fedora-32</property>
        <property name="management_dispvm"></property>
        <property name="updatevm"></property>
      </properties>
      <domains>
        <domain id="domain-0" class="AdminVM">
          <properties>
            <property name="label">black</property>
          </properties>
          <features/>
          <devices class="usb"/>
          <tags/>
        </domain>
      <domains>
```



#### SYSTEMD

Now all Qubes related configuration is complete, ensure Qubes systemd services are enabled with exception of `qubes-qmemman` which should be disabled.  Some services may have already been enabled and failed to start due to missing configuration so it may be best to first stop all services, then enable and start them.  After all services have been enabled, check the status. Most log errors can be ignored so long as the services started and listed as active.  It may also be a good idea to reboot the host once all services have been enabled and recheck the status since it is important to ensure the listed services are running and active before attempting to install a virtual machine template.

```bash
# Stop all Qubes related running serivces
$ sudo systemctl stop kvmchand-host.service
$ sudo systemctl stop qubes-db-dom0.service
$ sudo systemctl stop qubesd.service
$ sudo systemctl stop qubes-qrexec-policy-daemon.service
$ sudo systemctl stop qubes-qmemman.service
$ sudo systemctl stop qubes-core.service

# Enable all Qubes related serivces
$ sudo systemctl enable kvmchand-host.service
$ sudo systemctl enable qubes-db-dom0.service
$ sudo systemctl enable qubesd.service
$ sudo systemctl enable qubes-qrexec-policy-daemon.service
$ sudo systemctl enable qubes-core.service

# Disable qubes-qmemman
$ sudo systemctl disable qubes-qmemman.service

# Start all Qubes related serivces
$ sudo systemctl start kvmchand-host.service
$ sudo systemctl start qubes-db-dom0.service
$ sudo systemctl start qubesd.service
$ sudo systemctl start qubes-qrexec-policy-daemon.service
$ sudo systemctl start qubes-core.service

# Confirm running active status of all Qubes related serivces
$ sudo systemctl status kvmchand-host.service
$ sudo systemctl status qubes-db-dom0.service
$ sudo systemctl status qubesd.service  # Will have errors related to Dom0, that's okay
$ sudo systemctl status qubes-qrexec-policy-daemon.service
$ sudo systemctl status qubes-qmemman.service  # Should be disabled
$ sudo systemctl status qubes-core.service
```



####  NETWORK

Set up libvirt default networking to use same IP address range as Qubes to
allow easier migration for when I specific networking has been
implemented.

```bash
$ sudo virsh net-edit default
```

```xml
<network>
  <name>default</name>
  <!-- Keep same UUID? -->
  <uuid>12345678-1234-1234-1234-123456789012</uuid>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <! -- Keep same mac? -->
  <mac address='11:22:33:44:55:66'/>
  <ip address='10.137.0.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.137.0.2' end='10.137.0.254'/>
    </dhcp>
  </ip>
</network>
```



## DEVELOPER NOTES

#### proc-xen.mount (TODO: remove)

Nothing to do here.  Just a reminder for developer to make sure `/proc/xen` does not attempt to mount.

```bash
# XXX:  HOW TO REMOVE - DISABLE?  DROPIN?
# journalctl log:
mount: /proc/xen: mount point does not exist.
 Failed to insert module 'xen_blkback': No such device
 Failed to insert module 'xen_gntalloc': No such device
 Failed to insert module 'xen_gntdev': No such device
 Failed to insert module 'xen_privcmd': No such device
 Failed to insert module 'xen_evtchn': No such device
 Failed to insert module 'xen_netback': No such device
 Failed to insert module 'xen_pciback': No such device
 Failed to insert module 'xen_scsiback': No such device
 Failed to insert module 'xen_acpi_processor': No such device
```

