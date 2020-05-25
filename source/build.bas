dim pathToFbc as string = "fbc"
dim args(20) as string

#include once "dir.bi"
if dir("lib", fbDirectory) <> "lib" then
    mkdir "lib"
end if

args(0)  = "common.bas       -lib -x lib/libcommon.a"
args(1)  = "mobs.bas         -lib -x lib/libmobs.a"
args(2)  = "inventry.bas     -lib -x lib/libinventry.a"
args(3)  = "palette256.bas   -lib -x lib/libpalette256.a"
args(4)  = "video.bas        -lib -x lib/libvideo.a"
args(5)  = "videobuffer.bas  -lib -x lib/libvideobuffer.a"
args(6)  = "videosprites.bas -lib -x lib/libvideosprites.a"
args(7)  = "ld2gfx.bas       -lib -x lib/libld2gfx.a"
args(8)  = "sdlsnd.bas       -lib -x lib/libsdlsnd.a"
args(9)  = "ld2snd.bas       -lib -x lib/libld2snd.a"

print "Building independent modules..."
dim i as integer
dim percent as double
dim s as string
for i = 0 to 9
    if shell(pathToFbc+" "+args(i)) = -1 then
        print "ERROR while running fbc with: "+args(i)
    else
        percent = (i/9)
        s = "["
        s += string(int(percent*25), "=")
        s += string(25-int(percent*25), " ")
        s += "] "
        s += str(int(percent*100))+"% "
        print s+left(args(i), 16)+chr(13);
    end if
next i

args(0) = "scene.bas    -lib -p lib/ -x lib/libscene.a"
args(1) = "status.bas   -lib -p lib/ -x lib/libstatus.a"
args(2) = "title.bas    -lib -p lib/ -x lib/libtitle.a"
args(3) = "ld2e.bas     -lib -p lib/ -x lib/libld2e.a"

print ""
print "Building dependent modules..."
for i = 0 to 3
    if shell(pathToFbc+" "+args(i)) = -1 then
        print "ERROR while running fbc with: "+args(i)
    else
        percent = (i/3)
        s = "["
        s += string(int(percent*25), "=")
        s += string(25-int(percent*25), " ")
        s += "] "
        s += str(int(percent*100))+"%"
        print s+chr(13);
    end if
next i

args(0) = "-w all ld2.bas -p lib/ -exx"

print ""
print "Compiling game..."

if shell(pathToFbc+" "+args(0)) = -1 then
    print "ERROR while running fbc with: -w all ld2.bas -p lib/ -exx"
end if
print "Done!"
