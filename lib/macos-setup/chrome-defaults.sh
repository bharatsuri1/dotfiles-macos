install_chrome_defaults() {
  section Chrome
  # User-level managed Chrome policies: read from ~/Library/Preferences/com.google.Chrome.plist.
  # Chrome must be restarted for these to take effect.
  defaults_write com.google.Chrome DefaultBrowserSettingEnabled -bool false
  defaults_write com.google.Chrome DefaultNotificationsSetting -int 2    # 2 = block all site notifications
  defaults_write com.google.Chrome PasswordManagerEnabled -bool false    # rely on 1Password instead
  log 'Chrome policies written; restart Chrome to apply'
}

show_chrome_defaults_status() {
  section Chrome
  defaults_group_status policies \
    com.google.Chrome DefaultBrowserSettingEnabled bool false \
    com.google.Chrome DefaultNotificationsSetting int 2 \
    com.google.Chrome PasswordManagerEnabled bool false
}
