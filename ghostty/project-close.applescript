on run argv
    set actionName to item 1 of argv
    set projectTag to item 2 of argv
    set workTitle to projectTag & "-work"
    set serverTitle to projectTag & "-server"

    if application "Ghostty" is not running then return 0

    tell application "Ghostty"
        set matchingIds to {}
        repeat with win in windows
            repeat with theTab in tabs of win
                set tabTitle to name of theTab
                if tabTitle is workTitle or tabTitle is serverTitle then
                    set end of matchingIds to id of win
                    exit repeat
                end if
            end repeat
        end repeat

        if actionName is "count" then
            return count of matchingIds
        else if actionName is "close" then
            set frontId to id of front window
            repeat with windowId in matchingIds
                if (contents of windowId) is not frontId then
                    close window (first window whose id is (contents of windowId))
                end if
            end repeat
            if matchingIds contains frontId then
                close window (first window whose id is frontId)
            end if
            return count of matchingIds
        else
            error "Unknown project-close action."
        end if
    end tell
end run
