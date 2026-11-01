; ---------------------------------------------------------------------------

; (via Saxman's doc): set voice selection to xx
; zloc_E03
cfSetVoice:
                ld      (ix+zTrack.VoiceIndex),a        ; Set current voice
                ld      c,a                             ; a -> c (saving for later, if we go to cfSetVoiceCont)
                bit     2,(ix+zTrack.PlaybackControl)   ; If "SFX is overriding this track" bit set
                ret     nz                              ; ...return!
                push    hl                              ; Save 'hl'
                call    cfSetVoiceCont                  ; Set the new voice!
                pop     hl                              ; Restore 'hl'
                ret

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_E12
cfSetVoiceCont:
                ld      a,(zDoSFXFlag)                  ; Check SFX flag 0 = updating music, anything else means updating SFX (use custom voice table)
                or      a                               ; Test
                ld      a,c                             ; c -> a (restored 'a')
                jr      z,zSetVoiceMusic                ; If not busy, jump to zSetVoiceMusic (set 'hl' to VoiceTblPtr)
                ld      l,(ix+zTrack.VoicePtrLow)       ; Get low byte of custom voice table
                ld      h,(ix+zTrack.VoicePtrHigh)      ; Get high byte of custom voice table
                jr      zSetVoice                       ; Do not set 'hl' to VoiceTblPtr
; End of function cfSetVoiceCont

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_E21
zSetVoiceMusic:
; Set 'hl' to normal voice table pointer
                ld      hl,(zAbsVar.VoiceTblPtr)

; zloc_E24
zSetVoice:
; This does the actual setting of the FM registers for the specific voice
; 'a' is the voice index to set
; 'hl' is set to the address of the voice table pointer (can be substituted, probably mainly for SFX)

                push    hl                              ; push 'hl' for the end of the following block

; The following is a crazy block designed to 'multiply' our target voice value by 25
; Where a single voice is 25 bytes long
                ld      c,a                             ; a -> c
                ld      b,0                             ; b = 0 (so only low byte of 'bc' is set, basically voice to set)
                add     a,a                             ; a *= 2 (indexing something...)
                ld      l,a                             ; low byte of 'hl' set to 'a'
                ld      h,b                             ; high byte = 0
                add     hl,hl                           ; hl *= 2
                add     hl,hl                           ; hl *= 2 (total hl * 4!!)
                ld      e,l
                ld      d,h                             ; de = hl
                add     hl,hl                           ; hl *= 2
                add     hl,de                           ; hl += de
                add     hl,bc                           ; hl += bc (waaah!)
                pop     de                              ; old 'hl' value -> 'de'
                add     hl,de                           ; hl += de (Adds address from the very beginning)
; End crazy multiply-by-25 block

; Sets up a value for future total level setting
                ld      a,(hl)                          ; Get feedback/algorithm -> a
                inc     hl                              ; Next byte of voice
                ld      (.a_backup+1),a                 ; Self-modified code: basically enables 'a' restored to its current value later
                ld      c,a                             ; a -> c (will be data to YM2612)
                ld      a,(ix+zTrack.VoiceControl)      ; Get "voice control" byte
                and     3                               ; Only keep bits 0-2 (bit 2 specifies which chip to write to)
                add     a,0B0h                          ; Add to get appropriate feedback/algorithm register
                rst     zWriteFMIorII                   ; Write new value to appropriate part

; detune/coarse freq, all channels
                sub     80h                             ; Subtract 80h from 'a' (Detune/coarse frequency of operator 1 register)
                ld      b,4                             ; Do next 4 bytes (operator 1, 2, 3, and 4)

.detuneloop:
                ld      c,(hl)                          ; Get next detune/coarse freq
                inc     hl                              ; Next voice byte
                rst     zWriteFMIorII                   ; Write this detune/coarse freq
                add     a,4                             ; Next detune/coarse freq register
                djnz    .detuneloop

                push    af                              ; Saving 'a' for much later... will be restored when time to "Total Level"

; other regs up to just before "total level", all channels
                add     a,10h                           ; We're at 40h+, now at 50h+ (RS/AR of operator 1 register)
                ld      b,10h                           ; Perform 16 writes (basically goes through RS/AR, AM/D1R, D2R, D1L)

.registerloop:
                ld      c,(hl)                          ; Get next reg data value
                inc     hl                              ; Next voice byte
                rst     zWriteFMIorII                   ; Write to FM
                add     a,4                             ; Next register
                djnz    .registerloop

; Now going to set "stereo output control and LFO sensitivity"
                add     a,24h                           ; Sets to reg B4h+ (stereo output control and LFO sensitivity)
                ld      c,(ix+zTrack.AMSFMSPan)         ; Panning / AMS / FMS settings from track
                rst     zWriteFMIorII                   ; Write it!
                ld      (ix+zTrack.TLPtrLow),l          ; Save current position (TL bytes begin)
                ld      (ix+zTrack.TLPtrHigh),h         ; ...for updating volume correctly later later

; zloc_E65
.a_backup:
                ld      a,0                             ; Self-modified code: 'a' will actually be set to the feedback/algorithm byte
                and     7                               ; Only keeping the "algorithm" part of it
                add     a,zVolTLMaskTbl&0FFh            ; Adds offset to zVolTLMaskTbl table (low byte only)
                ld      e,a                             ; Puts this low byte into 'e'
                ld      d,(zVolTLMaskTbl&0FF00h)>>8     ; Get high byte -> 'd'
                ld      a,(de)                          ; Get this zVolTLMaskTbl value by algorithm
                ld      (ix+zTrack.VolTLMask),a         ; Store this zVolTLMaskTbl value into (ix+1Ah)
                ld      e,a                             ; Store zVolTLMaskTbl value -> 'e'
                ld      d,(ix+zTrack.Volume)            ; Store channel volume -> 'd'
                pop     af                              ; Restore 'a'; it's now back at appropriate 40h+ register for Total Level setting!

; Set "total levels" (general volume control)
zSetFMTLs:
                ld      b,4                             ; Loop 4 times (for each total level register on this channel)

.loop:
                ld      c,(hl)                          ; Get next TL byte -> c
                inc     hl                              ; Next voice byte
                rr      e                               ; zVolTLMaskTbl value is rotated right; if the bit 0 of this value prior to the rotate was reset (0)
                jr      nc,.write                       ; ...then we make the jump here (just write the TL value directly, don't modify it)

; Otherwise, apply channel volume to TL here
; It's not appropriate to alter ALL TL values, only
; the ones which are "slots" (output operators)
                push    af                              ; Save 'a'
                ld      a,d                             ; Channel volume -> d
                add     a,c                             ; Add it to the TL value
                ld      c,a                             ; Modified value -> c
                pop     af                              ; Restore 'a'

.write:
                rst     zWriteFMIorII                   ; Write TL value
                add     a,4                             ; Next TL reg
                djnz    .loop

                ret
; End of function zSetVoiceMusic

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_E8A
zSetChanVol:
                bit     7,(ix+zTrack.VoiceControl)      ; Is this a PSG track?
                ret     nz                              ; If so, quit!
                bit     2,(ix+zTrack.PlaybackControl)   ; If playback control byte "SFX is overriding this track" bit set
                ret     nz                              ; ...then quit!
                ld      e,(ix+zTrack.VolTLMask)         ; zVolTLMaskTbl value from last voice setting (marks which specific TL operators need updating)
                ld      a,(ix+zTrack.VoiceControl)      ; Load current voice control byte
                and     3                               ; Keep only bits 0-2
                add     a,40h                           ; Add 40h -- appropriate TL register
                ld      d,(ix+zTrack.Volume)            ; Get channel volume
                bit     7,d                             ; If bit 7 (80h) is set
                ret     nz                              ; ...then quit!
                push    hl                              ; Save 'hl'
                ld      l,(ix+zTrack.TLPtrLow)          ; Low byte of where TL bytes begin (set during last voice setting)
                ld      h,(ix+zTrack.TLPtrHigh)         ; High byte of where TL bytes begin (set during last voice setting)
                call    zSetFMTLs                       ; Set the appropriate Total Levels
                pop     hl                              ; Restore 'hl'
                ret
; End of function zSetChanVol

; ---------------------------------------------------------------------------

; (via Saxman's doc): F0wwxxyyzz - modulation
; o ww - Wait for this period of time before modulation starts
; o xx - Modulation speed
; o yy - Modulation change per mod. step
; o zz - Number of steps in modulation
; zloc_EB0
cfModulation:
                set     3,(ix+zTrack.PlaybackControl)   ; Set bit 3 (08h) of "playback control" byte (modulation on)
                dec     hl                              ; Move 'hl' back one
                ld      (ix+zTrack.ModulationPtrLow),l  ; Back up modulation setting address into (ix+11h), (ix+12h)
                ld      (ix+zTrack.ModulationPtrHigh),h

; zloc_EBB
zSetModulation:
; Sets up modulation for this track; expects 'hl' to point to modulation
; configuration info
                ld      a,ixl                           ; Get lower byte of current track address (ew :P)
                add     a,zTrack.ModulationWait         ; ... and add 19 bytes to it
                ld      e,a                             ; put that into 'e'
                adc     a,ixu                           ; If carry occurred, add that to upper part of address
                sub     e                               ; subtract 'e'
                ld      d,a                             ; Basically, 'd' is now the appropriate upper byte of the address, completing de = (ix + 19)
    ; Copying next three bytes
                ldi                                     ; *(de)++ = *(hl)++  (Wait for ww period of time before modulation starts)
                ldi                                     ; *(de)++ = *(hl)++  (Modulation Speed)
                ldi                                     ; *(de)++ = *(hl)++  (Modulation change per Mod. Step)
                ld      a,(hl)                          ; Get Number of steps in modulation
                inc     hl                              ; Next byte
                srl     a                               ; divide number of steps by 2
                ld      (ix+zTrack.ModulationSteps),a   ; Store this step count into trackPtr+16h
                bit     4,(ix+zTrack.PlaybackControl)   ; Is bit 4 "do not attack next note" (10h) set?
                ret     nz                              ; If so, quit!
                xor     a                               ; Clear 'a'
                ld      (ix+zTrack.ModulationValLow),a  ; Clear modulation value low byte
                ld      (ix+zTrack.ModulationValHigh),a  ; Clear modulation value high byte
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): Turn on modulation
; zloc_EDE
cfEnableModulation:
                dec     hl
                set     3,(ix+zTrack.PlaybackControl)   ; Playback byte bit 3 (08h) -- modulation on
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): stop the track
; zloc_EE4
cfStopTrack:
                res     7,(ix+zTrack.PlaybackControl)   ; Clear playback byte bit 7 (80h) -- currently playing (not anymore)
                res     4,(ix+zTrack.PlaybackControl)   ; Clear playback byte bit 4 (10h) -- do not attack
                bit     7,(ix+zTrack.VoiceControl)      ; Is voice control bit 7 (80h) a PSG track set?
                jr      nz,zStopPSGTrack                ; If so, skip this next part
                ld      a,(zAbsVar.DACUpdating)         ; Is DAC updating?  (FF if so)
                or      a                               ; test it
                jp      m,zDACStopTrack                 ; If DAC is updating, go here (we're in a DAC track)
                call    zFMNoteOff                      ; Otherwise, stop this FM track
                jr      zStoppedChannel

; zcall_zsub_526
zStopPSGTrack:
                call    zPSGNoteOff

zStoppedChannel:                                        ; General stop track continues here
                ld      a,(zDoSFXFlag)                  ; Check if we're an SFX track
                or      a                               ; test it
                jp      p,zStopMusicTrack               ; if not, jump
                xor     a                               ; a = 0
                ld      (zAbsVar.SFXPriorityVal),a      ; Reset SFX priority
                ld      a,(ix+zTrack.VoiceControl)      ; Load "voice control" byte
                or      a                               ; test it
                jp      m,zStopPSGSFXTrack              ; If this is a PSG SFX track, jump
                push    ix                              ; save 'ix'
; This is an FM SFX track that's trying to stop
                sub     2                               ; Take channel assignment - 2 (since SFX never use FM 1 or FM 2)
                add     a,a                             ; a *= 2 (each table entry is 2 bytes wide)
                add     a,zMusicTrackOffs&0FFh          ; Get low byte value from zMusicTrackOffs
                ld      (.fmtrackoffs+2),a              ; Store into the instruction after .fmtrackoffs (self-modifying code)

; zloc_F1D:
.fmtrackoffs:
                ld      ix,(zMusicTrackOffs)            ; Self-modified code from just above: 'ix' points to corresponding Music FM track
                bit     2,(ix+zTrack.PlaybackControl)   ; If "SFX is overriding this track" is not set
                jp      z,zNoVoiceUpdate                ; Skip this part (i.e. if SFX was not overriding this track, then nothing to restore)
                call    zBankSwitchToMusic              ; Bank switch back to music track
                res     2,(ix+zTrack.PlaybackControl)   ; Clear SFX is overriding this track from playback control
                set     1,(ix+zTrack.PlaybackControl)   ; Set track as resting bit
                ld      a,(ix+zTrack.VoiceIndex)        ; Get voice this track was using
                call    zSetVoiceMusic                  ; And set it! (takes care of volume too)

                bankswitch SoundIndex

zNoVoiceUpdate:
                pop     ix                              ; restore 'ix'
                pop     bc                              ; removing return address from stack; will not return to coord flag loop
                pop     bc                              ; removing return address from stack; will not return to zUpdateTrack function
                ret
; ---------------------------------------------------------------------------

zStopPSGSFXTrack:
                push    ix                              ; save 'ix'

; Keep in mind that we just entered with a PSG "voice control" byte
; which is one of the following values (PSG1-3/3N) -- 80h, A0h, C0h, E0h
                rra
                rra
                rra
                rra                                     ; in effect, ">> 4"
                and     0Fh                             ; 'a' is now 08, 0A, 0C, or 0E
                add     a,zMusicTrackOffs&0FFh
                ld      (.psgtrackoffs+2),a             ; store into the instruction after .psgtrackoffs (self-modifying code)

; zloc_F5A
.psgtrackoffs:
                ld      ix,(zMusicTrackOffs)            ; Self-modified code from just above: 'ix' points to corresponding Music PSG track
                res     2,(ix+zTrack.PlaybackControl)   ; Clear SFX is overriding this track from playback control
                set     1,(ix+zTrack.PlaybackControl)   ; Set track as resting bit
                ld      a,(ix+zTrack.VoiceControl)      ; Get voice control byte
                cp      0E0h                            ; Is this a PSG 3 noise (not tone) track?
                jr      nz,.exit                        ; If it isn't, don't do next part (non-PSG Noise doesn't restore)
                ld      a,(ix+zTrack.PSGNoise)          ; Get PSG noise setting
                ld      (zPSG),a                        ; Write it to PSG

.exit:
                pop     ix                              ; restore 'ix'

; zloc_F75
zStopMusicTrack:
                pop     bc                              ; removing return address from stack; will not return to coord flag loop

; zloc_F76
zDACStopTrack:
                pop     bc                              ; removing return address from stack; will not return to zUpdateTrack function (anything other than DAC) or not to coord flag loop (if DAC)
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): Change current PSG noise to xx (For noise channel, E0-E7)
; zloc_F78
cfSetPSGNoise:
                ld      (ix+zTrack.VoiceControl),0E0h   ; This is a PSG noise track now!
                ld      (ix+zTrack.PSGNoise),a          ; Save PSG noise setting for restoration if SFX overrides it
                bit     2,(ix+zTrack.PlaybackControl)   ; If SFX is currently overriding it, don't actually set it!
                ret     nz
                ld      (zPSG),a                        ; Otherwise, please do
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): Turn off modulation
; zloc_F88
cfDisableModulation:
                dec     hl                              ; No parameters used, must back up a byte
                res     3,(ix+zTrack.PlaybackControl)   ; Clear "modulation on" bit setting
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): Change current PSG tone to xx
; zloc_F8E
cfSetPSGTone:
                ld      (ix+zTrack.VoiceIndex),a        ; Set current PSG tone
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): jump to position yyyy
; zloc_F92
cfJumpTo:
                ld      h,(hl)                          ; Get hight byte of jump destination (since pointer advanced to it)
                ld      l,a                             ; Put low byte (already retrieved)
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): $F7xxyyzzzz - repeat section of music
; * xx - loop index, for loops within loops without confusing the engine
; o EXAMPLE: Some notes, then a section that is looped twice, then some more notes, and finally the whole thing is looped three times
; The "inner" loop (the section that is looped twice) would have an xx of 01, looking something along the lines of F70102zzzz, whereas the "outside" loop (the whole thing loop) would have an xx of 00, looking something like F70003zzzz
; * yy - number of times to repeat
; o NOTE: This includes the initial encounter of the F7 flag, not number of times to repeat AFTER hitting the flag
; * zzzz - position to loop back to
; zloc_F95
cfRepeatAtPos:
    ; Loop index is in 'a'
                ld      c,(hl)                          ; Get next byte (number of repeats) -> 'c'
                inc     hl                              ; Next byte
                push    hl                              ; Save 'hl'
                add     a,zTrack.LoopCounters           ; Add to make loop index offset (starts at 20h in track memory)
                ld      l,a                             ; Set hl = offset index
                ld      h,0
                ld      e,ixl                           ; Set 'de' to beginning of track
                ld      d,ixu
                add     hl,de                           ; hl is now pointing to track memory offset for this loop
                ld      a,(hl)                          ; Get loop count at this address
                or      a                               ; Test it
                jr      nz,.loopexists                  ; If not zero, then skip next step (i.e. we're currently looping)
                ld      (hl),c                          ; Otherwise, set it to the new number of repeats

.loopexists:
                dec     (hl)                            ; One less loop
                pop     hl                              ; Restore 'hl' (now at the position)
                jr      z,.noloop                       ; If counted to zero, skip the rest of this (hence start loop count of 1 terminates the loop without ever looping)
                ld      a,(hl)                          ; Get low byte of jump address
                inc     hl                              ; Next byte
                ld      h,(hl)                          ; Get high byte of jump address -> 'h'
                ld      l,a                             ; Put low byte of jump address -> 'l'

; Note then that this loop command only works AFTER the section you mean to loop
                ret

.noloop:
; If you get here, the loop terminated; just bypass the loop jump address
                inc     hl
                inc     hl
                ret
; ---------------------------------------------------------------------------

; (via Saxman's doc): jump to position yyyy (keep previous position in memory for returning)
; zloc_FB3
cfJumpToGosub:
                ld      c,a                             ; a -> c
                ld      a,(ix+zTrack.StackPointer)      ; Get current "stack" offset (starts at 2Ah, i.e. beginning of next track)
                sub     2                               ; Move back by two (we need to store a new return address)
                ld      (ix+zTrack.StackPointer),a      ; Set current stack offset
                ld      b,(hl)                          ; Get high byte of jump position -> 'b'
                inc     hl                              ; Next byte
                ex      de,hl                           ; hl <=> de
                add     a,ixl                           ; Add low byte of current track pointer to stack offset (low byte of stack location)
                ld      l,a                             ; Keep this in 'l'
                adc     a,ixu                           ; Update high byte, if necessary
                sub     l                               ; Fixup
                ld      h,a                             ; a -> 'h' (Simply, we just did hl = ix + stack_offset)
                ld      (hl),e                          ; Store current address low byte (just after jump) into stack
                inc     hl                              ; Next byte
                ld      (hl),d                          ; Store current address high byte (just after jump) into stack
                ld      h,b
                ld      l,c                             ; hl = bc (current location is where you wanted to jump to)
                ret
; ---------------------------------------------------------------------------

; Leftover from Sonic 1: was used in Spring Yard Zone's music
; zloc_FCC
cfOpF9:
                ld      a,88h                           ; D1L/RR of Operator 3
                ld      c,0Fh                           ; Loaded with fixed value (max RR, 1TL)
                rst     zWriteFMI                       ; Written to part I
                ld      a,8Ch                           ; D1L/RR of Operator 4
                ld      c,0Fh                           ; Loaded with fixed value (max RR, 1TL)
                rst     zWriteFMI                       ; Written to part I
                dec     hl                              ; Doesn't take an arg, so put back one byte
                ret
