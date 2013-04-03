PREF_PANE = PBXForwarderPrefPane.prefPane
SERVICE_APP = PBXForwarderService.app
SERVICE_SCRIPT = pbxforwarderservice.py
DIST_DIR = dist/PBXForwarder
DMG = PBXForwarder.dmg

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

release: prefpane service
	hdiutil create dist/$(DMG) -srcfolder $(DIST_DIR) -ov

try: prefpane
	cp -r $(DIST_DIR)/$(PREF_PANE) ~/Library/PreferencePanes/
	killall "System Preferences" || true
	open ~/Library/PreferencePanes/$(PREF_PANE)

