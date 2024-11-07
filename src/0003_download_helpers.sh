#!/bin/bash

download_from_private_github ()
{
    : '
        Download from Private GitHub Repository

        ShortDesc: Downloads a file from a private GitHub repository.

        Description:
        This function downloads a specified file from a private GitHub repository.
        It uses a GitHub personal access token for authentication and supports optional
        branch and output file naming. An optional parameter can disable SSL verification.
        If the request is unsuccessful, the function returns an error.

        Parameters:
        - GITHUB_TOKEN: GitHub token with access permissions to the repository.
        - REPO_OWNER: Owner of the GitHub repository.
        - REPO_NAME: Name of the GitHub repository.
        - FILE_PATH: Path to the file within the repository.
        - BRANCH (optional): The branch to download from. Defaults to "main".
        - OUTPUT_FILE (optional): Name of the output file. Defaults to the basename of FILE_PATH.
        - --no-verify (optional): Disables SSL certificate verification for curl requests.

        Returns:
        - 0: Success
        - 1: Failure if download fails or if parameters are missing.

        Example Usage:
        download_from_private_github "<GITHUB_TOKEN>" "owner" "repo" "path/to/file" "branch" "output_file" --no-verify
    '

    # Parameters
    local GITHUB_TOKEN=$1;
    local REPO_OWNER=$2;
    local REPO_NAME=$3;
    local FILE_PATH=$4;
    local BRANCH=${5:-main};
    local OUTPUT_FILE=${6:-$(basename "$FILE_PATH")};
    local VERIFY_SSL=true;

    # Check for optional --no-verify parameter
    for param in "$@"; do
        if [[ "$param" == "--no-verify" ]]; then
            VERIFY_SSL=false;
            break;
        fi
    done

    # Validate required parameters
    if [[ -z "$GITHUB_TOKEN" || -z "$REPO_OWNER" || -z "$REPO_NAME" || -z "$FILE_PATH" ]]; then
        echo "Usage: download_from_private_github <GITHUB_TOKEN> <REPO_OWNER> <REPO_NAME> <FILE_PATH> [<BRANCH>] [<OUTPUT_FILE>] [--no-verify]";
        return 1;
    fi;

    # Set curl options based on SSL verification
    local CURL_OPTS="-H 'Authorization: token $GITHUB_TOKEN' -H 'Accept: application/vnd.github.v3.raw' -L"
    if [[ "$VERIFY_SSL" == false ]]; then
        CURL_OPTS="$CURL_OPTS -k"
    fi

    # Download file and check HTTP status
    local response
    response=$(curl $CURL_OPTS -w "%{http_code}" -o "$OUTPUT_FILE" "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$FILE_PATH?ref=$BRANCH")
    local http_status="${response: -3}"  # Extract the last 3 characters (HTTP code)

    if [[ "$http_status" -eq 200 ]]; then
        echo "File downloaded successfully to $OUTPUT_FILE.";
        return 0;
    else
        echo "Error: Failed to download the file. HTTP status $http_status.";
        rm -f "$OUTPUT_FILE"  # Remove partial download if unsuccessful
        return 1;
    fi
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

