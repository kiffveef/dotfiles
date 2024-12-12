if type sheldon &>/dev/null; then
  eval "$(sheldon source)"
fi

ls $ZDOTDIR/conf.d/*.zsh >/dev/null 2>&1
if [ ! $? -ne 0 ]; then
  for conf in "$ZDOTDIR/conf.d/"*.zsh; do
    source "${conf}"
  done
  unset conf
fi

