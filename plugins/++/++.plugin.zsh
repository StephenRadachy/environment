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