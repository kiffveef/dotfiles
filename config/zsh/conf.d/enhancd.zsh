export ENHANCD_HOOK_AFTER_CD="lsd --group-directories-first -laF"

# ghq get wrapper to add directory to enhancd history
function ghq() {
  if [[ "$1" == "get" ]]; then
    # Execute original ghq get
    command ghq "$@"
    local exit_code=$?

    # If successful, cd to the cloned directory to register in enhancd history
    if [[ $exit_code -eq 0 ]]; then
      local repo_path=$(command ghq list --full-path | tail -n 1)
      if [[ -n "$repo_path" ]] && [[ -d "$repo_path" ]]; then
        cd "$repo_path"
      fi
    fi

    return $exit_code
  else
    # Pass through other ghq commands
    command ghq "$@"
  fi
}
