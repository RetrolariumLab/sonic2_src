; ---------------------------------------------------------------------------

; zloc_C89
zCoordFlag:
                sub     0E0h
                add     a,a                             ; Multiply by 4, skipping past padding
                add     a,a
                ld      (coordflagLookup+1),a           ; store into the instruction after coordflagLookup (self-modifying code)
                ld      a,(hl)
                inc     hl

; This is the lookup for Coordination flag routines

; zloc_C92
coordflagLookup:
                jr      $
; ---------------------------------------------------------------------------
                jp      cfPanningAMSFMS                 ; E0
                db      0
; ---------------------------------------------------------------------------
                jp      cfDetune                        ; E1
                db      0
; ---------------------------------------------------------------------------
                jp      cfSetCommunication              ; E2
                db      0
; ---------------------------------------------------------------------------
                jp      cfJumpReturn                    ; E3
                db      0
; ---------------------------------------------------------------------------
                jp      cfFadeInToPrevious              ; E4
                db      0
; ---------------------------------------------------------------------------
                jp      cfSetTempoDivider               ; E5
                db      0
; ---------------------------------------------------------------------------
                jp      cfChangeFMVolume                ; E6
                db      0
; ---------------------------------------------------------------------------
                jp      cfPreventAttack                 ; E7
                db      0
; ---------------------------------------------------------------------------
                jp      cfNoteFill                      ; E8
                db      0
; ---------------------------------------------------------------------------
                jp      cfChangeTransposition           ; E9
                db      0
; ---------------------------------------------------------------------------
                jp      cfSetTempo                      ; EA
                db      0
; ---------------------------------------------------------------------------
                jp      cfSetTempoMod                   ; EB
                db      0
; ---------------------------------------------------------------------------
                jp      cfChangePSGVolume               ; EC
                db      0
; ---------------------------------------------------------------------------
                jp      cfClearPush                     ; ED
                db      0
; ---------------------------------------------------------------------------
                jp      cfStopSpecialFM4                ; EE
                db      0
; ---------------------------------------------------------------------------
                jp      cfSetVoice                      ; EF
                db      0
; ---------------------------------------------------------------------------
                jp      cfModulation                    ; F0
                db      0
; ---------------------------------------------------------------------------
                jp      cfEnableModulation              ; F1
                db      0
; ---------------------------------------------------------------------------
                jp      cfStopTrack                     ; F2
                db      0
; ---------------------------------------------------------------------------
                jp      cfSetPSGNoise                   ; F3
                db      0
; ---------------------------------------------------------------------------
                jp      cfDisableModulation             ; F4
                db      0
; ---------------------------------------------------------------------------
                jp      cfSetPSGTone                    ; F5
                db      0
; ---------------------------------------------------------------------------
                jp      cfJumpTo                        ; F6
                db      0
; ---------------------------------------------------------------------------
                jp      cfRepeatAtPos                   ; F7
                db      0
; ---------------------------------------------------------------------------
                jp      cfJumpToGosub                   ; F8
                db      0
; ---------------------------------------------------------------------------
                jp      cfOpF9                          ; F9
                db      0
; ---------------------------------------------------------------------------

; (via Saxman's doc): panning, AMS, FMS
; zloc_CFC
cfPanningAMSFMS:
; Panning, AMS, FMS
    ; * xx - Value (reg a)
    ; o Bit 7 - Left channel status
    ; o Bit 6 - Right channel Status
    ; o Bit 5-3 - AMS
    ; o Bit 2 - 0
    ; o Bit 1-0 - FMS

; Note that the AMS and FMS bits are saved; this command was only meant to
; change the panning of a given channel

                bit     7,(ix+zTrack.VoiceControl)      ; Is this a PSG track?
; The following return check is a leftover from Sonic 1, where it returns if VoiceControl is negative (i.e. 80h or higher)
; A not zero check would make this more consistent with the rest of the sound driver
                ret     m                               ; If so, quit!
; This check is in the wrong place
; If this flag is triggered by a music track while it's being overridden
; by an SFX, it will use the old panning when the SFX ends
; This is because zTrack.AMSFMSPan doesn't get updated
                bit     2,(ix+zTrack.PlaybackControl)   ; If "SFX overriding" bit set
                ret     nz                              ; return
                ld      c,a                             ; input val 'a' -> c
                ld      a,(ix+zTrack.AMSFMSPan)         ; old PAF value
                and     37h                             ; retains AMS and FMS bits
                or      c                               ; OR'd with new settings
                ld      (ix+zTrack.AMSFMSPan),a         ; new PAF value
                ld      c,a                             ; a -> c (YM2612 data write)
                ld      a,(ix+zTrack.VoiceControl)      ; Get voice control byte
                and     3                               ; Channels only!
                add     a,0B4h                          ; Add register B4, stereo output control and LFO sensitivity
                rst     zWriteFMIorII                   ; Depends on bit 2 of (ix+zTrack.VoiceControl)
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): Alter note values by xx
; More or less a pitch bend; this is applied to the frequency as a signed value
; zloc_D1A cfAlterNotesUNK cfAlterNotes
cfDetune:
                ld      (ix+zTrack.Detune),a            ; set new detune value
                ret
; ---------------------------------------------------------------------------

; Set otherwise unused communication byte to parameter
; Used for triggering a boss' attacks in Ristar
; zloc_D1E cfUnknown1
cfSetCommunication:
                ld      (zAbsVar.Communication),a
                ret
; ---------------------------------------------------------------------------

; Return (Sonic 1 & 2)
; zloc_D22
cfJumpReturn:
                ld      c,(ix+zTrack.StackPointer)      ; Get current stack offset -> 'c'
                ld      b,0                             ; b = 0
                push    ix
                pop     hl                              ; hl = ix
                add     hl,bc                           ; hl += bc (latest item on "gosub" stack)
                ld      a,(hl)
                inc     hl
                ld      h,(hl)
                ld      l,a                             ; hl = address from "gosub" stack
                inc     c
                inc     c
                ld      (ix+zTrack.StackPointer),c      ; add 2 to "gosub" stack offset (pop)
                ret
; ---------------------------------------------------------------------------

; Fade-in to previous song (needed on DAC channel, Sonic 1 & 2)
; zloc_D35
cfFadeInToPrevious:
; This performs a "massive" restoration of all of the current
; track positions as they were prior to 1-up BGM
                ld      hl,zTracksSaveStart             ; Backup memory address
                ld      de,zAbsVar                      ; Ends at zComRange
                ld      bc,zTracksSaveEnd-zTracksSaveStart  ; for this many bytes
                ldir                                    ; Go!

                call    zBankSwitchToMusic
                ld      a,(zSongDAC.PlaybackControl)    ; Get DAC's playback bit
                or      4
                ld      (zSongDAC.PlaybackControl),a    ; Set "SFX is overriding" on it (not normal, but will work for this purpose)
                ld      a,(zAbsVar.FadeInCounter)       ; Get current count of many frames to continue bringing volume up
                ld      c,a
                ld      a,28h
                sub     c                               ; a = 28h - c (don't overlap fade-ins?)
                ld      c,a                             ; 'a' -> 'c'
                ld      b,MUSIC_FM_TRACK_COUNT          ; 6 FM tracks to follow
                ld      ix,zSongFMStart                 ; 'ix' points to first FM music track

.fmloop:
                bit     7,(ix+zTrack.PlaybackControl)   ; Is this track playing?
                jr      z,.nextfm                       ; If not, do nothing
                set     1,(ix+zTrack.PlaybackControl)   ; Mark track at rest
                ld      a,(ix+zTrack.Volume)            ; Get channel volume
                add     a,c                             ; Apply current fade value
                ld      (ix+zTrack.Volume),a            ; Store it back
; This bit is always cleared (see zPlayMusic)
                bit     2,(ix+zTrack.PlaybackControl)   ; Is track being overridden by SFX?
                jr      nz,.nextfm                      ; If so, skip next part
                push    bc
                ld      a,(ix+zTrack.VoiceIndex)        ; Get voice
                call    zSetVoiceMusic                  ; Update voice (and set volume)
                pop     bc

.nextfm:
                ld      de,zTrack.len
                add     ix,de                           ; Next track
                djnz    .fmloop                         ; Keep going for all FM tracks

                ld      b,MUSIC_PSG_TRACK_COUNT         ; 3 PSG tracks to follow

.psgloop:
                bit     7,(ix+zTrack.PlaybackControl)   ; Is this track playing?
                jr      z,.nextpsg                      ; If not, do nothing
                set     1,(ix+zTrack.PlaybackControl)   ; Set track at rest
                call    zPSGNoteOff                     ; Shut off PSG
                ld      a,(ix+zTrack.Volume)            ; Get channel volume
                add     a,c                             ; Apply current fade value
                ld      (ix+zTrack.Volume),a            ; Store it back

.nextpsg:
                ld      de,zTrack.len
                add     ix,de                           ; Next track
                djnz    .psgloop                        ; Keep going for all PSG tracks

                ld      a,80h
                ld      (zAbsVar.FadeInFlag),a          ; Stop any SFX during fade-in
                ld      a,28h
                ld      (zAbsVar.FadeInCounter),a       ; Fade in for 28h frames
                xor     a
                ld      (zAbsVar.1upPlaying),a          ; Set to zero; 1-up ain't playin' no more
                ld      a,(zAbsVar.DACEnabled)          ; DAC not yet enabled
                ld      c,a
                ld      a,2Bh
                rst     zWriteFMI                       ; Tell hardware his DAC ain't enabled yet either
                pop     bc
                pop     bc
                pop     bc                              ; These screw with the return address to make sure DAC doesn't run any further
                jp      zUpdateDAC                      ; But we update DAC regardless
; ---------------------------------------------------------------------------

; Change tempo divider to xx
; zloc_DB7
cfSetTempoDivider:
                ld      (ix+zTrack.TempoDivider),a      ; Set tempo divider on this track only
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): Change channel volume BY xx; xx is signed
; zloc_DBB cfSetVolume
cfChangeFMVolume:
                add     a,(ix+zTrack.Volume)            ; Add to current volume
                ld      (ix+zTrack.Volume),a            ; Update volume
                jp      zSetChanVol                     ; Immediately set this new volume
; ---------------------------------------------------------------------------

; (via Saxman's doc): prevent next note from attacking
; zloc_DC4
cfPreventAttack:
                set     4,(ix+zTrack.PlaybackControl)   ; Set bit 4 (10h) on playback control; do not attack next note
                dec     hl                              ; Takes no argument, so just put it back
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): set note fill amount to xx
; zloc_DCA
cfNoteFill:
                ld      (ix+zTrack.NoteFillTimeout),a   ; Note fill value (modifiable)
                ld      (ix+zTrack.NoteFillMaster),a    ; Note fill value (master copy, rewrites +0Fh when necessary)
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): add xx to channel key
; zloc_DD1 cfAddKey
cfChangeTransposition:
                add     a,(ix+zTrack.Transpose)         ; Add to current transpose value
                ld      (ix+zTrack.Transpose),a         ; Store updated transpose value
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): set music tempo to xx
; zloc_DD8
cfSetTempo:
                ld      (zAbsVar.CurrentTempo),a        ; Set tempo
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): Change tempo modifier to xx for ALL channels
; zloc_DDC
cfSetTempoMod:
                push    ix                              ; Save 'ix'
                ld      ix,zTracksSongStart             ; Start at beginning of track memory
                ld      de,zTrack.len                   ; Track size
                ld      b,MUSIC_TRACK_COUNT             ; All 10 tracks

.trackloop:
                ld      (ix+zTrack.TempoDivider),a      ; Sets the timing divisor for ALL tracks; this can result in total half-speed, quarter-speed, etc
                add     ix,de
                djnz    .trackloop

                pop     ix                              ; Restore 'ix'
                ret
; ---------------------------------------------------------------------------
; This controls which TL registers are set for a particular
; algorithm; it actually makes more sense to look at a zVolTLMaskTbl entry as a bitfield
; Bit 0-4 set which TL operators are actually effected for setting a volume;
; this table helps implement the following from the Sega Tech reference:
; "To make a note softer, only change the TL of the slots (the output operators)
; Changing the other operators will affect the flavor of the note."
; zloc_DF1
                ensure1byteoffset 8
zVolTLMaskTbl:
                db      8,  8,  8,  8
                db      0Ch,0Eh,0Eh,0Fh
; ---------------------------------------------------------------------------

; Alters a channel's volume by xx. This is only meant to be used by PSG channels
; zloc_DF9 cfChangeVolume
cfChangePSGVolume:
                add     a,(ix+zTrack.Volume)            ; Add to channel volume
                ld      (ix+zTrack.Volume),a            ; Store updated volume
                ret
; ---------------------------------------------------------------------------

; Unused command EDh
; This used to be Sonic 1's cfClearPush. The whole Push SFX feature
; was retained when the driver was ported to Z80, but eventually removed in Beta 5
; This broken code is all that's left of it
; zlocret_E00 cfUnused cfUnused1
cfClearPush:
; Dangerous!  It doesn't put back the byte read, meaning one gets skipped!
                ret
; ---------------------------------------------------------------------------

; Unused command EEh
; This used to be Sonic 1's cfStopSpecialFM4. But the Special SFX function hasn't been ported
; zloc_E01 cfVoiceUNK cfUnused2
cfStopSpecialFM4:
                dec     hl                              ; Put back byte; does nothing
                ret
