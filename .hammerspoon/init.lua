local function isScreenSharing()
    local success, result = hs.osascript.applescript([[
        tell application "System Events"
            set sharedScreens to current user's screensaver preferences
            return (exists sharedScreens)
        end tell
    ]])
    return success and result
end

-- Example usage
if isScreenSharing() then
    hs.alert.show("Screen Sharing Detected")
else
    hs.alert.show("No Screen Sharing")
end
