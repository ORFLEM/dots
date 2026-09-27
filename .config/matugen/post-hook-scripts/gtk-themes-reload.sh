#!/usr/bin/env bash

export GSETTINGS_SCHEMA_DIR=$(ls -d /nix/store/*-gsettings-desktop-schemas-*/share/gsettings-schemas/*/glib-2.0/schemas | head -1)

current=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ "$current" == "'prefer-dark'" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
else
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
fi
