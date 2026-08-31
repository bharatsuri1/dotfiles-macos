install_chrome_defaults() {
  # User-level managed Chrome policies: read from ~/Library/Preferences/com.google.Chrome.plist.
  # Chrome must be restarted for these to take effect.
  defaults_write com.google.Chrome DefaultBrowserSettingEnabled -bool false
  defaults_write com.google.Chrome DefaultNotificationsSetting -int 2    # 2 = block all site notifications
  defaults_write com.google.Chrome PasswordManagerEnabled -bool false    # rely on 1Password instead
  log 'Chrome policies written; restart Chrome to apply'
}
