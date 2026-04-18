import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 500
    height: 600

    // A API nativa do Noctalia para executar comandos
    property var pluginApi

    // O modelo de dados em memória
    ListModel {
        id: keybindsModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            text: "Editor de Atalhos (Niri)"
            font.pixelSize: 24
            font.bold: true
            color: "white" // Ajuste conforme o tema do seu Noctalia
            Layout.alignment: Qt.AlignHCenter
        }

        // Área rolável para a lista de atalhos
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: listView
                model: keybindsModel
                spacing: 10

                // O "delegate" dita como CADA atalho vai se parecer na tela
                delegate: RowLayout {
                    width: listView.width
                    spacing: 10

                    TextField {
                        text: model.key
                        Layout.preferredWidth: 150
                        placeholderText: "Atalho (ex: Mod+T)"
                        
                        // Atualiza o modelo na memória quando o usuário digitar
                        onTextEdited: model.key = text 
                    }

                    TextField {
                        text: model.action
                        Layout.fillWidth: true
                        placeholderText: "Ação (ex: spawn \"alacritty\")"
                        
                        // Atualiza o modelo na memória quando o usuário digitar
                        onTextEdited: model.action = text
                    }
                    
                    // Um botão de excluir para o futuro (opcional)
                    Button {
                        text: "X"
                        onClicked: keybindsModel.remove(index)
                    }
                }
            }
        }

        Button {
            text: "Salvar no Niri"
            Layout.alignment: Qt.AlignRight
            onClicked: {
                console.log("Botão de salvar clicado! (Lógica em breve)")
            }
        }
    }

    // Função que chama o Python e popula o ListModel
    function loadKeybinds() {
        // Atenção: Garanta que este caminho bate com a pasta real do seu plugin
        let scriptPath = "~/.config/noctalia/plugins/niri-keybinds/niri_bridge.py"
        
        pluginApi.exec(`python3 ${scriptPath} read`, function(error, stdout, stderr) {
            if (error) {
                console.error("Erro ao executar script:", stderr)
                return
            }
            
            try {
                let bindsArray = JSON.parse(stdout)
                
                keybindsModel.clear()
                for (let i = 0; i < bindsArray.length; i++) {
                    // O append joga o objeto JSON direto para o ListModel
                    keybindsModel.append(bindsArray[i])
                }
                console.log("Atalhos carregados com sucesso!")
            } catch (e) {
                console.error("Erro ao fazer parse do JSON:", e)
            }
        })
    }

    // Gatilho: Assim que a interface abrir, carrega os dados
    Component.onCompleted: {
        loadKeybinds()
    }
}