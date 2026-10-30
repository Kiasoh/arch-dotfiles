import QtQuick
import Quickshell.Io

// Stats pill. Collapsed: one icon (like your waybar hover state).
// Click to expand: cpu, temp, ram, disk, igpu, dgpu, fans.
// Click again to collapse.
Rectangle {
    id: root

    property bool expanded: false
    property string temp: "--"
    property string disk: "--"
    property string igpu: "0"
    property string dgpu: "Off"

    // CPU/RAM from /proc (no native SystemUsage in quickshell 0.3.2)
    property real cpuPct: 0
    property real memGib: 0
    property real memTotalGib: 0
    property var _cpuPrev: null

    function readSysStats() {
        statView.reload()
        memView.reload()

        // first cpu line: "cpu user nice system idle iowait ..."
        const cpuLine = statView.text() || ""
        const p = cpuLine.split("\n")[0].replace(/^cpu\s*/, "").split(/\s+/).map(Number)
        if (p.length > 4) {
            const idle = p[3] + p[4]
            const total = p.reduce((a, b) => a + b, 0)
            if (_cpuPrev && total > _cpuPrev.total) {
                cpuPct = Math.max(0, Math.min(100,
                    (total - idle - (_cpuPrev.total - _cpuPrev.idle)) * 100 / (total - _cpuPrev.total)))
            }
            _cpuPrev = { idle: idle, total: total }
        }

        // meminfo values are in kB
        const memTxt = memView.text() || ""
        const memTotal = memTxt.match(/^MemTotal:\s+(\d+)/m)
        const memAvail = memTxt.match(/^MemAvailable:\s+(\d+)/m)
        if (memTotal && memAvail) {
            memTotalGib = memTotal[1] / 1048576
            memGib = (memTotal[1] - memAvail[1]) / 1048576
        }
    }

    FileView { id: statView; path: "/proc/stat" }
    FileView { id: memView; path: "/proc/meminfo" }

    implicitHeight: statText.implicitHeight + 4
    implicitWidth: statText.implicitWidth + 12

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 120
        }
    }

    color: Theme.surfaceContainer
    radius: height / 2

    Text {
        id: statText
        anchors.centerIn: parent
        color: Theme.onSurface
        font.pixelSize: 12
        font.weight: Font.Medium

        text: root.expanded ? ` ${Math.round(root.cpuPct)}% (${parseFloat(root.temp) || "--"}°) | ${root.memGib.toFixed(1)}/${Math.round(root.memTotalGib)}G | ${root.disk} | i:${root.igpu}% | d:${root.dgpu}` : "󰾆"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.expanded = !root.expanded;
            if (root.expanded) {
                if (!statProc.running)
                    statProc.running = true;
                if (!igpuProc.running)
                    igpuProc.running = true;
            }
        }
    }

    // temp + disk + dgpu, one bash run per interval
    Process {
        id: statProc

        command: ["bash", "-c", `
s=$(sensors)
t=$(echo "$s" | awk '/Package id 0/{print $4; exit}' | tr -d '+')
[ -z "$t" ] && t=$(echo "$s" | awk '/Tctl/{print $4; exit}' | tr -d '+')
d=$(df -h / | awk 'NR==2{print $5}')
g=Off
lsmod | grep -q '^nvidia' && g="$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)%"
[ "$g" = "%" ] && g=Off
echo "$t|$d|$g"
`]

        stdout: SplitParser {
            onRead: data => {
                const p = data.split("|");
                root.temp = p[0] || "--";
                root.disk = p[1] || "--";
                root.dgpu = p[2] || "Off";
            }
        }
    }

    // iGPU: intel_gpu_top needs root and ~1s to sample, so it gets its own slower loop
    Process {
        id: igpuProc

        command: ["bash", "-c", "timeout 1 sudo intel_gpu_top 2>/dev/null | awk '/^[ \t]*[0-9]+/{ val=$9 } END { print val }'"]

        stdout: SplitParser {
            onRead: data => {
                root.igpu = data.trim() || "0";
            }
        }
    }

    Timer {
        interval: 1000
        running: root.expanded
        repeat: true
        onTriggered: root.readSysStats()
    }

    Timer {
        interval: 2000
        running: root.expanded
        repeat: true
        onTriggered: if (!statProc.running)
            statProc.running = true
    }

    Timer {
        interval: 1200
        running: root.expanded
        repeat: true
        onTriggered: if (!igpuProc.running)
            igpuProc.running = true
    }
}
