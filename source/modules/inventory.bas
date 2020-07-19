#include once "inc/inventory.bi"
#include once "file.bi"

DECLARE SUB LoadSids (filename AS STRING)
DECLARE SUB LoadNames (filename as string)

type UseType
    dim toUse as string
    dim useCommand as string
    dim item as string
    dim itemQty as string
    dim discard as string
    dim message as string
end type

REDIM SHARED InventoryItems(0) AS InventoryType
REDIM SHARED ItemSids(0) AS STRING
redim shared ItemShortNames(0) as string
redim shared ItemLongNames(0) as string
DIM SHARED InventorySize AS INTEGER
dim shared VisibleSize as integer

dim shared UseItemId as integer
dim shared UseItemQty as integer
dim shared UseItemMessage as string
dim shared UseItemDiscard as integer

const DATA_DIR = "data/"

function Inventory_Add (id as integer, qty as integer, max as integer = -1, slot as integer = -1) as integer
    
    dim i as integer
    dim added as integer

    added = 0
    
    if slot > -1 then
        if (slot >= 0) and (slot < InventorySize) then
            InventoryItems(slot).id = id
            InventoryItems(slot).qty = qty
            InventoryItems(slot).max = max
            InventoryItems(slot).slot = slot
            added = 1
        else
            return InventoryErr_OUTOFBOUNDS
        end if
    else
        for i = 0 to VisibleSize - 1
            if InventoryItems(i).id = 0 then
                InventoryItems(i).id = id
                InventoryItems(i).qty = qty
                InventoryItems(i).max = max
                InventoryItems(i).slot = i
                added = 1
                exit for
            end if
        next i
    end if
    
    if added then
        return 0
    else
        return InventoryErr_NOVACANTSLOT
    end if
    
end function

function Inventory_AddHidden (id as integer, qty as integer, max as integer = -1) as integer
    
    dim i as integer
    dim added as integer

    added = 0
    for i = VisibleSize to InventorySize - 1
        if InventoryItems(i).id = 0 then
            InventoryItems(i).id = id
            InventoryItems(i).qty = qty
            InventoryItems(i).max = max
            InventoryItems(i).slot = i
            added = 1
            exit for
        end if
    next i
    
    if added then
        return 0
    else
        return InventoryErr_NOVACANTSLOT
    end if
    
end function

function Inventory_AddQty (slot as integer, qty as integer) as integer
    
    if (slot >= 0) and (slot < InventorySize) then
        InventoryItems(slot).qty = InventoryItems(slot).qty + qty
        if (InventoryItems(slot).max >= -1) and (InventoryItems(slot).qty > InventoryItems(slot).max) then
            InventoryItems(slot).qty = InventoryItems(slot).max
        end if
    else
        return InventoryErr_OUTOFBOUNDS
    end if
    
    return 0
    
end function

sub Inventory_Clear
    
    dim i as integer
    for i = 0 to InventorySize - 1
        Inventory_ResetItem InventoryItems(i)
    next i
    
end sub

FUNCTION Inventory_GetErrorMessage(errorId as integer) as string
    
    dim msg as string
    msg = "Invalid error code"
    
    SELECT CASE errorId
    CASE InventoryErr_OUTOFBOUNDS
        msg = "Specified inventory slot is out of bounds"
    CASE InventoryErr_INVALIDSIZE
        msg = "Invalid inventory size (less than zero)"
    CASE InventoryErr_SIZETOOBIG
        msg = "Invalid inventory size (too big)"
    CASE InventoryErr_NOVACANTSLOT
        msg = "No vacant inventory slot available"
    END SELECT
    
    return msg
    
END FUNCTION

function Inventory_HasItem (itemId as integer) as integer
    
    dim i as integer
    
    for i = 0 to InventorySize - 1
        if InventoryItems(i).id = itemId then
            return 1
        end if
    next i
    
    return 0
    
end function

sub Inventory_GetItem (byref item as InventoryType, id as integer)
    
    dim i as integer
    
    for i = 0 to InventorySize - 1
        if InventoryItems(i).id = id then
            item = InventoryItems(i)
            exit for
        end if
    next i
    
end sub

function Inventory_GetItemBySlot (byref item as InventoryType, slot as integer) as integer
    
    if (slot >= 0) and (slot < InventorySize) then
        item = InventoryItems(slot)
    else
        return InventoryErr_OUTOFBOUNDS
    end if
    
    return 0
    
end function

function Inventory_GetQty (id as integer) as integer
    
    dim qty as integer
    dim i as integer
    
    for i = 0 to InventorySize - 1
        if InventoryItems(i).id = id then
            qty += InventoryItems(i).qty
        end if
    next i
    
    return qty
    
end function

function Inventory_GetSize () as integer
    
    return InventorySize
    
end function

FUNCTION Inventory_Init (size AS INTEGER, sizeVisible as integer = -1) as integer
    
    DIM i AS INTEGER
    
    if sizeVisible = -1 then
        sizeVisible = size
    end if
    IF (size > 0) AND (size <= INVENTORYMAXSIZE) THEN
        REDIM InventoryItems(size - 1) AS InventoryType
        InventorySize = size
        VisibleSize = sizeVisible
        FOR i = 0 TO InventorySize - 1
            InventoryItems(i).slot = i
            InventoryItems(i).visible = iif(i < sizeVisible, 1, 0)
        NEXT i
        LoadSids "tables/items.txt"
        LoadNames "tables/names.txt"
    ELSE
        IF size <= 0 THEN
            return InventoryErr_INVALIDSIZE
        ELSE
            return InventoryErr_SIZETOOBIG
        END IF
    END IF
    
    return 0
    
END FUNCTION

function Inventory_LoadDescription (itemId as integer) as string
    
    dim shortName as string
    dim longName as string
    dim filename as string
    dim fullpath as string
    dim newLine as string
    dim desc as string
    dim row as string
    dim sid as string
    dim ItemsFile as integer
    dim TextFile as integer
    dim found as integer
    dim id as integer
    dim i as integer
    
    newLine = chr(10)
    
    ItemsFile = freefile
    open DATA_DIR+"tables/descs.txt" for input as ItemsFile
    found = 0
    while not eof(ItemsFile)
        input #ItemsFile, sid
        input #ItemsFile, desc
        id = Inventory_SidToItemId(sid)
        if itemId = id then
            found = 1
            exit while
        end if
    wend
    close ItemsFile
    
    if found then
        if ucase(left(desc, 5)) = "FILE:" then
            filename = trim(right(desc, len(desc)-5))
            fullpath = DATA_DIR+"tables/files/"+filename
            desc = ""
            if fileexists(fullpath) then
                TextFile = freefile
                if open(fullpath for input as TextFile) then
                    desc = "Error opening file "+filename
                    desc += newLine+newLine
                    desc += "Err code "+str(err)
                else
                    while not eof(TextFile)
                        line input #TextFile, row
                        desc += iif(len(desc),newLine,"")+row
                    wend
                    close TextFile
                end if
            else
                desc = "File not found "+filename
            end if
        end if
        return desc
    else
        return ""
    end if
    
end function

SUB Inventory_RefreshNames
    
    DIM ItemsFile AS INTEGER
    DIM found AS INTEGER
    DIM item AS INTEGER
    DIM id AS INTEGER
    DIM i AS INTEGER
    
    DIM sid AS STRING
    DIM shortName AS STRING
    DIM longName AS STRING
    
    ItemsFile = FREEFILE
    OPEN DATA_DIR+"tables/names.txt" FOR INPUT AS ItemsFile
    FOR i = 0 TO InventorySize - 1
        item = InventoryItems(i).id
        found = 0
        SEEK ItemsFile, 1
        DO WHILE NOT EOF(ItemsFile)
            INPUT #ItemsFile, sid
            INPUT #ItemsFile, shortName
            INPUT #ItemsFile, longName
            id = Inventory_SidToItemId(sid)
            IF item = id THEN
                found = 1
                EXIT DO
            END IF
        LOOP
        IF found THEN
            InventoryItems(i).id = id
            InventoryItems(i).shortName = shortName
            InventoryItems(i).longName = longName
            InventoryItems(i).slot = i
        ELSE
            InventoryItems(i).id = item
            InventoryItems(i).shortName = "Item ID: " + LTRIM(STR(item))
            InventoryItems(i).longName = "Item ID: " + LTRIM(STR(item))
            InventoryItems(i).slot = i
        END IF
    NEXT i
    CLOSE ItemsFile
    
END SUB

FUNCTION Inventory_SidToItemId (sid AS STRING) as integer
    
    DIM id AS INTEGER
    DIM bound AS INTEGER
    
    bound = UBOUND(ItemSids)
    
    sid = UCASE(LTRIM(RTRIM(sid)))
    
    FOR id = 0 TO bound
        IF ItemSids(id) = sid THEN
            return id
        END IF
    NEXT id
    
    return -1
    
END FUNCTION

sub Inventory_RemoveItem (byref item as InventoryType)
    
    dim slot as integer
    
    slot = item.slot
    if (slot >= 0) and (slot < InventorySize) then
        Inventory_ResetItem InventoryItems(slot)
    end if
    
end sub

sub Inventory_ResetItem (byref item as InventoryType)
    
    item.id  = 0
    item.qty = 0
    item.max = -1
    item.shortName  = "Empty"
    item.longName   = "Empty"
    
end sub

SUB LoadSids (filename AS STRING)
    
    DIM File AS INTEGER
    DIM id AS INTEGER
    DIM sid AS STRING
    DIM maxid AS INTEGER
    
    maxid = 0
    
    File = FREEFILE
    OPEN DATA_DIR+filename FOR INPUT AS File
    DO WHILE NOT EOF(File)
        INPUT #File, id, sid
        IF id > maxid THEN
            maxid = id
        END IF
    LOOP
    REDIM ItemSids(maxid) AS STRING
    SEEK File, 1
    DO WHILE NOT EOF(File)
        INPUT #File, id, sid
        sid = UCASE(LTRIM(RTRIM(sid)))
        if len(sid) then
            ItemSids(id) = sid
        end if
    LOOP
    CLOSE File
    
END SUB

SUB LoadNames (filename as string)
    
    DIM ItemsFile AS INTEGER
    DIM sid AS STRING
    DIM shortName AS STRING
    DIM longName AS STRING
    dim max as integer
    dim id as integer
    
    max = 0
    ItemsFile = FREEFILE
    OPEN DATA_DIR+filename FOR INPUT AS ItemsFile
    DO WHILE NOT EOF(ItemsFile)
        INPUT #ItemsFile, sid, shortName, longName
        id = Inventory_SidToItemId(sid)
        if id > max then max = id
    LOOP
    redim ItemShortNames(max) as string
    redim ItemLongNames(max) as string
    SEEK ItemsFile, 1
    DO WHILE NOT EOF(ItemsFile)
        INPUT #ItemsFile, sid, shortName, longName
        id = Inventory_SidToItemId(sid)
        if id >= 0 then
            ItemShortNames(id) = ucase(trim(shortName))
            ItemLongNames(id) = ucase(trim(longName))
        end if
    LOOP
    CLOSE ItemsFile
    
END SUB

function Inventory_Use (itemId as integer) as integer

    dim _data as UseType
    dim ItemsFile as integer
    dim toUseId as integer
    dim itemTotest as integer
    dim qtyToTest as integer
    dim item as InventoryType
    dim maxqty as integer
    dim qty as integer
    dim prc as integer
    
    UseItemId = 0
    UseItemQty = 0
    UseItemMessage = ""
    UseItemDiscard = 0
        
    ItemsFile = freefile
    open DATA_DIR+"tables/uses.txt" for input as ItemsFile
        
        while not eof(ItemsFile)
            
            input #ItemsFile, _data.toUse, _data.useCommand, _data.item, _data.itemQty, _data.discard, _data.message
            
            _data.toUse      = lcase(trim(_data.toUse))
            _data.useCommand = lcase(trim(_data.useCommand))
            _data.item       = lcase(trim(_data.item))
            _data.itemQty    = lcase(trim(_data.itemQty))
            _data.discard    = lcase(trim(_data.discard))
            _data.message    = lcase(trim(_data.message))
            
            if left(_data.toUse, 1) = "#" then continue while
            
            toUseId = Inventory_SidToItemId(_data.toUse)
            
            if toUseId = itemId then
                UseItemDiscard = iif(_data.discard = "discard" ,1 ,0)
                select case _data.useCommand
                case "add", "use"
                    UseItemId = Inventory_SidToItemId(_data.item)
                    Inventory_ResetItem item
                    Inventory_GetItem item, UseItemId
                    maxqty = iif(item.max > -1, item.max, 1)
                    if left(_data.itemQty, 1) = "p" then
                        _data.itemQty = right(_data.itemQty, len(_data.itemQty)-1)
                        prc = val(_data.itemQty)
                        UseItemQty = int((maxqty*prc)/100)
                    else
                        qty = val(_data.itemQty)
                        UseItemQty = iif(_data.itemQty="max", maxqty, qty)
                    end if
                    UseItemMessage = _data.message
                    return 1
                case "eq"
                    item.id = -1
                    itemToTest = Inventory_SidToItemId(_data.item)
                    Inventory_GetItem item, itemToTest
                    qtyToTest  = iif(_data.itemQty="max",item.max,val(_data.itemQty))
                    if Inventory_GetQty(item.id) = qtyToTest then
                        UseItemMessage = _data.message
                        return 0
                    end if
                case "neq"
                    itemToTest = Inventory_SidToItemId(_data.item)
                    item.qty = -1
                    Inventory_GetItem item, itemToTest
                    qtyToTest  = iif(_data.itemQty="max",item.max,val(_data.itemQty))
                    if Inventory_GetQty(item.id) <> qtyToTest then
                        UseItemMessage = _data.message
                        return 0
                    end if
                case "has"
                    item.id = -1
                    itemToTest = Inventory_SidToItemId(_data.item)
                    Inventory_GetItem item, itemToTest
                    qtyToTest  = val(_data.itemQty)
                    if ((item.id > -1) and (qtyToTest = 1)) or ((item.id = -1) and (qtyToTest = 0)) then
                        UseItemMessage = _data.message
                        return 0
                    end if
                end select
            end if
        wend
        
    close ItemsFile
    
    return -1

end function

function Inventory_GetUseItem() as integer
    
    return UseItemId
    
end function

function Inventory_GetUseQty() as integer
    
    return UseItemQty
    
end function

function Inventory_GetUseMessage() as string
    
    return UseItemMessage
    
end function

function Inventory_GetUseItemDiscard() as integer
    
    return UseItemDiscard
    
end function 

function Inventory_GetShortName(id as integer) as string
    dim bound as integer
    bound = UBOUND(ItemShortNames)
    if id >= 0 and id <= bound then
        return ItemShortNames(id)
    end if
    return "OUT OF BOUNDS"
end function

function Inventory_GetLongName(id as integer) as string
    dim bound as integer
    bound = UBOUND(ItemLongNames)
    if id >= 0 and id <= bound then
        return ItemLongNames(id)
    end if
    return "OUT OF BOUNDS"
end function

function Inventory_GetSid(id as integer) as string
    dim bound as integer
    bound = UBOUND(ItemSids)
    if id >= 0 and id <= bound then
        return ItemSids(id)
    end if
    return "OUT OF BOUNDS"
end function

function Inventory_GetMaxId() as integer
    return ubound(ItemSids)
end function

FUNCTION Inventory_Mix(itemId0 AS INTEGER, itemId1 AS INTEGER, resultMixMsg AS STRING) as integer
    
    DIM MixesFile AS INTEGER
    DIM found AS INTEGER
    DIM sid0 AS STRING
    DIM sid1 AS STRING
    DIM resultSid AS STRING
    DIM resultMsg AS STRING
    
    DIM char AS STRING * 1
    DIM col  AS STRING
    DIM row  AS STRING
    
    dim id0 as integer
    dim id1 as integer
    dim n as integer
    
    MixesFile = FREEFILE
    OPEN DATA_DIR+"tables/mixes.txt" FOR INPUT AS MixesFile
    found = 0
    DO WHILE NOT EOF(MixesFile)
        LINE INPUT #MixesFile, row
        sid0 = ""
        sid1 = ""
        resultSid = ""
        resultMsg = ""
        col = ""
        FOR n = 1 TO LEN(row)
            char = MID(row, n, 1)
            IF (char = ",") OR (n = LEN(row)) THEN
                col = LTRIM(RTRIM(col))
                IF LEFT(col, 1) = CHR(34) THEN
                    col = RIGHT(col, LEN(col)-1)
                END IF
                IF RIGHT(col, 1) = CHR(34) THEN
                    col = LEFT(col, LEN(col)-1)
                END IF
                IF sid0 = "" THEN
                    sid0 = col
                ELSEIF sid1 = "" THEN
                    sid1 = col
                ELSEIF resultSid = "" THEN
                    resultSid = col
                ELSEIF resultMsg = "" THEN
                    resultMsg = col
                END IF
                col = ""
            ELSE
                col = col + char
            END IF
        NEXT n
        id0 = Inventory_SidToItemId(sid0)
        id1 = Inventory_SidToItemId(sid1)
        IF ((itemId0 = id0) AND (itemId1 = id1)) OR ((itemId0 = id1) AND (itemId1 = id0)) THEN
            found = 1
            EXIT DO
        END IF
    LOOP
    CLOSE MixesFile

    IF found THEN
        resultMixMsg   = resultMsg
        return Inventory_SidToItemId(resultSid)
    ELSE
        resultMixMsg   = "I cannot mix these two items"
        return -1
    END IF
    
END FUNCTION

sub Inventory_PopulateItem(byref item as InventoryType, byval id as integer)
    
    Inventory_ResetItem item
    item.id = id
    item.shortName = Inventory_GetShortName(id)
    item.longName = Inventory_GetLongName(id)
    
end sub
