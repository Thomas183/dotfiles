import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Main status bar — one instance spawned per screen via Variants in shell.qml.
PanelWindow {
    property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    implicitHeight: 30
    color:          root.colBg

    // Thin vertical separator used between bar sections
    component BarSep: Rectangle {
        Layout.preferredWidth:  1
        Layout.preferredHeight: 16
        Layout.alignment:       Qt.AlignVCenter
        Layout.rightMargin:     8
        color:                  root.colMuted
    }

    // Clicking the bar background dismisses any open panel
    MouseArea {
        anchors.fill:            parent
        propagateComposedEvents: true
        onClicked: mouse => { root.closeAllPanels(); mouse.accepted = false }
    }

    RowLayout {
        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
        spacing: 0

        // ── Workspaces 1–9 ───────────────────────────────────────────────────
        Repeater {
            model: 9
            Rectangle {
                Layout.preferredWidth:  20
                Layout.preferredHeight: parent.height
                Layout.rightMargin:     4
                color: "transparent"

                property bool isActive:   Hyprland.focusedWorkspace?.id === (index + 1)
                property bool hasWindows: Hyprland.workspaces.values.some(ws => ws.id === index + 1)

                // Workspace number
                Text {
                    anchors.centerIn: parent
                    text:           index + 1
                    color:          parent.isActive   ? root.colCyan
                                  : parent.hasWindows ? root.colBlue
                                  :                     root.colMuted
                    font.pixelSize: root.fontSize
                    font.family:    root.fontFamily
                    font.bold:      true
                }
                // Active-workspace underline
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom:           parent.bottom
                    width: parent.width; height: 3
                    color: parent.isActive ? root.colPurple : "transparent"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked:    Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }

        // Flexible spacer — pushes everything else to the right
        Item { Layout.fillWidth: true }

        // ── NixOS version ─────────────────────────────────────────────────────
        BarSep {}
        Text {
            text:               "NixOS " + root.nixosVersion
            color:              root.colRed
            font.pixelSize:     root.fontSize
            font.family:        root.fontFamily
            font.bold:          true
            Layout.rightMargin: 8
        }

        // ── CPU usage ─────────────────────────────────────────────────────────
        BarSep {}
        Text {
            text:               "CPU: " + root.cpuUsage + "%"
            color:              root.colYellow
            font.pixelSize:     root.fontSize
            font.family:        root.fontFamily
            font.bold:          true
            Layout.rightMargin: 8
        }

        // ── RAM usage ─────────────────────────────────────────────────────────
        BarSep {}
        Text {
            text:               "Mem: " + root.memUsage + "%"
            color:              root.colCyan
            font.pixelSize:     root.fontSize
            font.family:        root.fontFamily
            font.bold:          true
            Layout.rightMargin: 8
        }

        // ── Disk usage ────────────────────────────────────────────────────────
        BarSep {}
        Text {
            text:               "Disk: " + root.diskUsage + "%"
            color:              root.colBlue
            font.pixelSize:     root.fontSize
            font.family:        root.fontFamily
            font.bold:          true
            Layout.rightMargin: 8
        }

        // ── Battery + power profile module ───────────────────────────────────
        BarSep {}
        BatteryModule {}

        // ── Status + Clock button ─────────────────────────────────────────────
        // Displays [network icon] | [HH:mm] | [NixOS logo]
        // Clicking anywhere on the button toggles the control panel.
        BarSep {}
        Rectangle {
            Layout.preferredHeight: 24
            Layout.preferredWidth:  statusButtonRow.implicitWidth + 20
            Layout.alignment:       Qt.AlignVCenter
            Layout.rightMargin:     4
            radius: 5
            color:  statusButtonArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08)
                                                  : Qt.rgba(1, 1, 1, 0.03)

            RowLayout {
                id: statusButtonRow
                anchors.centerIn: parent
                spacing: 7

                NetworkIcon {}

                // Clock — always HH:mm; full date is in the control panel
                Text {
                    id: clockText
                    Layout.alignment: Qt.AlignVCenter
                    color:          root.colFg
                    font.pixelSize: root.fontSize
                    font.family:    root.fontFamily
                    font.bold:      true
                    function refresh() { text = Qt.formatDateTime(new Date(), "HH:mm") }
                    Component.onCompleted: refresh()
                    Timer { interval: 1000; running: true; repeat: true; onTriggered: clockText.refresh() }
                }

                // NixOS logo — slightly dimmed at rest, full opacity on hover
                Image {
                    source:                "file:///home/thomas/.config/quickshell/nixos_logo.png"
                    Layout.preferredWidth:  14
                    Layout.preferredHeight: 14
                    Layout.alignment:       Qt.AlignVCenter
                    fillMode:              Image.PreserveAspectFit
                    opacity:               statusButtonArea.containsMouse ? 1.0 : 0.75
                }
            }

            MouseArea {
                id:           statusButtonArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked:    root.controlPanelOpen = !root.controlPanelOpen
            }
        }
    }
}
