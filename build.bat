@ECHO OFF
rem set path to add qb folder

rem set path=%path%;C:\DOWNLO~1\QB45 >> log\build.log
rem copy tasm.exe to source folder
set qbpath=C:\DOWNLO~1\QB45

cd source

copy %qbpath%\lib\qb.lib     lib\qb.lib
copy %qbpath%\lib\bcom45.lib lib\bcom45.lib
copy %qbpath%\lib\bqlb45.lib lib\bqlb45.lib

mkdir log >> log\build.log
mkdir lib >> log\build.log

del lib\ld2.qlb >> log\build.log
del lib\ld2ns.qlb >> log\build.log
del lib\ld2ws.qlb >> log\build.log
del lib\ld2gfx.lib >> log\build.log
del lib\ds4qbpp.lib >> log\build.log
del lib\ld2snd.lib >> log\build.log
del lib\nosound.lib >> log\build.log

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

echo "bc ld2snd.bas/o/t/c:512;" >> ..\log\build.log
bc ld2snd.bas/o/t/c:512; >> ..\log\build.log
echo "lib ld2snd.lib ld2snd.obj," >> ..\log\build.log
lib ld2snd.lib ld2snd.obj, >> ..\log\build.log

echo "cd .." >> ..\log\build.log
cd .. >> log\build.log

echo "copy inc\ds4qbpp.lib lib\ds4qbpp.lib" >> log\build.log
copy inc\ds4qbpp.lib lib\ds4qbpp.lib >> log\build.log
echo "del inc\ds4qbpp.lib" >> log\build.log
del inc\ds4qbpp.lib >> log\build.log
echo "copy inc\ds4qbpp.obj ." >> log\build.log
copy inc\ds4qbpp.obj . >> log\build.log
echo "del inc\ds4qbpp.obj" >> log\build.log
del inc\ds4qbpp.obj >> log\build.log

echo "link /q ld2gfx.obj+ds4qbpp.obj,lib\ld2.qlb,,lib\qb.lib+lib\bqlb45.lib" >> log\build.log
link /q ld2gfx.obj+ds4qbpp.obj,lib\ld2.qlb,,lib\qb.lib+lib\bqlb45.lib >> log\build.log

echo "copy inc\nosound.lib lib\nosound.lib" >> log\build.log
copy inc\nosound.lib lib\nosound.lib >> log\build.log
echo "del inc\nosound.lib" >> log\build.log
del inc\nosound.lib >> log\build.log
echo "copy inc\nosound.obj ." >> log\build.log
copy inc\nosound.obj . >> log\build.log
echo "del inc\nosound.obj" >> log\build.log
del inc\nosound.obj >> log\build.log

echo "link /q ld2gfx.obj+nosound.obj,lib\ld2ns.qlb,,lib\qb.lib+lib\bqlb45.lib" >> log\build.log
link /q ld2gfx.obj+nosound.obj,lib\ld2ns.qlb,,lib\qb.lib+lib\bqlb45.lib >> log\build.log

echo "copy inc\ld2snd.lib lib\ld2snd.lib" >> log\build.log
copy inc\ld2snd.lib lib\ld2snd.lib >> log\build.log
echo "del inc\ld2snd.lib" >> log\build.log
del inc\ld2snd.lib >> log\build.log
echo "copy inc\ld2snd.obj ." >> log\build.log
copy inc\ld2snd.obj . >> log\build.log
echo "del inc\ld2snd.obj" >> log\build.log
del inc\ld2snd.obj >> log\build.log

copy lib\bcom45.lib .
copy lib\qb.lib .
copy lib\ld2gfx.lib .
copy lib\nosound.lib .
copy lib\ld2snd.lib .
copy lib\mse_qb.lib .

echo "link /q ld2gfx.obj+ld2snd.obj lib\qb.lib,lib\ld2ws.qlb,,lib\bqlb45.lib+lib\mse_qb.lib" >> log\build.log
link /q ld2gfx.obj+ld2snd.obj lib\qb.lib,lib\ld2ws.qlb,,lib\bqlb45.lib+lib\mse_qb.lib >> log\build.log

echo "bc mobs.bas mobs.obj,," >> ..\log\build.log
bc mobs.bas mobs.obj,, >> ..\log\build.log
echo "bc inventry.bas inventry.obj,," >> ..\log\build.log
bc inventry.bas inventry.obj,, >> ..\log\build.log
echo "bc scene.bas scene.obj,," >> ..\log\build.log
bc scene.bas scene.obj,, >> ..\log\build.log
echo "bc ld2e.bas ld2e.obj,," >> log\build.log
bc ld2e.bas ld2e.obj,, >> log\build.log
echo "bc ld2.bas ld2.obj,," >> log\build.log
bc ld2.bas ld2.obj,, >> log\build.log
echo "bc title.bas title.obj,," >> log\build.log
bc title.bas title.obj,, >> log\build.log
rem echo "link /ex /noe /nod:brun45.lib ld2e.obj+ld2.obj+title.obj,nosound.exe,,lib\bcom45.lib+lib\qb.lib+lib\ld2gfx.lib" >> log\build.log
rem link /ex /noe /nod:brun45.lib ld2e.obj+ld2.obj+title.obj,nosound.exe,,lib\bcom45.lib+lib\qb.lib+lib\ld2gfx.lib >> log\build.log

rename ld2e.obj e.obj
rename title.obj t.obj
rename mobs.obj m.obj
rename inventry.obj i.obj
rename scene.obj s.obj

rem echo "link /ex /noe /nod:brun45.lib ld2e.obj+ld2.obj+title.obj,nosound.exe,,bcom45.lib+qb.lib+ld2gfx.lib+ld2snd.lib+lib\mse_qb.lib" >> log\build.log
rem link /ex /noe /nod:brun45.lib ld2e.obj+ld2.obj+title.obj,nosound.exe,,bcom45.lib+qb.lib+ld2gfx.lib+ld2snd.lib+lib\mse_qb.lib >> log\build.log
echo "link /ex /noe /nod:brun45.lib ld2.obj+e.obj+t.obj+m.obj+i.obj+s.obj,ld2.exe,,bcom45.lib+qb.lib+ld2gfx.lib+ld2snd.lib+mse_qb.lib"
link /ex /noe /nod:brun45.lib ld2.obj+e.obj+t.obj+m.obj+i.obj+s.obj,ld2.exe,,bcom45.lib+qb.lib+ld2gfx.lib+ld2snd.lib+mse_qb.lib

del edit.map
del edit.obj
del ld2.map
del ld2.obj
del e.obj
del t.obj
del m.obj
del i.obj
del s.obj
del ld2gfx.obj
del ds4qbpp.obj
del ld2ns.map
del ld2ws.map
rem del nosound.map
del nosound.obj
del ld2snd.obj

del bcom45.lib
del qb.lib
del ld2gfx.lib
del nosound.lib
del ld2snd.lib
del mse_qb.lib

del inventry.lst
del ld2.lst
del ld2e.lst
del mobs.lst
del scene.lst
del title.lst

cd ..

copy source\ld2.exe .
copy source\edit.exe .

del source\ld2.exe
del source\edit.exe
