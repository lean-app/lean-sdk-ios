mkdir - p build
mkdir - p build/simulator
mkdir - p build/devices
mkdir - p build/universal
xcodebuild clean build \
  -project LeanSdk.xcodeproj \
  -scheme LeanSdk \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath derived_data \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \


cp -r derived_data/Build/Products/Release-iphoneos/LeanSdk.framework build/devices

xcodebuild clean build \
  -project LeanSdk.xcodeproj \
  -scheme LeanSdk \
  -configuration Release \
  -sdk iphonesimulator \
  -derivedDataPath derived_data \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  EXCLUDED_ARCHS="arm64"

cp -r derived_data/Build/Products/Release-iphonesimulator/ build/simulator/

cp -r build/devices/LeanSdk.framework build/universal/

lipo -create \
  build/simulator/LeanSdk.framework/LeanSdk \
  build/devices/LeanSdk.framework/LeanSdk \
  -output build/universal/LeanSdk.framework/LeanSdk

cp -r \
build/simulator/LeanSdk.framework/Modules/LeanSdk.swiftmodule/* \
build/universal/LeanSdk.framework/Modules/LeanSdk.swiftmodule/
