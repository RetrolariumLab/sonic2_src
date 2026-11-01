; ---------------------------------------------------------------------------
; zloc_ABF
zFadeOutMusic:
                ld      a,3
                ld      (zAbsVar.FadeOutDelay),a        ; Set delay ticker to 3
                ld      a,28h
                ld      (zAbsVar.FadeOutCounter),a      ; Set total frames to decrease volume over
                xor     a
                ld      (zSongDAC.PlaybackControl),a    ; Stop DAC track (can't fade it)
                ld      (zAbsVar.SpeedUpFlag),a         ; No speed shoe tempo?
                ret

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_AD1
zUpdateFadeout:
                ld      a,(zAbsVar.FadeOutDelay)        ; Get current tick count before next volume decrease
                or      a
                jr      z,.continuefade                 ; If not yet zero
                dec     (ix+zVar.FadeOutDelay)          ; Just decrement it
                ret

.continuefade:
                dec     (ix+zVar.FadeOutCounter)        ; Otherwise, decrement fadeout!
                jp      z,zClearTrackPlaybackMem        ; If it hits zero, clear everything!
                ld      (ix+zVar.FadeOutDelay),3        ; Otherwise, reload tick count with 3
                push    ix
                ld      ix,zSongFMStart                 ; 'ix' points to first FM music track
                ld      b,MUSIC_FM_TRACK_COUNT          ; 6 FM tracks to follow

; zloc_AED
.fmloop:
                bit     7,(ix+zTrack.PlaybackControl)   ; Is this track playing?
                jr      z,.nextfm                       ; If not, do nothing
                inc     (ix+zTrack.Volume)              ; Increment channel volume (remember -- higher is quieter!)
                jp      p,.sendfmtl                     ; Don't let it overflow
                res     7,(ix+zTrack.PlaybackControl)   ; Otherwise, stop playing this track
                jr      .nextfm                         ; Just loop

.sendfmtl:
                push    bc
                call    zSetChanVol                     ; We need to update volume
                pop     bc

; zloc_B04
.nextfm:
                ld      de,zTrack.len
                add     ix,de                           ; Next track
                djnz    .fmloop                         ; Keep going for all FM tracks
                ld      b,MUSIC_PSG_TRACK_COUNT         ; 3 PSG tracks to follow

; zloc_B0D
.psgloop:
                bit     7,(ix+zTrack.PlaybackControl)   ; Is this track playing?
                jr      z,.nextpsg                      ; If not, do nothing
                inc     (ix+zTrack.Volume)              ; increment channel volume (remember -- higher is quieter!)
                ld      a,10h
                cp      (ix+zTrack.Volume)              ; Don't let volume go over 0Fh on PSG tracks!
                jp      nc,.sendpsgvol
                res     7,(ix+zTrack.PlaybackControl)   ; Otherwise, stop playing this track
                jr      .nextpsg

.sendpsgvol:
                push    bc
                ld      b,(ix+zTrack.Volume)            ; Channel volume -> 'b'
; DANGER! This code ignores volume envelopes, breaking fade on envelope-using tracks
; (It's also a part of the envelope-processing code, so calling it here is redundant)
; This is only useful for envelope 0 (no envelope)
                call    zPSGUpdateVol                   ; Update volume (ignores current envelope!!!)
                pop     bc

; zloc_B2C
.nextpsg:
                ld      de,zTrack.len
                add     ix,de                           ; Next track
                djnz    .psgloop                        ; Keep going for all PSG tracks
                pop     ix
                ret
; End of function zUpdateFadeout

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_B36
zFMSilenceAll:
                ld      a,28h                           ; Start at FM KEY ON/OFF register
                ld      b,3                             ; Three key on/off per part

.noteoffloop:
                ld      c,b                             ; Current key off -> 'c
                dec     c                               ; c--
                rst     zWriteFMI                       ; Write key off for part I
                set     2,c                             ; Set part II select
                rst     zWriteFMI                       ; Write key off for part II
                djnz    .noteoffloop

                ld      a,30h                           ; Starting at FM register 30h
                ld      c,0FFh                          ; Write dummy kill-all values
                ld      b,60h                           ; ...up to register 90h

.channelloop:
                rst     zWriteFMI                       ; ...on part I
                rst     zWriteFMII                      ; ...and part II
                inc     a                               ; Next register!
                djnz    .channelloop

                ret
; End of function zFMSilenceAll

; ---------------------------------------------------------------------------
; zloc_B4E
zStopSoundAndMusic:
                xor     a
                ld      (zAbsVar.StopMusic),a

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_B52
zClearTrackPlaybackMem:
; This totally wipes out the track memory and resets playback hardware
                ld      a,2Bh                           ; DAC Enable register
                ld      c,80h                           ; Enable DAC
                rst     zWriteFMI                       ; Write it!
                ld      a,c                             ; 80h -> 'a'
                ld      (zAbsVar.DACEnabled),a          ; Store that to DAC Enabled byte
                ld      a,27h                           ; Channel 3 special settings
                ld      c,0                             ; All clear
                rst     zWriteFMI                       ; Write it!
; This performs a full clear across all track/playback memory
                ld      hl,zAbsVar
                ld      de,zAbsVar+1
                ld      (hl),0                          ; Starting byte is 00h
                ld      bc,(zTracksSFXEnd-zAbsVar)-1    ; For 695 bytes
                ldir                                    ; 695 bytes of clearing! (Because it will keep copying the byte prior to the byte after; thus 00h repeatedly)
                ld      a,80h
                ld      (zAbsVar.QueueToPlay),a         ; Nothing is queued
                call    zFMSilenceAll                   ; Silence FM
                jp      zPSGSilenceAll                  ; Silence PSG
; End of function zClearTrackPlaybackMem

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_B78
zInitMusicPlayback:
; This function saves some of the queue/flag items and
; otherwise resets all music-related playback memory and
; silences the hardware.  Used prior to playing a new song
; Very similar to zClearTrackPlaybackMem except that it is
; specific to the music tracks

; Save some queues/flags:
                ld      ix,zAbsVar
                ld      b,(ix+zVar.SFXPriorityVal)
                ld      c,(ix+zVar.1upPlaying)          ; 1-up playing flag
                push    bc
                ld      b,(ix+zVar.SpeedUpFlag)         ; Speed shoe flag
                ld      c,(ix+zVar.FadeInCounter)       ; Fade in frames
                push    bc
                ld      b,(ix+zVar.Queue0)
                ld      c,(ix+zVar.Queue1)
                push    bc
; The following clears all playback memory and non-SFX tracks
                ld      hl,zAbsVar
                ld      de,zAbsVar+1
                ld      (hl),0
                ld      bc,(zTracksSongEnd-zAbsVar)-1   ; This many bytes (from start of zComRange to just short of end of PSG3 music track)
                ldir
; Restore those queue/flags:
                pop     bc
                ld      (ix+zVar.Queue0),b
                ld      (ix+zVar.Queue1),c
                pop     bc
                ld      (ix+zVar.SpeedUpFlag),b         ; Speed shoe flag
                ld      (ix+zVar.FadeInCounter),c       ; Fade in frames
                pop     bc
                ld      (ix+zVar.SFXPriorityVal),b
                ld      (ix+zVar.1upPlaying),c          ; 1-up playing flag
                ld      a,80h
                ld      (zAbsVar.QueueToPlay),a

; This silences all channels, even those being used by SFX!
; zSFXFinishSetup does the same thing, only better (it doesn't affect SFX channels)
                call    zFMSilenceAll
                jp      zPSGSilenceAll
; End of function zInitMusicPlayback

; ---------------------------------------------------------------------------
; zloc_BBE
; increases the tempo of the music
zSpeedUpMusic:
                ld      b,80h
                ld      a,(zAbsVar.1upPlaying)
                or      a
                ld      a,(zAbsVar.TempoTurbo)
                jr      z,zSetTempo
                jr      zSetTempo_1up

; ===========================================================================
; zloc_BCB
; returns the music tempo to normal
zSlowDownMusic:
                ld      b,0
                ld      a,(zAbsVar.1upPlaying)
                or      a
                ld      a,(zAbsVar.TempoMod)
                jr      z,zSetTempo
                jr      zSetTempo_1up

; ===========================================================================
; helper routines for changing the tempo
zSetTempo:
                ld      (zAbsVar.CurrentTempo),a        ; Store new tempo value
                ld      a,b
                ld      (zAbsVar.SpeedUpFlag),a
                ret
; ---------------------------------------------------------------------------
; zloc_BE0
zSetTempo_1up:
                ld      (zSaveVar.CurrentTempo),a       ; Store new tempo value
                ld      a,b
                ld      (zSaveVar.SpeedUpFlag),a
                ret

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_BE8
zUpdateFadeIn:
                ld      a,(zAbsVar.FadeInDelay)         ; Get current tick count before next volume increase
                or      a
                jr      z,.continuefade                 ; If not yet zero
                dec     (ix+zVar.FadeInDelay)           ; Just decrement it
                ret

.continuefade:
                ld      a,(zAbsVar.FadeInCounter)       ; Get current fade out frame count
                or      a
                jr      nz,.fadenotdone                 ; If fadeout hasn't reached zero yet, skip this
                ld      a,(zSongDAC.PlaybackControl)    ; Get DAC's playback control byte
                and     0FBh                            ; Clear "SFX is overriding" bit
                ld      (zSongDAC.PlaybackControl),a    ; Set that
                xor     a
                ld      (zAbsVar.FadeInFlag),a          ; Done fading-in, SFX can play now
                ret

.fadenotdone:
                dec     (ix+zVar.FadeInCounter)         ; Otherwise, we decrement fadein!
                ld      (ix+zVar.FadeInDelay),2         ; Otherwise, reload tick count with 2 (little faster than fadeout)
                push    ix
                ld      ix,zSongFMStart                 ; 'ix' points to first FM music track
                ld      b,MUSIC_FM_TRACK_COUNT          ; 6 FM tracks to follow

.fmloop:
                bit     7,(ix+zTrack.PlaybackControl)   ; Is this track playing?
                jr      z,.nextfm                       ; If not, do nothing
                dec     (ix+zTrack.Volume)              ; Decrement channel volume (remember -- lower is louder!)
                push    bc
                call    zSetChanVol                     ; We need to update volume
                pop     bc

.nextfm:
                ld      de,zTrack.len
                add     ix,de                           ; Next track
                djnz    .fmloop                         ; Keep going for all FM tracks

                ld      b,MUSIC_PSG_TRACK_COUNT         ; 3 PSG tracks to follow

.psgloop:
                bit     7,(ix+zTrack.PlaybackControl)   ; Is this track playing?
                jr      z,.nextpsg                      ; If not, do nothing
                dec     (ix+zTrack.Volume)              ; Decrement channel volume (remember -- lower is louder!)
                push    bc
                ld      b,(ix+zTrack.Volume)            ; Channel volume -> 'b'
; DANGER! This code ignores volume envelopes, breaking fade on envelope-using tracks
; (It's also a part of the envelope-processing code, so calling it here is redundant)
; This is only useful for envelope 0 (no envelope)
                call    zPSGUpdateVol                   ; Update volume (ignores current envelope!!!)
                pop     bc

.nextpsg:
                ld      de,zTrack.len
                add     ix,de                           ; Next track
                djnz    .psgloop                        ; Keep going for all PSG tracks

                pop     ix
                ret
; End of function zUpdateFadeIn

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_C46
zFMNoteOn:
                ld      a,(ix+zTrack.PlaybackControl)   ; Get playback control byte
                and     6
                ret     nz                              ; If either bit 1 ("track in rest") and 2 ("SFX overriding this track"), quit!
                ld      a,(ix+zTrack.VoiceControl)      ; Get "voice control" byte
                or      0F0h                            ; Turn on ALL operators
                ld      c,a                             ; Set as data to write to FM
                ld      a,28h                           ; Write to KEY ON/OFF port (key ON in this case)
                rst     zWriteFMI                       ; Do it!
                ret
; End of function zFMNoteOn

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_C56
zFMNoteOff:
                ld      a,(ix+zTrack.PlaybackControl)   ; Load this track's playback control byte
                and     14h                             ; Are bits 4 (no attack) or 2 (SFX overriding) set?
                ret     nz                              ; If they are, return
                ld      a,28h                           ; Otherwise, send a KEY ON/OFF
                ld      c,(ix+zTrack.VoiceControl)      ; Track's data for this key operation

; Format of key on/off:
; 4321 .ccc
; Where 4321 are the bits for which operator,
; and ccc is which channel (0-2 for channels 1-3, 4-6 for channels 4-6 WATCH BIT GAP)

                rst     zWriteFMI                       ; Write to part I (note this particular register is ALWAYS sent to part I)
                ret
; End of function zFMNoteOff

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Performs a bank switch to where the music for the current track is at
; (there are two possible bank locations for music)

; zsub_C63:
zBankSwitchToMusic:
                ld      a,(zAbsVar.MusicBankNumber)
                or      a
                jr      nz,zSwitchToBank2

                bankswitch MusicPoint1
                ret

zSwitchToBank2:
                bankswitch MusicPoint2
                ret
; End of function zBankSwitchToMusic
