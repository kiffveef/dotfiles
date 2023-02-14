function fcd -d "Change local repository"
  ghq list --full-path |
    fzf-tmux --preview "bat --color=always --style=header,grid /{}/README.*" |
    read -l repo_path
  or return

  cd $repo_path
end
