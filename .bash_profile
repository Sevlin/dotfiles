#!/usr/bin/env bash
readonly __COLRST='\033[00m'
readonly __COLRED='\033[01;31m'
readonly __COLGRN='\033[01;32m'
readonly __COLYLW='\033[01;33m'
readonly __COLBLU='\033[01;34m'

__ROOT_PS1="\[${__COLRED}\]\h\[${__COLBLU}\] \w #\[${__COLRST}\] "
__USER_PS1="\[${__COLGRN}\]\u@\h\[${__COLBLU}\] \w \$\[${__COLRST}\] "
__ROOT_PS2="\[${__COLYLW}\]|\[${__COLRST}\] "
__USER_PS2="\[${__COLYLW}\]|\[${__COLRST}\] "

__which_first_found()
{
    local ___entry=''

    if [ ${#} -ne 0 ]; then
        for e in ${@}; do
            ___entry="$(which ${e})"

            if [ ! -z "${___entry}" ]; then
                echo "${___entry}"
                break
            fi
        done
    fi
}

__export_ps()
{
    if [ "${USERNAME}" == 'root' ]; then
        export PS1="${__ROOT_PS1}"
        export PS2="${__ROOT_PS2}"
    else
        export PS1="${__USER_PS1}"
        export PS2="${__USER_PS2}"
        export SUDO_PS1="${__ROOT_PS1}"
        export SUDO_PS2="${__ROOT_PS2}"
    fi
}

__export_pager()
{
    local ___pager=''

    # User-defined
    if [ ! -z "${1}" ]; then
        ___pager="$(which ${1})"

    # Guess
    else
        ___pager="$(__which_first_found 'most' 'less' 'more')"
    fi

    # Export existing pager
    if [ ! -z "${___pager}" ]; then
        export PAGER="${___pager}"
    fi
}

__export_editor()
{
    local ___editor=''

    # User-defined
    if [ ! -z "${1}" ]; then
        ___editor="$(which ${1})"

    # Guess
    else
        ___editor="$(__which_first_found 'vim' 'emacs' 'nano' 'ee' 'vi')"
    fi

    # Export existing editor
    if [ ! -z "${___editor}" ]; then
        export EDITOR="${___editor}"
    fi
}


__export_browser()
{
    local ___browser=''

    # User-defined
    if [ ! -z "${1}" ]; then
        ___browser="$(which ${1})"

    # Guess
    else
        ___browser="$(__which_first_found 'firefox' 'midori' 'lynx')"
    fi

    # Export existing browser
    if [ ! -z "${___browser}" ]; then
        export BROWSER="${___browser}"
    fi
}



# --- SSH agent --- #
agent()
{
    case "${1}" in
        'start')
            if [ -z "${SSH_AUTH_SOCK}" ] ; then
                eval $(ssh-agent -s)
                ssh-add
            fi
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
            echo "   agent {start|stop|term|restart|status|add <key>}" 1>&2
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


################################
# Actual exporting starts here #
################################
__export_ps
__export_pager
__export_editor
__export_browser

export MAKEOPTS='-j 2'
export NUMJOBS=${MAKEOPTS}

if [ -f "${HOME}/.bash_aliases" ]; then
    source "${HOME}/.bash_aliases"
fi

