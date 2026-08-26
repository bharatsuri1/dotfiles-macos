readonly XDG_DATA_HOME_RESOLVED="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly SCREENSHOTS_DIR="${XDG_SCREENSHOTS_DIR:-$XDG_DATA_HOME_RESOLVED/pictures/screenshots}"

# Apply a single `defaults write` so dry-run output stays inspectable. Values
# are written idempotently; a later phase must killall any daemons whose UI
# state needs to refresh (Finder, Dock, SystemUIServer).
defaults_write() {
  run defaults write "$@"
}

apply_keyboard_defaults() {
  log 'applying keyboard defaults'
  # Fast key repeat with a short initial delay for Vim-style motion.
  defaults_write NSGlobalDomain KeyRepeat -int 2
  defaults_write NSGlobalDomain InitialKeyRepeat -int 15
  # Repeat keys on hold instead of showing the accented-character menu.
  defaults_write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  # Disable automatic text substitution so typed characters stay literal.
  defaults_write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  defaults_write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  defaults_write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
  defaults_write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults_write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
}

apply_finder_defaults() {
  log 'applying Finder defaults'
  defaults_write com.apple.finder AppleShowAllFiles -bool true
  defaults_write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults_write com.apple.finder ShowPathbar -bool true
  defaults_write com.apple.finder ShowStatusBar -bool true
  # Default to list view.
  defaults_write com.apple.finder FXPreferredViewStyle -string "Nlsv"
  # Scope searches to the current folder instead of This Mac.
  defaults_write com.apple.finder FXDefaultSearchScope -string "SCcf"
  defaults_write com.apple.finder FXEnableExtensionChangeWarning -bool false
  # Show the full POSIX path in the window title (false = default behavior).
  defaults_write com.apple.finder _FXShowPosixPathInTitle -bool false
  # Avoid writing .DS_Store on network and removable volumes.
  defaults_write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  # Keep files/folders on the Desktop but hide volume icons (external drives,
  # removable media, internal disks, network shares) so mounting a DMG does
  # not clutter the desktop.
  defaults_write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
  defaults_write com.apple.finder ShowRemovableMediaOnDesktop -bool false
  defaults_write com.apple.finder ShowHardDrivesOnDesktop -bool false
  defaults_write com.apple.finder ShowMountedServersOnDesktop -bool false
}

apply_dock_defaults() {
  log 'applying Dock defaults'
  defaults_write com.apple.dock tilesize -int 64
  defaults_write com.apple.dock autohide -bool true
  # Show and hide the dock instantly: no hover delay and no slide animation.
  defaults_write com.apple.dock autohide-delay -float 0.0
  defaults_write com.apple.dock autohide-time-modifier -float 0
  defaults_write com.apple.dock show-recents -bool false
  # Keep Spaces in their original order; do not reorder by usage.
  defaults_write com.apple.dock mru-spaces -bool false
  defaults_write com.apple.dock minimize-to-application -bool true
  defaults_write com.apple.dock largesize -int 96
  defaults_write com.apple.dock launchanim -bool false
}

apply_trackpad_defaults() {
  log 'applying trackpad defaults'
  defaults_write com.apple.AppleMultitouchTrackpad Clicking -bool true
  defaults_write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
  # Mouse pointer acceleration is intentionally left at the macOS default.
  # Slightly faster scroll speed.
  defaults_write NSGlobalDomain com.apple.scrollwheel.scaling -float 0.5
}

apply_screenshot_defaults() {
  log 'applying screenshot defaults'
  run mkdir -p "$SCREENSHOTS_DIR"
  defaults_write com.apple.screencapture location -string "$SCREENSHOTS_DIR"
  defaults_write com.apple.screencapture type -string "png"
  defaults_write com.apple.screencapture disable-shadow -bool true
  defaults_write com.apple.screencapture show-thumbnail -bool false
}

apply_menubar_defaults() {
  log 'applying menu bar defaults'
  defaults_write com.apple.menuextra.clock ShowDate -int 1
  defaults_write com.apple.menuextra.clock ShowDayOfWeek -bool true
  defaults_write com.apple.menuextra.battery ShowPercent -string YES
}

apply_general_defaults() {
  log 'applying general UI defaults'
  defaults_write NSGlobalDomain AppleInterfaceStyle -string "Dark"
  defaults_write NSGlobalDomain AppleReduceDesktopTinting -bool true
  # Merge the titlebar and toolbar for a cleaner window chrome.
  defaults_write NSGlobalDomain NSTitlebarToolbarSeparatorStyle -string "none"
  # Expand the save and print panels by default.
  defaults_write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults_write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  # Save new documents locally instead of prompting for iCloud.
  defaults_write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
}

install_macos_defaults() {
  apply_keyboard_defaults
  apply_finder_defaults
  apply_dock_defaults
  apply_trackpad_defaults
  apply_screenshot_defaults
  apply_menubar_defaults
  apply_general_defaults
  # Affect running apps: restart the UI daemons whose defaults we changed so
  # the new values take effect without a logout. Finder and Dock relaunch
  # automatically.
  log 'restarting Finder, Dock, and SystemUIServer to apply defaults'
  run killall Finder || true
  run killall Dock || true
  run killall SystemUIServer || true
}
