import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// Slide-down control panel — anchored top-right, appears just below the bar.
//
// Layout note: controlPanelLayout is anchored top/left/right only — NOT
// anchors.fill — to avoid a circular implicit-height dependency with its
// own content. The window height is driven by the layout's implicitHeight.
//
// Warning note: KeyboardFocus.OnDemand may produce a "not defined" warning
// on some Quickshell builds where the enum isn't exported; the behaviour
// is still correct.
PanelWindow {
    visible:        root.controlPanelOpen
    implicitWidth:  280
    implicitHeight: controlPanelLayout.implicitHeight + 32
    color:          root.colBg
    anchors { top: true; right: true }
    margins.top:    32
    exclusionMode:  ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: KeyboardFocus.OnDemand

    onVisibleChanged: {
        if (visible) {
            // Refresh the date label and hardware readings each time we open
            panelDateText.text         = Qt.formatDateTime(new Date(), "dddd, MMMM d yyyy")
            brightnessReadProc.running = true
            wifiRadioStateProc.running = true
        } else {
            // Reset child views so next open always starts on the main view
            root.wifiListOpen        = false
            root.wifiPasswordVisible = false
            root.connectTargetSsid   = ""
        }
    }

    ColumnLayout {
        id: controlPanelLayout
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
        spacing: 12

        // ── Date ──────────────────────────────────────────────────────────────
        Text {
            id:               panelDateText
            Layout.alignment: Qt.AlignHCenter
            color:            root.colFg
            font.pixelSize:   root.fontSize - 1
            font.family:      root.fontFamily
        }
        Rectangle { Layout.fillWidth: true; height: 1; color: root.colMuted }

        // ── Main view: brightness, volume, wifi toggle, power ─────────────────
        Item {
            visible:          !root.wifiListOpen
            Layout.fillWidth: true
            implicitHeight:   mainView.implicitHeight

            ColumnLayout {
                id: mainView
                anchors { left: parent.left; right: parent.right; top: parent.top }
                spacing: 12

                // Brightness slider
                Text {
                    text:           "Brightness  " + root.brightnessLevel + "%"
                    color:          root.colYellow
                    font.pixelSize: root.fontSize
                    font.family:    root.fontFamily
                    font.bold:      true
                }
                Item {
                    id: brightnessSlider
                    Layout.fillWidth: true
                    height: 20
                    // Maps 1–100% to 0–1 so the thumb never overflows the track ends
                    property real ratio: Math.max(0, Math.min(1, (root.brightnessLevel - 1) / 99))

                    Timer {
                        id:          brightnessDebounce
                        interval:    100
                        onTriggered: root.setBrightness(root.brightnessLevel)
                    }
                    // Track
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width; height: 4; radius: 2; color: root.colMuted
                        Rectangle {
                            width:  brightnessSlider.ratio * parent.width
                            height: parent.height; radius: 2; color: root.colYellow
                        }
                    }
                    // Thumb
                    Rectangle {
                        width: 16; height: 16; radius: 8; color: root.colYellow
                        anchors.verticalCenter: parent.verticalCenter
                        x: brightnessSlider.ratio * (brightnessSlider.width - width)
                    }
                    MouseArea {
                        anchors.fill: parent
                        function scrub(mx) {
                            root.brightnessLevel = Math.round(1 + Math.max(0, Math.min(1, mx / brightnessSlider.width)) * 99)
                            brightnessDebounce.restart()
                        }
                        onPressed:         mouse => scrub(mouse.x)
                        onPositionChanged: mouse => { if (pressed) scrub(mouse.x) }
                    }
                }

                // Volume slider
                Text {
                    text:           "Volume  " + root.volumeLevel + "%"
                    color:          root.colPurple
                    font.pixelSize: root.fontSize
                    font.family:    root.fontFamily
                    font.bold:      true
                }
                Item {
                    id: volumeSlider
                    Layout.fillWidth: true
                    height: 20
                    property real ratio: Math.max(0, Math.min(1, root.volumeLevel / 100))

                    Timer {
                        id:          volumeDebounce
                        interval:    100
                        onTriggered: root.setVolume(root.volumeLevel)
                    }
                    // Track
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width; height: 4; radius: 2; color: root.colMuted
                        Rectangle {
                            width:  volumeSlider.ratio * parent.width
                            height: parent.height; radius: 2; color: root.colPurple
                        }
                    }
                    // Thumb
                    Rectangle {
                        width: 16; height: 16; radius: 8; color: root.colPurple
                        anchors.verticalCenter: parent.verticalCenter
                        x: volumeSlider.ratio * (volumeSlider.width - width)
                    }
                    MouseArea {
                        anchors.fill: parent
                        function scrub(mx) {
                            root.volumeLevel = Math.round(Math.max(0, Math.min(1, mx / volumeSlider.width)) * 100)
                            volumeDebounce.restart()
                        }
                        onPressed:         mouse => scrub(mouse.x)
                        onPositionChanged: mouse => { if (pressed) scrub(mouse.x) }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: root.colMuted }

                // WiFi row: toggle radio on/off + button to open network list
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true; height: 32; radius: 4
                        color: wifiToggleArea.containsMouse
                               ? (root.wifiEnabled ? Qt.rgba(0.05, 0.73, 0.84, 0.15) : Qt.rgba(1, 1, 1, 0.08))
                               : (root.wifiEnabled ? Qt.rgba(0.05, 0.73, 0.84, 0.08) : "transparent")
                        border.color: root.wifiEnabled ? root.colCyan : root.colMuted
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text:           root.wifiEnabled ? "Wi-Fi  ●  ON" : "Wi-Fi  ○  OFF"
                            color:          root.wifiEnabled ? root.colCyan : root.colMuted
                            font.pixelSize: root.fontSize
                            font.family:    root.fontFamily
                            font.bold:      true
                        }
                        MouseArea {
                            id:           wifiToggleArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked:    root.toggleWifi()
                        }
                    }

                    // Open network list (only shown when radio is on)
                    Rectangle {
                        visible:      root.wifiEnabled
                        width: 32; height: 32; radius: 4
                        color:        wifiExpandArea.containsMouse ? Qt.rgba(0.05, 0.73, 0.84, 0.15)
                                                                   : Qt.rgba(0.05, 0.73, 0.84, 0.08)
                        border.color: root.colCyan
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text:           "▶"
                            color:          root.colCyan
                            font.pixelSize: root.fontSize - 2
                            font.family:    root.fontFamily
                            font.bold:      true
                        }
                        MouseArea {
                            id:           wifiExpandArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.wifiListOpen    = true
                                wifiScanProc.running = true
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: root.colMuted }

                // Power actions
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true; height: 32; radius: 4
                        color:        shutdownArea.containsMouse ? Qt.rgba(0.97, 0.46, 0.56, 0.15) : "transparent"
                        border.color: root.colRed
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text:           "⏻  Shutdown"
                            color:          root.colRed
                            font.pixelSize: root.fontSize
                            font.family:    root.fontFamily
                            font.bold:      true
                        }
                        MouseArea {
                            id:           shutdownArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked:    shutdownProc.running = true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 32; radius: 4
                        color:        rebootArea.containsMouse ? Qt.rgba(0.88, 0.69, 0.41, 0.15) : "transparent"
                        border.color: root.colYellow
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text:           "↺  Restart"
                            color:          root.colYellow
                            font.pixelSize: root.fontSize
                            font.family:    root.fontFamily
                            font.bold:      true
                        }
                        MouseArea {
                            id:           rebootArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked:    rebootProc.running = true
                        }
                    }
                }

                Item { height: 4 }  // bottom padding inside the panel
            }
        }

        // ── WiFi network list ─────────────────────────────────────────────────
        Item {
            visible:          root.wifiListOpen
            Layout.fillWidth: true
            implicitHeight:   wifiView.implicitHeight

            ColumnLayout {
                id: wifiView
                anchors { left: parent.left; right: parent.right; top: parent.top }
                spacing: 8

                // Header: [←] Wi-Fi [↻]
                RowLayout {
                    Layout.fillWidth: true

                    Rectangle {
                        width: 28; height: 28; radius: 4
                        color:        backBtnArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                        border.color: root.colMuted
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text:           "←"
                            color:          root.colMuted
                            font.pixelSize: root.fontSize
                            font.family:    root.fontFamily
                            font.bold:      true
                        }
                        MouseArea {
                            id:           backBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.wifiListOpen = false
                                root.cancelWifiPassPrompt()
                            }
                        }
                    }

                    Text {
                        text:             "Wi-Fi"
                        color:            root.colCyan
                        font.pixelSize:   root.fontSize
                        font.family:      root.fontFamily
                        font.bold:        true
                        Layout.fillWidth: true
                        leftPadding:      8
                    }

                    Text {
                        text:           "↻"
                        color:          wifiRefreshArea.containsMouse ? root.colFg : root.colMuted
                        font.pixelSize: root.fontSize + 4
                        font.family:    root.fontFamily
                        MouseArea {
                            id:           wifiRefreshArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked:    wifiScanProc.running = true
                        }
                    }
                }

                // Currently connected network name
                Text {
                    visible:        root.activeConnection.length > 0
                    text:           "Connected: " + root.activeConnection
                    color:          root.colCyan
                    font.pixelSize: root.fontSize - 1
                    font.family:    root.fontFamily
                }

                // Password prompt — shown after the user taps a network
                Rectangle {
                    visible:          root.wifiPasswordVisible
                    Layout.fillWidth: true
                    height:           passPromptLayout.implicitHeight + 16
                    radius:           4
                    color:            Qt.rgba(0.05, 0.73, 0.84, 0.06)
                    border.color:     root.colCyan
                    border.width:     1

                    // Clear the password field every time this prompt opens
                    onVisibleChanged: if (visible) passwordInput.text = ""

                    ColumnLayout {
                        id: passPromptLayout
                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 8 }
                        spacing: 8

                        // Network name being connected to
                        Text {
                            text:             root.connectTargetSsid
                            color:            root.colCyan
                            font.pixelSize:   root.fontSize
                            font.family:      root.fontFamily
                            font.bold:        true
                            elide:            Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // Password input field
                        Rectangle {
                            Layout.fillWidth: true; height: 32; radius: 4
                            color:        Qt.rgba(1, 1, 1, 0.05)
                            border.color: passwordInput.activeFocus ? root.colCyan : root.colMuted
                            border.width: 1

                            TextInput {
                                id: passwordInput
                                anchors {
                                    left: parent.left; right: parent.right
                                    leftMargin: 8; rightMargin: 8
                                    verticalCenter: parent.verticalCenter
                                }
                                echoMode:       TextInput.Password
                                color:          root.colFg
                                font.pixelSize: root.fontSize
                                font.family:    root.fontFamily
                                Keys.onReturnPressed: root.connectToWifi(passwordInput.text)
                                Keys.onEscapePressed: root.cancelWifiPassPrompt()
                            }
                            // Placeholder shown while the field is empty and unfocused
                            Text {
                                visible:        passwordInput.text.length === 0 && !passwordInput.activeFocus
                                text:           "Password…"
                                color:          root.colMuted
                                font.pixelSize: root.fontSize
                                font.family:    root.fontFamily
                                anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                            }
                        }

                        // Connect / Cancel
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true; height: 28; radius: 4
                                color:        connectBtnArea.containsMouse ? Qt.rgba(0.05, 0.73, 0.84, 0.2)
                                                                           : Qt.rgba(0.05, 0.73, 0.84, 0.08)
                                border.color: root.colCyan
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text:           "Connect"
                                    color:          root.colCyan
                                    font.pixelSize: root.fontSize - 1
                                    font.family:    root.fontFamily
                                    font.bold:      true
                                }
                                MouseArea {
                                    id:           connectBtnArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked:    root.connectToWifi(passwordInput.text)
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true; height: 28; radius: 4
                                color:        cancelBtnArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                                border.color: root.colMuted
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text:           "Cancel"
                                    color:          root.colMuted
                                    font.pixelSize: root.fontSize - 1
                                    font.family:    root.fontFamily
                                    font.bold:      true
                                }
                                MouseArea {
                                    id:           cancelBtnArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked:    root.cancelWifiPassPrompt()
                                }
                            }
                        }
                    }
                }

                // Shown before the first scan result arrives
                Text {
                    visible:          root.wifiNetworks.length === 0
                    text:             "Scanning…"
                    color:            root.colMuted
                    font.pixelSize:   root.fontSize
                    font.family:      root.fontFamily
                    Layout.alignment: Qt.AlignHCenter
                }

                // Scrollable network list — active network first, then by signal
                ListView {
                    id:               networkList
                    visible:          root.wifiNetworks.length > 0
                    Layout.fillWidth: true
                    height:           Math.min(contentHeight, 220)
                    clip:             true
                    model:            root.wifiNetworks
                    spacing:          4

                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    delegate: Rectangle {
                        property var network: modelData
                        width:  networkList.width
                        height: 36; radius: 4
                        color:  networkItemArea.containsMouse
                                ? Qt.rgba(1, 1, 1, 0.05)
                                : (network.inUse ? Qt.rgba(0.05, 0.73, 0.84, 0.08) : "transparent")

                        RowLayout {
                            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                            spacing: 8

                            // ASCII signal-strength indicator
                            Text {
                                text:           network.signal > 75 ? "▂▄▆█"
                                              : network.signal > 50 ? "▂▄▆ "
                                              : network.signal > 25 ? "▂▄  "
                                              :                       "▂   "
                                color:          network.inUse ? root.colCyan : root.colMuted
                                font.pixelSize: 10
                                font.family:    root.fontFamily
                            }

                            // Network name
                            Text {
                                text:             network.ssid
                                color:            network.inUse ? root.colCyan : root.colFg
                                font.pixelSize:   root.fontSize
                                font.family:      root.fontFamily
                                font.bold:        network.inUse
                                Layout.fillWidth: true
                                elide:            Text.ElideRight
                            }

                            // Numeric signal strength
                            Text {
                                text:           network.signal + "%"
                                color:          root.colMuted
                                font.pixelSize: root.fontSize - 2
                                font.family:    root.fontFamily
                            }
                        }

                        MouseArea {
                            id:           networkItemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked:    root.openWifiPassPrompt(network.ssid, network.inUse)
                        }
                    }
                }

                Item { height: 4 }  // bottom padding inside the panel
            }
        }
    }
}
