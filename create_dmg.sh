flutter build macos --release

rm installer/dmg_creator/deliver.dmg

mv build/macos/Build/Products/Release/Deliver.app build/macos/Build/Products/Release/We.app

cd installer/dmg_creator

npx appdmg ./config.json ./we.dmg