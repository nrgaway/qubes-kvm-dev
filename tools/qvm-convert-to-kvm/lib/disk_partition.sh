#!/bin/bash

source "$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"/lib_utils.sh
source "$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"/lib_cleaner.sh

toggle_verbose  # Hide 'Currently runnig script...' message
source "$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"/lib_functions.sh
toggle_verbose

set -e

__all__=(
    ## Partition info
    attach_image_loopdev
    get_image_loop
    get_partition_by_type
    is_boot_partition
    get_partition_size
    get_partition_info
    get_subvolid

    ## Mount
    mount_partition
    umount_detach_all

    calculate_ideal_image_size
    get_disk_usage
    mountpoints_filter
    mountpoints_unique
    set_template_image_sizes
)

GUID_EFI="c12a7328-f81f-11d2-ba4b-00a0c93ec93b"
GUID_BIOS="21686148-6449-6e6f-744e-656564454649"
GUID_SWAP="0657fd6d-a4ab-43c4-84e5-0933c84b4f4f"
GUID_FILESYSTEM="0fc63daf-8483-4772-8e79-3d69d8477de4"

##DISK_PARTITION_MOUNTS=()
##declare -Ag DISK_PARTITION_DEVICES


# ==============================================================================
# Get image loop device
# ==============================================================================
get_image_loop () {
    local path="$1"
    local device

    if [ -z "$path" ]; then
        return 1
    fi

    path="$(readlink -m "$path")"
    ##device="${DISK_PARTITION_DEVICES["$path"]}"
    ##if [ -z "$device" ]; then
    ##    #device="$(/sbin/losetup -j "$path" | awk '{sub(/:/,"",$1); print $1}')"
    ##    device="$(/sbin/losetup --noheadings --output=NAME -j "$path")"
    ##    if [ -z "$device" ]; then
    ##        return 1
    ##    fi
    ##fi
    #device="$(/sbin/losetup -j "$path" | awk '{sub(/:/,"",$1); print $1}')"
    device="$(/sbin/losetup --noheadings --output=NAME -j "$path")"
    if [ -z "$device" ]; then
        return 1
    fi

    echo "$device"
    return 0
}

# ==============================================================================
# Attach image to loop device
# ==============================================================================
attach_image_loopdev () {
    local path="$1"
    local dev

    if [ ! -e "${path}" ]; then
        echo "Image path $(quote "$path") does not exist!"
        return 1
    elif [ ! -f "${path}" ]; then
        echo "Image path $(quote "$path") is not a file!"
        return 1
    fi

    path="$(readlink -m "$path")"
    dev="$(/sbin/losetup -P -f --show "$path")"
    ##DISK_PARTITION_DEVICES["$path"]="$dev"
}

################################################################################
################################################################################
################################################################################


# ==============================================================================
# Partition Size
# ==============================================================================
get_partition_size () {
    local partition="$1"
    local size
    echo $(( $(numfmt --from=iec $(lsblk --raw --noheadings --output SIZE "$partition")) ))

    ##size=$(lsblk --raw --noheadings --output SIZE "$partition") 2>/dev/null
    ##size=$(numfmt --from=iec $size)
    ##echo $(( $size ))

    ##size=$(lsblk --raw --noheadings --output SIZE "$partition") 2>/dev/null
    ##echo $(( $(numfmt --from=iec $size) ))
}


# ==============================================================================
# Determines if partition is boot partition based on partition size.
# TODO:  Add better detection, maybe mount and check if required
# ==============================================================================
is_boot_partition () {
    local partition="$1"
    if [ $(get_partition_size "$partition") -le $(numfmt --from=iec 1G) ]; then
        return 0
    fi
    return 1
}


# ==============================================================================
# Return partition info
#
# Disk labels:
#   MINIMUM_IO_SIZE, PHYSICAL_SECTOR_SIZE, LOGICAL_SECTOR_SIZE, PTUUID, PTTYPE
#
# Partition labels:
#   UUID,
#   UUID_SUB,
#   TYPE,
#   USAGE,
#   LABEL,
#
#   PART_ENTRY_UUID,
#   PART_ENTRY_TYPE,
#   PART_ENTRY_NAME,
#
#   PART_ENTRY_SCHEME,
#   PART_ENTRY_NUMBER,
#   PART_ENTRY_OFFSET,
#   PART_ENTRY_SIZE,
#   PART_ENTRY_DISK,
#
#   LOGICAL_SECTOR_SIZE,
#   MINIMUM_IO_SIZE,
#   PHYSICAL_SECTOR_SIZE,
#   VERSION,
# ==============================================================================
get_partition_info () {
    local device="$1"
    local label="$2"
    local partition_type="$3"
    local info

    if [ -z "$device" ]; then
        return 1
    fi

    if [ ! -z "$partition_type" ]; then
        partition="$(get_partition_by_type "$device" "$partition_type")"
    else
        partition="$device"
    fi

    info="$(blkid --probe --info "$partition")"
    if [ ! -z "$label" ]; then
        echo "$info" | grep -Po '(?<=\s'${label}'=").*?(?=".*)'
    else
        echo "$info"
    fi
}


# ==============================================================================
# Return btrfs active subvolid
# XXX:  Not implemented
# ==============================================================================
get_subvolid () {
    local partition="$1"

    partition_type="$(get_partition_info "$partition" "TYPE")" || true
    if [ "$partition_type" == "btrfs" ]; then
        ##echo 5
        echo 256
    else
        return 1
    fi
}



# ==============================================================================
# Get partition
# ==============================================================================
get_partition_by_type () {
    local device="$1"
    local type="$2"

    local partitions
    local partition_guid
    local match=false

    ##if [ "$type" == "root" ] || [ "$type" == "private" ]; then
    if [ "$type" == "root" -o "$type" == "private" ]; then
        type="filesystem"
    fi

    partitions=($(lsblk --raw --noheadings --output NAME "$device"))
    if [ ${#partitions[@]} == 1 ]; then
        echo "$device"
        return 0
    fi

    for partition in "${partitions[@]}"; do
        partition="/dev/${partition}"
        udevadm settle --exit-if-exists="$partition"

        partition_guid="$(get_partition_info "$partition" "PART_ENTRY_TYPE")" || true
        if [ "$type" == "efi" ] && [ "$partition_guid" == "$GUID_EFI" ]; then
            match=true
        elif [ "$type" == "bios" ] && [ "$partition_guid" == "$GUID_BIOS" ]; then
            match=true
        elif [ "$type" == "swap" ] && [ "$partition_guid" == "$GUID_SWAP" ]; then
            match=true
        elif [ "$type" == "boot" ] && [ "$partition_guid" == "$GUID_FILESYSTEM" ]; then
            if is_boot_partition "$partition"; then
                match=true
            fi
        elif [ "$type" == "filesystem" ] && [ "$partition_guid" == "$GUID_FILESYSTEM" ]; then
            if ! is_boot_partition "$partition"; then
                match=true
            fi
        fi

        if (( match )); then
            echo "$partition"
            return 0
        fi
    done
    return 1
}


# ==============================================================================
# Mount Partition
# ==============================================================================
mount_partition () {
    local name="$1"
    local device="$2"
    local mountdir="$3"

    local partition
    local partition_type
    local subvolid
    local mount_args

    if [ "$name" == "root" ] || [ "$name" == "private" ]; then
        partition_type="filesystem"
    else
        partition_type="$name"
    fi

    if [ -z "$device" ]; then
        echo "No device available for '${name}'"
        rm -df "${mountdir}" > /dev/null 2>&1
        return 1
    fi

    udevadm settle --exit-if-exists="$device"

    partition="$(get_partition_by_type "$device" "$partition_type")" || {
        echo "partition_type '$partition_type' not found!"
        rm -df "${mountdir}" > /dev/null 2>&1
        return 1
    }

    subvolid=$(get_subvolid "$partition") || true
    if [ ! -z "$subvolid" ]; then
        echo "      subvolid: $subvolid"
    fi

    if [ -z "$subvolid" ]; then
        mount_args=("${partition}" "${mountdir}"
        )
    else
        mount_args=(
            -t btrfs -o subvolid=$subvolid
            "${partition}" "${mountdir}"
        )
    fi

    mkdir -p "${mountdir}"
    mount "${mount_args[@]}" > /dev/null 2>&1 || {
        rm -df "${mountdir}" > /dev/null 2>&1
        return 1
    }
    ##DISK_PARTITION_MOUNTS+=($mountdir)

    echo "        device: $device"
    echo "          name: $name"
    echo "partition_type: $partition_type"
    echo "     partition: $partition"
    echo "         mount: "${mount_args[@]}""
}


# ==============================================================================
# Unmount all mountpoints mounted within loop devices attached to image file
# paths then detatch loop devices.
# ==============================================================================
##mountpoints_sortuniq () {
##    local -n _mountpoints="$1"
##    #local mnt
##    #for mnt in "${_mountpoints[@]}"; do echo "$mnt"; done | sort -r | uniq
##    (
##        local mountpoint
##        for mountpoint in "${_mountpoints[@]}"; do 
##            if [ ! -z "$mountpoint" ] && [ -e "$mountpoint" ]; then
##                echo "$mountpoint"
##            fi
##        done
##    ) | sort -r | uniq
##}

mountpoints_unique () {
    local -n _mountpoints="$1"
    local unique=()
    local mountpoint

    for mountpoint in "${_mountpoints[@]}"; do 
        if contains "$mountpoint" unique; then
            continue
        fi
        if [ -z "$mountpoint" ]; then
            continue
        fi
        if [ ! -e "$mountpoint" ]; then
            continue
        fi
        unique+=("$mountpoint")
        echo "$mountpoint"
    done
}

mountpoints_filter () {
    local -n _mountpoints="$1"
    local -n _device_mountpoints="$2"
    local filtered=()
    local mountpoint

    for mountpoint in "${_mountpoints[@]}"; do
        if contains "$mountpoint" _device_mountpoints; then
            continue
        fi
        filtered+=("$mountpoint")
    done
    ##mountpoints_sortuniq filtered
    mountpoints_unique filtered
}

umount_detach_all () {
    local paths=("${@}")
    local devices=()
    local device_mountpoints=()
    local mountpoints=()
    local path device mountpoint
    local index

    # --------------------------------------------------------------------------
    # Find device mountpoints mounted to loop device
    for path in "${paths[@]}"; do
        if [ ! -e "$path" ]; then
            continue
        fi

        path="$(readlink -m "$path")"
        device="$(get_image_loop "$path")" || continue
        devices+=("$device")
        index=$(( ${#device_mountpoints[@]} +1 ))
        if findmnt --raw | grep -Poq '.*(?=\s'"$device"')'; then
            readarray -t -O $index device_mountpoints \
                <<<"$(findmnt --raw | grep -Po '.*(?=\s'"$device"')')"
        fi
    done
    readarray -t device_mountpoints < <(mountpoints_unique device_mountpoints)

    # --------------------------------------------------------------------------
    ##output ""
    ##info "Device mountpoints"
    ##output "Number of device mountpoints: "${#device_mountpoints[@]}""
    ##for mountpoint in "${device_mountpoints[@]}"; do
    ##    echo "$(quote $mountpoint)"
    ##done

    # --------------------------------------------------------------------------
    # Find recursive mountpoints
    for mountpoint in "${device_mountpoints[@]}"; do
        index=$(( ${#mountpoints[@]} +1 ))
        readarray -t -O $index mountpoints \
            <<<"$(findmnt -R --noheading --raw --output=target "$mountpoint")"
    done

    # --------------------------------------------------------------------------
    # Filter and sort unique mountpoints in reverse
    readarray -t mountpoints \
        < <(mountpoints_filter mountpoints device_mountpoints)

    # --------------------------------------------------------------------------
    ##mountpoints+=( "${device_mountpoints[@]}" )
    device_mountpoints+=( "${mountpoints[@]}" )
    mountpoints=( "${device_mountpoints[@]}" )

    # --------------------------------------------------------------------------
    output ""
    info "Mountpoints"
    output "Number of mountpoints: "${#mountpoints[@]}""
    for mountpoint in "${mountpoints[@]}"; do
        echo "$(quote $mountpoint)"
    done

    # --------------------------------------------------------------------------
    # Unmounted in reverse order
    output ""
    info "disk_partition.sh: Un-mounting mountpoints..."
    output "MOUNTPOINTS: ${#mountpoints[@]}"
    ##for mountpoint in "${mountpoints[@]}"; do
    ##    output umount ${mountpoint}
    ##    ##umount ${mountpoint} > /dev/null 2>&1 || {
    ##    ##    error "Failed to umount $(quote "$mountpoint")"
    ##    ##}
    ##done
    for ((i=${#mountpoints[@]}-1; i>=0; i--)); do
        mountpoint="${mountpoints[$i]}"
        output umount ${mountpoint}
        umount ${mountpoint} > /dev/null 2>&1 || {
            error "Failed to umount $(quote "$mountpoint")"
        }
    done

    output ""
    info "disk_partition.sh: Detaching devices..."
    output "DEVICES: ${#devices[@]}"
    for device in "${devices[@]}"; do
        if [ -e "$device" ]; then
            output /sbin/losetup -d "${device}"
            #/sbin/losetup -d "${device}" > /dev/null 2>&1 || {
            #    error "Failed to detach device $(quote "$device")"
            #}
            /sbin/losetup -d "${device}"
        fi
    done
}


################################################################################
################################################################################
################################################################################


# ==============================================================================
# Return ideal image size to nearest $round or $min value
#
# $1: existing size
# $2: minimum size
# $3: round up to nearest value
# $4: amount to subtract from existing size (IE: Don't calculate home dir)
# ==============================================================================
calculate_ideal_image_size () {
    size=$1
    min=$2
    round=$3
    subtract=$4

    # Convert human readable values into bytes
    min=$(numfmt --from=iec $min)
    round=$(numfmt --from=iec $round)
    ##half_round=$(( $round / 2 ))
    #half_round=$(( $round / 10 ))
    half_round=$(printf "%.0f" $(echo "$round * 0.15" | bc))
    size=$(numfmt --from=iec $size)

    # Subtract $subtract value from $size if provided
    if [ ! -z $subtract ]; then
        subtract=$(numfmt --from=iec $subtract)
        size=$(( $size - $subtract ))
    fi

    # Round up to nearest $round value
    ##size=$(( $size + $half_round ))
    ##size=$(echo $(( size = (size+$round)/$round, size*=$round )))
    size=$(echo $(( size = (size+$round+$half_round)/$round, size*=$round )))

    # Min size
    size=$(dc -e "${min}sm ${size}d ${min}>mp")

    # Convert size back into human readable format
    size=$(numfmt --to=iec $size)

    # Remove any decimal places
    size=$(echo "$size" | perl -lne 'print "$1$2" if /(\d+)(?:[.]\d+|)(\w+)/')

    echo $size
}


# ==============================================================================
# Return disk usage within path
# ==============================================================================
get_disk_usage () {
    local path="$1"
    echo $(du -sh "${path}" | grep -Po '^\S+')
}


# ==============================================================================
# Set templates root and private sizes
#
# Calculates image sizes based on existing source image sizes.
# ==============================================================================
set_template_image_sizes () {
    local root_min=${1:="10G"}
    local root_round=${2:="5G"}
    local private_min=${3:="2G"}
    local private_round=${4:="5G"}

    local source_root_size
    local source_private size
    local partition

    ##echo ""
    source_root_size=$(get_disk_usage "${SOURCEDIR}"/root)
    echo "      ROOT DISK USAGE: $source_root_size"
    if [ -d "${SOURCEDIR}/private" ]; then
        ##echo "       PRIVATE EXISTS: "${SOURCEDIR}"/private"
        partition="$(get_partition_by_type "$SOURCE_PRIVATE_IMG_LOOP" "filesystem")" && {
            source_private_size="$(get_partition_size "$partition")"
        echo "         PRIVATE SIZE: $source_private_size"
        } || {
            source_private_size=$(get_disk_usage "${SOURCEDIR}"/private)
        echo "   PRIVATE DISK USAGE: $source_private_size"
        }
        source_root_size=$(calculate_ideal_image_size $source_root_size "$root_min" "$root_round")
    else
        ##echo "      PRIVATE MISSING: "${SOURCEDIR}"/private"
        source_private_size=$(get_disk_usage "${SOURCEDIR}"/root/home)
        echo "   PRIVATE DISK USAGE: $source_private_size"
        source_root_size=$(calculate_ideal_image_size $source_root_size "$root_min" "$root_round" $source_private_size)
    fi
    source_private_size=$(calculate_ideal_image_size $source_private_size "$private_min" "$private_round")
    echo "        ROOT ADJUSTED: $source_root_size"

    if [ -z "$TEMPLATE_ROOT_SIZE" ]; then
        TEMPLATE_ROOT_SIZE=$source_root_size
    fi
    if [ -z "$TEMPLATE_PRIVATE_SIZE" ]; then
        TEMPLATE_PRIVATE_SIZE=$source_private_size
    fi

    echo ""
    echo "   TEMPLATE_ROOT_SIZE: $TEMPLATE_ROOT_SIZE"
    echo "TEMPLATE_PRIVATE_SIZE: $TEMPLATE_PRIVATE_SIZE"
}


# ==============================================================================
# Cleanup
# ==============================================================================
##disk_partition_cleanup() {
##    info "Disk partition unmounting mounts..."
##    output "MOUNTPOINTS: ${#DISK_PARTITION_MOUNTS[@]}"
##    # Unmount in reverse order
##    for ((i=${#DISK_PARTITION_MOUNTS[@]}-1; i>=0; i--)); do
##        mountdir="${DISK_PARTITION_MOUNTS[$i]}"
##        output umount ${mountdir} || true
##        umount ${mountdir} > /dev/null 2>&1 || true
##    done
##    output ""
##
##    info "Disk partition detaching devices..."
##    output "DEVICES: ${#DISK_PARTITION_DEVICES[@]}"
##    #output "${DISK_PARTITION_DEVICES[@]}"
##    for device in ${DISK_PARTITION_DEVICES[@]}; do
##        if [ -e "$device" ]; then
##            output /sbin/losetup -d "${device}"
##            /sbin/losetup -d "${device}" > /dev/null 2>&1 || true
##        fi
##    done
##    output ""
##}
##
##if is_declared CLEANERS; then
##    CLEANERS+=(disk_partition_cleanup)
##fi

