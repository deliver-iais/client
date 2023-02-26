function fail {
  echo $1 >&2
  exit 1
}

function retry {
  local n=1
  local max=50
  local delay=2
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        fail "The command has failed after $n attempts."
      fi
    }
  done
}

retry timeout 30m flutter pub get