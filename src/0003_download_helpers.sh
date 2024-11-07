#!/bin/bash

download_from_private_github() {
    : '
        Download from Private GitHub Repository

        ShortDesc: Downloads a file from a private GitHub repository using a personal access token.

        Description:
        This function downloads a specified file from a private GitHub repository. It requires a GitHub personal
        access token, repository owner, repository name, and file path. The branch and output file name are optional.
        It can also skip SSL verification if specified and supports a dry-run mode to print the curl command instead of executing it.

        Parameters:
        --token <GITHUB_TOKEN>: The GitHub personal access token for authentication.
        --owner <REPO_OWNER>: The GitHub repository owner (user or organization).
        --repo <REPO_NAME>: The name of the repository.
        --file <FILE_PATH>: The file path in the repository to download.
        --branch <BRANCH> (optional): The branch to download from, default is "main".
        --output <OUTPUT_FILE> (optional): The name of the file to save the output to, default is the files basename.
        --insecure (optional): If provided, skip SSL verification for curl.
        --dry-run (optional): Print the generated curl command without executing it.

        Returns:
        - 0: Success
        - 1: Failure if invalid parameters are used or if the HTTP response is not 200.

        Example Usage:
        download_from_private_github --token "your_token" --owner "repo_owner" --repo "repo_name" --file "path/to/file" --branch "main" --output "output.txt" --insecure --dry-run
    '

    # Initialize parameters
    local GITHUB_TOKEN="" REPO_OWNER="" REPO_NAME="" FILE_PATH=""
    local BRANCH="main" OUTPUT_FILE="" INSECURE="" DRY_RUN="false"

    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --token) GITHUB_TOKEN="$2"; shift ;;
            --owner) REPO_OWNER="$2"; shift ;;
            --repo) REPO_NAME="$2"; shift ;;
            --file) FILE_PATH="$2"; shift ;;
            --branch) BRANCH="$2"; shift ;;
            --output) OUTPUT_FILE="$2"; shift ;;
            --insecure) INSECURE="-k" ;;
            --dry-run) DRY_RUN="true" ;;
            *) echo "Unknown parameter: $1"; return 1 ;;
        esac
        shift
    done

    # Validate required parameters
    if [[ -z "$GITHUB_TOKEN" || -z "$REPO_OWNER" || -z "$REPO_NAME" || -z "$FILE_PATH" ]]; then
        echo "Usage: download_from_private_github --token <GITHUB_TOKEN> --owner <REPO_OWNER> --repo <REPO_NAME> --file <FILE_PATH> [--branch <BRANCH>] [--output <OUTPUT_FILE>] [--insecure] [--dry-run]"
        return 1
    fi

    # Set default output file name if not specified
    OUTPUT_FILE="${OUTPUT_FILE:-$(basename "$FILE_PATH")}"

    # Construct curl command
    local curl_cmd
    curl_cmd="curl -H \"Authorization: token $GITHUB_TOKEN\" -H \"Accept: application/vnd.github.v3.raw\" -L \"https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$FILE_PATH?ref=$BRANCH\" $INSECURE -o \"$OUTPUT_FILE\""

    # Dry-run mode: print command
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Dry-run: Command to execute:"
        echo "$curl_cmd"
        return 0
    fi

    # Execute curl command
    eval "$curl_cmd"
    local response_code=$?

    # Check response code
    if [[ $response_code -ne 0 ]]; then
        echo "Failed to download the file. Curl returned error code $response_code."
        return 1
    elif [[ "$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3.raw" -L "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$FILE_PATH?ref=$BRANCH")" -ne 200 ]]; then
        echo "Failed to download the file. Received non-200 HTTP response code."
        return 1
    fi

    echo "File downloaded successfully to $OUTPUT_FILE."
    return 0
}


# Example usage (uncomment to test):
# download_from_private_github "your_personal_access_token" "owner" "repo" "path/to/file.txt" "main" "output.txt"


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

    # Create target directory if it does not exist
    mkdir -p "$TARGET_DIR"

    # Fetch the file list from GitHub API
    file_list=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
                     -H "Accept: application/vnd.github.v3+json" \
                     "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$DIRECTORY_PATH?ref=$BRANCH")

    # Download each file
    echo "$file_list" | jq -r '.[] | select(.type == "file") | .download_url' | while read -r file_url; do
        file_name=$(basename "$file_url")
        curl -H "Authorization: token $GITHUB_TOKEN" -L "$file_url" -o "$TARGET_DIR/$file_name"
    done

    echo "Directory downloaded successfully to $TARGET_DIR."
    return 0
}

