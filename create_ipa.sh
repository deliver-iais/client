flutter build ios

rm -r installer/ipa_creator/Payload

mkdir -p installer/ipa_creator/Payload

cp -r build/ios/iphoneos/Runner.app installer/ipa_creator/Payload/

zip -r -X installer/ipa_creator/Payload.zip installer/ipa_creator/Payload

mv installer/ipa_creator/Payload.zip installer/ipa_creator/Payload.ipa