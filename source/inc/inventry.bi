#pragma once
#inclib "inventry"

TYPE InventoryType
  id AS INTEGER
  qty AS INTEGER
  shortName AS STRING * 15
  longName AS STRING * 25
  slot AS INTEGER
END TYPE

DECLARE FUNCTION Inventory_Add (id AS INTEGER, qty AS INTEGER) as integer
DECLARE FUNCTION Inventory_AddQty (slot AS INTEGER, qty AS INTEGER) as integer
DECLARE SUB Inventory_Clear ()
DECLARE FUNCTION Inventory_GetErrorMessage (errorId as integer) as string
DECLARE SUB Inventory_GetItem (item AS InventoryType, id AS INTEGER)
DECLARE FUNCTION Inventory_GetItemBySlot (item AS InventoryType, slot AS INTEGER) as integer
DECLARE FUNCTION Inventory_Init (size AS INTEGER) as integer
DECLARE FUNCTION Inventory_LoadDescription (itemId AS INTEGER) as string
DECLARE FUNCTION Inventory_Mix(itemId0 AS INTEGER, itemId1 AS INTEGER, resultMixMsg AS STRING) as integer
DECLARE SUB Inventory_RefreshNames ()
DECLARE SUB Inventory_RemoveItem (item AS InventoryType)
DECLARE FUNCTION Inventory_SidToItemId (sid AS STRING) as integer
DECLARE FUNCTION Inventory_GetSuccessMsg (itemId AS INTEGER) as string
DECLARE FUNCTION Inventory_GetFailMsg (itemId AS INTEGER) as string

CONST INVENTORYMAXSIZE = 99
CONST InventoryErr_OUTOFBOUNDS = -101
CONST InventoryErr_INVALIDSIZE = -102
CONST InventoryErr_SIZETOOBIG = -103
CONST InventoryErr_NOVACANTSLOT = -104

