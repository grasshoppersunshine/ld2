#include once "modules/inc/common.bi"
#include once "modules/inc/keys.bi"
#include once "modules/inc/ld2gfx.bi"
#include once "modules/inc/ld2snd.bi"
#include once "inc/ld2e.bi"
#include once "inc/ld2.bi"
#include once "inc/status.bi"

DECLARE SUB Drop (item AS InventoryType)
DECLARE SUB BuildStatusWindow (heading AS STRING, elementWindow as ElementType ptr, elementHeading as ElementType ptr, elementBorder as ElementType ptr)
DECLARE SUB Look (item AS InventoryType)
DECLARE SUB Mix (item0 AS InventoryType, item1 AS InventoryType)
DECLARE SUB RefreshStatusScreen ()
DECLARE SUB ShowResponse (response AS STRING)
DECLARE SUB UseItem (item AS InventoryType)

DIM SHARED selectedInventorySlot AS INTEGER
dim shared UseItemCallback as sub(id as integer, qty as integer)

const DATA_DIR = "data/"
const STATUS_DIALOG_ALPHA_UNIT = 0.75
const STATUS_DIALOG_ALPHA = 192
const STATUS_DIALOG_COLOR = 66

sub STATUS_SetUseItemCallback(callback as sub(id as integer, qty as integer))
    
    UseItemCallback = callback
    
end sub

SUB BuildStatusWindow (heading AS STRING, elementWindow as ElementType ptr, elementHeading as ElementType ptr, elementBorder as ElementType ptr)
	
	dim fontW as integer
    dim fontH as integer
	
	fontW = LD2_GetFontWidthWithSpacing()
    fontH = LD2_GetFontHeightWithSpacing()
	
    LD2_InitElement elementWindow
    elementWindow->background = STATUS_DIALOG_COLOR
    elementWindow->background_alpha = STATUS_DIALOG_ALPHA_UNIT
    elementWindow->w = SCREEN_W
    elementWindow->h = 96
    
    LD2_InitElement elementHeading, heading+"\"+string(15, "="), 31
    elementHeading->parent = elementWindow
    elementHeading->padding_x = fontW
    elementHeading->y = fontH * 1
    
    LD2_InitElement elementBorder, STRING(53, "*"), 31
    elementBorder->parent = elementWindow
    elementBorder->y = elementWindow->h - fontH
    
    LD2_ClearElements
    LD2_AddElement elementWindow
    LD2_AddElement elementHeading
    LD2_AddElement elementBorder
	
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
    dim selectedLabel as string
	DIM topFloor AS INTEGER
	DIM btmFloor AS INTEGER
	DIM keyOn AS INTEGER
	DIM keyOff AS INTEGER
	DIM ElevatorFile AS INTEGER
	
	DIM floors(50) AS tFloor
	DIM numFloors AS INTEGER
	DIM scroll AS INTEGER
	DIM doLoadMap AS INTEGER
    
    dim menuWindow as ElementType
    dim menuTitle as ElementType
    dim menuBorder as ElementType
    redim menuNumbers(0) as ElementType
    redim menuLabels(0) as ElementType
    
    dim fontW as integer
    dim fontH as integer
    
    fontW = LD2_GetFontWidthWithSpacing()
    fontH = LD2_GetFontHeightWithSpacing()
	
	w = 6: h = 6
	
	selectedRoom = currentRoomId
	topFloor = 0
	btmFloor = 0
    
    LD2_PlaySound Sounds.status
	
	ElevatorFile = FREEFILE
	OPEN DATA_DIR+"tables/rooms.txt" FOR INPUT AS ElevatorFile
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
    
    redim menuNumbers(numFloors) as ElementType
    redim menuLabels(numFloors) as ElementType
	
	DIM e AS DOUBLE
	DIM easeTimer AS DOUBLE
	DIM easeTime AS DOUBLE
	DIM lft AS INTEGER
    
    LD2_InitElement @menuWindow, "", 31
    menuWindow.h = SCREEN_H
    menuWindow.background = STATUS_DIALOG_COLOR
    menuWindow.background_alpha = STATUS_DIALOG_ALPHA_UNIT
    
    LD2_InitElement @menuTitle, "Please Select a Floor\======================", 31
    menuTitle.parent = @menuWindow
    menuTitle.y = fontH * 1
    menuTitle.x = fontW * 1
    
    LD2_InitElement @menuBorder, "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *", 31
    menuBorder.parent = @menuWindow
    menuBorder.x = 156 - fontW
    menuBorder.w = fontW
    menuBorder.h = SCREEN_H
    
    for i = 0 to numFloors-1
        floorStr = iif(len(floors(i).filename), ltrim(str(floors(i).floorNo)), "")
        LD2_InitElement @menuNumbers(i), floorStr, 31, ElementFlags.MonospaceText or ElementFlags.AlignTextRight
        menuNumbers(i).parent = @menuWindow
        menuNumbers(i).w = fontW * 2
        menuNumbers(i).h = FONT_H
        menuNumbers(i).padding_y = 1
        menuNumbers(i).x = fontW
        menuNumbers(i).y = fontH * 4 + fontH * i
        menuNumbers(i).text_color = 182
        menuNumbers(i).background = 177
        LD2_InitElement @menuLabels(i), floors(i).label, 31
        menuLabels(i).parent = @menuWindow
        menuLabels(i).w = 156 - fontW * 5 - 3
        menuLabels(i).h = FONT_H
        menuLabels(i).padding_x = 3
        menuLabels(i).padding_y = 1
        menuLabels(i).x = fontW * 4 - 5
        menuLabels(i).y = fontH * 4 + fontH * i
        menuLabels(i).text_color = 31
    next i
	
	LD2_SaveBuffer 2
	LD2_CopyBuffer 1, 2
	
    e = getEaseInInterval(1)
	DO
		e = getEaseInInterval(0, 3)
        menuWindow.w = int(e * 156)
		LD2_CopyBuffer 2, 1
		LD2_RenderElement @menuWindow
		LD2_RefreshScreen
        PullEvents
	LOOP WHILE e < 1
    
    LD2_ClearElements
    LD2_AddElement @menuWindow
    LD2_AddElement @menuTitle
    LD2_AddElement @menuBorder
    for i = 0 to numFloors-1
        LD2_AddElement @menuNumbers(i)
        LD2_AddElement @menuLabels(i)
    next i
	
	DO
		FOR i = 0 TO numFloors - 1
		
			floorNo = floors(i).floorNo
			filename = floors(i).filename
			label = floors(i).label
			
			floorStr = LTRIM(STR(floorNo))
			
			IF (numFloors - i - 1) = selectedRoom THEN
                menuNumbers(i).background = 19: menuNumbers(i).text_color = 188
                menuLabels(i).background = 70: menuLabels(i).text_color = 31
				selectedFilename = filename
                selectedLabel = label
			ELSE
				menuNumbers(i).background = 177
                menuLabels(i).background = -1
				IF LTRIM(filename) <> "" THEN
					menuNumbers(i).text_color = 182
                    menuLabels(i).text_color = 31
				END IF
			END IF
			IF floorNo > topFloor THEN topFloor = floorNo
			IF floorNo < btmFloor THEN btmFloor = floorNo
		NEXT i
		
        LD2_CopyBuffer 2, 1
		LD2_RenderElements
		LD2_RefreshScreen
        PullEvents
		
		IF canExit = 0 THEN
			IF (keyboard(KEY_TAB) = 0) or (keyboard(KEY_ESCAPE) = 0) THEN
			  canExit = 1
			END IF
		ELSE
			IF keyboard(KEY_TAB) or keyboard(KEY_ESCAPE) THEN
				EXIT DO
			END IF
            if keyboard(KEY_E) and LD2_isTestMode() then
                exit do
            end if
			
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
						LD2_PlaySound Sounds.denied
					ELSE
						LD2_PlaySound Sounds.select1
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
						LD2_PlaySound Sounds.denied
					ELSE
						LD2_PlaySound Sounds.select1
					END IF
				END IF
			END IF
			IF keyboard(KEY_ENTER) or keyboard(KEY_SPACE) THEN
				keyOn = 1
				IF keyOff THEN
					LD2_PlaySound Sounds.select1
					LD2_SetRoom selectedRoom
					'currentRoomId = selectedRoom
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
	
	WaitForKeyup(KEY_TAB)
    
    LD2_PlaySound Sounds.status
	
	e = getEaseOutInterval(1)
	DO
		e = getEaseOutInterval(0, 3)
		menuWindow.w = int(e * 156)
		LD2_CopyBuffer 2, 1
		LD2_RenderElement @menuWindow
		LD2_RefreshScreen
        PullEvents
	LOOP WHILE e > 0
	LD2_RestoreBuffer 2
	
    dim eMessage as ElementType
    dim eRoomName as ElementType
    dim labelFloor as ElementType
    dim elevatorText as string
    dim elevatorStep as integer
    dim seconds as double
    elevatorStep = iif(selectedRoom > currentRoomId, 1, -1)
    elevatorText = iif(elevatorStep > 0, "Going Up", "Going Down")
    seconds = 0
    e = getEaseInInterval(1)
    e = getEaseInInterval(0, 35)
    dim counterStep as double
    dim secondsToWait as double
    counterStep = abs(currentRoomId-selectedRoom)/25
    IF doLoadMap THEN
        LD2_FadeOut 3
		LD2_LoadMap selectedFilename
        LD2_HidePlayer
        LD2_PlayMusic mscELEVATOR
        LD2_InitElement @eMessage, elevatorText, 31
        eMessage.y = 60
        eMessage.is_centered_x = 1
        eMessage.text_spacing = 1.9
        eMessage.text_color = 31
        LD2_InitElement @eRoomName, trim(selectedLabel), 31
        eRoomName.y = 60 + fontH * 5.5
        eRoomName.is_centered_x = 1
        eRoomName.text_spacing = 1.9
        eRoomName.text_color = 31
        LD2_cls 1, 0
        LD2_RenderElement @eMessage
        LD2_FadeIn 2
        for i = currentRoomId to selectedRoom step elevatorStep
            LD2_InitElement(@labelFloor)
            labelFloor.y = 60 + fontH * 2.5
            labelFloor.is_centered_x = 1
            labelFloor.text = trim(str(i))
            labelFloor.text_spacing = 1.9
            labelFloor.text_color = 31
            LD2_cls 1, 0
            LD2_RenderElement @eMessage
            LD2_RenderElement @labelFloor
            if i = selectedRoom then LD2_RenderElement @eRoomName
            LD2_RefreshScreen
            PullEvents
            e = getEaseInInterval(0, counterStep)
            select case abs(i-selectedRoom)
            case 0
                secondsToWait = 1.00
            case 1
                secondsToWait = 0.40
            case 2
                secondsToWait = 0.35
            case 3
                secondsToWait = 0.30
            case 4
                secondsToWait = 0.25
            case 5 to 9
                secondsToWait = 0.2
            case 10 to 15
                secondsToWait = 0.15
            case else
                secondsToWait = 0.12
            end select
            WaitSeconds secondsToWait
            seconds += secondsToWait
        next i
        if seconds < 2.0 then
            WaitSeconds 2.0 - seconds
        end if
        LD2_FadeOut 2
        LD2_RenderFrame
        WaitSeconds 0.5
        LD2_FadeIn 2
	END IF
    
    currentRoomId = selectedRoom
	
END SUB

SUB Look (item AS InventoryType)
	
    LD2_BackupElements
    
    dim canExit as integer
    dim desc as string
    dim i as integer
    
    dim dialog as ElementType
    dim heading as ElementType
    dim border as ElementType
    dim textDescription as ElementType
    dim revealStep as integer
    
    dim fontW as integer
    dim fontH as integer
    
    fontW = LD2_GetFontWidthWithSpacing()
    fontH = LD2_GetFontHeightWithSpacing()
	
	desc = Inventory_LoadDescription(item.id)
	IF desc = "" THEN
		desc = "No description found for item id:" + STR(item.id)
	END IF
	
	BuildStatusWindow item.longName, @dialog, @heading, @border
    
    LD2_InitElement @textDescription, "", 31
    textDescription.parent = @dialog
    textDescription.w = SCREEN_W - fontW*2
    textDescription.x = fontW
    textDescription.y = fontH * 3.5
    
    revealStep = int(len(desc) / 20)
    if revealStep < 2 then revealStep = 2
    if revealStep > 5 then revealStep = 5
    for i = 1 to len(desc) step revealStep
        textDescription.text = left(desc, i)
        LD2_RenderElements
        LD2_RenderElement @textDescription
        LD2_RefreshScreen
        PullEvents
    next i
    
    textDescription.text = desc
    LD2_RenderElements
    LD2_RenderElement @textDescription
    LD2_RefreshScreen
	
	DO
        PullEvents
		IF canExit = 0 THEN
			IF keyboard(KEY_ENTER) = 0 THEN
				canExit = 1
			END IF
		ELSE
			IF keyboard(KEY_ENTER) THEN
				EXIT DO
			END IF
		END IF
	LOOP
    
    LD2_RestoreElements
	
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
    
    dim fontW as integer
    dim fontH as integer
    
    fontW = LD2_GetFontWidthWithSpacing()
    fontH = LD2_GetFontHeightWithSpacing()
	
	w = 6: h = 6
	
    RefreshStatusScreen
	
	action = -1
	
	DIM e AS DOUBLE
	dim canExit as integer
    dim keyOn as integer
    dim keyOff as integer
    
    LD2_PlaySound Sounds.status
	
	LD2_SaveBuffer 2
	LD2_CopyBuffer 1, 2
    
    dim dialog as ElementType
    LD2_InitElement @dialog
    dialog.background = STATUS_DIALOG_COLOR
    dialog.background_alpha = STATUS_DIALOG_ALPHA_UNIT
    dialog.w = SCREEN_W
	
	e = getEaseInInterval(1)
	DO
        e = getEaseInInterval(0, 3)
		'top = -INT((1 - e) * (1 - e) * (1 - e) * 96)
		'LD2_fillm 0, top, SCREEN_W, 96, 66, 1, STATUS_DIALOG_ALPHA
        LD2_CopyBuffer 2, 1
        dialog.h = e * 96
        LD2_RenderElement @dialog
		LD2_RefreshScreen
        PullEvents
	LOOP WHILE e < 1
    
    dialog.h = 96
    
    DIM player AS PlayerType
    
    dim labelBottomBorder as ElementType
    dim labelName as ElementType
    dim labelStatus as ElementType: dim valueStatus as ElementType
    dim labelHealth as ElementType: dim valueHealth as ElementType
    dim labelWeapon as ElementType: dim valueWeapon as ElementType
    dim labelInventory as ElementType
    dim labelItems(7) as ElementType
    dim labelItemsDecor(7) as ElementType
    dim menuActions as ElementType
    dim labelActions(3) as ElementType
    
    LD2_InitElement @labelBottomBorder, STRING(53, "*"), 31
    labelBottomBorder.parent = @dialog
    labelBottomBorder.y = dialog.h - fontH
    
    LD2_InitElement @labelName, "LARRY\=======", 31
    labelName.parent = @dialog
    labelName.padding_x = fontW
    labelName.y = fontH * 1
    
    LD2_InitElement @labelStatus, "STATUS:", 31
    labelStatus.parent = @dialog
    labelStatus.padding_x = fontW
    labelStatus.y = fontH * 3.5
    
    LD2_InitElement @valueStatus, "", 31
    valueStatus.parent = @labelStatus
    valueStatus.x = fontW + len(labelStatus.text) * fontW + fontW
    valueStatus.y = labelStatus.y
    
    LD2_InitElement @labelHealth, "HEALTH:", 31
    labelHealth.parent = @dialog
    labelHealth.padding_x = fontW
    labelHealth.y = fontH * 5.0
    
    LD2_InitElement @valueHealth, "", 31
    valueHealth.parent = @labelHealth
    valueHealth.x = fontW + len(labelHealth.text) * fontW + fontW
    valueHealth.y = labelHealth.y
    
    LD2_InitElement @labelWeapon, "WEAPON:", 31
    labelWeapon.parent = @dialog
    labelWeapon.padding_x = fontW
    labelWeapon.y = fontH * 6.5
    
    LD2_InitElement @valueWeapon, "", 31
    valueWeapon.parent = @labelWeapon
    valueWeapon.x = fontW + len(labelWeapon.text) * fontW + fontW
    valueWeapon.y = labelWeapon.y
    
    LD2_InitElement @labelInventory, "     INVENTORY\==========================", 31
    labelInventory.parent = @dialog
    labelInventory.x = SCREEN_W - 19 * fontW - fontW
    labelInventory.y = fontH * 1
    
    LD2_InitElement @menuActions, "  USE     LOOK    MIX     DROP  ", 31, ElementFlags.MonospaceText
    menuActions.parent = @dialog
    menuActions.h = FONT_H
    menuActions.x = SCREEN_W - len(menuActions.text) * fontW
    menuActions.y = (labelInventory.y + fontH*2.5) + (8*fontH) + 2
    
    LD2_ClearElements
    LD2_AddElement @dialog
    LD2_AddElement @labelName
    LD2_AddElement @labelBottomBorder
    LD2_AddElement @labelStatus
    LD2_AddElement @valueStatus
    LD2_AddElement @labelHealth
    LD2_AddElement @valueHealth
    LD2_AddElement @labelWeapon
    LD2_AddElement @valueWeapon
    LD2_AddElement @labelInventory
    'LD2_AddElement @menuActions
    'for i = 0 to 3
    '    LD2_AddElement @labelActions(i)
    'next i
    for i = 0 to 7
        LD2_AddElement @labelItems(i)
        LD2_AddElement @labelItemsDecor(i)
    next i

	DO
		LD2_GetPlayer player
        
        '- show item that was picked up (lower-right corner of screen: "Picked Up Shotgun")
        '- copy steve scene sprites over
        
        SELECT CASE Player.life
        CASE IS > 80
            valueStatus.text = "Good"
            valueStatus.text_color = 56
        CASE IS > 50
            valueStatus.text = "OK"
            valueStatus.text_color = 168
        CASE IS > 20
            valueStatus.text = "Not Well"
            valueStatus.text_color = 88
        CASE IS > 10
            valueStatus.text = "Critical"
            valueStatus.text_color = 40
        CASE ELSE
            valueStatus.text = "Almost Dead"
            valueStatus.text_color = 40
        END SELECT
        
        SELECT CASE Player.weapon
        CASE FIST
            valueWeapon.text = "Fist"
        CASE SHOTGUN
            valueWeapon.text = "Shotgun"
        CASE MACHINEGUN
            valueWeapon.text = "Machinegun"
        CASE PISTOL
            valueWeapon.text = "Pistol"
        CASE DESERTEAGLE
            valueWeapon.text = "Magnum"
        END SELECT
        
        valueHealth.text = ltrim(str(Player.life))+"%"
        
        'LD2_PutText w, top+h*4, "STATUS: ", 1
        'LD2_PutTextCol w*9, top+h*4, strLife, clr, 1
        'LD2_PutText w, top+h*6, "HEALTH: "+LTRIM(STR(Player.life))+"%", 1
        'LD2_PutText w, top+h*8, "WEAPON: "+strWeapon, 1
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

		FOR i = 0 TO 7
			
			IF Inventory_GetItemBySlot(item, i) THEN
				'- error
			END IF
            
            LD2_initElement @labelItemsDecor(i), "[ " + space(15) + " ]", 31, ElementFlags.MonospaceText
            labelItemsDecor(i).parent = @dialog
            labelItemsDecor(i).h = FONT_H
            labelItemsDecor(i).x = SCREEN_W - len(labelItemsDecor(i).text) * fontW - fontW
            labelItemsDecor(i).y = int(labelInventory.y + fontH*2.5) + (i*fontH)
            LD2_initElement @labelItems(i), item.shortName, 31
            labelItems(i).h = FONT_H
            labelItems(i).parent = @dialog
            labelItems(i).x = labelItemsDecor(i).x + fontW * 2
            labelItems(i).y = labelItemsDecor(i).y
			
			IF i = selectedInventorySlot THEN
                labelItems(i).background = 70
				selected = item
			ELSE
                labelItems(i).background = -1
			END IF
			
		NEXT i
        
        LD2_CopyBuffer 2, 1
        LD2_RenderElements
		
		IF action = -1 THEN
			'itemStr = LTRIM$(RTRIM$(item.shortName))
			'itemStr = itemStr + SPC$(15-LEN(itemStr))
			'LD2_fillm INT((SCREEN_W-(w*LEN(itemStr)))/2)-7, top+h*13-1, w*LEN(itemStr)+1+12, h+1, 130, 1
			'LD2_PutTextCol INT((SCREEN_W-(w*LEN(itemStr)))/2), top + h * 13, itemStr, 15, 1
		ELSEIF mixMode THEN
            shortName = LTRIM(RTRIM(mixItem.shortName))
            LD2_PutText w * 21, h * 13, "Mix "+SPACE(LEN(shortName))+" with ", 1
            LD2_PutTextCol w * 25, h * 13, shortName, 56, 1
            LD2_PutTextCol w * (31+LEN(shortName)), h * 13, LTRIM(RTRIM(selected.shortName)), 31, 1
        ELSE
            FOR i = 0 TO 3
                LD2_InitElement @labelActions(i), "", 31, ElementFlags.MonospaceText
                labelActions(i).parent = @menuActions
                labelActions(i).h = FONT_H
				IF i = action THEN
                    labelActions(i).text = "< " + actions(i) + " >"
                    labelActions(i).x = menuActions.x + i * 8 * fontW
                    labelActions(i).y = menuActions.y
                    labelActions(i).background = 70
				ELSE
                    labelActions(i).text = "  " + actions(i) + "  "
                    labelActions(i).x = menuActions.x + i * 8 * fontW
                    labelActions(i).y = menuActions.y
                    labelActions(i).background = -1
				END IF
			NEXT i
            LD2_RenderElement @menuActions
            for i = 0 to 3
                LD2_RenderElement @labelActions(i)
            next i
		END IF
        
		LD2_RefreshScreen
        PullEvents

		IF canExit = 0 THEN
			IF (keyboard(KEY_TAB) = 0) or (keyboard(KEY_ESCAPE) = 0) THEN
				canExit = 1
			END IF
		ELSE
			IF keyboard(KEY_TAB) or keyboard(KEY_ESCAPE) THEN
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
						LD2_PlaySound Sounds.denied
					ELSE
						'action = -1
						LD2_PlaySound Sounds.select1
					END IF
				END IF
			END IF
			IF keyboard(KEY_DOWN) THEN
				keyOn = 1
				IF keyOff THEN
					selectedInventorySlot = selectedInventorySlot + 1
					IF selectedInventorySlot > 7 THEN
						selectedInventorySlot = 7
						LD2_PlaySound Sounds.denied
					ELSE
						'action = -1
						LD2_PlaySound Sounds.select1
					END IF
				END IF
			END IF
			IF keyboard(KEY_LEFT) THEN
				keyOn = 1
				IF keyOff THEN
					action = action - 1
					IF action < 0 THEN
						action = 0
						LD2_PlaySound Sounds.denied
					ELSE
						LD2_PlaySound Sounds.select1
					END IF
				END IF
			END IF
			IF keyboard(KEY_RIGHT) THEN
				keyOn = 1
				IF keyOff THEN
					action = action + 1
					IF action > 3 THEN
						action = 3
						LD2_PlaySound Sounds.denied
					ELSE
						LD2_PlaySound Sounds.select1
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
							LD2_PlaySound Sounds.look
							Look selected
						CASE 2  '- MIX
                            mixMode = 1
                            mixItem = selected
						CASE 3  '- Drop
							LD2_PlaySound Sounds.drop
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
	
	WaitForKeyup(KEY_TAB)
    WaitForKeyup(KEY_ESCAPE)
    
    LD2_PlaySound Sounds.status
	
	e = getEaseOutInterval(1)
	DO
		e = getEaseOutInterval(0, 3)
		'top = -INT(e * e * e * 96)
		'LD2_fillm 0, top, SCREEN_W, 96, 66, 1, STATUS_DIALOG_ALPHA
        LD2_CopyBuffer 2, 1
        dialog.h = e * 96
        LD2_RenderElement @dialog
		LD2_RefreshScreen
        PullEvents
	LOOP WHILE e > 0
	LD2_RestoreBuffer 2
	
END SUB

SUB UseItem (item AS InventoryType)

    dim id as integer
    dim qty as integer
    dim message as string
    dim success as integer
    
    success = Inventory_Use(item.id)
    message = Inventory_GetUseMessage()
    if success then
        id  = Inventory_GetUseItem()
        qty = Inventory_GetUseQty()
        if UseItemCallback <> 0 then
            UseItemCallback(id, qty)
        else
            message = "ERROR - No callback for UseItem"
        end if
    else
        LD2_PlaySound Sounds.denied
    end if
    
    ShowResponse message
	
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
    
    dim canExit as integer
    dim i as integer
    dim labelResponse as ElementType
    dim fontW as integer
    dim fontH as integer
    dim textW as integer
    dim revealStep as integer
    
    fontW = LD2_GetFontWidthWithSpacing()
    fontH = LD2_GetFontHeightWithSpacing()
    
    LD2_InitElement @labelResponse, "", 31, ElementFlags.AlignTextRight
    textW = LD2_GetElementTextWidth(@labelResponse)
    labelResponse.parent = LD2_GetRootParent()
    labelResponse.w = SCREEN_W - textW - fontW
    labelResponse.x = 0
    labelResponse.y = fontH * 11.5 + 2
    
    revealStep = int(len(response) / 20)
    if revealStep < 1 then revealStep = 1
    FOR i = 1 TO LEN(response) step revealStep
        labelResponse.text = left(response, i)
        LD2_RenderElements
        LD2_RenderElement @labelResponse
        LD2_RefreshScreen
        PullEvents
        'WaitSeconds 0.05
    NEXT i

    DO
        IF (INT(TIMER*3) AND 1) THEN
            labelResponse.text = response
        ELSE
            labelResponse.text = response + "_"
        END IF
        LD2_RenderElements
        LD2_RenderElement @labelResponse
        LD2_RefreshScreen
        PullEvents
        IF canExit = 0 THEN
            IF keyboard(KEY_ENTER) = 0 THEN
                canExit = 1
            END IF
        ELSE
            IF keyboard(KEY_ENTER) THEN
                EXIT DO
            END IF
        END IF
    LOOP

END SUB

function getEaseInInterval(doReset as integer = 0, speed as double = 1.0) as double
    
    static e as double
    
    if doReset then
        e = 0
    end if
    
    e += 0.0167 * speed
    if e > 1 then
        e = 1
    end if
    
    return e * e * e
    
end function

function getEaseOutInterval(doReset as integer = 0, speed as double = 1.0) as double
    
    static e as double
    
    if doReset then
        e = 0
    end if
    
    e += 0.0167 * speed
    if e > 1 then
        e = 1
    end if
    
    return (1 - e) * (1 - e) * (1 - e)
    
end function

function STATUS_DialogYesNo(message as string) as integer
    
    dim e as double
    dim pixels as integer
    dim halfX as integer
    dim halfY as integer
    dim x as integer
    dim y as integer
    dim w as integer
    dim h as integer
    
    dim dialog as ElementType
    dim title as ElementType
    dim optionYes as ElementType
    dim optionNo as ElementType
    
    dim selections(1) as integer
    dim selection as integer
    dim escapeSelection as integer
    
    dim fontW as integer
    dim fontH as integer
    
    fontW = LD2_GetFontWidthWithSpacing()
    fontH = LD2_GetFontHeightWithSpacing()
    
    LD2_InitElement @dialog
    LD2_InitElement @title, message, 31
    LD2_InitElement @optionYes, "YES", 31, ElementFlags.CenterX
    LD2_InitElement @optionNo, "NO ", 31, ElementFlags.CenterX
    
    dialog.background = STATUS_DIALOG_COLOR
    dialog.background_alpha = STATUS_DIALOG_ALPHA_UNIT
    dialog.border_width = 1
    dialog.border_color = 15
    
    halfX = 160
    halfY = 100
    
    dim modw as double: modw = 1.6
    dim modh as double: modh = 0.8
    
    LD2_PlaySound Sounds.status
	
	LD2_SaveBuffer 2
	LD2_CopyBuffer 1, 2
	
    getEaseInInterval(1)
	do
        e = getEaseInInterval(0, 3)
        pixels = int(e * 50)
        dialog.x = halfX - pixels * modw
        dialog.y = halfY - pixels * modh
        dialog.w = pixels * modw * 2
        dialog.h = pixels * modh * 2
        LD2_CopyBuffer 2, 1
        LD2_RenderElement @dialog
        LD2_RefreshScreen
        PullEvents
	loop while e < 1

    pixels = 50
    dialog.x = halfX - pixels * modw
    dialog.y = halfY - pixels * modh
    dialog.w = pixels * modw * 2
    dialog.h = pixels * modh * 2
    title.x = dialog.x + fontW
    title.y = dialog.y + fontH
    optionYes.y = halfY-fontH*1.5
    optionYes.padding_x = fontW: optionYes.padding_y = 2
    optionYes.background = 68
    optionYes.text_is_monospace = 1
    optionNo.y  = halfY+fontW*0.5
    optionNo.padding_x = fontW: optionNo.padding_y = 2
    optionNo.text_is_monospace = 1
    optionYes.background = 70
    
    LD2_ClearElements
    LD2_AddElement @dialog
    LD2_AddElement @title, @dialog
    LD2_AddElement @optionYes, @dialog
    LD2_AddElement @optionNo, @dialog
    
    selections(0) = Options.Yes
    selections(1) = Options.No: selection = 1: escapeSelection = 1
    
    do
        select case selections(selection)
        case Options.Yes
            optionYes.background = 70: optionYes.text_color = 31
            optionNo.background = STATUS_DIALOG_COLOR
            optionNo.text_color = 7
        case Options.No
            optionYes.background = STATUS_DIALOG_COLOR
            optionYes.text_color = 7
            optionNo.background = 70: optionNo.text_color = 31
        end select
        LD2_CopyBuffer 2, 1
        LD2_RenderElements
		LD2_RefreshScreen
        PullEvents
        if keyboard(KEY_ENTER) then
            LD2_PlaySound Sounds.look
            exit do
        end if
        if keyboard(KEY_DOWN) then
            selection += 1
            if selection > 1 then
                selection = 1: LD2_PlaySound Sounds.denied
            else
                LD2_PlaySound Sounds.select1
            end if
        end if
        if keyboard(KEY_UP) then
            selection -= 1
            if selection < 0 then
                selection = 0: LD2_PlaySound Sounds.denied
            else
                LD2_PlaySound Sounds.select1
            end if
        end if
        if keyboard(KEY_ESCAPE) then
            selection = escapeSelection
            LD2_PlaySound Sounds.status
            exit do
        end if
    loop
    
    LD2_ClearElements
    
    getEaseOutInterval(1)
	do
        pixels = int(e * 50)
        dialog.x = halfX - pixels * modw
        dialog.y = halfY - pixels * modh
        dialog.w = pixels * modw * 2
        dialog.h = pixels * modh * 2
        LD2_CopyBuffer 2, 1
        LD2_RenderElement @dialog
        LD2_RefreshScreen
        PullEvents
        e = getEaseOutInterval(0, 3)
	loop while e > 0
    
    LD2_CopyBuffer 2, 1
    LD2_RefreshScreen
    LD2_RestoreBuffer 2
    
    return selections(selection)
    
end function
