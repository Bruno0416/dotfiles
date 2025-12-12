import QtQuick 2.0
import SddmComponents 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: container
    width: 2560
    height: 1440
    color: "black"
    
    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true
    
    property int sessionIndex: sessionList.currentIndex
    
    // PROPIEDAD NUEVA: Controla si mostramos el login
    property bool showLogin: false 
    
    TextConstants { id: textConstants }
    
    Connections {
        target: sddm
        function onLoginSucceeded() {}
        function onLoginFailed() {
            passwordInput.text = ""
            passwordInput.focus = true
            shakeAnimation.running = true 
            // Aseguramos que se mantenga visible si falla
            showLogin = true 
        }
    }
    
    // --- RELOJ (TIMER) ---
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var date = new Date()
            horaText.text = Qt.formatTime(date, "HH")
            minutoText.text = Qt.formatTime(date, "mm")
            diaText.text = Qt.formatDate(date, "dddd")
            fechaText.text = Qt.formatDate(date, "dd MMM")
        }
    }
    
    // --- FONDO AVANZADO ---
    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.background || "Backgrounds/current.jpg"
        fillMode: Image.PreserveAspectCrop
        visible: false
        smooth: true 
    }
    
    GaussianBlur {
        id: blurEffect
        anchors.fill: parent
        source: wallpaper
        radius: 40         
        samples: 40        
        deviation: 4       
        transparentBorder: true
        visible: false 
    }

    BrightnessContrast {
        anchors.fill: parent
        source: blurEffect
        brightness: -0.18
        contrast: -0.1
    }
    
    // --- RELOJ ---
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -150
        spacing: -50
        
        Text {
            id: horaText
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(new Date(), "HH")
            color: "white"
            font.pixelSize: 150
            font.bold: true
            font.family: "Adwaita Sans"
            style: Text.Normal
            renderType: Text.NativeRendering
        }
        
        Text {
            id: minutoText
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(new Date(), "mm")
            color: "white"
            font.pixelSize: 150
            font.bold: true
            font.family: "Adwaita Sans"
            style: Text.Normal
            renderType: Text.NativeRendering
        }
    }
    
    // --- FECHA ---
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.5 
        spacing: 0
        
        Text {
            id: diaText
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(new Date(), "dddd")
            color: "white"
            font.pixelSize: 22
            font.family: "JetBrainsMono NFM"
            font.bold: true
            opacity: 1.0
            font.capitalization: Font.AllUppercase
            renderType: Text.NativeRendering
        }

        Text {
            id: fechaText
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(new Date(), "dd MMM")
            color: "white"
            font.pixelSize: 18
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
            opacity: 1.0
            renderType: Text.NativeRendering
        }
    }
    
    // --- INPUT DE CONTRASEÑA ANIMADO ---
    Rectangle {
        id: loginBox
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 0 
        anchors.bottom: parent.bottom
        height: 55
        
        // --- ANIMACIÓN DE APARICIÓN (FADE + SLIDE UP) ---
        // 1. Fade: 0 si está oculto, 1 si se tecleó
        opacity: showLogin ? 1 : 0
        
        // 2. Slide: Empieza más abajo (150) y sube a su sitio (200)
        anchors.bottomMargin: showLogin ? 200 : 100
        
        // Suavizado para la aparición
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
        Behavior on anchors.bottomMargin { NumberAnimation { duration: 600; easing.type: Easing.OutBack } }

        // --- ANIMACIONES EXISTENTES ---
        width: passwordInput.activeFocus ? 240 : 200
        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        
        color: "#66ffffff"
        radius: 100
        border.width: 3
        border.color: passwordInput.activeFocus ? "white" : "#99ffffff"
        Behavior on border.color { ColorAnimation { duration: 200 } }

        SequentialAnimation {
            id: shakeAnimation
            NumberAnimation { target: loginBox; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50 }
            NumberAnimation { target: loginBox; property: "anchors.horizontalCenterOffset"; to: 10; duration: 50 }
            NumberAnimation { target: loginBox; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50 }
            NumberAnimation { target: loginBox; property: "anchors.horizontalCenterOffset"; to: 10; duration: 50 }
            NumberAnimation { target: loginBox; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
        }
        
        TextInput {
            id: passwordInput
            anchors.fill: parent
            anchors.margins: 15
            
            font.pixelSize: 15 
            font.family: "JetBrainsMono Nerd Font"
            font.letterSpacing: 5 
            
            color: "white"
            echoMode: TextInput.Password
            focus: true
            
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            
            renderType: Text.NativeRendering
            
            // --- DETECTOR DE ACTIVIDAD ---
            // Al presionar cualquier tecla, activamos las animaciones
            Keys.onPressed: {
                showLogin = true
            }
            
            Text {
                text: "Password..."
                color: "white"
                opacity: 0.5 
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
                font.italic: true
                font.letterSpacing: 0
                visible: parent.text === ""
                anchors.centerIn: parent
                renderType: Text.NativeRendering
            }
            
            Keys.onReturnPressed: sddm.login(userModel.lastUser, passwordInput.text, sessionIndex)
            Keys.onEnterPressed: sddm.login(userModel.lastUser, passwordInput.text, sessionIndex)
        }
    }
    
    // --- SELECTOR DE SESIÓN ---
    Item {
        id: sessionContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: loginBox.bottom
        anchors.topMargin: 15
        width: 180
        height: 35
        z: 100
        
        // Vinculamos la opacidad al loginBox para que aparezcan juntos
        opacity: showLogin ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
        
        property bool isOpen: false
        
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: 0
            
            Text {
                anchors.centerIn: parent
                text: sessionList.currentItem ? sessionList.currentItem.sessionName : ""
                color: "white"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16 
                opacity: 0.8 
                elide: Text.ElideRight
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                renderType: Text.NativeRendering
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.opacity = 1.0
                    onExited: parent.opacity = 0.8
                    onClicked: sessionContainer.isOpen = !sessionContainer.isOpen
                }
            }
        }
        
        Rectangle {
            visible: sessionContainer.isOpen
            width: parent.width + 60
            anchors.horizontalCenter: parent.horizontalCenter
            height: Math.min(sessionList.count * 35 + 10, 160)
            y: parent.height + 5
            
            color: "#66ffffff" 
            radius: 15 
            border.color: "#99ffffff"
            border.width: 2
            
            ListView {
                id: sessionList
                anchors.fill: parent
                anchors.margins: 5
                clip: true
                
                model: sessionModel
                currentIndex: sessionModel.lastIndex
                
                delegate: Item {
                    width: parent.width
                    height: 35
                    property string sessionName: name 
                    
                    Rectangle {
                        anchors.fill: parent
                        radius: 5
                        color: area.containsMouse || ListView.isCurrentItem ? "#40ffffff" : "transparent"
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: name
                        color: "white"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14 
                        renderType: Text.NativeRendering
                    }
                    
                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            sessionList.currentIndex = index
                            sessionContainer.isOpen = false
                        }
                    }
                }
            }
        }
    }
    
    // Texto de Usuario
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: loginBox.top
        anchors.bottomMargin: 15
        
        text: userModel.lastUser
        color: "white"
        font.pixelSize: 18
        font.family: "JetBrainsMono Nerd Font"
        
        // Vinculamos opacidad también (pero con max 0.8 como estaba antes)
        opacity: showLogin ? 0.8 : 0
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
        
        renderType: Text.NativeRendering
    }
    
    Component.onCompleted: {
        passwordInput.forceActiveFocus()
    }
}
