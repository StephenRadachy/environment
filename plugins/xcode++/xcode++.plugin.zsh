alias xcode="xed"

xc_download() {
    if [ -n "$1" ] && [ -n "$2" ]; then
        aria2c --header "Host: adcdownload.apple.com" --header "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" --header "Upgrade-Insecure-Requests: 1" --header "Cookie: ADCDownloadAuth=$2" --header "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 10_1 like Mac OS X) AppleWebKit/602.2.14 (KHTML, like Gecko) Version/10.0 Mobile/14B72 Safari/602.1" --header "Accept-Language: en-us" -x 16 -s 16 "#1" -d ~/Downloads
    else
        echo "USAGE: xc_download <url> <ADCDownload cookie>"
    fi
}

xc_install() {
    if [ -n "$1" ]; then
        xip -x "$1"
        kill $(ps aux | grep 'Xcode' | awk '{print $2}')
        sudo rm -rf /Applications/Xcode.app
        xc_path=$(dirname "$1")
        sudo mv "$xc_path/(Xcode|Xcode-beta).app" /Applications
    else
        echo "USAGE: xc_install <path-to-xcode-xip>"
    fi
}

xc_list() {
    curl -s https://xcodereleases.com/data.json | jq --raw-output '.[].links.download.url' | grep -v null
}