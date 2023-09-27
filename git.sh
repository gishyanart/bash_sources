# shellcheck shell=bash

gh_checkout() {
  if [ "$1" ]
  then
    if [ "$2" ]
    then
      git checkout -b "$1/$2"
    else
      git checkout -b "$1/pr-$(date +%s)"
    fi
  else
    git checkout -b "pr/$(date +%s)"
  fi
} 

gh_token() {
  init_file() {
    touch "$HOME/.config/gh_tokens.yaml"
    chmod 600 "$HOME/.config/gh_tokens.yaml"
    (command -v yq 1>/dev/null) || {
      echo -e "\n\033[01;32    Error. 'yq' command not found Download and install: https://github.com/mikefarah/yq. Breaking now!!!\033[00m\n"
      return 1
      }
  }
  set_token() {
    ORG="$1" TOKEN="$2" yq eval -i '.[env(ORG)] = env(TOKEN)' "$HOME/.config/gh_tokens.yaml"
  }
  get_token() {
    if [ "$1" ]
    then
      ORG="$1" yq '.[env(ORG)]' "$HOME/.config/gh_tokens.yaml"
    else
      yq -oy -P '.' "$HOME/.config/gh_tokens.yaml"
    fi
  }
  delete_token() {
    ORG="$1" yq eval -i 'del(.[env(ORG)])' "$HOME/.config/gh_tokens.yaml"
  }
  apply_token() {
    local token
    token="$(ORG="$1" yq '.[env(ORG)]' "$HOME/.config/gh_tokens.yaml")"
    export GITHUB_TOKEN="$token"
  }
  case "${1}" in
    init)
      init_file
      ;;
    get)
      init_file
      get_token "$2"
      ;;
    set)
      init_file
      set_token "$2" "$3"
      ;;
    delete)
      init_file
      delete_token "$2"
      ;;
    apply)
      init_file
      apply_token "$2"
      ;;
    *)
      echo -e "\n\033[01;31mError. Command not valid. Valid values are {init|set|get|delete|apply}\033[00m\n"
      ;;
    esac
    

}

_complete_gh_token() {
  local commands
  local orgs
  local prev
  declare -A commands=(
    [init]=1
    [get]=1
    [set]=1
    [delete]=1
    [apply]=1
  )
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  if [ "${COMP_CWORD}" -eq "1" ]; then
    readarray -t COMPREPLY <<< "$(compgen -W "${!commands[*]}" -- "${COMP_WORDS[1]}")"
  elif [ "${COMP_CWORD}" -eq "2" ]
  then
      if ! [ "${commands[${prev}]}" ] || [ "${prev}" == 'init' ]
      then
        return
      else
        readarray -t orgs <<< "$(yq '(. | keys)[]' "$HOME/.config/gh_tokens.yaml")"
        readarray -t COMPREPLY <<< "$(compgen -W "${orgs[*]}" -- "${COMP_WORDS[2]}")"
      fi
  else
    return
  fi
}

complete -F _complete_gh_token gh_token
