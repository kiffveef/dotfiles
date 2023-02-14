function fad
  set -l files (git status --short --branch -u |
    grep -v '##' |
    awk '{ print $2 }' |
    fzf-tmux --multi --preview "batdiff --color=always {}")
  or return

  git add $files && git status --short --branch -u
end
