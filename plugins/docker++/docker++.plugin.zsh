unalias d

d() {
    case "$1" in
    "run") docker run -it --rm -v "${PWD}:/current-dir" "$2" "$3"
        ;;
    *) echo "see repo for documentation"
    esac
}