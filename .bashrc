#PROXY_HOST='http://proxy.mi6:3128'
#export http_proxy=$PROXY_HOST
#export HTTP_PROXY=$PROXY_HOST
#export https_proxy=$PROXY_HOST
#export HTTPS_PROXY=$PROXY_HOST
#export ftp_proxy=$PROXY_HOST
#export FTP_PROXY=$PROXY_HOST

ROOT_PS1='\[\033[01;31m\]\h\[\033[01;34m\] \w \$\[\033[00m\] '
USER_PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
ROOT_PS2='\[\033[01;32m\]|\[\033[00m\] '
#USER_PS2='\[\033[01;31m\]>\[\033[01;33m\]>\[\033[01;32m\]>\[\033[00m\] '
USER_PS2='\[\033[01;32m\]|\[\033[00m\] '

### >>> ###
#
#ROOT_PS1='\[\033[01;31m\]\h\[\033[01;34m\] \w \[\033[01;31m\]>>>\[\033[00m\] '
#USER_PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \[\033[01;31m\]>\[\033[01;33m\]>\[\033[01;32m\]>\[\033[00m\] '

### RHEL ###
#
#ROOT_PS1='\[\033[01;34m[\]\[\033[01;31m\h\]\[\033[01;34m \w]\]\[\033[1;31m\$\033[0m\] '
#USER_PS1='\[\033[01;34m[\]\[\033[01;32m\u@\h\]\[\033[01;34m \w]\]\[\033[1;32m\$\033[0m\] '

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
export MAKEOPTS='-j 2'
export NUMJOBS=${MAKEOPTS}
                
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# --- SSH agent --- #
agent()
{
    case "${1}" in
        'start')
            if [ -z "${SSH_AUTH_SOCK}" ] ; then
                eval `ssh-agent -s`
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

