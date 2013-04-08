-- This script pimps the .dmg volume
-- ARGV:
-- 1 DMG_VOLUME
-- 2 PREF_PANE
-- 3 SERVICE_APP

on run argv
    -- tell application "Terminal" to display dialog (item 1 of argv)
    tell application "Finder"
        tell disk (item 1 of argv)
            open
            set current view of container window to icon view
            set toolbar visible of container window to false
            set statusbar visible of container window to false
            set opts to the icon view options of container window
            tell opts
                set icon size to 72
                set arrangement to not arranged
            end tell
            set background picture of opts to file ".background:dmg.png"
            set the bounds of container window to {303, 176, 1002, 574}
            -- pref pane
            set position of item (item 2 of argv) of container window to {131, 107}
            -- service app
            set position of item (item 3 of argv) of container window to {131, 237}
            -- symlinks
            set position of item "Preferencias" of container window to {570, 108}
            set position of item "Aplicaciones" of container window to {570, 243}
            -- close and open to force the .DSStore to be written 
            -- and thus the above position commands to work
            close
            open
            update without registering applications
            delay 5
        end tell
    end tell
end run