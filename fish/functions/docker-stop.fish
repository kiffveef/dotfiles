function docker-start
  set -l container (docker ps -af status=running |
    fzf --exit-0 --header-lines=1 --reverse --height 40% |
    awk '{ print $1 }')

  if test -n "$container"
    echo -e "Stoping container..."
    docker stop $container
  end
end
