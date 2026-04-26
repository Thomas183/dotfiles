import QtQuick
import QtQuick.Layouts

// Canvas network icon drawn without Nerd Font glyphs.
//   Wifi:     concentric arcs (1 arc always, +1 at >33 %, +1 at >66 %)
//   Ethernet: RJ45 port outline (rect + 3 pins + stem)
//   Offline:  circle with a diagonal slash
Canvas {
    id: networkIcon
    Layout.preferredWidth:  18
    Layout.preferredHeight: 14
    Layout.alignment:       Qt.AlignVCenter

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        var online = root.networkType.length > 0
        var col    = online ? root.colCyan.toString() : root.colMuted.toString()
        ctx.strokeStyle = col
        ctx.fillStyle   = col
        ctx.lineCap     = "round"

        if (root.networkType === "wifi") {
            // Arcs radiate upward from a point near the bottom of the canvas.
            // base is inset 2px from the bottom edge so the drawing is
            // vertically centred within the canvas bounds.
            // Canvas angles run clockwise from the positive x-axis,
            // so 1.25π–1.75π sweeps the upper hemisphere.
            var cx = width / 2, base = height - 2
            ctx.beginPath()
            ctx.arc(cx, base - 2, 1.5, 0, Math.PI * 2)
            ctx.fill()

            ctx.lineWidth = 1.5
            ctx.beginPath()
            ctx.arc(cx, base, 4.5, Math.PI * 1.25, Math.PI * 1.75)
            ctx.stroke()
            if (root.wifiSignal > 33) {
                ctx.beginPath()
                ctx.arc(cx, base, 7.5, Math.PI * 1.25, Math.PI * 1.75)
                ctx.stroke()
            }
            if (root.wifiSignal > 66) {
                ctx.beginPath()
                ctx.arc(cx, base, 10.5, Math.PI * 1.25, Math.PI * 1.75)
                ctx.stroke()
            }

        } else if (root.networkType === "ethernet") {
            // RJ45 port: rectangular body + 3 contact pins + cable stem
            ctx.lineWidth = 1.5
            ctx.strokeRect(3.75, 3.75, 10.5, 6)
            ctx.lineWidth = 1.0
            ;[5, 8, 11].forEach(function(px) {
                ctx.beginPath()
                ctx.moveTo(px, 3.75)
                ctx.lineTo(px, 1.75)
                ctx.stroke()
            })
            ctx.lineWidth = 1.5
            ctx.beginPath()
            ctx.moveTo(width / 2, 9.75)
            ctx.lineTo(width / 2, height - 1)
            ctx.stroke()

        } else {
            // Offline: circle with a diagonal slash
            var r = 5.5, cx = width / 2, cy = height / 2, d = r * 0.707
            ctx.lineWidth = 1.5
            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, Math.PI * 2)
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(cx - d, cy + d)
            ctx.lineTo(cx + d, cy - d)
            ctx.stroke()
        }
    }

    Connections {
        target: root
        function onNetworkTypeChanged() { networkIcon.requestPaint() }
        function onWifiSignalChanged()  { networkIcon.requestPaint() }
    }
    Component.onCompleted: requestPaint()
}
