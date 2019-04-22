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