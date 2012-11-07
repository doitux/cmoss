#!/bin/bash
set -e

# Changes for protobuf Copyright (c) 2012, Lothar May
# Copyright (c) 2010, Pierre-Olivier Latour
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * The name of Pierre-Olivier Latour may not be used to endorse or
#       promote products derived from this software without specific prior
#       written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL PIERRE-OLIVIER LATOUR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Download source
if [ ! -e "protobuf-${PROTOBUF_VERSION}.tar.bz2" ]
then
  curl $PROXY -O "http://protobuf.googlecode.com/files/protobuf-${PROTOBUF_VERSION}.tar.bz2"
fi

# Extract source
rm -rf "protobuf-${PROTOBUF_VERSION}"
tar xvjf "protobuf-${PROTOBUF_VERSION}.tar.bz2"
cp ${TOPDIR}/build-droid/config.guess.protobuf protobuf-${PROTOBUF_VERSION}/config.guess
cp ${TOPDIR}/build-droid/config.sub.protobuf protobuf-${PROTOBUF_VERSION}/config.sub

# Build
pushd "protobuf-${PROTOBUF_VERSION}"

DROID_GCC_LIBS=${TMPDIR}/droidtoolchains/${PLATFORM}/lib/gcc/arm-linux-androideabi/4.4.3

export CC=${DROIDTOOLS}-gcc
export LD=${DROIDTOOLS}-ld
export CPP=${DROIDTOOLS}-cpp
export CXX=${DROIDTOOLS}-g++
export AR=${DROIDTOOLS}-ar
export AS=${DROIDTOOLS}-as
export NM=${DROIDTOOLS}-nm
export STRIP=${DROIDTOOLS}-strip
export CXXCPP=${DROIDTOOLS}-cpp
export RANLIB=${DROIDTOOLS}-ranlib

export LDFLAGS="-Os -fPIC -nostdlib -Wl,-rpath-link=${SYSROOT}/usr/lib -L${SYSROOT}/usr/lib -L${DROID_GCC_LIBS} -L${ROOTDIR}/lib -lgcc -lc -lz"

export CFLAGS="-Os -pipe -isysroot ${SYSROOT} -I${ROOTDIR}/include"
export CXXFLAGS="-Os -pipe -isysroot ${SYSROOT} -I${ROOTDIR}/include"

./configure --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${ROOTDIR} --disable-shared --with-protoc=/usr/bin/protoc 
# Build will fail!
set +e
make
set -e
cp src/.libs/*.a ${ROOTDIR}/lib/
cp -r src/google ${ROOTDIR}/include/

# Clean up
rm -rf "protobuf-${PROTOBUF_VERSION}"