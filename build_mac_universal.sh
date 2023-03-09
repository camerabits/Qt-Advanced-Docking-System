#!/bin/sh

set -e

if [ -d "build_Arm64" ]; then
  rm -rf build_Arm64
fi
mkdir build_Arm64
mkdir build_Arm64/Debug
mkdir build_Arm64/Release

if [ -d "build_x86_64" ]; then
  rm -rf build_x86_64
fi
mkdir build_x86_64
mkdir build_x86_64/Debug
mkdir build_x86_64/Release

if [ -d "build_mac_universal" ]; then
  rm -rf build_mac_universal
fi
mkdir build_mac_universal
mkdir build_mac_universal/Debug
mkdir build_mac_universal/Release

QT_PREFIX_PATH="/Users/kbaker/Development/Qt/6.3.2/macos"

cd build_Arm64/Debug
cmake -DCMAKE_PREFIX_PATH=$QT_PREFIX_PATH -DCMAKE_BUILD_TYPE=Debug -DCMAKE_OSX_ARCHITECTURES=arm64 -G"Unix Makefiles" ../../CMakeLists.txt
make qtadvanceddocking
cp x64/lib/libqtadvanceddocking.dylib ./.
make clean
cd ../Release
cmake -DCMAKE_PREFIX_PATH=$QT_PREFIX_PATH -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=arm64 -G"Unix Makefiles" ../../CMakeLists.txt
make qtadvanceddocking
cp x64/lib/libqtadvanceddocking.dylib ./.
make clean

cd ../../build_x86_64/Debug
cmake -DCMAKE_PREFIX_PATH=$QT_PREFIX_PATH -DCMAKE_BUILD_TYPE=Debug -DCMAKE_OSX_ARCHITECTURES=x86_64 -G"Unix Makefiles" ../../CMakeLists.txt
make qtadvanceddocking
cp x64/lib/libqtadvanceddocking.dylib ./.
make clean
cd ../Release
cmake -DCMAKE_PREFIX_PATH=$QT_PREFIX_PATH -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=x86_64 -G"Unix Makefiles" ../../CMakeLists.txt
make qtadvanceddocking
cp x64/lib/libqtadvanceddocking.dylib ./.
make clean

cd ../../build_mac_universal
lipo -create ../build_Arm64/Debug/libqtadvanceddocking.dylib ../build_x86_64/Debug/libqtadvanceddocking.dylib -output Debug/libqtadvanceddocking.dylib
cd Debug
ln -s libqtadvanceddocking.dylib libqtadvanceddocking.3.8.2.dylib
cd ..
echo "Universal Debug dylib created" >&2
lipo -create ../build_Arm64/Release/libqtadvanceddocking.dylib ../build_x86_64/Release/libqtadvanceddocking.dylib -output Release/libqtadvanceddocking.dylib
cd Release
ln -s libqtadvanceddocking.dylib libqtadvanceddocking.3.8.2.dylib
install_name_tool -delete_rpath $QT_PREFIX_PATH/lib libqtadvanceddocking.dylib -add_rpath "@executable_path/../Frameworks"
cd ..
echo "Universal Release dylib created" >&2

echo "Removing Arm64 and x86_64 build directories"
rm -rf ../build_Arm64
rm -rf ../build_x86_64

file Debug/libqtadvanceddocking.dylib
file Release/libqtadvanceddocking.dylib

# need to copy the libs

echo "done" >&2
