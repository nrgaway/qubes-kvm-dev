#!/bin/bash

source "$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")"/disk_partition.sh

set -e

get_uuid () {
    local dev="$1"
    local name="$2"
    local type="$3"
    local uuid

    case "$name" in
        ptuuid)
            uuid="$(get_partition_info "$dev" "$type")" || {
                if [ "$type" == "PTUUID" ]; then
                    uuid="71756265-732d-6b76-6d2d-69726f6f7400"
                fi
            }
            ;;
        efi)
            uuid="$(get_partition_info "$dev" "$type" "efi")" || {
                if [ "$type" == "PART_ENTRY_UUID" ]; then
                    uuid="71756265-732d-6b76-6d2d-706566690000"
                elif [ "$type" == "UUID" ]; then
                    echo ""
                    return 0
                fi
            }
            if [ "$type" == "UUID" ]; then
                uuid="${uuid/-/}"
            fi
            ;;
        bios)
            uuid="$(get_partition_info "$dev" "$type" "bios")" || {
                if [ "$type" == "PART_ENTRY_UUID" ]; then
                    uuid="71756265-732d-6b76-6d2d-7062696f7300"
                fi
            }
            ;;
        swap)
            uuid="$(get_partition_info "$dev" "$type" "swap")" || {
                if [ "$type" == "PART_ENTRY_UUID" ]; then
                    uuid="71756265-732d-6b76-6d2d-707377617000"
                fi
            }
            ;;
        boot)
            uuid="$(get_partition_info "$dev" "$type" "boot")" || {
                if [ "$type" == "PART_ENTRY_UUID" ]; then
                    uuid="71756265-732d-6b76-6d2d-70626f6f7400"
                fi
            }
            ;;
        root)
            uuid="$(get_partition_info "$dev" "$type" "filesystem")" || {
                if [ "$type" == "PART_ENTRY_UUID" ]; then
                    uuid="71756265-732d-6b76-6d2d-70726f6f7400"
                fi
            }
            ;;
        private)
            uuid="$(get_partition_info "$dev" "$type" "filesystem")" || true
            ;;
        *)
            return 1
    esac
    if [ -z "$uuid" ]; then
        uuid="$(uuidgen -r)"
    fi
    echo "$uuid"
}

#echo ""
#echo "      PTUUID: $(get_uuid $dev ptuuid PTUUID)"        # PASS
#echo "    UUID_EFI: $(get_uuid $dev efi PART_ENTRY_UUID)"  # PASS
#echo "   UUID_BOOT: $(get_uuid $dev boot PART_ENTRY_UUID)"
#echo "   UUID_ROOT: $(get_uuid $dev root PART_ENTRY_UUID)"
#echo "UUID_PRIVATE: $(get_uuid $dev private UUID)"

