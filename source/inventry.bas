REM $INCLUDE: 'INC\INVENTRY.BI'
REM $INCLUDE: 'INC\LD2E.BI'

DECLARE SUB LoadSids (filename AS STRING)
DECLARE FUNCTION Inventory.GetUseMsg$ (itemId AS INTEGER, success AS INTEGER)

REDIM SHARED InventoryItems(0) AS InventoryType
REDIM SHARED ItemSids(0) AS STRING
DIM SHARED InventorySize AS INTEGER

FUNCTION Inventory.Add% (id AS INTEGER, qty AS INTEGER)
    
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
        Inventory.Add% = 0
    ELSE
        Inventory.Add% = InventoryErr.NOVACANTSLOT
    END IF
    
END FUNCTION

FUNCTION Inventory.AddQty% (slot AS INTEGER, qty AS INTEGER)
    
    Inventory.AddQty% = 0
    
    IF (slot >= 0) AND (slot < InventorySize) THEN
        InventoryItems(slot).qty = InventoryItems(slot).qty + qty
    ELSE
        Inventory.AddQty% = InventoryErr.OUTOFBOUNDS
    END IF
    
END FUNCTION

SUB Inventory.Clear
    
    DIM i AS INTEGER
    FOR i = 0 TO InventorySize - 1
        InventoryItems(i).id = 0
        InventoryItems(i).qty = 0
        InventoryItems(i).shortName = "Empty"
        InventoryItems(i).longName = "Empty"
    NEXT i
    
END SUB

FUNCTION Inventory.GetErrorMessage$
    
    Inventory.GetErrMsg$ = "Invalid error code"
    
    SELECT CASE errorId
    CASE InventoryErr.OUTOFBOUNDS
        Inventory.GetErrMsg$ = "Specified inventory slot is out of bounds"
    CASE InventoryErr.INVALIDSIZE
        Inventory.GetErrMsg$ = "Invalid inventory size (less than zero)"
    CASE InventoryErr.SIZETOOBIG
        Inventory.GetErrMsg$ = "Invalid inventory size (too big)"
    CASE InventoryErr.NOVACANTSLOT
        Inventory.GetErrMsg$ = "No vacant inventory slot available"
    END SELECT
    
END FUNCTION

SUB Inventory.GetItem (item AS InventoryType, id AS INTEGER)
    
    DIM i AS INTEGER
    
    FOR i = 0 TO InventorySize - 1
        IF InventoryItems(i).id = id THEN
            item = InventoryItems(i)
            EXIT FOR
        END IF
    NEXT i
    
END SUB

FUNCTION Inventory.GetItemBySlot% (item AS InventoryType, slot AS INTEGER)
    
    Inventory.GetItemBySlot% = 0
    
    IF (slot >= 0) AND (slot < InventorySize) THEN
        item = InventoryItems(slot)
    ELSE
        Inventory.GetItemBySlot% = InventoryErr.OUTOFBOUNDS
    END IF
    
END FUNCTION

FUNCTION Inventory.Init% (size AS INTEGER)
    
    DIM i AS INTEGER
    
    Inventory.Init% = 0
    
    IF (size > 0) AND (size <= INVENTORYMAXSIZE) THEN
        REDIM InventoryItems(size - 1) AS InventoryType
        InventorySize = size
        FOR i = 0 TO InventorySize - 1
            InventoryItems(i).slot = i
        NEXT i
        LoadSids "tables/items.txt"
    ELSE
        IF size <= 0 THEN
            Inventory.Init% = InventoryErr.INVALIDSIZE
        ELSE
            Inventory.Init% = InventoryErr.SIZETOOBIG
        END IF
    END IF
    
END FUNCTION

FUNCTION Inventory.LoadDescription$ (itemId AS INTEGER)
    
    DIM ItemsFile AS INTEGER
    DIM id AS INTEGER
    DIM sid AS STRING
    DIM shortName AS STRING
    DIM longName AS STRING
    DIM desc AS STRING
    DIM found AS INTEGER
    DIM i AS INTEGER
    
    ItemsFile = FREEFILE
    OPEN "tables/descs.txt" FOR INPUT AS ItemsFile
    found = 0
    DO WHILE NOT EOF(ItemsFile)
        INPUT #ItemsFile, sid: IF EOF(ItemsFile) THEN EXIT DO
        INPUT #ItemsFile, desc
        id = Inventory.SidToItemId%(sid)
        IF itemId = id THEN
            found = 1
            EXIT DO
        END IF
    LOOP
    CLOSE ItemsFile
    
    IF found THEN
        Inventory.LoadDescription$ = desc
    ELSE
        Inventory.LoadDescription$ = ""
    END IF
    
END FUNCTION

SUB Inventory.RefreshNames
    
    DIM ItemsFile AS INTEGER
    DIM found AS INTEGER
    DIM item AS INTEGER
    DIM id AS INTEGER
    DIM i AS INTEGER
    
    DIM sid AS STRING
    DIM shortName AS STRING
    DIM longName AS STRING
    
    ItemsFile = FREEFILE
    OPEN "tables/names.txt" FOR INPUT AS ItemsFile
    FOR i = 0 TO InventorySize - 1
        item = InventoryItems(i).id
        found = 0
        SEEK ItemsFile, 1
        DO WHILE NOT EOF(ItemsFile)
            INPUT #ItemsFile, sid: IF EOF(ItemsFile) THEN EXIT DO
            INPUT #ItemsFile, shortName: IF EOF(ItemsFile) THEN EXIT DO
            INPUT #ItemsFile, longName: IF EOF(ItemsFile) THEN EXIT DO
            id = Inventory.SidToItemId%(sid)
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
            InventoryItems(i).shortName = "Item ID: " + LTRIM$(STR$(id))
            InventoryItems(i).longName = "Item ID: " + LTRIM$(STR$(id))
            InventoryItems(i).slot = i
        END IF
    NEXT i
    CLOSE ItemsFile
    
END SUB

FUNCTION Inventory.SidToItemId% (sid AS STRING)
    
    DIM id AS INTEGER
    DIM bound AS INTEGER
    
    bound = UBOUND(ItemSids)
    
    sid = UCASE$(LTRIM$(RTRIM$(sid)))
    
    FOR id = 0 TO bound
        IF ItemSids(id) = sid THEN
            Inventory.SidToItemId% = id
            EXIT FUNCTION
        END IF
    NEXT id
    
    Inventory.SidToItemId% = -1
    
END FUNCTION

SUB Inventory.RemoveItem (item AS InventoryType)
    
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
    OPEN filename FOR INPUT AS File
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
        ItemSids(id) = UCASE$(LTRIM$(RTRIM$(sid)))
    LOOP
    CLOSE File
    
END SUB

FUNCTION Inventory.GetSuccessMsg$ (itemId AS INTEGER)
    
    Inventory.GetSuccessMsg$ = Inventory.GetUseMsg$(itemId, 1)
    
END FUNCTION

FUNCTION Inventory.GetFailMsg$ (itemId AS INTEGER)
    
    Inventory.GetFailMsg$ = Inventory.GetUseMsg$(itemId, 0)
    
END FUNCTION

FUNCTION Inventory.GetUseMsg$ (itemId AS INTEGER, success AS INTEGER)
    
    DIM ItemsFile AS INTEGER
    DIM found AS INTEGER
    DIM id AS INTEGER
    
    DIM sid AS STRING
    DIM successMsg AS STRING
    DIM failMsg AS STRING
    
    DIM char AS STRING * 1
    DIM col  AS STRING
    DIM row  AS STRING
    
    ItemsFile = FREEFILE
    OPEN "tables/uses.txt" FOR INPUT AS ItemsFile
    found = 0
    DO WHILE NOT EOF(ItemsFile)
        LINE INPUT #ItemsFile, row
        sid = ""
        successMsg = ""
        failMsg = ""
        col = ""
        FOR n = 1 TO LEN(row)
            char = MID$(row, n, 1)
            IF (char = ",") OR (n = LEN(row)) THEN
                col = LTRIM$(RTRIM$(col))
                IF LEFT$(col, 1) = CHR$(34) THEN
                    col = RIGHT$(col, LEN(col)-1)
                END IF
                IF RIGHT$(col, 1) = CHR$(34) THEN
                    col = LEFT$(col, LEN(col)-1)
                END IF
                IF sid = "" THEN
                    sid = col
                ELSEIF successMsg = "" THEN
                    successMsg = col
                ELSEIF failMsg = "" THEN
                    failMsg = col
                END IF
                col = ""
            ELSE
                col = col + char
            END IF
        NEXT n
        id = Inventory.SidToItemId%(sid)
        IF itemId = id THEN
            found = 1
            EXIT DO
        END IF
    LOOP
    CLOSE ItemsFile

    IF found THEN
        IF success THEN
            Inventory.GetUseMsg$ = successMsg
        ELSE
            Inventory.GetUseMsg$ = failMsg
        END IF
    ELSE
        Inventory.GetUseMsg$ = "No use message found for item id:"+STR$(itemId)
    END IF
    
END FUNCTION

FUNCTION Inventory.Mix%(itemId0 AS INTEGER, itemId1 AS INTEGER, resultMixMsg AS STRING)
    
    DIM MixesFile AS INTEGER
    DIM found AS INTEGER
    DIM sid0 AS STRING
    DIM sid1 AS STRING
    DIM resultSid AS STRING
    DIM resultMsg AS STRING
    
    DIM char AS STRING * 1
    DIM col  AS STRING
    DIM row  AS STRING
    
    MixesFile = FREEFILE
    OPEN "tables/mixes.txt" FOR INPUT AS MixesFile
    found = 0
    DO WHILE NOT EOF(MixesFile)
        LINE INPUT #MixesFile, row
        sid0 = ""
        sid1 = ""
        resultSid = ""
        resultMsg = ""
        col = ""
        FOR n = 1 TO LEN(row)
            char = MID$(row, n, 1)
            IF (char = ",") OR (n = LEN(row)) THEN
                col = LTRIM$(RTRIM$(col))
                IF LEFT$(col, 1) = CHR$(34) THEN
                    col = RIGHT$(col, LEN(col)-1)
                END IF
                IF RIGHT$(col, 1) = CHR$(34) THEN
                    col = LEFT$(col, LEN(col)-1)
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
        id0 = Inventory.SidToItemId%(sid0)
        id1 = Inventory.SidToItemId%(sid1)
        IF ((itemId0 = id0) AND (itemId1 = id1)) OR ((itemId0 = id1) AND (itemId1 = id0)) THEN
            found = 1
            EXIT DO
        END IF
    LOOP
    CLOSE MixesFile

    IF found THEN
        Inventory.Mix% = Inventory.SidToItemId%(resultSid)
        resultMixMsg   = resultMsg
    ELSE
        Inventory.Mix% = -1
        resultMixMsg   = "I cannot mix these two items"
    END IF
    
END FUNCTION
