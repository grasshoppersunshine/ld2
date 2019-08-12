

ROOMS:
'=
'=   ID  FILENAME    ROOM NAME
DATA 23, "23th.ld2", "Rooftop"             '23 'yellow or code
DATA 22, "22th.ld2", "Sky Room"            '22
DATA 21, "21th.ld2", "Unknown"             '21 'red
DATA 20, "20th.ld2", "Unknown"             '20 'get 1/2 white card here from steve
DATA 19, "19th.ld2", "Research Laboratory" '19 'blue
DATA 18, "18th.ld2", "Debriefing Room"     '18
DATA 17, "17th.ld2", "Office"              '17 'window room
DATA 16, "16th.ld2", "Office"              '16 'tv room '1/2 white card behind yellow door (yellow door in middle of room)
DATA 15, "15th.ld2", "Office"              '15 'maybe make some green doors yellow?
DATA 14, "14th.ld2", "Larry's Office"      '14 'larry's office
DATA 13, "13th.ld2", "Storage Room"        '13 'mystery meat
DATA 12, "12th.ld2", "Ventilation Control" '12 'janitor's note / rooftop code
DATA 11, "11th.ld2", "Office"              '11 'window room / white door with red card in back
DATA 10, "10th.ld2", "Office"              '10 'barney's office
DATA  9,  "9th.ld2", "Office"              '09 'dark room
DATA  8,  "8th.ld2", "Office"              '08 'data entry
DATA  7,  "7th.ld2", "Weapon's Locker"     '07 'blue
DATA  6,  "6th.ld2", "Storage Room"        '06
DATA  5,  "5th.ld2", "Meeting Room"        '05
DATA  4,  "4th.ld2", "Recreation Room"     '04 'pool table here
DATA  3,  "3th.ld2", "Lunch Room"          '03 'chemical 409
DATA  2,  "2th.ld2", "Restrooms"           '02
DATA  1,  "1th.ld2", "Lobby"               '01 'red
DATA  0, " 0th.ld2", "Basement"            '00 'yellow 'flashlight

' other room ides
'----------------------
' SHOWERS
' LIBRARY
' LADY RESTROOMS / SHOWERS
' CONSERVATORY
' STAFF LOUNGE
' SAVE ROOM
' SECURITY ROOM
' LOCKER ROOM
' BACKYARD
' LOADING BAY
' SWIMMING POOL (building after crossing back yard)
' BREAK ROOM
' CREEPY EXECUTIVE OFFICE / TROPHY ROOM / PAINTINGS HALLWAY

' weapon ideas
'----------------------
' hand grenade
' grenade launcher
' c4/remote explosive
' molotov cocktail type thing
' homebrew type stuff / improvise
' upgrade current weapons by mixing modifiers
' convert leaf blower to flame thrower
' hair spray with lighter
' make gun powder from lab
' throw glass vials of acid

' puzzle ideas
'----------------------
' jump on rockmonster heads for access to higher ground
' get lighter to burn down large picture with secret behind painting
' jump up in plenum or down below and crawl/roll in ventilation
' roll underneath hanging, exposes electrical cords
' turn power off to section of building to disable hazard (exposed electrical cords in water, etc)
' power goes out in building, restore power
' stairs access to other side of rooms
' push blocks onto pressure plates, or to reveal something underneath, or to jump on to get to a high place
' put metal spoon in microwave; microwave blows up and starts fire; water sprayers come down and put fire out
' leaf blower; blow leaves to reveal item underneath; use leaf blower to reveal carpets that can be removed (corner flaps with wind)
' "The toilet water is gross, but there seems to be someting lodged in it. I'm not sticking my hands in there though" get vinyl gloves, reach hand in toilet
' security room - find tape, review security footage that reveals something
' drop acid on floor to access secret room on lower level
' breakable tiles (crates, fish tanks, break-in-case-of-fire, etc) to get items
' need grenades or explosives to break some tiles (boulders, safes, statues, etc)
' large trees grow several floors high - break window or something and jump on tree

' monster ideas
'----------------------
' something that crawls on ceiling and then pounces down
' rock monsters jump and use tounge

' other ideas
'----------------------
' tiles/areas have descriptions
' "The Cola dispenser. Probably best not to drink anything from this after what just happened"
' "This room is really dark. Is it because the power went out?"
' "Nothing interesting here."
' "Filing cabinet. Nothing interesting."

' environment
'----------------------
' storm outside
' quite and creeky; once window breaks you hear the treacherous winds
' items are larger, shiny, or sparkle, something; or they/some are hidden inside objects (like filing cabinets, etc)
' footstep sounds when running
' each room has its own feel and music (or several music tracks shared amongst all the rooms)
'   maybe shift the palette more to red/blue/green/yellow based on room (maybe call algorithm and pass room number?)
' different enemy profile per room (some have rockmonsters with troops; some only have troops; etc)
' spawn points for enemies (or enemies spawn off screen -- so you never have a room 100% cleared -- always a chance something might come after you)
' enemies spawn out of vents; teleport in; spawn off screen; crash through windows; etc

' item ideas
'----------------------
' LARGE CHEST in one room to store items
' BACKPACK to carry more items with you

ITEMS:
'=
'=   ID               NAME                        DESCRIPTION (LOOK)
DATA NOTHING        , "Nothing"                 , "An extra space to store an item."
DATA MEDIKIT50      , "Medikit +50"             , "Restores 50 health."
DATA MEDIKIT100     , "Medikit +100"            , "Restores 100 health."
DATA SHOTGUN        , "Shotgun"                 , "The good ol' shotgun.||Fire-Power: 3||Firing-Rate: Slow"
DATA MACHINEGUN     , "Machine-Gun"             , "Weak, but fires very fast.||Fire-Power: 2||Firing-Rate: Fast" '// make firing rate 1?
DATA PISTOL         , "Pistol"                  , "Weak, but still good for shooting at things.||Fire-Power: 1||Firing-Rate: Medium"
DATA DESERTEAGLE    , "Desert Eagle"            , "This pistol packs a punch.||Fire-Power: 5|| Firing-Rate: Slow" '// double-check firing rate?
DATA GRENADE        , "Grenade"                 , "An explosive device."
DATA SHELLS         , "Shells"                  , "Shotgun ammo.||Amount: 20" '"Shotgun shells. Ammo for a shotgun."
DATA BULLETS        , "Bullets"                 , "Bullets. Useful for many guns.||Amount: 50%||Can be used with: Pistol, Machine-Gun."
DATA DEAGLEAMMO     , "Desert Eagle Ammo"       , "Ammo for the desert eagle.||Amount: 12"
DATA MYSTERYMEAT    , "Mystery Meat"            , "White processed mystery meat.||Processed meat usually has certain mysterious||chemicals in it that try to simulate the taste of||meat, which fail to succeed."
DATA CHEMICAL409    , "Chemical 409"            , "A strong kitchen cleaner.||The warning label says to keep this away from processed foods.||Seems ironic for a *kitchen* cleaner."
DATA CHEMICAL410    , "Chemical 410"            , "A strong acidic chemical with a PH value of 0.0||I didn't even know such number existed in the PH||scale. This can probably eat away anything."
DATA JANITORNOTE    , "Janitor Note"            , "Notice to all maintenance personell.||"
DATA                                              "Since we Janitors don't have yellow cards,||but still require access to the rooftop for maintenance, the staff setup||"
DATA                                              "a console at the door and assigned us a 4-digit number we can type in for access. It is ####."
DATA BATTERIES      , "Batteries"               , "Looks like they are in good condition."
DATA FLASHLIGHTNOBAT, "Flashlight"              , "This should brighten up a dark area pretty well...||but is has no batteries."
DATA FLASHLIGHT     , "Flashlight"              , "This should brighten up a dark area pretty well."
DATA GREENCARD      , "Code-Green Access Card" , "Allows access to doors with green trims.||It's not much, but it gets you around."
DATA BLUECARD       , "Code-Blue Access Card"  , "Allows access to doors with blue and green trims."
DATA YELLOWCARD     , "Code-Yellow Access Card", "Allows access to doors with yellow, blue, and||green trims."
DATA REDCARD        , "Code-Red Access Card"   , "Allows access to doors with red, yellow, blue,||and green trims. That's pretty much every door in||the building."
DATA WHITECARD      , "White Card"             , "Allows access only to doors with white trims."
DATA WHITECARD1     , "White Card (Left-Half)" , "This would allow access to white doors, but||it's broken in half."
DATA WHITECARD2     , "White Card (Right-Half)", "This would allow access to white doors, but||it's broken in half."
DATA EXTRALIFE      , "Extra Life"             , "Gives me an extra life if I use it."


'DATA "Checmial 409", "A strong, all-purpose, cleaner. I have no use for this.||||The warning label states to keep this away from processed foods."
'DATA "1/2 White Card 1", "Would allow access to doors with white trims||if I had the other piece."
'DATA "1/2 White Card 1", ""
'//"A useless chemical as of now, but if it is mixed||with some other chemical, it can form a strong acid.||The instructions which specify which chemical to mix||
'//it with are faded and work out; however, there is a||warning that isn't faded out which says to keep||processed foods a safe distance from it."
'//"Notice to all maintenance personell.||Even though it's not inside the building, the||rooftop still needs maintenane every week.||Since we Janitor's don't have
'//code-yellow access,||but still need access to the rooftop, they gave||us a 4-digit passcode for access. It is ####."


MIXES:
'=   MIX ID 1         MIX ID 2     RESULT ID   SUCCESS MSG
DATA MYSTERYMEAT    , CHEMICAL409, CHEMICAL10, "Mixed two items: Now have CHEMICAL 410"
DATA FLASHLIGHTNOBAT, BATTERIES  , FLASHLIGHT, "Mixed two items: Now have WORKING FLASHLIGHT"
DATA WHITECARD1     , WHITECARD2 , WHITECARD , "Mixed two items: Now have WHITE CARD"

MIXFAILMSG:
DATA "I cannot mix these two items"

INVENTORYOPTIONS:
DATA "  USE     LOOK    MIX     DROP"

USES:
'//  ID          SUCCESS MSG                 FAIL MSG
'=======================================================================
DATA NOTHING   , ""                        , "I can't use nothing"
DATA MEDIKIT50 , "Used Medikit +50"        , ""
DATA MEDIKIT100, "Used Medikit +100"       , ""
DATA GRENADE   , ""                        , ""
DATA SHELLS    , "Loaded Shells"           , "Don't have SHOTGUN"
DATA BULLETS   , "Loaded bullets"          , "Don't have PISTOL or MACHINE-GUN"
DATA DEAGLEAMMO, "Loaded Desert Eagle Ammo", "Don't have DESERT EAGLE"
DATA "I can't use this"
DATA GREENCARD , ""                        ,"It is used automatically when near a door."
DATA BLUECARD  , ""                        ,"It is used automatically when near a door."
DATA YELLOWCARD, ""                        ,"It is used automatically when near a door."
DATA REDCARD   , ""                        ,"It is used automatically when near a door."
DATA WHITECARD , ""                        ,"It is used automatically when near a door."
DATA "I cannot use this."
DATA "It has no batteries."
DATA "Used Flashlight."
DATA "Clunk!!"
DATA "I should get closer to the dark."
DATA "I should save the batteries and only use this in dark areas."
DATA "SHOTGUN is equipped."
DATA "MACHINE-GUN is equipped."
DATA "PISTOL is equipped."
DATA "DESERT EAGLE is equipeed."
DATA "Used Chemical 410"
DATA "I need to get closer to the goo"
DATA "I can't used this here"
DATA "Used Extra Life"
