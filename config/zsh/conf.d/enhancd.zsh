export ENHANCD_HOOK_AFTER_CD="lsd --group-directories-first -laF"

# ghq get wrapper to add directory to enhancd history
function ghq() {
  if [[ "$1" == "get" ]]; then
    # Execute original ghq get
    command ghq "$@"
    local exit_code=$?

    # If successful, cd to the cloned directory to register in enhancd history
    if [[ $exit_code -eq 0 ]]; then
      # ghq list is sorted, so resolve the clone by owner/repo from the last argument instead of taking its tail
      local spec="${@[-1]%/}"
      spec="${spec%.git}"
      spec="${spec##*:}"
      local -a parts=(${(s:/:)spec})
      # zsh yields an empty slice when -2 is out of range, so only trim URLs with a host part
      (( $#parts > 2 )) && spec="${(j:/:)parts[-2,-1]}"
      local repo_path=$(command ghq list -p -e "$spec" | head -n 1)
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
