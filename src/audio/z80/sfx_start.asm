; ---------------------------------------------------------------------------
; zloc_942:
zPlaySound_CheckGloop:
                ld      a,c
                cp      SndID_Gloop                     ; Is this the bloop/gloop noise?
                jr      nz,zPlaySound_CheckSpindash     ; if not, jump
                ld      a,(zGloopFlag)
                cpl
                ld      (zGloopFlag),a
                or      a
                ret     z                               ; Sometimes don't play it
                jp      zPlaySound                      ; Now play the gloop sound
; ---------------------------------------------------------------------------
; zloc_953:
zPlaySound_CheckSpindash:
                ld      a,c
                cp      SndID_SpindashRev               ; is this the spindash rev sound playing?
                jr      nz,zPlaySound                   ; if not, jump

                ld      a,(zSpindashPlayingCounter)
                or      a
                ld      a,(zSpindashExtraFrequencyIndex)
                jr      nz,.incfreq                     ; if the spindash sound is already playing, jump
                ld      a,-1                            ; reset the extra frequency (becomes 0 on the next line)

.incfreq:
                inc     a                               ; increase the frequency
                cp      0Ch
                jr      nc,.maxfreq
                ld      (zSpindashExtraFrequencyIndex),a

.maxfreq:
                ld      a,3Ch
                ld      (zSpindashPlayingCounter),a
                ld      a,-1
                ld      (zSpindashActiveFlag),a

; zloc_975:
zPlaySound:
                bankswitch SoundIndex                   ; Switch to SFX banks

                ld      hl,zmake68kPtr(SoundIndex)      ; 'hl' points to beginning of SFX bank in ROM window
                ld      a,c                             ; 'c' -> 'a'
                sub     SndID__First                    ; Bring 'a' down to index value
                add     a,a                             ; Multiply it by 2
                ld      e,a
                ld      d,0                             ; de = a
                add     hl,de                           ; now hl points to a pointer in the SoundIndex list (such as rom_ptr_z80 Sound20)
                ld      a,(hl)
                inc     hl
                ld      h,(hl)
                ld      l,a                             ; now hl points to a sound's data (such as Sound20: ...)
                ld      e,(hl)
                inc     hl
                ld      d,(hl)                          ; 'de' points to custom voice table (if any; otherwise is 0000h)
                inc     hl
                ld      (.voiceptr+1),de                ; Store into the instruction after .voiceptr (self-modifying code)
                ld      c,(hl)                          ; Timing divisor -> 'c'
                inc     hl
                ld      b,(hl)                          ; Total channels used -> 'b'
                inc     hl

; zloc_99F
.sfx_loadloop:
                push    bc                              ; Backup divisor/channel usage
                xor     a                               ; a = 0 (will end up being NO CUSTOM VOICE TABLE!)
                ld      (.is_psg+1),a                   ; Store into the instruction after .bgmchannel (self-modifying code)
                push    hl                              ; Save current position within sound (offset 04h)
                inc     hl                              ; Next byte

                ld      a,(hl)                          ; Track sound def -> 'a' (if 80h set, it's PSG, otherwise it's FM) -- note this also tells what channel it's on (80, A0, C0 for PSG, FM channel assignments otherwise)
                or      a                               ; Test it
                jp      m,.sfxinitpsg                   ; If bit 7 (80h) set (meaning PSG track), skip next part
                sub     2                               ; Subtract 2 from this value
                add     a,a                             ; Multiply it by 2
                jp      .sfxinitfm                      ; This is an FM sound track

.sfxinitpsg:
; This is a PSG track!
; Always ends up writing zero to voice table pointer?
                ld      (.is_psg+1),a                   ; Store into the instruction after .bgmchannel (self-modifying code)
                cp      0C0h                            ; Is this PSG3?
                jr      nz,.getindex                    ; If not, skip this part
                push    af
                or      1Fh                             ; Set silence on PSG!
                ld      (zPSG),a
                xor     20h
                ld      (zPSG),a
                pop     af

.getindex:
                rra
                rra
                rra
                rra
                and     0Fh                             ; For PSG, just shift it down by 4 and we have its index!

; zloc_9CA
.sfxinitfm:
                add     a,zMusicTrackOffs&0FFh          ; Offset to corresponding music track
                ld      (.bgm_to_override+1),a          ; Store into the instruction after .bgm_to_override (self-modifying code)

; zloc_9CF
.bgm_to_override:
                ld      hl,(zMusicTrackOffs)            ; Self-modified code: 'hl' is now start of corresponding music track
                set     2,(hl)                          ; Set "SFX is overriding this track!" bit
                add     a,zSFXTrackOffs-zMusicTrackOffs  ; Jump to corresponding SFX track
                ld      (.bgm_to_sfx+2),a               ; Store into the instruction after .bgm_to_sfx (self-modifying code)

; zloc_9D9
.bgm_to_sfx:
                ld      ix,(zSFXTrackOffs)              ; 'ix' is now start of corresponding SFX track

; Little bit busy there, but basically for a given 'a' value, where a == 0
; means first SFX track (FM3), 'hl' now points to the music track and 'ix' points
; to the SFX track that both correspond to track 'a'

; Now we're going to clear this SFX track
                ld      e,ixl
                ld      d,ixu                           ; de = ix
                push    de                              ; Save 'de'
                ld      l,e                             ; hl = de (start of SFX track)
                ld      h,d
                ld      (hl),0                          ; Store 00h on first byte of track
                inc     de                              ; Next byte
                ld      bc,zTrack.len-1                 ; For all bytes in the track, minus 1 (since we're copying 00h from first byte)
                ldir                                    ; Clear track memory!
                pop     de                              ; Restore 'de' (start of SFX track yet again)
                pop     hl                              ; Get 'hl' back from way before (offset of sound in ROM + 04h)
; ld a,e
; add a,zTrack.PlaybackControl
; ld e,a
; adc a,d
; sub e
; ld d,a
                ldi                                     ; *de++ = *hl++ (write playback control byte) (... not really sure why this is used)
                ldi                                     ; *de++ = *hl++ (write voice control byte) (sets whether is PSG or what)
                pop     bc                              ; Restore 'bc'
                push    bc                              ; ...and back it up again!
                ld      (ix+zTrack.TempoDivider),c      ; Set timing divisor of SFX track
                ld      (ix+zTrack.DurationTimeout),1   ; Current duration timeout to 1 (will expire immediately and thus update)
                ld      (ix+zTrack.StackPointer),zTrack.GoSubStack  ; Reset track "gosub" stack
                ld      a,e
                add     a,zTrack.DataPointerLow-zTrack.TempoDivider
                ld      e,a
                adc     a,d
                sub     e
                ld      d,a                             ; de += 1 (skip timing divisor; already set)
                ldi                                     ; *de++ = *hl++ (track position low byte)
                ldi                                     ; *de++ = *hl++ (track position high byte)
                ldi                                     ; *de++ = *hl++ (key offset)

; If spindash active, the following block updates its frequency specially:
                ld      a,(zSpindashActiveFlag)
                or      a
                jr      z,.notspindash                  ; If spindash not last sound played, skip this
                ld      a,(zSpindashExtraFrequencyIndex)  ; Get current frequency index
                dec     de                              ; Go back to key offset
                ex      de,hl                           ; hl <=> de
                add     a,(hl)                          ; Add spindash key offset!
                ex      de,hl                           ; de <=> hl (just done because we wanted add a,(hl))
                ld      (de),a                          ; Store it!
                inc     de                              ; Go passed key offset again

.notspindash:
                ldi                                     ; *de++ = *hl++ (channel volume)

; zloc_A1D
.is_psg:                                                ; Modified way back within .sfx_loadloop
                ld      a,0                             ; Self-modified code
                or      a                               ; Test it
                jr      nz,.sfxpsginitdone              ; Jump, if this is a PSG track
; Do some more FM-related initialisation
                ld      (ix+zTrack.AMSFMSPan),0C0h      ; Default panning / AMS / FMS settings (just L/R Stereo enabled)

; zloc_A26
.voiceptr:
                ld      de,0                            ; Self-modified code: This will be modified to custom voice table address (possibly still 0000h)
                ld      (ix+zTrack.VoicePtrLow),e       ; Low byte of custom voice table (for SFX)
                ld      (ix+zTrack.VoicePtrHigh),d      ; High byte of custom voice table (for SFX)

.sfxpsginitdone:
                pop     bc                              ; Restore divisor (c) and channel counts (b0)
                dec     b                               ; One less FM channel
                jp      nz,.sfx_loadloop                ; If more to go, loop!

                jp      zBankSwitchToMusic              ; Otherwise, prepare to do music
; ---------------------------------------------------------------------------
; zloc_KillSFXPrio
zKillSFXPrio:
                xor     a
                ld      (zAbsVar.SFXPriorityVal),a      ; Reset SFX priority
                ret
; End of function zPlaySoundByIndex

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_A3C
zStopSoundEffects:
                xor     a
                ld      (zAbsVar.SFXPriorityVal),a      ; Reset SFX priority
                ld      ix,zTracksSFXStart              ; 'ix' points to start of SFX track memory (10 prior tracks were DAC, 6 FM, 3 PSG)
                ld      b,SFX_TRACK_COUNT               ; All 6 SFX tracks

; zloc_A46
.trackloop:
                push    bc                              ; Save 'bc'
                bit     7,(ix+zTrack.PlaybackControl)   ; Check if this track was playing
                jp      z,.nexttrack                    ; If not
                res     7,(ix+zTrack.PlaybackControl)   ; You're not playing anymore!
                res     4,(ix+zTrack.PlaybackControl)   ; Not not attacking, either
                ld      a,(ix+zTrack.VoiceControl)      ; Get "voice control" byte
                or      a                               ; Test it
                jp      m,.trackpsg                     ; If 80h set (PSG track) jump to .trackpsg
                push    af
                call    zFMNoteOff                      ; FM key off
                pop     af
                push    ix
                sub     2                               ; Determine proper corresponding music track (starting on FM3, so subtract 2 from channel assignment)
                add     a,a                             ; Multiply by 2 (each index 2 bytes)
                add     a,zMusicTrackOffs&0FFh          ; Get offset -> 'a'
                ld      (.fmpointer+2),a                ; Store into the instruction after .fmpointer (self-modifying code)

; zloc_A6C
.fmpointer:
                ld      ix,(zMusicTrackOffs)            ; Self-modified code: will load appropriate corresponding music track address
                bit     2,(ix+zTrack.PlaybackControl)   ; Was this music track is overridden by an SFX track?
                jr      z,.notoverridden                ; If not, do nothing
                res     2,(ix+zTrack.PlaybackControl)   ; Otherwise, tell it is is no longer!
                set     1,(ix+zTrack.PlaybackControl)   ; Set track to rest
                ld      a,(ix+zTrack.VoiceIndex)        ; Get current voice
                call    zSetVoiceMusic                  ; Reset FM voice

.notoverridden:
                pop     ix
                jp      .nexttrack                      ; Jump down to loop
; ---------------------------------------------------------------------------

; zloc_A89
.trackpsg:
                push    af
                call    zPSGNoteOff                     ; PSG Note off
                pop     af
                push    ix
                rra
                rra
                rra
                rra
                and     0Fh                             ; 'a' is now 08, 0A, 0C, or 0E
                add     a,zMusicTrackOffs&0FFh
                ld      (.psgpointer+2),a               ; Store into the instruction after .psgpointer (self-modifying code)

; zloc_A9B
.psgpointer:
                ld      ix,(zMusicTrackOffs)            ; Self-modified code from just above: 'ix' points to corresponding Music PSG track
                res     2,(ix+zTrack.PlaybackControl)   ; Tell this track it is is no longer overridden by SFX!
                set     1,(ix+zTrack.PlaybackControl)   ; Set track to rest
                ld      a,(ix+zTrack.VoiceControl)      ; Get voice control
                cp      0E0h                            ; Is this a PSG 3 noise (not tone) track?
                jr      nz,.nexttrackpop                ; If it isn't, don't do next part (non-PSG Noise doesn't restore)
                ld      a,(ix+zTrack.PSGNoise)          ; Get PSG noise setting
                ld      (zPSG),a                        ; Write it to PSG

.nexttrackpop:
                pop     ix

; zloc_AB6
.nexttrack:
                ld      de,zTrack.len
                add     ix,de                           ; Got to next track
                pop     bc                              ; Restore 'bc'
                djnz    .trackloop                      ; Loop around
                ret
; End of function zStopSoundEffects
