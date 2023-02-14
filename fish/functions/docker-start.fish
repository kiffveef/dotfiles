function docker-start
  set -l container (docker ps -af status=exited |
    fzf --exit-0 --header-lines=1 --reverse --height 40% |
    awk '{ print $1 }')

  if test -n "$container"
    echo -e "Starting container..."
    docker start $container
  end
end
