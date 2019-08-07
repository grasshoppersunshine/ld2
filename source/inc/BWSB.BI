'ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
'                     Bells, Whistles, and Sound Boards
'                  Copyright (c) 1993-97, Edward Schlunder.
'                 See COPYING.ES for redistribution details.
'ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
' BWSB.BI - Bells, Whistles, and Sound Boards library declaration file
'           for QuickBASIC, PDS, and VB/DOS.
'
'           Written by Edward Schlunder (1993-95)
'ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
DECLARE FUNCTION LoadMSE% (MSE$, FileOff&, OvrRate%, BufSize%, Addr%, IRQ%, DMA%)
DECLARE FUNCTION DeviceName$ ()
DECLARE SUB FreeMSE ()
DECLARE FUNCTION StartOutput& (Channels%, Amplify%)
DECLARE SUB StopOutput ()
DECLARE SUB StopBanner ()

DECLARE SUB MixForground ()
DECLARE FUNCTION MixStatus% ()
DECLARE SUB SetAutoMix (MixTime%)

'Music Routines:
DECLARE SUB StartMusic ()                  'Enables music processing
DECLARE SUB StopMusic ()                   'Disables music processing
DECLARE SUB AmigaHertz (Hertz&)            'Amiga Period Hertz clock
DECLARE FUNCTION MusicStatus% ()           'Current music enable/disable status
DECLARE FUNCTION MusicBPM% (BPM%)
DECLARE FUNCTION MusicTempo% (Tempo%)
DECLARE FUNCTION MusicOrder% (Order%)
DECLARE FUNCTION MusicPattern% (Pattern%)
DECLARE FUNCTION MusicRow% ()
DECLARE FUNCTION MusicLoop% (LoopStatus%)
DECLARE FUNCTION MusicVolume% (GlobalVol%)

DECLARE SUB GetChannelTable (Channel%, TableSeg%, TableOff%)
DECLARE FUNCTION ChannelPan% (Channel%, Pan%)
DECLARE FUNCTION ChannelVU% (Channel%, VU%)
DECLARE FUNCTION ChannelVol% (Channel%, Vol%)
DECLARE FUNCTION ChannelPos& (Channel%, NewPos&)
DECLARE SUB PlaySample (Channel%, Sample%, Rate&, Vol%, Pan%)
DECLARE SUB PlayNote (Channel%, Sample%, Octave%, Note%)
DECLARE SUB GetSampleTable (Sample%, TableSeg%, TableOff%)
DECLARE SUB GetMainScope (LeftScope&, RightScope&)

DECLARE SUB LoadGDM (Hand%, FileOff AS LONG, LoadFlags%, GDMSeg%, GDMOff%)
DECLARE SUB UnloadModule ()

'Internal BWSB Routines:
DECLARE SUB RegisterSample (SampleNum%, SampleSeg%, SampleOff%)
DECLARE SUB RegisterPatterns (PatSeg%, PatOff%)     'Sets up MSE pattern segment table
DECLARE SUB RegisterOrders (OrdSeg%, OrdOff%, NOO%) 'Sets up MSE order table

'Expanded Memory functions
DECLARE FUNCTION EmsExist% ()
DECLARE FUNCTION EmsStatus% ()
DECLARE FUNCTION EmsFrameSegment% ()
DECLARE FUNCTION EmsPagesTotal% ()
DECLARE FUNCTION EmsPagesFree% ()
DECLARE FUNCTION EmsAlloc% (Pages%)
DECLARE SUB EmsMapPage (PhyPage%, LogPage&, Handle%)
DECLARE SUB EmsDealloc (Handle%)

