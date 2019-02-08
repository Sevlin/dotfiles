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
            ___entry="$(command -v ${e} 2>/dev/null)"

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
        ___pager="$(__which_first_found 'less' 'most' 'more' 'cat')"
    fi

    # Export existing pager
    if [ ! -z "${___pager}" ]; then
        export PAGER="${___pager}"

        export LESS='-r'
        # Add colours for less
        export LESS_TERMCAP_mb=$'\E[01;31m'
        export LESS_TERMCAP_md=$'\E[01;31m'
        export LESS_TERMCAP_me=$'\E[0m'
        export LESS_TERMCAP_se=$'\E[0m'
        export LESS_TERMCAP_so=$'\E[01;44;33m'
        export LESS_TERMCAP_ue=$'\E[0m'
        export LESS_TERMCAP_us=$'\E[01;32m'
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
    local __agent_env=''
    case "${1}" in
        'start')
            if [ -z "${SSH_AUTH_SOCK}" ] ; then
                __agent_env="$(ssh-agent -s 2>/dev/null)"

                if [ ${?} -eq 0 ] \
                && [ ! -z "${__agent_env}" ]; then
                    eval "$(echo ${__agent_env} | tee ${HOME}/.ssh/.agent)"
                    ssh-add
                fi
            fi
        ;;
        'stop')
            kill -TERM ${SSH_AGENT_PID} &> /dev/null
            rm "${HOME}/.ssh/.agent"    2> /dev/null
            unset SSH_AUTH_SOCK SSH_AGENT_PID
        ;;
        'term')
            killall -s TERM ssh-agent
            rm "${HOME}/.ssh/.agent" 2> /dev/null
            unset SSH_AUTH_SOCK SSH_AGENT_PID
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
    echo -en "${__COLBLU}IPv4:${__COLRST} "
    curl -4 --no-keepalive \
            --silent \
            --connect-timeout "3" \
            --get "${1}" 2>/dev/null \
    || echo -e "${__COLRED}Unable to determine${__COLRST}" 1>&2
}

_myip_ip6()
{
    echo -en "${__COLBLU}IPv6:${__COLRST} "
    curl -6 --no-keepalive \
            --silent \
            --connect-timeout "3" \
            --get "${1}" 2>/dev/null \
    || echo -e "${__COLRED}Unable to determine${__COLRST}" 1>&2
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

# Handy function to extract files
#
# Copied from http://ricecows.org/configs/bash/.bashrc
ex()
{
    if [ -r "${1}" ]; then
        case "${1}" in
            *.tgz  | *.tar.gz)  tar xzvf "${1}" ;;
            *.tbz2 | *.tar.bz2) tar xjvf "${1}" ;;
            *.txz  | *.tar.xz)  tar xJvf "${1}" ;;
            *.gz)  gunzip "${1}"     ;;
            *.bz2) bunzip2 "${1}"    ;;
            *.xz)  unxz "${1}"       ;;
            *.Z)   uncompress "${1}" ;;
            *.7z)  7z x "${1}"       ;;
            *.zip) unzip "${1}"      ;;
            *.rar) unrar x "${1}"    ;;
            *.rpm)
                local __dir="${1%%.rpm}"
                mkdir "${__dir}"
                cd "${__dir}"
                rpm2cpio "../${1}" | cpio -vid
                cd -
                unset __dir
            ;;
            *.deb)
                local __dir="${1%%.deb}"
                mkdir "${__dir}"
                ar xv "${1}"
                tar -C "${__dir}" -xvf data.tar.?z*
                unset __dir
            ;;
            *) echo "${1} is not supported" 1>&2 ;;
        esac
    else
        echo "Missing archive" 1>&2
    fi
}

#################
# Shell options #
#################

# Re-check window size after each command
shopt -s checkwinsize

# Append to history file
shopt -s histappend

################################
# Actual exporting starts here #
################################

# Add local directories to PATH
export PATH="${HOME}/.local/bin:${HOME}/bin:${PATH}"

# Remove duplicates form .bash_history
export HISTCONTROL=ignoreboth:erasedups

__export_ps
__export_pager
__export_editor
__export_browser

if [[ -f "${HOME}/.bash_aliases" ]]; then
    source "${HOME}/.bash_aliases"
fi

if [[ -f "${HOME}/.environment" ]]; then
    source "${HOME}/.environment"
fi

# ssh-agent
if [ -r "${HOME}/.ssh/.agent" ]; then
    source "${HOME}/.ssh/.agent" > /dev/null
fi

