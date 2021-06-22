#
# ~/.bashrc
#

################################################################################
### PATH stuff

## pyenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv virtualenvwrapper

## npm

# Store NPM packages in homedir
NPM_PACKAGES="${HOME}/.npm-packages"

# Tell Node about these packages
NODE_PATH="${NPM_PACKAGES}/lib/node_modules:${NODE_PATH}"

# Tell our environment about user-installed node tools
PATH="${NPM_PACKAGES}/bin:${PATH}"

# Expand our manpath to include node docs
MANPATH="${NPM_PACKAGES}/share/man:$(manpath)"

################################################################################
### Terminal behavior

# Bash history awesomeness
export HISTTIMEFORMAT="%A %Y-%m-%dT%T%z "
export HISTCONTROL="ignoredups:ignorespace"
export HISTSIZE="-1"
export HISTFILESIZE="-1"
shopt -u histappend
shopt -s cmdhist
shopt -s lithist

# Vim all the things
export EDITOR=vim
export VISUAL=vim

# make Ctrl-W delete portions of words
stty werase undef
bind '\C-w:unix-filename-rubout'
# and prevent dotfiles from being tabbed by default (must type a dot first)
bind 'set match-hidden-files off'

# OG PS1
# PS1='[\u@\h \W]\$ '
# New PS1
export PROMPT_COMMAND='log_bash_persistent_history; echo -en "\033[m\033[38;5;2m"$(( `sed -n "s/MemFree:[\t ]\+\([0-9]\+\) kB/\1/p" /proc/meminfo`/1024))"\033[38;5;22m/"$((`sed -n "s/MemTotal:[\t ]\+\([0-9]\+\) kB/\1/Ip" /proc/meminfo`/1024 ))MB" \033[m\033[38;5;55m$(< /proc/loadavg)\033[m"' \
export PS1=' \e[1;35m\]$(date -Is)\n\[\e[1;30m\][\[\e[1;34m\]\u@\H\[\e[1;30m\]:\[\e[0;37m\]${SSH_TTY} \[\e[0;32m\]+${SHLVL}\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \[\e[1;92m\]\$\[\e[0m\] '

################################################################################
### Functions and aliases

# Some sort of persistent bash history thing, maybe
log_bash_persistent_history()
{
  [[
    $(history 1) =~ ^\ *[0-9]+\ +([^\ ]+\ [^\ ]+)\ +(.*)$
  ]]
  local date_part="${BASH_REMATCH[1]}"
  local command_part="${BASH_REMATCH[2]}"
  if [ "$command_part" != "$PERSISTENT_HISTORY_LAST" ]
  then
    echo $date_part "|" "$command_part" >> ~/.persistent_history
    export PERSISTENT_HISTORY_LAST="$command_part"
  fi
}

# Get X window properties - output the window class (useful for i3 floating windows)
function windowclass() {
    xprop | awk '/WM_CLASS/ {print $NF}'
}

# Set X display brightness to maximum in case screen saver breaks it
alias dudeicantsee='xrandr --output "HDMI-0" --brightness 1'

# Update pacman mirrorlist with fastest 16 https mirrors updated in the last 4 hours
alias reflector-update='reflector --country "United States" --age 4 --protocol https --sort rate -f 16 --threads 16 | sudo tee /etc/pacman.d/mirrorlist'
alias grep='grep --color'
alias fgrep='fgrep --color'
alias ls='ls --color=auto'
alias sl='ls'
alias ll='ls -al'
alias l='ll'

# Daily progress report - useful for "WHAT WAS I EVEN DOING YESTERDAY?!"
alias dpr='echo "*${@}" >> ~/.dpr-$(date +%Y%m%d)'
alias printdpr='cat ~/.dpr-$(date +%Y%m%d)'
alias dso='sh ~/.local/bin/dso.sh'

################################################################################
### Docker

## Fancy experimental build time/info
export DOCKER_BUILDKIT=1

################################################################################
### AWS-specific aliases/functions

# Used to fix terraform due to the AWS Go SDK lagging behind in AWS SSO functionality
export AWS_SDK_LOAD_CONFIG=1

# Assume a role and spit out its credentials
function assumerole() {
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
    eval $(aws sts assume-role --role-arn ${1} --role-session-name $(date +%Y%m%dT%H%M) | jq -jr ".Credentials | (\"export AWS_ACCESS_KEY_ID='\",.AccessKeyId,\"'\"),\"\n\", (\"export AWS_SECRET_ACCESS_KEY='\",.SecretAccessKey,\"'\"),\"\n\", (\"export AWS_SESSION_TOKEN='\",.SessionToken,\"'\"),\"\n\"")
    aws sts get-caller-identity
    egrep "(AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|AWS_SESSION_TOKEN)" <(printenv)
}

# Log into ECR using current credentials
function ecrlogin () {
  ECR_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
  ECR_REGION="${ECR_REGION:-"us-east-1"}"
  echo "Using ECR region ${ECR_REGION} - if you need to change this, export ECR_REGION."
  if ! aws --region ${ECR_REGION} ecr get-login-password | docker login --username AWS --password-stdin ${ECR_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com 2> /dev/null
  then
    return 1
  else
    echo "Describing ECR repositories in ${ECR_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com..."
    aws --region ${ECR_REGION} ecr describe-repositories
    return 0
  fi
}
function ecrlogin-main () {
  REGION_REGEX='^[a-z]{2}-.*?-[1-3]$'
  ACCOUNT_REGEX='^[0-9]{12}$'
  if [ -e ~/.ecr_config ]
  then
    source ~/.ecr_config
    if [[ ${ECR_ACCOUNT_ID+x} ]] && [[ ${ECR_REGION+x} ]]
    then
      if ! aws --region ${ECR_REGION} ecr get-login-password | docker login --username AWS --password-stdin ${ECR_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com 2> /dev/null
      then
        return 1
      else
        echo "Describing ECR repositories in ${ECR_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com..."
        aws --region ${ECR_REGION} ecr describe-repositories
        return 0
      fi
    else
      echo "Error: malformed config file: ~/.ecr_config"
      BAD_ECR_CONFIG=1
    fi
  else
    BAD_ECR_CONFIG=1
  fi
  
  if [[ ${BAD_ECR_CONFIG+x} ]]
  then
    echo "Error: You must first populate a file located at ~/.ecr_config to include the 12-digit AWS account ID and region in which the ECR is located, as follows:"
    echo "export ECR_REGION='us-east-2'"
    echo "export ECR_ACCOUNT_ID='000000000000'"
  fi
}

# List AWS profiles within the configuration
alias profiles="aws configure list-profiles | perl -pe 's|^|export AWS_PROFILE=|'"

# Find the CloudFormation stack for a resource
alias cfnfind='aws cloudformation describe-stack-resources --query 'StackResources[].StackName' --physical-resource-id'

################################################################################
### GitHub

source ~/.github_token

################################################################################
### Terraform-specific aliases/functions

alias tf='terraform'
alias terraformit='terraform fmt && terraform validate && terraform plan && read -p "Press return to continue." && terraform apply'

