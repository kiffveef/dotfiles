function docker-exec
  set -l container (docker ps -af status=running |
    fzf --exit-0 --header-lines=1 --reverse --height 40% |
    awk '{ print $1 }')

  if test -n "$container"
    docker exec -it $container bash
  end
end
