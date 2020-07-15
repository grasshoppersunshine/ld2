#include once "modules/inc/common.bi"
#include once "modules/inc/keys.bi"
#include once "modules/inc/ld2gfx.bi"
#include once "modules/inc/ld2snd.bi"
#include once "modules/inc/inventory.bi"
#include once "modules/inc/elements.bi"
#include once "inc/ld2e.bi"
#include once "inc/ld2.bi"
#include once "inc/status.bi"

declare sub Drop (item AS InventoryType)
declare sub BuildStatusWindow (heading AS STRING, elementWindow as ElementType ptr, elementHeading as ElementType ptr, elementBorder as ElementType ptr)
declare function Look (item AS InventoryType, skipInput as integer = 0) as integer
declare sub Mix (item0 AS InventoryType, item1 AS InventoryType)
declare function CanMix (itemId as integer) as integer
declare function ShowResponse (response as string = "", textColor as integer = -1, skipInput as integer = 0) as integer
declare function UseItem (item AS InventoryType) as integer

dim shared selectedInventorySlot as integer

dim shared BeforeUseItemCallback as sub(byval id as integer)
dim shared UseItemCallback as sub(byval id as integer, byval qty as integer, byref exitMenu as integer)
dim shared LookItemCallback as sub(id as integer, byref description as string)

const DATA_DIR = "data/"
const STATUS_DIALOG_ALPHA = 0.75
const STATUS_DIALOG_COLOR = 66
const STATUS_EASE_SPEED = 0.3333

const STATUS_COLOR_SUCCESS = 56
const STATUS_COLOR_DENIED = 232

const ITEM_BORDER_COLOR = 77
const ITEM_SELECTED_BG = 70
const ITEM_NOT_SELECTED_BG = 77

const ACTION_SELECTED_BG = 70
const ACTION_NOT_SELECTED_BG = -1

const MIX_TEXT_COLOR = 216
const MIX_SUBJECT_BG = 31 '88
const MIX_SUBJECT_FG = 22
const MIX_OBJECT_BG = 184 '184
const MIX_OBJECT_FG = 22

const PI = 3.141592

sub STATUS_SetBeforeUseItemCallback(callback as sub(byval id as integer))
    
    BeforeUseItemCallback = callback
    
end sub

sub STATUS_SetUseItemCallback(callback as sub(byval id as integer, byval qty as integer, byref exitMenu as integer))
    
    UseItemCallback = callback
    
end sub

sub STATUS_SetLookItemCallback(callback as sub(id as integer, byref description as string))
    
    LookItemCallback = callback
    
end sub

function STATUS_InitInventory() as integer
    
    return Inventory_Init(16, 8)
    
end function

SUB BuildStatusWindow (heading AS STRING, elementWindow as ElementType ptr, elementHeading as ElementType ptr, elementBorder as ElementType ptr)
	
	dim fontW as integer
    dim fontH as integer
	
	fontW = Elements_GetFontWidthWithSpacing()
    fontH = Elements_GetFontHeightWithSpacing()
	
    Element_Init elementWindow
    elementWindow->background = STATUS_DIALOG_COLOR
    elementWindow->background_alpha = STATUS_DIALOG_ALPHA
    elementWindow->padding_x = fontW
    elementWindow->padding_y = fontH
    elementWindow->w = SCREEN_W-elementWindow->padding_x*2
    elementWindow->h = 96-elementWindow->padding_y*2
    
    Element_Init elementHeading, heading, 31, ElementFlags.CenterText '+"\"+string(45, "-"), 31
    elementHeading->parent = elementWindow
    elementHeading->w = int(SCREEN_W*0.25)
    
    dim starw as integer
    dim starc as integer
    starw = Element_GetTextWidth(elementWindow, "*")+1
    starc = int(SCREEN_W/starw)
    Element_Init elementBorder, STRING(starc, "*"), 31
    elementBorder->y = elementWindow->y+elementWindow->padding_y+elementWindow->h
    elementBorder->padding_x = int((SCREEN_W-starw*starc)*0.5)
    
    Elements_Clear
    Elements_Add elementWindow
    Elements_Add elementHeading
    Elements_Add elementBorder
	
END SUB

sub RenderStatusScreen (action as integer = -1, mixItem as InventoryType ptr = 0, mixItemWith as InventoryType ptr = 0)
    
    static dialog as ElementType
    static labelBottomBorder as ElementType
    static labelName as ElementType
    static labelStatus as ElementType: static valueStatus as ElementType
    static labelHealth as ElementType: static valueHealth as ElementType
    static labelWeapon as ElementType: static valueWeapon as ElementType
    static labelCards  as ElementType: static valueCards as ElementType
    static labelInventory as ElementType
    static labelItems(7) as ElementType
    static labelItemsQty(7) as ElementType
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
    dim lft as integer
    dim top as integer
    dim x as integer, y as integer
    dim n as integer
    dim i as integer
    DIM actions(3) AS STRING
	actions(0) = "USE"
	actions(1) = "LOOK"
	actions(2) = "MIX"
	actions(3) = "DROP"
    
    fontW = Elements_GetFontWidthWithSpacing()
    fontH = Elements_GetFontHeightWithSpacing()
    
    Element_Init @dialog
    dialog.background = STATUS_DIALOG_COLOR
    dialog.background_alpha = STATUS_DIALOG_ALPHA
    dialog.padding_x = fontW
    dialog.padding_y = fontH
    dialog.w = SCREEN_W-dialog.padding_x*2
    dialog.h = 96-dialog.padding_y*2
    
    dim starw as integer
    dim starc as integer
    starw = Element_GetTextWidth(@dialog, "*")+1
    starc = int(SCREEN_W/starw)
    Element_Init @labelBottomBorder, STRING(starc, "*"), 31
    labelBottomBorder.y = dialog.y+dialog.padding_y+dialog.h
    labelBottomBorder.padding_x = int((SCREEN_W-starw*starc)*0.5)
    
    '*******************************************************************
    '* HEADING
    '*******************************************************************
    Element_Init @labelName, "LARRY  [ THE DINOSAUR ]\--------------------------", 31
    labelName.parent = @dialog
    
    '*******************************************************************
    '* STATUS
    '*******************************************************************
    Element_Init @labelStatus, "STATUS", 31
    labelStatus.parent = @dialog
    labelStatus.y = fontH * 2.5
    labelStatus.w = FONT_W * 20
    
    Element_Init @valueStatus, "", 31
    valueStatus.parent = @labelStatus
    valueStatus.x = FONT_W * 7
    
    '*******************************************************************
    '* HEALTH
    '*******************************************************************
    Element_Init @labelHealth, "HEALTH", 31
    labelHealth.parent = @dialog
    labelHealth.y = fontH * 4.0
    labelHealth.w = FONT_W * 20
    
    Element_Init @valueHealth, "", 31
    valueHealth.parent = @labelHealth
    valueHealth.x = FONT_W * 7
    
    '*******************************************************************
    '* WEAPON
    '*******************************************************************
    Element_Init @labelWeapon, "WEAPON", 31
    labelWeapon.parent = @dialog
    labelWeapon.y = fontH * 5.5
    labelWeapon.w = FONT_W * 20
    
    Element_Init @valueWeapon, "", 31
    valueWeapon.parent = @labelWeapon
    valueWeapon.x = FONT_W * 7
    
    '*******************************************************************
    '* CARDS
    '*******************************************************************
    Element_Init @labelCards, "CARDS", 31
    labelCards.parent = @dialog
    labelCards.y = fontH * 8.0
    labelCards.w = FONT_W * 20
    
    Element_Init @valueCards, "", 31
    valueCards.parent = @labelCards
    valueCards.x = FONT_W * 7
    
    '*******************************************************************
    '* INVENTORY
    '*******************************************************************
    Element_Init @labelInventory, "INVENTORY\----------------------------", 31
    labelInventory.parent = @dialog
    
    '*******************************************************************
    '* ACTIONS MENU
    '*******************************************************************
    Element_Init @menuActions, "USE  LOOK  MIX  DROP", 31, ElementFlags.AlignTextRight
    menuActions.parent = @dialog
    menuActions.y = menuActions.parent->h - fontH
    menuActions.x = menuActions.parent->w - Element_GetTextWidth(@menuActions)
    
    Elements_Clear
    Elements_Add @dialog
    Elements_Add @labelName
    Elements_Add @labelBottomBorder
    Elements_Add @labelStatus
    Elements_Add @valueStatus
    Elements_Add @labelHealth
    Elements_Add @valueHealth
    Elements_Add @labelWeapon
    Elements_Add @valueWeapon
    Elements_Add @labelCards
    Elements_Add @valueCards
    Elements_Add @labelInventory
    for i = 0 to 8
        Elements_Add @labelItems(i)
    next i
    if (action <> -1) and (mixItem = 0) then
        Elements_Add @menuActions
        for n = 0 to 3
            Element_Init @labelActions(n), actions(n), 31
            labelActions(n).parent = @dialog
            labelActions(n).h = FONT_H
            labelActions(n).text_height = 1
            labelActions(n).padding_x = fontW
            labelActions(n).x = menuActions.x - labelActions(n).padding_x
            labelActions(n).y = menuActions.y
            i = instr(menuActions.text, actions(n))
            if i > len(actions(0)) then
                labelActions(n).x += Element_GetTextWidth(@menuActions, left(menuActions.text, i-1))+1
            end if
            Elements_Add @labelActions(n)
        next n
    end if
    static labelMix as ElementType
    static labelWith as ElementType
    static mixSubject as ElementType
    static mixObject as ElementType
    if mixItem <> 0 then
        dim subname as string
        dim objname as string
        Inventory_GetItemBySlot(item, selectedInventorySlot)
        subname = trim(mixItem->shortName)
        if mixItemWith <> 0 then
            objname = trim(mixItemWith->shortName)
        else
            objname = iif(mixItem->id <> item.id, trim(item.shortName)+" ", "")
            if (int(timer*3) and 1) then objname += "?"
            Element_Init @labelMix, "MIX", MIX_TEXT_COLOR
        end if
        Element_Init @labelWith, iif(mixItemWith = 0, "WITH", "/"), MIX_TEXT_COLOR
        Element_Init @mixSubject, subname, MIX_SUBJECT_BG
        Element_Init @mixObject, objname, MIX_OBJECT_BG
        Elements_Add @labelMix  , @dialog
        Elements_Add @labelWith , @dialog
        Elements_Add @mixSubject, @dialog
        Elements_Add @mixObject , @dialog
    end if

    Player_Get player
    
    static cards(5) as ElementType
    for n = GREENACCESS to Player_GetAccessLevel()
        Element_Init @cards(n), "", 31, ElementFlags.SpriteCenterX or ElementFlags.SpriteCenterY
        cards(n).parent = @dialog
        cards(n).w = SPRITE_W*1.0
        cards(n).h = SPRITE_H*1.0
        cards(n).parent = @dialog
        cards(n).x = (n-1) * 16 - 3
        cards(n).y = fontH * 8.5
        cards(n).sprite = MapItems_GetCardSprite(n)
        cards(n).sprite_set_id = idOBJCRP
        cards(n).sprite_zoom = 1.5
        Elements_Add @cards(n)
    next n
    
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
    CASE ItemIds.Fist
        valueWeapon.text = "Fist"
    CASE ItemIds.Shotgun
        valueWeapon.text = "Shotgun"
    CASE ItemIds.MachineGun
        valueWeapon.text = "Machinegun"
    CASE ItemIds.Handgun
        valueWeapon.text = "Handgun"
    CASE ItemIds.Magnum
        valueWeapon.text = "Magnum"
    END SELECT
    
    valueHealth.text = ltrim(str(Player_GetItemQty(ItemIds.Hp)))+"%"
    
    dim qty as integer
    dim colW as integer
    dim cspc as integer
    dim rowH as integer
    dim rspc as integer
    dim numCols as integer
    dim numRows as integer
    
    colW = SPRITE_W*2.00: cspc = SPRITE_W*0.25: numCols = 4
    rowH = SPRITE_H*1.25: rspc = SPRITE_H*0.25: numRows = 2
    lft = dialog.w - (colW+cspc)*numCols + cspc
    top = 0
    
    labelInventory.x = lft
    labelInventory.y = top: top += fontH*2.5
    
    static labelItemName as ElementType
    if mixItem = 0 then
        Element_Init @labelItemName, "", 31
        labelItemName.parent = @dialog
        labelItemName.x = lft
        labelItemName.y = top+(rowH+rspc)*numRows
        Elements_Add @labelItemName
    else
        labelMix.x   = lft-Element_GetTextWidth(@labelMix, labelMix.text+" ")-1
        labelMix.y   = top+(rowH+rspc)*numRows
        mixSubject.x = lft
        mixSubject.y = labelMix.y
        if mixItemWith = 0 then
            labelWith.x  = lft-Element_GetTextWidth(@labelWith, labelWith.text+" ")-1
            labelWith.y  = top+(rowH+rspc)*numRows+fontH
            mixObject.x  = lft
            mixObject.y  = labelWith.y
        else
            labelWith.x  = labelMix.x+Element_GetTextWidth(@labelMix, labelMix.text+" "+mixSubject.text+" ")-1
            labelWith.y  = labelMix.y
            mixObject.x  = labelWith.x+Element_GetTextWidth(@labelMix, labelWith.text+" ")-1
            mixObject.y  = labelWith.y
            if mixObject.x + Element_GetTextWidth(@mixObject) > mixObject.parent->w then
                for n = len(mixObject.text)-1 to 1 step -1
                    if mixObject.x + Element_GetTextWidth(@mixObject, left(mixObject.text, n)) <= mixObject.parent->w then
                        mixObject.text = left(mixObject.text, n-1)+"..."
                        exit for
                    end if
                next n
            end if
        end if
    end if
    
    i = -1
    for y = 0 to numRows-1
        for x = 0 to numCols-1
            
            i += 1
            Inventory_GetItemBySlot(item, i)
            
            Element_Init @labelItems(i), iif(item.max = 1, "", str(item.qty)), 31, ElementFlags.SpriteCenterX or ElementFlags.SpriteCenterY
            labelItems(i).parent = @dialog
            labelItems(i).padding_x = 3
            labelItems(i).padding_y = 1
            labelItems(i).border_size = 1
            labelItems(i).w = colW - labelItems(i).padding_x*2 - labelItems(i).border_size*2
            labelItems(i).h = rowH - labelItems(i).padding_y*2 - labelItems(i).border_size*2
            labelItems(i).border_color = ITEM_BORDER_COLOR
            labelItems(i).x = lft + x * (colW+cspc)
            labelItems(i).y = top + y * (rowH+rspc)
            labelItems(i).sprite = item.id
            labelItems(i).sprite_set_id = idOBJCRP
            
            if i = selectedInventorySlot then
                selected = item
                labelItemName.text = trim(item.shortName)
                labelItems(i).background = ITEM_SELECTED_BG
                if mixItem <> 0 then
                    labelItems(i).background = MIX_OBJECT_BG
                    labelItems(i).text_color = MIX_OBJECT_FG
                end if
            else
                labelItems(i).background = ITEM_NOT_SELECTED_BG
                labelItems(i).background_alpha = 0.5
            end if
            
            if (mixItem <> 0) then
                if (item.id = mixItem->id) then
                    labelItems(i).background = MIX_SUBJECT_BG
                    labelItems(i).text_color = MIX_SUBJECT_FG
                    labelItems(i).background_alpha = 1.0
                end if
            end if
            
        next x
    next y
    
    if action >= 0 then
        for i = 0 to 3
            labelActions(i).background = iif(i = action, ACTION_SELECTED_BG, ACTION_NOT_SELECTED_BG)
        next i
    end if
    
end sub

function CanMix (itemId as integer) as integer
    
    dim message as string
    
    select case itemId
    case ItemIds.NOTHING
        message = "Not Mixable."
    case ItemIds.ELEVATORMENU
        message = "The fuck is wrong with you?"
    case else
        return 1
    end select
    
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
        STATUS_RefreshInventory
        ShowResponse "Dropped " + trim(item.shortName), STATUS_COLOR_SUCCESS
        exit sub
    end select
    
    LD2_PlaySound Sounds.uiDenied
    STATUS_RefreshInventory
    ShowResponse message, STATUS_COLOR_DENIED
    
END SUB

function EStatusScreen (byval currentRoomId as integer, byref selectedRoomId as integer, byref selectedRoomName as string, byval skipInput as integer = 0) as integer
	
	LD2_LogDebug "LD2_EStatusScreen ("+str(currentRoomId)+","+str(selectedRoomId)+","+selectedRoomName+","+str(skipInput)+" )"
	
    static state as integer = DialogStates.closed
    
    static swipe as ElementType
    static menuWindow as ElementType
    static menuTitle as ElementType
    static menuBorder as ElementType
    static container as ElementType
    static listFloors as ElementType
    static menuNumbers() as ElementType
    static menuLabels() as ElementType
    static floors() AS FloorInfoType
    
    static e as double = -1
    
    static roomId as integer
    static roomName as string
	static floorsMin as integer
    static floorsMax as integer
    static numLabels as integer
    
    dim ElevatorFile as integer
    dim fontW as integer
    dim fontH as integer
    
    dim i as integer
    
    fontW = Elements_GetFontWidthWithSpacing()
    fontH = Elements_GetFontHeightWithSpacing()
	
	select case state
    case DialogStates.closed
        Element_Init @swipe, "", 31
        swipe.background = STATUS_DIALOG_COLOR
        swipe.background_alpha = STATUS_DIALOG_ALPHA
        swipe.h = SCREEN_H
        state = DialogStates.opening
        return 0
    case DialogStates.opening
        if e = -1 then
            e = getEaseInOutInterval(1)
            LD2_PlaySound Sounds.uiMenu
        else
            e = getEaseInOutInterval(0, STATUS_EASE_SPEED)
        end if
        swipe.w = int(e * 156)
        Element_Render @swipe
        if e = 1 then
            e = -1
            state = DialogStates.init
        end if
        return 0
    case DialogStates.closing
        if e = -1 then
            e = getEaseInOutInterval(1)
            LD2_PlaySound Sounds.uiMenu
        else
            e = getEaseInOutInterval(0, STATUS_EASE_SPEED)
        end if
        swipe.w = int((1-e) * 156)
        Element_Render @swipe
        if e = 1 then
            e = -1
            state = DialogStates.closed
            return 1
        end if
        return 0
    case DialogStates.init
        state = DialogStates.ready
        selectedRoomId = currentRoomId
        roomId = currentRoomId
        floorsMin = 0
        floorsMax = 0
        numLabels = 0
        '*******************************************************************
        '* LOAD FLOORS DATA
        '*******************************************************************
        dim roomsFile as string
        redim floors(0) as FloorInfoType
        roomsFile = iif(Game_hasFlag(CLASSICMODE),"2002/tables/rooms.txt","tables/rooms.txt")
        ElevatorFile = freefile
        open DATA_DIR+roomsFile for input as ElevatorFile
        do while not eof(ElevatorFile)
            input #ElevatorFile, floors(0).floorNo
            input #ElevatorFile, floors(0).filename
            input #ElevatorFile, floors(0).label
            input #ElevatorFile, floors(0).allowed
            numLabels += 1
        loop
        
        redim preserve floors(numLabels) as FloorInfoType
        redim preserve menuNumbers(numLabels) as ElementType
        redim preserve menuLabels(numLabels) as ElementType
        
        seek #ElevatorFile, 1
        for i = 0 to numLabels-1
            input #ElevatorFile, floors(i).floorNo
            input #ElevatorFile, floors(i).filename
            input #ElevatorFile, floors(i).label
            input #ElevatorFile, floors(i).allowed
            if floors(i).floorNo > floorsMax then floorsMax = floors(i).floorNo
            if floors(i).floorNo < floorsMin then floorsMin = floors(i).floorNo
        next i
        close ElevatorFile
        
        '*******************************************************************
        '* BUILD WINDOW
        '*******************************************************************
        Element_Init @menuWindow, "", 31
        menuWindow.background = STATUS_DIALOG_COLOR
        menuWindow.background_alpha = STATUS_DIALOG_ALPHA
        menuWindow.padding_x = fontW
        menuWindow.padding_y = fontH
        menuWindow.w = 156 - menuWindow.padding_y*2
        menuWindow.h = SCREEN_H - menuWindow.padding_y*2
        
        Element_Init @menuTitle, "Please Select a Floor\======================", 31
        menuTitle.parent = @menuWindow
        
        dim numStars as integer
        numStars = int((SCREEN_H+(fontH-FONT_H))/fontH)
        Element_Init @menuBorder, "", 31
        for i = 0 to numStars-1
            menuBorder.text += "* "
        next i
        menuBorder.padding_y = int((SCREEN_H+(fontH-FONT_H)-numStars*fontH)*0.5)
        menuBorder.parent = 0
        menuBorder.background_alpha = 0
        menuBorder.x = 156 - fontW
        menuBorder.w = fontW
        menuBorder.h = SCREEN_H - menuBorder.padding_y*2
        
        container.parent = @menuWindow
        container.y = fontH * 2
        container.w = container.parent->w
        container.h = container.parent->h - container.y
        
        Element_Init @listFloors, "", 31
        listFloors.parent = @container
        listFloors.w = listFloors.parent->w
        listFloors.h = numLabels*fontH
        
        dim floorStr as string
        for i = 0 to numLabels-1
            floorStr = iif(len(floors(i).filename), ltrim(str(floors(i).floorNo)), "")
            Element_Init @menuNumbers(i), floorStr, 31, ElementFlags.MonospaceText or ElementFlags.AlignTextRight
            menuNumbers(i).parent = @listFloors
            menuNumbers(i).w = fontW * 2
            menuNumbers(i).h = FONT_H
            menuNumbers(i).padding_y = 1
            menuNumbers(i).x = 0
            menuNumbers(i).y = fontH * i
            menuNumbers(i).text_color = 182
            menuNumbers(i).background = 177
            menuNumbers(i).background_alpha = 0.5
            Element_Init @menuLabels(i), floors(i).label, 31
            menuLabels(i).parent = @listFloors
            menuLabels(i).w = 156 - fontW * 5 - 3
            menuLabels(i).h = FONT_H
            menuLabels(i).padding_x = 3
            menuLabels(i).padding_y = 1
            menuLabels(i).x = fontW * 3 - 5
            menuLabels(i).y = fontH * i
            menuLabels(i).text_color = 31
        next i
        '*******************************************************************
        '* END BUILD WINDOW
        '*******************************************************************
    end select
    
    if roomId <= 9 then
        listFloors.y = -(9-roomId)*fontH
    end if
    for i = 0 to numLabels-1
        if (roomId = floors(i).floorNo) and len(trim(floors(i).filename)) then
            menuNumbers(i).background = 19: menuNumbers(i).text_color = 188
            menuLabels(i).background = 70: menuLabels(i).text_color = 31
            roomName = floors(i).label
        else
            menuNumbers(i).background = 177
            menuLabels(i).background = -1
            if len(trim(floors(i).filename)) then
                menuNumbers(i).text_color = 182
                menuLabels(i).text_color = 31
            end if
        end if
    next i
    
    Elements_Clear
    Elements_Add @menuWindow
    Elements_Add @menuTitle
    Elements_Add @menuBorder
    for i = 0 to numLabels-1
        Elements_Add @menuNumbers(i)
        Elements_Add @menuLabels(i)
    next i
    Elements_Render
    
    if skipInput then
        return 0
    end if
    
    if keypress(KEY_TAB) or keypress(KEY_ESCAPE) or keypress(KEY_E) or mouseRB() or mouseMB() then
        state = DialogStates.closing
        return 0
    end if
    
    '- TODO: hold down for one second, then scroll down with delay
    if keypress(KEY_1) or keypress(KEY_KP_1) then
        if roomId <> 1 then
            LD2_PlaySound Sounds.uiArrows
            roomId = 1
        else
            LD2_PlaySound Sounds.uiInvalid
        end if
    end if
    if keypress(KEY_UP) or keypress(KEY_W) or mouseWheelUp() then
        if roomId < floorsMax then
            roomId += 1
            LD2_PlaySound Sounds.uiArrows
        else
            LD2_PlaySound Sounds.uiInvalid
        end if
    end if
    if keypress(KEY_DOWN) or keypress(KEY_S) or mouseWheelDown() then
        if roomId > floorsMin then
            roomId -= 1
            LD2_PlaySound Sounds.uiArrows
        else
            LD2_PlaySound Sounds.uiInvalid
        end if
    end if
    if keypress(KEY_ENTER) or keypress(KEY_SPACE) or mouseLB() then
        selectedRoomId = roomId
        selectedRoomName = roomName
        state = DialogStates.closing
        LD2_PlaySound Sounds.uiSelect
    end if
    
    return 0
    
end function

function Look (item AS InventoryType, skipInput as integer = 0) as integer
	
    static container as ElementType
    static dialog as ElementType
    static heading as ElementType
    static border as ElementType
    static imgSprite as ElementType
    static textDescription as ElementType
    static scrollbar as ElementType
    static divider as ElementType
    
    static wobbleType as integer
    static wobbleAction as integer
    static nextAction as integer
    
    static scrollHeight as integer
    static scrollRows as integer
    static scroll as integer
    
    static text_length as integer
    static wobbleClock as double
    static textClock as double
    static holdClock as double
    static state as integer = 0
    
    static desc as string
    
    dim img_w as integer, img_h as integer
    img_w = SPRITE_W*4
    img_h = SPRITE_H*4
    
    dim filtered as string
    dim wobbleStatus as integer
    dim timediff as double
    dim fontW as integer
    dim fontH as integer
    dim i as integer
    dim n as integer
    
    if state = DialogStates.closed then
        state = DialogStates.init
        LD2_PlaySound Sounds.uiSelect
    end if
    
    select case state
    case DialogStates.closing
        state = DialogStates.closed
        while mouseLB(): PullEvents: wend
        while mouseRB(): PullEvents: wend
        while mouseMB(): PullEVents: wend
        Elements_Restore
        LD2_PlaySound Sounds.uiSubmenu
        return 1
    case DialogStates.init
        state = DialogStates.ready
        
        Elements_Backup
        wobbleClock = timer
        textClock = timer
        scrollHeight = 0
        scrollRows = 0
        scroll = 0
        text_length = 10
        
        fontW = Elements_GetFontWidthWithSpacing()
        fontH = Elements_GetFontHeightWithSpacing()
        
        '***************************************************************
        '* FILTER DESCRIPTION
        '***************************************************************
        desc = trim(Inventory_LoadDescription(item.id))
        if LookItemCallback <> 0 then
            LookItemCallback(item.id, desc)
        end if
        if len(desc) = 0 then
            desc = "No description found for item id: " + str(item.id)
        end if
        filtered = ""
        for i = 1 to len(desc)
            if mid(desc, i, 1) = "`" then
                filtered += !"\""
            else
                filtered += mid(desc, i, 1)
            end if
        next i
        desc = filtered
        
        '***************************************************************
        '* BUILD ELEMENTS
        '***************************************************************
        BuildStatusWindow item.longName, @dialog, @heading, @border
        
        Element_Init @imgSprite, "", 31, ElementFlags.SpriteCenterX or ElementFlags.SpriteCenterY
            imgSprite.parent = @dialog
            imgSprite.w = img_w
            imgSprite.h = img_h
            imgSprite.padding_x = int((heading.w-img_w)*0.5)
            imgSprite.padding_y = imgSprite.padding_x
            imgSprite.sprite = item.id
            imgSprite.sprite_set_id = idOBJCRP
        Elements_Add @imgSprite
        
        Element_Init @container, "", 31
            container.parent = @dialog
            container.w = container.parent->w-heading.w
            container.h = container.parent->h
            container.x = container.parent->w-container.w
        Elements_Add @container

        Element_Init @textDescription, "", 31, ElementFlags.CenterY
            textDescription.parent = @container
            textDescription.text_height = 1.8
            textDescription.padding_x = fontW*1.5
            textDescription.w = textDescription.parent->w-textDescription.padding_x*2
            textDescription.text_length = 0

        Elements_Add @textDescription
        
        textDescription.text = desc
        
        '*******************************************************************
        '* add scrollbar (if necessary)
        '*******************************************************************
        
        fontH = Elements_GetFontHeightWithSpacing(textDescription.text_height)
        
        Element_Init @divider, "", 31
            divider.parent = @container
            divider.text_height = textDescription.text_height
            divider.w = fontW
            for n = 0 to int(container.h/fontH)-1: divider.text += "| ": next n
        Elements_Add @divider
        textDescription.w -= divider.w
        textDescription.x += divider.w
        
        Element_RenderPrepare @textDescription
        if textDescription.h > container.h then
            Element_Init @scrollbar, "", 31
                scrollbar.parent = @container
                scrollbar.text_height = textDescription.text_height
                scrollbar.w = fontW
                scrollbar.x = container.w-scrollbar.w
            Elements_Add @scrollbar
            textDescription.w -= scrollbar.w
            Element_RenderPrepare @textDescription
            scrollRows = int((textDescription.h-container.h)/fontH)
            if (textDescription.h-container.h)/fontH - scrollRows > 0 then scrollRows += 1
            scrollHeight = int(container.h/fontH)
            if scrollRows < scrollHeight then
                scrollRows = scrollHeight
            end if
        end if
        
        '***************************************************************
        '* SET INITIAL WOBBLE STATES
        '***************************************************************
        select case imgSprite.sprite
            case ItemIds.Shotgun
                wobbleType = WobbleTypes.RevealSpin
            case ItemIds.Handgun
                wobbleType = WobbleTypes.Reveal540Spin
            case ItemIds.Magnum
                wobbleType = WobbleTypes.RevealBackSpin
            case ItemIds.Flashlight, ItemIds.FlashlightNoBat
                wobbleType = WobbleTypes.Reveal540BackSpin
            case else
                wobbleType = WobbleTypes.RevealNoSpin
        end select
        wobbleAction = WobbleActions.ResetAnimations
    
    case DialogStates.ready
        
        fontH = Elements_GetFontHeightWithSpacing(textDescription.text_height)
        
    end select

    '*******************************************************************
    '* START
    '*******************************************************************
    if ((timer - textClock) > 0.45) then
        if text_length < len(desc) then
            text_length += 10
            textDescription.text_length = text_length
            if text_length >= len(desc) then
                textDescription.text_length = -1 '* resets to auto
            end if
        end if
    end if
    
    Elements_Render
    
    timediff = (timer - wobbleClock)
    if timediff > 0.01 then
        wobbleStatus = DoWobble(@imgSprite, wobbleType, wobbleAction)
        if wobbleAction = WobbleActions.ResetAnimations then
            wobbleAction = wobbleActions.NoAction
        end if
        select case wobbleStatus
        case WobbleStatuses.RevealComplete
            wobbleType = WobbleTypes.AssignType
        case WobbleStatuses.ActionComplete
            wobbleAction = WobbleActions.NoAction
            wobbleStatus = WobbleStatuses.Ready
        end select
        wobbleClock = timer
    end if
    
    if wobbleType = WobbleTypes.AssignType then
        select case imgSprite.sprite
        case ItemIds.MysteryMeat
            wobbleType = WobbleTypes.Squishy
        case ItemIds.Flashlight, ItemIds.FlashlightNoBat, ItemIds.Wrench, ItemIds.Magnum, ItemIds.Handgun, ItemIds.Shotgun
            wobbleType = WobbleTypes.Metal
        case else
            wobbleType = WobbleTypes.Elastic
        end select
    end if
    
    if scrollRows > 0 then
        textDescription.y = int(-scroll*fontH)
        scrollbar.text = ""
        for n = 0 to scrollHeight-1
            scrollbar.text += iif(n = int(scrollHeight*(scroll/scrollRows)), "= ", "| ")
        next n
    end if
    
    if skipInput then
        return 0
    end if
    
    if keypress(KEY_DOWN) or keypress(KEY_S) or keypress(KEY_KP_2) or (mouseWheelY() > 0) then
        if scroll < scrollRows-1 then
            scroll += 1
            LD2_PlaySound Sounds.dialog
        else
            nextAction = WobbleActions.SlapDown
        end if
    end if
    if keypress(KEY_UP) or keypress(KEY_W) or keypress(KEY_KP_8) or (mouseWheelY() < 0) then
        if scroll > 0 then
            scroll -= 1
            LD2_PlaySound Sounds.dialog
        else
            nextAction = WobbleActions.SlapUp
        end if
    end if
    if keyboard(KEY_UP) or keyboard(KEY_DOWN) then
        if holdClock = 0 then holdClock = timer
        if (timer - holdClock) > 0.5 then
            if keyboard(KEY_UP)   then nextAction = WobbleActions.HoldUp
            if keyboard(KEY_DOWN) then nextAction = WobbleActions.HoldDown
        end if
    else
        if (nextAction = WobbleActions.HoldUp) or (nextAction = WobbleActions.HoldDown) then
            nextAction = 0
        end if
        if holdClock <> 0 then
            holdClock = 0
        end if
    end if
    if keypress(KEY_LEFT) or keypress(KEY_A) or keypress(KEY_KP_4) then
        nextAction = WobbleActions.SlapLeft
    end if
    if keypress(KEY_RIGHT) or keypress(KEY_D) or keypress(KEY_KP_6) then
        nextAction = WobbleActions.SlapRight
    end if
    if keypress(KEY_CTRL) then
        nextAction = WobbleActions.Punch
    end if
    if keypress(KEY_ENTER) or keypress(KEY_TAB) or keypress(KEY_ESCAPE) or keypress(KEY_E) or mouseLB() or mouseRB() or mouseMB() then
        state = DialogStates.closing
    end if
    
    if (wobbleStatus = WobbleStatuses.Ready) and (nextAction > 0) then
        wobbleAction = nextAction
        nextAction = 0
    end if
    
    '*******************************************************************
    '* END
    '*******************************************************************
    
end function

function DoWobble(wobble as ElementType ptr, wobbleType as integer = WobbleTypes.RevealNoSpin, wobbleAction as integer = WobbleActions.NoAction) as integer
    
    static stretching as integer
    static e as double
    dim percent as double
    dim stretchStart as integer
    dim img_w as integer
    dim img_h as integer
    dim is_reveal as integer
    
    img_w = SPRITE_W*4
    img_h = SPRITE_H*4
    
    wobble->x = 9999
    wobble->y = 9999
    
    if wobbleAction = WobbleActions.ResetAnimations then
        wobbleAction = WobbleActions.NoAction
        stretching = 0
        e = 0
    end if
    
    select case wobbleType
    '*******************************************************************
    '* REVEALS
    '*******************************************************************
    case WobbleTypes.RevealNoSpin
        
        e = iif(e=0 or e=1, getEaseInOutInterval(0.15), getEaseInOutInterval(0, 0.45))
        wobble->w = int(img_w*(1.0+(1-e))+0.5)
        wobble->h = int(img_h*(1.0+(1-e))+0.5)
        wobble->sprite_rot = 0
        is_reveal = 1
        
    case WobbleTypes.RevealSpin
        
        e = iif(e=0 or e=1, getEaseInOutInterval(0.15), getEaseInOutInterval(0, 0.45))
        wobble->w = int(img_w*(1.0+(1-e))+0.5)
        wobble->h = int(img_h*(1.0+(1-e))+0.5)
        wobble->sprite_rot = int(e*360)
        is_reveal = 1
        
    case WobbleTypes.RevealBackSpin
        
        e = iif(e=0 or e=1, getEaseInOutInterval(0.15), getEaseInOutInterval(0, 0.45))
        wobble->w = int(img_w*(1.0+(1-e))+0.5)
        wobble->h = int(img_h*(1.0+(1-e))+0.5)
        wobble->sprite_rot = int(e*-360)
        is_reveal = 1
    
    case WobbleTypes.Reveal540Spin
        
        e = iif(e=0 or e=1, getEaseInOutInterval(0.15), getEaseInOutInterval(0, 0.45))
        wobble->w = int(img_w*(1.0+(1-e))+0.5)
        wobble->h = int(img_h*(1.0+(1-e))+0.5)
        wobble->sprite_rot = int(e*540+180)
        is_reveal = 1
    
    case WobbleTypes.Reveal540BackSpin
        
        e = iif(e=0 or e=1, getEaseInOutInterval(0.15), getEaseInOutInterval(0, 0.45))
        wobble->w = int(img_w*(1.0+(1-e))+0.5)
        wobble->h = int(img_h*(1.0+(1-e))+0.5)
        wobble->sprite_rot = int(e*-630-90)
        is_reveal = 1
        
    '*******************************************************************
    '* ELASTIC
    '*******************************************************************
    case WobbleTypes.Elastic
        
        select case wobbleAction
        case WobbleActions.SlapLeft, WobbleActions.SlapRight
            
            e = iif(e=0 or e=1, getEaseInWobble(0.15), getEaseInWobble(0, 0.45))
            wobble->w = int(img_w*(1-e)+0.5)
            wobble->h = int(img_h*(1+e)+0.5)
            
        case WobbleActions.Slapup, WobbleActions.SlapDown
            
            e = iif(e=0 or e=1, getEaseInWobble(0.15), getEaseInWobble(0, 0.45))
            wobble->h = int(img_h*(1+e)+0.5)
        
        case WobbleActions.Punch
            
            if e=0 or e=1 then LD2_PlaySound Sounds.punch
            e = iif(e=0 or e=1, getEaseInShake(0.15), getEaseInShake(0, 0.7))
            wobble->w = int(img_w*(1.0+e)+0.5)
            wobble->h = int(img_h*(1.0+e)+0.5)
            
        end select
    
    '*******************************************************************
    '* SQUISHY
    '*******************************************************************
    case WobbleTypes.Squishy
        
        select case wobbleAction
        case WobbleActions.SlapLeft, WobbleActions.SlapRight
            
            if e=0 or e=1 then LD2_PlaySound Sounds.blood2
            e = iif(e=0 or e=1, getEaseInWobble(0.15), getEaseInWobble(0, 0.45))
            wobble->w = int(img_w*(1-abs(e))+0.5)
            if (wobble->w and 1) = 0 then wobble->w -= 1
            if (wobble->h and 1) = 0 then wobble->h -= 1
            select case wobbleAction
            case WobbleActions.SlapLeft
                wobble->x = int((img_w*(1-e*1.2)-wobble->w)*0.5)
            case WobbleActions.SlapRight
                wobble->x = int((img_w*(1+e*1.2)-wobble->w)*0.5)
            end select
            wobble->y = int((img_h-wobble->h)*0.5)
        
        case WobbleActions.SlapUp, WobbleActions.SlapDown
            
            if e=0 or e=1 then LD2_PlaySound Sounds.blood2
            e = iif(e=0 or e=1, getEaseInWobble(0.15), getEaseInWobble(0, 0.45))
            wobble->h = int(img_h*(1-abs(e))+0.5)
            if (wobble->w and 1) = 0 then wobble->w -= 1
            if (wobble->h and 1) = 0 then wobble->h -= 1
            select case wobbleAction
            case WobbleActions.SlapUp
                wobble->y = int((img_h*(1-e)-wobble->h)*0.5)
            case WobbleActions.SlapDown
                wobble->y = int((img_h*(1+e)-wobble->h)*0.5)
            end select
            wobble->x = int((img_w-wobble->w)*0.5)
        
        case WobbleActions.HoldUp, WobbleActions.HoldDown
            
            if stretching = 0 then
                stretchStart = timer
                LD2_PlaySound Sounds.squishy
            end if
            e = iif(stretching = 0, getEaseInOutInterval(0.15), getEaseInOutInterval(0, 2))
            wobble->w = int(img_h*(1+e*0.1)+0.5)
            wobble->h = int(img_h*(1+e*0.7)+0.5)
            wobble->sprite_rot = e*-2
            stretching = 1
        
        case WobbleActions.Punch
            
            if e=0 or e=1 then LD2_PlaySound Sounds.punch: LD2_PlaySound Sounds.splatter
            e = iif(e=0 or e=1, getEaseInShake(0.15), getEaseInShake(0, 0.7))
            wobble->w = int(img_w*(1.0+e)+0.5)
            wobble->h = int(img_h*(1.0+e)+0.5)
            
        case else
            
            if stretching then
                stretching = 0
                wobble->sprite_rot = 0
                LD2_PlaySound Sounds.blood2
                e = getEaseInShake(1-iif((timer-stretchStart)*0.5>0.85,0.85,(timer-stretchStart)*0.5))
            else
                e = getEaseInShake(0, 0.3)
            end if
            wobble->h = int(img_h*(1+e*1.5)+0.5)
            
        end select
    '*******************************************************************
    '* METAL
    '*******************************************************************
    case WobbleTypes.Metal
        
        select case wobbleAction
        case WobbleActions.SlapLeft, WobbleActions.SlapRight
            
            if e=0 or e=1 then
                e = getEaseInShake(0.01)
                percent = 0
                wobble->sprite_rot = 0
                LD2_PlaySound Sounds.lookMetal
            else
                e = getEaseInShake(0, 0.45, percent)
            end if
            e = abs(e)
            select case wobbleAction
            case WobbleActions.SlapLeft
                wobble->x = int((img_w*(1-e*0.7)-wobble->w)*0.5)
                if percent > 0.15 then wobble->sprite_rot = 10
            case WobbleActions.SlapRight
                wobble->x = int((img_w*(1+e*0.7)-wobble->w)*0.5)
                if percent > 0.15 then wobble->sprite_rot = -45
            end select
            wobble->y = int((img_h-wobble->h)*0.5)
            if e=0 or e=1 then
                wobble->sprite_rot = 0
            end if
        
        case WobbleActions.SlapUp, WobbleActions.SlapDown
            
            if e=0 or e=1 then
                e = getEaseInShake(0.01)
                percent = 0
                wobble->sprite_rot = 0
                LD2_PlaySound Sounds.lookMetal
            else
                e = getEaseInShake(0, 0.45, percent)
            end if
            select case wobbleAction
            case WobbleActions.SlapUp
                wobble->y = int((img_h*(1-abs(e)*0.5)-wobble->h)*0.5)
                if percent > 0.15 then wobble->sprite_rot = 3
            case WobbleActions.SlapDown
                wobble->y = int((img_h*(1+abs(e)*0.5)-wobble->h)*0.5)
                if percent > 0.15 then wobble->sprite_rot = -6
            end select
            wobble->x = int((img_w-wobble->w)*0.5)
            if e=0 or e=1 then
                wobble->sprite_rot = 0
            end if
        
        case WobbleActions.Punch
            
            if e=0 or e=1 then
                e = getEaseInShake(0.15)
                percent = 0
                LD2_PlaySound Sounds.punch
                LD2_PlaySound Sounds.lookMetal
                
            else
                e = getEaseInShake(0, 0.35, percent)
            end if
            e = abs(e)
            wobble->w = int(img_w*(1.0+e*0.7)+0.5)
            wobble->h = int(img_h*(1.0+e*0.7)+0.5)
            wobble->sprite_rot = 30
            
            if e=0 or e=1 then
                wobble->sprite_rot = 0
            end if
            
        end select
        
    end select
    
    if (wobble->w and 1) = 0 then wobble->w -= 1
    if (wobble->h and 1) = 0 then wobble->h -= 1
    if wobble->x = 9999 then wobble->x = int((img_w-wobble->w)*0.5)
    if wobble->y = 9999 then wobble->y = int((img_h-wobble->h)*0.5)
    
    if e=0 or e=1 then
        return iif(is_reveal, WobbleStatuses.RevealComplete, iif(wobbleAction = WobbleActions.NoAction, WobbleStatuses.Ready, WobbleStatuses.ActionComplete))
    end if
    
    if (wobbleAction = WobbleActions.HoldUp) or (wobbleAction = WobbleActions.HoldDown) then
        return WobbleStatuses.ActionComplete
    end if
    
    return WobbleStatuses.Pending
    
end function

sub STATUS_RefreshInventory
    
    DIM i AS INTEGER
    DIM id AS INTEGER
    DIM qty AS INTEGER
    dim qtyMax as integer
    
    Inventory_Clear
    FOR i = 0 TO 7 '- change to LD2_GetMaxInvSize% ?
        id = LD2_GetStatusItem(i)
        qty = LD2_GetStatusAmount(i)
        qtyMax = Player_GetItemMaxQty(id)
        IF Inventory_Add(id, qty, qtyMax, i) THEN
            EXIT FOR
        END IF
    NEXT i
    Inventory_RefreshNames
    
end sub

function StatusScreen(skipInput as integer = 0) as integer
	
	LD2_LogDebug "StatusScreen ()"
	
	static dialog as ElementType
    static lookItem as InventoryType
    static mixItem as InventoryType
    static mixMode as integer = 0
	static action as integer
    static state as integer = DialogStates.closed
    static row as integer
    static col as integer
    static e as double = -1
    
    dim numCols as integer: numCols = 4
    dim numRows as integer: numRows = 2
    dim selected as InventoryType
	
    
    if state = DialogStates.closed then
        state = DialogStates.opening
    end if
    
    if dialog.w = 0 then
        Element_Init @dialog
        dialog.background = STATUS_DIALOG_COLOR
        dialog.background_alpha = STATUS_DIALOG_ALPHA
        dialog.w = SCREEN_W
    end if
    
    select case state
    case DialogStates.opening
        if e = -1 then
            e = getEaseInOutInterval(1)
            LD2_PlaySound Sounds.uiMenu
        else
            e = getEaseInOutInterval(0, STATUS_EASE_SPEED)
        end if
        dialog.h = e * 96
        Element_Render @dialog
        if e = 1 then
            state = DialogStates.init
            e = -1
        end if
        return 0
    case DialogStates.closing
        if e = -1 then
            e = getEaseInOutInterval(1)
            LD2_PlaySound Sounds.uiMenu
        else
            e = getEaseInOutInterval(0, STATUS_EASE_SPEED)
        end if
        dialog.h = (1-e) * 96
        Element_Render @dialog
        if e = 1 then
            state = DialogStates.closed
            e = -1
            return 1
        else
            return 0
        end if
    case DialogStates.init
        state = DialogStates.ready
        STATUS_RefreshInventory
        row = int(selectedInventorySlot / numCols)
        col = selectedInventorySlot-row*numCols
        LookItem.id = -1
        action = -1
    end select
    
    
    '*******************************************************************
    '* START
    '*******************************************************************
    if LookItem.id > -1 then
        if Look(LookItem, skipInput) then
            LookItem.id = -1
        else
            return 0
        end if
    end if
    
    RenderStatusScreen action, iif(mixMode, @mixItem, 0)
    Elements_Render
    
    if ShowResponse("", -1, skipInput) then
        return 0
    end if
    
    if skipInput then
        return 0
    end if
    
    selectedInventorySlot = row*numCols+col
    Inventory_GetItemBySlot(selected, selectedInventorySlot)
    
    IF keypress(KEY_TAB) or keypress(KEY_ESCAPE) or keypress(KEY_E) or mouseRB() or mouseMB() THEN
        IF action > -1 THEN
            while mouseRB(): PullEvents: wend
            while mouseMB(): PullEvents: wend
            LD2_PlaySound Sounds.uiCancel
            action = -1
        ELSE
            state = DialogStates.closing
        END IF
    END IF
        
    '- TODO: hold down for one second, then scroll down with delay
    IF keypress(KEY_UP) or keypress(KEY_W) or (action = -1 and mouseWheelUp()) THEN
        if action >= 0 then
            LD2_PlaySound Sounds.uiCancel
            action = -1
        else
            row -= 1
            IF row < 0 THEN
                row = 0
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
            row += 1
            IF row > numRows-1 THEN
                row = numRows-1
                LD2_PlaySound Sounds.uiInvalid
            ELSE
                LD2_PlaySound Sounds.uiArrows
            END IF
        end if
    END IF
    IF keypress(KEY_LEFT) or (action >= 0 and mouseWheelDown()) THEN
        if action >= 0 then
            action = action - 1
            IF action < 0 THEN
                action = 0
                LD2_PlaySound Sounds.uiInvalid
            ELSE
                LD2_PlaySound Sounds.uiArrows
            END IF
        else
            col -= 1
            if col < 0 then
                col = 0
                LD2_PlaySound Sounds.uiInvalid
            else
                LD2_PlaySound Sounds.uiArrows
            end if
        end if
    END IF
    IF keypress(KEY_RIGHT) or (action >= 0 and mouseWheelUp()) THEN
        if action >= 0 then
            action = action + 1
            IF action > 3 THEN
                action = 3
                LD2_PlaySound Sounds.uiInvalid
            ELSE
                LD2_PlaySound Sounds.uiArrows
            END IF
        else
            col += 1
            if col > numCols-1 then
                col = numCols-1
                LD2_PlaySound Sounds.uiInvalid
            else
                LD2_PlaySound Sounds.uiArrows
            end if
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
                    state = DialogStates.closing
                end if
                action = -1
            case 1  '- LOOK
                LookItem = selected
                action = -1
            case 2  '- MIX
                if canMix(selected.id) then
                    mixMode = 1
                    mixItem = selected
                    action = -1
                    LD2_PlaySound Sounds.uiSubmenu
                end if
            case 3  '- Drop
                Drop selected
                action = -1
            end select
        else
            action = 0
            LD2_PlaySound Sounds.uiSubmenu
        end if
    end if
	'*******************************************************************
    '* END
    '*******************************************************************
	
	return 0
	
end function

function UseItem (item AS InventoryType) as integer

    dim id as integer
    dim qty as integer
    dim message as string
    dim success as integer
    dim discard as integer
    dim textColor as integer
    dim exitMenu as integer
    dim callbackValue as integer
    
    if BeforeUseItemCallback <> 0 then
        STATUS_RefreshInventory
        BeforeUseItemCallback(item.id)
    end if
    
    success = Inventory_Use(item.id)
    message = Inventory_GetUseMessage()
    
    if success then
        id  = Inventory_GetUseItem()
        qty = Inventory_GetUseQty()
        discard = Inventory_GetUseItemDiscard()
        if discard then
            LD2_AddToStatus item.id, -qty
        end if
        if (UseItemCallback <> 0) then
            UseItemCallback(id, qty, exitMenu)
        else
            LD2_AddToStatus id, qty
        end if
        STATUS_RefreshInventory
        textColor = STATUS_COLOR_SUCCESS
    else
        LD2_PlaySound Sounds.uiDenied
        textColor = STATUS_COLOR_DENIED
    end if
    
    if exitMenu = 0 then
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
        STATUS_RefreshInventory
        LD2_PlaySound Sounds.uiMix
        textColor = STATUS_COLOR_SUCCESS
    else
        LD2_PlaySound Sounds.uiDenied
        textColor = STATUS_COLOR_DENIED
    END IF
    
    ShowResponse msg, textColor
    
END SUB

function ShowResponse (response as string = "", textColor as integer = -1, skipInput as integer = 0) as integer
    
    static labelResponse as ElementType
    static responseMessage as string
    static responseColor as integer = -1
    static d as double = 0
    dim revealStep as double
    dim fontH as integer
    dim textW as integer
    
    if len(response) then
        responseMessage = response
        responseColor = textColor
        d = 0
    elseif len(responseMessage) = 0 then
        return 0
    end if
    
    response = responseMessage
    textColor = responseColor
    
    if d = 0 then
        Element_Init @labelResponse, response, 31
        fontH = Elements_GetFontHeightWithSpacing()
        textW = Element_GetTextWidth(@labelResponse)
        labelResponse.parent = Elements_GetRootParent()
        labelResponse.x = labelResponse.parent->w - textW - 1
        labelResponse.y = labelResponse.parent->h+labelResponse.parent->padding_y-fontH*2
    end if
    
    if textColor >= 0 then
        labelResponse.text_color = textColor
    end if
    
    if int(d) < len(response) then
        revealStep = int(len(response)*0.065)
        if revealStep < 2 then revealStep = 2
        d += revealStep
        labelResponse.text = left(response, int(d))
        Element_Render @labelResponse
        return 1
    end if

    if (int(timer*3) and 1) then
        labelResponse.text = response
    else
        labelResponse.text = response + "_"
    end if
    
    Element_Render @labelResponse
    
    if skipInput then
        return 1
    end if
    
    if keypress(KEY_ENTER) or keypress(KEY_ESCAPE) or keypress(KEY_E) or mouseLB() or mouseRB() or mouseMB() then
        LD2_PlaySound Sounds.uiArrows
        responseMessage = ""
        textColor = -1
        return 0
    end if
    
    return 1
    
end function

function getEaseInInterval(doReset as double = 0, speed as double = 1.0) as double
    
    static clock as double
    static e as double
    
    if doReset <> 0 then
        e = iif(doReset < 1, doReset, 0)
    else
        e += (timer-clock)/speed
        if e > 1 then
            e = 1
        end if
    end if
    clock = timer
    
    return e * e * e
    
end function

function getEaseOutInterval(doReset as double = 0, speed as double = 1.0) as double
    
    static clock as double
    static e as double
    
    if doReset <> 0 then
        e = iif(doReset < 1, doReset, 0)
    else
        e += (timer-clock)/speed
        if e > 1 then
            e = 1
        end if
    end if
    clock = timer
    
    return (1 - e) * (1 - e) * (1 - e)
    
end function

function getEaseInOutInterval(doReset as double = 0, speed as double = 1.0) as double
    
    static clock as double
    static e as double
    dim d as double
    
    if doReset <> 0 then
        e = iif(doReset < 1, doReset, 0)
    else
        e += (timer-clock)/speed
        if e > 1 then
            e = 1
        end if
    end if
    clock = timer
    
    d = iif(e <= 0.5, e*2, (1-e)*2)
    return iif(e <= 0.5, d*d*d*0.5, 1.0-d*d*d*0.5)
    
end function

function getEaseOutInInterval(doReset as double = 0, speed as double = 1.0) as double
    
    static clock as double
    static e as double
    dim d as double
    
    if doReset <> 0 then
        e = iif(doReset < 1, doReset, 0)
    else
        e += (timer-clock)/speed
        if e > 1 then
            e = 1
        end if
    end if
    clock = timer
    
    d = 1.0 - iif(e <= 0.5, e*2, (1-e)*2)
    return iif(e <= 0.5, 0.5-d*0.5, 0.5+d*0.5)
    
end function

function getEaseInAndReverseInterval(doReset as double = 0, speed as double = 1.0) as double
    
    static clock as double
    static e as double
    dim d as double
    
    if doReset <> 0 then
        e = iif(doReset < 1, doReset, 0)
    else
        e += (timer-clock)/speed
        if e > 1 then
            e = 1
        end if
    end if
    clock = timer
    
    d = iif(e <= 0.5, e*2, (1-e)*2)
    return d*d*d*0.5
    
end function

function getEaseInWobble(doReset as double = 0, speed as double = 1.0) as double
    
    static clock as double
    static e as double
    dim d as double
    
    if doReset <> 0 then
        e = iif(doReset < 1, doReset, 0)
        LD2_PlaySound Sounds.uiCancel
    else
        e += (timer-clock)/speed
        if e > 1 then
            e = 1
        end if
    end if
    clock = timer
    
    d = sin(e*4*PI)*(1-e)
    
    return d
    
end function

function STATUS_DialogYesNo(message as string) as integer
    
    dim e as double
    dim pixels as integer
    dim halfX as integer
    dim halfY as integer
    dim size as integer
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
    
    fontW = Elements_GetFontWidthWithSpacing()
    fontH = Elements_GetFontHeightWithSpacing()
    
    Element_Init @dialog
    Element_Init @title, message, 31
    Element_Init @optionYes, "YES", 31, ElementFlags.CenterX
    Element_Init @optionNo, "NO ", 31, ElementFlags.CenterX
    
    dialog.background = STATUS_DIALOG_COLOR
    dialog.background_alpha = STATUS_DIALOG_ALPHA
    dialog.border_size = 1
    dialog.border_color = 15
    title.text_height = 2.0
    
    halfX = int(SCREEN_W*0.5)
    halfY = int(SCREEN_H*0.5)
    
    size = int(SCREEN_H*0.25)
    
    dim modw as double: modw = 1.6
    dim modh as double: modh = 0.8
    
    LD2_PlaySound Sounds.uiMenu
	
	LD2_SaveBuffer 2
	LD2_CopyBuffer 1, 2
	
    getEaseInInterval(1)
	do
        e = getEaseInInterval(0, STATUS_EASE_SPEED)
        pixels = int(e * size)
        dialog.x = halfX - pixels * modw
        dialog.y = halfY - pixels * modh
        dialog.w = pixels * modw * 2
        dialog.h = pixels * modh * 2
        LD2_CopyBuffer 2, 1
        Element_Render @dialog
        LD2_RefreshScreen
        PullEvents
	loop while e < 1

    pixels = size
    dialog.x = halfX - pixels * modw
    dialog.y = halfY - pixels * modh
    dialog.w = pixels * modw * 2
    dialog.h = pixels * modh * 2
    title.x = fontW
    title.y = fontH
    optionYes.y = dialog.h*0.5-fontH-3
    optionYes.padding_x = fontW: optionYes.padding_y = 3
    optionYes.background = 68
    optionYes.text_is_monospace = 1
    optionYes.text_height = 1
    optionNo.y  = optionYes.y + fontH*2
    optionNo.padding_x = fontW: optionNo.padding_y = 3
    optionNo.text_is_monospace = 1
    optionNo.text_height = 1
    optionYes.background = 70
    
    Elements_Clear
    Elements_Add @dialog
    Elements_Add @title, @dialog
    Elements_Add @optionYes, @dialog
    Elements_Add @optionNo, @dialog
    
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
        Elements_Render
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
    
    Elements_Clear
    
    getEaseOutInterval(1)
	do
        pixels = int(e * size)
        dialog.x = halfX - pixels * modw
        dialog.y = halfY - pixels * modh
        dialog.w = pixels * modw * 2
        dialog.h = pixels * modh * 2
        LD2_CopyBuffer 2, 1
        Element_Render @dialog
        LD2_RefreshScreen
        PullEvents
        e = getEaseOutInterval(0, STATUS_EASE_SPEED)
	loop while e > 0
    
    LD2_CopyBuffer 2, 1
    LD2_RefreshScreen
    LD2_RestoreBuffer 2
    
    return selections(selection)
    
end function

sub STATUS_DialogOk(message as string)
    
    dim e as double
    dim pixels as integer
    dim halfX as integer
    dim halfY as integer
    dim size as integer
    dim x as integer
    dim y as integer
    dim w as integer
    dim h as integer
    
    dim dialog as ElementType
    dim title as ElementType
    dim optionOk as ElementType
    
    dim fontW as integer
    dim fontH as integer
    
    fontW = Elements_GetFontWidthWithSpacing()
    fontH = Elements_GetFontHeightWithSpacing()
    
    Element_Init @dialog
    Element_Init @title, message, 31
    Element_Init @optionOk, "OK", 31, ElementFlags.CenterX
    
    dialog.background = STATUS_DIALOG_COLOR
    dialog.background_alpha = STATUS_DIALOG_ALPHA
    dialog.border_size = 1
    dialog.border_color = 15
    title.text_height = 2.0
    
    halfX = int(SCREEN_W*0.5)
    halfY = int(SCREEN_H*0.5)
    
    size = int(SCREEN_H*0.25)
    
    dim modw as double: modw = 1.6
    dim modh as double: modh = 0.8
    
    LD2_PlaySound Sounds.uiMenu
	
	LD2_SaveBuffer 2
	LD2_CopyBuffer 1, 2
	
    getEaseInInterval(1)
	do
        e = getEaseInInterval(0, STATUS_EASE_SPEED)
        pixels = int(e * size)
        dialog.x = halfX - pixels * modw
        dialog.y = halfY - pixels * modh
        dialog.w = pixels * modw * 2
        dialog.h = pixels * modh * 2
        LD2_CopyBuffer 2, 1
        Element_Render @dialog
        LD2_RefreshScreen
        PullEvents
	loop while e < 1

    pixels = size
    dialog.x = halfX - pixels * modw
    dialog.y = halfY - pixels * modh
    dialog.w = pixels * modw * 2
    dialog.h = pixels * modh * 2
    title.x = fontW
    title.y = fontH
    optionOk.y = dialog.h*0.5
    optionOk.padding_x = fontW: optionOk.padding_y = 3
    optionOk.background = 70
    optionOk.text_is_monospace = 1
    
    Elements_Clear
    Elements_Add @dialog
    Elements_Add @title, @dialog
    Elements_Add @optionOk, @dialog
    
    do
        LD2_CopyBuffer 2, 1
        Elements_Render
		LD2_RefreshScreen
        PullEvents
        if keypress(KEY_ENTER) then
            LD2_PlaySound Sounds.uiSelect
            exit do
        end if
        if keypress(KEY_DOWN) then
            LD2_PlaySound Sounds.uiInvalid
        end if
        if keypress(KEY_UP) then
            LD2_PlaySound Sounds.uiInvalid
        end if
        if keypress(KEY_ESCAPE) then
            LD2_PlaySound Sounds.uiCancel
            exit do
        end if
    loop
    
    Elements_Clear
    
    getEaseOutInterval(1)
	do
        pixels = int(e * size)
        dialog.x = halfX - pixels * modw
        dialog.y = halfY - pixels * modh
        dialog.w = pixels * modw * 2
        dialog.h = pixels * modh * 2
        LD2_CopyBuffer 2, 1
        Element_Render @dialog
        LD2_RefreshScreen
        PullEvents
        e = getEaseOutInterval(0, STATUS_EASE_SPEED)
	loop while e > 0
    
    LD2_CopyBuffer 2, 1
    LD2_RefreshScreen
    LD2_RestoreBuffer 2
    
end sub

