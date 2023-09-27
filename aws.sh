# shellcheck shell=bash

set_profile_aws() {
  unset AWS_ACCESS_KEY_ID 
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
  if [ "$#" -eq 0 ] 
  then 
    unset AWS_PROFILE
  else
    if ! ( grep -E "(\[|[[:space:]])$1\]" ~/.aws/config >/dev/null )
    then
      echo -e "${RED}\n  Error: Profile $1 not found\n${RESET}"
      return 1
    fi
    export AWS_PROFILE="$1"
  fi
  if [ "$AWS_PROFILE" ]
  then
    echo -e "\n${GREEN}AWS_PROFILE is set to ${RED}${AWS_PROFILE}\n ${RESET}"
  else
    echo -e "\n${BLUE} AWS_PROFILE is unset\n${RESET}"
  fi
}

_complete_set_profile_aws() {
  if [ "${#COMP_WORDS[@]}" != "2" ]; then
    return
  fi
  local profile_names
  readarray -t profile_names <<< "$(grep -E '\[profile' ~/.aws/config | grep -o -E '[[:space:]][[:alnum:]].+[[:alnum:]]')"
  if ( grep default ~/.aws/config &>/dev/null )
  then
    profile_names+=( 'default' )
  fi
  #COMPREPLY=($(compgen -W "${profile_names[*]}" -- "${COMP_WORDS[1]}"))
  readarray -t COMPREPLY <<< "$(compgen -W "${profile_names[*]}" -- "${COMP_WORDS[1]}")"
}

complete -F _complete_set_profile_aws set_profile_aws

docker_login_aws() {
  local region
  region='us-east-1'
  if [ "$1" ]
  then
    region="$1"
  fi
  local account_id
  account_id="$(aws sts get-caller-identity | yq -r .Account)"
  echo -e "\n${GREEN}Logging in to ${BLUE}${account_id}.dkr.ecr.${region}.amazonaws.com \n ${RESET}"
  aws ecr get-login-password | docker login --username AWS --password-stdin "${account_id}.dkr.ecr.${region}.amazonaws.com"
}

_complete_docker_login_aws() {
  if [ "${#COMP_WORDS[@]}" != "2" ]; then
    return
  fi
  local region_names
  region_names=(
    af-south-1 
    ap-east-1 
    ap-northeast-1 
    ap-northeast-2 
    ap-northeast-3 
    ap-south-1 
    ap-south-2 
    ap-southeast-1 
    ap-southeast-2 
    ap-southeast-3 
    ap-southeast-4 
    ca-central-1 
    cn-north-1 
    cn-northwest-1 
    eu-central-1 
    eu-central-2 
    eu-north-1 
    eu-south-1 
    eu-south-2 
    eu-west-1 
    eu-west-2 
    eu-west-3 
    il-central-1 
    me-central-1 
    me-south-1 
    sa-east-1 
    us-east-1 
    us-east-2 
    us-gov-east-1 
    us-gov-west-1 
    us-west-1 
    us-west-2
  )
  readarray -t COMPREPLY <<< "$(compgen -W "${region_names[*]}" -- "${COMP_WORDS[1]}")"
}

complete -F _complete_docker_login_aws docker_login_aws

docker_login_aws_public() {
  local region
  local registry_id

  while getopts "hr:i:" option
  do
    case "${option}" in
      r)
        region=${OPTARG}
      ;;
      i)
        registry_id=${OPTARG}
      ;;
      h)
        echo -e "\n    \033[33;01mUsage: \033[32;01m docker_login_aws_public -r REGION -i REGISTRY_ID\n\033[00m"
        return
      ;;
      *)
        echo -e "\n    \033[31;01m docker_login_aws_public -r REGION -i REGISTRY_ID\n\033[00m"
        return 1
      ;;
    esac
  done
  echo -e "\n${GREEN}Logging in to public.ecr.aws/${registry_id} \n ${RESET}"
  aws ecr-public get-login-password | docker login --username AWS --password-stdin "public.ecr.aws/${registry_id}"
}


set_aws_role_creds() {
  if ! [ "$1" ] || ! [ "$1" == "$(grep -o -E 'arn:aws:iam::[0-9]{12}:role/([[:alnum:]]|[\+=,\.@_-]){1,64}' <<< "$1")" ]
  then
    echo -e "  \033[01;34m$1 \033[01;31m is not a valid AWS IAM Role ARN\033[00m"
    return 1
  fi
  local creds
  local access_key
  local secret_key
  local sess_token
  echo -e "${GREEN}Getting credentials for the IAM Role ${BLUE}$1${RESET}"
  creds="$(aws sts assume-role --role-session-name "artyom-$(date +%s)" --role-arn "$1" )" || return 1
  access_key="$(yq .Credentials.AccessKeyId     <<< "$creds")"
  secret_key="$(yq .Credentials.SecretAccessKey <<< "$creds")"
  sess_token="$(yq .Credentials.SessionToken    <<< "$creds")"
  if ! [ "${access_key}" == 'null' ]
  then
    export "AWS_ACCESS_KEY_ID=$access_key" "AWS_SECRET_ACCESS_KEY=$secret_key" "AWS_SESSION_TOKEN=$sess_token"
  fi
  echo -e "${GREEN}Credentials are applied${RESET}"
}

set_creds_aws() {
  if ! [ "$1" ]
  then
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    echo -e "\n${BLUE} AWS credentials are unset\n${RESET}"
    return
  fi
  unset  AWS_PROFILE AWS_SESSION_TOKEN
  export AWS_ACCESS_KEY_ID="$1"
  export AWS_SECRET_ACCESS_KEY="$2"
  [ -n "$3" ] && export AWS_SESSION_TOKEN="$3"
}
