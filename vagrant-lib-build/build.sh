#!/bin/bash
set -e
set -o pipefail

sudo apt-get update -y
sudo apt-get install -y build-essential \
                   cmake \
                   autoconf \
                   libtool \
                   wget \
                   unzip \
                   git \
                   libffi-dev \
                   libfreetype6-dev \
                   libjpeg-dev \
                   libjpeg-turbo8-dev \
                   libsasl2-dev \
                   libssl-dev \
                   libsqlite3-dev \
                   libxml2-dev \
                   libxslt1-dev \
                   tk-dev \
                   zlib1g-dev \
                   doxygen \
                   libpng12-dev \
                   libcairo2-dev \
                   libtiff5-dev \
                   libexpat1-dev \
                   libpixman-1-dev \
                   m4 \
                   curl \
                   libicu52 \
                   libldap2-dev \
                   libboost-all-dev

sudo mkdir -p /app/.heroku && sudo chmod -R 777 /app
pushd /app/.heroku
wget https://s3.amazonaws.com/boundlessps-public/cf/raster-vendor-libs.zip
unzip raster-vendor-libs.zip && rm raster-vendor-libs.zip
pushd vendor/lib
ln -s libNCSCnet.so.0.0.0 libNCSCnet.so
ln -s libNCSCnet.so.0.0.0 libNCSCnet.so.0
ln -s libNCSEcwC.so.0.0.0 libNCSEcwC.so
ln -s libNCSEcwC.so.0.0.0 libNCSEcwC.so.0
ln -s libNCSEcw.so.0.0.0 libNCSEcw.so
ln -s libNCSEcw.so.0.0.0 libNCSEcw.so.0
ln -s libNCSUtil.so.0.0.0 libNCSUtil.so
ln -s libNCSUtil.so.0.0.0 libNCSUtil.so.0
ln -s libltidsdk.so.8 libltidsdk.so
ln -s liblti_lidar_dsdk.so.1 liblti_lidar_dsdk.so
popd
popd

export PKG_CONFIG_PATH="/app/.heroku/vendor/lib/pkgconfig":"${PKG_CONFIG_PATH}"
pushd ~

wget https://ftp.postgresql.org/pub/source/v9.5.3/postgresql-9.5.3.tar.gz
tar xf postgresql-9.5.3.tar.gz && pushd postgresql-9.5.3
sed --in-place '/fmgroids/d' src/include/Makefile
./configure --prefix=/app/.heroku/vendor \
            --without-readline \
            --enable-static=no
make -C src/bin install
make -C src/include install
make -C src/interfaces install
popd && rm -fr postgresql-9.5.3

wget https://github.com/nmoinvaz/minizip/archive/master.zip
unzip master.zip && pushd minizip-master
cmake -DCMAKE_INSTALL_PREFIX:PATH=/app/.heroku/vendor -DBUILD_SHARED_LIBS=ON .
make install
popd && rm -fr minizip-master

wget https://github.com/nevali/uriparser/archive/uriparser-0.8.0.tar.gz
tar xf uriparser-0.8.0.tar.gz && pushd uriparser-uriparser-0.8.0
./autogen.sh
./configure --prefix=/app/.heroku/vendor \
            --enable-static=no \
            --disable-test \
            --disable-doc
make install
popd && rm -fr uriparser-uriparser-0.8.0

wget https://github.com/libkml/libkml/archive/1.3.0.tar.gz
tar xf 1.3.0.tar.gz && pushd libkml-1.3.0
cmake -DCMAKE_INSTALL_PREFIX:PATH=/app/.heroku/vendor .
make install
popd && rm -fr libkml-1.3.0

wget http://download.osgeo.org/geos/geos-3.5.0.tar.bz2
tar xf geos-3.5.0.tar.bz2 && pushd geos-3.5.0/
./configure --prefix=/app/.heroku/vendor/ \
            --enable-static=no
make install
popd && rm -fr geos-3.5.0

wget http://download.osgeo.org/proj/proj-4.9.2.tar.gz
tar xf proj-4.9.2.tar.gz && pushd proj-4.9.2/
./configure --prefix=/app/.heroku/vendor/ \
            --enable-static=no
make install
popd && rm -fr proj-4.9.2

wget http://download.osgeo.org/gdal/2.1.0/gdal-2.1.0.tar.gz
tar xf gdal-2.1.0.tar.gz && pushd gdal-2.1.0/
./configure --prefix=/app/.heroku/vendor/ \
    --with-jpeg \
    --with-png=internal \
    --with-geotiff=internal \
    --with-libtiff=internal \
    --with-libz=internal \
    --with-curl \
    --with-gif=internal \
    --with-geos=/app/.heroku/vendor/bin/geos-config \
    --with-expat \
    --with-threads \
    --with-ecw=/app/.heroku/vendor \
    --with-mrsid=/app/.heroku/vendor \
    --with-mrsid_lidar=/app/.heroku/vendor \
    --with-libkml=/app/.heroku/vendor \
    --with-libkml-inc=/app/.heroku/vendor/include/kml \
    --with-pg=/app/.heroku/vendor/bin/pg_config \
    --enable-static=no
make install
popd && rm -fr gdal-2.1.0/

wget https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tgz
tar xfz Python-2.7.11.tgz && pushd Python-2.7.11
./configure --prefix=/app/.heroku/python \
            --enable-ipv6 \
            --enable-static=no \
            --enable-shared
make && make install
popd && rm -fr Python-2.7.11

wget https://sourceforge.net/projects/boost/files/boost/1.61.0/boost_1_61_0.tar.gz
tar xf boost_1_61_0.tar.gz && pushd boost_1_61_0
./bootstrap.sh --prefix=/app/.heroku/vendor \
               --with-icu=/usr/lib/x86_64-linux-gnu/icu \
               --with-python=/app/.heroku/python/bin/python2.7 \
               --with-libraries=filesystem,python,system,regex,thread
./bjam install
popd && rm -fr boost_1_61_0

wget https://cairographics.org/releases/py2cairo-1.10.0.tar.bz2
tar xf py2cairo-1.10.0.tar.bz2 && pushd py2cairo-1.10.0
export PYTHON=/app/.heroku/python/bin/python2.7
./waf configure --prefix=/app/.heroku/python
./waf build
./waf install
popd && rm -fr py2cairo-1.10.0

git clone https://github.com/mapnik/mapnik mapnik-2.3.x -b 2.3.x --depth 10
pushd mapnik-2.3.x
./configure PREFIX=/app/.heroku/vendor \
            PKG_CONFIG_PATH=/usr/bin:/app/.heroku/python/lib/pkgconfig/:=/app/.heroku/vendor/bin/ \
            PYTHON_PREFIX=/app/.heroku/python \
            BOOST_INCLUDES=/app/.heroku/vendor/include/boost \
            BOOST_LIBS=/app/.heroku/vendor/lib \
            GDAL_CONFIG=/app/.heroku/vendor/bin/gdal-config \
            PG_CONFIG=/app/.heroku/vendor/bin/pg_config
make install
popd && rm -fr mapnik-2.3.x

pushd /app/.heroku/
if [ -f /vagrant/vendor.tar.gz ]; then
    rm -f /vagrant/vendor.tar.gz
fi
tar -zcf vendor.tar.gz vendor/ && mv vendor.tar.gz /vagrant/
popd

pushd /app/.heroku/python/lib/python2.7/
if [ -f /vagrant/site-packages.tar.gz ]; then
    rm -f /vagrant/site-packages.tar.gz
fi
tar -zcf site-packages.tar.gz site-packages/ && mv site-packages.tar.gz /vagrant/
popd

sudo chmod -R 777 /app
curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | /app/.heroku/python/bin/python
if [ -f /vagrant/requirements.txt ]; then
    /app/.heroku/python/bin/pip wheel --wheel-dir=/vagrant/vendor -r /vagrant/requirements.txt
fi
