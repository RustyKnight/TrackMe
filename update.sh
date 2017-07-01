sudo xcode-select -s /Applications/Xcode-beta.app/Contents/Developer
#rm -rf ~/Library/Caches/org.carthage.CarthageKit/dependencies/
xcodebuild -version
time carthage update --platform iOS --configuration Debug
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer