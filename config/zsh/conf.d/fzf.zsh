# Ctrl-y bind lives here because enhancd splits ENHANCD_FILTER on colons
export FZF_DEFAULT_OPTS="--ansi -e --prompt='QUERY> ' --layout=reverse --border=rounded --height=50% --bind 'ctrl-y:execute-silent(printf %s {} | win32yank.exe -i)+abort'"
export FZF_DEFAULT_COMMAND="fd -H -E .git --color=always"

export FZF_CTRL_T_OPTS="--preview 'bat  --color=always --style=header,grid {}' --preview-window=right:60%"
export FZF_CTRL_T_COMMAND="rg --files --hidden --follow --glob '!**/.git/*'"

export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# cf. https://gist.github.com/sheepla/d680f1480d8c36c4290d6aabebf1abc6
function _fzf_cd_ghq() {
    # FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --reverse --height=50%"
    local root="$(ghq root)"
    # ghq list prints paths relative to ghq root, so Ctrl-y must prepend it
    local repo="$(ghq list | fzf --preview="lsd -1F --group-directories-first ${root}/{1}" \
        --bind="ctrl-y:execute-silent(printf %s ${root}/{} | win32yank.exe -i)+abort")"
    local dir="${root}/${repo}"
    [ -n "${repo}" ] && cd "${dir}"
    zle accept-line
    zle reset-prompt
}

zle -N _fzf_cd_ghq
bindkey "^h" _fzf_cd_ghq

# Zellij session selector
function _fzf_zellij_session() {
    # Get sessions and remove ANSI color codes
    local sessions
    sessions=$(zellij list-sessions 2>&1 | sed -r 's/\x1b\[[0-9;]*m//g')

    # Check if no sessions exist
    if [[ -z "$sessions" ]] || [[ "$sessions" == *"No active zellij sessions found"* ]]; then
        BUFFER="zellij"
        zle accept-line
        return 0
    fi

    local session_list=$(echo "$sessions" | awk '{print $1}')
    local selected=$(echo "$session_list" | fzf \
        --prompt="Zellij Session> " \
        --preview="zellij list-sessions | grep {}" \
        --preview-window=right:50%:wrap \
        --header="ENTER: attach | ESC: cancel")

    if [[ -n "$selected" ]]; then
        BUFFER="zellij attach \"$selected\""
        zle accept-line
    else
        zle reset-prompt
    fi
}

zle -N _fzf_zellij_session
bindkey "^z" _fzf_zellij_session
