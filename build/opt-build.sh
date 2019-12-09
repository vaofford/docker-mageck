#! /bin/bash

set -xe

if [[ -z "${TMPDIR}" ]]; then
  TMPDIR=/tmp
fi

set -u

if [ "$#" -lt "1" ] ; then
  echo "Please provide an installation path such as /opt/ICGC"
  exit 1
fi

# get path to this script
SCRIPT_PATH=`dirname $0`;
SCRIPT_PATH=`(cd $SCRIPT_PATH && pwd)`

# get the location to install to
INST_PATH=$1
mkdir -p $1
INST_PATH=`(cd $1 && pwd)`
echo $INST_PATH

# get current directory
INIT_DIR=`pwd`

CPU=`grep -c ^processor /proc/cpuinfo`
if [ $? -eq 0 ]; then
  if [ "$CPU" -gt "6" ]; then
    CPU=6
  fi
else
  CPU=1
fi
echo "Max compilation CPUs set to $CPU"

SETUP_DIR=$INIT_DIR/install_tmp
mkdir -p $SETUP_DIR/distro # don't delete the actual distro directory until the very end
mkdir -p $INST_PATH/bin
cd $SETUP_DIR

# make sure tools installed can see the install loc of libraries
set +u
export LD_LIBRARY_PATH=`echo $INST_PATH/lib:$LD_LIBRARY_PATH | perl -pe 's/:\$//;'`
export LIBRARY_PATH=`echo $INST_PATH/lib:$LIBRARY_PATH | perl -pe 's/:\$//;'`
export C_INCLUDE_PATH=`echo $INST_PATH/include:$C_INCLUDE_PATH | perl -pe 's/:\$//;'`
export PATH=`echo $INST_PATH/bin:$PATH | perl -pe 's/:\$//;'`
export MANPATH=`echo $INST_PATH/man:$INST_PATH/share/man:$MANPATH | perl -pe 's/:\$//;'`
export PERL5LIB=`echo $INST_PATH/lib/perl5:$PERL5LIB | perl -pe 's/:\$//;'`
set -u

# numpy
if [ ! -e $SETUP_DIR/numpy.success ]; then
  pip3 install --target=$INST_PATH/python3 numpy==${VER_NUMPY}
  touch $SETUP_DIR/numpy.success
fi

# scipy
if [ ! -e $SETUP_DIR/scipy.success ]; then
  pip3 install --target=$INST_PATH/python3 scipy==${VER_SCIPY}
  touch $SETUP_DIR/scipy.success
fi

# MAGeCK
if [ ! -e $SETUP_DIR/htslib.success ]; then
    curl -sSL --retry 10 -o mageck.tar.gz https://downloads.sourceforge.net/project/mageck/0.5/liulab-mageck-${VER_MAGECK}.tar.gz
    mkdir mageck
    tar --strip-components 1 -C mageck -xzf mageck.tar.gz
    cd mageck
    python3 setup.py install --prefix=$INST_PATH/python3
    cd $SETUP_DIR
    rm -rf mageck.* mageck/*
    touch $SETUP_DIR/mageck.success
fi

