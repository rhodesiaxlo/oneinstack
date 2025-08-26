#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_pecl_pcntl() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    
    # 检查pcntl是否已经编译到PHP核心中
    if ${php_install_dir}/bin/php -m | grep -q pcntl; then
      echo "${CWARNING}PHP pcntl module is already built-in! ${CEND}"
      popd > /dev/null
      return 0
    fi
    
    # 下载对应版本的PHP源码
    src_url=https://secure.php.net/distributions/php-${PHP_detail_ver}.tar.gz && Download_src
    tar xzf php-${PHP_detail_ver}.tar.gz
    
    pushd php-${PHP_detail_ver}/ext/pcntl > /dev/null
    ${php_install_dir}/bin/phpize
    
    # 配置和编译
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd > /dev/null
    
    if [ -f "${phpExtensionDir}/pcntl.so" ]; then
      echo 'extension=pcntl.so' > ${php_install_dir}/etc/php.d/04-pcntl.ini
      echo "${CSUCCESS}PHP pcntl module installed successfully! ${CEND}"
      rm -rf php-${PHP_detail_ver}
    else
      echo "${CFAILURE}PHP pcntl module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_pcntl() {
  if [ -e "${php_install_dir}/etc/php.d/04-pcntl.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/04-pcntl.ini
    echo; echo "${CMSG}PHP pcntl module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP pcntl module does not exist! ${CEND}"
  fi
}
