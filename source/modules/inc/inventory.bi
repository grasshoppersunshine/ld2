#pragma once
#inclib "inventory"

type InventoryType
    id as integer
    qty as integer
    max as integer
    shortName as string
    longName as string
    slot as integer
    visible as integer
end type

declare function Inventory_Add (id as integer, qty as integer, max as integer = -1) as integer
declare function Inventory_AddHidden (id as integer, qty as integer, max as integer = -1) as integer
declare function Inventory_AddQty (slot as integer, qty as integer) as integer
DECLARE SUB Inventory_Clear ()
DECLARE FUNCTION Inventory_GetErrorMessage (errorId as integer) as string
declare sub Inventory_GetItem (byref item as InventoryType, id as integer)
declare function Inventory_GetItemBySlot (byref item as InventoryType, slot as integer) as integer
declare function Inventory_GetSize () as integer
declare function Inventory_HasItem (itemId as integer) as integer
DECLARE FUNCTION Inventory_Init (size AS INTEGER, sizeVisible as integer = -1) as integer
DECLARE FUNCTION Inventory_LoadDescription (itemId AS INTEGER) as string
DECLARE FUNCTION Inventory_Mix(itemId0 AS INTEGER, itemId1 AS INTEGER, resultMixMsg AS STRING) as integer
DECLARE SUB Inventory_RefreshNames ()
declare sub Inventory_RemoveItem (byref item as InventoryType)
declare sub Inventory_ResetItem (byref item as InventoryType)
DECLARE FUNCTION Inventory_SidToItemId (sid AS STRING) as integer

declare function Inventory_Use (itemId as integer) as integer
declare function Inventory_GetUseItem() as integer
declare function Inventory_GetUseQty() as integer
declare function Inventory_GetUseMessage() as string
declare function Inventory_GetUseItemDiscard() as integer
declare function Inventory_GetShortName(id as integer) as string
declare function Inventory_GetSid(id as integer) as string
declare function Inventory_GetMaxId() as integer

CONST INVENTORYMAXSIZE = 99
CONST InventoryErr_OUTOFBOUNDS = -101
CONST InventoryErr_INVALIDSIZE = -102
CONST InventoryErr_SIZETOOBIG = -103
CONST InventoryErr_NOVACANTSLOT = -104

