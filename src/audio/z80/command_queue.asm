; ---------------------------------------------------------------------------
zQueueNext:
                djnz    zInputLoop
                ret
; ---------------------------------------------------------------------------
zQueueItem:
                ld      a,e                             ; restore a to be the last queue item read
                ld      (zAbsVar.QueueToPlay),a         ; Put it as the next item to play
                ret
; End of function zCycleQueue

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; zsub_6B2
zPlaySoundByIndex:
                or      a                               ; is it sound 00?
                jp      z,zClearTrackPlaybackMem        ; if yes, jump to RESET EVERYTHING!!
                if      MusID__First-1 = 80h
                ret     p                               ; return if it was (invalidates 00h-7Fh; maybe we don't want that someday?)
                else
                cp      MusID__First
                ret     c                               ; return if id is less than the first music id
                endif

                ld      (ix+zVar.QueueToPlay),80h       ; Rewrite zComRange+8 flag so we know nothing new is coming in
                cp      MusID__End                      ; is it music (less than index 20)?
                jp      c,zPlayMusic                    ; if yes, play it
                cp      SndID__First                    ; is it not a sound effect? (this check is redundant if MusID__End == SndID__First...)
                ret     c                               ; if not, return (do nothing)
                cp      SndID__End                      ; is it a sound effect (less than index 71)?
                jp      c,zPlaySound_CheckRing          ; if yes, play it
                cp      CmdID__First                    ; is it after the last regular sound but before the first special sound command (between 71 and 78)?
                ret     c                               ; if yes, return (do nothing)
                cp      MusID_Pause                     ; is it sound 7E or 7F (pause all or resume all)
                ret     nc                              ; if yes, return (those get handled elsewhere)
; Otherwise, this is a special command to the music engine
                sub     CmdID__First                    ; convert index 78-7D to a lookup into the following jump table
                add     a,a
                add     a,a
                ld      (.commandjump+1),a              ; store into the following instruction (self-modifying code)

; zloc_6D5
.commandjump:
                jr      $
; ---------------------------------------------------------------------------
zCommandIndex:

CmdPtr_StopSFX: jp      zStopSoundEffects               ; sound test index 78
                db      0
CmdPtr_FadeOut: jp      zFadeOutMusic                   ; 79
                db      0
CmdPtr_SegaSound:   jp      zPlaySegaSound              ; 7A
                db      0
CmdPtr_SpeedUp: jp      zSpeedUpMusic                   ; 7B
                db      0
CmdPtr_SlowDown:    jp      zSlowDownMusic              ; 7C
                db      0
CmdPtr_Stop:    jp      zStopSoundAndMusic              ; 7D
                db      0
CmdPtr__End:
; ---------------------------------------------------------------------------
; zloc_6EF
zPlaySegaSound:
.loop_counter   =       pcmLoopCounter(Snd_Sega.sample_rate)

                ld      a,2Bh                           ; DAC enable/disable register
                ld      c,80h                           ; Command to enable DAC
                rst     zWriteFMI

                bankswitch Snd_Sega                     ; We want the Sega sound

                ld      hl,zmake68kPtr(Snd_Sega)        ; was: 9E8Ch
                ld      de,Snd_Sega.size/2              ; was: 30BAh
                ld      a,2Ah                           ; DAC data register
                ld      (zYM2612_A0),a                  ; Select it
                ld      c,80h                           ; If QueueToPlay is not this, stops Sega PCM

.loop:
; According to Kabuto, the Z80 suffers a delay of approximately 3.3 cycles for each ROM access
; https://plutiedev.com/mirror/kabuto-hardware-notes#bus-system
                ld      a,(hl)                          ; 7+3 ; Get next PCM byte
                ld      (zYM2612_D0),a                  ; 13 ; Send to DAC
                inc     hl                              ; 6 ; Advance pointer
                nop                                     ; 4
                ld      b,.loop_counter                 ; 7 ; Sega PCM pitch
                djnz    $                               ; 8 ; Delay loop

                nop                                     ; 4
                ld      a,(zAbsVar.QueueToPlay)         ; 13 ; Get next item to play
                cp      c                               ; 4 ; Is it 80h?
                jr      nz,.stop                        ; 7 ; If not, stop Sega PCM
                ld      a,(hl)                          ; 7+3 ; Get next PCM byte
                ld      (zYM2612_D0),a                  ; 13 ; Send to DAC
                inc     hl                              ; 6 ; Advance pointer
                nop                                     ; 4
                ld      b,.loop_counter                 ; 7 ; Sega PCM pitch
                djnz    $                               ; 8 ; Delay loop

                nop                                     ; 4
                dec     de                              ; 6 ; 2 less bytes to play
                ld      a,d                             ; 4 ; a = d
                or      e                               ; 4 ; Is de zero?
                jp      nz,.loop                        ; 10 ; If not, loop
        ; 152
; Two samples per 152 cycles, meaning that pcmLoopCounter should used 152 divided by 2

.stop:
                call    zBankSwitchToMusic
                ld      a,(zAbsVar.DACEnabled)          ; DAC status
                ld      c,a                             ; c = DAC status
                ld      a,2Bh                           ; DAC enable/disable register
                rst     zWriteFMI
                ret
