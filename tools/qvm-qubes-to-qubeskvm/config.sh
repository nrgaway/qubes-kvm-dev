#!/bin/bash
# vim: set ts=4 sw=4 sts=4 et :

# --- FUNCTIONS ----------------------------------------------------------------
raise () {
    echo "${@}"
    echo "Exiting..."
    exit 1
}

find_qubesdir () {
    echo "$(readlink -m "${ROOTDIR}"/../../../../)"
}

find_packagedir () {
    local dist="$1"
    local type="${2:-vm}"
    local qubesdir="$(find_qubesdir)"
    local repodir="${qubesdir}/qubes-packages-mirror-repo"
    local package_type packagedir

    case "$dist" in
        fc32)
            package_type=rpm
            ;;
        *)
            return 1
    esac

    packagedir="${repodir}/${type}-${dist}/${package_type}"
    if [ -e "$packagedir" ]; then
        echo "$packagedir"
    else
        return 1
    fi
}

install_package_installer_scripts () {
    # Copy required package installer scripts to data directory
    local scripts=("${@}")
    local datadir_share="${DATADIR}/share"
    local script source target

    if [ ! -d "$PACKAGE_INSTALLER_DIR" ]; then
        raise "package installer directory not found"
    fi

    for script in "${scripts[@]}"; do
        source="${PACKAGE_INSTALLER_DIR}/${script}"
        target="${datadir_share}/${script}"
        if [ ! -e "$source" ]; then
            raise "Installer script not found ${source@Q}"
        fi
        echo ""
        echo "Installing package installer script"
        echo "  FROM: ${source@Q}"
        echo "    TO: ${target@Q}"
        cp -fp "$source" "$target"
    done
}


# --- CONFIG -------------------------------------------------------------------
declare -ir false=0 true=1

DIST="${DIST:-fc32}"
#if [ -z "$DIST" ]; then
#    raise "DIST not set"
#fi
echo "      DIST: $DIST"

ROOTDIR="$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"
echo "   ROOTDIR: $ROOTDIR"

SCRIPTSDIR="${ROOTDIR}/template_kvm"
echo "SCRIPTSDIR: $SCRIPTSDIR"

DATADIR="${ROOTDIR}/data"
echo "   DATADIR: $DATADIR"

PACKAGEDIR="$(find_packagedir $DIST)" || raise "Could not determine PACKAGEDIR"
echo "PACKAGEDIR: $PACKAGEDIR"

INSTALLDIR="${ROOTDIR}/mnt/root"
echo "INSTALLDIR: $INSTALLDIR"

export DIST ROOTDIR SCRIPTSDIR DATADIR PACKAGEDIR INSTALLDIR

# --- Copy required package installer scripts to data directory ----------------
PACKAGE_INSTALLER_DIR="${PACKAGE_INSTALLER_DIR:-"${ROOTDIR}/package-installer"}"
install_package_installer_scripts \
    'package-installer.sh' \
    'install-vm-packages.sh'

# --- Install other tools ------------------------------------------------------
link_matched="${ROOTDIR}/../link-matched"
if [ -e "$link_matched" ]; then
    cp "$link_matched" "${DATADIR}/root/bin"
fi

