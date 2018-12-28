killsteam() {
	ps aux | grep steam_osx | awk '{print $2}' | xargs kill -9
	launchctl remove com.valvesoftware.steam.ipctool
}