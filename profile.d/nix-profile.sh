
ROOT_PS1='\[\033[01;31m\]\h\[\033[01;34m\] \w \$\[\033[00m\] '
USER_PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
ROOT_PS2='\[\033[01;32m\]|\[\033[00m\] '
USER_PS2='\[\033[01;32m\]|\[\033[00m\] '

if [ "${USERNAME}" == 'root' ]; then
    export PS1="${ROOT_PS1}"
    export PS2="${ROOT_PS2}"
else
    export PS1="${USER_PS1}"
    export PS2="${USER_PS2}"
    export SUDO_PS1="${ROOT_PS1}"
    export SUDO_PS2="${ROOT_PS2}"
fi

export PAGER=/usr/bin/most
export EDITOR=/usr/bin/vim
export BROWSER=/usr/bin/firefox

alias 'x'='clear'
alias 'su+'='sudo -Ei'
alias 'll'="ls $LS_OPTIONS -hl"
alias 'la'="ls $LS_OPTIONS -hla"
alias 'rm'='rm --preserve-root -v -I'
alias 'chown'='chown --preserve-root -v'
alias 'chmod'='chmod --preserve-root -v'
alias 'mkdir'='mkdir -p -v'
alias 'grep'='grep --color=auto'
alias 'cp'='cp -r -v'
alias 'mv'='mv -v'
alias 'emacs'='emacs -nw'
alias '..'='cd ..'
alias 'fucking'='sudo'

if [ -x /usr/sbin/mtr ]; then
    alias 'mtr'='/usr/sbin/mtr %s'
fi

# --- Start SSH agent --- #
if [ -r "${HOME}/.ssh/.ssh-agent" ]; then
    source "${HOME}/.ssh/.ssh-agent" 1>/dev/null
fi

agent()
{
    case "${1}" in
        'start')
            if [ -z "${SSH_AUTH_SOCK}" ] ; then
                eval `ssh-agent -s | tee ${HOME}/.ssh/.ssh-agent`
                ssh-add
            fi
        ;;
        'start-local')
            eval `ssh-agent -s`
        ;;
        'stop')
            kill -TERM ${SSH_AGENT_PID} &> /dev/null
        ;;
        'term')
            killall -s TERM ssh-agent
        ;;
        'restart')
            agent stop
            agent start
        ;;
        'status')
            ssh-add -l
        ;;
        'add')
            if [ -r "${2}" ]; then
                ssh-add "${2}"
            else
                echo "Can't read file ${2}" 1>&2
                return 1
            fi
        ;;
        *)
            echo "Usage:" 1>&2
            echo "   agent {start[-local]|stop|term|restart|status|add <key>}" 1>&2
            return 1
        ;;
    esac
}


# --- MyIP resolver --- #
_myip_ip4()
{
    echo -n 'IPv4: '
    curl -4 --no-keepalive \
            --silent \
            --connect-timeout "3" \
            --get "${1}" 2>/dev/null \
    || echo 'Unable to determine' 1>&2
}

_myip_ip6()
{
    echo -n 'IPv6: '
    curl -6 --no-keepalive \
            --silent \
            --connect-timeout "3" \
            --get "${1}" 2>/dev/null \
    || echo 'Unable to determine' 1>&2
}

myip()
{
    local _myip_url='https://myip.nix.org.ua'
    case "${1}" in
        4|v4|-4|-v4) _myip_ip4 "${_myip_url}" ;;
        6|v6|-6|-v6) _myip_ip6 "${_myip_url}" ;;
       help)
            echo 'Usage:'
            echo '   myip <options>'
            echo ''
            echo 'Options:'
            echo '   4|v4|-4|-v4 - resolve only IPv4 address'
            echo '   6|v6|-6|-v6 - resolve only IPv6 address'
            echo '   help - show help'
        ;;
        *)
            _myip_ip4 "${_myip_url}"
            _myip_ip6 "${_myip_url}"
        ;;
    esac

    return 0
}

