flutter build macos --release

rm installer/dmg_creator/We.dmg

cd installer/dmg_creator

npx appdmg ./config.json ./We.dmg