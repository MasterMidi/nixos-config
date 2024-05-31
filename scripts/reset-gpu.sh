#!/usr/bin/env bash
# https://www.youtube.com/watch?v=0uZODoPQH9c
#
#replace xx\:xx.x with the number of your gpu and sound counterpart
#
#
echo "disconnecting amd graphics"
echo "1" | tee -a /sys/bus/pci/devices/0000\:03\:00.0/remove
echo "disconnecting amd sound counterpart"
echo "1" | tee -a /sys/bus/pci/devices/0000\:03\:00.1/remove
echo "entered suspended state press power button to continue"
echo -n mem >/sys/power/state
echo "reconnecting amd gpu and sound counterpart"
echo "1" | tee -a /sys/bus/pci/rescan
echo "AMD graphics card sucessfully reset"
