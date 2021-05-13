#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# initialize PATH
unset PATH
PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl

# Bash history awesomeness
export HISTTIMEFORMAT="%Y-%m-%dT%T%z "
export HISTCONTROL="ignoredups:ignorespace"
export HISTSIZE="-1"
export HISTFILESIZE="-1"
shopt -u histappend
shopt -s cmdhist
shopt -s lithist

# IDE
export EDITOR=vim
export VISUAL=vim

# make Ctrl-W delete portions of words
stty werase undef
bind '\C-w:unix-filename-rubout'
# and prevent dotfiles from being tabbed by default (must type a dot first)
bind 'set match-hidden-files off'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
pyenv virtualenvwrapper

# npm
# NPM packages in homedir
NPM_PACKAGES="${HOME}/.npm-packages"

# Tell our environment about user-installed node tools
PATH="${NPM_PACKAGES}/bin:${PATH}"
# Unset manpath so we can inherit from /etc/manpath via the `manpath` command
unset MANPATH  # delete if you already modified MANPATH elsewhere in your configuration
MANPATH="${NPM_PACKAGES}/share/man:$(manpath)"

# Tell Node about these packages
NODE_PATH="${NPM_PACKAGES}/lib/node_modules:${NODE_PATH}"

# OG PS1
# PS1='[\u@\h \W]\$ '
# New PS1
export PROMPT_COMMAND='echo -en "\033[m\033[38;5;2m"$(( `sed -n "s/MemFree:[\t ]\+\([0-9]\+\) kB/\1/p" /proc/meminfo`/1024))"\033[38;5;22m/"$((`sed -n "s/MemTotal:[\t ]\+\([0-9]\+\) kB/\1/Ip" /proc/meminfo`/1024 ))MB" \033[m\033[38;5;55m$(< /proc/loadavg)\033[m"' \
export PS1=' \e[1;35m\]$(date -Is)\n\[\e[1;30m\][\[\e[1;34m\]\u@\H\[\e[1;30m\]:\[\e[0;37m\]${SSH_TTY} \[\e[0;32m\]+${SHLVL}\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \[\e[1;92m\]\$\[\e[0m\] '

### Variables
export AWS_SDK_LOAD_CONFIG=1
export DOCKER_BUILDKIT=1

### Functions
function windowclass() {
    xprop | awk '/WM_CLASS/ {print $NF}'
}

function assumerole() {
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
    eval $(aws sts assume-role --role-arn ${1} --role-session-name $(date +%Y%m%dT%H%M) | jq -jr ".Credentials | (\"export AWS_ACCESS_KEY_ID='\",.AccessKeyId,\"'\"),\"\n\", (\"export AWS_SECRET_ACCESS_KEY='\",.SecretAccessKey,\"'\"),\"\n\", (\"export AWS_SESSION_TOKEN='\",.SessionToken,\"'\"),\"\n\"")
    aws sts get-caller-identity
    printenv | egrep "(AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|AWS_SESSION_TOKEN)"
}

### Aliases
alias ls='ls --color=auto'
alias ll='ls -al'
alias sl='ls'
#alias aws-azure-login='npx aws-azure-login'
alias gs='git status'
alias gp='git pull --all'
alias ga='git add -p'
alias profiles="aws configure list-profiles | perl -pe 's|^|export AWS_PROFILE=|'"
alias tf='terraform'
alias dudeicantsee='xrandr --output "HDMI-0" --brightness 1'
alias terraformit='terraform fmt && terraform validate && terraform plan && read -p "Press return to continue." && terraform apply'

alias dprentry='echo $@ >> ~/.dpr-$(date +%Y%m%d)'
alias printdpr='cat ~/.dpr-$(date +%Y%m%d)'

alias ecrlogin='source ~/.ECR_ACCOUNT_ID && aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin ${ECR_ACCOUNT_ID}.dkr.ecr.us-east-2.amazonaws.com'
