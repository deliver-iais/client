flutter build macos --release

rm installer/dmg_creator/deliver.dmg

cd installer/dmg_creator

npx appdmg ./config.json ./deliver.dmg