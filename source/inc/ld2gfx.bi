DECLARE SUB LD2put (x AS INTEGER, y AS INTEGER, SpriteSeg AS INTEGER, SpritePtr AS INTEGER, bufferSeg AS INTEGER, flip AS INTEGER)
DECLARE SUB LD2putf (x AS INTEGER, y AS INTEGER, SpriteSeg AS INTEGER, SpritePtr AS INTEGER, bufferSeg AS INTEGER)
DECLARE SUB LD2putl (x AS INTEGER, y AS INTEGER, SpriteSeg AS INTEGER, SpritePtr AS INTEGER, bufferSeg AS INTEGER)
DECLARE SUB LD2putwl (x AS INTEGER, y AS INTEGER, SpriteSeg AS INTEGER, SpritePtr AS INTEGER, LightSeg AS INTEGER, LightPtr AS INTEGER, TempPtr AS INTEGER, bufferSeg AS INTEGER)
DECLARE SUB LD2mixwl (SpriteSeg AS INTEGER, SpritePtr AS INTEGER, LightSeg AS INTEGER, LightPtr AS INTEGER, TempPtr AS INTEGER)
DECLARE SUB LD2copySprite (SrcSeg AS INTEGER, SrcPtr AS INTEGER, DestSeg AS INTEGER, DestPtr AS INTEGER)
DECLARE SUB LD2copyFull (Buffer1 AS INTEGER, Buffer2 AS INTEGER)
DECLARE SUB LD2cls (bufferSeg AS INTEGER, col AS INTEGER)
DECLARE SUB LD2put65 (x AS INTEGER, y AS INTEGER, SpriteSeg AS INTEGER, SpritePtr AS INTEGER, bufferSeg AS INTEGER)
DECLARE SUB LD2put65c (x AS INTEGER, y AS INTEGER, SpriteSeg AS INTEGER, SpritePtr AS INTEGER, bufferSeg AS INTEGER)
DECLARE SUB LD2putCol65 (x AS INTEGER, y AS INTEGER, SpriteSeg AS INTEGER, SpritePtr AS INTEGER, col AS INTEGER, bufferSeg AS INTEGER)
DECLARE SUB LD2putCol65c (x AS INTEGER, y AS INTEGER, SpriteSeg AS INTEGER, SpritePtr AS INTEGER, col AS INTEGER, bufferSeg AS INTEGER)
DECLARE SUB LD2pset (x AS INTEGER, y AS INTEGER, bufferSeg AS INTEGER, col AS INTEGER)
DECLARE SUB LD2fill (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, bufferSeg AS INTEGER)

