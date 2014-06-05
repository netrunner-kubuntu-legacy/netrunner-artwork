/*
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
import org.kde.plasma.components 0.1 as PlasaComponents
import org.kde.plasma.core 0.1 as PlasmaCore

PlasmaCore.FrameSvgItem {
    id: powerBar
    width: childrenRect.width + margins.left
    height: childrenRect.height + margins.top * 2
    //imagePath: "translucent/widgets/tooltip"
    //prefix: "south-mini-top"

    enabledBorders: "LeftBorder|TopBorder"

    Row {
        spacing: 48
        x: parent.margins.left
        y: parent.margins.top

        /*PlasmaComponents.*/ToolButton {
            id: suspendButton
//            text: i18n("Suspend")
//            iconSource: "system-suspend"
            iconSource: "img/sleep.png"
            enabled: power.canSuspend;
            onClicked: power.suspend();
        }

        /*PlasmaComponents.*/ToolButton {
            id: hibernateButton
//            text: i18n("Hibernate")
//            iconSource: "system-suspend-hibernate"
            iconSource: "img/hibernate.png"
            //Hibernate is a special case, lots of distros disable it, so if it's not enabled don't show it
            enabled: power.canHibernate
            onClicked: power.hibernate();
        }

        /*PlasmaComponents.*/ToolButton {
            id: restartButton
//            text: i18n("Restart")
//            iconSource: "system-reboot"
            iconSource: "img/reboot.png"
            enabled: power.canRestart
            onClicked: power.restart();
        }

        /*PlasmaComponents.*/ToolButton {
            id: shutdownButton
//            text: i18n("Shutdown")
//            iconSource: "system-shutdown"
            iconSource: "img/shutdown.png"
            enabled: power.canShutdown
            onClicked: power.shutdown();
        }
    }
}
