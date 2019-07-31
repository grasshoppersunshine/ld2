@ECHO OFF
rem set path to add qb folder

set path=%path%;C:\DOWNLO~1\QB45
mkdir log
mkdir lib

del lib\ld2.qlb
del lib\ld2gfx.lib
del lib\ds4qbpp.lib

echo "tasm /os ld2gfx.asm" > log\build.log
tasm /os ld2gfx.asm >> log\build.log

echo "lib lib\ld2gfx.lib ld2gfx.obj," >> log\build.log
lib lib\ld2gfx.lib ld2gfx.obj, >> log\build.log

echo "bc edit.bas/o/t/c:512;" >> log\build.log
bc edit.bas/o/t/c:512; >> log\build.log

echo "link /ex /noe /nod:brun45.lib edit.obj,edit.exe,,lib\bcom45.lib+lib\ld2gfx.lib" >> log\build.log
link /ex /noe /nod:brun45.lib edit.obj,edit.exe,,lib\bcom45.lib+lib\ld2gfx.lib >> log\build.log

echo "cd inc" >> log\build.log
cd inc >> log\build.log

echo "bc ds4qbpp.bas/o/t/c:512;" >> ..\log\build.log
bc ds4qbpp.bas/o/t/c:512; >> ..\log\build.log
echo "lib ds4qbpp.lib ds4qbpp.obj," >> ..\log\build.log
lib ds4qbpp.lib ds4qbpp.obj, >> ..\log\build.log

echo "bc nosound.bas/o/t/c:512;" >> ..\log\build.log
bc nosound.bas/o/t/c:512; >> ..\log\build.log
echo "lib nosound.lib nosound.obj," >> ..\log\build.log
lib nosound.lib nosound.obj, >> ..\log\build.log

echo "cd .." >> ..\log\build.log
cd .. >> log\build.log

echo "copy inc\ds4qbpp.lib lib\ds4qbpp.lib" >> log\build.log
copy inc\ds4qbpp.lib lib\ds4qbpp.lib >> log\build.log
echo "inc\ds4qbpp.lib" >> log\build.log
del inc\ds4qbpp.lib >> log\build.log
echo "inc\ds4qbpp.obj" >> log\build.log
echo "copy inc\ds4qbpp.obj ." >> log\build.log
copy inc\ds4qbpp.obj . >> log\build.log
del inc\ds4qbpp.obj >> log\build.log

echo "link /q ld2gfx.obj+ds4qbpp.obj lib\qb.lib,lib\ld2.qlb,,lib\bqlb45.lib" >> log\build.log
link /q ld2gfx.obj+ds4qbpp.obj lib\qb.lib,lib\ld2.qlb,,lib\bqlb45.lib >> log\build.log

echo "copy inc\nosound.lib lib\nosound.lib" >> log\build.log
copy inc\nosound.lib lib\nosound.lib >> log\build.log
echo "inc\nosound.lib" >> log\build.log
del inc\nosound.lib >> log\build.log
echo "inc\nosound.obj" >> log\build.log
echo "copy inc\nosound.obj ." >> log\build.log
copy inc\nosound.obj . >> log\build.log
del inc\nosound.obj >> log\build.log

echo "link /q ld2gfx.obj+nosound.obj lib\qb.lib,lib\ld2ns.qlb,,lib\bqlb45.lib" >> log\build.log
link /q ld2gfx.obj+nosound.obj lib\qb.lib,lib\ld2ns.qlb,,lib\bqlb45.lib >> log\build.log

echo "bc ld2e.bas/o/t/c:512;" >> log\build.log
bc ld2e.bas/o/t/c:512; >> log\build.log
echo "bc ld2.bas/o/t/s/c:512;" >> log\build.log
bc ld2.bas/o/t/s/c:512; >> log\build.log
echo "bc title.bas/o/t/c:512;" >> log\build.log
bc title.bas/o/t/c:512; >> log\build.log
echo "link /ex /noe /nod:brun45.lib ld2e.obj+ld2.obj+title.obj,ld2.exe,,lib\bcom45.lib+lib\qb.lib+lib\ld2gfx.lib+lib\ds4qbpp.lib" >> log\build.log
link /ex /noe /nod:brun45.lib ld2e.obj+ld2.obj+title.obj,ld2.exe,,lib\bcom45.lib+lib\qb.lib+lib\ld2gfx.lib+lib\ds4qbpp.lib >> log\build.log
echo "link /ex /noe /nod:brun45.lib ld2e.obj+ld2.obj+title.obj,nosound.exe,,lib\bcom45.lib+lib\qb.lib+lib\ld2gfx.lib+lib\nosound.lib" >> log\build.log
link /ex /noe /nod:brun45.lib ld2e.obj+ld2.obj+title.obj,nosound.exe,,lib\bcom45.lib+lib\qb.lib+lib\ld2gfx.lib+lib\nosound.lib >> log\build.log

del edit.map
del edit.obj
del ld2.map
del ld2.obj
del ld2e.obj
del title.obj
del ld2gfx.obj
del ds4qbpp.obj
del ld2ns.map
del nosound.map
del nosound.obj
