flutter build macos --release

rm installer/dmg_creator/we.dmg

mkdir -p build/macos/Build/Products/Release/We.app

mv build/macos/Build/Products/Release/Deliver.app/Contents build/macos/Build/Products/Release/We.app

cd installer/dmg_creator

npx appdmg ./config.json ./we.dmg