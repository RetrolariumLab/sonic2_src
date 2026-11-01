; ---------------------------------------------------------------------------
zDACUpdateTrack:
                dec     (ix+zTrack.DurationTimeout)
                ret     nz
                ld      l,(ix+zTrack.DataPointerLow)
                ld      h,(ix+zTrack.DataPointerHigh)

.sampleloop:
                ld      a,(hl)                          ; Get next byte from DAC Track
                inc     hl                              ; Move to next position
                cp      0E0h                            ; Check if is coordination flag
                jr      c,.notcoord                     ; Not coord flag?  Skip ahead
                call    zCoordFlag                      ; Handle coordination flag
                jp      .sampleloop                     ; Loop back around

.notcoord:
                or      a                               ; Test 'a' for 80h not set, which is a note duration
                jp      p,.gotduration                  ; If note duration, jump ahead (note that "hl" is already incremented)
                ld      (ix+zTrack.SavedDAC),a          ; This is a note; store it here
                ld      a,(hl)                          ; Get next byte
                or      a                               ; Test 'a' for 80h not set, which is a note duration
                jp      p,.repeatduration               ; Is this a duration this time??  If so, jump ahead (only difference is to increment "hl")
; Note followed by a note... apparently recycles the previous duration
                ld      a,(ix+zTrack.SavedDuration)     ; Current DAC note ticker goal value -> 'a'
                ld      (ix+zTrack.DurationTimeout),a   ; Use it again
                jr      zDACAfterDur                    ; Jump to after duration subroutine
; ---------------------------------------------------------------------------

; zloc_20D
.repeatduration:
                inc     hl                              ; Goes to next byte (after duration byte)

; zloc_20E
.gotduration:
                call    zSetDuration

; zloc_211
zDACAfterDur:
                ld      (ix+zTrack.DataPointerLow),l    ; Stores "hl" to the DAC track pointer memory
                ld      (ix+zTrack.DataPointerHigh),h
                bit     2,(ix+zTrack.PlaybackControl)   ; Is SFX overriding this track?
                ret     nz                              ; If so, we're done
                ld      a,(ix+zTrack.SavedDAC)          ; Check next note to play
                cp      80h                             ; Is it a rest?
                ret     z                               ; If so, quit
                sub     81h                             ; Otherwise, transform note into an index... (we're selecting which drum to play!)
                add     a,a                             ; Multiply by 2
                add     a,zDACMasterPlaylist&0FFh       ; Offset into list
                ld      (zDACDataStore+2),a             ; store into the following instruction (self-modifying code)

; zloc_22A
zDACDataStore:
                ld      bc,(zDACMasterPlaylist)         ; Load appropriate drum info -> bc
                ld      a,c                             ; DAC sample number (81h base) -> 'a'
                ld      (zCurDAC),a                     ; Store current DAC sound to play
                ld      a,b                             ; Data rate delay -> 'b'
                ld      (zDACStoreDelay+1),a            ; store into the instruction after zDACStoreDelay (self-modifying code)
                ret

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_237
zFMUpdateTrack:
                dec     (ix+zTrack.DurationTimeout)     ; Decrement duration
                jr      nz,.notegoing                   ; If not time-out yet, go do updates only
                res     4,(ix+zTrack.PlaybackControl)   ; When duration over, clear "do not attack" bit 4 (0x10) of track's play control
                call    zFMDoNext                       ; Handle coordination flags, get next note and duration
                call    zFMPrepareNote                  ; Prepares to play next note
                call    zFMNoteOn                       ; Actually key it (if allowed)
                call    zDoModulation                   ; Update modulation (if modulation doesn't change, we do not return here)
                jp      zFMUpdateFreq                   ; Applies frequency update from modulation

.notegoing:
                call    zNoteFillUpdate                 ; Applies "note fill" (time until cut-off); NOTE: Will not return here if "note fill" expires
                call    zDoModulation                   ; Update modulation (if modulation doesn't change, we do not return here)
                jp      zFMUpdateFreq                   ; Applies frequency update from modulation
; End of function zFMUpdateTrack

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_258
zFMDoNext:
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
                push    af
                call    zFMNoteOff                      ; Send key off
                pop     af
                or      a                               ; Test 'a' for 80h not set, which is a note duration
                jp      p,.gotduration                  ; If duration, jump to .gotduration
                call    zFMSetFreq                      ; Otherwise, this is a note; call zFMSetFreq
                ld      a,(hl)                          ; Get next byte
                or      a                               ; Test 'a' for 80h set, which is a note
                jp      m,zFinishTrackUpdate            ; If this is a note, jump to zFinishTrackUpdate
                inc     hl                              ; Otherwise, go to next byte; a duration

.gotduration:
                call    zSetDuration
                jp      zFinishTrackUpdate              ; Either way, jumping to zFinishTrackUpdate
; End of function zFMDoNext

; ---------------------------------------------------------------------------
; zloc_285 zGetFrequency
zFMSetFreq:
; 'a' holds a note to get frequency for
                sub     80h
                jr      z,zFMDoRest                     ; If this is a rest, jump to zFMDoRest
                add     a,(ix+zTrack.Transpose)         ; Add current channel transpose (coord flag E9)
                add     a,a                             ; Offset into Frequency table
                add     a,zFrequencies&0FFh
                ld      (.storefreq+2),a                ; Store into the instruction after .storefreq (self-modifying code)
; ld d,a
; adc a,(zFrequencies&0FF00h)>>8
; sub d
; ld (.storefreq+3),a  ; This is how you could store the high byte of the pointer too (unnecessary if it's in the right range)

; zloc_292
.storefreq:
                ld      de,(zFrequencies)               ; Stores frequency into "de"
                ld      (ix+zTrack.FreqLow),e           ; Frequency low byte   -> trackPtr + 0Dh
                ld      (ix+zTrack.FreqHigh),d          ; Frequency high byte  -> trackPtr + 0Eh
                ret
; ---------------------------------------------------------------------------

; zloc_29D
zFMDoRest:
                set     1,(ix+zTrack.PlaybackControl)   ; Set bit 1 (track is at rest)
                xor     a                               ; Clear 'a'
                ld      (ix+zTrack.FreqLow),a           ; Zero out FM Frequency
                ld      (ix+zTrack.FreqHigh),a          ; Zero out FM Frequency
                ret

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_2A9
zSetDuration:
                ld      c,a                             ; 'a' = current duration
                ld      b,(ix+zTrack.TempoDivider)      ; Divisor; causes multiplication of duration for every number higher than 1

.multloop:
                djnz    .multloop_outer
                ld      (ix+zTrack.SavedDuration),a     ; Store new duration into ticker goal of this track (this is reused if a note follows a note without a new duration)
                ld      (ix+zTrack.DurationTimeout),a   ; Sets it on ticker (counts to zero)
                ret

.multloop_outer:
                add     a,c                             ; Will multiply duration based on 'b'
                jp      .multloop
; End of function zSetDuration

; ---------------------------------------------------------------------------

; zloc_2BA
zFinishTrackUpdate:
; Common finish-up routine used by FM or PSG
                ld      (ix+zTrack.DataPointerLow),l    ; Stores "hl" to the track pointer memory
                ld      (ix+zTrack.DataPointerHigh),h
                ld      a,(ix+zTrack.SavedDuration)     ; Last set duration
                ld      (ix+zTrack.DurationTimeout),a   ; ... put into ticker
                bit     4,(ix+zTrack.PlaybackControl)   ; Is bit 4 (10h) "do not attack next note" set on playback?
                ret     nz                              ; If so, quit
                ld      a,(ix+zTrack.NoteFillMaster)    ; Master "note fill" value -> a
                ld      (ix+zTrack.NoteFillTimeout),a   ; Reset 0Fh "note fill" value to master
                ld      (ix+zTrack.VolFlutter),0        ; Reset PSG flutter byte
                bit     3,(ix+zTrack.PlaybackControl)   ; is modulation turned on?
                ret     z                               ; if not, quit
                ld      l,(ix+zTrack.ModulationPtrLow)  ; Otherwise, get address of modulation setting
                ld      h,(ix+zTrack.ModulationPtrHigh)
                jp      zSetModulation                  ; ... and go do it!

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_2E3
zNoteFillUpdate:
                ld      a,(ix+zTrack.NoteFillTimeout)   ; Get current note fill value
                or      a
                ret     z                               ; If zero, return!
                dec     (ix+zTrack.NoteFillTimeout)     ; Decrement note fill
                ret     nz                              ; If not zero, return
                set     1,(ix+zTrack.PlaybackControl)   ; Set bit 1 (track is at rest)
                pop     de                              ; return address -> 'de' (will not return to zUpdateTrack function!!)
                bit     7,(ix+zTrack.VoiceControl)      ; Is this a PSG track?
                jp      nz,zPSGNoteOff                  ; If so, jump to zPSGNoteOff
                jp      zFMNoteOff                      ; Else, jump to zFMNoteOff
; End of function zNoteFillUpdate

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_2FB
zDoModulation:
                pop     de                              ; keep return address -> de (MAY not return to caller)

                bit     1,(ix+zTrack.PlaybackControl)   ; Is "track in rest"?
                ret     nz                              ; If so, quit
                bit     3,(ix+zTrack.PlaybackControl)   ; Is modulation on?
                ret     z                               ; If not, quit
                ld      a,(ix+zTrack.ModulationWait)    ; 'ww' period of time before modulation starts
                or      a
                jr      z,.waitdone                     ; if zero, go to it!
                dec     (ix+zTrack.ModulationWait)      ; Otherwise, decrement timer
                ret                                     ; return if decremented (does NOT return to zUpdateTrack!!)

.waitdone:
                dec     (ix+zTrack.ModulationSpeed)     ; Decrement modulation speed counter
                ret     nz                              ; Return if not yet zero
                ld      l,(ix+zTrack.ModulationPtrLow)
                ld      h,(ix+zTrack.ModulationPtrHigh)  ; 'hl' points to modulation setting
                inc     hl                              ; skip passed 'ww' period of time
                ld      a,(hl)                          ; Get modulation speed
                ld      (ix+zTrack.ModulationSpeed),a   ; Restore speed counter
                ld      a,(ix+zTrack.ModulationSteps)   ; Get number of steps in modulation
                or      a
                jr      nz,.calcfreq                    ; If not zero, skip to .calcfreq

; If steps have reached zero
                inc     hl                              ; passed mod speed
                inc     hl                              ; passed mod change per mod step
                ld      a,(hl)                          ; get number of steps in modulation
                ld      (ix+zTrack.ModulationSteps),a   ; restore modulation steps
                ld      a,(ix+zTrack.ModulationDelta)   ; get modulation change per mod step
                neg                                     ; flip it negative
                ld      (ix+zTrack.ModulationDelta),a   ; store negated value
                ret

.calcfreq:
                dec     (ix+zTrack.ModulationSteps)     ; Decrement the step
                ld      l,(ix+zTrack.ModulationValLow)
                ld      h,(ix+zTrack.ModulationValHigh)  ; Get 16-bit modulation value

; This is a 16-bit sign extension for 'bc'
                ld      b,0
                ld      c,(ix+zTrack.ModulationDelta)   ; Get current modulation change per step -> 'c'
                bit     7,c
                jp      z,.nosignextend
                ld      b,0FFh                          ; Sign extend if negative

.nosignextend:
                add     hl,bc                           ; Add to current modulation value
                ld      (ix+zTrack.ModulationValLow),l
                ld      (ix+zTrack.ModulationValHigh),h  ; Store new 16-bit modulation value
                ld      c,(ix+zTrack.FreqLow)           ; frequency low byte -> c
                ld      b,(ix+zTrack.FreqHigh)          ; frequency high byte -> b
                add     hl,bc                           ; Add modulation value
                ex      de,hl
                jp      (hl)                            ; WILL return to zUpdateTrack
; End of function zDoModulation

; ---------------------------------------------------------------------------
zMakePSGFrequency       function frequency,min(3FFh,roundFloatToInteger(PSG_Sample_Rate/(frequency*2)))
zMakePSGFrequencies     macro
                    irp     op,ALLARGS
                    dw      zMakePSGFrequency(op)
                endm
                endm

; This the note -> frequency setting lookup
; the same array is found at $729CE in Sonic 1, and at $C9C44 in Ristar
; zword_359:
                ensure1byteoffset 8Ch
zPSGFrequencies:
; 6 octaves, each one begins with C and ends with B, with
; the exception of the final octave, which ends at A-flat
; The last octave's final note is set to the PSG's maximum
; frequency. This is typically used by the noise channel to
; create a sound that is similar to a hi-hat
                zMakePSGFrequencies 130.98,    138.78,    146.99,    155.79,    165.22,    174.78,    185.19,    196.24,    207.91,    220.63,    233.52,    247.47
                zMakePSGFrequencies 261.96,    277.56,    293.59,    311.58,    329.97,    349.56,    370.39,    392.49,    415.83,    440.39,    468.03,    494.95
                zMakePSGFrequencies 522.71,    556.51,    588.73,    621.44,    661.89,    699.12,    740.79,    782.24,    828.59,    880.79,    932.17,    989.91
                zMakePSGFrequencies 1045.42,   1107.52,   1177.47,   1242.89,   1316.00,   1398.25,   1491.47,   1575.50,   1669.55,   1747.82,   1864.34,   1962.46
                zMakePSGFrequencies 2071.49,   2193.34,   2330.42,   2485.78,   2601.40,   2796.51,   2943.69,   3107.23,   3290.01,   3495.64,   3608.40,   3857.25
                zMakePSGFrequencies 4142.98,   4302.32,   4660.85,   4863.50,   5084.56,   5326.69,   5887.39,   6214.47,   6580.02, 223721.56
