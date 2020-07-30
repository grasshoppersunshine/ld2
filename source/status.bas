#include once "modules/inc/common.bi"
#include once "modules/inc/keys.bi"
#include once "modules/inc/ld2gfx.bi"
#include once "modules/inc/ld2snd.bi"
#include once "modules/inc/inventory.bi"
#include once "modules/inc/elements.bi"
#include once "modules/inc/easing.bi"
#include once "inc/ld2e.bi"
#include once "inc/enums.bi"
#include once "inc/status.bi"

declare sub Drop (item AS InventoryType)
declare sub BuildStatusWindow (heading AS STRING, elementWindow as ElementType ptr, elementHeading as ElementType ptr, elementBorder as ElementType ptr)
declare function Look (item AS InventoryType, skipInput as integer = 0) as integer
declare function Look_Classic (item AS InventoryType, skipInput as integer = 0) as integer
declare sub Mix (item0 AS InventoryType, item1 AS InventoryType)
declare function CanMix (itemId as integer) as integer
declare function ShowResponse (response as string = "", textColor as integer = -1, skipInput as integer = 0) as integer
declare function UseItem (item AS InventoryType) as integer
declare sub GetInventoryRowsCols(byref rows as integer, byref cols as integer)

declare sub RenderStatusScreen (action as integer = -1, mixItem as InventoryType ptr = 0, mixItemWith as InventoryType ptr = 0)
declare sub RenderClassicScreen (action as integer = -1, mixItem as InventoryType ptr = 0, mixItemWith as InventoryType ptr = 0)

dim shared SCREEN_W as integer
dim shared SCREEN_H as integer

dim shared SHARED_SPRITES as VideoSprites ptr

dim shared SELECTED_INVENTORY_SLOT as integer

dim shared BeforeUseItemCallback as sub(byval id as integer)
dim shared UseItemCallback as sub(byval id as integer, byref qty as integer, byref exitMenu as integer)
dim shared LookItemCallback as sub(id as integer, byref description as string)

dim shared STATUS_WINDOW_HEIGHT_MIN as integer
dim shared STATUS_WINDOW_HEIGHT_MED as integer
dim shared STATUS_WINDOW_HEIGHT_MAX as integer

dim shared STATUS_INVENTORY_SIZE as integer = 8
dim shared STATUS_WINDOW_HEIGHT as integer
dim shared STATUS_TEMP_HEIGHT as integer
dim shared LOOK_ITEM_ID as integer = -1

dim shared ROOMS_FILE as string

dim shared DEBUGMODE as integer
dim shared CLASSICMODE as integer
dim shared ENHANCEDMODE as integer
dim shared TESTMODE as integer

const DATA_DIR = "data/"
const STATUS_DIALOG_ALPHA = 0.75
const STATUS_DIALOG_COLOR = 66
const STATUS_EASE_SPEED = 0.3333

const OPTION_ACTIVE_BG   = STATUS_DIALOG_COLOR+4
const OPTION_INACTIVE_BG = STATUS_DIALOG_COLOR+2
const OPTION_ACTIVE_COLOR   = 15
const OPTION_INACTIVE_COLOR = 7

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

sub STATUS_SetUseItemCallback(callback as sub(byval id as integer, byref qty as integer, byref exitMenu as integer))
    
    UseItemCallback = callback
    
end sub

sub STATUS_SetLookItemCallback(callback as sub(id as integer, byref description as string))
    
    LookItemCallback = callback
    
end sub

function STATUS_Init() as integer
    
    DEBUGMODE   = iif(Game_hasFlag(GameFlags.DebugMode  ), 1, 0)
    CLASSICMODE = iif(Game_hasFlag(GameFlags.ClassicMode), 1, 0)
    SCREEN_W    = Screen_GetWidth()
    SCREEN_H    = Screen_GetHeight()
    
    if CLASSICMODE then
        STATUS_WINDOW_HEIGHT_MIN = 100
        STATUS_WINDOW_HEIGHT_MED = 124
        STATUS_WINDOW_HEIGHT_MAX = SCREEN_H
    else
        STATUS_WINDOW_HEIGHT_MIN = 96
        STATUS_WINDOW_HEIGHT_MED = 120
        STATUS_WINDOW_HEIGHT_MAX = SCREEN_H
    end if
    
    STATUS_WINDOW_HEIGHT = STATUS_WINDOW_HEIGHT_MIN
    
    if CLASSICMODE then
        Inventory_SetDataDir DATA_DIR+"2002/"
    end if
    
    return Inventory_Init(24, 12)
    
end function

sub STATUS_SetInventorySize(size as integer)
    
    STATUS_INVENTORY_SIZE = size
    
end sub

sub BuildClassicWindow (dialog as ElementType ptr, headingText as string = "", dividerText as string = "")
    
    static dialogBorder as ElementType
    static heading as ElementType
    static headingDivider as ElementType
    dim fontH as integer
    
    fontH = FONT_H+1
    
    Element_Init dialog, "", 31
    dialog->w = SCREEN_W
    dialog->padding_y = 4
    dialog->h = STATUS_WINDOW_HEIGHT-dialog->padding_y*2
    dialog->background = 68
    
    Element_Init @dialogBorder, string(53, "*")
    dialogBorder.y = dialog->h+dialog->padding_y*2-fontH
    dialogBorder.text_height = 1
    dialogBorder.background = 68
    
    Element_Init @heading, headingText
    heading.parent = dialog
    heading.x = 4
    
    Element_Init @headingDivider, dividerText
    headingDivider.parent = dialog
    headingDivider.x = 4
    headingDivider.y = fontH
    
    Elements_Add dialog
    Elements_Add @dialogBorder
    Elements_Add @heading
    Elements_Add @headingDivider
    
end sub

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
    elementWindow->h = STATUS_WINDOW_HEIGHT-elementWindow->padding_y*2
    
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

sub STATUS_CycleWindowSize(forceSize as integer = -1)
    
    dim sizes(2) as integer
    
    sizes(0) = STATUS_WINDOW_HEIGHT_MIN
    sizes(1) = STATUS_WINDOW_HEIGHT_MED
    sizes(2) = STATUS_WINDOW_HEIGHT_MAX
    
    if (forceSize >= 0) and (forceSize <= ubound(sizes)) then
        STATUS_WINDOW_HEIGHT = sizes(forceSize)
    else
        select case STATUS_WINDOW_HEIGHT
        case STATUS_WINDOW_HEIGHT_MIN
            STATUS_WINDOW_HEIGHT = STATUS_WINDOW_HEIGHT_MED
        case STATUS_WINDOW_HEIGHT_MED
            STATUS_WINDOW_HEIGHT = STATUS_WINDOW_HEIGHT_MAX
        case STATUS_WINDOW_HEIGHT_MAX
            STATUS_WINDOW_HEIGHT = STATUS_WINDOW_HEIGHT_MIN
        end select
    end if
    
end sub

sub STATUS_SetWindowSize(size as integer)
    
    STATUS_CycleWindowSize size
    
end sub

sub STATUS_SetTempWindowSize(size as integer)
    
    STATUS_TEMP_HEIGHT = size
    
end sub

sub STATUS_SetRoomsFile(filename as string)
    
    ROOMS_FILE = filename
    
end sub

sub RenderClassicScreen (action as integer = -1, mixItem as InventoryType ptr = 0, mixItemWith as InventoryType ptr = 0)
    
    static dialog as ElementType
    static labelInventory as ElementType
    static inventoryDivider as ElementType
    static menuActions as ElementType
    static labelItems(7) as ElementType
    
    dim item as InventoryType
    
    dim fontH as integer
    dim i as integer
    
    dim lft as integer
    lft = 200
    fontH = FONT_H+1
    
    Elements_Clear
    BuildClassicWindow @dialog, "STATUS SCREEN", "============="
    
    '*******************************************************************
    '* INVENTORY
    '*******************************************************************
    Element_Init @labelInventory, "INVENTORY"
    labelInventory.parent = @dialog
    labelInventory.x = lft + int((9*FONT_W)*0.5)
    
    Element_Init @inventoryDivider, "=================="
    inventoryDivider.parent = @dialog
    inventoryDivider.x = lft
    inventoryDivider.y = fontH
    
    '*******************************************************************
    '* INVENTORY ITEMS
    '*******************************************************************
    for i = 0 to 7
        Inventory_GetItemBySlot(item, i)
        Element_Init @labelItems(i), iif(i=SELECTED_INVENTORY_SLOT,"->","  ")+item.shortName
        labelItems(i).parent = @dialog
        labelItems(i).x = lft-FONT_W*2
        labelItems(i).y = 16+i*fontH
    next i
    
    '*******************************************************************
    '* ACTIONS MENU
    '*******************************************************************
    if action > -1 then
        Element_Init @menuActions, "  USE     LOOK    MIX     DROP"
        menuActions.text[action*8] = asc("-")
        menuActions.text[action*8+1] = asc(">")
        menuActions.parent = @dialog
        menuActions.x = menuActions.parent->w - FONT_W * len(menuActions.text)
        menuActions.y = menuActions.parent->h+menuActions.parent->padding_y - fontH * 2 - 2
    end if
    
    Elements_Add @labelInventory
    Elements_Add @inventoryDivider
    for i = 0 to 7
        Elements_Add @labelItems(i)
    next i
    if action > -1 then
        Elements_Add @menuActions
    end if
    
end sub

sub RenderStatusScreen (action as integer = -1, mixItem as InventoryType ptr = 0, mixItemWith as InventoryType ptr = 0)
    
    static dialog as ElementType
    static labelBottomBorder as ElementType
    static labelName as ElementType
    static labelStatus as ElementType: static valueStatus as ElementType
    static labelHealth as ElementType: static valueHealth as ElementType
    static labelWeapon as ElementType: static valueWeapon as ElementType
    static labelObjective as ElementType
    static labelCards  as ElementType: static valueCards as ElementType
    static labelInventory as ElementType
    static labelItems(11) as ElementType
    static labelItemsQty(11) as ElementType
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
    dialog.h = STATUS_WINDOW_HEIGHT-dialog.padding_y*2
    
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
    '* OBJECTIVE
    '*******************************************************************
    Element_Init @labelObjective, "", 75
    labelObjective.parent = @dialog
    labelObjective.y = labelObjective.parent->h+labelObjective.parent->padding_y-fontH*2
    
    'labelObjective.text = "Search Barney's office desk for a blue access card."
    'labelObjective.text = "Meet with Barney in the Weapons Locker."
    
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
    for i = 0 to 11
        Element_Init @labelItems(i)
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
    else
        Elements_Add @labelObjective
    end if
    static labelMix as ElementType
    static labelWith as ElementType
    static mixSubject as ElementType
    static mixObject as ElementType
    if mixItem <> 0 then
        dim subname as string
        dim objname as string
        Inventory_GetItemBySlot(item, SELECTED_INVENTORY_SLOT)
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
    
    GetInventoryRowsCols numRows, numCols
    
    select case numCols
    case 3: colW = int(SPRITE_W*2.00*3.5/numCols)
    case 4: colW = int(SPRITE_W*2.00)
    case 5: colW = int(SPRITE_W*2.00*4/numCols)
    end select
    cspc = int((SPRITE_W*8.75-colw*numCols)*1/(numCols-1))
    
    select case STATUS_WINDOW_HEIGHT
    case STATUS_WINDOW_HEIGHT_MIN
        rowH = SPRITE_H*1.25: rspc = SPRITE_H*0.25
    case STATUS_WINDOW_HEIGHT_MED
        if (numRows < 3) and (numCols < 5) then
            rowH = SPRITE_H*1.75: rspc = SPRITE_H*0.25
        else
            rowH = SPRITE_H*1.25: rspc = SPRITE_H*0.25
        end if
    case STATUS_WINDOW_HEIGHT_MAX
        rowH = SPRITE_H*1.75: rspc = SPRITE_H*0.25
    end select
    lft = dialog.w - SPRITE_W*2.25*4 + SPRITE_W*0.25 '(colW+cspc)*numCols + cspc
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
            
            if i = SELECTED_INVENTORY_SLOT then
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
        LD2_Drop item.slot
        STATUS_RefreshInventory
        ShowResponse "Dropped " + trim(item.shortName), STATUS_COLOR_SUCCESS
        exit sub
    end select
    
    LD2_PlaySound Sounds.uiDenied
    STATUS_RefreshInventory
    ShowResponse message, STATUS_COLOR_DENIED
    
END SUB

function EStatusScreen_Classic (byval currentRoomId as integer, byref selectedRoomId as integer, byref selectedRoomName as string, byval skipInput as integer = 0) as integer
    
    static dialog as ElementType
    static description as ElementType
    static selectionArrow as ElementType
    
    static menuNumbers() as ElementType
    static menuLabels() as ElementType
    static floors() AS FloorInfoType
    static floorsMin as integer
    static floorsMax as integer
    static numLabels as integer
    
    static selection as integer
    static state as integer
    
    dim ElevatorFile as integer
    dim fontH as integer
    dim i as integer
    
    fontH = FONT_H+1
    
    Elements_Clear
    BuildClassicWindow @dialog, "Elevator - Select Floor - Secret CIA Building", string(52, "-")
    
    select case state
    case DialogStates.closed
        state = DialogStates.ready
        LD2_PlaySound Sounds.uiMenu
        '*******************************************************************
        '* LOAD FLOORS DATA
        '*******************************************************************
        redim floors(0) as FloorInfoType
        ElevatorFile = freefile
        open DATA_DIR+ROOMS_FILE for input as ElevatorFile
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
    end select
    
    dim row as integer
    dim col as integer
    dim top as integer
    dim lft as integer
    
    top = 16
    i = 0
    for col = 0 to 1
        lft = iif(col=0,14,175)
        for row = 0 to 11
            Element_Init @menuNumbers(i), iif(floors(i).floorNo<10," ","")+str(floors(i).floorNo)
            menuNumbers(i).parent = @dialog
            menuNumbers(i).x = lft
            menuNumbers(i).y = top+row*fontH
            Element_Init @menuLabels(i), "- "+floors(i).label
            menuLabels(i).parent = @dialog
            menuLabels(i).x = menuNumbers(i).x+FONT_W*2+7
            menuLabels(i).y = menuNumbers(i).y
            if (floors(i).floorNo = floorsMin) or (floors(i).floorNo = floorsMax) then
                menuNumbers(i).text = iif(floors(i).floorNo<10," ","")+floors(i).label
                menuLabels(i).text = ""
            end if
            Elements_Add @menuNumbers(i)
            Elements_Add @menuLabels(i)
            i += 1
        next row
    next col
    Element_Init @selectionArrow, "->"
    selectionArrow.parent = @dialog
    selectionArrow.x = iif(selection > 11, 160, 1)
    selectionArrow.y = top+(selection mod 12)*fontH
    
    Elements_Add @selectionArrow
    
    Elements_Render
    
    if keypress(KEY_TAB) then
        state = DialogStates.closed
        LD2_PlaySound Sounds.uiMenu
        return 1
    end if
    if keypress(KEY_UP) then
        if selection > 0 then
            selection -= 1
        end if
    end if
    if keypress(KEY_DOWN) then
        if selection < 23 then
            selection += 1
        end if
    end if
    if keypress(KEY_ENTER) then
        selectedRoomId = floors(selection).floorNo
        return 1
    end if
    
    selectedRoomId = currentRoomId
    
    return 0
    
end function

function EStatusScreen (byval currentRoomId as integer, byref selectedRoomId as integer, byref selectedRoomName as string, byval skipInput as integer = 0) as integer
	
    if DEBUGMODE then LogDebug __FUNCTION__, str(currentRoomId), str(selectedRoomId), selectedRoomName, str(skipInput)
	
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
            e = Easing_doEaseInOut(-1)
            LD2_PlaySound Sounds.uiMenu
        else
            e = Easing_doEaseInOut(0, STATUS_EASE_SPEED)
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
            e = Easing_doEaseInOut(-1)
            LD2_PlaySound Sounds.uiMenu
        else
            e = Easing_doEaseInOut(0, STATUS_EASE_SPEED)
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
        redim floors(0) as FloorInfoType
        ElevatorFile = freefile
        open DATA_DIR+ROOMS_FILE for input as ElevatorFile
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

function Look_Classic (item as InventoryType, skipInput as integer = 0) as integer
    
    static dialog as ElementType
    static description as ElementType
    
    dim desc as string
    dim fontH as integer
    
    fontH = FONT_H+1
    
    '***************************************************************
    '* FILTER DESCRIPTION
    '***************************************************************
    desc = trim(Inventory_LoadDescription(item.id))
    if LookItemCallback <> 0 then
        LookItemCallback(item.id, desc)
    end if
    if len(desc) = 0 then
        desc = "No desc found for item id " + str(item.id)
    end if
    
    '*******************************************************************
    '* DIALOG WINDOW
    '*******************************************************************
    Elements_Clear
    BuildClassicWindow @dialog, item.longName
    
    '*******************************************************************
    '* DESCRIPTION
    '*******************************************************************
    Element_Init @description, desc
    description.parent = @dialog
    description.w = description.parent->w-8
    description.y = 4+fontH*2
    description.text_height = 1.4
    description.x = 4
    
    Elements_Add @description
    Elements_Render
    
    if keypress(KEY_ENTER) or keypress(KEY_TAB) or keypress(KEY_ESCAPE) or keypress(KEY_E) or mouseLB() or mouseRB() or mouseMB() then
        return 1
    end if
    
    return 0
    
end function

function Look (item as InventoryType, skipInput as integer = 0) as integer
	
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
    
    dim char as string*1
    
    dim img_w as integer, img_h as integer
    img_w = SPRITE_W*4
    img_h = SPRITE_H*4
    
    dim filtered as string
    dim wobbleStatus as integer
    dim timediff as double
    dim anchorJump as integer
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
            desc = "No desc found for item id " + str(item.id)
        end if
        
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
            textDescription.text_height = 2.0
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
            scrollRows = int((textDescription.h-container.h)/fontH+0.9999)
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
    
    if keypress(KEY_LALT) or keypress(KEY_RALT) then
        select case STATUS_WINDOW_HEIGHT
        case STATUS_WINDOW_HEIGHT_MIN
            STATUS_WINDOW_HEIGHT = STATUS_WINDOW_HEIGHT_MED
        case STATUS_WINDOW_HEIGHT_MED
            STATUS_WINDOW_HEIGHT = STATUS_WINDOW_HEIGHT_MAX
        case STATUS_WINDOW_HEIGHT_MAX
            STATUS_WINDOW_HEIGHT = STATUS_WINDOW_HEIGHT_MIN
        end select
        state = DialogStates.init
        LD2_PlaySound Sounds.uiSelect
    end if
    anchorJump = -1
    if keypress(KEY_0) or keypress(KEY_KP_0) then anchorJump = 0
    if keypress(KEY_1) or keypress(KEY_KP_1) then anchorJump = 1
    if keypress(KEY_2) or keypress(KEY_KP_2) then anchorJump = 2
    if keypress(KEY_3) or keypress(KEY_KP_3) then anchorJump = 3
    if keypress(KEY_4) or keypress(KEY_KP_4) then anchorJump = 4
    if keypress(KEY_5) or keypress(KEY_KP_5) then anchorJump = 5
    if keypress(KEY_6) or keypress(KEY_KP_6) then anchorJump = 6
    if keypress(KEY_7) or keypress(KEY_KP_7) then anchorJump = 7
    if keypress(KEY_8) or keypress(KEY_KP_8) then anchorJump = 8
    if keypress(KEY_9) or keypress(KEY_KP_9) then anchorJump = 9
    if anchorJump = 0 then
        scroll = 0
        LD2_PlaySound Sounds.uiSelect
    end if
    if anchorJump > 0 then
        Element_RenderPrepare @textDescription, str(anchorJump)+".", scroll
        LD2_PlaySound Sounds.uiSelect
    end if
    if keypress(KEY_DOWN) or keypress(KEY_S) or keypress(KEY_KP_2) or (mouseWheelY() > 0) then
        if scroll < scrollRows then
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
    static interval as double = -1
    static e as double
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
        interval = -1
        e = 0
    end if
    
    if (wobbleAction <> WobbleActions.NoAction) and interval = 1 then
        interval = -1
    end if
    
    select case wobbleType
    '*******************************************************************
    '* REVEALS
    '*******************************************************************
    case WobbleTypes.RevealNoSpin
        
        e = Easing_doEaseInOut(interval, 0.45)
        wobble->w = int(img_w*(1.0+(1-e))+0.5)
        wobble->h = int(img_h*(1.0+(1-e))+0.5)
        wobble->sprite_rot = 0
        is_reveal = 1
        
    case WobbleTypes.RevealSpin
        
        e = Easing_doEaseInOut(interval, 0.45)
        wobble->w = int(img_w*(1.0+(1-e))+0.5)
        wobble->h = int(img_h*(1.0+(1-e))+0.5)
        wobble->sprite_rot = int(e*360)
        is_reveal = 1
        
    case WobbleTypes.RevealBackSpin
        
        e = Easing_doEaseInOut(interval, 0.45)
        wobble->w = int(img_w*(1.0+(1-e))+0.5)
        wobble->h = int(img_h*(1.0+(1-e))+0.5)
        wobble->sprite_rot = int(e*-360)
        is_reveal = 1
    
    case WobbleTypes.Reveal540Spin
        
        e = Easing_doEaseInOut(interval, 0.45)
        wobble->w = int(img_w*(1.0+(1-e))+0.5)
        wobble->h = int(img_h*(1.0+(1-e))+0.5)
        wobble->sprite_rot = int(e*540+180)
        is_reveal = 1
    
    case WobbleTypes.Reveal540BackSpin
        
        e = Easing_doEaseInOut(interval, 0.45)
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
            
            e = Easing_doWobble(interval, 0.45)
            wobble->w = int(img_w*(1-e)+0.5)
            wobble->h = int(img_h*(1+e)+0.5)
            
        case WobbleActions.Slapup, WobbleActions.SlapDown
            
            e = Easing_doWobble(interval, 0.45)
            wobble->h = int(img_h*(1+e)+0.5)
        
        case WobbleActions.Punch
            
            if interval=-1 then LD2_PlaySound Sounds.punch
            e = Easing_doShake(interval, 0.7)
            wobble->w = int(img_w*(1.0+e)+0.5)
            wobble->h = int(img_h*(1.0+e)+0.5)
            
        end select
    
    '*******************************************************************
    '* SQUISHY
    '*******************************************************************
    case WobbleTypes.Squishy
        
        select case wobbleAction
        case WobbleActions.SlapLeft, WobbleActions.SlapRight
            
            if interval=-1 then LD2_PlaySound Sounds.blood2
            e = Easing_doWobble(interval, 0.45)
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
            
            if interval=-1 then LD2_PlaySound Sounds.blood2
            e = Easing_doWobble(interval, 0.45)
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
                stretching = 1
                stretchStart = timer
                Easing_doEaseInOut(-1)
                interval = 0.15
                LD2_PlaySound Sounds.squishy
            end if
            e = Easing_doEaseInOut(interval, 2.0)
            wobble->w = int(img_h*(1+e*0.1)+0.5)
            wobble->h = int(img_h*(1+e*0.7)+0.5)
            wobble->sprite_rot = e*-2
            if interval = 1 then interval = 0.9999
        
        case WobbleActions.Punch
            
            if interval=-1 then LD2_PlaySound Sounds.punch: LD2_PlaySound Sounds.splatter
            e = Easing_doShake(interval, 0.7)
            wobble->w = int(img_w*(1.0+e)+0.5)
            wobble->h = int(img_h*(1.0+e)+0.5)
            
        case else
            
            if stretching then
                stretching = 0
                wobble->sprite_rot = 0
                LD2_PlaySound Sounds.blood2
                Easing_doShake(-1)
                interval = 1-interval
            end if
            e = Easing_doShake(interval, 0.3)
            wobble->h = int(img_h*(1+e*1.5)+0.5)
            
        end select
    '*******************************************************************
    '* METAL
    '*******************************************************************
    case WobbleTypes.Metal
        
        select case wobbleAction
        case WobbleActions.SlapLeft, WobbleActions.SlapRight
            
            if interval = -1 then
                wobble->sprite_rot = 0
                LD2_PlaySound Sounds.lookMetal
            end if
            e = Easing_doShake(interval, 0.45)
            e = abs(e)
            select case wobbleAction
            case WobbleActions.SlapLeft
                wobble->x = int((img_w*(1-e*0.7)-wobble->w)*0.5)
                if interval > 0.15 then wobble->sprite_rot = 10
            case WobbleActions.SlapRight
                wobble->x = int((img_w*(1+e*0.7)-wobble->w)*0.5)
                if interval > 0.15 then wobble->sprite_rot = -45
            end select
            wobble->y = int((img_h-wobble->h)*0.5)
            if interval = 1 then
                wobble->sprite_rot = 0
            end if
        
        case WobbleActions.SlapUp, WobbleActions.SlapDown
            
            if interval = -1 then
                wobble->sprite_rot = 0
                LD2_PlaySound Sounds.lookMetal
            end if
            e = Easing_doShake(interval, 0.45)
            select case wobbleAction
            case WobbleActions.SlapUp
                wobble->y = int((img_h*(1-abs(e)*0.5)-wobble->h)*0.5)
                if interval > 0.15 then wobble->sprite_rot = 3
            case WobbleActions.SlapDown
                wobble->y = int((img_h*(1+abs(e)*0.5)-wobble->h)*0.5)
                if interval > 0.15 then wobble->sprite_rot = -6
            end select
            wobble->x = int((img_w-wobble->w)*0.5)
            if interval = 1 then
                wobble->sprite_rot = 0
            end if
        
        case WobbleActions.Punch
            
            if interval = -1 then
                LD2_PlaySound Sounds.punch
                LD2_PlaySound Sounds.lookMetal
            end if
            e = Easing_doShake(interval, 0.35)
            e = abs(e)
            wobble->w = int(img_w*(1.0+e*0.7)+0.5)
            wobble->h = int(img_h*(1.0+e*0.7)+0.5)
            wobble->sprite_rot = 30
            
            if interval = 1 then
                wobble->sprite_rot = 0
            end if
            
        end select
        
    end select
    
    if (wobble->w and 1) = 0 then wobble->w -= 1
    if (wobble->h and 1) = 0 then wobble->h -= 1
    if wobble->x = 9999 then wobble->x = int((img_w-wobble->w)*0.5)
    if wobble->y = 9999 then wobble->y = int((img_h-wobble->h)*0.5) + int((STATUS_WINDOW_HEIGHT - STATUS_WINDOW_HEIGHT_MIN)*0.5)
    
    if interval=1 then
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
    FOR i = 0 TO Inventory_GetSize-1
        id = LD2_GetStatusItem(i)
        qty = LD2_GetStatusAmount(i)
        qtyMax = Player_GetItemMaxQty(id)
        IF Inventory_Add(id, qty, qtyMax, i) THEN
            EXIT FOR
        END IF
    NEXT i
    Inventory_RefreshNames
    
end sub

sub GetInventoryRowsCols(byref rows as integer, byref cols as integer)
    
    select case STATUS_INVENTORY_SIZE
    case 4
        rows = 1
        cols = 4
    case 5
        rows = 1
        cols = 5
    case 6
        rows = 2
        cols = 3
    case 8
        rows = 2
        cols = 4
    case 9
        rows = 3
        cols = 3
    case 10
        rows = 2
        cols = 5
    case 12
        rows = 3
        cols = 4
    case 15
        rows = 3
        cols = 5
    case 16
        rows = 4
        cols = 4
    end select
    
end sub

sub STATUS_SetLookItem(itemId as integer)
    
    LOOK_ITEM_ID = itemId
    
end sub

function StatusScreen_Classic(skipInput as integer = 0) as integer
    
    static lookItem as InventoryType
    static mixItem as InventoryType
    
    static selection as integer
    static action as integer = -1
    static state as integer
    static mixMode as integer
    
    dim selected as InventoryType
    SELECTED_INVENTORY_SLOT = selection
    Inventory_GetItemBySlot(selected, SELECTED_INVENTORY_SLOT)
    
    select case state
    case DialogStates.closed
        state = DialogStates.ready
        LD2_PlaySound Sounds.uiMenu
        STATUS_RefreshInventory
        lookItem.id = -1
        action = -1
        if LOOK_ITEM_ID > -1 then
            Inventory_PopulateItem(lookItem, LOOK_ITEM_ID)
        end if
    end select
    
    if lookItem.id > -1 then
        if Look_Classic(lookItem, skipInput) then
            lookItem.id = -1
            if LOOK_ITEM_ID > -1 then
                LOOK_ITEM_ID = -1
                state = DialogStates.closing
                return StatusScreen(skipInput)
            end if
        else
            return 0
        end if
    end if
    
    RenderClassicScreen action, iif(mixMode, @mixItem, 0)
    Elements_Render
    
    '*******************************************************************
    '* INPUT START
    '*******************************************************************
    if keypress(KEY_UP) or keypress(KEY_KP_8) then
        if selection > 0 then
            selection -= 1
            LD2_PlaySound Sounds.uiArrows
        else
            LD2_PlaySound Sounds.uiInvalid
        end if
    end if
    if keypress(KEY_DOWN) or keypress(KEY_KP_2) then
        if selection < STATUS_INVENTORY_SIZE-1 then
            selection += 1
            LD2_PlaySound Sounds.uiArrows
        else
            LD2_PlaySound Sounds.uiInvalid
        end if
    end if
    if action > -1 then
        if keypress(KEY_LEFT) or keypress(KEY_KP_4) or keypress(KEY_A) then
            if action > 0 then
                action -= 1
                LD2_PlaySound Sounds.uiArrows
            else
                LD2_PlaySound Sounds.uiInvalid
            end if
        end if
        if keypress(KEY_RIGHT) or keypress(KEY_KP_8) or keypress(KEY_D) then
            if action < 3 then
                action += 1
                LD2_PlaySound Sounds.uiArrows
            else
                LD2_PlaySound Sounds.uiInvalid
            end if
        end if
    end if
    if keypress(KEY_ENTER) or keypress(KEY_KP_ENTER) then
        if mixMode then
            Mix mixItem, selected
            mixMode = 0
            action = -1
        elseif action > -1 then
            select case action
            case 0 '* USE
                if UseItem(selected) then
                    state = DialogStates.closing
                end if
            case 1 '* LOOK
                lookItem = selected
            case 2  '* MIX
                if canMix(selected.id) then
                    mixMode = 1
                    mixItem = selected
                    LD2_PlaySound Sounds.uiSubmenu
                end if
            case 3  '* Drop
                Drop selected
            end select
            action = -1
        else
            '* item selection
            action = 0
            LD2_PlaySound Sounds.uiSubmenu
        end if
    end if
    if keypress(KEY_TAB) then
        state = DialogStates.closed
        LD2_PlaySound Sounds.uiMenu
        return 1
    end if
    
    return 0
    
end function

function StatusScreen(skipInput as integer = 0) as integer
	
    if DEBUGMODE then LogDebug __FUNCTION__, str(skipInput)
	
	static dialog as ElementType
    static lookItem as InventoryType
    static mixItem as InventoryType
    static mixMode as integer = 0
	static action as integer
    static prevWindowHeight as integer = -1
    static state as integer = DialogStates.closed
    static row as integer
    static col as integer
    static e as double = -1
    
    dim numCols as integer
    dim numRows as integer
    dim selected as InventoryType
    
    GetInventoryRowsCols numRows, numCols
	
    
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
            e = Easing_doEaseInOut(-1)
            LD2_PlaySound Sounds.uiMenu
            if STATUS_TEMP_HEIGHT > -1 then
                prevWindowHeight = STATUS_WINDOW_HEIGHT
                STATUS_SetWindowSize STATUS_TEMP_HEIGHT
                STATUS_TEMP_HEIGHT = -1
            end if
        else
            e = Easing_doEaseInOut(0, STATUS_EASE_SPEED)
        end if
        dialog.h = e * STATUS_WINDOW_HEIGHT
        Element_Render @dialog
        if e = 1 then
            state = DialogStates.init
            e = -1
        end if
        return 0
    case DialogStates.closing
        if e = -1 then
            e = Easing_doEaseInOut(-1)
            LD2_PlaySound Sounds.uiMenu
        else
            e = Easing_doEaseInOut(0, STATUS_EASE_SPEED)
        end if
        dialog.h = (1-e) * STATUS_WINDOW_HEIGHT
        Element_Render @dialog
        if e = 1 then
            state = DialogStates.closed
            e = -1
            if prevWindowHeight > -1 then
                STATUS_WINDOW_HEIGHT = prevWindowHeight
                prevWindowHeight = -1
            end if
            return 1
        else
            return 0
        end if
    case DialogStates.init
        state = DialogStates.ready
        STATUS_RefreshInventory
        row = int(SELECTED_INVENTORY_SLOT / numCols)
        col = SELECTED_INVENTORY_SLOT-row*numCols
        LookItem.id = -1
        action = -1
        if LOOK_ITEM_ID > -1 then
            Inventory_PopulateItem(lookItem, LOOK_ITEM_ID)
        end if
    end select
    
    
    '*******************************************************************
    '* START
    '*******************************************************************
    if LookItem.id > -1 then
        if Look(LookItem, skipInput) then
            LookItem.id = -1
            if LOOK_ITEM_ID > -1 then
                LOOK_ITEM_ID = -1
                state = DialogStates.closing
                return StatusScreen(skipInput)
            end if
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
    
    SELECTED_INVENTORY_SLOT = row*numCols+col
    Inventory_GetItemBySlot(selected, SELECTED_INVENTORY_SLOT)
    
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
    
    if keypress(KEY_LALT) or keypress(KEY_RALT) then
        select case STATUS_WINDOW_HEIGHT
        case STATUS_WINDOW_HEIGHT_MIN
            STATUS_WINDOW_HEIGHT = STATUS_WINDOW_HEIGHT_MED
        case STATUS_WINDOW_HEIGHT_MED
            STATUS_WINDOW_HEIGHT = STATUS_WINDOW_HEIGHT_MAX
        case STATUS_WINDOW_HEIGHT_MAX
            STATUS_WINDOW_HEIGHT = STATUS_WINDOW_HEIGHT_MIN
        end select
        state = DialogStates.init
        LD2_PlaySound Sounds.uiSelect
    end if
        
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
    dim slot as integer
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
        id   = Inventory_GetUseItem()
        qty  = Inventory_GetUseQty()
        discard = Inventory_GetUseItemDiscard()
        if (UseItemCallback <> 0) then
            UseItemCallback(id, qty, exitMenu)
        else
            LD2_AddToStatus id, qty
        end if
        if discard then
            LD2_AddToStatus item.id, -qty, item.slot
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

function STATUS_DialogYesNo(message as string, playOpenSound as integer = 1) as integer
    
    dim e as double
    dim pixels as integer
    dim halfX as integer
    dim halfY as integer
    dim size as integer
    dim maxw as integer
    dim w as integer
    
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
    
    if playOpenSound then
        LD2_PlaySound Sounds.uiMenu
    end if
	
	LD2_SaveBuffer 2
	LD2_CopyBuffer 1, 2
	
    Easing_doEaseInOut(-1)
	do
        e = Easing_doEaseInOut(0, STATUS_EASE_SPEED)
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
    optionYes.y = int(dialog.h*0.3333)
    optionYes.padding_x = int(fontW*2.5): optionYes.padding_y = 5
    optionYes.background = 68
    optionYes.text_height = 1
    optionNo.y  = optionYes.y + int(fontH*2.5)
    optionNo.padding_x = int(fontW*2.5): optionNo.padding_y = 5
    optionNo.text_height = 1
    optionYes.background = 70
    
    maxw = Element_GetTextWidth(@optionYes)
    w = Element_GetTextWidth(@optionNo)
    if w > maxw then maxw = w
    optionYes.w = maxw
    optionNo.w = maxw
    
    Elements_Clear
    Elements_Add @dialog
    Elements_Add @title, @dialog
    Elements_Add @optionYes, @dialog
    Elements_Add @optionNo, @dialog
    
    selections(0) = OptionIds.Yes
    selections(1) = OptionIds.No: selection = 1: escapeSelection = 1
    
    do
        select case selections(selection)
        case OptionIds.Yes
            optionYes.background = 70: optionYes.text_color = 31
            optionNo.background = STATUS_DIALOG_COLOR
            optionNo.text_color = 7
        case OptionIds.No
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
    
    if selections(selection) <> OptionIds.No then
        e = Easing_doEaseInOut(-1)
        do
            pixels = int((1-e) * size)
            dialog.x = halfX - pixels * modw
            dialog.y = halfY - pixels * modh
            dialog.w = pixels * modw * 2
            dialog.h = pixels * modh * 2
            LD2_CopyBuffer 2, 1
            Element_Render @dialog
            LD2_RefreshScreen
            PullEvents
            e = Easing_doEaseInOut(0, STATUS_EASE_SPEED)
        loop while e < 1
    end if
    
    LD2_CopyBuffer 2, 1
    LD2_RefreshScreen
    LD2_RestoreBuffer 2
    
    return selections(selection)
    
end function

sub STATUS_DialogOk(message as string, playOpenSound as integer = 1)
    
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
    
    if playOpenSound then
        LD2_PlaySound Sounds.uiMenu
    end if
	
	LD2_SaveBuffer 2
	LD2_CopyBuffer 1, 2
	
    Easing_doEaseInOut(-1)
	do
        e = Easing_doEaseInOut(0, STATUS_EASE_SPEED)
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
    
    e = Easing_doEaseInOut(-1)
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
        e = Easing_doEaseInOut(0, STATUS_EASE_SPEED)
	loop while e > 0
    
    LD2_CopyBuffer 2, 1
    LD2_RefreshScreen
    LD2_RestoreBuffer 2
    
end sub

function STATUS_DialogExitGame(message as string, playOpenSound as integer = 1) as integer
    
    dim e as double
    dim pixels as integer
    dim halfX as integer
    dim halfY as integer
    dim size as integer
    dim maxw as integer
    dim w as integer
    dim n as integer
    
    dim dialog as ElementType
    dim title as ElementType
    dim options(2) as ElementType
    
    dim selections(2) as integer
    dim selection as integer
    dim escapeSelection as integer
    
    dim fontW as integer
    dim fontH as integer
    
    fontW = Elements_GetFontWidthWithSpacing()
    fontH = Elements_GetFontHeightWithSpacing()
    
    Element_Init @dialog
    Element_Init @title, message, 31
    Element_Init @options(0), "Back to Game", 31, ElementFlags.CenterX
    Element_Init @options(1), "How to Play ", 31, ElementFlags.CenterX
    Element_Init @options(2), "Exit Game   ", 31, ElementFlags.CenterX
    
    dialog.background = STATUS_DIALOG_COLOR
    dialog.background_alpha = STATUS_DIALOG_ALPHA
    dialog.border_size = 1
    dialog.border_color = 15
    title.text_height = 2.0
    
    halfX = int(SCREEN_W*0.5)
    halfY = int(SCREEN_H*0.5)
    
    size = int(SCREEN_H*0.25)
    
    dim modw as double: modw = 1.6
    dim modh as double: modh = 0.8+ubound(options)*0.1
    
    if playOpenSound then
        LD2_PlaySound Sounds.uiMenu
    end if
	
	LD2_SaveBuffer 2
	LD2_CopyBuffer 1, 2
	
    Easing_doEaseInOut(-1)
	do
        e = Easing_doEaseInOut(0, STATUS_EASE_SPEED)
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
    
    dim top as integer
    top = int(dialog.h*0.3333)
    pixels = size
    dialog.x = halfX - pixels * modw
    dialog.y = halfY - pixels * modh
    dialog.w = pixels * modw * 2
    dialog.h = pixels * modh * 2
    title.x = fontW
    title.y = fontH
    for n = 0 to 2
        options(n).padding_x = fontW
        options(n).padding_y = 5
        options(n).y  = top + n*int(fontH*2.5) - options(n).padding_y
        options(n).text_height = 1
        w = Element_GetTextWidth(@options(n)) 
        if w > maxw then maxw = w
    next n
    for n = 0 to 2
        options(n).w = maxw
    next n
    
    Elements_Clear
    Elements_Add @dialog
    Elements_Add @title, @dialog
    for n = 0 to 2
        Elements_Add @options(n), @dialog
    next n
    
    selections(0) = OptionIds.BackToGame
    selections(1) = OptionIds.HowToPlay
    selections(2) = OptionIds.ExitGame
    selection = 0: escapeSelection = 0
    
    do
        for n = 0 to 2
            if selection = n then
                options(n).background = OPTION_ACTIVE_BG
                options(n).text_color = OPTION_ACTIVE_COLOR
            else
                options(n).background = OPTION_INACTIVE_BG
                options(n).text_color = OPTION_INACTIVE_COLOR
            end if
        next n
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
            if selection > ubound(options) then
                selection = ubound(options): LD2_PlaySound Sounds.uiInvalid
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
    
    if selections(selection) <> OptionIds.ExitGame then
        e = Easing_doEaseInOut(-1)
        do
            pixels = int((1-e) * size)
            dialog.x = halfX - pixels * modw
            dialog.y = halfY - pixels * modh
            dialog.w = pixels * modw * 2
            dialog.h = pixels * modh * 2
            LD2_CopyBuffer 2, 1
            Element_Render @dialog
            LD2_RefreshScreen
            PullEvents
            e = Easing_doEaseInOut(0, STATUS_EASE_SPEED)
        loop while pixels > 1
    end if
    
    LD2_CopyBuffer 2, 1
    LD2_RefreshScreen
    LD2_RestoreBuffer 2
    
    return selections(selection)
    
end function

private sub elementsPutSprite(x as integer, y as integer, spriteId as integer, spriteSetId as integer, doFlip as integer = 0, w as integer = -1, h as integer = -1, angle as integer = 0)
    dim dest as SDL_RECT
    dest.x = x
    dest.y = y
    dest.w = iif(w > -1, w, SPRITE_W)
    dest.h = iif(h > -1, h, SPRITE_H)
    if SHARED_SPRITES <> 0 then
        SHARED_SPRITES->putToScreenEx x, y, spriteId, doFlip, angle, 0, @dest
    end if
end sub

private sub elementsSpriteMetrics(spriteId as integer, spriteSetId as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
    if SHARED_SPRITES <> 0 then
        SHARED_SPRITES->getMetrics spriteId, x, y, w, h
    end if
end sub

function STATUS_DialogLaunch(message as string, playOpenSound as integer = 1) as integer
    
    dim e as double
    dim pixels as integer
    dim halfX as integer
    dim halfY as integer
    dim size as integer
    dim maxw as integer
    dim mx as integer
    dim my as integer
    dim w as integer
    dim n as integer
    dim x as integer
    dim y as integer
    
    dim sprites(2) as VideoSprites
    
    LD2_InitSprites "", @sprites(0), 320, 200: sprites(0).loadBmp DATA_DIR+"launcher/remastered.bmp"
    LD2_InitSprites "", @sprites(1), 320, 200: sprites(1).loadBmp DATA_DIR+"launcher/classic.bmp"
    LD2_InitSprites "", @sprites(2), 320, 200: sprites(2).loadBmp DATA_DIR+"launcher/enhanced.bmp"
    
    Elements_SetSpritePutCallback @elementsPutSprite
    Elements_SetSpriteMetricsCallback @elementsSpriteMetrics
    
    dim dialog as ElementType
    dim title as ElementType
    dim labels(2) as ElementType
    dim options(5) as ElementType
    dim backgrounds(5) as integer
    dim description as ElementType
    dim thumbnail as ElementType
    
    dim selections(5) as integer
    dim selection as integer
    dim refresh as integer
    
    dim res_x as integer
    dim res_y as integer
    LD2_GetWindowSize res_x, res_y
    
    dim fontW as integer
    dim fontH as integer
    
    fontW = Elements_GetFontWidthWithSpacing()
    fontH = Elements_GetFontHeightWithSpacing()
    
    dim radioOn as string
    dim radioOff as string
    dim checked as string
    dim unchecked as string
    radioOn   = "[*] "
    radioOff  = "[_] "
    checked   = "[*] "
    unchecked = "[_] "
    
    Element_Init @dialog
    Element_Init @title, message, 31
    Element_Init @labels(0), "Select Version", 31
    Element_Init @labels(1), "Launch Options", 31
    Element_Init @labels(2), "v1.1.193", 31
    Element_Init @options(0), iif(Game_notFlag(GameFlags.ClassicMode) and Game_notFlag(GameFlags.EnhancedMode),radioOn,radioOff)  +"Remastered", 31
    Element_Init @options(1), iif(Game_hasFlag(GameFlags.ClassicMode) and Game_notFlag(GameFlags.EnhancedMode),radioOn,radioOff) +"Classic"   , 31
    Element_Init @options(2), iif(Game_hasFlag(GameFlags.EnhancedMode),radioOn,radioOff) +"Enhanced"  , 31
    Element_Init @options(3), iif(Game_hasFlag(GameFlags.TestMode),checked,unchecked)+"Test Mode" , 31
    Element_Init @options(4), iif(Game_hasFlag(GameFlags.NoBackground)=0,checked,unchecked)+"Background" , 31
    Element_Init @options(5), "Play Game", 31, ElementFlags.CenterText
    Element_Init @description
    
    options(2).disabled = 1
    
    dialog.background = STATUS_DIALOG_COLOR
    dialog.background_alpha = STATUS_DIALOG_ALPHA
    dialog.border_size = 1
    dialog.border_color = 15
    title.text_height = 2.0
    
    labels(0).parent = @dialog
    labels(1).parent = @dialog
    labels(2).parent = @dialog
    
    halfX = int(SCREEN_W*0.5)
    halfY = int(SCREEN_H*0.5)
    
    size = SCREEN_W*0.49
    
    dim modw as double: modw = 1.0
    dim modh as double: modh = SCREEN_H/SCREEN_W
    
    if playOpenSound then
        LD2_PlaySound Sounds.uiMix
    end if
	
	LD2_SaveBuffer 2
	LD2_CopyBuffer 1, 2
	
    Easing_doEaseInOut(-1)
	do
        e = Easing_doEaseInOut(0, STATUS_EASE_SPEED)
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
    
    dim top as integer
    top = int(dialog.h*0.3333)
    pixels = size
    dialog.x = halfX - pixels * modw
    dialog.y = halfY - pixels * modh
    dialog.w = pixels * modw * 2
    dialog.h = pixels * modh * 2
    title.x = fontW
    title.y = fontH
    for n = 0 to ubound(options)
        options(n).x = fontW
        options(n).padding_x = fontW
        options(n).padding_y = 7
        options(n).y = fontH*2.5 + n*int(fontH*3.5)
        options(n).text_height = 1
        w = Element_GetTextWidth(@options(n)) 
        if w > maxw then maxw = w
        backgrounds(n) = OPTION_ACTIVE_BG
    next n
    for n = 0 to ubound(options)
        options(n).w = maxw
    next n
    options(3).y -= fontH*1.0
    options(4).y -= fontH*1.0
    backgrounds(5) = 54
    
    labels(0).x = fontW
    labels(0).y = fontH
    labels(1).x = fontW
    labels(1).y = options(3).y-fontH*1.5
    labels(2).x = dialog.w-Element_GetTextWidth(@labels(2))-fontW
    labels(2).y = fontH
    
    description.parent = @dialog
    description.padding_x = fontW
    description.x = maxw+options(0).x+options(0).padding_x*2+fontW*1.5
    description.y = options(0).y+fontH
    description.w = dialog.w - description.x - description.padding_x*2
    description.text_height = 1.8
    
    Elements_Clear
    Elements_Add @dialog
    Elements_Add @title, @dialog
    for n = 0 to ubound(options)
        if options(n).disabled then continue for
        Elements_Add @options(n), @dialog
    next n
    Elements_Add @labels(0)
    Elements_Add @labels(1)
    Elements_Add @labels(2)
    
    selections(0) = OptionIds.Remastered
    selections(1) = OptionIds.Classic
    selections(2) = OptionIds.Enhanced
    selections(3) = OptionIds.ToggleTestMode
    selections(4) = OptionIds.ToggleBackground
    selections(5) = OptionIds.PlayGame
    selection = 0
    
    dim descs(4) as string
    descs(0) = "Remastered (2020)\\The new version of the game. The feature presentation."
    descs(1) = "Classic (2002)\\Intended to be as close to the original as possible."
    descs(2) = "Classic (Enhanced)\\The original game with some extra sounds and features."
    descs(3) = "Test Mode\\Skip title and intro sequences. Cheats enabled."
    descs(4) = "Dynamic Background\\Multi-layered background (mountains, clouds, etc.)."
    Elements_Add @description
    
    Element_Init @thumbnail
    thumbnail.parent = @dialog
    thumbnail.padding_x = description.padding_x
    thumbnail.w = 160 'description.w
    thumbnail.h = 95 'description.w*0.5625
    thumbnail.x = description.x
    thumbnail.y = dialog.h-thumbnail.h-fontH*1.5
    Elements_Add @thumbnail
    
    options(5).parent = @dialog
    options(5).background = backgrounds(4)
    options(5).w = maxw
    options(5).padding_x = fontW
    options(5).padding_y = 11
    options(5).x = fontW
    options(5).y = thumbnail.y+thumbnail.h-options(4).padding_y*2-fontH+1
    options(5).text_height = 1
    
    'description.y -= fontH*2.5
    
    title.x = description.x+description.padding_x
    
    refresh = 1
    do
        for n = 0 to ubound(options)
            if options(n).disabled then continue for
            if selection = n then
                options(n).background = backgrounds(n)+2
                options(n).text_color = OPTION_ACTIVE_COLOR
            else
                options(n).background = backgrounds(n)
                options(n).text_color = OPTION_ACTIVE_COLOR
            end if
        next n
        if refresh then
            refresh = 0
            if selection > -1 and selection <= ubound(descs) then
                description.text = descs(selection)
                if selection <= ubound(sprites) then
                    thumbnail.sprite_set_id = 0
                    thumbnail.sprite = 0
                    SHARED_SPRITES = @sprites(selection)
                end if
            else
                description.text = "Selected\\"
                description.text += iif(CLASSICMODE,iif(ENHANCEDMODE,"Classic (Enhanced)","Classic (2002)"),"Remastered (2020)")
                description.text += "\Test Mode "+iif(TESTMODE,"On","Off")
                SHARED_SPRITES = @sprites(CLASSICMODE)
            end if
            if selection > -1 then LD2_PlaySound Sounds.uiArrows
        end if
        LD2_CopyBuffer 2, 1
        Elements_Render
		LD2_RefreshScreen
        PullEvents
        if QuitEvent() then exit do
        
        if MouseMoved() then
            mx = int(mouseX()*(SCREEN_W/res_x))
            my = int(mouseY()*(SCREEN_H/res_Y))
            for n = 0 to ubound(options)
                if options(n).disabled then continue for
                x = options(n).render_visible_x
                y = options(n).render_visible_y
                if  (mx >= x) and (mx <= x+options(n).render_outer_w) _
                and (my >= y) and (my <= y+options(n).render_outer_h) then
                    if selection <> n then
                        selection = n
                        refresh = 1
                    end if
                    exit for
                end if
            next n
            if n > ubound(options) then
                if selection <> -1 then
                    selection = -1
                    refresh = 1
                end if
            end if
        end if
        if (newMouseLB() or keypress(KEY_ENTER)) and selection <> -1 then
            select case selections(selection)
            case OptionIds.Remastered
                LD2_PlaySound iif(CLASSICMODE or ENHANCEDMODE,Sounds.uiToggle,Sounds.dialog)
                CLASSICMODE  = 0
                ENHANCEDMODE = 0
                options(0).text = iif(CLASSICMODE,radioOff,radioOn)+"Remastered"
                options(1).text = iif(CLASSICMODE and (ENHANCEDMODE=0),radioOn,radioOff)+"Classic"
                options(2).text = iif(ENHANCEDMODE,radioOn,radioOff)+"Enhanced"
            case OptionIds.Classic
                LD2_PlaySound iif((CLASSICMODE=0) or ENHANCEDMODE,Sounds.uiToggle,Sounds.dialog)
                CLASSICMODE  = 1
                ENHANCEDMODE = 0
                options(0).text = iif(CLASSICMODE,radioOff,radioOn)+"Remastered"
                options(1).text = iif(CLASSICMODE and (ENHANCEDMODE=0),radioOn,radioOff)+"Classic"
                options(2).text = iif(ENHANCEDMODE,radioOn,radioOff)+"Enhanced"
            case OptionIds.Enhanced
                LD2_PlaySound iif((CLASSICMODE=0) or (ENHANCEDMODE=0),Sounds.uiToggle,Sounds.dialog)
                CLASSICMODE  = 1
                ENHANCEDMODE = 1
                options(0).text = iif(CLASSICMODE,radioOff,radioOn)+"Remastered"
                options(1).text = iif(CLASSICMODE and (ENHANCEDMODE=0),radioOn,radioOff)+"Classic"
                options(2).text = iif(ENHANCEDMODE,radioOn,radioOff)+"Enhanced"
            case OptionIds.ToggleTestMode
                TESTMODE = iif(TESTMODE=0,1,0)
                options(selection).text = iif(TESTMODE,checked,unchecked)+"Test Mode" 
                LD2_PlaySound Sounds.uiToggle
            case OptionIds.ToggleBackground
                Game_toggleFlag(GameFlags.NoBackground)
                options(selection).text = iif(Game_hasFlag(GameFlags.NoBackground)=0,checked,unchecked)+"Background" 
                LD2_PlaySound Sounds.uiToggle
            case else
                LD2_PlaySound Sounds.uiSelect
                exit do
            end select
        end if
        if keypress(KEY_DOWN) then
            selection += 1
            if selection > ubound(options) then
                selection = ubound(options): LD2_PlaySound Sounds.uiInvalid
            else
                refresh = 1
            end if
        end if
        if keypress(KEY_UP) then
            selection -= 1
            if selection < 0 then
                selection = 0: LD2_PlaySound Sounds.uiInvalid
            else
                refresh = 1
            end if
        end if
        if keypress(KEY_ESCAPE) then
            Game_setFlag GameFlags.ExitGame
            LD2_PlaySound Sounds.uiCancel
            exit do
        end if
    loop
    
    Elements_Clear
    
    if (selections(selection) <> OptionIds.ExitGame) and (QuitEvent() = 0) then
        e = Easing_doEaseInOut(-1)
        do
            pixels = int((1-e) * size)
            dialog.x = halfX - pixels * modw
            dialog.y = halfY - pixels * modh
            dialog.w = pixels * modw * 2
            dialog.h = pixels * modh * 2
            LD2_CopyBuffer 2, 1
            Element_Render @dialog
            LD2_RefreshScreen
            PullEvents
            e = Easing_doEaseInOut(0, STATUS_EASE_SPEED)
        loop while pixels > 1
        if CLASSICMODE then Game_setFlag GameFlags.ClassicMode
        if ENHANCEDMODE then Game_setFlag GameFlags.EnhancedMode
        if TESTMODE then Game_setFlag GameFlags.TestMode
    end if
    
    LD2_CopyBuffer 2, 1
    LD2_RefreshScreen
    LD2_RestoreBuffer 2
    
    return selections(selection)
    
end function
