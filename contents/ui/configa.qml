import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
import QtQuick.Dialogs 1.0

Item {
	id: page
	property alias cfg_tamano: slide.value
	property alias cfg_dirsource: imagedir.text
	property alias cfg_wichsource:  fromdistro.checked
	property alias cfg_usedistro:  distros.checked
	property alias cfg_usephoto:  photos.checked
	
	Component.onCompleted:{
//         fromdistro.checked = plasmoid.configuration.wichsource == 0?true:false
        fromadir.checked = fromdistro.checked?false:true
    }
	
	ColumnLayout {
		    
	    
		Label{
			text:"Size: "+slide.value+"x"+slide.value
		}
		RowLayout {
			Label{
				text:"2x2"
			}
			Slider {
				id: slide
				minimumValue: 2
				maximumValue: 9
				stepSize: 1
				tickmarksEnabled: true
			}
			Label{
				text:"9x9"
			}
		}
		
		ColumnLayout{
            ExclusiveGroup { id: tabPositionGroup }
            Label{text: "Random image:"}
            RadioButton {
                id: fromdistro
                text: "Predefined images"
//                 checked: true
                exclusiveGroup: tabPositionGroup
            }
            ColumnLayout {
                Layout.leftMargin: 20
                CheckBox {
                    id:distros
                    text: qsTr("Distros logos")
                    enabled: fromdistro.checked
//                     checked: true
                    onCheckedChanged:{if(!distros.checked && !photos.checked){checked=true}}
                }
                CheckBox {
                    id:photos
                    text: qsTr("Photos")
                    enabled: fromdistro.checked
                    onCheckedChanged:{if(!distros.checked && !photos.checked){distros.checked=true}}
                }
            }
            RadioButton {
                id: fromadir
                text: "From a directory"
//                 checked: false
                exclusiveGroup: tabPositionGroup
            }
            RowLayout {
                TextField{
                    id: imagedir
                    Layout.fillWidth: true
                    //width:1600
                    placeholderText: qsTr("Choose a directory with images")
                    //text: fileDialog.fileUrl
                    //text : (logos.indexOf(plasmoid.configuration.imagenbackground) >= 0)?"":plasmoid.configuration.imagenbackground
                    visible: fromadir.checked
                    //onTextChanged: imagenes.imagen = imageother.text
                    Component.onCompleted:{
                        text = plasmoid.configuration.dirsource

                    }
                }
                Button {
                    //QtLayouts.Layout.fillWidth: true
                    text: "..."
                    visible: fromadir.checked
                    //width: 10
                    //visible: (imagenes.currentText == "Other...")?true:false
                    onClicked: {fileDialog.visible = true;}
                }
            }
                
            
        }
	}
	
	 FileDialog {
        id: fileDialog
        title: "Please choose directory with images"
        folder: shortcuts.home
        selectFolder : true
        //nameFilters: [ "Image files (*.jpg *.png *.svg)", "All files (*)" ]
        onAccepted: {
            imagedir.text = fileUrl.toString().replace(/^(file:\/{2})/,"");
            Qt.quit()
        }
        onRejected: {
            Qt.quit()
        }
        //Component.onCompleted: visible = true
    }

}
