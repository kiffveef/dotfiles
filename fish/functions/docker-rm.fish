function docker-rm
  set -l container (docker ps -a |
    fzf --multi --exit-0 --header-lines=1 --reverse --height 40% |
    awk '{ print $1 }')

  if test -n "$container"
    docker rm $container
  end
end
