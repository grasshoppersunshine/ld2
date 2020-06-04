#include once "dir.bi"

const GAME_TITLE = "Larry the Dinosaur II"
const MAIN_PROGRAM = "ld2.exe"

type ArgsType
private:
    redim _paths(0) as string
    redim _params(0) as string
    _numArgs as integer
    _idx as integer
    _maxPathLen as integer
public:
    declare sub init()
    declare sub add(path as string, params as string)
    declare function getNext() as integer
    declare function getPath() as string
    declare function getParams() as string
    declare function getArgString() as string
    declare function getPercent() as integer
    declare function getPaddedPath() as string
end type
sub ArgsType.init()
    redim this._paths(0) as string
    redim this._params(0) as string
    this._numArgs = 0
    this._idx = -1
    this._maxPathLen = 0
end sub
sub ArgsType.add(path as string, params as string)
    dim length as integer
    dim n as integer
    n = this._numArgs
    redim preserve this._paths(n+1)
    redim preserve this._params(n+1)
    this._paths(n) = path
    this._params(n) = params
    this._numArgs += 1
    length = len(path)
    if length > this._maxPathLen then
        this._maxPathLen = length
    end if
end sub
function ArgsType.getNext() as integer
    this._idx += 1
    if this._idx < this._numArgs then
        return 1
    else
        return 0
    end if
end function
function ArgsType.getPath() as string
    if (this._idx >= 0) and (this._idx < this._numArgs) then
        return this._paths(this._idx)
    else
        return ""
    end if
end function
function ArgsType.getParams() as string
    if (this._idx >= 0) and (this._idx < this._numArgs) then
        return this._params(this._idx)
    else
        return ""
    end if
end function
function ArgsType.getArgString() as string
    if (this._idx >= 0) and (this._idx < this._numArgs) then
        return trim(this._paths(this._idx)+" "+this._params(this._idx))
    else
        return ""
    end if
end function
function ArgsType.getPercent() as integer
    if (this._idx >= 0) and (this._idx < this._numArgs) then
        return int(100 * (this._idx / this._numArgs))
    else
        return 0
    end if
end function
function ArgsType.getPaddedPath() as string
    dim path as string
    if (this._idx >= 0) and (this._idx < this._numArgs) then
        path = this._paths(this._idx)
        return path + string(this._maxPathLen - len(path), " ")
    else
        return string(this._maxPathLen, " ")
    end if
end function

declare sub doArgs(args as ArgsType, pathToFbc as string, title as string = "")
sub doArgs(args as ArgsType, pathToFbc as string, title as string = "")
    dim percent as integer
    dim commandLine as string
    dim s as string
    while args.getNext()
        percent = args.getPercent()
        s = "["
        s += string(int(percent*0.25), "=")
        s += string(25-int(percent*0.25), " ")
        s += "] "
        s += str(percent)+"% "
        print title+" "+s+args.getPaddedPath()+chr(13);
        commandLine = pathToFbc+" "+args.getArgString()
        if shell(commandLine) = -1 then
            print "ERROR while running fbc with: "+commandLine
        end if
    wend
    print title+" ["+string(25,"=")+"] 100% "+args.getPaddedPath()+chr(13)
end sub

function CommandHasArgument(fieldName as string) as integer
    dim arg as string
    dim i as integer
    i = 1
    do
        arg = lcase(command(i))
        if len(arg) = 0 then
            exit do
        end if
        if arg = lcase(fieldName) then
            return 1
        end if
        i += 1
    loop
    return 0
end function

function CommandGetValue(fieldName as string) as string
    dim captureNext as integer
    dim arg as string
    dim i as integer
    captureNext = 0
    i = 1
    do
        arg = lcase(command(i))
        if len(arg) = 0 then
            exit do
        end if
        if captureNext then
            return arg
        elseif arg = lcase(fieldName) then
            captureNext = 1
        end if
        i += 1
    loop
    return ""
end function

dim pathToFbc as string = "fbc"
dim launchAfterBuild as integer
dim launchCommand as string
dim args as ArgsType

if CommandHasArgument("--launch") then
    launchAfterBuild = 1
    launchCommand = CommandGetValue("--launch")
    launchCommand = MAIN_PROGRAM + iif(len(launchCommand), " "+launchCommand, "")
else
    launchAfterBuild = 0
end if

if dir("lib", fbDirectory) <> "lib" then
    mkdir "lib"
end if

print string(72, "-")
print ucase(GAME_TITLE)
print string(72, "-")
if launchAfterBuild then print "Launching after build!"
print "Building game..."
print

args.init
args.add "modules/common.bas"      , "-lib -x lib/libcommon.a"
args.add "modules/mobs.bas"        , "-lib -x lib/libmobs.a"
args.add "modules/inventory.bas"   , "-lib -x lib/libinventory.a"
args.add "modules/palette256.bas"  , "-lib -x lib/libpalette256.a"
args.add "modules/video.bas"       , "-lib -x lib/libvideo.a"
args.add "modules/videobuffer.bas" , "-lib -x lib/libvideobuffer.a"
args.add "modules/videosprites.bas", "-lib -x lib/libvideosprites.a"
args.add "modules/ld2gfx.bas"      , "-lib -x lib/libld2gfx.a"
args.add "modules/sdlsnd.bas"      , "-lib -x lib/libsdlsnd.a"
args.add "modules/ld2snd.bas"      , "-lib -x lib/libld2snd.a"
doArgs args, pathToFbc, ucase("[1/3] dependencies")

args.init
args.add "scene.bas" , "-lib -p lib/ -x lib/libscene.a"
args.add "status.bas", "-lib -p lib/ -x lib/libstatus.a"
args.add "title.bas" , "-lib -p lib/ -x lib/libtitle.a"
args.add "ld2e.bas"  , "-lib -p lib/ -x lib/libld2e.a"
doArgs args, pathToFbc, ucase("[2/3] game modules")

args.init
args.add "ld2.bas", "-w all -p lib/ -exx"
doArgs args, pathToFbc, ucase("[3/3] main program")

print
print string(72, "-")
print "Done!"

if launchAfterBuild then
    print ucase("Starting main program: "+launchCommand)
    shell(launchCommand)
else
    print ucase("Start game with: "+MAIN_PROGRAM)
end if
