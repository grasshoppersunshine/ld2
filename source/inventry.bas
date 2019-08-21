REM $INCLUDE: 'INC\INVENTRY.BI'

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

FUNCTION Inventory.GetItem% (item AS InventoryType, slot AS INTEGER)
    
    Inventory.GetItem% = 0
    
    IF (slot >= 0) AND (slot < InventorySize) THEN
        item = InventoryItems(slot)
    ELSE
        Inventory.GetItem% = InventoryErr.OUTOFBOUNDS
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
    
    Inventory.GetFailMsg$ = Inventory.GetUseMsg$(itemId, 1)
    
END FUNCTION

FUNCTION Inventory.GetUseMsg$ (itemId AS INTEGER, success AS INTEGER)
    
    DIM ItemsFile AS INTEGER
    DIM found AS INTEGER
    DIM id AS INTEGER
    
    DIM sid AS STRING
    DIM successMsg AS STRING
    DIM failMsg AS STRING
    
    ItemsFile = FREEFILE
    OPEN "tables/uses.txt" FOR INPUT AS ItemsFile
    found = 0
    DO WHILE NOT EOF(ItemsFile)
        INPUT #ItemsFile, sid: IF EOF(ItemsFile) THEN EXIT DO
        INPUT #ItemsFile, successMsg: IF EOF(ItemsFile) THEN EXIT DO
        INPUT #ItemsFile, failMsg: IF EOF(ItemsFile) THEN EXIT DO
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
