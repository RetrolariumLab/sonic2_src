; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Z80 'ROM' start:
; zEntryPoint:
                di                                      ; Disable interrupts
                ld      sp,zStack
                jp      zStartDAC
; ---------------------------------------------------------------------------
; zbyte_7:
zPalModeByte:
                db      0

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                align   8
; zsub_8
zFMBusyWait:    rsttarget
; Performs the annoying task of waiting for the FM to not be busy
                ld      a,(zYM2612_A0)
                add     a,a
                jr      c,zFMBusyWait
                ret
; End of function zFMBusyWait

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                align   8
; zsub_10
zWriteFMIorII:  rsttarget
                bit     2,(ix+zTrack.VoiceControl)
                jr      z,zWriteFMI
                jr      zWriteFMII
; End of function zWriteFMIorII

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                align   8
; zsub_18
zWriteFMI:      rsttarget
; Write reg/data pair to part I; 'a' is register, 'c' is data
                push    af
                rst     zFMBusyWait                     ; 'rst' is like 'call' but only works for 8-byte aligned addresses <= 38h
                pop     af
                ld      (zYM2612_A0),a
                push    af
                rst     zFMBusyWait
                ld      a,c
                ld      (zYM2612_D0),a
                pop     af
                ret
; End of function zWriteFMI

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                align   8
; zsub_28
zWriteFMII:     rsttarget
; Write reg/data pair to part II; 'a' is register, 'c' is data
                push    af
                rst     zFMBusyWait
                pop     af
                ld      (zYM2612_A1),a
                push    af
                rst     zFMBusyWait
                ld      a,c
                ld      (zYM2612_D1),a
                pop     af
                ret
; End of function zWriteFMII

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                org     38h
zVInt:          rsttarget
; This is called every VBLANK (38h is the interrupt entry point,
; and VBLANK is the only one Z80 is hooked up to.)

                push    af                              ; Save 'af'
                exx                                     ; Effectively backs up 'bc', 'de', and 'hl'
                call    zBankSwitchToMusic              ; Bank switch to the music
                xor     a                               ; Clear 'a'
                ld      (zDoSFXFlag),a                  ; Not updating SFX (updating music)
                ld      ix,zAbsVar                      ; ix points to zComRange
                ld      a,(zAbsVar.StopMusic)           ; Get pause/unpause flag
                or      a                               ; Test 'a'
                jr      z,zUpdateEverything             ; If zero, go to zUpdateEverything
                call    zPauseMusic
                jp      zUpdateDAC                      ; Now update the DAC
; ---------------------------------------------------------------------------

; zloc_51
zUpdateEverything:
                ld      a,(zAbsVar.FadeOutCounter)      ; Are we fading out?
                or      a
                call    nz,zUpdateFadeout               ; If so, update that

                ld      a,(zAbsVar.FadeInFlag)          ; Are we fading in?
                or      a
                call    nz,zUpdateFadeIn                ; If so, update that

                ld      a,(zAbsVar.Queue0)
                or      (ix+zVar.Queue1)
                or      (ix+zVar.Queue2)                ; This was missing in Sonic 1's driver, breaking the third queue slot
                call    nz,zCycleQueue                  ; If any of those are non-zero, cycle queue

; Apparently if this is 80h, it does not play anything new,
; otherwise it cues up the next play (flag from 68K for new item)
                ld      a,(zAbsVar.QueueToPlay)
                cp      80h
                call    nz,zPlaySoundByIndex            ; If not 80h, we need to play something new!

; Spindash update
                ld      a,(zSpindashPlayingCounter)
                or      a
                jr      z,.pal_timer                    ; If the spindash counter is already 0, jump
                dec     a                               ; Decrease the spindash sound playing counter
                ld      (zSpindashPlayingCounter),a

.pal_timer:
; If the system is PAL, then this performs some timing adjustments
; (i.e. you need to update 1.2x as much to keep up the same rate)
                ld      hl,zPalModeByte                 ; Get address of zPalModeByte
                ld      a,(zAbsVar.IsPalFlag)           ; Get IsPalFlag -> 'a'
                and     (hl)                            ; 'And' them together
                jr      z,.not_pal                      ; If it comes out zero, do nothing
                ld      hl,zPALUpdTick
                dec     (hl)
                jr      nz,.not_pal
                ld      (hl),5                          ; Every 6 frames (0-5) you need to "double update" to sort of keep up
                call    zUpdateMusic

.not_pal:
                call    zUpdateMusic

; Now all of the SFX tracks are updated in a similar manner to "zUpdateMusic"
                bankswitch SoundIndex                   ; Bank switch to sound effects

                ld      a,80h
                ld      (zDoSFXFlag),a                  ; Set zDoSFXFlag = 80h (updating sound effects)

; FM SFX channels
                ld      b,SFX_FM_TRACK_COUNT            ; Only 3 FM channels for SFX (FM3, FM4, FM5)

.fmloop:
                push    bc
                ld      de,zTrack.len                   ; Spacing between tracks
                add     ix,de                           ; Next track
                bit     7,(ix+zTrack.PlaybackControl)   ; Is it playing?
                call    nz,zFMUpdateTrack               ; If it is, go update it
                pop     bc
                djnz    .fmloop

; PSG SFX channels
                ld      b,SFX_PSG_TRACK_COUNT           ; All PSG channels available

.psgloop:
                push    bc
                ld      de,zTrack.len                   ; Spacing between tracks
                add     ix,de                           ; Next track
                bit     7,(ix+zTrack.PlaybackControl)   ; Is it playing?
                call    nz,zPSGUpdateTrack              ; If it is, go update it
                pop     bc
                djnz    .psgloop

; Now we update the DAC... this only does anything if there's a new DAC
; sound to be played.  This is called after updating the DAC track
; Otherwise it just mucks with the timing loop, forcing an update
zUpdateDAC:
                bankswitch SndDAC_Start                 ; Bankswitch to the DAC data

                ld      a,(zCurDAC)                     ; Get currently playing DAC sound
                or      a
                jp      m,.dacqueued                    ; If one is queued (80h+), go to it!
                exx                                     ; Otherwise restore registers from mirror regs
                ld      b,1                             ; b=1 (initial feed to the DAC "djnz" loops, i.e. UPDATE RIGHT AWAY)
                pop     af
                ei                                      ; Enable interrupts
                ret

.dacqueued:
; If you get here, it's time to start a new DAC sound
                ld      a,80h
                ex      af,af'                          ; '
                ld      a,(zCurDAC)                     ; Get current DAC sound
                sub     81h                             ; Subtract 81h (first DAC index is 81h)
                ld      (zCurDAC),a                     ; Store that as current DAC sound
; The following two instructions are dangerous: they discard the upper
; two bits of zCurDAC, meaning you can only have 40h DAC samples
                add     a,a
                add     a,a                             ; a *= 4 (each DAC entry is a pointer and length, 2+2)
                add     a,zDACPtrTbl&0FFh               ; Get low byte into table -> 'a'
                ld      (zDACStartAddress+1),a          ; Store into the instruction after zDACStartAddress (self-modifying code)
                add     a,zDACLenTbl-zDACPtrTbl         ; How to offset to length versus pointer
                ld      (zDACStoreLength+2),a           ; Store into the instruction after zDACStoreLength (self-modifying code)
                pop     af
                ld      hl,zWriteToDAC
                ex      (sp),hl                         ; Jump to zWriteToDAC

; zloc_104
zDACStartAddress:
                ld      hl,(zDACPtrTbl)                 ; Self-modified code: sets start address of DAC sample for zWriteToDAC

; zloc_107
zDACStoreLength:
                ld      de,(zDACLenTbl)                 ; Self-modified code: sets length of DAC sample for zWriteToDAC

; zloc_10B
zDACStoreDelay:
                ld      bc,100h                         ; Self-modified code: From zDACDataStore; sets b=1 (the 100h part of it) UPDATE RIGHT AWAY and c="data rate delay" for this DAC sample, the future 'b' setting
                ei                                      ; Enable interrupts
                ret
; End of function zVInt

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Updates all tracks; queues notes and durations!

; zsub_110
zUpdateMusic:
; Calling this function here is bad, because it can cause the
; first note of a newly-started song to be delayed for a frame
; The vanilla driver resorts to a workaround to prevent such a
; delay from having side-effects, but it's better to just fix
; the problem directly, and move this call to the proper place
                call    TempoWait

; DAC updates
                ld      a,0FFh
                ld      (zAbsVar.DACUpdating),a         ; Store FFh to DACUpdating
                ld      ix,zTracksSongStart             ; Point "ix" to zTracksSongStart
                bit     7,(ix+zTrack.PlaybackControl)   ; Is bit 7 (80h) set on playback control byte? (means "is playing")
                call    nz,zDACUpdateTrack              ; If so, zDACUpdateTrack
                xor     a                               ; Clear a
                ld      (zAbsVar.DACUpdating),a         ; Store 0 to DACUpdating
                ld      b,MUSIC_FM_TRACK_COUNT          ; Loop 6 times (FM)

.fmloop:
                push    bc
                ld      de,zTrack.len                   ; Space between tracks
                add     ix,de                           ; Go to next track
                bit     7,(ix+zTrack.PlaybackControl)   ; Is bit 7 (80h) set on playback control byte? (means "is playing")
                call    nz,zFMUpdateTrack               ; If so
                pop     bc
                djnz    .fmloop

                ld      b,MUSIC_PSG_TRACK_COUNT         ; Loop 3 times (PSG)

.psgloop:
                push    bc
                ld      de,zTrack.len                   ; Space between tracks
                add     ix,de                           ; Go to next track
                bit     7,(ix+zTrack.PlaybackControl)   ; Is this track playing?
                call    nz,zPSGUpdateTrack              ; If so
                pop     bc
                djnz    .psgloop

; See above. Removing this instruction will cause this
; subroutine to fall-through to TempoWait
                ret
; End of function zUpdateMusic

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_14C
TempoWait:
; Tempo works as divisions of the 60Hz clock (there is a fix supplied for
; PAL that "kind of" keeps it on track.)  Every time the internal music clock
; overflows, it will update.  So a tempo of 80h will update every other
; frame, or 30 times a second

                ld      ix,zAbsVar                      ; ix points to zComRange
                ld      a,(ix+zVar.CurrentTempo)        ; tempo value
                add     a,(ix+zVar.TempoTimeout)        ; Adds previous value to
                ld      (ix+zVar.TempoTimeout),a        ; Store this as new
                ret     c                               ; If addition overflowed (answer greater than FFh), return

; So if adding tempo value did NOT overflow, then we add 1 to all durations
                ld      hl,zTracksSongStart+zTrack.DurationTimeout  ; Start at first track's delay counter (counting up to delay)
                ld      de,zTrack.len                   ; Offset between tracks
                ld      b,MUSIC_TRACK_COUNT             ; Loop for all tracks

.tempoloop:
                inc     (hl)                            ; Increasing delay tick counter to target
                add     hl,de                           ; Next track
                djnz    .tempoloop

                ret
; End of function TempoWait
