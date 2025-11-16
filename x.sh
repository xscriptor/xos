#!/usr/bin/env bash
sudo umount -R work/x86_64/airootfs 2>/dev/null || true
sudo rm -rf work out
sudo mkarchiso -C pacman.conf -v -w ./work -o ./out . 2>&1 | tee build-$(date +%Y%m%d-%H%M).log