#
# ~/.bashrc
#

################################################################################
### PATH stuff

## pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
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
export HISTTIMEFORMAT="%Y-%m-%dT%T%z "
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
export PROMPT_COMMAND='echo -en "\033[m\033[38;5;2m"$(( `sed -n "s/MemFree:[\t ]\+\([0-9]\+\) kB/\1/p" /proc/meminfo`/1024))"\033[38;5;22m/"$((`sed -n "s/MemTotal:[\t ]\+\([0-9]\+\) kB/\1/Ip" /proc/meminfo`/1024 ))MB" \033[m\033[38;5;55m$(< /proc/loadavg)\033[m"' \
export PS1=' \e[1;35m\]$(date -Is)\n\[\e[1;30m\][\[\e[1;34m\]\u@\H\[\e[1;30m\]:\[\e[0;37m\]${SSH_TTY} \[\e[0;32m\]+${SHLVL}\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \[\e[1;92m\]\$\[\e[0m\] '

################################################################################
### Functions and aliases

# Get X window properties - output the window class (useful for i3 floating windows)
function windowclass() {
    xprop | awk '/WM_CLASS/ {print $NF}'
}

# Set X display brightness to maximum in case screen saver breaks it
alias dudeicantsee='xrandr --output "HDMI-0" --brightness 1'

# Update pacman mirrorlist with fastest 16 https mirrors updated in the last 4 hours
alias reflector-update='reflector --country "United States" --age 4 --protocol https --sort rate -f 16 --threads 16 | sudo tee /etc/pacman.d/mirrorlist'
alias ls='ls --color=auto'
alias ll='ls -al'
alias sl='ls'

# Daily progress report - useful for "WHAT WAS I EVEN DOING YESTERDAY?!"
alias dprentry='echo $@ >> ~/.dpr-$(date +%Y%m%d)'
alias printdpr='cat ~/.dpr-$(date +%Y%m%d)'

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

################################################################################
### Git-specific aliases/functions

alias gs='git status'
alias gp='git pull --all'
alias ga='git add -p'

################################################################################
### Terraform-specific aliases/functions

alias tf='terraform'
alias terraformit='terraform fmt && terraform validate && terraform plan && read -p "Press return to continue." && terraform apply'

