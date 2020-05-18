TYPE InventoryType
  id AS INTEGER
  qty AS INTEGER
  shortName AS STRING * 15
  longName AS STRING * 25
  slot AS INTEGER
END TYPE

DECLARE FUNCTION Inventory.Add% (id AS INTEGER, qty AS INTEGER)
DECLARE FUNCTION Inventory.AddQty% (slot AS INTEGER, qty AS INTEGER)
DECLARE SUB Inventory.Clear ()
DECLARE FUNCTION Inventory.GetErrorMessage$ ()
DECLARE SUB Inventory.GetItem (item AS InventoryType, id AS INTEGER)
DECLARE FUNCTION Inventory.GetItemBySlot% (item AS InventoryType, slot AS INTEGER)
DECLARE FUNCTION Inventory.Init% (size AS INTEGER)
DECLARE FUNCTION Inventory.LoadDescription$ (itemId AS INTEGER)
DECLARE FUNCTION Inventory.Mix%(itemId0 AS INTEGER, itemId1 AS INTEGER, resultMixMsg AS STRING)
DECLARE SUB Inventory.RefreshNames ()
DECLARE SUB Inventory.RemoveItem (item AS InventoryType)
DECLARE FUNCTION Inventory.SidToItemId% (sid AS STRING)
DECLARE FUNCTION Inventory.GetSuccessMsg$ (itemId AS INTEGER)
DECLARE FUNCTION Inventory.GetFailMsg$ (itemId AS INTEGER)

CONST INVENTORYMAXSIZE = 99
CONST InventoryErr.OUTOFBOUNDS = -101
CONST InventoryErr.INVALIDSIZE = -102
CONST InventoryErr.SIZETOOBIG = -103
CONST InventoryErr.NOVACANTSLOT = -104

