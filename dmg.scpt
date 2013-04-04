-- ARGV:
-- 1 DMG_VOLUME
-- 2 SERVICE_APP
-- 3 PREF_PANE

on run argv
    -- tell application "Terminal" to display dialog (item 1 of argv)
    tell application "Finder"
        tell disk (item 1 of argv)
            open
            set current view of container window to icon view
            set toolbar visible of container window to false
            set statusbar visible of container window to false
            set the bounds of container window to {400, 100, 980, 600}
            set viewoptions to the icon view options of container window
            set arrangement of viewoptions to not arranged
            set icon size of viewoptions to 72
            set background picture of viewoptions to file ".background:dmg.png"
            set position of item (item 2 of argv) of container window to {300, 200}
            set position of item "Aplicaciones" of container window to {475, 200}
            set position of item (item 3 of argv) of container window to {300, 400}
            set position of item "Preferencias" of container window to {475, 400}
            update without registering applications
            delay 2
            eject
        end tell
    end tell
end run