import Quickshell
import QtQuick
import QtQuick.Layouts

// Battery bar module — drawn battery icon + percentage.
// Color reflects the active power profile; clicking cycles through profiles.
Rectangle {
    id:                     battModule
    Layout.preferredHeight: 24
    Layout.preferredWidth:  battRow.implicitWidth + 20
    Layout.alignment:       Qt.AlignVCenter
    Layout.rightMargin:     4
    radius: 5
    color:  battArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.03)

    // Power-saver = green  /  balanced = blue  /  performance = red
    property color profileColor: root.powerProfile === "power-saver" ? "#9ece6a"
                                : root.powerProfile === "performance" ? root.colRed
                                :                                       root.colBlue

    RowLayout {
        id:              battRow
        anchors.centerIn: parent
        spacing:          6

        // ── Drawn battery icon ─────────────────────────────────────────────
        Item {
            Layout.alignment:       Qt.AlignVCenter
            Layout.preferredWidth:  26
            Layout.preferredHeight: 12

            // Body outline
            Rectangle {
                id:     battBody
                anchors { left: parent.left; right: battNub.left; top: parent.top; bottom: parent.bottom }
                radius: 2
                color:  "transparent"
                border.color: battModule.profileColor
                border.width: 1.5

                // Charge fill — animates smoothly when level changes
                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 2 }
                    width:   Math.max(2, (parent.width - 4) * (root.batteryLevel / 100))
                    radius:  1
                    color:   battModule.profileColor
                    opacity: 0.75

                    Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                }

                // Charging bolt — shown centered when plugged in
                Text {
                    visible:          root.batteryCharging
                    anchors.centerIn: parent
                    text:             "⚡"
                    font.pixelSize:   8
                    color:            root.colFg
                }
            }

            // Positive terminal nub (right side of battery)
            Rectangle {
                id:     battNub
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                width: 3; height: 7; radius: 1
                color:  battModule.profileColor
            }
        }

        // ── Percentage label — ⚡ prefix when plugged in ───────────────────
        Text {
            Layout.alignment: Qt.AlignVCenter
            text:           (root.batteryCharging ? "⚡" : "") + root.batteryLevel + "%"
            color:          battModule.profileColor
            font.pixelSize: root.fontSize
            font.family:    root.fontFamily
            font.bold:      true
        }
    }

    MouseArea {
        id:           battArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked:    root.cyclePowerProfile()
    }
}
