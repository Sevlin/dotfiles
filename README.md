# Dotfiles
This repo contains configuration files for `bash`, `git` and `vim` that are being used by me on daily basis.  

## Files
|       Name      | Description                                                                                                                                                                              |
|:---------------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| *.bashrc*       | Some Slackware-based distros use `.bashrc` as config source, but ignore `.bash_profile` (unlike original Slackware). This file is mostly workaround and will only `source .bash_profile`.|
| *.bash_profile* | Profile configuration file for BASH. Includes various useful functions and, of course, Gentoo-ish colouring for PS1. :)                                                                  |
| *.bash_aliases* | Yup, just BASH aliases.                                                                                                                                                                  |
| *.gitconfig*    | Main configuration file for Git.                                                                                                                                                         |
| *.gitignore*    | Global gitigrore.                                                                                                                                                                        |
| *.vimrc*        | Configuration file for VIM.                                                                                                                                                              |

## bash_profile functions
### User
|       Name      |                     Flags                         | Description                                                                                |
|:---------------:|:-------------------------------------------------:|:-------------------------------------------------------------------------------------------|
| agent           | **start**, **stop**, **term**, **status**, **add**| Wrapper function to manage local `ssh-agent`                                               |
| myip            | `<empty>`, **v4**, **v6**, **help**               | Get current public IP(v4 and/or v6) address. Function will `curl https://myip.nix.org.ua`. |
| ex              | `<archive file path>`                             | Wrapper function for various archivers.<br>Example:`ex archive.txz` or `ex package.rpm`    |
| weather (alias) | `<empty>`                                         | Alias for `curl`'ing wttr.in service.                                                      |

### Internal
| Name                  | Arguments                                   | Description                                                                                                                   |
|:---------------------:|:-------------------------------------------:|:------------------------------------------------------------------------------------------------------------------------------|
| __which_first_found() | List of executables to choose within `PATH` | This function is used by "guessing" mechainsm. Will return full path to first matched binary name provided in argument list. At the moment used only in `__export_*()` functions. |
| __export_ps()         | None                                        | `export PS1` and `export PS2` |
| __export_pager()      | Empty or pager name                         | `export PAGER`<br>If user hadn't explicitly specify pager name, then function will try to "guess" first available pager available using `__which_first_found()`.<br>Default list: **less**, **most**, **more**, **cat** |
| __export_editor()     | Empty or editor name                        | `export EDITOR`<br> If user hadn't explicitly specify editor name, then function will try to "guess" first available editor available using `__which_first_found()`.<br>Default list: **vim**, **emacs**, **nano**, **ee**, **vi** |
| __export_browser()    | Empty or browser name                       | `export BROWSER`<br>If user hadn't explicitly specify browser name, then function will try to "guess" first available editor available using `__which_first_found()`.<br>Default list: **firefox**, **midori**, **lynx** |

## Installation
```bash
# Install bash configs
make bash

# Install git configs
make git

# Install vim config
make vim

# Install bash, git and vim configs
make install

# Create nix-profile.sh that can be used in Slackware's /etc/profile.d
# (concatenated bash_profile and bash_aliases)
make profile
```
