#!/usr/bin/env bash
#===============================================================================
#         FILE:  reconnect-vpn.sh
#
#  DESCRIPTION:  Reconnect a disconnected VPN session on Synology DSM
#    SOURCE(S):  https://forum.synology.com/enu/viewtopic.php?f=241&t=65444
#
#       AUTHOR:  Ian Harrier
#      VERSION:  1.0.3
#      LICENSE:  MIT License
#===============================================================================

#-------------------------------------------------------------------------------
#  Set variables - EDIT THIS!
#  Get the configuration from:
#  /usr/syno/etc/synovpnclient/l2tp/l2tpclient.conf
#  /usr/syno/etc/synovpnclient/openvpn/ovpnclient.conf
#  /usr/syno/etc/synovpnclient/pptp/pptpclient.conf)
#  PROFILE_PROTOCOL="openvpn"|"l2tp"|"pptp"
#-------------------------------------------------------------------------------

PROFILE_ID=
PROFILE_NAME=
PROFILE_PROTOCOL=

#-------------------------------------------------------------------------------
#  Check the VPN connection
#-------------------------------------------------------------------------------

if [[ $(/usr/syno/bin/synovpnc get_conn | grep Uptime) ]] && ping -c1 8.8.8.8 >/dev/null; then
	echo "[I] VPN is already connected. Exiting..."
	exit 0
fi

#-------------------------------------------------------------------------------
#  Reconnect the VPN connection
#-------------------------------------------------------------------------------

/usr/syno/bin/synovpnc kill_client
sleep 20
echo conf_id=$PROFILE_ID > /usr/syno/etc/synovpnclient/vpnc_connecting
echo conf_name=$PROFILE_NAME >> /usr/syno/etc/synovpnclient/vpnc_connecting
echo proto=$PROFILE_PROTOCOL >> /usr/syno/etc/synovpnclient/vpnc_connecting
/usr/syno/bin/synovpnc connect --id=$PROFILE_ID
sleep 20

#-------------------------------------------------------------------------------
#  Re-check the VPN connection
#-------------------------------------------------------------------------------

if [[ $(/usr/syno/bin/synovpnc get_conn | grep Uptime) ]] ping -c1 8.8.8.8 >/dev/null; then
	echo "[I] VPN successfully reconnected. Exiting..."
	exit 0
else
	echo "[E] VPN failed to reconnect. Exiting..."
	exit 1
fi
