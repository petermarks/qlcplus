/*
  Q Light Controller Plus
  RGBMatrixEditor.qml

  Copyright (c) Massimo Callegari

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0.txt

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import QtQuick 2.0
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.1

import com.qlcplus.classes 1.0
import "."

Rectangle
{
    id: rgbmeContainer
    anchors.fill: parent
    color: "transparent"

    property int functionID: -1
    property RGBMatrix matrix

    signal requestView(int ID, string qmlSrc)

    onFunctionIDChanged:
    {
        console.log("RGBMatrix ID: " + functionID)
        matrix = functionManager.getFunction(functionID)
    }

    Rectangle
    {
        id: topBar
        color: UISettings.bgMedium
        width: rgbmeContainer.width
        height: 40
        z: 2

        Rectangle
        {
            id: backBox
            width: 40
            height: 40
            color: "transparent"

            Image
            {
                id: leftArrow
                anchors.fill: parent
                rotation: 180
                source: "qrc:/arrow-right.svg"
                sourceSize: Qt.size(width, height)
            }
            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: backBox.color = "#666"
                onExited: backBox.color = "transparent"
                onClicked: requestView(-1, "qrc:/FunctionManager.qml")
            }
        }
        TextInput
        {
            id: cNameEdit
            x: leftArrow.width + 5
            height: 40
            width: rgbmeContainer.width - x
            color: UISettings.fgMain
            text: matrix ? matrix.name : ""
            verticalAlignment: TextInput.AlignVCenter
            font.family: "RobotoCondensed"
            font.pixelSize: 20
            selectByMouse: true
            Layout.fillWidth: true
            onTextChanged:
            {
                if (matrix)
                    matrix.name = text
            }
        }
    }

    onWidthChanged: rgbmeGrid.width = width - 10

    GridLayout
    {
        id: rgbmeGrid
        columns: 2
        columnSpacing: 5
        rowSpacing: 5
        x: 5
        y: topBar.height + 2
        width: parent.width - 10
        //height: parent.height - topBar.height - 10

        property int itemsHeight: 38

        // row 1
        RobotoText { label: qsTr("Fixture Group") }
        CustomComboBox
        {
            Layout.fillWidth: true
            height: rgbmeGrid.itemsHeight
            model: fixtureManager.groupsListModel
            currentValue: rgbMatrixEditor.fixtureGroup
            onValuechanged: rgbMatrixEditor.fixtureGroup = value
        }

        // row 2
        RGBMatrixPreview
        {
            Layout.columnSpan: 2
            Layout.fillWidth: true
            //Layout.fillHeight: true

            //height: width

            matrixSize: rgbMatrixEditor.previewSize
            matrixData: rgbMatrixEditor.previewData
        }

        // row 3
        RobotoText { label: qsTr("Pattern") }
        CustomComboBox
        {
            Layout.fillWidth: true
            height: rgbmeGrid.itemsHeight
            model: rgbMatrixEditor.algorithms
            currentIndex: rgbMatrixEditor.algorithmIndex
            onCurrentIndexChanged:
            {
                rgbMatrixEditor.algorithmIndex = currentIndex
                if (currentText == "Text")
                    rgbParamsLoader.sourceComponent = textAlgoComponent
                else if (currentText == "Image")
                    rgbParamsLoader.sourceComponent = imageAlgoComponent
                else
                    rgbParamsLoader.sourceComponent = null
            }
        }

        // row 4
        RobotoText { label: qsTr("Blend mode") }
        CustomComboBox
        {
            Layout.fillWidth: true
            height: rgbmeGrid.itemsHeight

            ListModel
            {
                id: blendModel
                ListElement { mLabel: qsTr("Default (HTP)"); }
                ListElement { mLabel: qsTr("Mask"); }
                ListElement { mLabel: qsTr("Additive"); }
                ListElement { mLabel: qsTr("Subtractive"); }
            }
            model: blendModel
            //model: rgbMatrixEditor.algorithms
            //currentIndex: rgbMatrixEditor.currentAlgo
            //onCurrentIndexChanged: rgbMatrixEditor.currentAlgo = currentIndex
        }

        // row 5
        RobotoText { label: qsTr("Colors") }
        Row
        {
            Layout.fillWidth: true
            height: rgbmeGrid.itemsHeight
            spacing: 4

            Rectangle
            {
                id: startColButton
                width: 80
                height: parent.height
                radius: 5
                border.color: scMouseArea.containsMouse ? "white" : UISettings.bgLight
                border.width: 2
                color: startColTool.selectedColor
                visible: rgbMatrixEditor.algoColors > 0 ? true : false

                MouseArea
                {
                    id: scMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: startColTool.visible = !startColTool.visible
                }

                ColorTool
                {
                    id: startColTool
                    parent: mainView
                    x: rightSidePanel.x - width
                    y: rightSidePanel.y
                    visible: false
                    closeOnSelect: true
                    selectedColor: rgbMatrixEditor.startColor

                    onColorChanged:
                    {
                        startColButton.color = Qt.rgba(r, g, b, 1.0)
                        rgbMatrixEditor.startColor = startColButton.color
                    }
                }
            }
            Rectangle
            {
                id: endColButton
                width: 80
                height: parent.height
                radius: 5
                border.color: ecMouseArea.containsMouse ? "white" : UISettings.bgLight
                border.width: 2
                color: rgbMatrixEditor.hasEndColor ? rgbMatrixEditor.endColor : "transparent"
                visible: rgbMatrixEditor.algoColors > 1 ? true : false

                MouseArea
                {
                    id: ecMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: endColTool.visible = !startColTool.visible
                }

                ColorTool
                {
                    id: endColTool
                    parent: mainView
                    x: rightSidePanel.x - width
                    y: rightSidePanel.y
                    visible: false
                    closeOnSelect: true
                    selectedColor: rgbMatrixEditor.endColor

                    onColorChanged: rgbMatrixEditor.endColor = Qt.rgba(r, g, b, 1.0)
                }
            }
            IconButton
            {
                width: parent.height
                height: parent.height
                imgSource: "qrc:/cancel.svg"
                visible: rgbMatrixEditor.algoColors > 1 ? true : false
                onClicked: rgbMatrixEditor.hasEndColor = false
            }
        }

        Rectangle
        {
            Layout.columnSpan: 2
            Layout.fillWidth: true
            height: rgbmeGrid.itemsHeight
            visible: rgbParamsLoader.sourceComponent ? true : false

            color: UISettings.bgLight
            RobotoText { label: qsTr("Parameters") }
        }
    } // GridLayout

    Loader
    {
        id: rgbParamsLoader
        y: rgbmeGrid.y + rgbmeGrid.height + 5
        width: parent.width
        source: ""
    }

    // *************************************************************
    // Here starts all the Algorithm-specific Component definitions,
    // loaded at runtime depending on the selected algorithm
    // *************************************************************

    // Text Algorithm parameters
    Component
    {
        id: textAlgoComponent
        GridLayout
        {
            columns: 2
            columnSpacing: 5

            // Row 1
            RobotoText { label: qsTr("Text") }
            Rectangle
            {
                Layout.fillWidth: true
                height: rgbmeGrid.itemsHeight
                color: "transparent"

                Rectangle
                {
                    height: parent.height
                    width: parent.width - fontButton.width - 5
                    radius: 3
                    color: UISettings.bgMedium
                    border.color: "#222"

                    TextInput
                    {
                        id: algoTextEdit
                        anchors.fill: parent
                        anchors.margins: 4
                        anchors.verticalCenter: parent.verticalCenter
                        text: rgbMatrixEditor.algoText
                        font.pointSize: 16
                        color: "white"

                        onTextChanged: rgbMatrixEditor.algoText = text
                    }
                }
                IconButton
                {
                    id: fontButton
                    anchors.right: parent.right
                    imgSource: "qrc:/font.svg"

                    onClicked: fontDialog.visible = true

                    FontDialog
                    {
                        id: fontDialog
                        title: qsTr("Please choose a font")
                        //font: wObj ? wObj.font : ""
                        visible: false

                        onAccepted:
                        {
                            console.log("Selected font: " + fontDialog.font)
                            algoTextEdit.font = fontDialog.font
                            algoTextEdit.font.pointSize = 16
                            //wObj.font = fontDialog.font
                        }
                    }
                }
            }

            // Row 2
            RobotoText { label: qsTr("Animation") }
            CustomComboBox
            {
                Layout.fillWidth: true
                height: rgbmeGrid.itemsHeight

                ListModel
                {
                    id: textAnimModel
                    ListElement { mLabel: qsTr("Letters"); }
                    ListElement { mLabel: qsTr("Horizontal"); }
                    ListElement { mLabel: qsTr("Vertical"); }
                }
                model: textAnimModel
            }

            // Row 3
            RobotoText { label: qsTr("Offset") }
            Rectangle
            {
                Layout.fillWidth: true
                height: rgbmeGrid.itemsHeight
                color: "transparent"

                Row
                {
                    spacing: 20
                    anchors.fill: parent

                    RobotoText { label: qsTr("X") }
                    CustomSpinBox
                    {
                        height: parent.height
                    }

                    RobotoText { label: qsTr("Y") }
                    CustomSpinBox
                    {
                        height: parent.height
                    }
                }
            }
        }
    }
    // ************************************************************

    // Image Algorithm parameters
    Component
    {
        id: imageAlgoComponent
        GridLayout
        {
            columns: 2
            columnSpacing: 5

            // Row 1
            RobotoText { label: qsTr("Image") }
            Rectangle
            {
                Layout.fillWidth: true
                height: rgbmeGrid.itemsHeight
                color: "transparent"

                Rectangle
                {
                    height: parent.height
                    width: parent.width - fontButton.width - 5
                    radius: 3
                    color: UISettings.bgMedium
                    border.color: "#222"
                    clip: true

                    TextInput
                    {
                        id: algoTextEdit
                        anchors.fill: parent
                        anchors.margins: 4
                        anchors.verticalCenter: parent.verticalCenter
                        text: rgbMatrixEditor.algoImagePath
                        font.pointSize: 16
                        color: "white"

                        onTextChanged: rgbMatrixEditor.algoImagePath = text
                    }
                }
                IconButton
                {
                    id: fontButton
                    anchors.right: parent.right
                    imgSource: "qrc:/background.svg"

                    onClicked: fileDialog.visible = true

                    FileDialog
                    {
                        id: fileDialog
                        visible: false
                        title: qsTr("Select an image")
                        nameFilters: [ "Image files (*.png *.bmp *.jpg *.jpeg *.gif)", "All files (*)" ]

                        onAccepted: rgbMatrixEditor.algoImagePath = fileDialog.fileUrl
                    }

                }
            }

            // Row 2
            RobotoText { label: qsTr("Animation") }
            CustomComboBox
            {
                Layout.fillWidth: true
                height: rgbmeGrid.itemsHeight

                ListModel
                {
                    id: imageAnimModel
                    ListElement { mLabel: qsTr("Static"); }
                    ListElement { mLabel: qsTr("Horizontal"); }
                    ListElement { mLabel: qsTr("Vertical"); }
                    ListElement { mLabel: qsTr("Animation"); }
                }
                model: imageAnimModel
            }

            // Row 3
            RobotoText { label: qsTr("Offset") }
            Rectangle
            {
                Layout.fillWidth: true
                height: rgbmeGrid.itemsHeight
                color: "transparent"

                Row
                {
                    spacing: 20
                    anchors.fill: parent

                    RobotoText { label: qsTr("X") }
                    CustomSpinBox
                    {
                        height: parent.height
                    }

                    RobotoText { label: qsTr("Y") }
                    CustomSpinBox
                    {
                        height: parent.height
                    }
                }
            }
        }
    }

}