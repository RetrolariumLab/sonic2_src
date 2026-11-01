; Sonic the Hedgehog 2 disassembled Z80 sound driver

; Disassembled by Xenowhirl for AS
; Additional disassembly work by RAS Oct 2008
; RAS' work merged into SVN by Flamewing
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; NOTES:
;
; Set your editor's tab width to 8 characters wide for viewing this file
;
; This code is compressed in the ROM, but you can edit it here as uncompressed
; and it will automatically be assembled and compressed into the correct place
; during the build process
;
; This Z80 code can use labels and equates defined in the 68k code,
; and the 68k code can use the labels and equates defined in here
; This is fortunate, as they contain references to each other's addresses
;
; If you want to add significant amounts of extra code to this driver,
; try putting your code as far down as possible, after the function zDecEnd
; That will make you less likely to run into space shortages from dislocated data alignment
;
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Setup defines and macros

; zComRange: @ 1B80h
; +00h -- Priority of current SFX (cleared when 1-up song is playing)
; +01h -- tempo clock
; +02h -- current tempo
; +03h -- Pause/unpause flag: 7Fh for pause; 80h for unpause (set from 68K)
; +04h -- total volume levels to continue decreasing volume before fade out considered complete (starts at 28h, works downward)
; +05h -- delay ticker before next volume decrease
; +06h -- communication value
; +07h -- "DAC is updating" flag (set to FFh until completion of DAC track change)
; +08h -- When NOT set to 80h, 68K request new sound index to play
; +09h -- SFX to Play queue slot
; +0Ah -- Play stereo sound queue slot
; +0Bh -- Unknown SFX Queue slot
; +0Ch -- Address to table of voices
;
; +0Eh -- Set to 80h while fading in (disabling SFX) then 00h
; +0Fh -- Same idea as +05h, except for fade IN
; +10h -- Same idea as +04h, except for fade IN
; +11h -- 80h set indicating 1-up song is playing (stops other sounds)
; +12h -- main tempo value
; +13h -- original tempo for speed shoe restore
; +14h -- Speed shoes flag
; +15h -- If 80h, FM Channel 6 is NOT in use (DAC enabled)
; +16h -- value of which music bank to use (0 for MusicPoint1, $80 for MusicPoint2)
; +17h -- Pal mode flag
;
; ** zTracksSongStart starts @ +18h
;
; 1B98 base
; Track 1 = DAC
; Then 6 FM
; Then 3 PSG
;
;
; 1B98 = DAC
; 1BC2 = FM 1
; 1BEC = FM 2
; 1C16 = FM 3
; 1C40 = FM 4
; 1C6A = FM 5
; 1C94 = FM 6
; 1CBE = PSG 1
; 1CE8 = PSG 2
; 1D12 = PSG 3 (tone or noise)
;
; 1D3C = SFX FM 3
; 1D66 = SFX FM 4
; 1D90 = SFX FM 5
; 1DBA = SFX PSG 1
; 1DE4 = SFX PSG 2
; 1E0E = SFX PSG 3 (tone or noise)
;
;
zTrack          STRUCT  DOTS
; "playback control"; bits:
; 1 (02h): track is at rest
; 2 (04h): SFX is overriding this track
; 3 (08h): modulation on
; 4 (10h): do not attack next note
; 7 (80h): track is playing
PlaybackControl:    ds.b    1
; "voice control"; bits:
; 2 (04h): If set, bound for part II, otherwise 0 (see zWriteFMIorII)
; -- bit 2 has to do with sending key on/off, which uses this differentiation bit directly
; 7 (80h): PSG track
VoiceControl:       ds.b    1
TempoDivider:       ds.b    1                           ; Timing divisor; 1 = Normal, 2 = Half, 3 = Third
DataPointerLow:     ds.b    1                           ; Track's position low byte
DataPointerHigh:    ds.b    1                           ; Track's position high byte
Transpose:          ds.b    1                           ; Transpose (from coord flag E9)
Volume:             ds.b    1                           ; Channel volume (only applied at voice changes)
AMSFMSPan:          ds.b    1                           ; Panning / AMS / FMS settings
VoiceIndex:         ds.b    1                           ; Current voice in use OR current PSG tone
VolFlutter:         ds.b    1                           ; PSG flutter (dynamically affects PSG volume for decay effects)
StackPointer:       ds.b    1                           ; "Gosub" stack position offset (starts at 2Ah, i.e. end of track, and each jump decrements by 2)
DurationTimeout:    ds.b    1                           ; Current duration timeout; counting down to zero
SavedDuration:      ds.b    1                           ; Last set duration (if a note follows a note, this is reapplied to 0Bh)
;
; ; 0Dh / 0Eh change a little depending on track -- essentially they hold data relevant to the next note to play
SavedDAC:                                               ; DAC: Next drum to play
FreqLow:            ds.b    1                           ; FM/PSG: frequency low byte
FreqHigh:           ds.b    1                           ; FM/PSG: frequency high byte
NoteFillTimeout:    ds.b    1                           ; Currently set note fill; counts down to zero and then cuts off note
NoteFillMaster:     ds.b    1                           ; Reset value for current note fill
ModulationPtrLow:   ds.b    1                           ; Low byte of address of current modulation setting
ModulationPtrHigh:  ds.b    1                           ; High byte of address of current modulation setting
ModulationWait:     ds.b    1                           ; Wait for ww period of time before modulation starts
ModulationSpeed:    ds.b    1                           ; Modulation speed
ModulationDelta:    ds.b    1                           ; Modulation change per mod. Step
ModulationSteps:    ds.b    1                           ; Number of steps in modulation (divided by 2)
ModulationValLow:   ds.b    1                           ; Current modulation value low byte
ModulationValHigh:  ds.b    1                           ; Current modulation value high byte
Detune:             ds.b    1                           ; Set by detune coord flag E1; used to add directly to FM/PSG frequency
VolTLMask:          ds.b    1                           ; zVolTLMaskTbl value set during voice setting (value based on algorithm indexing zGain table)
PSGNoise:           ds.b    1                           ; PSG noise setting
VoicePtrLow:        ds.b    1                           ; Low byte of custom voice table (for SFX)
VoicePtrHigh:       ds.b    1                           ; High byte of custom voice table (for SFX)
TLPtrLow:           ds.b    1                           ; Low byte of where TL bytes of current voice begin (set during voice setting)
TLPtrHigh:          ds.b    1                           ; High byte of where TL bytes of current voice begin (set during voice setting)
LoopCounters:       ds.b    $A                          ; Loop counter index 0
; ... open
GoSubStack:                                             ; start of next track, every two bytes below this is a coord flag "gosub" (F8h) return stack
;
; The bytes between +20h and +29h are "open"; starting at +20h and going up are possible loop counters
; (for coord flag F7) while +2Ah going down (never AT 2Ah though) are stacked return addresses going
; down after calling coord flag F8h.  Of course, this does mean collisions are possible with either
; or other track memory if you're not careful with these!  No range checking is performed!
;
; All tracks are 2Ah bytes long
zTrack          ENDSTRUCT

zVar                STRUCT  DOTS
SFXPriorityVal:     ds.b    1
TempoTimeout:       ds.b    1
CurrentTempo:       ds.b    1                           ; Stores current tempo value here
StopMusic:          ds.b    1                           ; Set to 7Fh to pause music, set to 80h to unpause. Otherwise 00h
FadeOutCounter:     ds.b    1
FadeOutDelay:       ds.b    1
Communication:      ds.b    1                           ; Unused byte used to synchronise gameplay events with music
DACUpdating:        ds.b    1                           ; Set to FFh while DAC is updating, then back to 00h
QueueToPlay:        ds.b    1                           ; The head of the queue
Queue0:             ds.b    1
Queue1:             ds.b    1
Queue2:             ds.b    1                           ; This slot was totally broken in Sonic 1's driver. It's mostly fixed here, but it's still a little broken (see 'zInitMusicPlayback')
VoiceTblPtr:        ds.b    2                           ; Address of the voices
FadeInFlag:         ds.b    1
FadeInDelay:        ds.b    1
FadeInCounter:      ds.b    1
1upPlaying:         ds.b    1
TempoMod:           ds.b    1
TempoTurbo:         ds.b    1                           ; Stores the tempo if speed shoes are acquired (or 7Bh is played otherwise)
SpeedUpFlag:        ds.b    1
DACEnabled:         ds.b    1
MusicBankNumber:    ds.b    1
IsPalFlag:          ds.b    1                           ; Flags if the system is a PAL console
zVar                ENDSTRUCT

; equates: standard (for Genesis games) addresses in the memory map
zYM2612_A0      =       $4000
zYM2612_D0      =       $4001
zYM2612_A1      =       $4002
zYM2612_D1      =       $4003
zBankRegister   =       $6000
zPSG            =       $7F11
zROMWindow      =       $8000
; More equates: addresses specific to this program (besides labelled addresses)
zMusicData      =       $1380                           ; don't change this unless you change all the pointers in the BINCLUDE'd music too
zStack          =       zMusicData+$800                 ; 1B80h

                phase   zStack
zAbsVar:        zVar

zTracksSongStart:                                       ; This is the beginning of all BGM track memory
zSongDACFMStart:
zSongDAC:       zTrack
zSongFMStart:
zSongFM1:       zTrack
zSongFM2:       zTrack
zSongFM3:       zTrack
zSongFM4:       zTrack
zSongFM5:       zTrack
zSongFM6:       zTrack
zSongFMEnd:
zSongDACFMEnd:
zSongPSGStart:
zSongPSG1:      zTrack
zSongPSG2:      zTrack
zSongPSG3:      zTrack
zSongPSGEnd:
zTracksSongEnd:

zTracksSFXStart:
zSFX_FMStart:
zSFX_FM3:       zTrack
zSFX_FM4:       zTrack
zSFX_FM5:       zTrack
zSFX_FMEnd:
zSFX_PSGStart:
zSFX_PSG1:      zTrack
zSFX_PSG2:      zTrack
zSFX_PSG3:      zTrack
zSFX_PSGEnd:
zTracksSFXEnd:

zTracksSaveStart:                                       ; When extra life plays, it backs up a large amount of memory (all track data plus 36 bytes)
zSaveVar:       zVar
zSaveSongDAC:   zTrack
zSaveSongFM1:   zTrack
zSaveSongFM2:   zTrack
zSaveSongFM3:   zTrack
zSaveSongFM4:   zTrack
zSaveSongFM5:   zTrack
zSaveSongFM6:   zTrack
zSaveSongPSG1:  zTrack
zSaveSongPSG2:  zTrack
zSaveSongPSG3:  zTrack
zTracksSaveEnd:
; See the very end for another set of variables

                if      *>$2000
                fatal   "Z80 variables are \{*-$2000}h bytes past the end of Z80 RAM!"
                endif
                dephase

MUSIC_TRACK_COUNT           =       (zTracksSongEnd-zTracksSongStart)/zTrack.len
MUSIC_DAC_FM_TRACK_COUNT    =       (zSongDACFMEnd-zSongDACFMStart)/zTrack.len
MUSIC_FM_TRACK_COUNT        =       (zSongFMEnd-zSongFMStart)/zTrack.len
MUSIC_PSG_TRACK_COUNT       =       (zSongPSGEnd-zSongPSGStart)/zTrack.len

SFX_TRACK_COUNT         =       (zTracksSFXEnd-zTracksSFXStart)/zTrack.len
SFX_FM_TRACK_COUNT      =       (zSFX_FMEnd-zSFX_FMStart)/zTrack.len
SFX_PSG_TRACK_COUNT     =       (zSFX_PSGEnd-zSFX_PSGStart)/zTrack.len

    ; In what I believe is an unfortunate design choice in AS,
    ; both the phased and unphased PCs must be within the target processor's range,
    ; which means phase is useless here despite being designed to fix this problem
    ; oh well, I set it up to fix this later when processing the .p file
                !org    0                               ; Z80 code starting at address 0 has special meaning to s2p2bin.exe

                CPU     Z80UNDOC
                listing purecode

; Macro to perform a bank switch... after using this,
; the start of zROMWindow points to the start of the given 68k address,
; rounded down to the nearest $8000 byte boundary
bankswitch      macro   addr68k
                        xor     a                       ; a = 0
                        ld      e,1                     ; e = 1
                        ld      hl,zBankRegister
.cnt            :=      0
                        rept    9
; this is either ld (hl),a or ld (hl),e
                        db      73h|((((addr68k)&(1<<(15+.cnt)))=0)<<2)
.cnt            :=      .cnt+1
                    endm
                endm

; macro to make a certain error message clearer should you happen to get it
rsttarget       macro   {INTLABEL}
                        if      ($&7)||($>38h)
                        fatal   "Function __LABEL__ is at 0\{$}h, but must be at a multiple of 8 bytes <= 38h to be used with the rst instruction."
                        endif
                        if      "__LABEL__"<>""
__LABEL__       label   $
                        endif
                    endm

; function to decide whether an offset's full range won't fit in one byte
offsetover1byte     function from,maxsize, ((from&0FFh)>(100h-maxsize))

; macro to make sure that ($ & 0FF00h) == (($+maxsize) & 0FF00h)
ensure1byteoffset   macro   maxsize
                            if      offsetover1byte($,maxsize)
startpad        :=      $
                            align   100h
                            if      MOMPASS=1
endpad          :=      $
                            if      endpad-startpad>=1h
    ; warn because otherwise you'd have no clue why you're running out of space so fast
                            warning "had to insert \{endpad-startpad}h   bytes of padding before improperly located data at 0\{startpad}h in Z80 code"
                            endif
                            endif
                            endif
                        endm

; Function to turn a 68k address into a word the Z80 can use to access it,
; assuming the correct bank has been switched to first
zmake68kPtr     function addr,zROMWindow+(addr&7FFFh)

; Function to turn a sample rate into a djnz loop counter
pcmLoopCounterBase  function sampleRate,baseCycles, 1+(Z80_Clock/(sampleRate)-(baseCycles)+(13/2))/13
pcmLoopCounter      function sampleRate, pcmLoopCounterBase(sampleRate,152/2)  ; 152 is the number of cycles zPlaySegaSound takes to deliver two samples
dpcmLoopCounter     function sampleRate, pcmLoopCounterBase(sampleRate,295/2)  ; 295 is the number of cycles zWriteToDAC takes to deliver two samples
