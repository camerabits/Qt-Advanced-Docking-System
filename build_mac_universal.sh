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

if [[ ! -d "$QT_PREFIX_PATH" ]]; then
	echo "QT_PREFIX_PATH has not been set or is not a valid path."
	echo "QT_PREFIX_PATH=$QT_PREFIX_PATH"
	echo "Add the QT_PREFIX_PATH environment variable pointing to your Qt platform installation."
	exit 1
fi

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
cd ..
echo "Universal Debug dylib created" >&2
lipo -create ../build_Arm64/Release/libqtadvanceddocking.dylib ../build_x86_64/Release/libqtadvanceddocking.dylib -output Release/libqtadvanceddocking.dylib
cd Release
install_name_tool -delete_rpath $QT_PREFIX_PATH/lib libqtadvanceddocking.dylib -add_rpath "@executable_path/../Frameworks"
cd ..
echo "Universal Release dylib created" >&2

echo "Removing Arm64 and x86_64 build directories"
rm -rf ../build_Arm64
rm -rf ../build_x86_64

file Debug/libqtadvanceddocking.dylib
file Release/libqtadvanceddocking.dylib

# copy the libs
cp Debug/libqtadvanceddocking.dylib ../../lib/Debug/bin
cp Release/libqtadvanceddocking.dylib ../../lib/Release/bin
# setup symlinks
ln -s libqtadvanceddocking.dylib ../../lib/Debug/bin/libqtadvanceddocking.3.8.2.dylib
ln -s libqtadvanceddocking.dylib ../../lib/Release/bin/libqtadvanceddocking.3.8.2.dylib

# copy the headers
cd ../src
rm -rf ../../include/ads
mkdir ../../include/ads
cp AutoHideDockContainer.h ../../include/ads/
cp AutoHideSideBar.h ../../include/ads/
cp AutoHideTab.h ../../include/ads/
cp DockAreaTabBar.h ../../include/ads/
cp DockAreaTitleBar.h ../../include/ads/
cp DockAreaTitleBar_p.h ../../include/ads/
cp DockAreaWidget.h ../../include/ads/
cp DockComponentsFactory.h ../../include/ads/
cp DockContainerWidget.h ../../include/ads/
cp DockFocusController.h ../../include/ads/
cp DockManager.h ../../include/ads/
cp DockOverlay.h ../../include/ads/
cp DockSplitter.h ../../include/ads/
cp DockWidget.h ../../include/ads/
cp DockWidgetTab.h ../../include/ads/
cp DockingStateReader.h ../../include/ads/
cp ElidingLabel.h ../../include/ads/
cp FloatingDockContainer.h ../../include/ads/
cp FloatingDragPreview.h ../../include/ads/
cp IconProvider.h ../../include/ads/
cp PushButton.h ../../include/ads/
cp ResizeHandle.h ../../include/ads/
cp ads_globals.h ../../include/ads/

echo "done" >&2
