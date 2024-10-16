# no shebang line here, for sourcing ONLY, works in both bash and zsh
# shebang is not working in sourced files!

: '
Color Definition Source file 

ShortDesc: This script defines color codes for both Bash and Zsh shells, supporting various text styles.

Description:
The script provides an associative array `colors` that contains different color codes and text styles.
It supports normal colors, bold, high intensity, and bold high intensity colors. The color definitions
differ between Bash and Zsh due to their unique syntax requirements. For Bash, ANSI escape codes are used,
while for Zsh, prompt formatting is utilized. The `reset` color is used to return the terminal text back
to its default appearance.

Usage Example:

	source <THIS COLOR DEFINITION SOURCE FILE> 

    # To use the defined colors in Bash
    if [ -n "$BASH_VERSION" ]; then
        echo -e "${colors["red"]}This is red text in Bash${colors["reset"]}"
    elif [ -n "$ZSH_VERSION" ]; then
        print -P "${colors[red]}This is red text in Zsh${colors[reset]}"
    fi

Parameters:
- None

Returns:
- Sets the `colors` associative array for use in terminal output.


'


if [ -n "$BASH_VERSION" ]; then
    : '
    Bash Color Definitions

    - Declare an associative array named colors.
    - Each color is defined using ANSI escape codes.
    '
	declare -A bash_colors

    # Define Bash colors
    bash_colors["black"]="\033[0;30m"
    bash_colors["red"]="\033[0;31m"
    bash_colors["green"]="\033[0;32m"
    bash_colors["yellow"]="\033[0;33m"
    bash_colors["blue"]="\033[0;34m"
    bash_colors["purple"]="\033[0;35m"
    bash_colors["cyan"]="\033[0;36m"
    bash_colors["white"]="\033[0;37m"
    # Bold
    bash_colors["bblack"]="\033[1;30m"
    bash_colors["bred"]="\033[1;31m"
    bash_colors["bgreen"]="\033[1;32m"
    bash_colors["byellow"]="\033[1;33m"
    bash_colors["bblue"]="\033[1;34m"
    bash_colors["bpurple"]="\033[1;35m"
    bash_colors["bcyan"]="\033[1;36m"
    bash_colors["bwhite"]="\033[1;37m"
    # High Intensity
    bash_colors["iblack"]="\033[0;90m"
    bash_colors["ired"]="\033[0;91m"
    bash_colors["igreen"]="\033[0;92m"
    bash_colors["iyellow"]="\033[0;93m"
    bash_colors["iblue"]="\033[0;94m"
    bash_colors["ipurple"]="\033[0;95m"
    bash_colors["icyan"]="\033[0;96m"
    bash_colors["iwhite"]="\033[0;97m"
    # Bold High Intensity
    bash_colors["biblack"]="\033[1;90m"
    bash_colors["bired"]="\033[1;91m"
    bash_colors["bigreen"]="\033[1;92m"
    bash_colors["biyellow"]="\033[1;93m"
    bash_colors["biblue"]="\033[1;94m"
    bash_colors["bipurple"]="\033[1;95m"
    bash_colors["bicyan"]="\033[1;96m"
    bash_colors["biwhite"]="\033[1;97m"
    # Reset
    bash_colors["reset"]="\033[0m"

elif [ -n "$ZSH_VERSION" ]; then
    : '
    Zsh Color Definitions

    - Use a typeset associative array to define colors.
    - Colors are defined using Zsh prompt formatting.
    '
    typeset -A zsh_colors

    # Define Zsh colors using prompt formatting
    zsh_colors=(
        [black]="%F{black}"
        [red]="%F{red}"
        [green]="%F{green}"
        [yellow]="%F{yellow}"
        [blue]="%F{blue}"
        [purple]="%F{magenta}"
        [cyan]="%F{cyan}"
        [white]="%F{white}"
        # Bold
        [bblack]="%F{black}%B"
        [bred]="%F{red}%B"
        [bgreen]="%F{green}%B"
        [byellow]="%F{yellow}%B"
        [bblue]="%F{blue}%B"
        [bpurple]="%F{magenta}%B"
        [bcyan]="%F{cyan}%B"
        [bwhite]="%F{white}%B"
        # High Intensity
        [iblack]="%F{black}"
        [ired]="%F{red}"
        [igreen]="%F{green}"
        [iyellow]="%F{yellow}"
        [iblue]="%F{blue}"
        [ipurple]="%F{magenta}"
        [icyan]="%F{cyan}"
        [iwhite]="%F{white}"
        # Bold High Intensity
        [biblack]="%F{black}%B"
        [bired]="%F{red}%B"
        [bigreen]="%F{green}%B"
        [biyellow]="%F{yellow}%B"
        [biblue]="%F{blue}%B"
        [bipurple]="%F{magenta}%B"
        [bicyan]="%F{cyan}%B"
        [biwhite]="%F{white}%B"
        # Reset
        [reset]="%f%b"
    )
fi


############################################################################
#
# now define all functions which need to access those colored functions
#
############################################################################


# private function, not to be exposed on the cli
_echo_colored() {
    local COLOR=${1}
    local COLORED_CONTENT=${2}
    local NONCOLORED_CONTENT=${3:-""} # non-colored content goes in here


	if [ -n "$BASH_VERSION" ]; then
		# bash coloring prompt, \e[0m is COLOROFF
		echo -e "${bash_colors[${COLOR}]}${COLORED_CONTENT}\e[0m ${NONCOLORED_CONTENT}"
	elif [ -n "$ZSH_VERSION" ]; then
		# zsh coloring prompt
		# %f is COLOROFF
		print -P "${zsh_colors[${COLOR}]}${COLORED_CONTENT}%f ${NONCOLORED_CONTENT}"
	fi
}

# private function, not to be exposed on the cli
_debug_colored() {
    local COLOR=${1}
    local LEVEL=${2}
    local NOW=$(date +"%Y-%m-%d %H:%M:%S.%3N")
    local CALLER_SCRIPT=""
    shift 2

    # [2016-01-28 18:06:40.946] [INFO] upd-init - ein fehler ist aufgetreten

    # ignore caller on interactive shell
    if [[ -z "$PS1"  && -n "$DEBUG" ]]; then
        CALLER_SCRIPT="$(basename "$(caller 1)") "
    fi

	_echo_colored ${COLOR} "[${NOW}] [${LEVEL}]" "${CALLER_SCRIPT}$@"
}

debug_info(){
    _debug_colored green INFO $@
}

debug_debug(){
    _debug_colored icyan DEBUG $@
}

debug_warn(){
    _debug_colored biyellow WARN $@
}

debug_error(){
    _debug_colored bired ERROR $@
}

debug_warn(){
    _debug_colored biyellow WARN $@
}

debug_abort(){
    _debug_colored bipurple ABORT $@
    exit 1
}


###############################################

print_info(){
	set -x
    _echo_colored green INFO $@
	set +x
}

print_debug(){
    _echo_colored icyan DEBUG $@
}

print_warn(){
    _echo_colored biyellow WARN $@
}

print_error(){
    _echo_colored bired ERROR $@
}

print_warn(){
    _echo_colored biyellow WARN $@
}

print_abort(){
    _echo_colored bipurple ABORT $@
    exit 1
}
