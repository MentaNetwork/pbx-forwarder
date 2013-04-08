# PBX Forwarder beta


### Objetivos

* Forwardear la extensión telefónica a un determinado número automaticamente al apagar la computadora, y eliminar dicho forwardeo al prenderla.
* Ejercitar Objective-C, Cocoa, XCode, Applescript, y Python.


### Componentes

* Panel de preferencias para administrar la información del forwarding desde la aplicación de Preferencias de OSX.
* Aplicación como servicio de sistema para remover y agregar el forwarding al prender y apagar la mac respectivamente.
* Scripts de compilación y creación de archivos distribución.


### Compilación

Para uso local:

```
$ fab build
$ fab install
```

Para distribución en .dmg:

```
$ fab dist
$ open dist
```


### Instalación y uso

* Abrir el PBXForwarder.dmg y arrastrar a la derecha los elementos de la izquierda, a los directorios de Aplicaciones y Páneles de preferencias.
* __No abrir ninguna de las dos aplicaciones directamente__.
* Abrir la aplicación de Preferencias de OSX y luego el panel PBX Forwarder que aparecerá en la parte inferior.
* Capturar número de extensión, número de forwarding, y password de pbx.menta.
* Activar el forwarding con el botón.

Habiendo hecho lo anterior, se creará un pseudo servicio de sistema que creará el forwarding al apagar el equipo, y lo removerá al prenderlo.

Si algo no funciona, se deberá inspeccionar el log principal dentro la aplicación Consola, filtrando con la cadena "pbx".



