function fish_user_key_bindings
  # Bind peco_select_history to Ctrl+R
  bind \cr peco_select_history

  # Bind peco_change_directory to Ctrl+F
  bind \cf peco_change_directory

  bind \cl forward-char
  bind \cd delete-char
end
