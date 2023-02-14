function docker-rmi
  set -l images (docker images |
    fzf --multi --exit-0 --header-lines=1 --reverse --height 40% |
    awk '{ print $3 }')

  if test -n "$images"
    docker rmi $images
  end
end
