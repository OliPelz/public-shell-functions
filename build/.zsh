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
bash_colors["black"]="\033[0;30m"
bash_colors["red"]="\033[0;31m"
bash_colors["green"]="\033[0;32m"
bash_colors["yellow"]="\033[0;33m"
bash_colors["blue"]="\033[0;34m"
bash_colors["purple"]="\033[0;35m"
bash_colors["cyan"]="\033[0;36m"
bash_colors["white"]="\033[0;37m"
bash_colors["bblack"]="\033[1;30m"
bash_colors["bred"]="\033[1;31m"
bash_colors["bgreen"]="\033[1;32m"
bash_colors["byellow"]="\033[1;33m"
bash_colors["bblue"]="\033[1;34m"
bash_colors["bpurple"]="\033[1;35m"
bash_colors["bcyan"]="\033[1;36m"
bash_colors["bwhite"]="\033[1;37m"
bash_colors["iblack"]="\033[0;90m"
bash_colors["ired"]="\033[0;91m"
bash_colors["igreen"]="\033[0;92m"
bash_colors["iyellow"]="\033[0;93m"
bash_colors["iblue"]="\033[0;94m"
bash_colors["ipurple"]="\033[0;95m"
bash_colors["icyan"]="\033[0;96m"
bash_colors["iwhite"]="\033[0;97m"
bash_colors["biblack"]="\033[1;90m"
bash_colors["bired"]="\033[1;91m"
bash_colors["bigreen"]="\033[1;92m"
bash_colors["biyellow"]="\033[1;93m"
bash_colors["biblue"]="\033[1;94m"
bash_colors["bipurple"]="\033[1;95m"
bash_colors["bicyan"]="\033[1;96m"
bash_colors["biwhite"]="\033[1;97m"
bash_colors["reset"]="\033[0m"
elif [ -n "$ZSH_VERSION" ]; then
: '
Zsh Color Definitions
- Use a typeset associative array to define colors.
- Colors are defined using Zsh prompt formatting.
'
typeset -A zsh_colors
zsh_colors=(
[black]="%F{black}"
[red]="%F{red}"
[green]="%F{green}"
[yellow]="%F{yellow}"
[blue]="%F{blue}"
[purple]="%F{magenta}"
[cyan]="%F{cyan}"
[white]="%F{white}"
[bblack]="%F{black}%B"
[bred]="%F{red}%B"
[bgreen]="%F{green}%B"
[byellow]="%F{yellow}%B"
[bblue]="%F{blue}%B"
[bpurple]="%F{magenta}%B"
[bcyan]="%F{cyan}%B"
[bwhite]="%F{white}%B"
[iblack]="%F{black}"
[ired]="%F{red}"
[igreen]="%F{green}"
[iyellow]="%F{yellow}"
[iblue]="%F{blue}"
[ipurple]="%F{magenta}"
[icyan]="%F{cyan}"
[iwhite]="%F{white}"
[biblack]="%F{black}%B"
[bired]="%F{red}%B"
[bigreen]="%F{green}%B"
[biyellow]="%F{yellow}%B"
[biblue]="%F{blue}%B"
[bipurple]="%F{magenta}%B"
[bicyan]="%F{cyan}%B"
[biwhite]="%F{white}%B"
[reset]="%f%b"
)
fi
_echo_colored() {
local COLOR=${1}
local COLORED_CONTENT=${2}
local NONCOLORED_CONTENT=${3:-""} # non-colored content goes in here
if [ -n "$BASH_VERSION" ]; then
echo -e "${bash_colors[${COLOR}]}${COLORED_CONTENT}\e[0m ${NONCOLORED_CONTENT}"
elif [ -n "$ZSH_VERSION" ]; then
print -P "${zsh_colors[${COLOR}]}${COLORED_CONTENT}%f ${NONCOLORED_CONTENT}"
fi
}
_debug_colored() {
local COLOR=${1}
local LEVEL=${2}
local NOW=$(date +"%Y-%m-%d %H:%M:%S.%3N")
local CALLER_SCRIPT=""
shift 2
if [[ -z "$PS1"  && -n "$DEBUG" ]]; then
CALLER_SCRIPT="$(basename "$(caller 1)") "
fi
_echo_colored ${COLOR} "[${NOW}] [${LEVEL}]" "${CALLER_SCRIPT}$@"
}
get_log_level_num() {
case "$1" in
DEBUG) echo 1 ;;
INFO) echo 2 ;;
WARN) echo 3 ;;
ERROR) echo 4 ;;
FATAL) echo 5 ;;
*) echo 0 ;;
esac
}
should_log() {
local message_level="$1"
local current_level="${BASH_LOGLEVEL:-INFO}"  # Default to INFO if BASH_LOGLEVEL is not set
local message_level_num
local current_level_num
message_level_num=$(get_log_level_num "$message_level")
current_level_num=$(get_log_level_num "$current_level")
if [ "$message_level_num" -ge "$current_level_num" ]; then
return 0
else
return 1
fi
}
: '
Bash Logger System
ShortDesc: A logging system for Bash scripts with configurable log levels using an environment variable.
Description:
This logging system provides functions for different log levels (DEBUG, INFO, WARN, ERROR, FATAL),
which can be controlled using the `BASH_LOGLEVEL` environment variable. If a log level is set,
the corresponding log messages will be printed.
Log Levels: (from less to more severe)
- DEBUG: Detailed information, typically for diagnosing problems.
- INFO: Informational messages that highlight the progress of the script.
- WARN: Potentially harmful situations.
- ERROR: Error events that might still allow the script to continue.
- FATAL: Severe errors that will likely cause the script to abort.
Precedence is:
FATAL: will only print FATAL log level messages
ERROR: will print FATAL and error messages
WARN: will print FATAL, ERROR and WARN
...
DEBUG will print all log levels
Environment Variable:
- BASH_LOGLEVEL: Controls which log levels are printed. Supported values: DEBUG, INFO, WARN, ERROR, FATAL.
Messages of levels equal to or more severe than the current level will be printed.
Example Usage:
BASH_LOGLEVEL="DEBUG"
print_debug "This is a debug message."
print_info "Informational message."
print_warn "Warning message."
print_error "Error message."
print_fatal "Fatal error message."
'
log_info(){
should_log INFO && _echo_colored green [INFO] "$@"
}
log_debug(){
should_log DEBUG && _echo_colored icyan [DEBUG] "$@"
}
log_warn(){
should_log WARN && _echo_colored biyellow [WARN] "$@"
}
log_error(){
should_log ERROR && _echo_colored bired [ERROR] "$@"
}
log_abort(){
should_log ABORT && _echo_colored bipurple [ABORT] "$@"
exit 1
}
log_ts_info(){
should_log INFO && _debug_colored green INFO "$@"
}
log_ts_debug(){
should_log DEBUG && _debug_colored icyan DEBUG "$@"
}
log_ts_warn(){
should_log WARN &&  _debug_colored biyellow WARN "$@"
}
log_ts_error(){
should_log ERROR && _debug_colored bired ERROR "$@"
}
log_ts_abort(){
should_log ABORT && _debug_colored bipurple ABORT "$@"
exit 1
}
is_root() {
: '
Is Root
ShortDesc: This function checks if the script is being run with root privileges.
Description:
This function evaluates the effective user ID (EUID) of the current user.
It returns 0 if the script is being executed by the root user (EUID 0) and
returns 1 if it is being executed by a non-root user. This is useful for
ensuring that certain operations requiring elevated privileges are only
executed when the script is run as root.
Parameters:
- None
Returns:
- 0: Success (the script is running as root)
- 1: Failure (the script is not running as root)
Example Usage:
if is_root; then
echo "Running as root."
else
echo "Not running as root. Please run with sudo."
fi
'
if [[ $EUID -ne 0 ]]; then
return 1
fi
return 0
}
contains() {
: '
Contains
ShortDesc: This function checks if a substring exists within a main string.
Description:
This function takes two strings as arguments: a main string and a substring.
It checks if the substring is present within the main string and returns 0
if found, or 1 if not found.
Parameters:
- main_string: The string in which to search for the substring.
- substring: The string to search for within the main string.
Returns:
- 0: Success (the substring is found within the main string)
- 1: Failure (the substring is not found)
Example Usage:
if contains "Hello, World!" "World"; then
echo "Substring found!"
else
echo "Substring not found."
fi
'
local main_string="$1"
local substring="$2"
if [[ "$main_string" == *"$substring"* ]]; then
return 0
else
return 1
fi
}
get_full_path_script_executed_in() {
: '
Get Full Path of Script Executed In
ShortDesc: This function retrieves the full directory path of the currently executing script.
Description:
This function checks the shell type (Bash or Zsh) and retrieves the full path of the script
being executed. It returns the directory of the script. If the shell is unsupported, it
prints an error message and returns 1.
Parameters:
- None
Returns:
- 0: Success (the full directory path is printed)
- 1: Failure (unsupported shell)
Example Usage:
echo "Script is located in: $(get_full_path_script_executed_in)"
'
local MYSHELL_NAME=$(get_current_shell_name)
if [ "$MYSHELL_NAME" = "bash" ]; then
script_path="${BASH_SOURCE[0]}"
elif [ "$MYSHELL_NAME" = "zsh" ]; then
script_path="${(%):-%x}"
else
echo "Unsupported shell"
return 1
fi
script_dir="$(cd "$(dirname "$script_path")" && pwd)"
echo "$script_dir"
}
get_parent_dir_name_of_script() {
: '
Get Parent Directory Name of the Script
ShortDesc: This function retrieves the name of the parent directory where the currently executing script is located.
Description:
This function uses the `get_full_path_script_executed_in` function to obtain the full directory path of
the currently executing script. It then extracts the parent directory name from the path.
If the parent directory name cannot be determined, an error message is displayed, and the function returns 1.
Parameters:
- None
Returns:
- 0: Success (the parent directory name is printed)
- 1: Failure (unable to determine parent directory)
Example Usage:
parent_dir_name=$(get_parent_dir_name_of_script)
echo "Parent directory name is: $parent_dir_name"
'
local full_path
full_path=$(get_full_path_script_executed_in)
if [[ $? -ne 0 || -z "$full_path" ]]; then
echo "Failed to determine the full path of the script."
return 1
fi
local parent_dir_name
parent_dir_name=$(basename "$full_path")
if [[ -z "$parent_dir_name" ]]; then
echo "Failed to determine the parent directory name."
return 1
fi
echo "$parent_dir_name"
return 0
}
test_env_variable_defined() {
: '
Test Environment Variable (Defined, Non-Empty, or Both)
ShortDesc: This function checks if a specified environment variable is defined, non-empty, or both.
Description:
This function takes the name of an environment variable as the first argument and an optional mode
("defined" or "non-empty") as the second argument. By default, it checks if the variable is defined
and not empty. If "defined" is provided, it checks if the variable is defined, regardless of its value.
If "non-empty" is provided, it checks if the variable is non-empty, regardless of whether its defined.
Parameters:
- ARG: The name of the environment variable to check.
- MODE (optional): The mode to check ("defined", "non-empty", or default).
Returns:
- 0: Success (the condition specified by the mode is met)
- 1: Failure (the condition specified by the mode is not met)
Example Usages:
1. Check if variable is defined and non-empty (default mode):
MY_VAR="Hello"
if test_env_variable_defined "MY_VAR"; then
echo "MY_VAR is defined and non-empty."
fi
2. Check if variable is defined (MODE="defined"):
unset MY_VAR
if test_env_variable_defined "MY_VAR" "defined"; then
echo "MY_VAR is defined."
else
echo "MY_VAR is not defined."
fi
3. Check if variable is non-empty (MODE="non-empty"):
MY_VAR=""
if test_env_variable_defined "MY_VAR" "non-empty"; then
echo "MY_VAR is non-empty."
else
echo "MY_VAR is empty or not defined."
fi
'
local ARG="$1"
local MODE="${2:-both}"
case "$MODE" in
"defined")
if [ "${!ARG+set}" = "set" ]; then
return 0
else
return 1
fi
;;
"non-empty")
if [ -n "${!ARG}" ]; then
return 0  # Variable is non-empty
else
return 1
fi
;;
"both" | *)
if [ "${!ARG+set}" = "set" ] && [ -n "${!ARG}" ]; then
return 0  # Variable is defined and non-empty
else
return 1
fi
;;
esac
}
is_var_true() {
: '
Is Variable True
ShortDesc: This function checks if a specified environment variable is set to "true".
Description:
This function takes the name of an environment variable as an argument and checks
if it is defined. If defined, it converts the variables value to lowercase and checks
if it is equal to "true". The function returns 0 if the variable is set and true, and
1 if the variable is not defined or is not true.
Parameters:
- var_name: The name of the environment variable to check.
Returns:
- 0: Success (the variable is defined and set to "true")
- 1: Failure (the variable is not defined or is not "true")
Example Usage:
if is_var_true "MY_VAR"; then
echo "MY_VAR is set to true."
else
echo "MY_VAR is not set to true."
fi
'
local var_name="$1"
local var_value
if test_env_variable_defined "${var_name}"; then
var_value="${!var_name,,}"
if [ "${var_value}" == "true" ]; then
return 0  # Success, the variable is set and true
fi
fi
return 1  # Failure, the variable is either not set or not true
}
create_temp() {
: '
Create Temporary File or Directory
ShortDesc: This function creates a temporary file or directory and optionally deletes it on exit.
Description:
This function creates a temporary file or directory based on the specified type.
It uses `mktemp` to create the temporary item and can automatically delete it
when the script exits. The user can specify a suffix for the temporary item and
whether it should be deleted upon exit.
Parameters:
- type: The type of temporary item to create ("file" or "dir").
- delete_on_exit: A boolean value indicating whether to delete the temporary item on exit
(optional; defaults to true).
- suffix: An optional suffix to append to the temporary item name (optional; defaults to an empty string).
Returns:
- 0: Success (the path of the created temporary item is printed)
- 1: Failure (if an invalid type is specified)
Example Usage:
temp_file=$(create_temp "file" true ".txt")
echo "Temporary file created at: $temp_file"
temp_dir=$(create_temp "dir" false)
echo "Temporary directory created at: $temp_dir"
'
local type="$1"
local delete_on_exit="${2:-true}"
local suffix="${3:-''}"
local temp_path=""
if [[ "$type" == "file" ]]; then
temp_path=$(mktemp --suffix $suffix)
elif [[ "$type" == "dir" ]]; then
temp_path=$(mktemp -d --suffix $suffix)
else
echo "Invalid type specified. Use 'file' or 'dir'."
return 1
fi
echo "$temp_path"
if [[ "$delete_on_exit" == true ]]; then
trap 'rm -rf "$temp_path"' EXIT
fi
}
detect_distribution() {
: '
Detect Distribution
ShortDesc: This function detects the Linux distribution based on the /etc/os-release file.
Description:
This function checks for the presence of the /etc/os-release file, which contains information
about the operating system. It sources this file to retrieve the distribution ID and uses
a case statement to determine the type of Linux distribution. It returns a string indicating
the distribution type or an error message if the distribution is unsupported or cannot be determined.
Parameters:
- None
Returns:
- "RHEL": If the distribution is Fedora, CentOS, or RHEL.
- "ARCH": If the distribution is Arch Linux.
- "DEBIAN": If the distribution is Ubuntu or Debian.
- "NONE": If the distribution is unsupported or if the /etc/os-release file cannot be found.
Example Usage:
distro=$(detect_distribution)
if [[ "$distro" != "NONE" ]]; then
echo "Detected distribution: $distro"
else
echo "Failed to detect distribution."
fi
'
if [ -f /etc/os-release ]; then
. /etc/os-release
case "${ID}" in
fedora|centos|rhel)
return "RHEL"
;;
arch)
return "ARCH"
;;
ubuntu|debian)
return "DEBIAN"
;;
*)
echo "Unsupported distribution: ${ID}"
return "NONE"
;;
esac
else
echo "Cannot determine distribution."
return "NONE"
fi
}
check_command_installed() {
: '
Check Command Installed
ShortDesc: Checks if a specified command is accessible and installed on the system.
Description:
This function verifies if a given command is available in the system’s PATH, indicating that it
is installed and accessible. It is useful for checking dependencies before running other scripts or commands.
Parameters:
- command_name: The name of the command to check (e.g., "curl", "git").
Returns:
- 0: Success (the command is accessible and installed)
- 1: Failure (the command is not found)
Example Usage:
check_command_installed "curl" && echo "Curl is installed." || echo "Curl is not installed."
'
local command_name="$1"
if command -v "$command_name" &> /dev/null; then
return 0
else
return 1
fi
}
check_string_starts_with() {
: '
Check If String Starts With Substring
ShortDesc: Determines if a given string starts with a specified substring.
Description:
This function checks if a provided string starts with a specific substring.
It also has an optional parameter to ignore leading whitespaces in the string
before performing the comparison.
Parameters:
- string: The string to check.
- substring: The substring to check if the string starts with.
- ignore_whitespace (optional): If set to "true", leading whitespaces in the string
will be ignored before the comparison.
Returns:
- 0: If the string starts with the substring.
- 1: If the string does not start with the substring.
Example Usage:
check_string_starts_with "Hello World" "Hello"
check_string_starts_with "   Hello World" "Hello" true
check_string_starts_with "Goodbye World" "Hello"
'
local string="$1"
local substring="$2"
local ignore_whitespace="${3:-false}"
if [ "$ignore_whitespace" = "true" ]; then
string="$(echo "$string" | sed 's/^[[:space:]]*//')"
fi
if [[ "$string" == "$substring"* ]]; then
return 0
else
return 1
fi
}
list_subdirectories() {
: '
List Subdirectories
ShortDesc: This function lists subdirectory names up to a specified depth.
Description:
Given a directory path, this function prints the names of its subdirectories up to the specified depth.
By default, it lists the subdirectories at the first level (max depth of 1). Optionally, a different
maximum depth can be provided.
Parameters:
- dir: The directory path where to search for subdirectories.
- max_depth: Optional. The maximum depth for searching subdirectories (default is 1).
Returns:
- 0: Success (subdirectories printed)
- 1: Failure (directory does not exist or invalid depth)
Example Usage:
list_subdirectories "/path/to/directory"
list_subdirectories "/path/to/directory" 2
'
local dir="$1"
local max_depth="${2:-1}"
if [ ! -d "$dir" ]; then
echo "Error: Directory does not exist: $dir"
return 1
fi
find "$dir" -mindepth 1 -maxdepth "$max_depth" -type d -exec basename {} \;
}
function download_from_private_github {
: '
Download from Private GitHub Repository
ShortDesc: Downloads a file from a private GitHub repository using a Personal Access Token (PAT).
Description:
This function allows you to download a specific file from a private GitHub repository. It uses a personal access token
for authentication and the GitHub API to retrieve the file from the specified repository and branch. If the file exists
locally, it will be overwritten. If no output filename is provided, the file will be saved with the same name as in
the repository.
Parameters:
- GITHUB_TOKEN: Personal Access Token (PAT) with access to the private repository.
- REPO_OWNER: GitHub repository owner (user or organization name).
- REPO_NAME: Name of the GitHub repository.
- FILE_PATH: The path to the file in the repository to download.
- BRANCH: The branch to download the file from (optional, defaults to "main").
- OUTPUT_FILE: Local file name to save the downloaded content (optional).
Returns:
- 0: Success (file downloaded successfully)
- 1: Failure (missing parameters or file download failed)
Example Usage:
download_from_private_github "your_personal_access_token" "owner" "repo" "path/to/file.txt"
download_from_private_github "your_personal_access_token" "owner" "repo" "path/to/file.txt" "main" "local_file.txt"
'
local GITHUB_TOKEN=$1
local REPO_OWNER=$2
local REPO_NAME=$3
local FILE_PATH=$4
local BRANCH=${5:-main}
local OUTPUT_FILE=${6:-$(basename "$FILE_PATH")}
if [[ -z "$GITHUB_TOKEN" || -z "$REPO_OWNER" || -z "$REPO_NAME" || -z "$FILE_PATH" ]]; then
echo "Usage: download_from_private_github <GITHUB_TOKEN> <REPO_OWNER> <REPO_NAME> <FILE_PATH> [<BRANCH>] [<OUTPUT_FILE>]"
return 1
fi
curl -H "Authorization: token $GITHUB_TOKEN" \
-H "Accept: application/vnd.github.v3.raw" \
-L "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$FILE_PATH?ref=$BRANCH" \
-o "$OUTPUT_FILE"
if [[ $? -eq 0 ]]; then
echo "File downloaded successfully to $OUTPUT_FILE."
return 0
else
echo "Failed to download the file."
return 1
fi
}
function download_directory_from_github {
: '
Download a directory from a private GitHub repository using the GitHub API
ShortDesc: Downloads all files in a specific directory from a private GitHub repository.
Parameters:
- GITHUB_TOKEN: Personal Access Token (PAT) with access to the private repository.
- REPO_OWNER: GitHub repository owner (user or organization name).
- REPO_NAME: Name of the GitHub repository.
- DIRECTORY_PATH: The path of the directory to download.
- BRANCH: The branch to download the directory from (optional, defaults to "main").
- TARGET_DIR: Local directory where the files will be downloaded.
Returns:
- 0: Success (directory downloaded successfully)
- 1: Failure (missing parameters or directory download failed)
Example Usage:
download_directory_from_github "your_personal_access_token" "owner" "repo" "path/to/directory" "main" "local_dir"
'
local GITHUB_TOKEN=$1
local REPO_OWNER=$2
local REPO_NAME=$3
local DIRECTORY_PATH=$4
local BRANCH=${5:-main}
local TARGET_DIR=${6:-$(basename "$DIRECTORY_PATH")}
if [[ -z "$GITHUB_TOKEN" || -z "$REPO_OWNER" || -z "$REPO_NAME" || -z "$DIRECTORY_PATH" ]]; then
echo "Usage: download_directory_from_github <GITHUB_TOKEN> <REPO_OWNER> <REPO_NAME> <DIRECTORY_PATH> [<BRANCH>] [<TARGET_DIR>]"
return 1
fi
mkdir -p "$TARGET_DIR"
file_list=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
-H "Accept: application/vnd.github.v3+json" \
"https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$DIRECTORY_PATH?ref=$BRANCH")
echo "$file_list" | jq -r '.[] | select(.type == "file") | .download_url' | while read -r file_url; do
file_name=$(basename "$file_url")
curl -H "Authorization: token $GITHUB_TOKEN" -L "$file_url" -o "$TARGET_DIR/$file_name"
done
echo "Directory downloaded successfully to $TARGET_DIR."
return 0
}
import common
get_url() {
: '
Get URL
ShortDesc: This function downloads a file from a specified URL.
Description:
This function retrieves a file from the internet using the provided URL.
It checks if the target file already exists and prompts the user for
overwriting it if it has changed.
Parameters:
- url: The URL from which to download the file.
- output_file: The file path where the downloaded content will be saved
(optional; defaults to the name derived from the URL).
Returns:
- 0: Success
- 1: Failure (if the URL is invalid or download fails)
Example Usage:
get_url "https://example.com/file.txt" "localfile.txt"
'
local url=""
local dest=""
local overwrite=false
local usage="Usage: get_url -u <url> -d <destination_file> [-o] [-h]
-h                : Show this help message
-u <url>          : URL to fetch the file from
-d <destination_file>: Local file to save the downloaded content
-o                : Prompt for overwrite if the file has changed"
while [[ "$#" -gt 0 ]]; do
case "$1" in
-h|--help)
echo $usage
return 0
;;
-u|--url)
url="$2"
shift 2
;;
-d|--destination)
dest="$2"
shift 2
;;
-o|--overwrite)
overwrite=1
shift
;;
*)
echo "Unknown option: $1"
return 1
;;
esac
done
if [[ -z "$url" || -z "$dest" ]]; then
echo "Both URL and destination file are required."
echo "$usage"
return 1
fi
echo "Fetching $url..."
temp_file=$(mktemp)
if curl -fsSL "$url" -o "$temp_file"; then
if [[ -f "$dest" ]]; then
if ! cmp -s "$temp_file" "$dest"; then
echo "File has changed."
echo "Current destination file: $dest"
echo "New file: $temp_file"
if $overwrite; then
read -p "Do you want to overwrite $dest? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
mv "$temp_file" "$dest"
echo "File updated: $dest"
else
echo "Keeping the original file: $dest"
rm "$temp_file"
fi
else
echo "Keeping the original file: $dest"
rm "$temp_file"
fi
else
echo "File has not changed. No update needed."
rm "$temp_file"
fi
else
echo "Downloading to $dest..."
mv "$temp_file" "$dest"
echo "File downloaded: $dest"
fi
else
echo "Failed to fetch $url"
rm "$temp_file"
return 1
fi
return 0
}
lineinfile() {
: '
Line In File
ShortDesc: This function ensures a specific line is present in a file.
Description:
This function checks for a specified line in a given file. If the line does not exist,
it adds it to the file. If the line already exists, it can be updated based on parameters.
The function also allows for specifying whether to create the file if it does not exist.
Additionally, you can choose to add the line at the beginning or end of the file.
Parameters:
- -f <file>: The path to the file to be modified.
- -l <line>: The line of text to ensure is present in the file.
- -a: Add the line if it doesn’t already exist.
- -r: Remove the line if it exists.
- -p <position>: Add position - either "beginning" or "end" (optional; defaults to "end").
- -i: Ignore if the line already exists.
- -o <output_file>: Copy output to a specified file instead of modifying the original.
Returns:
- 0: Success
- 1: Failure (if file operations fail or the file cannot be created)
Example Usage:
lineinfile -f "example.txt" -l "This is a new line." -a -p beginning
'
local file line action ignore_existing output_file position="end"
while [[ "$#" -gt 0 ]]; do
case "$1" in
-f) file="$2"; shift ;;
-l) line="$2"; shift ;;
-a) action="add" ;;
-r) action="remove" ;;
-p) position="$2"; shift ;;
-i) ignore_existing=true ;;
-o) output_file="$2"; shift ;;
*) echo "Unknown option: $1"; return 1 ;;
esac
shift
done
if [[ -z "$file" || -z "$line" ]]; then
echo "Usage: lineinfile -f <file> -l <line> [-a | -r] [-p <beginning|end>] [-i] [-o <output_file>]"
return 1
fi
add_line() {
if [[ "$ignore_existing" == true ]] && grep -qF -- "$line" "$file"; then
echo "Line already exists and ignoring: $line"
else
if [[ "$position" == "beginning" ]]; then
sed -i "1i $line" "$file"
else
echo "$line" >> "$file"
fi
echo "Line added at $position: $line"
fi
}
remove_line() {
if grep -qF -- "$line" "$file"; then
sed -i "/^$(echo "$line" | sed 's/[\/&]/\\&/g')$/d" "$file"
echo "Line removed: $line"
else
echo "Line not found: $line"
fi
}
if [[ -n "$output_file" ]]; then
cp "$file" "$output_file"
file="$output_file"
fi
if [[ "$action" == "add" ]]; then
add_line
elif [[ "$action" == "remove" ]]; then
remove_line
else
echo "No action specified. Use -a to add or -r to remove."
return 1
fi
}
function pcurl_wrapper {
: '
Curl Proxy Wrapper
ShortDesc: A wrapper for the curl command that supports optional proxy and SSL certificate usage.
Description:
This function provides a convenient way to execute curl commands with optional proxy settings
and SSL certificate handling. It takes a URL as the first parameter and any additional curl
parameters as subsequent arguments. If proxy usage is enabled via the USE_PROXY environment variable,
it configures curl to use the specified proxy. If a base64-encoded SSL certificate is provided,
it decodes it to a temporary file for use with curl.
Parameters:
- url: The URL to be requested with curl.
- additional_params: Additional parameters to pass to the curl command (optional).
Environment Variables:
- USE_PROXY: Set to "true" to enable proxy usage.
- HTTPS_PROXY: The proxy URL to use if USE_PROXY is true.
- CERT_BASE64_STRING: Base64-encoded SSL certificate string for verifying proxy connections (optional).
Returns:
- 0: Success (curl command executed successfully)
- 1: Failure (if the curl command fails)
Example Usage:
pcurl_wrapper "https://example.com" --verbose --header "User-Agent: CustomAgent"
'
local url="$1"
shift
local additional_params="$@"
local curl_cmd="curl"
local proxy_cmd=""
local cert_cmd=""
if [ "${USE_PROXY,,}" == "true" ]; then
if test_env_variable_defined CERT_BASE64_STRING; then
TEMP_CERT_FILE=$(create_temp_file)
echo "${CERT_BASE64_STRING}" | base64 -d > "${TEMP_CERT_FILE}"
cert_cmd="--cacert ${TEMP_CERT_FILE}"
fi
proxy_cmd="--proxy ${HTTPS_PROXY}"
fi
${curl_cmd} ${proxy_cmd} ${cert_cmd} ${additional_params} "${url}"
if [ -n "${TEMP_CERT_FILE}" ]; then
rm "${TEMP_CERT_FILE}"
fi
}
function ppip_wrapper {
: '
Pip Proxy Wrapper
ShortDesc: A wrapper for the pip command that supports optional proxy and SSL certificate usage.
Description:
This function provides a way to execute pip commands with optional proxy settings, SSL certificate handling,
and custom Python package index configurations. It takes the pip command as the first parameter followed
by any additional parameters needed for pip. If proxy usage is enabled via the USE_PROXY environment variable,
it configures pip to use the specified proxy. If a base64-encoded SSL certificate is provided, it decodes
it to a temporary file for use with pip. The function also allows specifying a custom index URL, repository URL,
and trusted host.
Parameters:
- command: The pip command to be executed (e.g., install, uninstall).
- additional_params: Additional parameters to pass to the pip command (optional).
Environment Variables:
- USE_PROXY: Set to "true" to enable proxy usage.
- HTTPS_PROXY: The proxy URL to use if USE_PROXY is true.
- CERT_BASE64_STRING: Base64-encoded SSL certificate string for verifying proxy connections (optional).
- PYTHON_INDEX_URL: Custom Python package index URL (optional).
- PYTHON_REPO_URL: Custom repository URL (optional).
- PYTHON_TRUSTED_HOST: Trusted host for pip operations (optional).
Returns:
- 0: Success (pip command executed successfully)
- 1: Failure (if the pip command fails)
Example Usage:
ppip_wrapper "install" "requests" --upgrade
'
local command="$1"
shift
local additional_params="$@"
local pip_cmd="pip"
local proxy_cmd=""
local cert_cmd=""
local index_url_cmd=""
local repo_url_cmd=""
local trusted_host_cmd=""
if [ "${USE_PROXY,,}" == "true" ]; then
if test_env_variable_defined CERT_BASE64_STRING; then
TEMP_CERT_FILE=$(create_temp_file)
echo "${CERT_BASE64_STRING}" | base64 -d > "${TEMP_CERT_FILE}"
cert_cmd="--cert ${TEMP_CERT_FILE}"
fi
proxy_cmd="--proxy ${HTTPS_PROXY}"
fi
if test_env_variable_defined PYTHON_INDEX_URL; then
index_url_cmd="--index ${PYTHON_INDEX_URL}"
fi
if test_env_variable_defined PYTHON_REPO_URL; then
repo_url_cmd="--index-url ${PYTHON_REPO_URL}"
fi
if test_env_variable_defined PYTHON_TRUSTED_HOST; then
trusted_host_cmd="--trusted-host ${PYTHON_TRUSTED_HOST}"
fi
${pip_cmd} ${proxy_cmd} ${cert_cmd} ${index_url_cmd} ${repo_url_command} ${trusted_host_cmd} ${command} ${additional_params}
if [ -n "${TEMP_CERT_FILE}" ]; then
rm "${TEMP_CERT_FILE}"
fi
}
function pwget_wrapper {
: '
Wget Proxy Wrapper
ShortDesc: A wrapper for the wget command that supports optional proxy and SSL certificate usage.
Description:
This function provides a convenient way to execute wget commands with optional proxy settings
and SSL certificate handling. It takes a URL as the first parameter and any additional wget
parameters as subsequent arguments. If proxy usage is enabled via the USE_PROXY environment variable,
it configures wget to use the specified proxy. If a base64-encoded SSL certificate is provided,
it decodes it to a temporary file for use with wget.
Parameters:
- url: The URL to be retrieved with wget.
- additional_params: Additional parameters to pass to the wget command (optional).
Environment Variables:
- USE_PROXY: Set to "true" to enable proxy usage.
- HTTPS_PROXY: The proxy URL to use if USE_PROXY is true.
- CERT_BASE64_STRING: Base64-encoded SSL certificate string for verifying proxy connections (optional).
Returns:
- 0: Success (wget command executed successfully)
- 1: Failure (if the wget command fails)
Example Usage:
pwget_wrapper "https://example.com/file.zip" --output-document=myfile.zip
'
local url="$1"
shift
local additional_params="$@"
local wget_cmd="wget"
local proxy_cmd=""
local cert_cmd=""
if [ "${USE_PROXY,,}" == "true" ]; then
if test_env_variable_defined CERT_BASE64_STRING; then
TEMP_CERT_FILE=$(create_temp_file)
echo "${CERT_BASE64_STRING}" | base64 -d > "${TEMP_CERT_FILE}"
cert_cmd="--ca-certificate=${TEMP_CERT_FILE}"
fi
proxy_cmd="--proxy=${HTTPS_PROXY}"
fi
${wget_cmd} ${proxy_cmd} ${cert_cmd} ${additional_params} "${url}"
if [ -n "${TEMP_CERT_FILE}" ]; then
rm "${TEMP_CERT_FILE}"
fi
}
vault() {
: '
Vault
ShortDesc: This function encrypts and decrypts files and directories using a password.
Description:
This function allows for the encryption and decryption of files and directories.
It uses a password prompt by default, with an optional password file.
Additionally, an output file can be specified for the decrypted content.
Parameters:
- encrypt: If set, the file or directory will be encrypted.
- decrypt: If set, the file or directory will be decrypted.
- file: The path to the file or directory to be encrypted or decrypted.
- password_file: The path to a file containing the password (optional).
- output_file: The path to save the output file (optional).
Returns:
- 0: Success
- 1: Failure (if file operations or encryption/decryption fails)
Example Usage:
vault -e -f ./file.txt -o ./encrypted_file.enc
vault -d -f ./encrypted_file.enc -o ./decrypted_file.txt
vault -e -f ./my_directory -o ./encrypted_directory.enc
vault -d -f ./encrypted_directory.enc -o ./decrypted_directory
'
local action=""
local file=""
local password_file=""
local output_file=""
local usage="Usage: vault {-e|-d} -f <file|directory> [-p <password_file>] [-o <output_file>] [-h]
-e                : Encrypt the file or directory
-d                : Decrypt the file or directory
-f <file|directory>: Specify the file or directory to encrypt/decrypt
-p <password_file>: Optional file containing the password
-o <output_file>  : Optional output file for the result
-h                : Show this help message"
while getopts ":edf:p:o:h" opt; do
case $opt in
e) action="encrypt" ;;
d) action="decrypt" ;;
f) file="$OPTARG" ;;
p) password_file="$OPTARG" ;;
o) output_file="$OPTARG" ;;
h) echo "$usage"; return 0 ;;
\?) echo "Invalid option: -$OPTARG" >&2; echo "$usage"; return 1 ;;
:) echo "Option -$OPTARG requires an argument." >&2; echo "$usage"; return 1 ;;
esac
done
if [[ -z "$action" ]]; then
echo "You must specify either -e (encrypt) or -d (decrypt)."
echo "$usage"
return 1
fi
if [[ -z "$file" ]]; then
echo "File or directory is required."
echo "$usage"
return 1
fi
local password=""
if [[ -n "$password_file" ]]; then
password=$(<"$password_file")
else
read -sp "Enter password: " password
echo
fi
encrypt() {
local output_file_final="${output_file:-${file}.enc}"
if [[ -d "$file" ]]; then
tar -czf "${file}.tar.gz" -C "$(dirname "$file")" "$(basename "$file")"
openssl enc -aes-256-cbc -salt -pbkdf2 -in "${file}.tar.gz" -out "$output_file_final" -pass pass:"$password"
rm "${file}.tar.gz"
else
openssl enc -aes-256-cbc -salt -pbkdf2 -in "$file" -out "$output_file_final" -pass pass:"$password"
fi
if [[ $? -eq 0 ]]; then
echo "File/Directory encrypted successfully: $output_file_final"
else
echo "Encryption failed!"
fi
}
decrypt() {
local output_file_final="${output_file:-${file%.enc}}"
if [[ "$file" == *.enc && -d "$file" ]]; then
openssl enc -d -aes-256-cbc -pbkdf2 -in "$file" -out "${output_file_final}.tar.gz" -pass pass:"$password"
tar -xzf "${output_file_final}.tar.gz" -C "$(dirname "$output_file_final")"
rm "${output_file_final}.tar.gz"
else
openssl enc -d -aes-256-cbc -pbkdf2 -in "$file" -out "$output_file_final" -pass pass:"$password"
fi
if [[ $? -eq 0 ]]; then
echo "File/Directory decrypted successfully: $output_file_final"
else
echo "Decryption failed!"
fi
}
if [[ "$action" == "encrypt" ]]; then
encrypt
elif [[ "$action" == "decrypt" ]]; then
decrypt
else
echo "Invalid action. Use '-e' for encrypt or '-d' for decrypt."
return 1
fi
}
