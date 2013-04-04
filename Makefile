PREF_PANE = PBXForwarderPrefPane.prefPane
SERVICE_APP = PBXForwarderService.app
SERVICE_SCRIPT = pbxforwarderservice.py
DIST_DIR = dist/PBXForwarder
DMG_VOLUME = PBXForwarder
DMG_SIZE = 3500

.PHONY: prefpane service foo release try

prefpane:
	mkdir -p $(DIST_DIR)
	xcodebuild
	cp -r build/Release/$(PREF_PANE) $(DIST_DIR)
	cp -r build/Release/$(PREF_PANE) ~/Library/PreferencePanes/

service:
	mkdir -p $(DIST_DIR)
	rm -rf /Applications/$(SERVICE_APP)
	rm -rf $(DIST_DIR)/$(SERVICE_APP)
	python setup.py py2app --dist-dir=$(DIST_DIR)
	cp -r $(DIST_DIR)/$(SERVICE_APP) /Applications/

dist: prefpane service
	ln -s ~/Library/PreferencePanes $(DIST_DIR)/Preferencias
	ln -s /Applications $(DIST_DIR)/Aplicaciones

release: prefpane service
	hdiutil "create dist/$(DMG_VOLUME).dmg" -srcfolder $(DIST_DIR) -ov

try: prefpane
	cp -r $(DIST_DIR)/$(PREF_PANE) ~/Library/PreferencePanes/
	killall "System Preferences" || true
	open ~/Library/PreferencePanes/$(PREF_PANE)

clean:
	rm -rf dist/*
	rm -rf build/*

dmg: dist
	rm -f pack.temp.dmg
	hdiutil create -srcfolder "$(DIST_DIR)" -volname "$(DMG_VOLUME)" -fs HFS+ \
		-fsargs "-c c=64,a=16,e=16" -format UDRW -size $(DMG_SIZE)k pack.temp.dmg
	DEVICE=`hdiutil attach -readwrite -noverify -noautoopen "pack.temp.dmg" | \
		egrep '^/dev/' | sed 1q | awk '{print $$1}'`
	echo "Device: ${DEVICE} $DEVICE"
	mkdir -p /Volumes/$(DMG_VOLUME)/.background
	cp dmg.png /Volumes/$(DMG_VOLUME)/.background/
	osascript dmg.scpt $(DMG_VOLUME) $(SERVICE_APP) $(PREF_PANE)
	chmod -Rf go-w /Volumes/"$(DMG_VOLUME)"
	sync
	sync
	hdiutil detach $DEVICE
	hdiutil convert "pack.temp.dmg" -format UDZO -imagekey zlib-level=9 -o "$(DMG_VOLUME).dmg"
	rm -f pack.temp.dmg


