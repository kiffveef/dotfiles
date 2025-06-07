export FZF_DEFAULT_OPTS="--ansi -e --prompt='QUERY> ' --layout=reverse --border=rounded --height=50%"
export FZF_DEFAULT_COMMAND="fd -H -E .git --color=always"

export FZF_CTRL_T_OPTS="--preview 'bat  --color=always --style=header,grid {}' --preview-window=right:60%"
export FZF_CTRL_T_COMMAND="rg --files --hidden --follow --glob '!**/.git/*'"

export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# cf. https://gist.github.com/sheepla/d680f1480d8c36c4290d6aabebf1abc6
function _fzf_cd_ghq() {
    # FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --reverse --height=50%"
    local root="$(ghq root)"
    local repo="$(ghq list | fzf --preview="lsd -1F --group-directories-first ${root}/{1}")"
    local dir="${root}/${repo}"
    [ -n "${dir}" ] && cd "${dir}"
    zle accept-line
    zle reset-prompt
}

zle -N _fzf_cd_ghq
bindkey "^g" _fzf_cd_ghq

# cf. https://www.mizdra.net/entry/2024/10/19/172323
user_name=$(git config user.name)
fmt="\
  %(if:equals=$user_name)%(authorname)%(then)%(color:default)%(else)%(color:brightred)%(end)%(refname:short) | \
  %(authordate:format-local:%Y/%m/%d %H:%M:%S) | \
  %(subject)"

_fzf_git_brach_select_friendly() {
  selected_branch=$(
    git branch --all --sort=-committerdate --format=$fmt --color=always \
    | column -ts'|' \
    | fzf --ansi --exact --preview='git log-format-fzf-list --graph --decorate --color=always -50 {+1}' \
    | awk '{print $1}' \
  )

  # BUFFER="${LBUFFER}${selected_branch}${RBUFFER}"
  # CORSOR=$#BUFFERE+$#selected_branch
  # zle redisplay
  git checkout $selected_branch
}

zle -N _fzf_git_brach_select_friendly
bindkey "^b" _fzf_git_brach_select_friendly
