#!/usr/bin/env bash

#
# SCRIPT .... : SolusVM intaller
# Source .... : https://files.soluslabs.com/install.sh
# Version ... : 5.5
# Last Edit . : 2019-12-30
#

ALLOWED_CHARS='1234567890abcdefghijklmnopqertuvwxyxABCDEFGHIJKLMNOPQRSTUVWXYZ';
IP=$(ip ro get 8.8.8.8 | awk -F 'src' '{print $2}' | cut -d " " -f 2 | sed '/^$/d');
IP=${IP//[[:blank:]]/}
INSTALL_LOG_LOCATION=/tmp/install.log;
MIRROR=http://files.soluslabs.com;
HOSTNAME=$(hostname);
ECHO_PATH=echo;
WITH_TEMPLATES=false;
IS_MASTER=false;
OPENVZ=false;
PATH_PREFIX="";
ARCH=$(arch)

while getopts ":c:p:" option
do
    case "${option}"
    in
        c) INSTALL_CONF="${OPTARG}";;
        p) PATH_PREFIX="${OPTARG}/";;
    esac
done

clear;

function compatibility() {
    if [[ "${ARCH}" != "x86_64" ]]; then
        echo "Warning. We have detected that server architecture is ${ARCH}. Please be informed that SolusVM installation supports x86_64 based operating systems only. You can continue the installation process at your own risk. For that, use the following command: " | tee -a "${INSTALL_LOG_LOCATION}"
        echo 'curl -o install_eol.sh http://files.soluslabs.com/install_eol.sh && sh install_eol.sh'
        exit 1
    fi
}

${ECHO_PATH} " ** Please wait while the installer requirements are installed...";

function menu() {
    ntpInstall;
    clear;
        ${ECHO_PATH} " o----------------------------------------------------------------o";
        ${ECHO_PATH} " | :: SolusVM Installer                         v5.6 (2020/05/26) |";
        ${ECHO_PATH} " o----------------------------------------------------------------o";
        ${ECHO_PATH} " |                                                                |";
        ${ECHO_PATH} " |   What SolusVM type would you like to install?                 |";
        ${ECHO_PATH} " |                                                                |";
        ${ECHO_PATH} " |                                                                |";
    if [ "${OSV}" == "7" ]; then
     if [ "${LINUX}" == "Virtuozzo" ]; then
        ${ECHO_PATH} " |   VIRTUOZZO 7 HOST SERVER:                                     |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |   | Opt | Type             | Virtualization                |   |";
        ${ECHO_PATH} " |   ==========================================================   |";
        ${ECHO_PATH} " |   | [1] | Hypervisor       | OpenVZ with basic templates   |   |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |   | [2] | UI               | OpenVZ with basic templates   |   |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |                                                                |";
     else
        ${ECHO_PATH} " |   RHEL/CENTOS/SCI LINUX 7 HOST SERVER:                         |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |   | Opt | Type             | Virtualization                |   |";
        ${ECHO_PATH} " |   ==========================================================   |";
        ${ECHO_PATH} " |   | [1] | UI               | None                          |   |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |   | [2] | Hypervisor       | KVM                           |   |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |   | [3] | Hypervisor       | Xen                           |   |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |   | [4] | Kernel           | OpenVZ                        |   |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |                                                                |";
     fi
    fi
    if [ "${OSV}" == "6" ]; then
        YumRhel6;
        ${ECHO_PATH} " |   RHEL/CENTOS/SCI LINUX 6 HOST SERVER:                         |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |   | Opt | Type             | Virtualization                |   |";
        ${ECHO_PATH} " |   ==========================================================   |";
        ${ECHO_PATH} " |   | [1] | UI               | None                          |   |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |   | [2] | UI               | OpenVZ with basic templates   |   |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |   | [3] | UI               | OpenVZ                        |   |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |   | [4] | Hypervisor       | KVM                           |   |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |   | [5] | Hypervisor       | Xen                           |   |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |   | [6] | Hypervisor       | OpenVZ                        |   |";
        ${ECHO_PATH} " |   ----------------------------------------------------------   |";
        ${ECHO_PATH} " |                                                                |";
    fi
        ${ECHO_PATH} " o----------------------------------------------------------------o";
        ${ECHO_PATH} "";
        ${ECHO_PATH} " Choose an option : ";
    read -e option;
    if [ "${OSV}" == "7" ]; then
     if [ "${LINUX}" == "Virtuozzo" ]; then
      until [ "${option}" = "1" ] || [ "${option}" = "2" ] || [ "${option}" = "3" ] || [ "${option}" = "4" ]; do
            ${ECHO_PATH} "   Please enter a valid option: ";
            read -e option;
        done
        brctl delbr host-routed >> ${INSTALL_LOG_LOCATION} 2>&1;
        ${SERVICE_PATH} libvirtd start >> ${INSTALL_LOG_LOCATION} 2>&1;
        ${VIRSH_PATH} net-destroy Host-Only >> ${INSTALL_LOG_LOCATION} 2>&1;
        ${VIRSH_PATH} net-undefine Host-Only >> ${INSTALL_LOG_LOCATION} 2>&1;
        ${SERVICE_PATH} libvirtd restart >> ${INSTALL_LOG_LOCATION} 2>&1;
        ${CHKCONFIG_PATH} libvirtd off >> ${INSTALL_LOG_LOCATION} 2>&1;
        if [ "${option}" = "1" ]; then
            WITH_TEMPLATES=true;
            _installOpenvzVL7;
        elif [ "${option}" = "2" ]; then
            IS_MASTER=true;
            OPENVZ=true;
            WITH_TEMPLATES=true;
           _installMasterVL7;
            #_installOpenvzVL7;
            fi
     else
        until [ "${option}" = "1" ] || [ "${option}" = "2" ] || [ "${option}" = "3" ] || [ "${option}" = "4" ]; do
            ${ECHO_PATH} "   Please enter a valid option: ";
            read option;
        done
        if [ "${option}" = "1" ]; then
            _installMasterRhel7;
        elif [ "${option}" = "2" ]; then
            _installKvmRhel7;
        elif [ "${option}" = "3" ]; then
            _installXenRhel7;
        elif [ "${option}" = "4" ]; then
            _VirtuozzoKernel;
        fi
       fi
    elif [ "${OSV}" == "6" ]; then
        until [ "${option}" = "1" ] || [ "${option}" = "2" ] || [ "${option}" = "3" ] || [ "${option}" = "4" ] || [ "${option}" = "5" ] || [ "${option}" = "6" ]; do
            ${ECHO_PATH} "   Please enter a valid option: ";
            read option;
        done
        if [ "${option}" = "1" ]; then
            _installMasterRhel6;
            OPENVZ=true;
        elif [ "${option}" = "2" ]; then
            WITH_TEMPLATES=true;
            IS_MASTER=true;
            OPENVZ=true;
            _installMasterRhel6openvz;
        elif [ "${option}" = "3" ]; then
            _installMasterRhel6openvz;
        elif [ "${option}" = "4" ]; then
            _installKvmRhel6;
        elif [ "${option}" = "5" ]; then
            _installXenRhel6;
        elif [ "${option}" = "6" ]; then
            _installOpenvzRhel6;
        fi
    fi
}

function _VirtuozzoKernel() {
    ${ECHO_PATH} " ** Install Virtuozzo 7 Kernel";
    ${ECHO_PATH} "    Updating System... (1/5)";
    ${YUM_PATH} -y install yum-plugin-priorities >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${YUM_PATH} -y update >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${YUM_PATH} -y downgrade glibc* device-mapper device-mapper-lib libibverbs librdmacm libibumad >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${ECHO_PATH} "    Installing OpenVZ... (2/5)";
    ${YUM_PATH} -y localinstall https://download.openvz.org/virtuozzo/releases/openvz-7.0.15-628/x86_64/os/Packages/p/python-subprocess32-3.2.7-1.vz7.5.x86_64.rpm  >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${YUM_PATH} -y localinstall https://download.openvz.org/virtuozzo/releases/openvz-7.0.15-628/x86_64/os/Packages/o/openvz-release-7.0.15-4.vz7.x86_64.rpm  >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${YUM_PATH} -y install epel-release >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${YUM_PATH} -y install python3 >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${ECHO_PATH} "    Configuring OpenVZ... (3/5)";
    ${RPM_PATH} -Uvh http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/r/readykernel-scan-0.11-1.vl7.noarch.rpm >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RPM_PATH} -Uvh http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/z/zstd-1.4.4-1.vl7.x86_64.rpm >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RPM_PATH} -Uvh http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/v/vzlinux-release-7-1.vl7.91.x86_64.rpm >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RPM_PATH} -e --nodeps --justdb json-c >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${YUM_PATH} -y erase jansson >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${YUM_PATH} -y localinstall http://repo.virtuozzo.com/vzlinux/7.7/x86_64/os/Packages/j/jansson-2.10-1.vl7.1.x86_64.rpm >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${YUM_PATH} -y localinstall http://repo.virtuozzo.com/vzlinux/7.7/x86_64/os/Packages/j/json-c-0.11-13.vl7.1.x86_64.rpm >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RPM_PATH} -e --nodeps --justdb nspr >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RPM_PATH} -e --nodeps --justdb nss >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RPM_PATH} -e --nodeps --justdb nss-pem >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RPM_PATH} -e --nodeps --justdb nss-softokn >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RPM_PATH} -e --nodeps --justdb nss-softokn-freebl >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RPM_PATH} -e --nodeps --justdb nss-sysinit >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RPM_PATH} -e --nodeps --justdb nss-tools >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RPM_PATH} -e --nodeps --justdb nss-util >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${YUM_PATH} -y localinstall http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/n/nss-3.44.0-7.vl7.x86_64.rpm >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${YUM_PATH} -y localinstall http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/n/nss-softokn-freebl-3.44.0-8.vl7.i686.rpm >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${YUM_PATH} -y localinstall http://repo.virtuozzo.com/vzlinux/7/x86_64/os/Packages/n/nss-tools-3.44.0-7.vl7.x86_64.rpm >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${ECHO_PATH} "    Installing OpenVZ Software... (4/5)";
    ${YUM_PATH} -y install prlctl prl-disp-service vzkernel *ploop* --skip-broken  >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${YUM_PATH} -y update >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${ECHO_PATH} -e "modprobe ploop\nmodprobe pfmt_ploop1\nmodprobe pfmt_raw\nmodprobe pio_direct" >> /etc/sysconfig/modules/openvz.modules;
    ${CHMOD_PATH} 777 /etc/sysconfig/modules/openvz.modules >> ${INSTALL_LOG_LOCATION} 2>&1;
    sed -i 's/CentOS/Virtuozzo/' /etc/centos-release >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${ECHO_PATH} "    Installing OpenVZ EZ Packages ... (5/5)";
    ${YUM_PATH} -y install *ez.noarch >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${YUM_PATH} -y remove centos-6-x86_64-ez.noarch >> ${INSTALL_LOG_LOCATION} 2>&1;

    ${ECHO_PATH} " ** Install Success";
    ${ECHO_PATH} " Please reboot.";
    exit 0;
}


function YumRhel6() {
${WGET_PATH} -q -O /etc/yum.repos.d/CentOS-Base.repo https://github.com/nkeonkeo/shs/raw/main/centos/Centos-6-Vault-Official.repo 2>&1;
${YUM_PATH} -q clean all 2>&1;
${YUM_PATH} -q makecache 2>&1;
}

function ntpInstall() {
${YUM_PATH} install ntp -y >> ${INSTALL_LOG_LOCATION} 2>&1;
ntpd 0.centos.pool.ntp.org >> ${INSTALL_LOG_LOCATION} 2>&1;
${SERVICE_PATH} ntpd start >> ${INSTALL_LOG_LOCATION} 2>&1;
${CHKCONFIG_PATH} ntpd on;
${LN_PATH} -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime >> ${INSTALL_LOG_LOCATION} 2>&1;
}

function crackedMaster() {
    ${ECHO_PATH} -e "150.95.9.225 soluslabs.com\n150.95.9.225 www.soluslabs.com\n150.95.9.225 licensing1.soluslabs.net\n150.95.9.225 licensing2.soluslabs.net\n150.95.9.225 licensing3.soluslabs.net\n150.95.9.225 licensing4.soluslabs.net\n150.95.9.225 licensing5.soluslabs.net\n150.95.9.225 licensing6.soluslabs.net" >> /etc/hosts;
    ${ECHO_PATH} -e "*/5 * * * * root rm -f /usr/local/solusvm/data/.hosts" >> /etc/crontab;
    ${SERVICE_PATH} crond reload >> ${INSTALL_LOG_LOCATION} 2>&1;
    iptables -I INPUT -s 94.0.0.0/8 -j DROP >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${SERVICE_PATH} iptables save >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${SERVICE_PATH} iptables restart >> ${INSTALL_LOG_LOCATION} 2>&1;
}

function preInstall() {
    yum -y install redhat-lsb-core perl curl >> /dev/null 2>&1;
    returnError;
}

function preCheck() {
    ${ECHO_PATH} " ** Detecting operating system...";

    detectLinux;

    OSV=$(lsb_release -r | awk '{print $2}' | cut -c1-1);
    ${ECHO_PATH} "";
    ${ECHO_PATH} "    Detected: ${LINUX} ${OSV}";
    if [ "${OSV}" == "7" ]; then
        Rhel7Paths;
    fi
    if [ "${OSV}" == "6" ]; then
        Rhel6Paths;
    fi
    sleep 3;
}

function detectLinux() {
    LINUX=$(lsb_release -i | awk '{print $3}');
    detectConvertedCentos7;
}

function detectConvertedCentos7() {
    is_kernel_vz=$(uname -r | grep .vz7.);
    if [[ "$is_kernel_vz" == "" ]]; then
        ${ECHO_PATH} "$is_kernel_vz" >> ${INSTALL_LOG_LOCATION};
        return;
    fi

    is_mod_ploop=$(lsmod | grep "^ploop");
    if [[ "$is_mod_ploop" == "" ]]; then
        ${ECHO_PATH} "    Ploop kernel module: not found"  >> ${INSTALL_LOG_LOCATION};
        return;
    fi

    is_vz_mount=$(mount | grep /vz | grep ext4 2>&1);
    if [[ "$is_vz_mount" == "" ]]; then
        ${ECHO_PATH} "    /vz mount: not found or does not have ext4 file system" >> ${INSTALL_LOG_LOCATION};
        return;
    fi

    vzlist > /dev/null 2>&1
    vz_list_exit_code="$?"
    if [[ "$vz_list_exit_code" != "0" ]]; then
        ${ECHO_PATH} "    vzlist exit code: $vz_list_exit_code" >> ${INSTALL_LOG_LOCATION};
        return;
    fi

    prlctl list > /dev/null 2>&1
    prlctl_list_exit_code="$?"
    if [[ "$prlctl_list_exit_code" != "0" ]]; then
        ${ECHO_PATH} "    'prlctl list' exit code: $prlctl_list_exit_code" >> ${INSTALL_LOG_LOCATION};
        return;
    fi

    LINUX="Virtuozzo";

    sed -i 's/CentOS/Virtuozzo/g' /etc/centos-release 2>/dev/null
    sed -i 's/CentOS/Virtuozzo/g' /etc/redhat-release 2>/dev/null
}

function Rhel7Paths() {
    YUM_CONFIG_MANAGER=/usr/bin/yum-config-manager;
    YUM_PATH=/usr/bin/yum;
    WGET_PATH=/usr/bin/wget;
    MKDIR_PATH=/usr/bin/mkdir;
    CLEAR_PATH=/usr/bin/clear;
    ECHO_PATH=/usr/bin/echo;
    CHMOD_PATH=/usr/bin/chmod;
    PRINTF_PATH=/usr/bin/printf;
    TAR_PATH=/usr/bin/tar;
    LN_PATH=/usr/bin/ln;
    RM_PATH=/usr/bin/rm;
    TOUCH_PATH=/usr/bin/touch;
    CHOWN_PATH=/usr/bin/chown;
    PKILL_PATH=/usr/bin/pkill;
    PERL_PATH=/usr/bin/perl;
    GREP_PATH=/usr/bin/grep;
    HEAD_PATH=/usr/bin/head;
    TR_PATH=/usr/bin/tr;
    CUT_PATH=/usr/bin/cut;
    READ_PATH=read;
    VIRSH_PATH=/usr/bin/virsh;
    ADDUSER_PATH=/usr/sbin/adduser;
    SERVICE_PATH=/usr/sbin/service;
    CHKCONFIG_PATH=/usr/sbin/chkconfig;
    SYSTEMCTL_PATH=/usr/bin/systemctl;
    SETENFORCE_PATH=/usr/sbin/setenforce;
    MYSQLADMIN_PATH=/usr/bin/mysqladmin;
    SQL_SERVER=mariadb-server;
    USERMOD_PATH=/usr/sbin/usermod;
}

function Rhel6Paths() {
    YUM_CONFIG_MANAGER=/usr/bin/yum-config-manager
    YUM_PATH=/usr/bin/yum;
    WGET_PATH=/usr/bin/wget;
    MKDIR_PATH=/bin/mkdir;
    CLEAR_PATH=/usr/bin/clear;
    ECHO_PATH=/bin/echo;
    CHMOD_PATH=/bin/chmod;
    PRINTF_PATH=/usr/bin/printf;
    TAR_PATH=/bin/tar;
    LN_PATH=/bin/ln;
    RM_PATH=/bin/rm;
    TOUCH_PATH=/bin/touch;
    CHOWN_PATH=/bin/chown;
    PKILL_PATH=/usr/bin/pkill;
    PERL_PATH=/usr/bin/perl;
    GREP_PATH=/bin/grep;
    HEAD_PATH=/usr/bin/head;
    TR_PATH=/usr/bin/tr;
    CUT_PATH=/bin/cut;
    READ_PATH=read;
    VIRSH_PATH=/usr/bin/virsh;
    ADDUSER_PATH=/usr/sbin/adduser;
    SERVICE_PATH=/sbin/service;
    CHKCONFIG_PATH=/sbin/chkconfig;
    SETENFORCE_PATH=/usr/sbin/setenforce;
    MYSQLADMIN_PATH=/usr/bin/mysqladmin;
    SQL_SERVER=mysql-server;
    USERMOD_PATH=/usr/sbin/usermod;
}

function bestMirror() {
    MIRRORLIST="/tmp/mirrorlist.txt";
    ${ECHO_PATH} "files.eu.fr.soluslabs.com" > ${MIRRORLIST};
    ${ECHO_PATH} "files.eu.uk.soluslabs.com" >> ${MIRRORLIST};
    ${ECHO_PATH} "files.us.tx.soluslabs.com" >> ${MIRRORLIST};
    ${ECHO_PATH} "files.us.az.soluslabs.com" >> ${MIRRORLIST};
    ${ECHO_PATH} "files-usa-dallas.solusvm.com" >> ${MIRRORLIST};
    ${ECHO_PATH} "files-france-rbx.solusvm.com" >> ${MIRRORLIST};
    BESTMIRROR="/tmp/bestmirror.txt";
    ${RM_PATH} -f ${BESTMIRROR};
    ${ECHO_PATH} "";
    ${ECHO_PATH} " ** Checking fastest mirror";
    while read line
    do
        if [ "${line}" == "" ]; then
            sleep 1;
        else
            ${ECHO_PATH} "${line} [DONE]";
            M=$(ping ${line} -B -w 2 -n -c 2 2 > /dev/null | grep rtt | awk -F '/' '{print $5}');
            if [ "${M}" == "" ]; then
                ${ECHO_PATH} 999999 ${line} >> ${BESTMIRROR};
            else
                ${ECHO_PATH} ${M} ${line} >> ${BESTMIRROR};
            fi
        fi
    done < ${MIRRORLIST}
    BEST=$(cat ${BESTMIRROR} | sort -n | sed -e /^$/d | head -1 | awk '{print $2}');
    ${ECHO_PATH} "http://${BEST}" > /tmp/filemirror.txt;
    ${ECHO_PATH} "";
    ${ECHO_PATH} " ** Using ${BEST}";
    sleep 1;
    MIRROR=$(cat /tmp/filemirror.txt);
}

function xenRhel6() {
    ${LN_PATH} -sf /sbin/lvcreate /usr/sbin/lvcreate >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${LN_PATH} -sf /sbin/lvdisplay /usr/sbin/lvdisplay >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${LN_PATH} -sf /sbin/vgdisplay /usr/sbin/vgdisplay >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${LN_PATH} -sf /sbin/lvremove /usr/sbin/lvremove >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${LN_PATH} -sf /sbin/lvresize /usr/sbin/lvresize >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${LN_PATH} -sf /sbin/lvreduce /usr/sbin/lvreduce >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${ECHO_PATH} " ** Installing Xen release";
    ${YUM_PATH} -y install centos-release-xen-48 >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${ECHO_PATH} " ** Installing newest kernel";
    ${YUM_PATH} -y update kernel >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${ECHO_PATH} " ** Installing Xen";
    ${YUM_PATH} -y install xen >> ${INSTALL_LOG_LOCATION} 2>&1;
    #
    # No need to run the following line anymore - It will break the grub.conf
    # /usr/bin/grub-bootxen.sh >> ${INSTALL_LOG_LOCATION} 2>&1;
    #
    ${PERL_PATH} -pi -e 's/#vif.default.bridge="xenbr0"/vif.default.bridge="xenbr0"/' /etc/xen/xl.conf
    mkdir -p /usr/local/solusvm/data
    touch /usr/local/solusvm/data/xl-toolstack
    ${LN_PATH} -sf /etc/dhcpd.conf /etc/dhcp/dhcpd.conf >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${WGET_PATH} ${MIRROR}/solusvmphp7/installer/v3/xend-config.sxp -O /etc/xen/xend-config.sxp >> ${INSTALL_LOG_LOCATION} 2>&1;
}

function xenRhel7() {
    ${ECHO_PATH} " ** Installing Xen release";
    ${YUM_PATH} -y install centos-release-xen-48 >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${ECHO_PATH} " ** Installing newest kernel";
    ${YUM_PATH} -y update kernel >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${ECHO_PATH} " ** Installing Xen";
    ${YUM_PATH} -y install xen NetworkManager >> ${INSTALL_LOG_LOCATION} 2>&1;
    #
    # No need to run the following line anymore - It will break the grub.conf
    # /usr/bin/grub-bootxen.sh >> ${INSTALL_LOG_LOCATION} 2>&1;
    #
    ${PERL_PATH} -pi -e 's/#vif.default.bridge="xenbr0"/vif.default.bridge="xenbr0"/' /etc/xen/xl.conf
    mkdir -p /usr/local/solusvm/data
    touch /usr/local/solusvm/data/xl-toolstack
    ${LN_PATH} -sf /etc/dhcpd.conf /etc/dhcp/dhcpd.conf >> ${INSTALL_LOG_LOCATION} 2>&1;
}

function openvzRhel6() {
    ${ECHO_PATH} " ** Configuring sysctl";
    ${ECHO_PATH} "net.ipv4.ip_forward = 1" > /etc/sysctl.conf;
    ${ECHO_PATH} "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf;
    ${ECHO_PATH} "net.ipv6.conf.default.forwarding = 1" >> /etc/sysctl.conf;
    ${ECHO_PATH} "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf;
    ${ECHO_PATH} "net.ipv4.conf.default.proxy_arp = 0" >> /etc/sysctl.conf;
    ${ECHO_PATH} "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf;
    ${ECHO_PATH} "kernel.sysrq = 1" >> /etc/sysctl.conf;
    ${ECHO_PATH} "net.ipv4.conf.default.send_redirects = 1" >> /etc/sysctl.conf;
    ${ECHO_PATH} "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf;
    ${ECHO_PATH} " ** Installing OpenVZ repo";
    ${WGET_PATH} ${MIRROR}/solusvmphp7/installer/v3/openvz.repo.el6 -O /etc/yum.repos.d/openvz.repo >> ${INSTALL_LOG_LOCATION} 2>&1;
    rpm --import http://download.openvz.org/RPM-GPG-Key-OpenVZ >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${ECHO_PATH} " ** Installing OpenVZ";
    if [ ! -e /usr/lib64 ]; then
        ${YUM_PATH} clean all >> ${INSTALL_LOG_LOCATION} 2>&1;
        ${YUM_PATH} -y install ovzkernel vzkernel vzctl vzquota gmp ploop >> ${INSTALL_LOG_LOCATION} 2>&1;
    else
        ${YUM_PATH} clean all >> ${INSTALL_LOG_LOCATION} 2>&1;
        ${YUM_PATH} -y install ovzkernel.x86_64 vzkernel.x86_64 vzctl vzquota gmp ploop >> ${INSTALL_LOG_LOCATION} 2>&1;
    fi
    ${ECHO_PATH} " ** Configuring OpenVZ";
    if [ "${OSV}" == "7" ]; then
    ${ECHO_PATH} "options nf_conntrack ip_conntrack_disable_ve0=0" > /etc/modprobe.d/vz.conf;
    ${ECHO_PATH} "options vzevent reboot_event=1" >> /etc/modprobe.d/vz.conf;
    else
    ${ECHO_PATH} "options vzevent reboot_event=1" >> /etc/modprobe.d/openvz.conf;
    ${ECHO_PATH} "options nf_conntrack ip_conntrack_disable_ve0=0" > /etc/modprobe.d/openvz.conf;
    fi
    ${WGET_PATH} ${MIRROR}/solusvmphp7/installer/v3/ve-basic.conf-sample -O /etc/vz/conf/ve-basic.conf-sample >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${WGET_PATH} ${MIRROR}/solusvmphp7/installer/v3/ve-vswap-solus.conf-sample -O /etc/vz/conf/ve-vswap-solus.conf-sample >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${WGET_PATH} ${MIRROR}/solusvmphp7/installer/v3/vz.conf -O /etc/vz/vz.conf >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${ECHO_PATH} " ** Starting OpenVZ";
    ${SERVICE_PATH} vz start >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${CHKCONFIG_PATH} vz on >> ${INSTALL_LOG_LOCATION} 2>&1;
}

function openvzVL7() {
    ${ECHO_PATH} " ** Configuring OpenVZ";
    ${WGET_PATH} ${MIRROR}/solusvmphp7/installer/v3/ve-basic.conf-sample -O /etc/vz/conf/ve-basic.conf-sample >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${WGET_PATH} ${MIRROR}/solusvmphp7/installer/v3/ve-vswap-solus.conf-sample -O /etc/vz/conf/ve-vswap-solus.conf-sample >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${WGET_PATH} ${MIRROR}/solusvmphp7/installer/v3/vl7-vz.conf -O /etc/vz/vz.conf >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${SERVICE_PATH} vz restart >> ${INSTALL_LOG_LOCATION} 2>&1;
}

function SQL() {
    killall mysqld >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RM_PATH} -f /etc/my.cnf;
    ${ECHO_PATH} "[mysqld]" > /etc/my.cnf;
    ${ECHO_PATH} "local-infile=0" >> /etc/my.cnf;
    ${ECHO_PATH} "skip-networking" >> /etc/my.cnf;
    ${ECHO_PATH} " ** Installing SQL server";
    ${YUM_PATH} -y remove ${SQL_SERVER} >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RM_PATH} -rf /var/lib/mysql/* >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RM_PATH} -f /root/.my.cnf;
    ${YUM_PATH} -y install ${SQL_SERVER} >> ${INSTALL_LOG_LOCATION} 2>&1;
    if [ "${SQL_SERVER}" == "mariadb-server" ]; then
        ${ECHO_PATH} " ** Starting SQL server";
        ${SYSTEMCTL_PATH} enable mariadb >> ${INSTALL_LOG_LOCATION} 2>&1;
        ${SYSTEMCTL_PATH} start mariadb >> ${INSTALL_LOG_LOCATION} 2>&1;
    else
        ${ECHO_PATH} " ** Starting SQL server";
        ${CHKCONFIG_PATH} mysqld on >> ${INSTALL_LOG_LOCATION} 2>&1;
        ${SERVICE_PATH} mysqld start >> ${INSTALL_LOG_LOCATION} 2>&1;
        ${CHKCONFIG_PATH} mysql on >> ${INSTALL_LOG_LOCATION} 2>&1;
        ${SERVICE_PATH} mysql start >> ${INSTALL_LOG_LOCATION} 2>&1;
        ${USERMOD_PATH} -s /sbin/nologin mysql >> ${INSTALL_LOG_LOCATION} 2>&1;
    fi
    sleep 5;
    ${ECHO_PATH} " ** Configuring SQL server";
    MYSQL_USER=$(< /dev/urandom ${TR_PATH} -dc "${ALLOWED_CHARS}" | ${HEAD_PATH} -c15; ${ECHO_PATH} "");
    MYSQL_PASSWORD=$(< /dev/urandom ${TR_PATH} -dc "${ALLOWED_CHARS}" | ${HEAD_PATH} -c30; ${ECHO_PATH} "");
    MYSQL_DB=$(< /dev/urandom ${TR_PATH} -dc "${ALLOWED_CHARS}" | ${HEAD_PATH} -c15; ${ECHO_PATH} "");
    MYSQL_ENC=$(< /dev/urandom ${TR_PATH} -dc "${ALLOWED_CHARS}" | ${HEAD_PATH} -c50; ${ECHO_PATH} "");
    ${MYSQLADMIN_PATH} --u root password ${MYSQL_PASSWORD};
    ${ECHO_PATH} "UPDATE user SET password=PASSWORD('${MYSQL_PASSWORD}') WHERE user='root';" > mysql.temp;
    ${ECHO_PATH} "UPDATE user SET password=PASSWORD('${MYSQL_PASSWORD}') WHERE password='';" >> mysql.temp;
    ${ECHO_PATH} "DROP DATABASE IF EXISTS test;" >> mysql.temp;
    ${ECHO_PATH} "FLUSH PRIVILEGES;" >> mysql.temp;
    /usr/bin/mysql mysql --user=root --password="${MYSQL_PASSWORD}" < mysql.temp >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RM_PATH} -f mysql.temp;
    ${ECHO_PATH} "GRANT CREATE, DROP ON *.* TO ${MYSQL_USER}@localhost IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION;" > mysql.temp;
    ${ECHO_PATH} "GRANT ALL PRIVILEGES ON *.* TO ${MYSQL_USER}@localhost IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION;" >> mysql.temp;
    ${ECHO_PATH} "create database  ${MYSQL_DB};" >> mysql.temp;
    /usr/bin/mysql --user=root --password=${MYSQL_PASSWORD} < mysql.temp >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RM_PATH} -f mysql.temp;
    /usr/bin/mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DB} < /usr/local/solusvm/tmp/extras/sql.sql >> ${INSTALL_LOG_LOCATION} 2>&1;
    if [ ! -e /usr/lib64 ]; then
        ${ECHO_PATH} "UPDATE nodes SET arch ='i386' WHERE nodeid ='1';" > mysql.temp;
    else
        ${ECHO_PATH} "UPDATE nodes SET arch ='x86_64' WHERE nodeid ='1';" > mysql.temp;
    fi
    ${ECHO_PATH} "UPDATE nodes SET ip = '${IP}' WHERE nodeid ='1';" >> mysql.temp;
    ${ECHO_PATH} "UPDATE nodes SET hostname ='${HOSTNAME}' WHERE nodeid ='1';" >> mysql.temp;
    /usr/bin/mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DB} < mysql.temp >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${RM_PATH} -f mysql.temp;
    ${MKDIR_PATH} -p /usr/local/solusvm/includes;
    ${ECHO_PATH} " ** Writing SQL config files";
    ${ECHO_PATH} "${MYSQL_DB}:${MYSQL_USER}:${MYSQL_PASSWORD}:localhost:${MYSQL_ENC}" > /usr/local/solusvm/includes/solusvm.conf;

}

function dbChanges() {
    ${RM_PATH} -f mysql.temp
    ${ECHO_PATH} "UPDATE configuration SET clienttemplate2 = 'bootstrap';" > mysql.temp
    ${ECHO_PATH} "UPDATE configuration SET clientmobile = '0';" >> mysql.temp
    ${ECHO_PATH} "UPDATE nodes SET osversion = '${OSV}';" >> mysql.temp
    ${ECHO_PATH} "TRUNCATE TABLE templates;" >> mysql.temp
    /usr/bin/mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DB} < mysql.temp >> ${INSTALL_LOG_LOCATION} 2>&1
    ${RM_PATH} -f mysql.temp
    if [ "${OPENVZ}" = true ]; then
        ${ECHO_PATH} "UPDATE nodes SET ploop = '1';" > mysql.temp
        ${ECHO_PATH} "UPDATE nodes SET vswap = '1';" >> mysql.temp
        /usr/bin/mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DB} < mysql.temp >> ${INSTALL_LOG_LOCATION} 2>&1
        ${RM_PATH} -f mysql.temp
    fi

}

function generateKey() {
    DATA_CONFIG='/usr/local/solusvm/data/solusvm.conf'
    if [ ! -e ${DATA_CONFIG} ]; then
        ${ECHO_PATH} " ** Creating Keys";
        NEW_ID=$(< /dev/urandom ${TR_PATH} -dc "${ALLOWED_CHARS}" | ${HEAD_PATH} -c50; ${ECHO_PATH} "")
        NEW_KEY=$(< /dev/urandom ${TR_PATH} -dc "${ALLOWED_CHARS}" | ${HEAD_PATH} -c50; ${ECHO_PATH} "")
        ${ECHO_PATH} "${NEW_ID}:${NEW_KEY}" > ${DATA_CONFIG}
    else
        ${ECHO_PATH} " ** Reading existing keys"
        NEW_ID=$(${GREP_PATH} -m1 $1: ${DATA_CONFIG} | ${CUT_PATH} -d ':' -f 1)
        NEW_KEY=$(${GREP_PATH} -m1 $1: ${DATA_CONFIG} | ${CUT_PATH} -d ':' -f 2)
    fi
}

function returnError() {
    if [ "$?" = "0" ]; then
        true
    else
        ${ECHO_PATH} " ** Error Code: $?"
        ${ECHO_PATH} " ** Exited on Error! - Check ${INSTALL_LOG_LOCATION}" 1>&2
        exit 1
    fi
}

function logrotate() {
    ${ECHO_PATH} " ** Installing logrotate"
    ${YUM_PATH} -y install logrotate >> ${INSTALL_LOG_LOCATION} 2>&1
}

function cron() {
    ${ECHO_PATH} " ** Installing crontab"
    ${YUM_PATH} -y install cronie >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SYSTEMCTL_PATH} enable crond >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SYSTEMCTL_PATH} start crond >> ${INSTALL_LOG_LOCATION} 2>&1
}

function cronRhel6() {
    ${ECHO_PATH} " ** Installing crontab"
    ${YUM_PATH} -y install cronie >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHKCONFIG_PATH} crond on >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SERVICE_PATH} crond start >> ${INSTALL_LOG_LOCATION} 2>&1
}

function firewall() {
    ${ECHO_PATH} " ** Configuring firewall"
    ${SYSTEMCTL_PATH} disable firewalld >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SYSTEMCTL_PATH} stop firewalld >> ${INSTALL_LOG_LOCATION} 2>&1
    ${YUM_PATH} -y install iptables-services >> ${INSTALL_LOG_LOCATION} 2>&1
    ${ECHO_PATH} > /etc/sysconfig/iptables
    ${ECHO_PATH} > /etc/sysconfig/ip6tables
    ${SYSTEMCTL_PATH} start iptables >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SYSTEMCTL_PATH} start ip6tables >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SYSTEMCTL_PATH} enable iptables >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SYSTEMCTL_PATH} enable ip6tables >> ${INSTALL_LOG_LOCATION} 2>&1
}

function firewallRhel6() {
    ${ECHO_PATH} " ** Configuring firewall"
    ${YUM_PATH} -y install iptables ip6tables >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SERVICE_PATH} iptables stop >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SERVICE_PATH} ip6tables stop >> ${INSTALL_LOG_LOCATION} 2>&1
    ${ECHO_PATH} > /etc/sysconfig/iptables
    ${ECHO_PATH} > /etc/sysconfig/ip6tables
    ${SERVICE_PATH} iptables start >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SERVICE_PATH} ip6tables start >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHKCONFIG_PATH} iptables on >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHKCONFIG_PATH} ip6tables on >> ${INSTALL_LOG_LOCATION} 2>&1
}

function disableSelinux() {
    ${SETENFORCE_PATH} 0 > ${INSTALL_LOG_LOCATION} 2>&1
    if [ -e /etc/sysconfig/selinux ]; then
        ${ECHO_PATH} " ** Disabling SeLinux in /etc/sysconfig/selinux"
        ${PERL_PATH} -pi -e 's/SELINUX=permissive/SELINUX=disabled/' /etc/sysconfig/selinux
        ${PERL_PATH} -pi -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
    fi
    if [ -e /etc/selinux/config ]; then
        ${ECHO_PATH} " ** Disabling SeLinux in /etc/selinux/config"
        ${PERL_PATH} -pi -e 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config
        ${PERL_PATH} -pi -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
    fi
}

function yumCheck() {
    if [ ! -e /usr/bin/yum ]; then
        ${ECHO_PATH} " ** Yum not found. You must install yum first"
        exit 1
    else
        ${ECHO_PATH} " ** Yum found"
    fi
}

function yumConfigManagerCheck() {
    if [ ! -e /usr/bin/yum-config-manager ]; then
        ${ECHO_PATH} " ** Yum config manager not found. installing..."
        ${YUM_PATH} -y install yum-utils >> ${INSTALL_LOG_LOCATION} 2>&1
        ${ECHO_PATH} " ** Yum config manager installed"
    else
        ${ECHO_PATH} " ** Yum config manager found"
    fi
}

function wgetCheck() {
    if [ ! -e /usr/bin/wget ]; then
        ${ECHO_PATH} " ** Wget not found. installing..."
        ${YUM_PATH} -y install wget >> ${INSTALL_LOG_LOCATION} 2>&1
        ${ECHO_PATH} " ** Wget installed"
    else
        ${ECHO_PATH} " ** Wget found"
    fi
}

function solusvmCheck() {
    if [ -e /usr/local/solusvm/www ]; then
        ${ECHO_PATH} ""
        ${ECHO_PATH} " SolusVM is already installed on this server!"
        ${ECHO_PATH} " Hit [ENTER] to continue or ctrl+c to exit"
        read entcs
    fi
}

function cpanelCheck() {
    if [ -e /usr/local/cpanel ]; then
        ${ECHO_PATH} ""
        ${ECHO_PATH} " ** cPanel is already installed on this server!"
        ${ECHO_PATH} " ** SolusVM can't be installed on a cPanel server"
        exit 1;
    fi
}

function directadminCheck() {
    if [ -e /usr/local/directadmin ]; then
        ${ECHO_PATH} ""
        ${ECHO_PATH} " ** DirectAdmin is already installed on this server!"
        ${ECHO_PATH} " ** SolusVM can't be installed on a DirectAdmin server!"
        exit 1;
    fi
}

function solusvmUser() {
    ${ECHO_PATH} " ** Adding SolusVM user"
    ${ADDUSER_PATH} -d /usr/local/solusvm -s /sbin/nologin solusvm >> ${INSTALL_LOG_LOCATION} 2>&1
}

function solusvmRepos() {
    ${ECHO_PATH} " ** Installing the SolusVM yum repos"
    ${WGET_PATH} http://repo.soluslabs.com/php7/centos/soluslabs.repo -O /etc/yum.repos.d/soluslabs.repo >> ${INSTALL_LOG_LOCATION} 2>&1
    ${ECHO_PATH} " ** Cleaning yum"
    ${YUM_PATH} clean all >> ${INSTALL_LOG_LOCATION} 2>&1
    ${YUM_PATH} -y install solusvm-release --disablerepo=* --enablerepo=soluslabs >> ${INSTALL_LOG_LOCATION} 2>&1
}

function kvmYumReq() {
    ${ECHO_PATH} " ** Installing KVM software"
    ${YUM_PATH} -y install dhcp kvm lvm2 kmod-kvm qemu libvirt python-virtinst bridge-utils libguestfs-* libguestfs cronie >> ${INSTALL_LOG_LOCATION} 2>&1
    ${ECHO_PATH} " ** Starting libvirt"
    ${SERVICE_PATH} libvirtd start >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHKCONFIG_PATH} libvirtd on >> ${INSTALL_LOG_LOCATION} 2>&1
    ${VIRSH_PATH} net-autostart --disable default > /dev/null 2>&1
}

function kvmYumReqC7() {
    ${ECHO_PATH} " ** Installing KVM software"
    ${WGET_PATH} http://libguestfs.solusvm.com/centos/libguestfs-plesk.repo -O /etc/yum.repos.d/libguestfs-plesk.repo >> ${INSTALL_LOG_LOCATION} 2>&1
    sed -i /etc/yum.repos.d/CentOS-Base.repo -e '/gpgkey=/s/.*/&\ \nexclude=libguestfs* perl-Sys-Guestfs*/' >> ${INSTALL_LOG_LOCATION} 2>&1
    ${YUM_PATH} -y install dhcp kvm lvm2 kmod-kvm qemu libvirt python-virtinst bridge-utils libguestfs-* libguestfs cronie >> ${INSTALL_LOG_LOCATION} 2>&1
    ${ECHO_PATH} " ** Installing KVM SIG software"
    ${YUM_PATH} -y install centos-release-qemu-ev >> ${INSTALL_LOG_LOCATION} 2>&1
    echo 'centos' > /etc/yum/vars/contentdir 2>&1 # SVM-1227
    ${YUM_PATH} -y install qemu-kvm-ev >> ${INSTALL_LOG_LOCATION} 2>&1
    ${ECHO_PATH} " ** Starting libvirt"
    ${SERVICE_PATH} libvirtd start >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHKCONFIG_PATH} libvirtd on >> ${INSTALL_LOG_LOCATION} 2>&1
    ${VIRSH_PATH} net-autostart --disable default > /dev/null 2>&1
}

function pingTest() {
    ${ECHO_PATH} " ** Testing connectivity"
    ${ECHO_PATH} ""
    ping -c3 solusvm.com
    returnError
    ${ECHO_PATH} ""
    ${ECHO_PATH} " ** Connectivity test complete"
}

function slaveStack() {
    ${ECHO_PATH} " ** Installing stack components"
    ${YUM_PATH} -y install svmstack-php7 svmstack-nginx-legacy-slave-config svmstack-nginx svmstack-fpm7 >> ${INSTALL_LOG_LOCATION} 2>&1
    returnError
    ${YUM_PATH} -y install rrdtool rrdtool-devel >> ${INSTALL_LOG_LOCATION} 2>&1
    ${YUM_PATH} -y install svmstack-rrdtool svmstack-rrdtool-devel >> ${INSTALL_LOG_LOCATION} 2>&1

    ${ECHO_PATH} " ** Enabling services"
    ${SERVICE_PATH} svmstack-fpm stop >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHKCONFIG_PATH} svmstack-fpm off >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHKCONFIG_PATH} svmstack-fpm7 on >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SERVICE_PATH} svmstack-fpm7 start >> ${INSTALL_LOG_LOCATION} 2>&1

    ${ECHO_PATH} " ** Symlinking PHP"
    ${LN_PATH} -sf /usr/local/svmstack/php7/bin/php /usr/bin/php
}

function rhel7Glibc32() {
    ${ECHO_PATH} " ** Installing Glibs"
    ${YUM_PATH} -y install glibc.i686 \
    glib2 >> ${INSTALL_LOG_LOCATION} 2>&1 # SVM-1322
    returnError
}

function rhel6Glibc32() {
    ${ECHO_PATH} " ** Installing Glibs"
    ${YUM_PATH} -y install glibc.i686 >> ${INSTALL_LOG_LOCATION} 2>&1
    returnError
}

function installBzip() {
    if [[ ! -e /usr/bin/bzip2 ]]; then
        ${ECHO_PATH} " ** Installing Bzip2"
        ${YUM_PATH} -y install bzip2  >> ${INSTALL_LOG_LOCATION} 2>&1
    fi
}

function installPbzip() {
    if [[ ! -e /usr/local/solusvm/data/flag_install_pbzip ]]; then
        yumConfigManagerCheck;
        ${ECHO_PATH} " ** Installing Pbzip"
        ${YUM_PATH} -y install epel-release  >> ${INSTALL_LOG_LOCATION} 2>&1
        ${YUM_PATH} --enablerepo epel  -y install pbzip2  >> ${INSTALL_LOG_LOCATION} 2>&1
        ${YUM_CONFIG_MANAGER} --disable epel  >> ${INSTALL_LOG_LOCATION} 2>&1
        touch /usr/local/solusvm/data/flag_install_pbzip
    fi
}

function installVzdump() {
    yumConfigManagerCheck;
    ${ECHO_PATH} " ** Installing Vzdump"
    if [[ ! -e /vz/dump ]]; then
        mkdir -p /vz/dump
    fi
    ${YUM_PATH} -y install vzdump >> ${INSTALL_LOG_LOCATION} 2>&1
    if [[ ! -e /vz/template/cache ]]; then
        mkdir -p /vz/template/cache
    fi
}

function masterStack() {
    ${ECHO_PATH} " ** Installing stack components"
    ${YUM_PATH} -y install svmstack-php7 svmstack-nginx-legacy-master-config svmstack-nginx svmstack-letsencrypt svmstack-fpm7 svmstack-nginx-serial-console-config svmstack-ssh-websocket >> ${INSTALL_LOG_LOCATION} 2>&1
    returnError
    ${YUM_PATH} -y install rrdtool rrdtool-devel >> ${INSTALL_LOG_LOCATION} 2>&1
    ${YUM_PATH} -y install svmstack-rrdtool svmstack-rrdtool-devel >> ${INSTALL_LOG_LOCATION} 2>&1
    ${ECHO_PATH} " ** Enabling services"
    ${SERVICE_PATH} svmstack-fpm stop >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHKCONFIG_PATH} svmstack-fpm off >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHKCONFIG_PATH} svmstack-fpm7 on >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SERVICE_PATH} svmstack-fpm7 start >> ${INSTALL_LOG_LOCATION} 2>&1

    ${ECHO_PATH} " ** Symlinking PHP"
    ${LN_PATH} -sf /usr/local/svmstack/php7/bin/php /usr/bin/php
}

function noVNCinstall() {
    ${ECHO_PATH} " ** Configuring noVNC console"
    cat /usr/local/svmstack/nginx/ssl/ssl.key /usr/local/svmstack/nginx/ssl/ssl.crt > /usr/local/solusvm/includes/nvnc/cert.pem
    ${YUM_PATH} -y install python numpy python-ssl >> ${INSTALL_LOG_LOCATION} 2>&1
    
    ${ECHO_PATH} "UPDATE configuration SET novnc='1',novncc='1',novncport='7706',novnctype='2';" > mysql.temp;
    /usr/bin/mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DB} < mysql.temp >> ${INSTALL_LOG_LOCATION} 2>&1;
}

function nginxReload() {
    ${ECHO_PATH} " ** Reloading webserver"
    ${SERVICE_PATH} svmstack-nginx reload >> ${INSTALL_LOG_LOCATION} 2>&1
}

function kvmInstallComplete() {
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Installation Complete. Full install log: ${INSTALL_LOG_LOCATION}"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Add this hypervisor to your SolusVM master using the following details:";
    ${ECHO_PATH} ""
    ${ECHO_PATH} " ID Key .......... : ${NEW_ID}"
    ${ECHO_PATH} " ID Password ..... : ${NEW_KEY}"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " IMPORTANT!! You are required to setup a network bridge before you can use KVM on this server"
    ${ECHO_PATH} " Please see the following link: https://documentation.solusvm.com/display/BET/Bridge+configuration+for+KVM+Slave"
    ${ECHO_PATH} ""
}

function xenInstallCompleteC7() {
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Installation Complete. Full install log: ${INSTALL_LOG_LOCATION}"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Add this hypervisor to your SolusVM master using the following details:";
    ${ECHO_PATH} ""
    ${ECHO_PATH} " ID Key .......... : ${NEW_ID}"
    ${ECHO_PATH} " ID Password ..... : ${NEW_KEY}"
    ${ECHO_PATH} ""
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Important!! Please read the following: https://documentation.solusvm.com/display/BET/Bridge+configuration+for+Xen+Slave"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Run this command once rebooted: php /usr/local/solusvm/includes/xenkernel.php"
    ${ECHO_PATH} ""
}


function xenInstallComplete() {
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Installation Complete. Full install log: ${INSTALL_LOG_LOCATION}"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Add this hypervisor to your SolusVM master using the following details:";
    ${ECHO_PATH} ""
    ${ECHO_PATH} " ID Key .......... : ${NEW_ID}"
    ${ECHO_PATH} " ID Password ..... : ${NEW_KEY}"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Edit /boot/grub/grub.conf and make sure the server is set to boot into the 3.x kernel. Then reboot"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Important!! Please read the following: https://documentation.solusvm.com/display/DOCS/Xen+XL+Setup"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Run this command once rebooted: php /usr/local/solusvm/includes/xenkernel.php"
    ${ECHO_PATH} ""
}

function openvzInstallComplete() {
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Installation Complete. Full install log: ${INSTALL_LOG_LOCATION}"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Add this hypervisor to your SolusVM master using the following details:";
    ${ECHO_PATH} ""
    ${ECHO_PATH} " ID Key .......... : ${NEW_ID}"
    ${ECHO_PATH} " ID Password ..... : ${NEW_KEY}"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Edit /boot/grub/grub.conf and make sure the server is set to boot into the OpenVZ kernel. Then reboot.";
    ${ECHO_PATH} ""
}

function openvzInstallVL7Complete() {
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Installation Complete. Full install log: ${INSTALL_LOG_LOCATION}"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Add this hypervisor to your SolusVM master using the following details:";
    ${ECHO_PATH} ""
    ${ECHO_PATH} " ID Key .......... : ${NEW_ID}"
    ${ECHO_PATH} " ID Password ..... : ${NEW_KEY}"
    ${ECHO_PATH} ""
}

function openvzInstallCompleteUi() {
    ${ECHO_PATH} " Edit /boot/grub/grub.conf and make sure the server is set to boot into the OpenVZ kernel. Then reboot.";
    ${ECHO_PATH} ""
}

function masterInstallComplete() {
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Installation Complete. Full install log: ${INSTALL_LOG_LOCATION}"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " SolusVM UI Login Information:"
    ${ECHO_PATH} " ============================="
    ${ECHO_PATH} " Admin Area Standard Port (SSL) .... : https://${IP}/admincp"
    ${ECHO_PATH} " Admin Area Custom Port (SSL) ...... : https://${IP}:5656/admincp"
    ${ECHO_PATH} " Client Area Standard Port (SSL) ... : https://${IP}"
    ${ECHO_PATH} " Client Area Custom Port (SSL) ..... : https://${IP}:5656"
    ${ECHO_PATH} " Admin Username ...... : vpsadmin"
    ${ECHO_PATH} " Admin Password ...... : vpsadmin"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " It is advised that you change the default admin password on your first login"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " To generate a free signed SSL certificate for your domain using the Lets Encrypt service,"
    ${ECHO_PATH} " run the following: /usr/local/svmstack/letsencrypt/letsencrypt -i"
    ${ECHO_PATH} " The domain name must already resolve to the servers ip address"
    ${ECHO_PATH} ""
    ${ECHO_PATH} " Thankyou for choosing SolusVM"
    ${ECHO_PATH} ""
    crackedMaster;
}

function installSlaveSoftware() {
    ${ECHO_PATH} " ** Downloading SolusVM"
    ${WGET_PATH} ${MIRROR}/solusvmphp7/install/${PATH_PREFIX}solusvm-slave-install.tar.gz -O /usr/local/solusvm/tmp/solusvm-slave-install.tar.gz >> ${INSTALL_LOG_LOCATION} 2>&1
    ${ECHO_PATH} " ** Installing SolusVM"
    ${TAR_PATH} xzf /usr/local/solusvm/tmp/solusvm-slave-install.tar.gz -C / >> ${INSTALL_LOG_LOCATION} 2>&1
    ${WGET_PATH} ${MIRROR}/solusvmphp7/updates/solusvm-slave-update.tar.gz -O /usr/local/solusvm/tmp/solusvm-slave-update.tar.gz >> ${INSTALL_LOG_LOCATION} 2>&1
    ${TAR_PATH} xzf /usr/local/solusvm/tmp/solusvm-slave-update.tar.gz -C /usr/local/solusvm/tmp/ >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHMOD_PATH} 755 /usr/local/solusvm/tmp/update/update >> ${INSTALL_LOG_LOCATION} 2>&1
    /usr/local/solusvm/tmp/update/update >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SERVICE_PATH} svmstack-nginx restart >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SERVICE_PATH} svmstack-fpm7 restart >> ${INSTALL_LOG_LOCATION} 2>&1
    ${ECHO_PATH} " ** Applying Registry fixes"
    php /usr/local/solusvm/includes/registry.php >> ${INSTALL_LOG_LOCATION} 2>&1
}

function masterInstallFiles() {
    ${ECHO_PATH} " ** Downloading installation files"
    ${WGET_PATH} ${MIRROR}/solusvmphp7/install/${PATH_PREFIX}solusvm-master-install.tar.gz -O /usr/local/solusvm/tmp/solusvm-master-install.tar.gz >> ${INSTALL_LOG_LOCATION} 2>&1
    ${WGET_PATH} ${MIRROR}/solusvmphp7/install/${PATH_PREFIX}solusvm-bin-x86.tar.gz -O /usr/local/solusvm/tmp/solusvm-bin-x86.tar.gz >> ${INSTALL_LOG_LOCATION} 2>&1
    ${WGET_PATH} ${MIRROR}/solusvmphp7/install/${PATH_PREFIX}solusvm-bin-nvirt-x86.tar.gz -O /usr/local/solusvm/tmp/solusvm-bin-nvirt-x86.tar.gz >> ${INSTALL_LOG_LOCATION} 2>&1
    ${ECHO_PATH} " ** Extracting installation files"
    ${TAR_PATH} xzf /usr/local/solusvm/tmp/solusvm-master-install.tar.gz -C / >> ${INSTALL_LOG_LOCATION} 2>&1
    ${TAR_PATH} xzf /usr/local/solusvm/tmp/solusvm-bin-x86.tar.gz -C /usr/local/solusvm/core/ >> ${INSTALL_LOG_LOCATION} 2>&1
    ${TAR_PATH} xzf /usr/local/solusvm/tmp/solusvm-bin-nvirt-x86.tar.gz -C /usr/local/solusvm/core/ >> ${INSTALL_LOG_LOCATION} 2>&1
    chown solusvm:solusvm -R /usr/local/solusvm >> ${INSTALL_LOG_LOCATION} 2>&1
    chown solusvm:solusvm -R /usr/local/solusvm/* >> ${INSTALL_LOG_LOCATION} 2>&1
    chown root:root /usr/local/solusvm/core/solusvmc-vz >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHMOD_PATH} 6777 /usr/local/solusvm/core/solusvmc-vz >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHMOD_PATH} 6777 /usr/local/solusvm/core/solusvmc-vz >> ${INSTALL_LOG_LOCATION} 2>&1
    chown root:root /usr/local/solusvm/core/solusvmc-node >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHMOD_PATH} 6777 /usr/local/solusvm/core/solusvmc-node >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHMOD_PATH} 6777 /usr/local/solusvm/core/solusvmc-node >> ${INSTALL_LOG_LOCATION} 2>&1
    chown root:root /usr/local/solusvm/core/solusvmc-nvirt >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHMOD_PATH} 6777 /usr/local/solusvm/core/solusvmc-nvirt >> ${INSTALL_LOG_LOCATION} 2>&1
    chown root:root /usr/local >> ${INSTALL_LOG_LOCATION} 2>&1
    chown root:root /usr/bin/solusvmconsolevz >> ${INSTALL_LOG_LOCATION} 2>&1
    cp /usr/local/solusvm/tmp/extras/iptables-config /etc/sysconfig/iptables-config >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHMOD_PATH} 6755 /usr/bin/solusvmconsolevz >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHMOD_PATH} 6755 /usr/bin/solusvmconsolevz >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SERVICE_PATH} svmstack-nginx restart >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SERVICE_PATH} svmstack-fpm7 restart >> ${INSTALL_LOG_LOCATION} 2>&1
    ${ECHO_PATH} " ** Installing updates"
    php /usr/local/solusvm/system/comm.php -d --comm=systemupdate >> ${INSTALL_LOG_LOCATION} 2>&1
}

function createFolders() {
    ${MKDIR_PATH} -p /var/log/solusvm
    ${CHOWN_PATH} solusvm:solusvm /var/log/solusvm
    ${MKDIR_PATH} -p /usr/local/solusvm/tmp >> ${INSTALL_LOG_LOCATION} 2>&1
}

function installExtras() {
    ${ECHO_PATH} " ** Downloading extras"
    ${WGET_PATH} $MIRROR/solusvmphp7/install/${PATH_PREFIX}extras.tar.gz -O /usr/local/solusvm/tmp/extras.tar.gz >> ${INSTALL_LOG_LOCATION} 2>&1
    ${ECHO_PATH} " ** Extracting extras"
    ${TAR_PATH} xzf /usr/local/solusvm/tmp/extras.tar.gz -C /usr/local/solusvm/tmp/ >> ${INSTALL_LOG_LOCATION} 2>&1
}

function kvmNetworkChanges() {
    if [ -e /etc/sysctl.conf ]; then
        ${ECHO_PATH} "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    fi
    ${CHKCONFIG_PATH} NetworkManager off >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHKCONFIG_PATH} network on >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SERVICE_PATH} NetworkManager stop >> ${INSTALL_LOG_LOCATION} 2>&1
    if [ -e /proc/sys/net/bridge/bridge-nf-call-iptables ]; then
        ${ECHO_PATH} 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
    fi
}

function dhcpdPrepInterim() {
    ${ECHO_PATH} " ** Symlinking DHCPD"
    ${RM_PATH} -rf /etc/dhcp/dhcpd.conf > /dev/null 2>&1
    ${RM_PATH} -rf /etc/dhcpd.conf > /dev/null 2>&1
    ${LN_PATH} -sf /etc/dhcpd.conf /etc/dhcp/dhcpd.conf
    ${TOUCH_PATH} /etc/dhcpd.conf
    ${CHOWN_PATH} solusvm:solusvm /etc/dhcp/dhcpd.conf > /dev/null 2>&1
    ${CHOWN_PATH} solusvm:solusvm /etc/dhcpd.conf > /dev/null 2>&1
    ${PKILL_PATH} dnsmasq >> ${INSTALL_LOG_LOCATION} 2>&1
    ${ECHO_PATH} " ** Configuring DHCPD"
    ${ECHO_PATH} 'subnet 0.0.0.0 netmask 0.0.0.0 {' > /etc/dhcp/dhcpd.conf
    ${ECHO_PATH} 'authoritative;' >> /etc/dhcp/dhcpd.conf
    ${ECHO_PATH} 'default-lease-time 21600000;' >> /etc/dhcp/dhcpd.conf
    ${ECHO_PATH} 'max-lease-time 432000000;' >> /etc/dhcp/dhcpd.conf
    ${ECHO_PATH} '}' >> /etc/dhcp/dhcpd.conf
    ${ECHO_PATH} 'ddns-update-style interim;' >> /etc/dhcp/dhcpd.conf
    ${ECHO_PATH} '' >> /etc/dhcp/dhcpd.conf
    ${ECHO_PATH} " ** Starting DHCPD"
    ${SERVICE_PATH} dhcpd restart >> ${INSTALL_LOG_LOCATION} 2>&1
}

function openvzTemplates() {
if [ "${OSV}" == "6" ]; then
    VZ_TEMPLATES=('centos-7-x86_64-minimal' 'centos-6-x86_64-minimal' 'debian-8.0-x86_64-minimal' 'debian-7.0-x86_64-minimal' 'ubuntu-15.10-x86_64-minimal' 'ubuntu-15.04-x86_64-minimal' 'ubuntu-14.04-x86_64-minimal');
    mkdir -p /vz/template/cache;
    for VZ_TEMPLATE in ${VZ_TEMPLATES[@]}; do
        if [ ! -e /vz/template/cache/${VZ_TEMPLATE}.tar.gz ]; then
            ${ECHO_PATH} "";
            ${ECHO_PATH} " ** Downloading template: ${VZ_TEMPLATE}";
            curl -# -s -o /vz/template/cache/${VZ_TEMPLATE}.tar.gz ${MIRROR}/solusvmphp7/templates/openvz/${VZ_TEMPLATE}.tar.gz;
            if [ "${IS_MASTER}" = true ]; then
                ${ECHO_PATH} " ** Updating template in database";
                F_NAME=$(${ECHO_PATH} ${VZ_TEMPLATE} | tr  "-"  " ");
                ${ECHO_PATH} "INSERT INTO templates (type,catid,filename,friendlyname,description,status,arch)VALUES ('openvz', '0', '${VZ_TEMPLATE}', '${F_NAME}', '${F_NAME}','Active','x86_64');" > mysql.temp;
                /usr/bin/mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DB} < mysql.temp >> ${INSTALL_LOG_LOCATION} 2>&1;
                ${RM_PATH} -f mysql.temp;
            fi
        else
            ${ECHO_PATH} " ** Template ${VZ_TEMPLATE} already exists. Skipping..";
        fi
    done
    else

    VZ_TEMPLATES=('centos-7-x86_64' 'centos-8-x86_64' 'ubuntu-14.04-x86_64' 'ubuntu-16.04-x86_64' 'ubuntu-18.04-x86_64' 'debian-8.0-x86_64' 'debian-9.0-x86_64' 'debian-10.0-x86_64');
    mkdir -p /vz/template/cache;
    for VZ_TEMPLATE in ${VZ_TEMPLATES[@]}; do
        if [ ! -e /vz/template/cache/${VZ_TEMPLATE}.tar.gz ]; then
            ${ECHO_PATH} "";
            ${ECHO_PATH} " ** Creating template cache: ${VZ_TEMPLATE}";
            ${ECHO_PATH} "Symbol link" > /vz/template/cache/${VZ_TEMPLATE}.tar.gz 2>&1;
            vzpkg create cache ${VZ_TEMPLATE} >> ${INSTALL_LOG_LOCATION} 2>&1;
            ${TOUCH_PATH} /vz/template/cache/${VZ_TEMPLATE}.plain.ploopv2.tar.lz4.lock;
            if [ "${IS_MASTER}" = true ]; then
                ${ECHO_PATH} " ** Updating template in database";
                F_NAME=$(${ECHO_PATH} ${VZ_TEMPLATE} | tr  "-"  " ");
                ${ECHO_PATH} "INSERT INTO templates (type,catid,filename,friendlyname,description,status,arch)VALUES ('openvz', '0', '${VZ_TEMPLATE}', '${F_NAME}', '${F_NAME}','Active','x86_64');" > mysql.temp;
                /usr/bin/mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DB} < mysql.temp >> ${INSTALL_LOG_LOCATION} 2>&1;
                ${RM_PATH} -f mysql.temp;
            fi
        else
            ${ECHO_PATH} " ** Template ${VZ_TEMPLATE} already exists. Skipping..";
        fi
    done

    fi
    ${CHOWN_PATH} solusvm:solusvm /vz/template/cache/*
}

function tmpClear() {
    ${CLEAR_PATH}
    ${ECHO_PATH} ""
    ${MKDIR_PATH} -p /usr/local/solusvm/tmp/
    ${MKDIR_PATH} -p /usr/local/solusvm/data/
}

function enable_kernel_module_autoload() {
  MODULE=$1
  ${ECHO_PATH} -e '#!/bin/bash\nexec /sbin/modprobe '$MODULE' > /dev/null 2>&1' > /etc/sysconfig/modules/"$MODULE".modules
  ${CHMOD_PATH} +x /etc/sysconfig/modules/"$MODULE".modules
}

function load_kvm_kernel_modules() {
  for i in kvm kvm_intel kvm_amd
  do
    /sbin/modprobe $i
  done

  VENDOR_KVM_MODULE=$(${GREP_PATH} ^kvm_ /proc/modules | ${CUT_PATH} -d ' ' -f 1)
  if [[ "$VENDOR_KVM_MODULE" == "" ]]
  then
    ${ECHO_PATH} -e "\nError: KVM modules 'kvm_intel' or 'kvm_amd' not found in /proc/modules. Please configure automatic loading of one of these kernel modules, depending on vendor of the CPU.\nSearch for the solution in Solus Help Center: http://solus.zendesk.com/hc/" |tee -a ${INSTALL_LOG_LOCATION};
    exit 1
  fi

  enable_kernel_module_autoload kvm
  enable_kernel_module_autoload $VENDOR_KVM_MODULE
}

function preCheckKVM() {
    ${ECHO_PATH} " ** Checking KVM node requirements"
    uname=$(uname -r)
    is_ovh_kernel=$(echo "$uname" | grep -iv -e '-ovh-')
    if [[ "$is_ovh_kernel" == "" ]]; then
        ${ECHO_PATH} -e "\nError: The OS kernel from the OVH service provider has been detected: $uname \nThis kernel is not supported at the moment. \nPlease change the kernel to the original one or re-setup the server with the original kernel using the OVH template\n" |tee -a ${INSTALL_LOG_LOCATION};
        exit 1;
    fi

    is_cpu_virtualization_flag=$(grep -E ' vmx | svm ' /proc/cpuinfo)
    if [[ "$is_cpu_virtualization_flag" == "" ]]; then
        ${ECHO_PATH} -e "\nError: Virtualization flags 'vmx' or 'svm' not found in /proc/cpuinfo.\nIt indicates that CPU virtualization extension is not enabled for the server. \nPlease check the manufacturer documentation how to enable it for bare-metal servers or how to enable nested virtualization if this is a virtual server\n\nSolusVM hardware requirements: https://documentation.solusvm.com/display/BET/Hardware+requirements+for+KVM+Slave\n" |tee -a ${INSTALL_LOG_LOCATION};
        exit 1;
    fi

    is_mod_kvm_ia=$(grep -E '^kvm_intel|^kvm_amd' /proc/modules)
    if [[ "$is_mod_kvm_ia" == "" ]]; then
        load_kvm_kernel_modules
    fi
}

function _installKvmRhel7() {
    preCheckKVM;
    tmpClear;
    ${ECHO_PATH} 7 > /usr/local/solusvm/data/.os_version;
    ${ECHO_PATH} 7 > /usr/local/solusvm/data/osversion.dat
    pingTest;
    bestMirror;
    disableSelinux
    yumCheck;
    wgetCheck;
    solusvmCheck;
    cpanelCheck;
    directadminCheck;
    solusvmUser;
    solusvmRepos;
    cron;
    rhel7Glibc32
    logrotate;
    kvmYumReqC7;
    firewall;
    slaveStack;
    dhcpdPrepInterim;
    kvmNetworkChanges
    installSlaveSoftware;
    installBzip;
    installPbzip;
    generateKey;
    kvmInstallComplete
}

function _installMasterRhel7() {
    tmpClear;
    ${ECHO_PATH} 7 > /usr/local/solusvm/data/.os_version;
    ${ECHO_PATH} 7 > /usr/local/solusvm/data/osversion.dat
    touch /usr/local/solusvm/data/use_openssl
    pingTest;
    bestMirror;
    disableSelinux;
    yumCheck;
    wgetCheck;
    solusvmCheck;
    cpanelCheck;
    directadminCheck;
    solusvmUser;
    solusvmRepos;
    rhel7Glibc32;
    cron;
    logrotate;
    firewall;
    masterStack;
    nginxReload;
    createFolders;
    installExtras;
    SQL;
    masterInstallFiles;
    dbChanges;
    installBzip;
    installPbzip;
    noVNCinstall;
    masterInstallComplete;
}

function _installMasterVL7() {
    tmpClear;
    ${ECHO_PATH} 7 > /usr/local/solusvm/data/.os_version;
    ${ECHO_PATH} 7 > /usr/local/solusvm/data/osversion.dat
    ${ECHO_PATH} 1 > /usr/local/solusvm/data/.virtuozzo;
    touch /usr/local/solusvm/data/use_openssl
    pingTest;
    bestMirror;
    disableSelinux;
    yumCheck;
    wgetCheck;
    solusvmCheck;
    cpanelCheck;
    directadminCheck;
    solusvmUser;
    solusvmRepos;
    rhel7Glibc32;
    cron;
    logrotate;
    firewall;
    masterStack;
    nginxReload;
    createFolders;
    installExtras;
    SQL;
    masterInstallFiles;
    dbChanges;
    openvzVL7;
    if [ "${WITH_TEMPLATES}" = true ]; then
    openvzTemplates;
    fi
    installBzip;
    installPbzip;
    installVzdump;
    noVNCinstall;
    masterInstallComplete;
}

function _installMasterRhel6openvz() {
    tmpClear;
    ${ECHO_PATH} 6 > /usr/local/solusvm/data/.os_version;
    ${ECHO_PATH} 6 > /usr/local/solusvm/data/osversion.dat
    touch /usr/local/solusvm/data/use_openssl
    pingTest;
    bestMirror;
    disableSelinux;
    yumCheck;
    wgetCheck;
    solusvmCheck;
    cpanelCheck;
    directadminCheck;
    solusvmUser;
    solusvmRepos;
    rhel6Glibc32;
    cronRhel6
    logrotate;
    firewallRhel6;
    masterStack;
    nginxReload;
    openvzRhel6;
    createFolders;
    installExtras
    SQL;
    masterInstallFiles;
    dbChanges;
    if [ "${WITH_TEMPLATES}" = true ]; then
    openvzTemplates;
    fi
    installBzip;
    installPbzip;
    noVNCinstall;
    masterInstallComplete;
    openvzInstallCompleteUi;
}

function _installMasterRhel6() {
    tmpClear;
    ${ECHO_PATH} 6 > /usr/local/solusvm/data/.os_version;
    ${ECHO_PATH} 6 > /usr/local/solusvm/data/osversion.dat;
    touch /usr/local/solusvm/data/use_openssl
    pingTest;
    bestMirror;
    disableSelinux;
    yumCheck;
    wgetCheck;
    solusvmCheck;
    cpanelCheck;
    directadminCheck;
    solusvmUser;
    solusvmRepos;
    rhel6Glibc32;
    cronRhel6
    logrotate;
    firewallRhel6;
    masterStack;
    nginxReload;
    createFolders;
    installExtras;
    SQL;
    masterInstallFiles;
    dbChanges;
    installBzip;
    installPbzip;
    noVNCinstall;
    masterInstallComplete;
}

function _installKvmRhel6() {
    preCheckKVM;
    tmpClear;
    ${ECHO_PATH} 6 > /usr/local/solusvm/data/.os_version;
    ${ECHO_PATH} 6 > /usr/local/solusvm/data/osversion.dat;
    pingTest;
    bestMirror;
    disableSelinux;
    yumCheck;
    wgetCheck;
    solusvmCheck;
    cpanelCheck;
    directadminCheck;
    solusvmUser;
    solusvmRepos;
    rhel6Glibc32;
    cronRhel6;
    logrotate;
    firewallRhel6;
    kvmYumReq;
    slaveStack;
    dhcpdPrepInterim;
    kvmNetworkChanges;
    installSlaveSoftware;
    generateKey;
    installBzip;
    installPbzip;
    kvmInstallComplete;
}

function _installOpenvzRhel6() {
    tmpClear;
    ${ECHO_PATH} 6 > /usr/local/solusvm/data/.os_version;
    ${ECHO_PATH} 6 > /usr/local/solusvm/data/osversion.dat;
    pingTest;
    bestMirror;
    disableSelinux;
    yumCheck;
    wgetCheck;
    solusvmCheck;
    cpanelCheck;
    directadminCheck;
    solusvmUser;
    solusvmRepos;
    rhel6Glibc32;
    cronRhel6;
    logrotate;
    firewallRhel6;
    slaveStack;
    openvzRhel6;
    ${CHKCONFIG_PATH} NetworkManager off >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${CHKCONFIG_PATH} network on >> ${INSTALL_LOG_LOCATION} 2>&1;
    ${SERVICE_PATH} NetworkManager stop >> ${INSTALL_LOG_LOCATION} 2>&1;
    installSlaveSoftware;
    generateKey;
    installBzip;
    installPbzip;
    openvzInstallComplete;
}

function _installOpenvzVL7() {
    tmpClear;
    ${ECHO_PATH} 7 > /usr/local/solusvm/data/.os_version;
    ${ECHO_PATH} 7 > /usr/local/solusvm/data/osversion.dat;
    ${ECHO_PATH} 1 > /usr/local/solusvm/data/.virtuozzo;
    pingTest;
    bestMirror;
    disableSelinux;
    yumCheck;
    wgetCheck;
    solusvmCheck;
    cpanelCheck;
    directadminCheck;
    solusvmUser;
    solusvmRepos;
    rhel7Glibc32;
    cron;
    logrotate;
    firewall;
    slaveStack;
    openvzVL7;
     if [ "${WITH_TEMPLATES}" = true ]; then
    openvzTemplates;
    fi
    installSlaveSoftware;
    generateKey;
    installBzip;
    installPbzip;
    installVzdump;
    openvzInstallVL7Complete;
}

function _installXenRhel6() {
    tmpClear;
    ${ECHO_PATH} 6 > /usr/local/solusvm/data/.os_version;
    ${ECHO_PATH} 6 > /usr/local/solusvm/data/osversion.dat;
    pingTest;
    bestMirror;
    disableSelinux;
    yumCheck;
    wgetCheck;
    solusvmCheck;
    cpanelCheck;
    directadminCheck;
    solusvmUser;
    solusvmRepos;
    rhel6Glibc32;
    cronRhel6;
    logrotate;
    firewallRhel6;
    slaveStack;
    xenRhel6;
    ${CHKCONFIG_PATH} NetworkManager off >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHKCONFIG_PATH} network on >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SERVICE_PATH} NetworkManager stop >> ${INSTALL_LOG_LOCATION} 2>&1
    installSlaveSoftware;
    generateKey;
    touch /usr/local/solusvm/data/xl-toolstack >> ${INSTALL_LOG_LOCATION} 2>&1
    ${CHKCONFIG_PATH} xend off >> ${INSTALL_LOG_LOCATION} 2>&1
    installBzip;
    installPbzip;
    xenInstallComplete;
}

function _installXenRhel7() {
    tmpClear;
    ${ECHO_PATH} 7 > /usr/local/solusvm/data/.os_version;
    ${ECHO_PATH} 7 > /usr/local/solusvm/data/osversion.dat;
    pingTest;
    bestMirror;
    disableSelinux;
    yumCheck;
    wgetCheck;
    solusvmCheck;
    cpanelCheck;
    directadminCheck;
    solusvmUser;
    solusvmRepos;
    rhel7Glibc32;
    cron;
    logrotate;
    firewall;
    slaveStack;
    xenRhel7;
    ${CHKCONFIG_PATH} NetworkManager on >> ${INSTALL_LOG_LOCATION} 2>&1
    ${SERVICE_PATH} NetworkManager start >> ${INSTALL_LOG_LOCATION} 2>&1
    installSlaveSoftware;
    generateKey;
    ${CHKCONFIG_PATH} xend off >> ${INSTALL_LOG_LOCATION} 2>&1
    systemctl start xendomains.service
    systemctl enable xendomains.service
    installBzip;
    installPbzip;
    xenInstallCompleteC7;
}

function install_by_conf() {
    case "${INSTALL_CONF}"
    in
        "rhel-6-master") _installMasterRhel6;;
        "rhel-6-master-slave-openvz") _installMasterRhel6openvz;;
        "rhel-6-master-slave-openvz-templates")
            OPENVZ=true;
            IS_MASTER=true;
            WITH_TEMPLATES=true;
            _installMasterRhel6openvz;
            ;;
        "rhel-6-slave-kvm") _installKvmRhel6;;
        "rhel-6-slave-xen") _installXenRhel6;;
        "rhel-6-slave-openvz") _installOpenvzRhel6;;
        "rhel-7-master") _installMasterRhel7;;
        "rhel-7-slave-kvm") _installKvmRhel7;;
        "rhel-7-slave-xen") _installXenRhel7;;
        "vl-7-master")
            OPENVZ=true;
            IS_MASTER=true;
            WITH_TEMPLATES=false;
            _installMasterVL7;
            ;;
        "vl-7-master-slave-openvz-templates")
            OPENVZ=true;
            IS_MASTER=true;
            WITH_TEMPLATES=true;
            _installMasterVL7;
            ;;
        "vl-7-slave") _installOpenvzVL7;;
        "vl-7-slave-templates")
            OPENVZ=true;
            IS_MASTER=false;
            WITH_TEMPLATES=true;
            _installOpenvzVL7;
            ;;
        *)
            echo "    Configuration is not supported: ${INSTALL_CONF}"
            exit 1
            ;;
    esac
}

compatibility;
preInstall;
preCheck;
if [ -n "${INSTALL_CONF}" ]; then
    install_by_conf;
else
    menu;
fi
