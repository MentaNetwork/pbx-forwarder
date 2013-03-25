PREF_PANE = PBXForwarderPrefPane.prefPane
SERVICE_APP = PBXForwarderService.app
SERVICE_SCRIPT = pbxforwarderservice.py
DIST_DIR = dist/PBXForwarder
DMG = PBXForwarder.dmg

.PHONY: prefpane app foo release try

prefpane:
	mkdir -p $(DIST_DIR)
	xcodebuild
	cp -r build/Release/$(PREF_PANE) $(DIST_DIR)

app:
	mkdir -p $(DIST_DIR)
	python appbuilder.py $(SERVICE_SCRIPT) $(SERVICE_APP)
	rm -rf $(DIST_DIR)/$(SERVICE_APP)
	cp -r $(SERVICE_APP) $(DIST_DIR)/
	rm -r $(SERVICE_APP)

release: prefpane app
	hdiutil create dist/$(DMG) -srcfolder $(DIST_DIR) -ov

try: prefpane
	cp -r $(DIST_DIR)/$(PREF_PANE) ~/Library/PreferencePanes/
	killall "System Preferences" || true
	open ~/Library/PreferencePanes/$(PREF_PANE)

