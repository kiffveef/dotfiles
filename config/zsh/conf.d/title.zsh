# 端末タイトル (OSC 2) をプロンプトごとに設定する
#
# zellij0.45 は、ペインが1つだけのタブでタブ名が既定 (Tab #N) のままだと、
# ペインのタイトルをタブ名として表示する。Claude Code は終了時にタイトルを
# 空文字で上書きするため、シェル側で設定しないとタブ名が空のままになる。
# プロンプト表示時はディレクトリ名、コマンド実行中はコマンド名をタイトルにする。

autoload -Uz add-zsh-hook

function _title_precmd() {
    print -Pn '\e]2;%1~\a'
}

function _title_preexec() {
    # $1 は実行されるコマンド行。先頭の単語 (コマンド名) だけを使う
    print -n "\e]2;${1%% *}\a"
}

add-zsh-hook precmd _title_precmd
add-zsh-hook preexec _title_preexec
