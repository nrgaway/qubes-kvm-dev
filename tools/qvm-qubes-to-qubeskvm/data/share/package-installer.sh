#!/bin/bash
# vim: set ts=4 sw=4 sts=4 et :

declare -ir false=0 true=1
DEBUG=false
DRYRUN=false
DEBUGINFO=false

COMPONENTS=()
INSTALL_MODES=()


# ==============================================================================
# Return matching RPM package names
# ==============================================================================

add_rpm_package() {
    local -n _packages="$1"
    local package="$2"
    local force=${3:-false}

    package=$(echo $package)
    if [ -e "$package" ] || (( force )) ; then
        _packages+=("$package")
        return
    fi
}
get_rpm_packages() {
    local -n packages="$1"
    local name="$2"
    local version="${3:-"[0-9]"}"
    local force=${4:-false}

    add_rpm_package packages "${name}"-"${version}"*".rpm" $force

    if (( DEBUGINFO )); then
        add_rpm_package packages "${name}"-debuginfo-"${version}"*".rpm"
        add_rpm_package packages "${name}"-debugsource-"${version}"*".rpm"
    fi
}


# ==============================================================================
# Install RPM packages
# ==============================================================================
dnf_install() {
    mode="$1"
    shift 1 || shift $(($#))
    local packages=("${@}")

    if (( DRYRUN )); then
        local index
        echo ""
        echo "sudo dnf "$mode" \\"
        for index in "${!packages[@]}"; do
            if (( index+1 < ${#packages[@]} )); then
                echo "  ${packages[index]} \\"
            else
                echo "  ${packages[index]}"
            fi
        done
    else
        sudo dnf -y "$mode" "${packages[@]}"
    fi
}


# ==============================================================================
# Generate and install RPM package list
# ==============================================================================
install_packages () {
    local rpmdir="$1"
    local -n components="$2"
    shift 2 || shift $(($#))

    local packages=()
    local argv=()
    local error=false
    local component component_name component_version
    local component_package component_packages
    local rpm_packages package install_mode

    rpmdir="$(readlink -m "$rpmdir")"

    # --- SYS-ARGV -------------------------------------------------------------
    # ARGV options or list of components to install
    if [ ${#@} -gt 0 ]; then
        argv=()
        for component in "${@}"; do
            if [ "$component" == "--dryrun" ]; then
                DRYRUN=true
            elif [ "$component" == "--debuginfo" ]; then
                DEBUGINFO=true
            elif [ "$component" == "--install" ]; then
                INSTALL_MODES+=('install')
            elif [ "$component" == "--reinstall" ]; then
                INSTALL_MODES+=('reinstall')
            else
                argv+=("$component")
            fi
        done
        if [ ${#argv} -gt 0 ]; then
            components=( "${argv[@]}" )
        fi
    fi

    # --- SET INSTALL MODES ----------------------------------------------------
    if [ "${#INSTALL_MODES[@]}" -eq 0 ]; then
        INSTALL_MODES+=('install')
        INSTALL_MODES+=('reinstall')
    fi

    # --- INFO -----------------------------------------------------------------
    echo "   DRYRUN: $DRYRUN"
    echo "DEBUGINFO: $DEBUGINFO"
    echo "   RPMDIR: $rpmdir"

    if (( DEBUG )); then
        echo "     ARGV: $@"
        echo ""
        for component in "${components[@]}"; do
            echo "COMPONENT: $component"
        done
    fi

    if (( ! DRYRUN )); then
        services_stop 2>/dev/null || true
    fi

    # --- INSTALL PACKAGES -----------------------------------------------------
    pushd "${rpmdir}" >/dev/null 2>&1
        for component in "${components[@]}"; do
            echo ""
            echo "COMPONENT: $component"
            component_name="${component%%=*}"
            component_name="${component_name//-/_}"

            if (( DEBUG )); then
                if [ "${component//-/_}" != "$component_name" ]; then
                    echo "     NAME: $component_name"
                fi
            fi

            component_version="$(echo "$component" | grep -Po '(?<=[=])\d.*')"
            if [ ! -z "$component_version" ]; then
                echo "  VERSION: $component_version"
            fi

            declare -n component_packages="$component_name"
            for component_package in ${component_packages[@]}; do
                ##echo "  PACKAGE: $component_package"
                rpm_packages=()
                get_rpm_packages rpm_packages "$component_package" "$component_version"
                if [ "${#rpm_packages[@]}" -eq 0 ]; then
                    if [ ! -z "$component_version" ]; then
                        component_package="${component_package}==${component_version}"
                    fi
                    echo ""
                    echo "    ERROR: ${component_package@Q} does not exist!  Exiting..."

                    # Force to show attempted match
                    get_rpm_packages rpm_packages "$component_package" "$component_version" true
                    error=true
                fi

                for package in "${rpm_packages[@]}"; do
                    echo "           $package"
                    packages+=("$package")
                done

                if (( error )); then
                    exit 1
                fi
            done
        done

        for install_mode in "${INSTALL_MODES[@]}"; do
            dnf_install "$install_mode" "${packages[@]}"
        done

    popd >/dev/null 2>&1

    if (( ! DRYRUN )); then
        services_restart 2>/dev/null || true
    fi
}
