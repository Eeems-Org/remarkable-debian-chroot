set -e

config_file="/home/$USER/.config/debian-chroot.conf"
if [ -f "$config_file" ]; then
  source "$config_file"
fi
repository="${repository:-"Eeems-Org/remarkable-debian-chroot"}"
branch="${branch:-master}"
bin_folder="${bin_folder:-"/home/$USER/.local/bin"}"
chroot_path="${chroot_path:-"/home/$USER/.local/share/debian"}"
debootstrap_path="${debootstrap_path:-"/home/$USER/.local/share/debootstrap"}"
debian_arch=${debian_arch:-armhf}
debian_variant=${debian_variant:-minbase}
debian_version=${debian_version:-bullseye}
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
SUDO=
if [[ "$USER" != "root" ]] && command -v sudo > /dev/null; then
  SUDO=sudo
fi

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
debian_arch=${debian_arch}
debian_variant=${debian_variant}
debian_version=${debian_version}
EOF
    "${bin_folder}/debian-chroot" true
    ;;
  uninstall)
    $SUDO rm -f "${bin_folder}/debian-chroot"
    $SUDO rm -f "${bin_folder}/debootstrap"
    while grep -q "${chroot_path}" /proc/mounts; do
      grep "${chroot_path}" /proc/mounts \
      | sort -r \
      | cut -d' ' -f2 \
      | xargs -rn1 $SUDO umount -lqR
    done
    $SUDO rm -rf "$chroot_path"
    $SUDO rm -f "$config_file"
    ;;
esac
