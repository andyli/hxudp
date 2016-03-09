all: test

native:
	cd project && haxelib run hxcpp build.xml
	cd project && haxelib run hxcpp build.xml -DHXCPP_M64

android:
	cd project && haxelib run hxcpp build.xml -Dandroid

ios:
	cd project && haxelib run hxcpp build.xml -Dios
	cd project && haxelib run hxcpp build.xml -Dios -DHXCPP_ARMV7
	cd project && haxelib run hxcpp build.xml -Dios -Dsimulator

test: native
	haxe compile.hxml

haxelib:
	zip -r hxudp.zip ndll
	cd src && zip -r ../hxudp.zip hxudp
	zip hxudp.zip haxelib.xml include.nmml
	haxelib local hxudp.zip
