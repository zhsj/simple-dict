import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "me.zhsj.ubuntu.dict"

    automaticOrientation: true
    width: units.gu(100)
    height: units.gu(75)

    XmlListModel {
        id: keyXmlModel
        source: ""
        query: "/dict/key"
        XmlRole {
            name: "content"
            query: "string()"
            isKey: true
        }

        onSourceChanged: {
            keyXmlModel.query = "/dict/key"
            keyXmlModel.reload()
        }
        property var tempValues

        onStatusChanged: {
            if(status == XmlListModel.Ready){
                //var tempValues;
                if(query == "/dict/key") {
                    wordLable.text = keyXmlModel.get(0).content;
                    wordLable.visible = true;
                    keyXmlModel.query = "/dict/ps";
                    keyXmlModel.reload();
                }
                else if(query == "/dict/ps"){
                    if(count > 0){
                        tempValues = [];
                        for(var i = 0;i < count; i++){
                            tempValues.push(keyXmlModel.get(i).content);
                        }
                        pron.values = tempValues;
                        pronHeader.visible = true;
                        pronList.visible = true;
                    }
                    keyXmlModel.query = "/dict/pos";
                    keyXmlModel.reload();
                }
                else if(query == "/dict/pos"){
                    if(count > 0){
                        tempValues = [];
                        for(var i = 0;i < count; i++){
                            tempValues.push(keyXmlModel.get(i).content);
                        }
                    }
                    keyXmlModel.query = "/dict/acceptation";
                    keyXmlModel.reload();
                }
                else if(query == "/dict/acceptation"){
                    if(count > 0 && tempValues.length > 0){
                        for(var i = 0; i < count; i++){
                            tempValues.push(keyXmlModel.get(i).content);
                        }
                        acceptation.values = tempValues;
                        acceptationHeader.visible = true;
                        acceptationList.visible = true;
                    }
                    keyXmlModel.query = "/dict/sent/orig";
                    keyXmlModel.reload();
                }
                else if(query == "/dict/sent/orig"){
                    if(count > 0){
                        tempValues = [];
                        for(var i = 0;i < count; i++){
                            tempValues.push(keyXmlModel.get(i).content);
                        }
                    }
                    keyXmlModel.query = "/dict/sent/trans";
                    keyXmlModel.reload();
                }
                else if(query == "/dict/sent/trans"){
                    if(count > 0 && tempValues.length > 0){
                        for(var i = 0; i < count; i++){
                            tempValues.push(keyXmlModel.get(i).content);
                        }
                        sent.values = tempValues;
                        sentHeader.visible = true;
                        sentList.visible = true;
                    }
                }
            }
        }
    }

    Page {
        title: i18n.tr("Ubuntu Dict")
        flickable: null
        Flickable{
            id: content
            anchors.fill: parent
            contentHeight: column.height
            Column {
                id : column
                spacing: units.gu(1)
                anchors {
                    margins: units.gu(2)
                    fill: parent
                }
                property var isVisible: (function(values){
                    if(values === undefined || values === null) return false;
                    if(values.length < 1) return false;
                    return true;
                })

                TextField {
                    id: input
                    objectName: "input"
                    width: parent.width
                    placeholderText: i18n.tr("要查的单词")
                }
                Button {
                    objectName: "button"
                    width: parent.width

                    text: i18n.tr("查询")

                    onClicked: {
                        if(input.text != ""){
                            var url = "http://dict-co.iciba.com/api/dictionary.php?key=5AF713DE602216C16CCCD3C6E3FA19C7&w=" + input.text
                            keyXmlModel.source = url
                        }
                    }
                }
                Label {
                    visible: column.isVisible(wordLable.text)
                    id: wordLable
                    text: i18n.tr("")
                    fontSize: "large"
                    anchors.left: parent.left

                }
                ListItem.Header {
                    id: pronHeader
                    visible: column.isVisible(pron.values)
                    text: i18n.tr("发音")
                }
                ListItem.Empty {
                    id: pronList
                    visible: column.isVisible(pron.values)
                    height: pron.height
                    Label{
                        id: pron
                        text: concatenatedValues(pron.values)
                        property var values : []
                        function concatenatedValues(values) {
                            var n = values.length;
                            var result = "";
                            if (n === 2) {
                                result = i18n.tr("英 [") + i18n.tr(values[0]) + i18n.tr("]    ")
                                        + i18n.tr("美 [") + i18n.tr(values[1]) + i18n.tr("]\n");
                            }
                            else if(n === 1) {
                                result = i18n.tr("[") + i18n.tr(values[0]) + i18n.tr("]\n")
                            }

                            return result;
                        }

                    }
                }

                ListItem.Header {
                    id: acceptationHeader
                    visible: column.isVisible(acceptation.values)
                    text: i18n.tr("基本解释")
                }
                ListItem.Empty {
                    id: acceptationList
                    visible: column.isVisible(acceptation.values)
                    height: acceptation.height
                    Label{
                        id: acceptation
                        text: concatenatedValues(acceptation.values)
                        property var values : []
                        function concatenatedValues(values) {
                            var n = values.length;
                            var result = "";
                            for (var i = 0; i < n/2; i++){
                                result += i18n.tr(values[i]) + i18n.tr(" ");
                                result += i18n.tr(values[n/2 + i]) + i18n.tr("\n");
                            }
                            return result;
                        }

                    }
                }

                ListItem.Header {
                    id: sentHeader
                    visible: column.isVisible(sent.values)
                    text: i18n.tr("例句")
                }
                ListItem.Empty {
                    id: sentList
                    visible: column.isVisible(sent.values)
                    height: sent.height
                    Label{
                        width: parent.width
                        id: sent
                        text: concatenatedValues(sent.values)
                        property var values : []
                        function concatenatedValues(values) {
                            var n = values.length;
                            var result = "";
                            for (var i = 0; i < n/2; i++){
                                result += i18n.tr(values[i]);
                                result += i18n.tr(values[n/2 + i]) + i18n.tr("\n");
                            }
                            return result;
                        }
                        wrapMode: Text.WrapAnywhere
                    }
                }
            }
        }
    }
}
