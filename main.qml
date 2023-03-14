import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    visible: true
    title: qsTr("Hello World")
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visibility: "Maximized"
    minimumWidth: 600
    minimumHeight: 480
    Timeline {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

    }
}
