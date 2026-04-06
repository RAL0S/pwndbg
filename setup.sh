#!/usr/bin/env bash

set -e


show_usage() {
    echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
    show_usage
    exit 1
fi


check_env() {
    if [[ -z "${RALPM_TMP_DIR}" ]]; then
        echo "RALPM_TMP_DIR is not set"
        exit 1
    elif [[ -z "${RALPM_PKG_INSTALL_DIR}" ]]; then
        echo "RALPM_PKG_INSTALL_DIR is not set"
        exit 1
    elif [[ -z "${RALPM_PKG_BIN_DIR}" ]]; then
        echo "RALPM_PKG_BIN_DIR is not set"
        exit 1
    fi
}


install() {
	wget "https://github.com/pwndbg/pwndbg/releases/download/2026.02.18/pwndbg_2026.02.18_x86_64-portable.tar.xz" -O "$RALPM_TMP_DIR/pwndbg-2026.02.18.tar.xz"

	tar -xf "$RALPM_TMP_DIR/pwndbg-2026.02.18.tar.xz" --strip-components=1 -C "$RALPM_PKG_INSTALL_DIR"

	rm "$RALPM_TMP_DIR/pwndbg-2026.02.18.tar.xz"
	
	echo '#!/bin/bash' > $RALPM_PKG_BIN_DIR/pwndbg
	echo "gdb -q -x \"$RALPM_PKG_INSTALL_DIR/pwndbg/lib/python3.13/site-packages/pwndbginit/gdbinit.py\" \"\$@\"" >> "$RALPM_PKG_BIN_DIR/pwndbg"
	
	chmod +x "$RALPM_PKG_BIN_DIR/pwndbg"
}


uninstall() {
	rm "$RALPM_PKG_BIN_DIR/pwndbg"
	rm -rf "$RALPM_PKG_INSTALL_DIR/pwndbg"
}


run() {
    if [[ "$1" == "install" ]]; then
        install
    elif [[ "$1" == "uninstall" ]]; then
        uninstall
    else
        show_usage
    fi
}


check_env
run $1
