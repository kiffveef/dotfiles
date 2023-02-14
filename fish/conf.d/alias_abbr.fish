# 読み込み時は一旦全て削除してから
for a in (abbr --list); abbr --erase $a; end

abbr -a reload exec $SHELL -l
abbr -a md mkdir -p
abbr -a .. cd ../
abbr -a ... cd ../../
abbr -a .... cd ../../../
abbr -a vi nvim
abbr -a gti git

if type -q lsd
  abbr -a ls 'lsd -F --group-directories-first'
  abbr -a la 'lsd -aF --group-directories-first'
  abbr -a ll 'lsd -alF --group-directories-first'
end

if type -q ghq
  abbr -a ghq-update 'ghq list | ghq get --update --parallel'
end
