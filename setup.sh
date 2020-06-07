#!/bin/bash -l

set -e

# env variables
export PKG_CONFIG_PATH=/opt/lnmp/lib/pkgconfig:/opt/lnmp/lib64/pkgconfig:/usr/lib64/pkgconfig

# vim
yum erase vim-minimal
yum install -y vim
ln -sf vim /usr/bin/vi

# common deps
yum install -y bzip2 gcc g++ make net-tools

##########################################################################

# nginx deps
yum install -y pcre-devel zlib-devel openssl-devel libxslt-devel gd-devel
yum install -y perl perl-devel perl-ExtUtils-Embed
yum install -y GeoIP-devel
yum install -y gperftools-devel

if [ ! -f "/opt/lnmp/sbin/nginx" ]; then
    # nginx build
    test ! -d /tmp/nginx-1.17.10 && tar -xvf nginx-1.17.10.tar.gz -C /tmp
    pushd /tmp/nginx-1.17.10
    ./configure --prefix=/opt/lnmp --with-select_module --with-poll_module --with-threads --with-file-aio --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_geoip_module=dynamic --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --with-http_perl_module=dynamic --http-client-body-temp-path=/opt/lnmp/temp/body --http-proxy-temp-path=/opt/lnmp/temp/proxy --http-fastcgi-temp-path=/opt/lnmp/temp/fastcgi --http-uwsgi-temp-path=/opt/lnmp/temp/uwsgi --http-scgi-temp-path=/opt/lnmp/temp/scgi --with-mail=dynamic --with-mail_ssl_module --with-stream=dynamic --with-stream_ssl_module --with-stream_realip_module --with-stream_geoip_module=dynamic --with-stream_ssl_preread_module --with-google_perftools_module --with-compat --with-debug
    make -j4
    make install
    popd
    rm -rf /tmp/nginx-1.17.10
fi

# nginx create dir
mkdir -p /opt/lnmp/temp

##########################################################################

if [ ! -f "/opt/lnmp/include/gd.h" ]; then
    # libgd build
    test ! -d /tmp/libgd-2.3.0 && tar -xvf libgd-2.3.0.tar.gz -C /tmp
    pushd /tmp/libgd-2.3.0
    ./configure --prefix=/opt/lnmp && make -j4 && make install
    popd
    rm -rf /tmp/libgd-2.3.0
fi

# if [ ! -f "/opt/lnmp/include/client.h" ]; then
#     # imap-2007a1 build
#     yum install -y pam-devel
#     test ! -d /tmp/imap-2007a && tar -xvf imap-2007a1.tar.gz -C /tmp
#     pushd /tmp/imap-2007a
#     make -j4 lrh && \cp -u c-client/c-client.a /opt/lnmp/lib/libc-client.a && \cp -u c-client/*.h /opt/lnmp/include && \cp -u tmail/tmail dmail/dmail mlock/mlock mtest/mtest ipopd/ipop2d ipopd/ipop3d imapd/imapd /opt/lnmp/bin
#     popd
#     rm -rf /tmp/imap-2007a
# fi

if [ ! -f "/opt/lnmp/include/pcre2.h" ]; then
    # pcre2 build
    test ! -d /tmp/pcre2-10.35 && tar -xvf pcre2-10.35.tar.bz2 -C /tmp
    pushd /tmp/pcre2-10.35
    ./configure --prefix=/opt/lnmp
    make -j4 && make install
    popd
    rm -rf /tmp/pcre2-10.35
fi

if [ ! -f "/opt/lnmp/include/mm.h" ]; then
    # mm build
    test ! -d /tmp/mm-1.4.1 && tar -xvf mm-1.4.1.tar.gz -C /tmp
    pushd /tmp/mm-1.4.1
    ./configure --prefix=/opt/lnmp
    make -j4 && make install
    popd
    rm -rf /tmp/mm-1.4.1
fi

if [ ! -f "/usr/local/bin/cmake" ]; then
    # cmake build
    test ! -d /tmp/cmake-3.17.1 && tar -xvf cmake-3.17.1.tar.gz -C /tmp
    pushd /tmp/cmake-3.17.1
    ./configure && make -j6 && make install
    popd
    rm -rf /tmp/cmake-3.17.1
fi

if [ ! -f "/opt/lnmp/include/zip.h" ]; then
    # libzip build
    test ! -d /tmp/libzip-1.6.1 && tar -xvf libzip-1.6.1.tar.gz -C /tmp
    pushd /tmp/libzip-1.6.1
    mkdir -p build
    pushd build
    cmake -DCMAKE_INSTALL_PREFIX=/opt/lnmp .. && make -j4 && make install
    popd
    popd
    rm -rf /tmp/libzip-1.6.1
fi

# php deps
yum install -y sqlite-devel libcurl-devel enchant-devel libffi-devel
yum install -y gmp-devel libicu-devel gcc-c++ openldap-devel systemd-devel libacl-devel bzip2-devel
yum install -y aspell-devel libedit-devel net-snmp-devel

ln -sf /usr/lib64/libldap* /usr/lib/

if [ ! -f "/opt/lnmp/sbin/php-fpm" ]; then
    # php build
    test ! -d /tmp/php-7.4.6 && tar -xvf php-7.4.6.tar.bz2 -C /tmp
    pushd /tmp/php-7.4.6
    EXTENSION_DIR=/opt/lnmp/lib/extensions ./configure CFLAGS=-O2 CXXFLAGS=-O2 EXTRA_LIBS=-llber --prefix=/opt/lnmp --enable-embed --enable-fpm --with-fpm-user=web --with-fpm-group=users --with-fpm-systemd --with-fpm-acl --enable-phpdbg --enable-phpdbg-webhelper --enable-phpdbg-debug --enable-phpdbg-readline --with-config-file-path=/opt/lnmp/etc --with-config-file-scan-dir=/opt/lnmp/etc/php.d --enable-sigchild --with-openssl --with-kerberos --with-system-ciphers --with-external-pcre --with-pcre-jit --with-zlib --enable-bcmath --with-bz2 --enable-calendar --with-curl --enable-dba=shared --with-enchant --enable-exif --with-ffi --enable-ftp --enable-gd --with-external-gd --with-webp --with-jpeg --with-xpm --with-freetype --enable-gd-jis-conv --with-gettext --with-gmp --with-mhash --enable-intl --with-ldap --with-ldap-sasl --enable-mbstring --disable-mbregex --with-mysqli --with-mysql-sock=/opt/lnmp/var/mysql/mysql.sock --enable-pcntl --with-pdo-mysql --with-zlib-dir --with-pspell --with-libedit --with-readline --with-mm=/opt/lnmp --enable-shmop --with-snmp --enable-soap --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm --with-expat --with-xmlrpc --with-expat --with-xsl --enable-zend-test=shared --with-zip --enable-mysqlnd
    # --with-imap=/opt/lnmp --with-kerberos --with-imap-ssl
    make -j6 && make install
    \cp php.ini-production /opt/lnmp/etc/php.ini && mkdir -p /opt/lnmp/etc/php.d
    popd
    rm -rf /tmp/php-7.4.6
fi

##########################################################################

# make ssl cert
# 1. 创建服务器证书密钥文件: openssl genrsa -des3 -out cert.key 1024
# 2. 创建服务器证书的申请文件: openssl req -new -key cert.key -out cert.csr
# 3. 备份一份服务器密钥文件: cp cert.key cert.key.org
# 4. 去除文件口令: openssl rsa -in cert.key.org -out cert.key
# 5. 生成证书文件: openssl x509 -req -days 365 -in cert.csr -signkey cert.key -out cert.pem

##########################################################################

if [ ! -f "/opt/lnmp/bin/mysqld" ]; then
    # install mysql
    yum install -y pam-devel bison
    test ! -d mariadb-10.4.13 && tar -xvf mariadb-10.4.13.tar.gz -C /tmp
    pushd /tmp/mariadb-10.4.13
    mkdir -p build
    pushd build
    cmake .. -DCMAKE_INSTALL_PREFIX=/opt/lnmp -DMYSQLD_USER=web -DMYSQL_DATADIR=/opt/lnmp/var/mysql -DSYSCONFDIR=/opt/lnmp/etc -DMYSQL_UNIX_ADDR=/opt/lnmp/var/mysql/mysql.sock -DWITHOUT_TOKUBD=1 -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
    make -j6 && make install
    popd
    popd
    rm -rf /tmp/mariadb-10.4.13
    pushd /opt/lnmp
    ./scripts/mysql_install_db --datadir=/opt/lnmp/var/mysql
    popd
    \cp my.cnf /opt/lnmp/etc/
    ln -sf etc/my.cnf /opt/lnmp/
    ln -sf /opt/lnmp/support-files/mysql.server /etc/init.d/mysql
    chkconfig mysql on
fi


##########################################################################

if [ ! -d "/opt/lnmp/html/phpmyadmin" ]; then
    # install phpmyadmin

    unzip -d /opt/lnmp/html phpMyAdmin-5.0.2-all-languages.zip
    pushd /opt/lnmp/html
    mv phpMyAdmin-5.0.2-all-languages phpmyadmin
    pushd phpmyadmin
    cp config.sample.inc.php config.inc.php
    popd
    popd
fi

if [ -f "/opt/lnmp/html/index.html" ]; then
    mv /opt/lnmp/html/index.html /opt/lnmp/html/nginx.html
fi

if [ ! -f "/opt/lnmp/html/phpinfo.php" ]; then
    cat - > /opt/lnmp/html/phpinfo.php <<!
<?php
phpinfo();
!
fi

pushd /opt/lnmp/etc
test ! -f php-fpm.conf && cp php-fpm.conf.default php-fpm.conf
test ! -f php-fpm.d/www.conf && cp php-fpm.d/www.conf.default php-fpm.d/www.conf
popd

egrep '^user\s+web\s+users;$' /opt/lnmp/conf/nginx.conf >/dev/null 2>&1 || \cp nginx.conf /opt/lnmp/conf/nginx.conf

mkdir -p /opt/lnmp/temp/mysql
mkdir -p /opt/lnmp/var/log/mysql

pushd /opt/lnmp
rm -rf COPYING CREDITS data/ docs/ EXCEPTIONS-CLIENT INSTALL-BINARY mysql-test/ README* sql-bench/ THIRDPARTY
popd

##########################################################################

# user
useradd -g users web || echo -n
chown -R web.users /opt/lnmp

##########################################################################

test ! -f /etc/init.d/nginx && cp nginx.sh /etc/init.d/nginx && chmod +x /etc/init.d/nginx && chkconfig nginx on

service mysql start
service nginx start

