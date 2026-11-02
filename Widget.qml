import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "tripex.keyboard-profile"

  readonly property string scriptPath: Qt.resolvedUrl("bin/keyboard-profile").toString().replace(/^file:\/\//, "")
  property string profile: ""
  readonly property bool isWindows: profile === "windows"

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function run(action) {
    if (root.bar) root.bar.run(Util.shellQuote(root.scriptPath) + " " + action)
  }

  Component.onCompleted: refresh()

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      // Every switch reloads the config, so this also catches the key binding.
      if (event && event.name === "configreloaded") root.refresh()
    }
  }

  Process {
    id: statusProc
    command: [root.scriptPath, "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.profile = text.trim()
    }
  }

  visible: profile !== ""
  implicitWidth: buttons.implicitWidth
  implicitHeight: buttons.implicitHeight

  Grid {
    id: buttons
    anchors.fill: parent
    columns: root.vertical ? 1 : 2

    WidgetButton {
      bar: root.bar
      text: root.isWindows ? "WIN" : "MAC"
      fontSize: Style.font.caption
      horizontalMargin: 6
      tooltipText: root.isWindows
        ? "Windows keyboard. Click to switch to Mac (SUPER + ALT + L)"
        : "Mac keyboard. Click to switch to Windows (SUPER + ALT + L)"
      onPressed: function(button) {
        if (button === Qt.LeftButton) root.run("toggle")
      }
    }

    WidgetButton {
      bar: root.bar
      text: "󰌌"
      horizontalMargin: 4
      tooltipText: "Key bindings for the Mac and Windows keyboard"
      onPressed: function(button) {
        if (button === Qt.LeftButton) root.run("menu")
      }
    }
  }
}
