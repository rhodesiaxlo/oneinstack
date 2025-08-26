#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack


Install_pecl_grpc() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    
    # 检查PHP版本兼容性
    if [[ "${PHP_main_ver}" =~ ^5.[3-6]$ ]]; then
      echo "${CWARNING}PHP ${PHP_detail_ver} does not support gRPC extension! Minimum required: PHP 7.0+ ${CEND}"
      popd > /dev/null
      return 1
    fi
    
    # 安装系统依赖
    echo "${CMSG}Installing gRPC dependencies... ${CEND}"
    if [ "${PM}" == 'yum' ]; then
      if [ "${RHEL_ver}" == '9' ]; then
        yum -y install openssl-devel zlib-devel
      else
        yum -y install openssl-devel
      fi
    else
      apt-get -y install libssl-dev zlib1g-dev
    fi
    
    # 根据PHP版本选择合适的gRPC版本
    if [[ "${PHP_main_ver}" =~ ^7.[0-4]$ ]]; then
      echo "${CMSG}Using gRPC ${grpc_oldver} for PHP ${PHP_detail_ver} ${CEND}"
      src_url=https://pecl.php.net/get/grpc-${grpc_oldver}.tgz && Download_src
      tar xzf grpc-${grpc_oldver}.tgz
      pushd grpc-${grpc_oldver} > /dev/null
    else
      echo "${CMSG}Using gRPC ${grpc_ver} for PHP ${PHP_detail_ver} ${CEND}"
      src_url=https://pecl.php.net/get/grpc-${grpc_ver}.tgz && Download_src
      tar xzf grpc-${grpc_ver}.tgz
      pushd grpc-${grpc_ver} > /dev/null
    fi
    
    # 编译安装
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config \
                --with-grpc \
                --with-openssl-dir=${openssl_install_dir}
    
    echo "${CMSG}Compiling gRPC extension (this may take several minutes)... ${CEND}"
    make -j ${THREAD} && make install
    popd > /dev/null
    
    # 验证安装结果
    if [ -f "${phpExtensionDir}/grpc.so" ]; then
      echo 'extension=grpc.so' > ${php_install_dir}/etc/php.d/08-grpc.ini
      echo "${CSUCCESS}PHP gRPC module installed successfully! ${CEND}"
      
      # 清理临时文件
      rm -rf grpc-${grpc_ver} grpc-${grpc_oldver}
    else
      echo "${CFAILURE}PHP gRPC module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    fi
    popd > /dev/null
  else
    echo "${CWARNING}PHP is not installed or phpize not found! ${CEND}"
  fi
}

Uninstall_pecl_grpc() {
  if [ -e "${php_install_dir}/etc/php.d/08-grpc.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/08-grpc.ini
    echo; echo "${CMSG}PHP gRPC module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP gRPC module does not exist! ${CEND}"
  fi
}
