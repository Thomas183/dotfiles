import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

ShellRoot {
    id: root

    // ── Theme — Tokyo Night palette ───────────────────────────────────────────
    property color colBg:     "#1a1b26"
    property color colFg:     "#a9b1d6"
    property color colMuted:  "#444b6a"
    property color colCyan:   "#0db9d7"
    property color colPurple: "#ad8ee6"
    property color colRed:    "#f7768e"
    property color colYellow: "#e0af68"
    property color colBlue:   "#7aa2f7"

    // Note: the installed JetBrainsMono does not include Nerd Font glyph pages;
    // icons that need glyphs are drawn via Canvas instead.
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int    fontSize:   14

    // ── System stats — updated every second by pollingTimer ───────────────────
    property string nixosVersion:    ""
    property int    cpuUsage:        0
    property int    memUsage:        0
    property int    diskUsage:       0
    property int    volumeLevel:     0
    property int    brightnessLevel: 100

    property int    batteryLevel:    0
    property bool   batteryCharging: false
    property string powerProfile:    "balanced"

    // Previous-tick values used to compute the CPU usage delta
    property int cpuPrevIdle:  0
    property int cpuPrevTotal: 0

    // ── Panel visibility ──────────────────────────────────────────────────────
    property bool controlPanelOpen: false   // the slide-down control panel
    property bool wifiListOpen:     false   // wifi network list inside the panel

    // ── Network state ─────────────────────────────────────────────────────────
    property bool   wifiEnabled:      true
    property string activeConnection: ""      // human-readable name of the active connection
    property string networkType:      ""      // "wifi" | "ethernet" | "" (offline / unknown)
    property int    wifiSignal:       0       // signal strength of the active AP (0–100)
    property var    wifiNetworks:     []      // list returned by the last wifi scan

    // State for the connect-to-network flow:
    // user taps a network → prompt appears → they type a password → connectToWifi()
    property string connectTargetSsid:   ""
    property bool   wifiPasswordVisible: false

    // ─────────────────────────────────────────────────────────────────────────
    // Background processes
    // ─────────────────────────────────────────────────────────────────────────

    // NixOS codename — read once at startup (e.g. "ghost")
    Process {
        id: nixosVersionProc
        command: ["sh", "-c", "nixos-version | awk -F'[()]' '{print $2}'"]
        stdout: SplitParser {
            onRead: data => { if (data) nixosVersion = data.trim() }
        }
        Component.onCompleted: running = true
    }

    // CPU usage — reads /proc/stat and computes the busy fraction from idle deltas
    Process {
        id: cpuProc
        command: ["head", "-1", "/proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                const f       = data.trim().split(/\s+/)
                const user    = parseInt(f[1]) || 0
                const nice    = parseInt(f[2]) || 0
                const system  = parseInt(f[3]) || 0
                const idle    = parseInt(f[4]) || 0
                const iowait  = parseInt(f[5]) || 0
                const irq     = parseInt(f[6]) || 0
                const softirq = parseInt(f[7]) || 0

                const total   = user + nice + system + idle + iowait + irq + softirq
                const idleNow = idle + iowait

                if (cpuPrevTotal > 0) {
                    const dtotal = total   - cpuPrevTotal
                    const didle  = idleNow - cpuPrevIdle
                    if (dtotal > 0)
                        cpuUsage = Math.round(100 * (dtotal - didle) / dtotal)
                }
                cpuPrevIdle  = idleNow
                cpuPrevTotal = total
            }
        }
        Component.onCompleted: running = true
    }

    // RAM usage as a percentage of total
    Process {
        id: memProc
        command: ["sh", "-c", "free | awk '/Mem:/ {printf \"%d\", $3/$2*100}'"]
        stdout: SplitParser {
            onRead: data => { if (data) memUsage = parseInt(data) || 0 }
        }
        Component.onCompleted: running = true
    }

    // Root filesystem usage
    Process {
        id: diskProc
        command: ["sh", "-c", "df / | awk 'NR==2 {print $5}' | tr -d '%'"]
        stdout: SplitParser {
            onRead: data => { if (data) diskUsage = parseInt(data) || 0 }
        }
        Component.onCompleted: running = true
    }

    // System volume via PipeWire / WirePlumber
    Process {
        id: volumeReadProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                const match = data.match(/Volume:\s*([\d.]+)/)
                if (match) volumeLevel = Math.round(parseFloat(match[1]) * 100)
            }
        }
        Component.onCompleted: running = true
    }

    Process { id: volumeSetProc }   // reused each time the volume slider moves

    // Screen brightness via brightnessctl.
    // Not run at startup — the control panel triggers a fresh read when it opens.
    Process {
        id: brightnessReadProc
        command: ["sh", "-c", "echo $(brightnessctl get) $(brightnessctl max)"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                const parts = data.trim().split(/\s+/)
                const cur   = parseInt(parts[0]) || 0
                const max   = parseInt(parts[1]) || 1
                brightnessLevel = Math.round(cur * 100 / max)
            }
        }
    }

    Process { id: brightnessSetProc }   // reused each time the brightness slider moves

    // Active connection name and type.
    // Outputs one "NAME:TYPE" line from nmcli; we parse both fields.
    Process {
        id: networkProc
        command: ["sh", "-c", "nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep -v ':loopback' | head -1"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim().length > 0) {
                    const parts   = data.trim().split(":")
                    activeConnection = parts[0] || ""
                    const typeStr    = parts[parts.length - 1] || ""
                    networkType = typeStr.includes("wireless") ? "wifi"
                               : typeStr.includes("ethernet")  ? "ethernet"
                               : ""
                } else {
                    activeConnection = ""
                    networkType      = ""
                }
            }
        }
        Component.onCompleted: running = true
    }

    // Signal strength for the currently connected AP.
    // Reads the kernel's cached value — instant, no rescan triggered.
    Process {
        id: wifiSignalProc
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SIGNAL device wifi 2>/dev/null | awk -F: '$1==\"yes\"{print $2; exit}'"]
        stdout: SplitParser {
            onRead: data => { if (data) wifiSignal = parseInt(data.trim()) || 0 }
        }
    }

    // WiFi radio state (enabled / disabled)
    Process {
        id: wifiRadioStateProc
        command: ["nmcli", "radio", "wifi"]
        stdout: SplitParser {
            onRead: data => { if (data) wifiEnabled = data.trim() === "enabled" }
        }
        Component.onCompleted: running = true
    }

    // Full wifi scan then network list — can take several seconds
    Process {
        id: wifiScanProc
        command: ["sh", "-c", "nmcli device wifi rescan 2>/dev/null; nmcli -t -f IN-USE,SSID,SIGNAL device wifi list 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n").filter(l => l.trim().length > 0)
                const seen  = new Set()
                const nets  = []
                for (const line of lines) {
                    const parts  = line.split(":")
                    if (parts.length < 3) continue
                    const inUse  = parts[0].trim() === "*"
                    const signal = parseInt(parts[parts.length - 1]) || 0
                    const ssid   = parts.slice(1, parts.length - 1).join(":").trim()
                    if (!ssid || seen.has(ssid)) continue
                    seen.add(ssid)
                    nets.push({ ssid, signal, inUse })
                }
                // Active network first, then descending signal strength
                nets.sort((a, b) => (b.inUse - a.inUse) || (b.signal - a.signal))
                wifiNetworks = nets
            }
        }
    }

    Process { id: wifiRadioToggleProc }   // runs "nmcli radio wifi on/off"
    Process { id: wifiConnectProc }        // connects to an open or saved network
    Process { id: wifiConnectPassProc }    // connects with an explicit password

    Process { id: shutdownProc; command: ["systemctl", "poweroff"] }
    Process { id: rebootProc;   command: ["systemctl", "reboot"]   }

    // Battery level and AC adapter state — capacity from BAT*/capacity,
    // plugged-in state from AC*/online (1 = plugged, 0 = on battery).
    // Using the AC online file avoids the "Full" vs "Charging" ambiguity.
    Process {
        id: batteryProc
        command: ["sh", "-c",
            "cap=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1); " +
            "ac=$(cat /sys/class/power_supply/AC*/online /sys/class/power_supply/ACAD*/online /sys/class/power_supply/ADP*/online 2>/dev/null | head -1); " +
            "echo ${cap:--1} ${ac:-0}"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                const parts = data.trim().split(/\s+/)
                const lvl   = parseInt(parts[0])
                if (!isNaN(lvl) && lvl >= 0) batteryLevel = lvl
                batteryCharging = parts[1] === "1"
            }
        }
        Component.onCompleted: running = true
    }

    // Power profile — read once at startup; updated optimistically on each cycle
    Process {
        id: powerProfileReadProc
        command: ["powerprofilesctl", "get"]
        stdout: SplitParser {
            onRead: data => { if (data) powerProfile = data.trim() }
        }
        Component.onCompleted: running = true
    }

    Process { id: powerProfileSetProc }   // applies a new power profile

    // ─────────────────────────────────────────────────────────────────────────
    // Functions
    // ─────────────────────────────────────────────────────────────────────────

    function setBrightness(pct) {
        brightnessSetProc.command = ["brightnessctl", "set", Math.round(pct) + "%"]
        brightnessSetProc.running = true
    }

    function setVolume(pct) {
        volumeSetProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@",
                                 (Math.round(pct) / 100).toFixed(2)]
        volumeSetProc.running = true
    }

    function toggleWifi() {
        wifiRadioToggleProc.command = ["nmcli", "radio", "wifi", wifiEnabled ? "off" : "on"]
        wifiRadioToggleProc.running = true
        // nmcli needs ~800 ms to apply the change before we re-read state
        wifiStateRefreshTimer.restart()
    }

    // Show the password prompt for a given network.
    // No-op if that network is already the active connection.
    function openWifiPassPrompt(ssid, inUse) {
        if (inUse) return
        connectTargetSsid    = ssid
        wifiPasswordVisible  = true
    }

    function cancelWifiPassPrompt() {
        wifiPasswordVisible = false
        connectTargetSsid   = ""
    }

    // Connect to the pending SSID, with or without a password
    function connectToWifi(password) {
        if (password.length > 0) {
            wifiConnectPassProc.command = ["nmcli", "device", "wifi", "connect",
                                           connectTargetSsid, "password", password]
            wifiConnectPassProc.running = true
        } else {
            // Open network or credentials already stored by NetworkManager
            wifiConnectProc.command = ["nmcli", "device", "wifi", "connect", connectTargetSsid]
            wifiConnectProc.running = true
        }
        cancelWifiPassPrompt()
        // networkProc will pick up the new connection on the next polling tick
    }

    // Cycle power profile: power-saver → balanced → performance → power-saver …
    function cyclePowerProfile() {
        const profiles = ["power-saver", "balanced", "performance"]
        const next = profiles[(profiles.indexOf(powerProfile) + 1) % profiles.length]
        powerProfileSetProc.command = ["powerprofilesctl", "set", next]
        powerProfileSetProc.running = true
        powerProfile = next
    }

    // Close the control panel and reset all child views back to their defaults
    function closeAllPanels() {
        controlPanelOpen    = false
        wifiListOpen        = false
        wifiPasswordVisible = false
        connectTargetSsid   = ""
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Polling timer — drives all stat updates
    // WiFi signal is only polled while we are actually connected via wifi.
    // ─────────────────────────────────────────────────────────────────────────
    Timer {
        id:       pollingTimer
        interval: 1000
        running:  true
        repeat:   true
        onTriggered: {
            cpuProc.running        = true
            memProc.running        = true
            diskProc.running       = true
            volumeReadProc.running = true
            networkProc.running    = true
            batteryProc.running    = true
            if (networkType === "wifi") wifiSignalProc.running = true
        }
    }

    // When the connection type changes to wifi, read signal immediately
    // rather than waiting up to one second for the next polling tick.
    onNetworkTypeChanged: {
        if (networkType === "wifi") wifiSignalProc.running = true
        else wifiSignal = 0
    }

    // Re-read wifi radio state after a toggle; also scan for networks if turning on.
    // Delayed 800 ms because nmcli needs a moment to apply the change.
    Timer {
        id:       wifiStateRefreshTimer
        interval: 800
        onTriggered: {
            wifiRadioStateProc.running = true
            if (wifiEnabled) wifiScanProc.running = true
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Visual components — one per logical widget
    // ─────────────────────────────────────────────────────────────────────────

    ControlPanel {}

    Variants {
        model: Quickshell.screens
        Bar {}
    }
}
