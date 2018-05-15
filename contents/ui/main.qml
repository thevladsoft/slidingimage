/*
 *   Copyright 2017 thevladsoft <thevladsoft2@gmail.com>
 *
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 */

import QtQuick 2.0;
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls 1.4 as QtControls
import org.kde.plasma.plasmoid 2.0
import QtWebKit 3.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1 as QtLayouts
import QtQuick.Controls.Styles 1.4
// import Qt.labs.folderlistmodel 2.1

Item {
    id:root

    width: 350
    property var arreglo: []
    property var vecinos: []
    property var cuadros: []
    property int pasos
    property int ancho: plasmoid.configuration.tamano//2/***********/
    property int alto: ancho//2/*************/
    property string imagen
    property var distros: ["images/distros/arch.png","images/distros/debian.png","images/distros/fedora.png","images/distros/kde.png","images/distros/kubuntu.png","images/distros/neon.png","images/distros/suse.png","images/distros/ubuntu.png"]
    property var photos: ["images/photos/arcobaleno.png.jpg","images/photos/bored.png.jpg","images/photos/coffee.png.jpg","images/photos/paris.png.jpg","images/photos/snack.png.jpg","images/photos/the-garden.png.jpg","images/photos/trevi.png.jpg"]
    property var extensions: ["png","PNG","jpg","JPG","svg","SVG","bmp","BMP","gif","GIF"]
    property var customimages: []

    
    Component.onCompleted:{
        inicializar()
		plasmoid.setAction("inicializa", i18n("Restart"));

    }
    
    
    function action_inicializa() {
        inicializar()
    }

    Connections {
        target: plasmoid.configuration
        onTamanoChanged: {inicializar()}
        onDirsourceChanged: {inicializar()}
        onWichsourceChanged: {inicializar()}
        onUsedistroChanged: {inicializar()}
        onUsephotoChanged: {inicializar()}
    }
    
    function recheckdir(){
        dir.ls(plasmoid.configuration.dirsource);
    }
    
    function shuffleArray(array) {
        for (var i = array.length - 2; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    }
    function buscaVecinos(array){//crea numeros enteros grandes, pero no creo que produzca error
        var left = array.slice(1).map(function(num,index) {
            if (index % (ancho) == ancho-1) {return 1}
            else {return num}
        })
        left.push(1)
        
        var right = array.slice(0,-1)
        right.splice(0,0,1)
        right = right.map(function(num,index) {
            if (index % (ancho) == 0) {return 1}
            else {return num}
        })
        
        var up = array.slice(ancho)
        for(var i=0;i<ancho;i++){
            up.push(1)
        }
        
        var down = array.slice(0,-ancho)
        for(var i=0;i<ancho;i++){
            down.unshift(1)
        }
        
		
		var result = []
        for(var i = 0; i<ancho*alto;i++){
            result[i]=left[i]*right[i]*up[i]*down[i]
        }
//         print(result)
        return result
    }
    
    function inicializar(){
        arreglo = []
        pasos = 0
        covertura.visible=false
        recheckdir()
        if(plasmoid.configuration.wichsource){
            if(plasmoid.configuration.usedistro && !plasmoid.configuration.usephoto){
                root.imagen = root.distros[Math.floor(Math.random()*root.distros.length)]
            }else if(!plasmoid.configuration.usedistro && plasmoid.configuration.usephoto){
                root.imagen = root.photos[Math.floor(Math.random()*root.photos.length)]
            }else if(plasmoid.configuration.usedistro && plasmoid.configuration.usephoto){
                root.imagen = root.photos.concat(root.distros)[Math.floor(Math.random()*(root.photos.length+root.distros.length))]
            }
        }else{
            root.imagen = plasmoid.configuration.dirsource +"/"+ customimages[Math.floor(Math.random()*root.customimages.length)]
            print("----------"+root.imagen)
        }
//         print(Math.random())
        for (var i = 0; i<ancho*alto-1;i++){
            arreglo[i]=i+1
        }
//         print(arreglo)
        var solvable=false
        while (!solvable || isordered(arreglo,false)){
            shuffleArray(arreglo)
            arreglo[ancho*alto-1]=0
            solvable = isSolvable(arreglo)
        }
        
        vecinos = buscaVecinos(arreglo)
        
        for (var i = 0; i<cuadros.length;i++){
            cuadros[i].destroy()
        }
        cuadros = []
        for (var i = 0; i<ancho*alto-1;i++){
            cuadros[i] = Qt.createQmlObject('import QtQuick 2.0; \
            Item {\
              clip: true;\
              width: Math.floor(root.width/ancho)-1; height: Math.floor(root.height/alto)-1;\
              x:0; y:0;\
              Image{\
                  source: root.imagen;\
                  width: root.width;\
                  height: root.height;\
                  x: -(('+(i)+')%ancho*Math.floor(root.width/ancho));\
                  y: -(Math.floor(('+(i)+')/ancho))*Math.floor(root.height/alto);\
			  }\
              MouseArea {\
                anchors.fill: parent;\
                onClicked:{rectangleclicked('+i+',arreglo)}\
              }\
              Behavior on x {\
                NumberAnimation {\
                  duration: 300 }\
              }\
              Behavior on y {\
                NumberAnimation { duration: 300 }\
              }\
              Rectangle {\
                color: "transparent";border.color: "black";\
                width: Math.floor(root.width/ancho)-1; height: Math.floor(root.height/alto)-1;\
              }\
            }', fondo,"dynamicSnippet1");
        //print (newObject.x);
        }
        reposiciona(cuadros)
        
//         print(isSolvable(arreglo))
        
    }
    
    function reposiciona(arr){
        for (var i = 0; i<arr.length;i++){
            arr[i].x=(arreglo.indexOf(i+1)%ancho*Math.floor(root.width/ancho))
//             arr[i].width=Math.floor(root.width/ancho)-1
            arr[i].y=(Math.floor(arreglo.indexOf(i+1)/ancho))*Math.floor(root.height/alto)
//             arr[i].height=Math.floor(root.height/alto)-1
        }
//         print(arreglo)
    }
    
	function isSolvable(puzzle){
		    var parity = 0
		    var gridWidth = Math.floor(Math.sqrt(puzzle.length))
		    var row = 0 // the current row we are on
		    var blankRow = 0; // the row with the blank tile

		    for (var i = 0; i < puzzle.length; i++){
		        if (i % gridWidth == 0) { // advance to next row
		            row++;
		        }
		        if (puzzle[i] == 0) { // the blank tile
		            blankRow = row; // save the row on which encountered
		            continue;
		        }
		        for (var j = i + 1; j < puzzle.length; j++)
		        {
		            if (puzzle[i] > puzzle[j] && puzzle[j] != 0)
		            {
		                parity++;
		            }
		        }
		    }

		    if (gridWidth % 2 == 0) { // even grid
		        if (blankRow % 2 == 0) { // blank on odd row; counting from bottom
		            return parity % 2 == 0;
		        } else { // blank on even row; counting from bottom
		            return parity % 2 != 0;
		        }
		    } else { // odd grid
		        return parity % 2 == 0;
		    }
	}
	
	function rectangleclicked(j,arreglo){
        var i=arreglo.indexOf(j+1)
        if (!vecinos[i]){
			pasos+=1;
            arreglo[arreglo.indexOf(0)]=arreglo[i]
            arreglo[i]=0
            vecinos = buscaVecinos(arreglo)
            reposiciona(cuadros)
        }
        if(isordered(arreglo)){covertura.visible=true}
    }
    
    function isordered(arr,ceroend){
        ceroend = ceroend || 1
        var gane=true
        for (var i = 0; i<ancho*alto-1-ceroend;i++){
            if(arr[i+1]<arr[i]){gane=false}
        }
        if(ceroend){
            if(arr[ancho*alto-1] && arr[ancho*alto-1]<arr[ancho*alto-2]){
                gane=false
            }
        }
        if(gane){//print("Gane")
            return true
        }else{
            return false
        }
    }

    
    Rectangle {
        id: fondo
        width: root.width; height: root.height
        color: "transparent"
        border.color:"black"
        border.width:1
        clip: true
        
        
        onWidthChanged:{reposiciona(cuadros)}
        onHeightChanged:{reposiciona(cuadros)}
        
    
        MouseArea {
            anchors.fill: parent
            onClicked: {//dir.ls("./")/************/
            }
        }
        
        Rectangle {
            id: covertura
            width: root.width; height: root.height
            color: "lightgray"
            border.color:"red"
            border.width:3
            z:1000
            
            visible:false
            
            opacity: visible?0.85:0.0;
            Behavior on opacity{ 
                NumberAnimation { duration: 700;easing.type:Easing.InExpo}
                
            }
            
            Image{
		          source: root.imagen
		          width: fondo.width
		          height: fondo.height
		          x: 0
		          y: 0
		    }
            
            Text{
                text:"YOU WIN\nin "+pasos+" steps\n\nClick to restart";
                horizontalAlignment:Text.AlignHCenter; 
                verticalAlignment:Text.AlignVCenter;
                width:parent.width;
                height:parent.height; 
                color: "white"
                styleColor : "red"
//                 font.bold : true
                style: Text.Outline
                font.letterSpacing: 1
                elide: Text.ElideMiddle
                font.weight: Font.ExtraBold
               font.pointSize: 12
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
//                     covertura.visible=false
                    inicializar()
                }
            }
        }
        
        

        
    }
    PlasmaCore.DataSource {
        id: dir
        engine: "filebrowser"
        //connectedSources: ["./"]
        onNewData: {disconnectSource(sourceName);            
            print(data["files.visible"].filter(/./.test.bind(new RegExp(extensions.join("$|")+"$"))));
            customimages = data["files.visible"].filter(/./.test.bind(new RegExp(extensions.join("$|")+"$")));
        }
        function ls(directorio){connectSource(directorio);}/*********/
    }


  
  
}
