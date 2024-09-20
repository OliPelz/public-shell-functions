#!/usr/bin/env bash

# small function collection

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
        return 0    # Success
    else
        return 1    # Failure
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
		script_directory=$(get_full_path_script_executed_in)
		echo "Script is located in: $script_directory"
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

test_env_variable_defined() {
        : '
			Test Environment Variable Defined

			ShortDesc: This function checks if a specified environment variable is defined and non-empty.

			Description:
			This function takes the name of an environment variable as an argument and checks
			if it is defined and not an empty string. It returns 0 if the variable is set,
			and 1 if it is not defined or is an empty string.

			Parameters:
			- ARG: The name of the environment variable to check.

			Returns:
			- 0: Success (the variable is defined and non-empty)
			- 1: Failure (the variable is not defined or is an empty string)

			Example Usage:
			if test_env_variable_defined "MY_VAR"; then
				echo "MY_VAR is defined and non-empty."
			else
				echo "MY_VAR is not defined or is empty."
			fi
		'
        ARG=$1
        CMD='test -z ${'$ARG'+x}'
        if eval $CMD;
        then
                return 1 # variable is not defined or empty string
        else
                return 0  # variable is set
        fi
}

function is_var_true() {
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
    local var_name="$1"  # Store the variable name
    local var_value

    # Call test_env_variable_defined with the variable name as a string
    if test_env_variable_defined "${var_name}"; then
        # Access the value of the variable using indirect expansion
        var_value="${!var_name,,}"  # Convert the value to lowercase

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
