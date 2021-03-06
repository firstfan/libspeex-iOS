#!/bin/sh

VERSION="1.2rc2"
SDKVERSION="8.2"
LIB="speex"

DEVELOPER=`xcode-select -print-path`
ARCHS="i386 x86_64 armv7 armv7s arm64"
CURRENTPATH=`pwd`
BUILD="x86_64-apple-darwin11"
OLD_PATH=$PATH

cd ${LIB}-${VERSION}

for ARCH in ${ARCHS}
do
    case "${ARCH}" in
        "i386"|"x86_64")
            PLATFORM="iPhoneSimulator"
            HOST="${ARCH}-apple-darwin11"
            ;;
        "arm64")
            PLATFORM="iPhoneOS"
            HOST="aarch64-apple-darwin11"
            ;;
        *)
            PLATFORM="iPhoneOS"
            HOST="${ARCH}-apple-darwin11"
            ;;
    esac

    SDK="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk"

#    export CC="clang -arch ${ARCH} -isysroot ${SDK}"
    export CC="clang"
    export CFLAGS="-arch ${ARCH} -isysroot ${SDK} -miphoneos-version-min=6.0"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="$CFLAGS"
    export LD=$CC

    PREFIX="${CURRENTPATH}/build/${LIB}/${ARCH}"

    mkdir -p ${PREFIX}

    echo "Please stand by..."

    ./configure --prefix=$PREFIX --host=${HOST} -build=${BUILD} --with-ogg-libraries=${CURRENTPATH}/build/libogg/Fat/lib/ -with-ogg-includes=${CURRENTPATH}/build/libogg/Fat/include
    make clean
    make && make install

    echo "======== CHECK ARCH ========"
    lipo -info ${PREFIX}/lib/lib${LIB}.a
    echo "======== CHECK DONE ========"

done

echo "== We just need static library == "
echo " == Copy headers to fat folder from i386 folder AND clean files in lib =="
cp -r ${CURRENTPATH}/build/${LIB}/i386/ ${CURRENTPATH}/build/${LIB}/Fat
rm -rf ${CURRENTPATH}/build/${LIB}/Fat/lib/*

echo "Build library - libspeex.a"
lipo -create ${CURRENTPATH}/build/${LIB}/i386/lib/lib${LIB}.a ${CURRENTPATH}/build/${LIB}/x86_64/lib/lib${LIB}.a ${CURRENTPATH}/build/${LIB}/arm64/lib/lib${LIB}.a ${CURRENTPATH}/build/${LIB}/armv7/lib/lib${LIB}.a ${CURRENTPATH}/build/${LIB}/armv7s/lib/lib${LIB}.a -output ${CURRENTPATH}/build/${LIB}/Fat/lib/lib${LIB}.a

#echo "Build library - libspeexdsp.a"
#lipo -create ${CURRENTPATH}/build/${LIB}/i386/lib/lib${LIB}dsp.a ${CURRENTPATH}/build/${LIB}/x86_64/lib/lib${LIB}dsp.a ${CURRENTPATH}/build/${LIB}/arm64/lib/lib${LIB}dsp.a ${CURRENTPATH}/build/${LIB}/armv7/lib/lib${LIB}dsp.a ${CURRENTPATH}/build/${LIB}/armv7s/lib/lib${LIB}dsp.a -output ${CURRENTPATH}/build/${LIB}/Fat/lib/lib${LIB}dsp.a


echo "======== CHECK FAT ARCH ========"
lipo -info ${CURRENTPATH}/build/${LIB}/Fat/lib/lib${LIB}.a
#lipo -info ${CURRENTPATH}/build/${LIB}/Fat/lib/lib${LIB}dsp.a
echo "======== CHECK DONE ========"

echo "== Done =="
