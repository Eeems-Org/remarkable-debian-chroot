set -e

config_file="/home/root/.config/debian-chroot.conf"
if [ -f "$config_file" ]; then
  . "$config_file"
fi
repository="${repository:-"Eeems-Org/remarkable-debian-chroot"}"
branch="${branch:-master}"
bin_folder="${bin_folder:-"/home/root/.local/bin"}"
chroot_path="${chroot_path:-"/home/root/.local/share/debian"}"
debootstrap_path="${debootstrap_path:-"/home/root/.local/share/debootstrap"}"
download() {
  if [ -f "$3" ]; then
    echo "Warning: ${3} already exists"
    return
  fi
  wget \
    "https://raw.githubusercontent.com/${repository}/${branch}/${2}" \
    --output-document="$3"
  chmod "$1" "$3"
}

case "${1:-install}" in
  install)
    if ! type perl &> /dev/null || ! type ar &> /dev/null; then
      echo "Perl and ar are required to run"
      if ! type opkg &> /dev/null; then
        exit 1
      fi
      echo "Installing perl and ar"
      opkg update
      opkg install perl ar
    fi
    mkdir -p "$bin_folder"
    download +x bin/debian-chroot "${bin_folder}/debian-chroot"
    download +x bin/debootstrap "${bin_folder}/debootstrap"
    mkdir -p "$(dirname "$config_file")"
    cat > "$config_file" <<EOF
repository="${repository}"
branch="${branch}"
bin_folder="${bin_folder}"
chroot_path="${chroot_path}"
debootstrap_path="${debootstrap_path}"
EOF
    "${bin_folder}/debian-chroot" true
    ;;
  uninstall)
    rm -f "${bin_folder}/debian-chroot"
    rm -f "${bin_folder}/debootstrap"
    while grep -q "${chroot_path}" /proc/mounts; do
      grep "${chroot_path}" /proc/mounts \
      | sort -r \
      | cut -d' ' -f2 \
      | xargs -rn1 umount -lqR
    done
    rm -rf "$chroot_path"
    rm -f "$config_file"
    ;;
esac
