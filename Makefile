launch:
	xcodebuild
	cp -R build/Release/PBX\ Forwarder.prefPane ~/Library/PreferencePanes/
	killall "System Preferences" || true
	open ~/Library/PreferencePanes/PBX\ Forwarder.prefPane