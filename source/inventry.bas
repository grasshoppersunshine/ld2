#include once "INC\INVENTRY.BI"
#include once "INC\LD2E.BI"

DECLARE SUB LoadSids (filename AS STRING)

type UseType
    dim toUse as string
    dim useCommand as string
    dim item as string
    dim itemQty as string
    dim message as string
end type

REDIM SHARED InventoryItems(0) AS InventoryType
REDIM SHARED ItemSids(0) AS STRING
DIM SHARED InventorySize AS INTEGER

dim shared UseItemId as integer
dim shared UseItemQty as integer
dim shared UseItemMessage as string

const DATA_DIR = "data/"

FUNCTION Inventory_Add (id AS INTEGER, qty AS INTEGER) as integer
    
    DIM i AS INTEGER
    DIM added AS INTEGER

    added = 0
    FOR i = 0 TO InventorySize - 1
        IF InventoryItems(i).id = 0 THEN
            InventoryItems(i).id = id
            InventoryItems(i).qty = qty
            added = 1
            EXIT FOR
        END IF
    NEXT i
    
    IF added THEN
        return 0
    ELSE
        return InventoryErr_NOVACANTSLOT
    END IF
    
END FUNCTION

FUNCTION Inventory_AddQty (slot AS INTEGER, qty AS INTEGER) as integer
    
    IF (slot >= 0) AND (slot < InventorySize) THEN
        InventoryItems(slot).qty = InventoryItems(slot).qty + qty
    ELSE
        return InventoryErr_OUTOFBOUNDS
    END IF
    
    return 0
    
END FUNCTION

SUB Inventory_Clear
    
    DIM i AS INTEGER
    FOR i = 0 TO InventorySize - 1
        InventoryItems(i).id = 0
        InventoryItems(i).qty = 0
        InventoryItems(i).shortName = "Empty"
        InventoryItems(i).longName = "Empty"
    NEXT i
    
END SUB

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

SUB Inventory_GetItem (item AS InventoryType, id AS INTEGER)
    
    DIM i AS INTEGER
    
    FOR i = 0 TO InventorySize - 1
        IF InventoryItems(i).id = id THEN
            item = InventoryItems(i)
            EXIT FOR
        END IF
    NEXT i
    
END SUB

FUNCTION Inventory_GetItemBySlot (item AS InventoryType, slot AS INTEGER) as integer
    
    IF (slot >= 0) AND (slot < InventorySize) THEN
        item = InventoryItems(slot)
    ELSE
        return InventoryErr_OUTOFBOUNDS
    END IF
    
    return 0
    
END FUNCTION

FUNCTION Inventory_Init (size AS INTEGER) as integer
    
    DIM i AS INTEGER
    
    IF (size > 0) AND (size <= INVENTORYMAXSIZE) THEN
        REDIM InventoryItems(size - 1) AS InventoryType
        InventorySize = size
        FOR i = 0 TO InventorySize - 1
            InventoryItems(i).slot = i
        NEXT i
        LoadSids "tables/items.txt"
    ELSE
        IF size <= 0 THEN
            return InventoryErr_INVALIDSIZE
        ELSE
            return InventoryErr_SIZETOOBIG
        END IF
    END IF
    
    return 0
    
END FUNCTION

FUNCTION Inventory_LoadDescription (itemId AS INTEGER) as string
    
    DIM ItemsFile AS INTEGER
    DIM id AS INTEGER
    DIM sid AS STRING
    DIM shortName AS STRING
    DIM longName AS STRING
    DIM desc AS STRING
    DIM found AS INTEGER
    DIM i AS INTEGER
    
    ItemsFile = FREEFILE
    OPEN DATA_DIR+"tables/descs.txt" FOR INPUT AS ItemsFile
    found = 0
    DO WHILE NOT EOF(ItemsFile)
        INPUT #ItemsFile, sid: IF EOF(ItemsFile) THEN EXIT DO
        INPUT #ItemsFile, desc
        id = Inventory_SidToItemId(sid)
        IF itemId = id THEN
            found = 1
            EXIT DO
        END IF
    LOOP
    CLOSE ItemsFile
    
    IF found THEN
        return desc
    ELSE
        return ""
    END IF
    
END FUNCTION

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
            INPUT #ItemsFile, sid: IF EOF(ItemsFile) THEN EXIT DO
            INPUT #ItemsFile, shortName: IF EOF(ItemsFile) THEN EXIT DO
            INPUT #ItemsFile, longName: IF EOF(ItemsFile) THEN EXIT DO
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
            InventoryItems(i).shortName = "Item ID: " + LTRIM(STR(id))
            InventoryItems(i).longName = "Item ID: " + LTRIM(STR(id))
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

SUB Inventory_RemoveItem (item AS InventoryType)
    
    DIM slot AS INTEGER
    
    slot = item.slot
    IF (slot >= 0) AND (slot < InventorySize) THEN
        item = InventoryItems(slot)
        item.id  = 0
        item.qty = 0
        item.shortName  = "Empty"
        item.longName   = "Empty"
        InventoryItems(slot) = item
    END IF
    
END SUB

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
        ItemSids(id) = UCASE(LTRIM(RTRIM(sid)))
    LOOP
    CLOSE File
    
END SUB

function Inventory_Use (itemId as integer) as integer

    dim _data as UseType
    dim ItemsFile as integer
    dim toUseId as integer
    dim itemTotest as integer
    dim qtyToTest as integer
    dim item as InventoryType
    
    UseItemId = 0
    UseItemQty = 0
    UseItemMessage = ""
        
    ItemsFile = freefile
    open DATA_DIR+"tables/uses.txt" for input as ItemsFile
        
        while not eof(ItemsFile)
            
            input #ItemsFile, _data.toUse, _data.useCommand, _data.item, _data.itemQty, _data.message
            
            _data.toUse      = trim(_data.toUse)
            _data.useCommand = trim(_data.useCommand)
            _data.item       = trim(_data.item)
            _data.itemQty    = trim(_data.itemQty)
            _data.message    = trim(_data.message)
            
            if left(_data.toUse, 1) = "#" then continue while
            
            toUseId = Inventory_SidToItemId(_data.toUse)
            
            if toUseId = itemId then
                select case ucase(_data.useCommand)
                case "ADD"
                    UseItemId = Inventory_SidToItemId(_data.item)
                    UseItemQty = val(_data.itemQty)
                    UseItemMessage = _data.message
                    return 1
                case "EQ"
                    itemToTest = Inventory_SidToItemId(_data.item)
                    qtyToTest  = val(_data.itemQty)
                    Inventory_GetItem item, itemToTest
                    if item.qty = qtyToTest then
                        UseItemMessage = _data.message
                        return 0
                    end if
                case "NEQ"
                    itemToTest = Inventory_SidToItemId(_data.item)
                    qtyToTest  = val(_data.itemQty)
                    Inventory_GetItem item, itemToTest
                    if item.qty <> qtyToTest then
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
