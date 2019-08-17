@ECHO OFF
rem set path to add qb folder

rem set path=%path%;C:\DOWNLO~1\QB45 >> log\build.log
rem copy tasm.exe to source folder
set qbpath=C:\DOWNLO~1\QB45
copy %qbpath%\lib\qb.lib     lib\qb.lib
copy %qbpath%\lib\bcom45.lib lib\bcom45.lib
copy %qbpath%\lib\bqlb45.lib lib\bqlb45.lib

mkdir log >> log\build.log
mkdir lib >> log\build.log

mkdir gfx >> log\build.log
mkdir rooms >> log\build.log
mkdir sfx >> log\build.log
mkdir soundsys >> log\build.log

copy ..\gfx gfx >> log\build.log
copy ..\rooms rooms >> log\build.log
copy ..\sfx sfx >> log\build.log
copy ..\soundsys soundsys >> log\build.log
copy ..\setup.exe setup.exe >> log\build.log

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

echo "link /q ld2gfx.obj+ld2snd.obj lib\qb.lib,lib\ld2ws.qlb,,lib\bqlb45.lib+lib\mse_qb.lib" >> log\build.log
link /q ld2gfx.obj+ld2snd.obj lib\qb.lib,lib\ld2ws.qlb,,lib\bqlb45.lib+lib\mse_qb.lib >> log\build.log

cd inc
echo "bc mobs.bas/o/t/c:512;" >> ..\log\build.log
bc mobs.bas/o/t/c:512; >> ..\log\build.log
cd ..
copy inc\mobs.obj .
del  inc\mobs.obj
echo "bc ld2e.bas/o/t/c:512;" >> log\build.log
bc ld2e.bas/o/t/c:512; >> log\build.log
echo "bc ld2.bas/o/t/s/c:512;" >> log\build.log
bc ld2.bas/o/t/s/c:512; >> log\build.log
echo "bc title.bas/o/t/c:512;" >> log\build.log
bc title.bas/o/t/c:512; >> log\build.log
rem echo "link /ex /noe /nod:brun45.lib ld2e.obj+ld2.obj+title.obj,nosound.exe,,lib\bcom45.lib+lib\qb.lib+lib\ld2gfx.lib" >> log\build.log
rem link /ex /noe /nod:brun45.lib ld2e.obj+ld2.obj+title.obj,nosound.exe,,lib\bcom45.lib+lib\qb.lib+lib\ld2gfx.lib >> log\build.log


rem echo "link /ex /noe /nod:brun45.lib ld2e.obj+ld2.obj+title.obj,nosound.exe,,bcom45.lib+qb.lib+ld2gfx.lib+ld2snd.lib+lib\mse_qb.lib" >> log\build.log
rem link /ex /noe /nod:brun45.lib ld2e.obj+ld2.obj+title.obj,nosound.exe,,bcom45.lib+qb.lib+ld2gfx.lib+ld2snd.lib+lib\mse_qb.lib >> log\build.log
echo "link /ex /noe /nod:brun45.lib ld2.obj+ld2e.obj+title.obj+mobs.obj,ld2.exe,,bcom45.lib+qb.lib+ld2gfx.lib+ld2snd.lib+lib\mse_qb.lib"
link /ex /noe /nod:brun45.lib ld2.obj+ld2e.obj+title.obj+mobs.obj,ld2.exe,,bcom45.lib+qb.lib+ld2gfx.lib+ld2snd.lib+lib\mse_qb.lib

del edit.map
del edit.obj
del ld2.map
del ld2.obj
del ld2e.obj
del title.obj
del ld2gfx.obj
del ds4qbpp.obj
del ld2ns.map
del ld2ws.map
del nosound.map
del nosound.obj
del ld2snd.obj
del mobs.obj

del bcom45.lib
del qb.lib
del ld2gfx.lib
del nosound.lib
del ld2snd.lib

