#include once "modules/inc/common.bi"
#include once "modules/inc/keys.bi"
#include once "modules/inc/ld2gfx.bi"
#include once "modules/inc/ld2snd.bi"
#include once "modules/inc/inventory.bi"
#include once "inc/ld2e.bi"
#include once "inc/ld2.bi"
#include once "inc/status.bi"

DECLARE SUB Drop (item AS InventoryType)
DECLARE SUB BuildStatusWindow (heading AS STRING, elementWindow as ElementType ptr, elementHeading as ElementType ptr, elementBorder as ElementType ptr)
DECLARE SUB Look (item AS InventoryType)
DECLARE SUB Mix (item0 AS InventoryType, item1 AS InventoryType)
declare function canMix (itemId as integer) as integer
DECLARE SUB RefreshStatusScreen ()
DECLARE SUB ShowResponse (response AS STRING, textColor as integer = -1)
declare function UseItem (item AS InventoryType) as integer

DIM SHARED selectedInventorySlot AS INTEGER
dim shared UseItemCallback as sub(byval id as integer, byval qty as integer, byref exitMenu as integer)
dim shared LookItemCallback as sub(id as integer, byref description as string)

const DATA_DIR = "data/"
const STATUS_DIALOG_ALPHA_UNIT = 0.75
const STATUS_DIALOG_ALPHA = 192
const STATUS_DIALOG_COLOR = 66

const STATUS_COLOR_SUCCESS = 56
const STATUS_COLOR_DENIED = 232

sub STATUS_SetUseItemCallback(callback as sub(byval id as integer, byval qty as integer, byref exitMenu as integer))
    
    UseItemCallback = callback
    
end sub

sub STATUS_SetLookItemCallback(callback as sub(id as integer, byref description as string))
    
    LookItemCallback = callback
    
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

sub RenderStatusScreen (action as integer = -1, mixItem as InventoryType ptr = 0)
    
    static dialog as ElementType
    static labelBottomBorder as ElementType
    static labelName as ElementType
    static labelStatus as ElementType: static valueStatus as ElementType
    static labelHealth as ElementType: static valueHealth as ElementType
    static labelWeapon as ElementType: static valueWeapon as ElementType
    static labelInventory as ElementType
    static labelItems(7) as ElementType
    static labelItemsDecor(7) as ElementType
    static menuActions as ElementType
    static labelActions(3) as ElementType
    static labelMixing as ElementType
    static labelMixName0 as ElementType
    static labelMixName1 as ElementType
    static fontW as integer
    static fontH as integer
    
    dim Player as PlayerType
    DIM item AS InventoryType
    dim selected as InventoryType
    dim i as integer
    dim mixingText as string
    DIM actions(3) AS STRING
	actions(0) = "USE "
	actions(1) = "LOOK"
	actions(2) = "MIX "
	actions(3) = "DROP"
    
    fontW = LD2_GetFontWidthWithSpacing()
    fontH = LD2_GetFontHeightWithSpacing()
    
    LD2_InitElement @dialog
    dialog.background = STATUS_DIALOG_COLOR
    dialog.background_alpha = STATUS_DIALOG_ALPHA_UNIT
    dialog.w = SCREEN_W
    dialog.h = 96
    
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
    for i = 0 to 7
        LD2_AddElement @labelItems(i)
        LD2_AddElement @labelItemsDecor(i)
    next i
    if (action <> -1) and (mixItem = 0) then
        LD2_AddElement @menuActions
        for i = 0 to 3
            LD2_AddElement @labelActions(i)
        next i
    end if
    if mixItem <> 0 then
        Inventory_GetItemBySlot(item, selectedInventorySlot)
        LD2_InitElement @labelMixName0, trim(mixItem->shortName), 88
        labelMixName0.parent = @dialog
        labelMixName0.y = menuActions.y
        LD2_InitElement @labelMixName1, iif(mixItem->id <> item.id, trim(item.shortName), "_____"), 184
        labelMixName1.parent = @dialog
        labelMixName1.y = menuActions.y
        mixingText = "Mix "+labelMixName0.text+" with "+labelMixName1.text+" "
        LD2_InitElement @labelMixing, mixingText, 216
        labelMixing.parent = @dialog
        labelMixing.x = SCREEN_W - LD2_GetElementTextWidth(@labelMixing) - fontW*1.5
        labelMixing.y = menuActions.y
        labelMixing.text = "Mix "
        labelMixName0.x = labelMixing.x + LD2_GetElementTextWidth(@labelMixing)+1 '+1 is font spacing
        labelMixing.text += labelMixName0.text+" with "
        labelMixName1.x = labelMixing.x + LD2_GetElementTextWidth(@labelMixing)+1
        labelMixing.text += labelMixName1.text+" "
        labelMixing.text += iif(int(timer*3) and 1, "?", " ")
        LD2_AddElement @labelMixing
        LD2_AddElement @labelMixName0
        LD2_AddElement @labelMixName1
    end if

    LD2_GetPlayer player
    
    '- show item that was picked up (lower-right corner of screen: "Picked Up Shotgun")
    '- copy steve scene sprites over
    
    SELECT CASE Player_GetItemQty(ItemIds.Hp)
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
    
    valueHealth.text = ltrim(str(Player_GetItemQty(ItemIds.Hp)))+"%"
    
    FOR i = 0 TO 7
        
        Inventory_GetItemBySlot(item, i)
        
        LD2_initElement @labelItemsDecor(i), "[ " + space(15) + " ]", 31, ElementFlags.MonospaceText
        labelItemsDecor(i).parent = @dialog
        labelItemsDecor(i).h = FONT_H
        labelItemsDecor(i).x = SCREEN_W - len(labelItemsDecor(i).text) * fontW - fontW
        labelItemsDecor(i).y = int(labelInventory.y + fontH*2.5) + (i*fontH)
        LD2_initElement @labelItems(i), item.shortName, 31
        labelItems(i).h = FONT_H
        labelItems(i).parent = @dialog
        labelItems(i).padding_x = 3
        labelItems(i).padding_y = 1
        labelItems(i).w = (FONT_W+1)*15 - labelItems(i).padding_x
        labelItems(i).x = labelItemsDecor(i).x + fontW * 2 - labelItems(i).padding_x
        labelItems(i).y = labelItemsDecor(i).y - labelItems(i).padding_y
        
        IF i = selectedInventorySlot THEN
            selected = item
            labelItems(i).background = 70
            if mixItem <> 0 then
                labelItems(i).background = 184
                labelItems(i).text_color = 22
            end if
        ELSE
            labelItems(i).background = -1
        END IF
        
        if (mixItem <> 0) then
            if (item.id = mixItem->id) then
                labelItems(i).text_color = 22
                labelItems(i).background = 88
            end if
        end if
        
    NEXT i
    
    if action >= 0 then
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
    END IF
    
end sub

function canMix (itemId as integer) as integer
    
    dim message as string
    
    select case itemId
    case ItemIds.NOTHING
        message = "Not Mixable."
    case ItemIds.ELEVATORMENU
        message = "The fuck is wrong with you?"
    case else
        return 1
    end select
    
    LD2_CopyBuffer 2, 1
    RenderStatusScreen
    LD2_PlaySound Sounds.uiDenied
    ShowResponse message, STATUS_COLOR_DENIED

    return 0
    
end function

SUB Drop (item AS InventoryType)
    
    dim message as string
    
    select case item.id
    case ItemIds.NOTHING
        message = "Not happening."
    case ItemIds.ElevatorMenu
        message = "Not happening."
    case else
        LD2_PlaySound Sounds.drop
        LD2_Drop item.id
        LD2_ClearInventorySlot item.slot
        RefreshStatusScreen
        LD2_CopyBuffer 2, 1
        RenderStatusScreen
        ShowResponse "Dropped " + trim(item.shortName), STATUS_COLOR_SUCCESS
        exit sub
    end select
    
    LD2_PlaySound Sounds.uiDenied
    RefreshStatusScreen
    LD2_CopyBuffer 2, 1
    RenderStatusScreen
    ShowResponse message, STATUS_COLOR_DENIED
    
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
	DIM selectedRoom AS INTEGER
	DIM selectedFilename AS STRING
    dim selectedLabel as string
	DIM topFloor AS INTEGER
	DIM btmFloor AS INTEGER
	DIM ElevatorFile AS INTEGER
	
	DIM floors(50) AS tFloor
	DIM numFloors AS INTEGER
	DIM scroll AS INTEGER
	DIM doLoadMap AS INTEGER
    dim current as integer
    
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
    
    LD2_PlaySound Sounds.uiMenu
	
    dim roomsFile as string
    roomsFile = iif(LD2_hasFlag(CLASSICMODE),"2002/tables/rooms.txt","tables/rooms.txt")
	ElevatorFile = FREEFILE
	OPEN DATA_DIR+roomsFile FOR INPUT AS ElevatorFile
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
		
        IF keypress(KEY_TAB) or keypress(KEY_ESCAPE) or keypress(KEY_E) or mouseRB() or mouseMB() THEN
            EXIT DO
        END IF
        
        '- TODO: hold down for one second, then scroll down with delay
        current = selectedRoom
        if keypress(KEY_1) or keypress(KEY_KP_1) then
            for i = 0 to numFloors - 1
                if floors(i).floorNo = 1 then
                    LD2_PlaySound Sounds.uiArrows
                    selectedRoom = (numFloors - i - 1) 
                    exit for
                end if
            next i
        end if
        IF keypress(KEY_UP) or keypress(KEY_W) or mouseWheelUp() THEN
            selectedRoom = selectedRoom + 1
            if selectedRoom <= numFloors - 1 then
                while (selectedRoom <= numFloors-1)
                    if trim(floors(numFloors-1-selectedRoom).filename) = "" then
                        selectedRoom = selectedRoom + 1
                    else
                        exit while
                    end if
                wend
            end if
            IF selectedRoom > numFloors - 1 THEN
                selectedRoom = current
                LD2_PlaySound Sounds.uiInvalid
            ELSE
                LD2_PlaySound Sounds.uiArrows
            END IF
        END IF
        IF keypress(KEY_DOWN) or keypress(KEY_S) or mouseWheelDown() THEN
            selectedRoom = selectedRoom - 1
            if selectedRoom >= 0 then
                while (selectedRoom >= 0)
                    if trim(floors(numFloors-1-selectedRoom).filename) = "" then
                        selectedRoom = selectedRoom - 1
                    else
                        exit while
                    end if
                wend
            end if
            IF selectedRoom < 0 THEN
                selectedRoom = current
                LD2_PlaySound Sounds.uiInvalid
            ELSE
                LD2_PlaySound Sounds.uiArrows
            END IF
        END IF
        IF keypress(KEY_ENTER) or keypress(KEY_SPACE) or mouseLB() THEN
            LD2_PlaySound Sounds.uiSelect
            Player_SetItemQty ItemIds.CurrentRoom, selectedRoom
            doLoadMap = 1
            EXIT DO
        END IF
	LOOP
	
	WaitForKeyup(KEY_TAB)
    WaitForKeyup(KEY_ESCAPE)
    WaitForKeyup(KEY_E)
    while mouseLB(): PullEvents: wend
    while mouseRB(): PullEvents: wend
    while mouseMB(): PullEvents: wend
    
    LD2_PlaySound Sounds.uiMenu
	
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
		Map_Load selectedFilename
        Player_Hide
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
    if LookItemCallback <> 0 then
        LookItemCallback(item.id, desc)
    end if
	IF desc = "" THEN
		desc = "No description found for item id: " + STR(item.id)
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
        LD2_CopyBuffer 2, 1
        LD2_RenderElements
        LD2_RenderElement @textDescription
        LD2_RefreshScreen
        PullEvents
    next i
    
    textDescription.text = desc
    LD2_CopyBuffer 2, 1
    LD2_RenderElements
    LD2_RenderElement @textDescription
    LD2_RefreshScreen
	
	DO
        PullEvents
		IF keypress(KEY_ENTER) or keypress(KEY_TAB) or keypress(KEY_ESCAPE) or keypress(KEY_E) or mouseLB() or mouseRB() or mouseMB() THEN
			EXIT DO
        END IF
	LOOP
    
    while mouseLB(): PullEvents: wend
    while mouseRB(): PullEvents: wend
    while mouseMB(): PullEVents: wend
    
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
    Inventory_AddHidden(ItemIds.Hp, Player_GetItemQty(ItemIds.Hp))
    Inventory_AddHidden(ItemIds.ShotgunLoaded   , Player_GetItemQty(ItemIds.ShotgunAmmo   ))
    Inventory_AddHidden(ItemIds.PistolLoaded    , Player_GetItemQty(ItemIds.PistolAmmo    ))
    Inventory_AddHidden(ItemIds.MachineGunLoaded, Player_GetItemQty(ItemIds.MachineGunAmmo))
    Inventory_AddHidden(ItemIds.MagnumLoaded    , Player_GetItemQty(ItemIds.MagnumAmmo    ))
    Inventory_AddHidden(ItemIds.Active410       , Player_GetItemQty(ItemIds.Active410     ))
    Inventory_RefreshNames
    
END SUB

SUB StatusScreen
	
	LD2_LogDebug "StatusScreen ()"
	
	dim dialog as ElementType
    dim selected as InventoryType
    dim mixMode as integer
    dim mixSlot as integer
    dim mixItem as InventoryType
	dim action as integer
    dim e as double
	
    LD2_PlaySound Sounds.uiMenu
    
    LD2_SaveBuffer 2
	LD2_CopyBuffer 1, 2
    
    LD2_InitElement @dialog
    dialog.background = STATUS_DIALOG_COLOR
    dialog.background_alpha = STATUS_DIALOG_ALPHA_UNIT
    dialog.w = SCREEN_W
	
	e = getEaseInInterval(1)
	do
        e = getEaseInInterval(0, 3)
		LD2_CopyBuffer 2, 1
        dialog.h = e * 96
        LD2_RenderElement @dialog
		LD2_RefreshScreen
        PullEvents
	loop while e < 1
    
    dialog.h = 96
    LD2_RenderElement @dialog
    LD2_RefreshScreen
    
    RefreshStatusScreen
	action = -1

	do
		LD2_CopyBuffer 2, 1
        RenderStatusScreen action, iif(mixMode, @mixItem, 0)
        LD2_RenderElements
        LD2_RefreshScreen
        PullEvents
        
        Inventory_GetItemBySlot(selected, selectedInventorySlot)
        
        IF keypress(KEY_TAB) or keypress(KEY_ESCAPE) or keypress(KEY_E) or mouseRB() or mouseMB() THEN
            IF action > -1 THEN
                while mouseRB(): PullEvents: wend
                while mouseMB(): PullEvents: wend
                LD2_PlaySound Sounds.uiCancel
                action = -1
            ELSE
                EXIT DO
            END IF
        END IF
            
        '- TODO: hold down for one second, then scroll down with delay
        IF keypress(KEY_UP) or keypress(KEY_W) or (action = -1 and mouseWheelUp()) THEN
            if action >= 0 then
                LD2_PlaySound Sounds.uiCancel
                action = -1
            else
                selectedInventorySlot = selectedInventorySlot - 1
                if mixMode and (mixSlot = selectedInventorySlot) then
                    selectedInventorySlot -= 1
                end if
                IF selectedInventorySlot < 0 THEN
                    selectedInventorySlot = iif(mixMode and (mixSlot = 0), 1, 0)
                    LD2_PlaySound Sounds.uiInvalid
                ELSE
                    LD2_PlaySound Sounds.uiArrows
                END IF
            end if
        END IF
        IF keypress(KEY_DOWN) or keypress(KEY_S) or (action =-1 and mouseWheelDown()) THEN
            if action >= 0 then
                LD2_PlaySound Sounds.uiCancel
                action = -1
            else
                selectedInventorySlot = selectedInventorySlot + 1
                if mixMode and (mixSlot = selectedInventorySlot) then
                    selectedInventorySlot += 1
                end if
                IF selectedInventorySlot > 7 THEN
                    selectedInventorySlot = iif(mixMode and (mixSlot = 7), 6, 7)
                    LD2_PlaySound Sounds.uiInvalid
                ELSE
                    LD2_PlaySound Sounds.uiArrows
                END IF
            end if
        END IF
        IF keypress(KEY_LEFT) or (action >= 0 and mouseWheelDown()) THEN
            if action = -1 then
                LD2_PlaySound Sounds.uiSubmenu
                action = 0
            else
                action = action - 1
                IF action < 0 THEN
                    action = 0
                    LD2_PlaySound Sounds.uiInvalid
                ELSE
                    LD2_PlaySound Sounds.uiArrows
                END IF
            end if
        END IF
        IF keypress(KEY_RIGHT) or (action >= 0 and mouseWheelUp()) THEN
            if action = -1 then
                LD2_PlaySound Sounds.uiSubmenu
                action = 0
            else
                action = action + 1
                IF action > 3 THEN
                    action = 3
                    LD2_PlaySound Sounds.uiInvalid
                ELSE
                    LD2_PlaySound Sounds.uiArrows
                END IF
            end if
        END IF
        if keypress(KEY_ENTER) or keypress(KEY_SPACE) or mouseLB() then
            while mouseLB(): PullEvents: wend
            if mixMode then
                Mix mixItem, selected
                mixMode = 0
                action = -1
            elseif action > -1 then
                select case action
                case 0  '- USE
                    if UseItem(selected) then
                        exit do
                    end if
                    action = -1
                case 1  '- LOOK
                    LD2_PlaySound Sounds.uiSelect
                    Look selected
                    action = -1
                    LD2_PlaySound Sounds.uiSubmenu
                case 2  '- MIX
                    if canMix(selected.id) then
                        mixMode = 1
                        mixItem = selected
                        mixSlot = selectedInventorySlot
                        action = -1
                        LD2_PlaySound Sounds.uiSubmenu
                    end if
                case 3  '- Drop
                    Drop selected
                    action = -1
                end select
            else
                'if selected.id > 0 then
                    action = 0
                    LD2_PlaySound Sounds.uiSubmenu
                'else
                '    LD2_PlaySound Sounds.uiInvalid
                'end if
            end if
        end if
	loop
	
	WaitForKeyup(KEY_TAB)
    WaitForKeyup(KEY_ESCAPE)
    WaitForKeyup(KEY_E)
    WaitForKeyup(KEY_ENTER)
    while mouseLB(): PullEvents: wend
    while mouseRB(): PullEvents: wend
    while mouseMB(): PullEvents: wend
    
    LD2_PlaySound Sounds.uiMenu
	
	e = getEaseOutInterval(1)
	do
		e = getEaseOutInterval(0, 3)
		LD2_CopyBuffer 2, 1
        dialog.h = e * 96
        LD2_RenderElement @dialog
		LD2_RefreshScreen
        PullEvents
	loop while e > 0
	LD2_RestoreBuffer 2
	
end sub

function UseItem (item AS InventoryType) as integer

    dim id as integer
    dim qty as integer
    dim message as string
    dim success as integer
    dim discard as integer
    dim textColor as integer
    dim exitMenu as integer
    
    exitMenu = 0
    if item.id = ItemIds.NOTHING then
        message = "Not usable."
    else
        success = Inventory_Use(item.id)
        message = Inventory_GetUseMessage()
    end if
    if success then
        id  = Inventory_GetUseItem()
        qty = Inventory_GetUseQty()
        discard = Inventory_GetUseItemDiscard()
        if discard then
            LD2_AddToStatus item.id, -qty
            RefreshStatusScreen
        end if
        if UseItemCallback <> 0 then
            UseItemCallback(id, qty, exitMenu)
        else
            message = "ERROR - No callback for UseItem"
        end if
        textColor = STATUS_COLOR_SUCCESS
    else
        LD2_PlaySound Sounds.uiDenied
        textColor = STATUS_COLOR_DENIED
    end if
    
    if exitMenu = 0 then
        LD2_CopyBuffer 2, 1
        RenderStatusScreen
        ShowResponse message, textColor
    end if
    
    return exitMenu
	
end function

SUB Mix (item0 AS InventoryType, item1 AS InventoryType)
    
    DIM msg AS STRING
    DIM resultId AS INTEGER
    dim textColor as integer
    
    resultId = Inventory_Mix(item0.id, item1.id, msg)
    
    IF resultId <> -1 THEN
        LD2_ClearInventorySlot item0.slot
        LD2_ClearInventorySlot item1.slot
        LD2_AddToStatus(resultId, 1)
        RefreshStatusScreen
        LD2_PlaySound Sounds.uiMix
        textColor = STATUS_COLOR_SUCCESS
    else
        LD2_PlaySound Sounds.uiDenied
        textColor = STATUS_COLOR_DENIED
    END IF
    
    LD2_CopyBuffer 2, 1
    RenderStatusScreen
    
    ShowResponse msg, textColor
    
END SUB

SUB ShowResponse (response AS STRING, textColor as integer = -1)
    
    dim i as integer
    dim labelResponse as ElementType
    dim fontW as integer
    dim fontH as integer
    dim textW as integer
    dim revealStep as integer
    
    fontW = LD2_GetFontWidthWithSpacing()
    fontH = LD2_GetFontHeightWithSpacing()
    
    LD2_InitElement @labelResponse, response, 31
    textW = LD2_GetElementTextWidth(@labelResponse)
    labelResponse.parent = LD2_GetRootParent()
    labelResponse.x = SCREEN_W - textW - fontW*1.5
    labelResponse.y = fontH * 11.5 + 2
    
    if textColor >= 0 then
        labelResponse.text_color = textColor
    end if
    
    revealStep = 2'int(len(response) / 20)
    if revealStep < 1 then revealStep = 1
    FOR i = 1 TO LEN(response) step revealStep
        labelResponse.text = left(response, i)
        LD2_CopyBuffer 2, 1
        LD2_RenderElements
        LD2_RenderElement @labelResponse
        LD2_RefreshScreen
        PullEvents
    NEXT i

    DO
        IF (INT(TIMER*3) AND 1) THEN
            labelResponse.text = response
        ELSE
            labelResponse.text = response + "_"
        END IF
        LD2_CopyBuffer 2, 1
        LD2_RenderElements
        LD2_RenderElement @labelResponse
        LD2_RefreshScreen
        PullEvents
        IF keypress(KEY_ENTER) or keypress(KEY_ESCAPE) or keypress(KEY_E) or mouseLB() or mouseRB() or mouseMB() THEN
            LD2_PlaySound Sounds.uiArrows
            EXIT DO
        END IF
    LOOP
    
    while mouseLB(): PullEvents: wend
    while mouseRB(): PullEvents: wend
    while mouseMB(): PullEvents: wend

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
    
    LD2_PlaySound Sounds.uiMenu
	
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
        if keypress(KEY_ENTER) then
            LD2_PlaySound Sounds.uiSelect
            exit do
        end if
        if keypress(KEY_DOWN) then
            selection += 1
            if selection > 1 then
                selection = 1: LD2_PlaySound Sounds.uiInvalid
            else
                LD2_PlaySound Sounds.uiArrows
            end if
        end if
        if keypress(KEY_UP) then
            selection -= 1
            if selection < 0 then
                selection = 0: LD2_PlaySound Sounds.uiInvalid
            else
                LD2_PlaySound Sounds.uiArrows
            end if
        end if
        if keypress(KEY_ESCAPE) then
            selection = escapeSelection
            LD2_PlaySound Sounds.uiCancel
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
