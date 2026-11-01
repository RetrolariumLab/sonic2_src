; ---------------------------------------------------------------------------

; zloc_3E5
zFMPrepareNote:
                bit     1,(ix+zTrack.PlaybackControl)   ; Is track in rest?
                ret     nz                              ; If so, quit
                ld      e,(ix+zTrack.FreqLow)           ; Get frequency low
                ld      d,(ix+zTrack.FreqHigh)          ; Get frequency high
                ld      a,d
                or      e
                jp      z,zSetRest                      ; If de == 0, go to zSetRest

; zloc_3F5
zFMUpdateFreq:
                bit     2,(ix+zTrack.PlaybackControl)   ; Is SFX overriding this track?
                ret     nz                              ; If so, quit!
; This is a 16-bit sign extension of (ix+19h)
                ld      h,0                             ; h = 0
                ld      l,(ix+zTrack.Detune)            ; Get detune value
                bit     7,l                             ; Did prior value have 80h set?
                jr      z,.nosignextend                 ; If not, skip next step
                ld      h,0FFh                          ; h = FFh

.nosignextend:
                add     hl,de                           ; Alter frequency just a tad
                ld      c,h                             ; Upper part of frequency as data to FM ('c')
                ld      a,(ix+zTrack.VoiceControl)      ; "voice control" byte -> 'a'
                and     3                               ; Strip to only channel assignment
                add     a,0A4h                          ; Change to proper register
                rst     zWriteFMIorII                   ; Write it!
                ld      c,l                             ; lower part of frequency
                sub     4                               ; A0h+ register
                rst     zWriteFMIorII                   ; Write it!
                ret

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_414
zPSGUpdateTrack:
                dec     (ix+zTrack.DurationTimeout)     ; decrement current duration timeout
                jr      nz,.notegoing                   ; If not time-out yet, go do updates only
                res     4,(ix+zTrack.PlaybackControl)   ; Reset "do not attack next note" bit
                call    zPSGDoNext                      ; Handle coordination flags, get next note and duration
                call    zPSGDoNoteOn                    ; Actually key it (if allowed)
                call    zPSGDoVolFX                     ; This applies PSG volume as well as its special volume-based effects that I call "flutter"
                call    zDoModulation                   ; Update modulation (if modulation doesn't change, we do not return here)
                jp      zPSGUpdateFreq

.notegoing:
                call    zNoteFillUpdate                 ; Applies "note fill" (time until cut-off); NOTE: Will not return here if "note fill" expires
                call    zPSGUpdateVolFX                 ; Update volume effects
                call    zDoModulation                   ; Update modulation (if modulation doesn't change, we do not return here)
                jp      zPSGUpdateFreq
; End of function zPSGUpdateTrack

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_438
zPSGDoNext:
                ld      l,(ix+zTrack.DataPointerLow)    ; Load track position low byte
                ld      h,(ix+zTrack.DataPointerHigh)   ; Load track position high byte
                res     1,(ix+zTrack.PlaybackControl)   ; Clear bit 1 (02h) "track is rest" from track

.noteloop:
                ld      a,(hl)
                inc     hl                              ; Increment track to next byte
                cp      0E0h                            ; Is it a control byte / "coordination flag"?
                jr      c,.gotnote                      ; If not, jump over
                call    zCoordFlag                      ; Handle coordination flag
                jr      .noteloop                       ; Go around, get next byte

.gotnote:
                or      a                               ; Test 'a' for 80h not set, which is a note duration
                jp      p,.gotduration                  ; If note duration, jump to .gotduration
                call    zPSGSetFreq                     ; Get frequency for this note
                ld      a,(hl)                          ; Get next byte
                or      a                               ; Test 'a' for 80h set, which is a note
                jp      m,zFinishTrackUpdate            ; If this is a note, jump to zFinishTrackUpdate
                inc     hl                              ; Otherwise, go to next byte; a duration

.gotduration:
                call    zSetDuration
                jp      zFinishTrackUpdate              ; Either way, jumping to zFinishTrackUpdate
; End of function zPSGDoNext

; ---------------------------------------------------------------------------

; zloc_460
zPSGSetFreq:
                sub     81h                             ; a = a-$81 (zero-based index from lowest note)
                jr      c,.restpsg                      ; If carry (only time that happens if 80h because of earlier logic) this is a rest!
                add     a,(ix+zTrack.Transpose)         ; Add current channel transpose (coord flag E9)
                add     a,a                             ; Multiply note value by 2
                add     a,zPSGFrequencies&0FFh          ; Point to proper place in table
                ld      (.storefreq+2),a                ; store into the following instruction (self-modifying code)

; zloc_46D
.storefreq:
                ld      de,(zPSGFrequencies)            ; Gets appropriate frequency setting -> 'de'
                ld      (ix+zTrack.FreqLow),e           ; Frequency low byte   -> trackPtr + 0Dh
                ld      (ix+zTrack.FreqHigh),d          ; Frequency high byte  -> trackPtr + 0Eh
                ret

.restpsg:
; If you get here, we're doing a PSG rest
                set     1,(ix+zTrack.PlaybackControl)   ; Set "track in rest" bit
                ld      a,0FFh
                ld      (ix+zTrack.FreqLow),a           ; Frequency low byte = FFh
                ld      (ix+zTrack.FreqHigh),a          ; Frequency hight byte = FFh
                jp      zPSGNoteOff                     ; Send PSG Note Off

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_487
zPSGDoNoteOn:
                bit     7,(ix+zTrack.FreqHigh)          ; If track is at rest (frequency was set to FFh)
                jr      nz,zSetRest                     ; jump to zSetRest
                ld      e,(ix+zTrack.FreqLow)           ; Frequency low byte -> e
                ld      d,(ix+zTrack.FreqHigh)          ; Frequency high byte -> d

; zloc_493
zPSGUpdateFreq:
                ld      a,(ix+zTrack.PlaybackControl)   ; Get playback control byte
                and     6
                ret     nz                              ; If either bit 1 ("track in rest") and 2 ("SFX overriding this track"), quit!
; This is a 16-bit sign extension of (ix+19h) -> 'hl'
                ld      h,0
                ld      l,(ix+zTrack.Detune)            ; hl = detune value (coord flag E9)
                bit     7,l                             ; Did prior value have 80h set?
                jr      z,.nosignextend                 ; If not, skip next step
                ld      h,0FFh                          ; sign extend negative value

.nosignextend:
                add     hl,de                           ; Alter frequency just a tad
; This picks out the reg to write to the PSG
                ld      a,(ix+zTrack.VoiceControl)      ; Get "voice control" byte
                cp      0E0h                            ; Is it E0h?
                jr      nz,.notnoise                    ; If not, skip next step
                ld      a,0C0h                          ; a = C0h instead of E0h

.notnoise:
                ld      b,a                             ; 'a' -> 'b'
                ld      a,l                             ; Frequency low byte -> 'a'
                and     0Fh                             ; Keep only lower four bits (first PSG reg write only applies d0-d3 of freq)
                or      b                               ; Apply register bits
                ld      (zPSG),a                        ; Write it to PSG!
                ld      a,l                             ; Get frequency low byte -> 'a'
                srl     h                               ; (h >> 1); lowest bit into carry
                rra                                     ; (a >> 1); carry from 'h' applied at end
                srl     h                               ; ... and so on
                rra
                rra
                rra                                     ; in C, basically (hl >> 4) (except possible garbage from the rotation in upper bits)
                and     3Fh                             ; keep only lower 6 bits (PSG d4-d9)
                ld      (zPSG),a                        ; Write other frequency byte to PSG!
                ret
; ---------------------------------------------------------------------------

; zloc_4C5
zSetRest:
                set     1,(ix+zTrack.PlaybackControl)   ; Set "track at rest" bit
                ret
; End of function zPSGDoNoteOn

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_4CA
zPSGUpdateVolFX:
                ld      a,(ix+zTrack.VoiceIndex)        ; Get current PSG tone
                or      a                               ; Test if it's zero
                ret     z                               ; If it is, return!
; Otherwise, fall into zPSGDoVolFX

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_4CF
zPSGDoVolFX:
                ld      b,(ix+zTrack.Volume)            ; Channel volume -> 'b'
                ld      a,(ix+zTrack.VoiceIndex)        ; Current PSG tone -> 'a'
                or      a                               ; Test it
                jr      z,zPSGUpdateVol                 ; If tone is zero, jump to zPSGUpdateVol
                ld      hl,zPSG_EnvTbl                  ; hl points to PSG envelope table
                dec     a                               ; a--
                add     a,a                             ; a *= 2
                ld      e,a
                ld      d,0                             ; de = a
                add     hl,de                           ; Offset into pointer table
                ld      a,(hl)                          ; Get low byte -> 'a'
                inc     hl                              ; Next byte
                ld      h,(hl)                          ; Get high byte into 'h'
                add     a,(ix+zTrack.VolFlutter)        ; Apply PSG flutter (provides dynamic volume for special effects)
                ld      l,a
                adc     a,h
                sub     l
                ld      h,a                             ; Basically, hl = (hl+(ix+zTrack.VolFlutter))
                ld      a,(hl)                          ; Get byte from this location
                inc     (ix+zTrack.VolFlutter)          ; Increment PSG flutter value
                or      a                               ; test byte from before
                jp      p,.gotflutter                   ; Is it a positive value?
                cp      80h                             ; Check if it's 80h (terminator to the "flutter" list)
                jr      z,zVolEnvHold                   ; If it is, then jump to zVolEnvHold (which just keeps at this flutter value, i.e. no more changes in volume)

.gotflutter:
                add     a,b                             ; Apply this "flutter" to channel volume -> 'a'
                ld      b,a                             ; a -> 'b'

; zloc_4F9
zPSGUpdateVol:
                ld      a,(ix+zTrack.PlaybackControl)   ; get playback control byte
                and     6                               ; Checks bits 1 ("track at rest") and 2 ("SFX overriding this track")
                ret     nz                              ; If either bit is set, quit!
                bit     4,(ix+zTrack.PlaybackControl)   ; Is "do not attack next note" set?
                jr      nz,zPSGCheckNoteFill            ; If so, jump to zPSGCheckNoteFill

; zloc_505
zPSGSendVol:
                ld      a,b                             ; 'b' -> 'a'
                cp      10h                             ; Did the level get pushed below silence level? (i.e. a > 0Fh)
                jr      c,.abovesilence
                ld      a,0Fh                           ; If so, fix it!

.abovesilence:
                or      (ix+zTrack.VoiceControl)        ; Apply channel info (which PSG to set!)
                or      10h                             ; This bit marks it as an attenuation level assignment (along with channel info just above)
                ld      (zPSG),a                        ; Write to PSG!!
                ret
; ---------------------------------------------------------------------------

; zloc_515
zPSGCheckNoteFill:                                      ; If you get here, then "do not attack next note" was set
                ld      a,(ix+zTrack.NoteFillMaster)    ; Get master "note fill" value
                or      a                               ; test it
                jr      z,zPSGSendVol                   ; If it's zero, then just process normally
                ld      a,(ix+zTrack.NoteFillTimeout)   ; Otherwise, get current "note fill" value
                or      a                               ; Test it
                jr      nz,zPSGSendVol                  ; If it's not zero, then just process normally
                ret
; ---------------------------------------------------------------------------
; zloc_522
zVolEnvHold:
; This just decrements the flutter to keep it in place; no more volume changes in this list
; DANGER! This effectively halts all future volume updates, breaking fades
                dec     (ix+zTrack.VolFlutter)          ; Put index back (before flag 80h)
                ret                                     ; Return and don't update volume on this frame (!!!)
; End of function zPSGDoVolFX

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_526
zPSGNoteOff:
                bit     2,(ix+zTrack.PlaybackControl)   ; Is "SFX override" bit set?
                ret     nz                              ; If so, quit!
                ld      a,(ix+zTrack.VoiceControl)      ; Get "voice control" byte (loads upper bits which specify attenuation setting)

; |a| |1Fh|
; VOL1    0x90 = 100 1xxxx vol 4b xxxx = attenuation value
; VOL2    0xb0 = 101 1xxxx vol 4b
; VOL3    0xd0 = 110 1xxxx vol 4b

                or      1Fh                             ; Attenuation Off
                ld      (zPSG),a
                ret
; End of function zPSGNoteOff

; ---------------------------------------------------------------------------
zMakeFMFrequency            function frequency,roundFloatToInteger(frequency*1024*1024*2/FM_Sample_Rate)
zMakeFMFrequenciesOctave    macro   octave
; Frequencies for the base octave. The first frequency is B, the last frequency is B-flat
                    irp     op, 15.39, 16.35, 17.34, 18.36, 19.45, 20.64, 21.84, 23.13, 24.51, 25.98, 27.53, 29.15
                    dw      zMakeFMFrequency(op)+octave*800h
                endm
                endm

; lookup table of FM note frequencies for instruments and sound effects
                ensure1byteoffset 0C0h
; zbyte_534
zFrequencies:
                zMakeFMFrequenciesOctave 0
                zMakeFMFrequenciesOctave 1
                zMakeFMFrequenciesOctave 2
                zMakeFMFrequenciesOctave 3
                zMakeFMFrequenciesOctave 4
                zMakeFMFrequenciesOctave 5
                zMakeFMFrequenciesOctave 6
                zMakeFMFrequenciesOctave 7

; zloc_5F4
zPSGSilenceAll:
                ld      hl,zPSG                         ; PSG reg
                ld      (hl),9Fh                        ; Stop channel 0
                ld      (hl),0BFh                       ; Stop channel 1
                ld      (hl),0DFh                       ; Stop channel 2
                ld      (hl),0FFh                       ; Stop noise channel
                ret

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; zsub_600
zPauseMusic:
                jp      m,.unpause                      ; If we are to unpause music, jump
                ld      a,(zPaused)                     ; Get paused flag
                or      a                               ; Are we paused already?
                ret     nz                              ; If so, return
                ld      a,0FFh                          ; a = 0FFh
                ld      (zPaused),a                     ; Set paused flag
                call    zFMSilenceAll
                jp      zPSGSilenceAll

.unpause:
                push    ix                              ; Save ix (nothing uses this, beyond this point...)
                ld      (ix+zVar.StopMusic),0           ; Clear pause/unpause flag
                xor     a                               ; a = 0
                ld      (zPaused),a                     ; Clear paused flag
                ld      ix,zSongDACFMStart              ; ix = pointer to track RAM
                ld      b,MUSIC_DAC_FM_TRACK_COUNT      ; 1 DAC + 6 FM
                call    zResumeTrack

                bankswitch SoundIndex                   ; Now for SFX

                ld      a,0FFh                          ; a = 0FFH
                ld      (zDoSFXFlag),a                  ; Set flag to say we are updating SFX
                ld      ix,zSFX_FMStart                 ; ix = pointer to SFX track RAM
                ld      b,SFX_FM_TRACK_COUNT            ; 3 FM
                call    zResumeTrack
; None of this is necessary
                xor     a                               ; a = 0
                ld      (zDoSFXFlag),a                  ; Clear SFX updating flag
                call    zBankSwitchToMusic              ; Back to music (Pointless: music isn't updated until the next frame)
                pop     ix                              ; Restore ix (nothing uses this, beyond this point...)
                ret
; End of function zPauseMusic

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; zsub_64D
zResumeTrack:
                bit     7,(ix+zTrack.PlaybackControl)   ; Is track playing?
                jr      z,.nexttrack                    ; If not, jump
                bit     2,(ix+zTrack.PlaybackControl)   ; Is SFX overriding track?
                jr      nz,.nexttrack                   ; If yes, jump
; cfSetVoiceCont already does this
                ld      c,(ix+zTrack.AMSFMSPan)         ; AMS/FMS/panning flags
                ld      a,(ix+zTrack.VoiceControl)      ; Get voice control bits
                and     3                               ; ... the FM portion of them
                add     a,0B4h                          ; Command to select AMS/FMS/panning register
                rst     zWriteFMIorII
                push    bc                              ; Save bc
                ld      c,(ix+zTrack.VoiceIndex)        ; Current track FM instrument
                call    cfSetVoiceCont
                pop     bc                              ; Restore bc

.nexttrack:
                ld      de,zTrack.len                   ; de = Track size
                add     ix,de                           ; Advance to next track
                djnz    zResumeTrack                    ; loop
                ret
; End of function zResumeTrack

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; zsub_674
zCycleQueue:
                ld      a,(zAbsVar.QueueToPlay)         ; Check if a sound request was made zComRange+08h
                cp      80h                             ; Is queue slot equal to 80h?
                ret     nz                              ; If not, return
                ld      hl,zAbsVar.Queue0               ; Get address of next sound
                ld      a,(zAbsVar.SFXPriorityVal)      ; Get current SFX priority
                ld      c,a                             ; a -> c
                ld      b,3                             ; 3, for Queue0, Queue1, and Queue2

zInputLoop:
                ld      a,(hl)                          ; Get sound to play -> 'a'
                ld      e,a                             ; 'a' -> 'e'
                ld      (hl),0                          ; Clear it back to zero (we got it)
                inc     hl                              ; hl = pointer to next queue item
                cp      MusID__First                    ; Is it before first music?
                jr      c,zQueueNext                    ; If so, jump
                cp      CmdID__First                    ; Is it a special command?
                jr      nc,zQueueItem                   ; If so, jump
                sub     SndID__First                    ; Subtract first SFX index
                jr      c,zQueueItem                    ; If it was music, jump
                add     a,zSFXPriority&0FFh             ; a = low byte of pointer to SFX priority
                ld      l,a                             ; l = low byte of pointer to SFX priority
                adc     a,(zSFXPriority&0FF00h)>>8      ; a = low byte of pointer to SFX priority + high byte of same pointer
                sub     l                               ; a = high byte of pointer to SFX priority
                ld      h,a                             ; hl = pointer to SFX priority
                ld      a,(hl)                          ; Get SFX priority
                cp      c                               ; Is the new SFX of a higher priority?
                jr      c,.nextinput                    ; If not, jump
                ld      c,a                             ; Save new priority
                call    zQueueItem                      ; Queue the new SFX

.nextinput:
                ld      a,c                             ; Get back SFX priority
                or      a                               ; Is it negative (jumping sound)?
                ret     m                               ; Return if so
                ld      (zAbsVar.SFXPriorityVal),a      ; Store the new priority
                ret
