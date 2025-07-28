# Installaltions

## HW (Hardware) repair

- USB (>=4GB)
- Live-image [https://voidlinux.org/download/](https://voidlinux.org/download/)
- Linux OS (I have installed VoidLinux from UBUNTU)
- USB-Windows-Installation (For failing installation) HAHAHAHA.

## Prepare Installation Media

* SOURCE: [Prepare Installation Media](https://docs.voidlinux.org/installation/live-images/prep.html)

(This part just make a USB LIVE IMAGE)

## Boot from USB LIVE-IMAGE 

### BASH

Void Linux installation only provides a command-line interface (CLI). For a more comfortable experience, you can use `Bash` by typing `bash` in the shell.

### Void-Installer

run `void-installer` to start install VoidLinux.

### Parition notes

SOURCE: [https://docs.voidlinux.org/installation/live-images/partitions.html](https://docs.voidlinux.org/installation/live-images/partitions.html)

This is your free disk:

    [-----------------------------------------]

My recommend:

    [--EFI:250MB---|--SWAP:4GB--|--ROOT(/)----]

### To be cont. :>

# THIS REPO

Back-up tree:

```
├── etc
│   └── acpi
│       └── handler.sh
├── home
│   └── fus
│       ├── .backup.sh
│       ├── .config
│       └── .fus
├── readme.md
└── usr
    └── share
        └── fonts
```
