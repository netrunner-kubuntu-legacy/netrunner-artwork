/*
This file is part of LightDM-KDE.

Copyright 2011, 2012 David Edmundson <kde@davidedmundson.co.uk>
Copyright 2013 Harald Sitter <sitter@kde.org>

LightDM-KDE is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LightDM-KDE is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LightDM-KDE.  If not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 1.0
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore

Item {
    id: screen
    width: screenSize.width;
    height: screenSize.height;

    ScreenManager {
        id: screenManager
        delegate: Image {
             // default to keeping aspect ratio
            fillMode: config.readEntry("BackgroundKeepAspectRatio") == false ? Image.Stretch : Image.PreserveAspectCrop;
            //read from config, if there's no entry use plasma theme
            source: config.readEntry("Background") ? config.readEntry("Background"): plasmaTheme.wallpaperPath(Qt.size(width,height));
        }
    }

    Item { //recreate active screen at a sibling level which we can anchor in.
        id: activeScreen
        x: screenManager.activeScreen.x
        y: screenManager.activeScreen.y
        width: screenManager.activeScreen.width
        height: screenManager.activeScreen.height
    }

    Connections {
        target: greeter;

        onShowPrompt: {
            greeter.respond(passwordInput.text);
        }

        onAuthenticationComplete: {
            if(greeter.authenticated) {
                loginAnimation.start();
            } else {
                feedbackLabel.text = i18n("Sorry, incorrect password. Please try again.");
                feedbackLabel.showFeedback();
                passwordInput.selectAll()
                passwordInput.forceActiveFocus()
            }
        }
    }

    function doSessionSync() {
       var session = sessionButton.dataForIndex(sessionButton.currentIndex);
       if (session == "") {
           session = "default";
       }
       greeter.startSessionSync(session);
    }

    ParallelAnimation {
        id: loginAnimation
        NumberAnimation { target: logoImage; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InOutQuad }
        NumberAnimation { target: welcomeLabel; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InOutQuad }
        NumberAnimation { target: feedbackLabel; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InOutQuad }
        NumberAnimation { target: usersList; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InOutQuad }
        NumberAnimation { target: loginButtonItem; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InOutQuad }
        NumberAnimation { target: sessionButton; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InOutQuad }
        NumberAnimation { target: dateTimeLabel; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InOutQuad }
        NumberAnimation { target: powerBar; property: "opacity"; to: 0; duration: 400; easing.type: Easing.InOutQuad }
        onCompleted: doSessionSync()
    }

    Component.onCompleted: {
        setTabOrder([usersList, loginButtonItem, sessionButton, suspendButton, hibernateButton, restartButton, shutdownButton]);
        usersList.forceActiveFocus();
    }

    function setTabOrder(lst) {
        var idx;
        var lastIdx = lst.length - 1;
        for (idx = 0; idx <= lastIdx; ++idx) {
            var item = lst[idx];
            item.KeyNavigation.backtab = lst[idx > 0 ? idx - 1 : lastIdx];
            item.KeyNavigation.tab = lst[idx < lastIdx ? idx + 1 : 0];
        }
    }

    Image {
        id: logoImage
        source: "img/version.png"
        anchors.horizontalCenter: activeScreen.horizontalCenter
	anchors.bottom: activeScreen.bottom
        anchors.bottomMargin: 25
//        anchors.left: activeScreen.left
//        anchors.leftMargin: 22
    }

    PlasmaComponents.Label {
        visible: false
        id: welcomeLabel
        anchors.horizontalCenter: activeScreen.horizontalCenter
        anchors.top: activeScreen.top
        anchors.topMargin: 15
        font.pointSize: 25
        font.bold: true
        color: "#b8b8b8"
        //text: i18n("Welcome to %1", greeter.hostname);
        text: i18n("Welcome to Netrunner Frontier");
    }

    FeedbackLabel {
        id: feedbackLabel
        anchors.horizontalCenter: activeScreen.horizontalCenter
        anchors.top: welcomeLabel.bottom
        anchors.topMargin: 5
        font.pointSize: 14
    }

    property int userItemWidth: 120
    property int userItemHeight: 80
    property int userFaceSize: 64

    property int padding: 10

    Component {
        id: userDelegate

        Item {
            id: wrapper

            property bool isCurrent: ListView.isCurrentItem
            property bool activeFocus: ListView.view.activeFocus

            /* Expose current item info to the outer world. I can't find
             * another way to access this from outside the list. */
            property string username: model.name
            property string usersession: model.session

            width: userItemWidth
            height: userItemHeight

            opacity: isCurrent ? 1.0 : 0.618

            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                }
            }

            Face {
                id: face
                active: (usersList.currentItem == parent)
                anchors.bottom: loginText.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: padding * 1.5
                sourceSize.width: userFaceSize
                sourceSize.height: userFaceSize
                source: "image://face/" + name
            }

            ShadowText {
                id: loginText
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: display
                anchors.bottomMargin: 0
                anchors.horizontalCenterOffset: 0
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    wrapper.ListView.view.currentIndex = index;
                    wrapper.ListView.view.forceActiveFocus();
                }
            }
        }
    }

    function startLogin() {
        var username = usersList.currentItem.username;
        if (username == greeter.guestLoginName) {
            greeter.authenticateAsGuest();
        } else {
            greeter.authenticate(username);
        }
    }
    
    function indexForUserName(name) {
        var index;
        for (index = 0; index < usersList.count; ++index) {
            if (usersList.contentItem.children[index].username == name) {
                return index;
            }
        }
        return 0;
    }

    ListView {
        id: usersList
        anchors {
            horizontalCenter: activeScreen.horizontalCenter
            bottom: loginButtonItem.top
            bottomMargin: 38
        }
        width: activeScreen.width
        height: userItemHeight
        currentIndex: indexForUserName(greeter.lastLoggedInUser)
        model: usersModel
        focus: true        

        cacheBuffer: count * 80

        delegate: userDelegate

        orientation: ListView.Horizontal

        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: width / 2 - userItemWidth / 2
        preferredHighlightEnd: width / 2 + userItemWidth / 2

        //if the user presses down or enter, focus password
        //if user presses any normal key
        //copy that character pressed to the pasword box and force focus

        //can't use forwardTo as I want to switch focus. Also it doesn't work.
        Keys.onPressed: {
            if (event.key == Qt.Key_Down ||
                event.key == Qt.Key_Enter ||
                event.key == Qt.Key_Return) {
                passwordInput.forceActiveFocus();
            } else if (event.key & Qt.Key_Escape) {
                //if special key, do nothing. Qt.Escape is 0x10000000 which happens to be a mask used for all special keys in Qt.
            } else {
                passwordInput.text += event.text;
                passwordInput.forceActiveFocus();
            }
        }
    }

    FocusScope {
        id: loginButtonItem
        anchors {
            horizontalCenter: activeScreen.horizontalCenter
            bottom: activeScreen.verticalCenter
            bottomMargin: -32
        }
        height: 30

        property bool isGuestLogin: usersList.currentItem.username == greeter.guestLoginName

        /*PlasmaComponents.*/TextField {
            id: passwordInput
            anchors.horizontalCenter: parent.horizontalCenter
            width: 200
            height: parent.height
            focus: !loginButtonItem.isGuestLogin
            opacity: loginButtonItem.isGuestLogin ? 0 : 1

            echoMode: TextInput.Password
            placeholderText: i18n("Password")
            onAccepted: startLogin();

            Keys.onEscapePressed: {
                usersList.forceActiveFocus()
            }

            PlasmaComponents.ToolButton {
                id: loginButton
                anchors {
                    right: parent.right
                    rightMargin: y
                    verticalCenter: parent.verticalCenter
                }
                width: implicitWidth
                height: width

                iconSource: "go-jump-locationbar"
                onClicked: startLogin();
            }

            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
        }

        PlasmaComponents.Button {
            id: guestLoginButton
            anchors.horizontalCenter: parent.horizontalCenter
            width: userFaceSize + 2 * padding
            height: parent.height
            focus: loginButtonItem.isGuestLogin
            opacity: 1 - passwordInput.opacity

            iconSource: loginButton.iconSource
            text: i18n("Login")
            onClicked: startLogin();

            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
        }
    }

    ListButton {
        id: sessionButton
        anchors {
            top: loginButtonItem.bottom
            topMargin: 24
            bottom: powerBar.top
            horizontalCenter: activeScreen.horizontalCenter
        }

        model: sessionsModel
        dataRole: "key"
        currentIndex: {
            index = indexForData(usersList.currentItem.usersession)
            if (index >= 0) {
                return index;
            }
            index = indexForData(greeter.defaultSession)
            if (index >= 0) {
                return index;
            }
            return 0;
        }
    }

    DateTimeLabel {
        id: dateTimeLabel
        anchors.horizontalCenter: activeScreen.horizontalCenter
        anchors.bottom: activeScreen.bottom
        anchors.bottomMargin: 100
    }

    ControlBar {
        id: powerBar
        anchors.bottom: activeScreen.bottom
        anchors.bottomMargin: 16
        anchors.right: activeScreen.right
        anchors.rightMargin: 22
    }
}
