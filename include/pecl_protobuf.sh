#!/bin/bash

Install_pecl_protobuf() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    if [[ "${PHP_main_ver}" =~ ^7\.[0-4]$ ]]; then
      src_url=https://pecl.php.net/get/protobuf-${protobuf_oldver}.tgz && Download_src
      tar xzf protobuf-${protobuf_oldver}.tgz
      pushd protobuf-${protobuf_oldver} > /dev/null
    else
      src_url=https://pecl.php.net/get/protobuf-${protobuf_ver}.tgz && Download_src
      tar xzf protobuf-${protobuf_ver}.tgz
      pushd protobuf-${protobuf_ver} > /dev/null
    fi
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/protobuf.so" ]; then
      echo 'extension=protobuf.so' > ${php_install_dir}/etc/php.d/09-protobuf.ini
      echo "${CSUCCESS}PHP protobuf module installed successfully! ${CEND}"
      rm -rf protobuf-${protobuf_ver} protobuf-${protobuf_oldver}
    else
      echo "${CFAILURE}PHP protobuf module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_protobuf() {
  if [ -e "${php_install_dir}/etc/php.d/09-protobuf.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/09-protobuf.ini
    echo; echo "${CMSG}PHP protobuf module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP protobuf module does not exist! ${CEND}"
  fi
}
