#include once "INC\COMMON.BI"
#include once "INC\LD2GFX.BI"
#include once "INC\LD2SND.BI"
#include once "INC\LD2E.BI"
#include once "INC\LD2.BI"
#include once "INC\KEYS.BI"
#include once "INC\STATUS.BI"

DECLARE SUB Drop (item AS InventoryType)
DECLARE SUB DrawStatusScreen (heading AS STRING)
DECLARE SUB Look (item AS InventoryType)
DECLARE SUB Mix (item0 AS InventoryType, item1 AS InventoryType)
DECLARE SUB RefreshStatusScreen ()
DECLARE SUB ShowResponse (response AS STRING)
DECLARE SUB UseItem (item AS InventoryType)

DIM SHARED selectedInventorySlot AS INTEGER

SUB DrawStatusScreen (heading AS STRING)
	
	DIM w AS INTEGER
	DIM h AS INTEGER
	DIM top AS INTEGER
	
	w = 6: h = 6
	top = 0
	
	LD2_CopyBuffer 2, 1
	LD2_fillm 0, top, 320, 96, 66, 1
	
	LD2_PutText w, top + h * 1, heading, 1
	LD2_PutText w, top + h * 2, STRING(LEN(heading), "="), 1
	LD2_PutText 1, top + h * 15, STRING(53, "*"), 1
	
END SUB

SUB Drop (item AS InventoryType)
    
    LD2_Drop item.id
    LD2_ClearInventorySlot item.slot
    
    ShowResponse "Dropped " + item.shortName
    
    RefreshStatusScreen
    
END SUB

SUB EStatusScreen (currentRoomId AS INTEGER)
	
	IF LD2_isDebugMode() THEN LD2_Debug "LD2_EStatusScreen (" + STR(currentRoomId) + " )"
	
	DIM top AS INTEGER
	DIM w AS INTEGER
	DIM h AS INTEGER
	DIM i AS INTEGER
	
	DIM floorNo AS INTEGER
	DIM floorStr AS STRING
	DIM filename AS STRING
	DIM label AS STRING
	DIM allowed AS STRING
	DIM canExit AS INTEGER
	DIM selectedRoom AS INTEGER
	DIM selectedFilename AS STRING
	DIM topFloor AS INTEGER
	DIM btmFloor AS INTEGER
	DIM keyOn AS INTEGER
	DIM keyOff AS INTEGER
	DIM ElevatorFile AS INTEGER
	
	DIM floors(50) AS tFloor
	DIM numFloors AS INTEGER
	DIM scroll AS INTEGER
	DIM doLoadMap AS INTEGER
	
	w = 6: h = 6
	
	selectedRoom = currentRoomId
	topFloor = 0
	btmFloor = 0
	
	ElevatorFile = FREEFILE
	OPEN "tables/rooms.txt" FOR INPUT AS ElevatorFile
	DO WHILE NOT EOF(ElevatorFile)
		INPUT #ElevatorFile, floorNo: IF EOF(ElevatorFile) THEN EXIT DO
		INPUT #ElevatorFile, filename: IF EOF(ElevatorFile) THEN EXIT DO
		INPUT #ElevatorFile, label
		INPUT #ElevatorFile, allowed
		floors(numFloors).floorNo = floorNo
		floors(numFloors).filename = filename
		floors(numFloors).label = label
		floors(numFloors).allowed = allowed
		numFloors = numFloors + 1
	LOOP
	CLOSE ElevatorFile
	
	DIM e AS DOUBLE
	DIM easeTimer AS DOUBLE
	DIM easeTime AS DOUBLE
	DIM lft AS INTEGER
	
	LD2_SaveBuffer 2
	LD2_CopyBuffer 1, 2
	
	easeTimer = TIMER
	DO
		easeTime = TIMER - easeTimer
		easeTimer = TIMER
		e = e + .0167 * 3
		IF e > 1 THEN
			e = 1
		END IF
		lft = -INT((1 - e) * (1 - e) * (1 - e) * 156)
		LD2_CopyBuffer 2, 1
		LD2_fillm lft, 0, 156, 200, 66, 1
		LD2_RefreshScreen
        PullEvents
	LOOP WHILE e < 1
	
	DO
		LD2_CopyBuffer 2, 1
		LD2_fillm 0, 0, 156, 200, 66, 1
		
		LD2_PutText w, h * 1, "Please Select a Floor", 1
		LD2_PutText w, h * 2, "======================", 1
		
		FOR i = 0 TO 32
			LD2_PutText w * 25, h * i + 1, "*", 1
		NEXT i
		
		'scroll = 28-selectedRoom
		'IF scroll < 0 THEN scroll = 0
		'IF scroll > 16 THEN scroll = 16
		scroll = 0
		
		top = h * 4
		FOR i = scroll TO numFloors - 1
		
			floorNo = floors(i).floorNo
			filename = floors(i).filename
			label = floors(i).label
			
			floorStr = LTRIM(STR(floorNo))
			IF LEN(floorStr) = 1 THEN floorStr = " " + floorStr
			IF (numFloors - i - 1) = selectedRoom THEN 'floorNo = selectedRoom THEN
				'LD2_PutTextCol w, top, floorStr+" "+label, 112, 1
				LD2_fillm w - 1, top - 1, w * 2 + 2, h + 1, 17, 1
				LD2_fillm w * 3 + 1, top - 1, w * 21 - 3, h + 1, 70, 1
				LD2_PutTextCol w, top, floorStr, 61, 1
				LD2_PutTextCol w * 4, top, label, 15, 1
				selectedFilename = filename
			ELSE
				LD2_fillm w - 1, top - 1, w * 2 + 2, h + 1, 48, 1'- 208, 160, 48
				IF LTRIM(filename) <> "" THEN
					'LD2_PutText w, top, floorStr + " " + label, 1
					LD2_PutTextCol w, top, floorStr, 54, 1
					LD2_PutText w * 4, top, label, 1
				ELSE
					LD2_PutText w, top, "   " + label, 1
				END IF
			END IF
			top = top + h + 1
			IF floorNo > topFloor THEN topFloor = floorNo
			IF floorNo < btmFloor THEN btmFloor = floorNo
			'LD2_RotatePalette
		NEXT i
		
		LD2_RefreshScreen
        PullEvents
		
		IF canExit = 0 THEN
			IF keyboard(KEY_TAB) = 0 THEN
			  canExit = 1
			END IF
		ELSE
			IF keyboard(KEY_TAB) THEN
				EXIT DO
			END IF
			
			'- TODO: hold down for one second, then scroll down with delay
			keyOn = 0
			IF keyboard(KEY_UP) THEN
				keyOn = 1
				IF keyOff THEN
					selectedRoom = selectedRoom + 1
					IF LTRIM(floors(numFloors - selectedRoom - 1).filename) = "" THEN
						selectedRoom = selectedRoom + 1
					END IF
					IF selectedRoom > numFloors - 1 THEN
						selectedRoom = numFloors - 1
						LD2_PlaySound sfxDENIED
					ELSE
						LD2_PlaySound sfxSELECT
					END IF
				END IF
			END IF
			IF keyboard(KEY_DOWN) THEN
				keyOn = 1
				IF keyOff THEN
					selectedRoom = selectedRoom - 1
					IF LTRIM(floors(numFloors - selectedRoom - 1).filename) = "" THEN
						selectedRoom = selectedRoom - 1
					END IF
					IF selectedRoom < 0 THEN
						selectedRoom = 0
						LD2_PlaySound sfxDENIED
					ELSE
						LD2_PlaySound sfxSELECT
					END IF
				END IF
			END IF
			IF keyboard(KEY_ENTER) or keyboard(KEY_SPACE) THEN
				keyOn = 1
				IF keyOff THEN
					LD2_PlaySound sfxSELECT
					LD2_SetRoom selectedRoom
					currentRoomId = selectedRoom
                    'LD2_SetAllowedEntities floors(selectedRoom).allowed
					doLoadMap = 1
					EXIT DO
				END IF
			END IF

			IF keyOn THEN
				keyOff = 0
			ELSE
				keyOff = 1
			END IF
			
		END IF
		
	LOOP
	
	WaitForKeyup(KEY_TAB) 'DO: LOOP WHILE keyboard(&HF)
	
	easeTimer = TIMER
	e = 0
	DO
		easeTime = TIMER - easeTimer
		easeTimer = TIMER
		e = e + .0167 * 4
		IF e > 1 THEN
			e = 1
		END IF
		lft = -INT(e * e * e * 156)
		LD2_CopyBuffer 2, 1
		LD2_fillm lft, 0, 156, 200, 66, 1
		LD2_RefreshScreen
        PullEvents
	LOOP WHILE e < 1
	LD2_RestoreBuffer 2
	
    IF doLoadMap THEN
		LD2_LoadMap selectedFilename
	END IF
	
END SUB

SUB Look (item AS InventoryType)
	
	DIM w AS INTEGER
	DIM h AS INTEGER
	DIM top AS INTEGER
	DIM lft AS INTEGER
	DIM pad AS INTEGER
	DIM maxlen AS INTEGER

	DIM desc AS STRING
	DIM chunk AS STRING
	DIM theword AS STRING
	DIM char AS STRING
    dim n as integer
    dim canExit as integer
	
	w = 6: h = 6
	top = h * 4
	lft = w
	pad = 0
	maxlen = INT((320 - pad * 2 - lft) / w)
	
	desc = Inventory_LoadDescription(item.id)
	IF desc = "" THEN
		desc = "No description found for item id:" + STR(item.id)
	END IF
	
	DrawStatusScreen item.longName
	
	DO WHILE LEN(desc) > 0
		IF LEN(desc) <= maxlen THEN
			chunk = desc
			desc = ""
		ELSE
			chunk = LEFT(desc, maxlen)
			desc = RIGHT(desc, LEN(desc) - maxlen)
			IF (MID(chunk, maxlen, 1) = " ") THEN
				chunk = RTRIM(chunk)
				desc = LTRIM(desc)
			ELSEIF (MID(chunk, maxlen, 1) <> " ") AND (MID(desc, maxlen + 1, 1) = " ") THEN
				desc = LTRIM(desc)
			ELSE
				FOR n = LEN(chunk) TO 1 STEP -1
					char = MID(chunk, n, 1)
					IF char <> " " THEN
						theword = char + theword
					ELSE
						EXIT FOR
					END IF
				NEXT n
				desc = theword + desc
				chunk = LEFT(chunk, LEN(chunk) - LEN(theword))
				chunk = RTRIM(chunk)
			END IF
			
		END IF
		LD2_PutText lft + pad, top, chunk, 1
		top = top + h
	LOOP
	
	LD2_RefreshScreen
	
	DO
        PullEvents
		IF canExit = 0 THEN
			IF keyboard(&H1C) = 0 THEN
				canExit = 1
			END IF
		ELSE
			IF keyboard(&H1C) THEN
				EXIT DO
			END IF
		END IF
	LOOP
	
END SUB

SUB RefreshStatusScreen
    
    DIM i AS INTEGER
    DIM id AS INTEGER
    DIM qty AS INTEGER
    
    Inventory_Clear
    FOR i = 0 TO 7 '- change to LD2_GetMaxInvSize% ?
        id = LD2_GetStatusItem(i)
        qty = LD2_GetStatusAmount(i)
        IF Inventory_Add(id, qty) THEN
            EXIT FOR
        END IF
    NEXT i
    Inventory_RefreshNames
    
END SUB

SUB StatusScreen
	
	IF LD2_isDebugMode() THEN LD2_Debug "LD2_StatusScreen"
	
	DIM top AS INTEGER
	DIM w AS INTEGER
	DIM h AS INTEGER
	DIM i AS INTEGER
	DIM qty AS INTEGER
	DIM itemStr AS STRING
	DIM id AS INTEGER
	DIM sid AS STRING
	DIM shortName AS STRING
	DIM longName AS STRING
	DIM desc AS STRING
	DIM found AS INTEGER
	DIM selected AS InventoryType
	DIM item AS InventoryType
    
    DIM strLife AS STRING
    DIM strWeapon AS STRING
    DIM clr AS INTEGER
    DIM mixMode AS INTEGER
    DIM mixItem AS InventoryType
	
	DIM actions(3) AS STRING
	DIM actionStr AS STRING
	DIM action AS INTEGER
	actions(0) = "USE "
	actions(1) = "LOOK"
	actions(2) = "MIX "
	actions(3) = "DROP"
	
	w = 6: h = 6
	
    RefreshStatusScreen
	
	action = -1
	
	DIM e AS DOUBLE
	DIM easeTimer AS DOUBLE
	DIM easeTime AS DOUBLE
	DIM saveTop AS INTEGER
    dim canExit as integer
    dim keyOn as integer
    dim keyOff as integer
	
	LD2_SaveBuffer 2
	LD2_CopyBuffer 1, 2
	
	easeTimer = TIMER
	DO
		easeTime = TIMER - easeTimer
		easeTimer = TIMER
		e = e + .0167 * 3
		IF e > 1 THEN
			e = 1
		END IF
		top = -INT((1 - e) * (1 - e) * (1 - e) * 96)
		LD2_CopyBuffer 2, 1
		LD2_fillm 0, top, 320, 96, 66, 1
		LD2_RefreshScreen
        PullEvents
	LOOP WHILE e < 1
    
    DIM player AS tPlayer
	
	DO
		top = 0
		LD2_CopyBuffer 2, 1
        
        LD2_fillm 0, top, 320, 96, 66, 1

		LD2_PutText w, top + h * 1, "LARRY", 1
		LD2_PutText w, top + h * 2, "=============", 1
        

		LD2_PutText 1, top + h * 15, STRING(53, "*"), 1
        
        
        LD2_GetPlayer player
        
        '- show item that was picked up (lower-right corner of screen: "Picked Up Shotgun")
        '- copy steve scene sprites over
        
        SELECT CASE Player.life
        CASE IS > 80
            strLife = "Good"
            clr = 56
        CASE IS > 50
            strLife = "OK"
            clr = 168
        CASE IS > 20
            strLife = "Not Well"
            clr = 88
        CASE IS > 10
            strLife = "Critical"
            clr = 40
        CASE ELSE
            strLife = "Almost Dead"
            clr = 40
        END SELECT
        
        SELECT CASE Player.weapon
        CASE FIST
            strWeapon = "Fist"
        CASE SHOTGUN
            strWeapon = "Shotgun"
        CASE MACHINEGUN
            strWeapon = "Machinegun"
        CASE PISTOL
            strWeapon = "Pistol"
        CASE DESERTEAGLE
            strWeapon = "Magnum"
        END SELECT
        
        LD2_PutText w, top+h*4, "STATUS: ", 1
        LD2_PutTextCol w*9, top+h*4, strLife, clr, 1
        LD2_PutText w, top+h*6, "HEALTH: "+LTRIM(STR(Player.life))+"%", 1
        LD2_PutText w, top+h*8, "WEAPON: "+strWeapon, 1
        'LD2_put w, top+h*1, 47, idLARRY, 1 '- larry
        'LD2_put w, top+h*3, 44, idLARRY, 1 '- heart
        'LD2_putTextCol w+16+w, top+h*3, STR$(Player.life), 15, 1
        'SELECT CASE player.weapon
        'CASE FIST
        '    LD2_put w, top+h*5, 46, idLARRY, 1
        'CASE SHOTGUN
        '    LD2_put w, top+h*5, 45, idLARRY, 1
        'END SELECT
        'IF Player.weapon = SHOTGUN     THEN LD2_PutTextCol w+16+w, top+h*5, STR$(Inventory(SHELLS)), 15, 1
        'IF Player.weapon = MACHINEGUN  THEN LD2_PutTextCol w+16+w, top+h*5, STR$(Inventory(BULLETS)), 15, 1
        'IF Player.weapon = PISTOL      THEN LD2_PutTextCol w+16+w, top+h*5, STR$(Inventory(BULLETS)), 15, 1
        'IF Player.weapon = DESERTEAGLE THEN LD2_PutTextCol w+16+w, top+h*5, STR$(Inventory(DEAGLES)), 15, 1
        'IF Player.weapon = FIST        THEN LD2_PutTextCol w+16+w, top+h*5, " INF", 15, 1

		LD2_PutText w * 38, top + h * 1, "INVENTORY", 1
		LD2_PutText w * 33, top + h * 2, "==================", 1

		saveTop = top
		top = top + (h * 4)
		FOR i = 0 TO 7
			
			IF Inventory_GetItemBySlot(item, i) THEN
				'- error
			END IF
			itemStr = "( " + item.shortName + " )"
			
			IF i = selectedInventorySlot THEN
				LD2_fillm w * 33, top - 1, w * 19.5, h + 1, 70, 1
				LD2_PutTextCol 200, top, itemStr, 15, 1
				selected = item
			ELSE
				LD2_PutText 200, top, itemStr, 1
			END IF
			
			top = top + h
			
		NEXT i
		
		top = saveTop
		IF action = -1 THEN
			'itemStr = LTRIM$(RTRIM$(item.shortName))
			'itemStr = itemStr + SPC$(15-LEN(itemStr))
			'LD2_fillm INT((320-(w*LEN(itemStr)))/2)-7, top+h*13-1, w*LEN(itemStr)+1+12, h+1, 130, 1
			'LD2_PutTextCol INT((320-(w*LEN(itemStr)))/2), top + h * 13, itemStr, 15, 1
		ELSEIF mixMode THEN
            shortName = LTRIM(RTRIM(mixItem.shortName))
            LD2_PutText w * 21, top + h * 13, "Mix "+SPACE(LEN(shortName))+" with ", 1
            LD2_PutTextCol w * 25, top + h * 13, shortName, 56, 1
            LD2_PutTextCol w * (31+LEN(shortName)), top + h * 13, LTRIM(RTRIM(selected.shortName)), 31, 1
        ELSE
			LD2_PutText w * 21, top + h * 13, "  USE     LOOK    MIX     DROP  ", 1
			FOR i = 0 TO 3
				IF i = action THEN
					actionStr = "( " + actions(i) + " )"
					LD2_fillm w * (21 + i * 8), top + h * 13 - 1, w * 8, h + 1, 70, 1
					LD2_PutTextCol w * (21 + i * 8), top + h * 13, actionStr, 15, 1
				ELSE
					actionStr = "  " + actions(i) + "  "
					LD2_PutText w * (21 + i * 8), top + h * 13, actionStr, 1
				END IF
			NEXT i
		END IF
		
		LD2_RefreshScreen
        PullEvents

		IF canExit = 0 THEN
			IF keyboard(KEY_TAB) = 0 THEN
				canExit = 1
			END IF
		ELSE
			IF keyboard(KEY_TAB) THEN
				IF action > -1 THEN
					action = -1
				ELSE
					EXIT DO
				END IF
			END IF
				
			'- TODO: hold down for one second, then scroll down with delay
			keyOn = 0
			IF keyboard(KEY_UP) THEN
				keyOn = 1
				IF keyOff THEN
					selectedInventorySlot = selectedInventorySlot - 1
					IF selectedInventorySlot < 0 THEN
						selectedInventorySlot = 0
						LD2_PlaySound sfxDENIED
					ELSE
						'action = -1
						LD2_PlaySound sfxSELECT
					END IF
				END IF
			END IF
			IF keyboard(KEY_DOWN) THEN
				keyOn = 1
				IF keyOff THEN
					selectedInventorySlot = selectedInventorySlot + 1
					IF selectedInventorySlot > 7 THEN
						selectedInventorySlot = 7
						LD2_PlaySound sfxDENIED
					ELSE
						'action = -1
						LD2_PlaySound sfxSELECT
					END IF
				END IF
			END IF
			IF keyboard(KEY_LEFT) THEN
				keyOn = 1
				IF keyOff THEN
					action = action - 1
					IF action < 0 THEN
						action = 0
						LD2_PlaySound sfxDENIED
					ELSE
						LD2_PlaySound sfxSELECT
					END IF
				END IF
			END IF
			IF keyboard(KEY_RIGHT) THEN
				keyOn = 1
				IF keyOff THEN
					action = action + 1
					IF action > 3 THEN
						action = 3
						LD2_PlaySound sfxDENIED
					ELSE
						LD2_PlaySound sfxSELECT
					END IF
				END IF
			END IF
			IF keyboard(KEY_ENTER) or keyboard(KEY_SPACE) THEN
				keyOn = 1
				IF keyOff THEN
                    IF mixMode THEN
                        Mix mixItem, selected
					ELSEIF action > -1 THEN
						'- DO SUB MENU (LOOK/MIX/DROP/ETC) HERE
						SELECT CASE action
						CASE 0  '- USE
							UseItem selected
						CASE 1  '- LOOK
							LD2_PlaySound sfxSELECT2
							Look selected
						CASE 2  '- MIX
                            mixMode = 1
                            mixItem = selected
						CASE 3  '- Drop
							LD2_PlaySound sfxDROP
							Drop selected
							LD2_RenderFrame
							LD2_CopyBuffer 0, 2
						END SELECT
					ELSE
						action = 0
					END IF
				END IF
			END IF
				
			IF keyOn THEN
				keyOff = 0
			ELSE
				keyOff = 1
			END IF
			
		END IF
	LOOP
	
	WaitForKeyup(KEY_TAB) 'DO: LOOP WHILE keyboard(KEYTAB)
	
	easeTimer = TIMER
	e = 0
	DO
		easeTime = TIMER - easeTimer
		easeTimer = TIMER
		e = e + .0167 * 4
		IF e > 1 THEN
			e = 1
		END IF
		top = -INT(e * e * e * 96)
		LD2_CopyBuffer 2, 1
		LD2_fillm 0, top, 320, 96, 66, 1
		LD2_RefreshScreen
        PullEvents
	LOOP WHILE e < 1
	LD2_RestoreBuffer 2
	
END SUB

SUB UseItem (item AS InventoryType)

    DIM msg AS STRING

    SELECT CASE item.id
    CASE NOTHING
        msg = Inventory_GetFailMsg(item.id)
        LD2_PlaySound sfxDenied
    CASE MEDIKIT50
        'IF LD2_LifeAtMax% THEN
        '    msg = Inventory_GetFailMsg$(item.id)
        '    LD2_PlaySound sfxDenied
        'ELSE
        '    LD2_AddAmmo -1, 50
        '    msg = Inventory_GetSuccessMsg$(item.id)
        'END IF
    CASE MEDIKIT100
        'IF LD2_LifeAtMax% THEN
        '    msg = Inventory_GetFailMsg$(item.id)
        '    LD2_PlaySound sfxDenied
        'ELSE
        '    LD2_AddAmmo -1, 100 '- change to LD2_AddLife MEDIKIT100AMT
        '    msg = Inventory_GetSuccessMsg$(item.id)
        'END IF
        'msg = Inventory_GetSuccessMsg$(item.id)
    CASE GRENADE
    CASE SHELLS
        'IF LD2_AmmoAtMax%(SHOTGUN) THEN
        '    msg = Inventory_GetSuccessMsg$(item.id)
        '    LD2_PlaySound sfxDenied
        'ELSE
        '    LD2_AddAmmo SHOTGUN, 4 '- change to LD2_AddAmmo SHOTGUN, SHELLSQTY
            msg = Inventory_GetSuccessMsg(item.id)
        'END IF
    CASE BULLETS
        msg = Inventory_GetSuccessMsg(item.id)
    CASE DEAGLES
        msg = Inventory_GetSuccessMsg(item.id)
    CASE GREENCARD
        msg = Inventory_GetFailMsg(item.id)
        LD2_PlaySound sfxDenied
    CASE BLUECARD
        msg = Inventory_GetFailMsg(item.id)
        LD2_PlaySound sfxDenied
    CASE YELLOWCARD
        msg = Inventory_GetFailMsg(item.id)
        LD2_PlaySound sfxDenied
    CASE REDCARD
        msg = Inventory_GetFailMsg(item.id)
        LD2_PlaySound sfxDenied
    CASE SHOTGUN
        LD2_SetWeapon1(SHOTGUN)
        LD2_SetWeapon 1
        msg = Inventory_GetSuccessMsg(item.id)
    CASE MACHINEGUN
        LD2_SetWeapon1(MACHINEGUN)
        LD2_SetWeapon 1
        msg = Inventory_GetSuccessMsg(item.id)
    CASE PISTOL
        LD2_SetWeapon1(PISTOL)
        LD2_SetWeapon 1
        msg = Inventory_GetSuccessMsg(item.id)
    CASE DESERTEAGLE
        LD2_SetWeapon1(DESERTEAGLE)
        LD2_SetWeapon 1
        msg = Inventory_GetSuccessMsg(item.id)
    CASE EXTRALIFE
        LD2_AddLives 1
        'LD2_PlaySound sfxPowerUp
        msg = Inventory_GetSuccessMsg(item.id)
	END SELECT
    
    ShowResponse msg
	
END SUB

SUB Mix (item0 AS InventoryType, item1 AS InventoryType)
    
    DIM msg AS STRING
    DIM resultId AS INTEGER
    dim nil as integer
    
    resultId = Inventory_Mix(item0.id, item1.id, msg)
    
    IF resultId <> -1 THEN
        LD2_ClearInventorySlot item0.slot
        LD2_ClearInventorySlot item1.slot
        nil = LD2_AddToStatus(resultId, 1)
        RefreshStatusScreen
    END IF
    
    ShowResponse msg
    
END SUB

SUB ShowResponse (response AS STRING)
    
    DIM w AS INTEGER, h AS INTEGER
    DIM i AS INTEGER
    DIM top AS INTEGER
    DIM lft AS INTEGER
    DIM text AS STRING
    dim canExit as integer
    
    w = 6: h = 6
    lft = w * 21
    top = h * 13 - 1

    FOR i = 1 TO LEN(response)
        LD2_fillm lft, top, 320-(w*21), h + 1, 66, 1
        LD2_PutTextCol lft+1, top+1, LEFT(response, i), 15, 1
        LD2_RefreshScreen
        'WaitSeconds 0.05
    NEXT i

    DO
        IF (INT(TIMER*3) AND 1) THEN
            text = response
        ELSE
            text = response + "_"
        END IF
        LD2_fillm lft, top, 320-(w*21), h + 1, 66, 1
        LD2_PutTextCol lft+1, top+1, text, 15, 1
        LD2_RefreshScreen
        PullEvents
        IF canExit = 0 THEN
            IF keyboard(&H1C) = 0 THEN
                canExit = 1
            END IF
        ELSE
            IF keyboard(&H1C) THEN
                EXIT DO
            END IF
        END IF
    LOOP

END SUB
