import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui

// Bitwarden (rbw) vault picker.
//
// The list and every action come from `omarchy-rbw`, which runs as its own
// short-lived process: this overlay only ever holds entry names, usernames and
// folders. No password, TOTP or note ever enters the shell process.
Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  property bool opened: false
  property string filterText: ""
  property int selectedIndex: 0
  property bool cursorActive: false
  property var rows: []
  property bool loading: false

  // Shares the [menu] surface tokens, so any theme that styles the Omarchy
  // menu styles this the same way.
  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding
  property int headerHeight: Math.max(Style.space(34), Style.font.title + Style.spacing.controlPaddingY * 2)
  property int footerHeight: Math.max(Style.space(22), Style.font.caption + Style.spacing.controlPaddingY)
  property int contentSpacing: Style.spacing.md
  property int rowHeight: Math.max(Style.space(58), Style.font.body + Style.font.caption + Style.spacing.rowPaddingX * 2)
  property int cardWidth: Math.min(Style.space(720), panel.width - Style.gapsOut * 2)

  readonly property int rowSpacing: Style.space(2)
  readonly property int rowPitch: rowHeight + rowSpacing
  // What the card spends on chrome: borders, padding, header, footer, and the
  // two gaps around the list.
  readonly property int chromeHeight: card.contentTopInset + card.contentBottomInset
    + headerHeight + footerHeight + contentSpacing * 2
  readonly property int maxCardHeight: Math.min(Style.space(700), panel.height - Style.gapsOut * 2)
  readonly property int maxListHeight: Math.max(rowPitch, maxCardHeight - chromeHeight)
  // Whole rows, and no more of them than there are results: the card shrinks to
  // its content rather than leaving dead space under the hints, and never slices
  // a row in half against the footer.
  readonly property int fittedListHeight: Math.floor((maxListHeight + rowSpacing) / rowPitch) * rowPitch - rowSpacing
  readonly property int listHeight: displayModel.count === 0
    ? Math.min(maxListHeight, rowPitch * 3)
    : Math.max(rowHeight, Math.min(displayModel.count * rowPitch - rowSpacing, fittedListHeight))
  property int cardHeight: chromeHeight + listHeight

  readonly property string hints: "Enter autotype   Alt+2 user   Alt+3 pass   Alt+4 totp   Alt+c/u/t copy   Alt+m fields   Alt+s sync"

  function open(payloadJson) {
    root.opened = true
    root.filterText = ""
    root.selectedIndex = 0
    root.cursorActive = true
    root.reload()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "andre.rbw")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  // Cheap enough to re-run on every summon (~0.25s for 550 entries), which
  // keeps the list honest after a sync or an edit in another client.
  function reload() {
    if (listProc.running) return
    root.loading = true
    listProc.collected = ""
    listProc.running = true
  }

  function loadRows(raw) {
    var parsed = []
    try {
      parsed = JSON.parse(raw || "[]")
    } catch (e) {
      parsed = []
    }
    root.rows = Array.isArray(parsed) ? parsed : []
    root.loading = false
    root.rebuildDisplay()
  }

  // A name match beats a match that only landed in the subtext, so typing
  // "gmail" surfaces the entry called Gmail before the 160 rows that merely
  // use a gmail address.
  function rebuildDisplay() {
    var query = root.filterText.trim().toLowerCase()
    var primary = []
    var secondary = []

    for (var i = 0; i < root.rows.length; i++) {
      var row = root.rows[i]
      if (!row || !row.name) continue
      if (!query) {
        primary.push(row)
        continue
      }
      if (String(row.name).toLowerCase().indexOf(query) >= 0) primary.push(row)
      else if (String(row.sub || "").toLowerCase().indexOf(query) >= 0) secondary.push(row)
    }

    var out = primary.concat(secondary)
    displayModel.clear()
    for (var j = 0; j < out.length; j++) {
      displayModel.append({
        name: String(out[j].name || ""),
        user: String(out[j].user || ""),
        folder: String(out[j].folder || ""),
        sub: String(out[j].sub || ""),
        glyph: String(out[j].glyph || "")
      })
    }

    if (displayModel.count === 0) root.selectedIndex = 0
    else if (root.selectedIndex >= displayModel.count) root.selectedIndex = displayModel.count - 1
    else if (root.selectedIndex < 0) root.selectedIndex = 0
    root.cursorActive = displayModel.count > 0

    Qt.callLater(function() {
      if (displayModel.count > 0) resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
    })
  }

  function select(delta) {
    if (displayModel.count === 0) return
    if (!root.cursorActive) {
      root.cursorActive = true
      root.selectedIndex = delta < 0 ? displayModel.count - 1 : 0
    } else {
      root.selectedIndex = (root.selectedIndex + delta + displayModel.count) % displayModel.count
    }
    resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
  }

  function selectPage(delta) {
    if (displayModel.count === 0) return
    var visibleRows = Math.max(1, Math.floor(resultList.height / root.rowHeight))
    var next = root.selectedIndex + delta * visibleRows
    if (next < 0) next = 0
    if (next >= displayModel.count) next = displayModel.count - 1
    root.cursorActive = true
    root.selectedIndex = next
    resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
  }

  function selectEdge(toEnd) {
    if (displayModel.count === 0) return
    root.cursorActive = true
    root.selectedIndex = toEnd ? displayModel.count - 1 : 0
    resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
  }

  function setFilter(nextFilter) {
    root.filterText = nextFilter
    root.selectedIndex = 0
    root.cursorActive = true
    root.rebuildDisplay()
  }

  // Actions are argv, never a shell string: an entry named `; rm -rf ~` is
  // just an awkward name.
  function act(action) {
    if (!root.cursorActive || root.selectedIndex < 0 || root.selectedIndex >= displayModel.count) return
    var row = displayModel.get(root.selectedIndex)
    if (!row) return
    root.dismiss()
    Quickshell.execDetached(["omarchy-rbw", "act", action, row.name, row.user, row.folder])
  }

  function syncVault() {
    root.dismiss()
    Quickshell.execDetached(["omarchy-rbw", "sync"])
  }

  ListModel { id: displayModel }

  Process {
    id: listProc
    command: ["omarchy-rbw", "list"]
    property string collected: ""
    stdout: SplitParser {
      onRead: function(data) { listProc.collected += data }
    }
    onExited: function(exitCode, exitStatus) {
      root.loadRows(listProc.collected)
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "andre-rbw"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          var alt = (event.modifiers & Qt.AltModifier) !== 0

          if (event.key === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else root.dismiss()
            event.accepted = true
            return
          }

          // The old rofi-rbw bindings, kept intact.
          if (alt) {
            switch (event.key) {
              case Qt.Key_1: root.act("autotype"); event.accepted = true; return
              case Qt.Key_2: root.act("type-username"); event.accepted = true; return
              case Qt.Key_3: root.act("type-password"); event.accepted = true; return
              case Qt.Key_4: root.act("type-totp"); event.accepted = true; return
              case Qt.Key_C: root.act("copy-password"); event.accepted = true; return
              case Qt.Key_U: root.act("copy-username"); event.accepted = true; return
              case Qt.Key_T: root.act("copy-totp"); event.accepted = true; return
              case Qt.Key_M: root.act("fields"); event.accepted = true; return
              case Qt.Key_S: root.syncVault(); event.accepted = true; return
              case Qt.Key_R: root.reload(); event.accepted = true; return
            }
          }

          if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
            event.accepted = true
          } else if (event.key === Qt.Key_Up) {
            root.select(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            root.select(1)
            event.accepted = true
          } else if (event.key === Qt.Key_PageUp) {
            root.selectPage(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_PageDown) {
            root.selectPage(1)
            event.accepted = true
          } else if (event.key === Qt.Key_Home) {
            root.selectEdge(false)
            event.accepted = true
          } else if (event.key === Qt.Key_End) {
            root.selectEdge(true)
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.act("autotype")
            event.accepted = true
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.setFilter(root.filterText + event.text)
            event.accepted = true
          }
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: root.contentSpacing

        Rectangle {
          width: parent.width
          height: root.headerHeight
          color: "transparent"

          Text {
            anchors.left: parent.left
            anchors.right: countText.left
            anchors.rightMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            text: root.filterText || (root.loading ? "Loading vault…" : "Search passwords…")
            color: root.foreground
            opacity: root.filterText ? 1 : 0.58
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            elide: Text.ElideRight
          }

          Text {
            id: countText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: displayModel.count > 0 ? String(displayModel.count) : ""
            color: root.foreground
            opacity: 0.4
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
          }
        }

        Item {
          width: parent.width
          height: root.listHeight

          ListView {
            id: resultList
            anchors.fill: parent
            model: displayModel
            clip: true
            spacing: root.rowSpacing
            boundsBehavior: Flickable.StopAtBounds
            cacheBuffer: root.rowHeight * 8

            delegate: Rectangle {
              required property int index
              required property string name
              required property string sub
              required property string glyph

              readonly property bool hasCursor: root.cursorActive && index === root.selectedIndex

              width: resultList.width
              height: root.rowHeight
              radius: root.cornerRadius
              color: hasCursor ? root.selectedBackground : "transparent"

              Text {
                id: glyphText
                text: parent.glyph
                color: parent.hasCursor ? root.selectedText : root.foreground
                opacity: parent.hasCursor ? 1 : 0.75
                font.family: root.fontFamily
                font.pixelSize: Style.font.iconLarge
                width: Style.space(36)
                horizontalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.leftMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
              }

              Column {
                anchors.left: glyphText.right
                anchors.leftMargin: Style.space(6)
                anchors.right: parent.right
                anchors.rightMargin: Style.space(10)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(3)

                Text {
                  width: parent.width
                  text: name
                  color: hasCursor ? root.selectedText : root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.heading
                  font.weight: Font.Medium
                  elide: Text.ElideRight
                }

                Text {
                  width: parent.width
                  text: sub
                  visible: sub.length > 0
                  color: root.foreground
                  opacity: 0.52
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  elide: Text.ElideRight
                }
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: if (containsMouse) {
                  root.cursorActive = true
                  root.selectedIndex = index
                }
                onClicked: {
                  root.cursorActive = true
                  root.selectedIndex = index
                  root.act("autotype")
                }
              }
            }
          }

          Column {
            anchors.centerIn: parent
            spacing: Style.space(8)
            visible: displayModel.count === 0 && !root.loading

            Text {
              text: ""
              color: root.selectedText
              opacity: 0.8
              font.family: root.fontFamily
              font.pixelSize: Style.font.displayLarge
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
            }

            Text {
              text: root.rows.length === 0
                ? "Vault unavailable — is rbw unlocked?"
                : "No matches for “" + root.filterText + "”"
              color: root.foreground
              opacity: 0.7
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
            }
          }
        }

        Text {
          width: parent.width
          height: root.footerHeight
          text: root.hints
          color: root.foreground
          opacity: 0.42
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
          verticalAlignment: Text.AlignVCenter
        }
      }
    }
  }
}
