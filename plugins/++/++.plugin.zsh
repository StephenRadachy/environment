export PATH="/usr/local/sbin:$PATH"
alias reload="source ~/.zshrc"

encrypt() {
  if [ -n "$1" ] && [ -n "$2" ]; then
    openssl enc -aes-256-cbc -pbkdf2 -in $1 -out $2
  else
    echo "USAGE: encrypt <input-file> <output-file>"
  fi
}

decrypt() {
  if [ -n "$1" ] && [ -n "$2" ]; then
    openssl enc -aes-256-cbc -pbkdf2 -d -in $1 -out $2
  else
    echo "USAGE: decrypt <input-file> <output-file>"
  fi
}

repo() {
    if [ -n "$1" ] && [ -n "$2" ]; then
        if [ -d "${HOME}/Code/github.com/$1/$2" ]; then
            pushd "${HOME}/Code/github.com/$1/$2"
        elif [ -d "${HOME}/Code/$1/$2" ]; then
            pushd "${HOME}/Code/$1/$2"
        else
            echo "ERROR: cannot find repo"
        fi
    else
        echo "USAGE: repo <org> <reponame>"
    fi
}

nv() {
    case "$1" in
    "edit-config") repo stephenradachy environment && code . && popd
        ;;
    *) echo "see repo for documentation"
    esac
}

fast_download() {
    if [ $# -eq 1 ] && [ $1 != "-H" ] && [ $1 != "--help" ] && [[ $1 =~ "curl" ]]; then
        if ! type "brew" > /dev/null; then
            echo 'Error: Homebrew is not installed.'
            echo 'Checkout https://brew.sh/ for installation'
        fi
        if ! type "aria2c" > /dev/null; then
            echo 'Please hold on while aria2 is being installed'
            brew install aria2
        fi

        command=$(echo $1 | sed 's/curl/aria2c -x16/g' | sed 's/--compressed/--http-accept-gzip true/g' | sed 's/-H/--header/g' | sed 's/(--insecure|)/--check-certificate false/g')
        eval $command
    else
        echo 'fast_download "<curl-command>"'
        echo 
        echo 'Converts curl commands to aria2 for maximum throughput 💪🔥'
        echo 'Aria2 docs: https://aria2.github.io/'
    fi
}