// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Item
{
    height: 100
    width: 100
    anchors.fill: parent

    property string color_d: "#1B94E0"
Rectangle {
    id: rect1
    width: parent.width
    height: parent.height
    radius: 10
    transformOrigin: Item.Center
    scale: 1.1
    opacity: 0.130
    color: color_d
    anchors.centerIn: parent
}

Rectangle {
    id: rect2
    width: parent.width
    height: parent.height
    radius: 10
    transformOrigin: Item.Center
    scale: 1.200
    opacity: 0.070
    color: color_d
    anchors.centerIn: parent
}

Rectangle {
    id: rect3
    width: parent.width
    height: parent.height
    radius: 10
    transformOrigin: Item.Center
    scale: 1.250
    opacity: 0.080
    color: color_d
    anchors.centerIn: parent
}

Rectangle {
    id: rect4
    width: parent.width
    height: parent.height
    radius: 10
    transformOrigin: Item.Center
    scale: 1.300
    opacity: 0.010
    color: color_d
    anchors.centerIn: parent
}

}
