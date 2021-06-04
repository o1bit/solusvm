#!/bin/bash
yum localinstall https://download.openvz.org/virtuozzo/releases/openvz-7.0.11-235/x86_64/os/Packages/p/python-subprocess32-3.2.7-1.vz7.5.x86_64.rpm -y
yum localinstall https://download.openvz.org/virtuozzo/releases/openvz-7.0.11-235/x86_64/os/Packages/o/openvz-release-7.0.11-3.vz7.x86_64.rpm -y
yum install epel-release -y
yum remove python-devel.x86_64 kernel-tools-libs-devel.x86_64 -y
yum install python3 -y
rpm -Uvh http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/r/readykernel-scan-0.11-1.vl7.noarch.rpm
rpm -Uvh http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/z/zstd-1.4.4-1.vl7.x86_64.rpm
rpm -Uvh http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/v/vzlinux-release-7-1.vl7.89.x86_64.rpm
mv /etc/yum.repos.d/CentOS-* /root/
rpm -e --nodeps --justdb json-c
yum erase jansson -y
yum localinstall http://repo.virtuozzo.com/vzlinux/7.7/x86_64/os/Packages/j/jansson-2.10-1.vl7.1.x86_64.rpm -y
yum localinstall http://repo.virtuozzo.com/vzlinux/7.7/x86_64/os/Packages/j/json-c-0.11-13.vl7.1.x86_64.rpm -y
rpm -e --nodeps --justdb nspr
rpm -e --nodeps --justdb nss
rpm -e --nodeps --justdb nss-pem
rpm -e --nodeps --justdb nss-softokn
rpm -e --nodeps --justdb nss-softokn-freebl
rpm -e --nodeps --justdb nss-sysinit
rpm -e --nodeps --justdb nss-tools
rpm -e --nodeps --justdb nss-util
yum localinstall http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/n/nss-3.44.0-7.vl7.x86_64.rpm -y
yum localinstall http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/n/nss-softokn-freebl-3.44.0-8.vl7.i686.rpm -y
yum localinstall http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/n/nss-tools-3.44.0-7.vl7.x86_64.rpm -y
yum downgrade glibc* -y
yum install prlctl prl-disp-service vzkernel *ploop* -y
