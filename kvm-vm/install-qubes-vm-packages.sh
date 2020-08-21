#!/bin/bash
# vim: set ts=4 sw=4 sts=4 et :
declare -ir false=0 true=1
DEBUG=false
DRYRUN=false
#DEBUG=true
#DRYRUN=true


# COMPONENTS
COMPONENTS=(
    #qubes_db
    ## Requries systemd unit file modification
    qrexec
)


RPMDIR="/rpm"

qubes_db=(
    ##qubes-db-4.1.7-1.fc32.x86_64.rpm
    ##qubes-db-libs-4.1.7-1.fc32.x86_64.rpm
    ##qubes-db-vm-4.1.7-1.fc32.x86_64.rpm
    qubes-db
    qubes-db-libs
    qubes-db-vm
)
qrexec=(
    ##qubes-core-qrexec-4.1.8-1.fc32.x86_64.rpm
    ##qubes-core-qrexec-vm-4.1.8-1.fc32.x86_64.rpm
    ##qubes-core-qrexec-libs-4.1.8-1.fc32.x86_64.rpm
    ##qubes-libvchan-kvm-4.1.0-1.fc32.x86_64.rpm
    ##python3-gbulb-0.6.1-1.fc32.x86_64.rpm
    qubes-core-qrexec
    qubes-core-qrexec-vm
    qubes-core-qrexec-libs
    qubes-libvchan-kvm
    python3-gbulb
)


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
            component_version="[0-9]"
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

    #install_packages install "${packages[@]}"
    install_packages reinstall "${packages[@]}"

popd >/dev/null 2>&1

