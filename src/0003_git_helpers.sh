git_clone_or_pull() {
    : '
        Git Clone or Pull

        ShortDesc: This function clones a Git repository if it does not exist, or pulls the latest changes if it does.

        Description:
        The function checks whether a specified Git repository directory already exists. If the directory exists,
        it pulls the latest changes from the remote repository. If it does not exist, the function clones the repository.
        Optionally, it can append the directory name to the `.gitignore` file if specified.

        Parameters:
        - repo_url: The URL of the Git repository to clone or pull.
        - target_dir (optional): The target directory where the repository should be cloned. If not provided, the repository 
                                 will be cloned into a directory named after the repository.
        - add_to_gitignore (optional): A flag ("true" or "false") to determine whether to add the directory name to `.gitignore`.
                                       Defaults to "false".

        Returns:
        - 0: Success
        - 1: Failure if the Git commands fail or if invalid parameters are used.

        Example Usage:
        git_clone_or_pull "https://github.com/user/repo.git" "my_repo" "true"
    '

    # Parameters
    local repo_url="$1"
    local target_dir="$2"
    local add_to_gitignore="${3:-false}"

    # Extract the repository name from the URL
    local org_repo_name
    org_repo_name=$(basename "$repo_url" .git)
    local repo_dir="${target_dir:-$org_repo_name}"

    # Check if the repository directory exists
    if [ -d "$repo_dir" ]; then
        echo "Repository '$org_repo_name' already exists. Pulling latest changes..."
        (cd "$repo_dir" && git pull > /dev/null) || return 1
    else
        echo "Cloning repository '$org_repo_name' into '$repo_dir'..."
        git clone "$repo_url" "$repo_dir" || return 1
    fi

    # Optionally add the directory name to .gitignore
    if [ "$add_to_gitignore" == "true" ]; then
        [ -f .gitignore ] && grep -q "^${repo_dir}$" .gitignore || echo "$repo_dir" >> .gitignore
    fi

    return 0
}

