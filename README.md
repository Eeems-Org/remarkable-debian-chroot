reMarkable Debian Chroot
========================

Scripts to automate creating and maintaining a minimal debian chroot on a reMarkable tablet.

### Install Automagic
```
sh -c "$(wget https://raw.githubusercontent.com/Eeems-Org/remarkable-debian-chroot/master/install.sh -O-)"
```

### Uninstall Automagic
```
sh -c "$(wget https://raw.githubusercontent.com/Eeems-Org/remarkable-debian-chroot/master/install.sh -O-)" _ uninstall
```

### Usage
Make sure `/home/root/.local/bin` is on your path.

#### Run command in chroot

```bash
debian-chroot lsb_release -a
```

#### Enter interactive console inside chroot

```bash
debian-chroot
```
