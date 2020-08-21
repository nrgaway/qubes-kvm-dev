#!/bin/bash
# vim: set ts=4 sw=4 sts=4 et :

declare -ir false=0 true=1
DEBUG=false
DRYRUN=false
#DEBUG=true
#DRYRUN=true

RPMDIR="/rpm"
CONFDIR="/share"

PACKAGES=()
INSTALL_PACKAGES=true

INSTALL_MODE="${1:-reinstall}"
echo "INSTALL_MODE: $INSTALL_MODE"


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
# DNF Install RPM packages
# ==============================================================================
function dnf_install() {
    mode="$1"
    shift 1 || shift $(($#))
    local packages=("${@}")

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
add_packages () {
    local component_version="[0-9]"
    pushd "${RPMDIR}" >/dev/null 2>&1
        for component_package in ${@}; do
            ##if (( DEBUG )); then
            ##    echo "COMPONENT PACKAGE: $component_package"
            ##fi

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
            PACKAGES+=("$package")
        done
    popd >/dev/null 2>&1
}


# ==============================================================================
# Install provided package names
# ==============================================================================
install_packages () {
    pushd "${RPMDIR}" >/dev/null 2>&1
        add_packages "${@}"
        dnf_install "$INSTALL_MODE" "${PACKAGES[@]}"
    popd >/dev/null 2>&1
}

