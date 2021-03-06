/*
    Copyright (C) 2012 Dickson Leong
    This file is part of Tweetian.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    id: root

    default property alias content: contentColumn.children
    property color sideRectColor: "transparent"
    property string imageSource: profileImageUrl
    property bool subItemIndicator: false

    property bool highlighted: highlight.opacity === 1 // read-only

    signal clicked
    signal pressAndHold

    property int __originalHeight: height // private

    implicitWidth: ListView.view ? ListView.view.width : 0
    implicitHeight: Math.max(contentColumn.height, profileImage.height) + 2 * constant.paddingLarge

    BorderImage {
        id: highlight
        border {
            left: platformStyle.borderSizeMedium
            top: platformStyle.borderSizeMedium
            right: platformStyle.borderSizeMedium
            bottom: platformStyle.borderSizeMedium
        }
        opacity: 0
        anchors.fill: parent
    }

    PropertyAnimation {
        id: highlightFadeOut
        target: highlight
        property: "opacity"
        to: 0
        easing.type: Easing.Linear
        duration: 150
    }

    Rectangle {
        id: bottomLine
        anchors { left: root.left; right: root.right; bottom: parent.bottom }
        height: 1
        color: constant.colorMarginLine
    }

    Loader {
        id: sideRectLoader
        anchors { left: parent.left; top: parent.top }
        sourceComponent: sideRectColor == "transparent" ? undefined : sideRect

        Component {
            id: sideRect

            Rectangle {
                height: root.height - 1
                width: constant.paddingSmall
                color: sideRectColor ? sideRectColor : "transparent"
            }
        }
    }

    Loader {
        id: subIconLoader
        anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: constant.paddingSmall }
        sourceComponent: subItemIndicator ? subIconComponent : undefined

        Component {
            id: subIconComponent

            Image {
                height: sourceSize.height; width: sourceSize.width
                sourceSize { height: constant.graphicSizeSmall; width: constant.graphicSizeSmall }
                source: "image://theme/qtg_graf_drill_down_indicator" + (settings.invertedTheme ? "_inverse" : "")
            }
        }
    }

    Image {
        id: profileImage
        anchors { top: parent.top; left: parent.left; margins: constant.paddingLarge }
        height: constant.graphicSizeMedium; width: constant.graphicSizeMedium
        sourceSize { height: height; width: width }
        asynchronous: true

        NumberAnimation {
            id: imageLoadedEffect
            target: profileImage
            property: "opacity"
            from: 0; to: 1
            duration: 250
        }

        Binding {
            id: imageSourceBinding
            target: profileImage
            property: "source"
            value: thumbnailCacher.get(root.imageSource)
                   || (networkMonitor.online ? root.imageSource : constant.twitterBirdIcon)
            when: false
        }

        Connections {
            id: movementEndedSignal
            target: null
            onMovementEnded: {
                imageSourceBinding.when = true
                movementEndedSignal.target = null
            }
        }

        onStatusChanged: {
            if (status == Image.Ready) {
                imageLoadedEffect.start()
                if (source == root.imageSource) thumbnailCacher.store(root.imageSource, profileImage)
            }
            else if (status == Image.Error) source = constant.twitterBirdIcon
        }

        Component.onCompleted: {
            if (!root.ListView.view || !root.ListView.view.moving) imageSourceBinding.when = true
            else movementEndedSignal.target = root.ListView.view
        }
    }

    Column {
        id: contentColumn
        anchors {
            top: parent.top; topMargin: constant.paddingLarge
            left: profileImage.right; leftMargin: constant.paddingMedium
            right: parent.right
            rightMargin: subIconLoader.status == Loader.Ready
                         ? (constant.paddingSmall + subIconLoader.width + constant.paddingSmall)
                         : constant.paddingMedium
        }
        height: childrenRect.height
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        onClicked: root.clicked()
        onPressed: {
            listItemHapticEffect.play()
            highlight.source = "../Image/list_pressed.svg"
            highlight.opacity = 1
        }
        onReleased: {
            listItemHapticEffect.play()
            highlightFadeOut.restart()
        }
        onCanceled: highlightFadeOut.restart()
        onPressAndHold: root.pressAndHold()
    }

    Timer {
        id: pause
        interval: 250
        onTriggered: height = __originalHeight
    }

    NumberAnimation {
        id: onAddAnimation
        target: root
        property: "scale"
        duration: 250
        from: 0.25; to: 1
        easing.type: Easing.OutBack
    }

    ListView.onAdd: {
        if (root.ListView.view.stayAtCurrentPosition) {
            if (root.ListView.view.atYBeginning) root.ListView.view.contentY += 1
            __originalHeight = height
            height = 0
            pause.start()
        }
        else onAddAnimation.start()
    }
}
