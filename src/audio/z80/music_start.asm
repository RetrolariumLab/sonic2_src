; ---------------------------------------------------------------------------
; zloc_73D
zPlayMusic:
; This is a workaround for a bug, where playing a new song will distort any SFX that were already playing
                push    af
                call    zStopSoundEffects               ; Stop all sounds before starting BGM
                pop     af
                ld      (zCurSong),a                    ; Get current BGM
                cp      MusID_ExtraLife                 ; If NOT 1-up sound
                jr      nz,.bgmnot1up                   ; ...skip over the following code
; The following code disables all sound (technically for duration of 1-up)
                ld      a,(zAbsVar.1upPlaying)          ; Check if 1-up sound is already playing
                or      a                               ; Test it
                jr      nz,zBGMLoad                     ; If it is, then just reload it! Otherwise, the track would play over and over again
                ld      ix,zTracksSongStart             ; Starting at beginning of all tracks
                ld      de,zTrack.len                   ; Each track size
                ld      b,MUSIC_TRACK_COUNT             ; All 10 (DAC, 6FM, 3PSG) tracks

.clearsfxloop:
                res     2,(ix+zTrack.PlaybackControl)   ; Clear "SFX is overriding" bit (no SFX are allowed!)
                add     ix,de                           ; Next track
                djnz    .clearsfxloop

                ld      ix,zTracksSFXStart              ; 'ix' points to start of SFX track memory (10 prior tracks were DAC, 6 FM, 3 PSG)
                ld      b,SFX_TRACK_COUNT               ; 6 SFX tracks total (3FM, 3PSG)

.cleartrackplayloop:
                res     7,(ix+zTrack.PlaybackControl)   ; Clear "is playing" bit!  (No SFX allowed!)
                add     ix,de                           ; Next track
                djnz    .cleartrackplayloop

; This performs a "massive" backup of all of the current track positions
; for restoration after 1-up BGM completes
                ld      de,zTracksSaveStart             ; Backup memory address
                ld      hl,zAbsVar                      ; Starts from zComRange
                ld      bc,zTracksSaveEnd-zTracksSaveStart  ; for this many bytes
                ldir                                    ; Go!

                ld      a,80h
                ld      (zAbsVar.1upPlaying),a          ; Set 1-up song playing flag

; This is done in the wrong place: it should have been done before
; the variables are backed-up. Because of this, SFXPriorityVal will
; be set back to a non-zero value when the 1-up jingle is over,
; preventing lower-priority sounds from being able to play until a
; high-priority sound is played
                xor     a
                ld      (zAbsVar.SFXPriorityVal),a      ; Clears SFX priority

                jr      zBGMLoad                        ; Now load 1-up BGM
; ---------------------------------------------------------------------------

; zloc_784
.bgmnot1up:
                xor     a
                ld      (zAbsVar.1upPlaying),a          ; clear 1-up is playing flag (it isn't)
                ld      (zAbsVar.FadeInCounter),a       ; clear fade-in frame count
; zInitMusicPlayback already does this
                ld      (zAbsVar.FadeOutCounter),a      ; clear fade-out frame count

; zloc_78E
zBGMLoad:
                call    zInitMusicPlayback
                ld      a,(zCurSong)                    ; So, let's take your desired song, put it into 'a'
                sub     MusID__First                    ; Make it a zero-based entry
                ld      e,a                             ; Transform 'a' into 16-bit de
                ld      d,0
                ld      hl,zSpedUpTempoTable            ; Load 'hl' of "sped up" tempos [I think]
                add     hl,de                           ; Offset by 16-bit version of song index to proper tempo
                ld      a,(hl)                          ; Get value at this location -> 'a'
                ld      (zAbsVar.TempoTurbo),a          ; Store 'a' here (provides an alternate tempo or something for speed up mode)
                ld      hl,zMasterPlaylist              ; Get address of the zMasterPlaylist
                add     hl,de                           ; Add the 16-bit offset here
                ld      a,(hl)                          ; Get "fixed" index
                ld      b,a                             ; 'a' -> 'b'
; The following instructions enable a bankswitch routine
                and     80h                             ; Get only 'bank' bit
                ld      (zAbsVar.MusicBankNumber),a     ; Store this (use to enable alternate bank)
                ld      a,b                             ; Restore 'a'
                add     a,a                             ; Adding a+a causes a possible overflow and a multiplication by 2
                add     a,a                             ; Now multiplied by 4 and another possible overflow
                ld      c,a                             ; Result -> 'c'
                ccf                                     ; Invert carry flag
                sbc     a,a                             ; ... so that this sets a to FFh if bit 6 of original a was clear (allow PAL double-update), zero otherwise (do not allow PAL double-update)
                ld      (zAbsVar.IsPalFlag),a           ; Set IsPalFlag
                ld      a,c                             ; Put prior multiply result back in
                add     a,a                             ; Now multiplied by 8!
                sbc     a,a                             ; This is FFh if bit 5 of original a was set (uncompressed song), zero otherwise (compressed song)
                push    af                              ; Backing up result...?
                ld      a,b                             ; Put 80h based index -> 'a'
                and     1Fh                             ; Strip the flag bits
                add     a,a                             ; multiply by 2; now 'a' is offset into music table, save for the $8000
                ld      e,a
                ld      d,0                             ; de = a
                ld      hl,zROMWindow
                add     hl,de                           ; "hl" now contains 2-byte offset for music address table lookup
                push    hl                              ; Save 'hl' (will be damaged by bank switch)
                call    zBankSwitchToMusic              ; Bank switch to start of music in ROM!
                pop     hl                              ; Restore 'hl'
                ld      e,(hl)
                inc     hl
                ld      d,(hl)                          ; Getting offset within bank to music -> de

; If we bypass the Saxman decompressor, the Z80 engine starts
; with the assumption that we're already decompressed with 'de' pointing
; at the decompressed data (which just so happens to be the ROM window)
                pop     af
                or      a                               ; Was the uncompressed song flag set?
                jr      nz,.nodecomp                    ; Bypass the Saxman decompressor if so

; This begins a call to the Saxman decompressor:
                ex      de,hl
                exx
                push    hl
                push    de
                push    bc
                exx
                call    zSaxmanDec
                exx
                pop     bc
                pop     de
                pop     hl
                exx
                ld      de,zMusicData                   ; Saxman compressed songs start at zMusicData (1380h)

.nodecomp:
; Begin common track init code
                push    de
                pop     ix                              ; ix = de (BGM's starting address)
                ld      e,(ix+0)                        ; Get voice table pointer low byte -> 'e'
                ld      d,(ix+1)                        ; Get voice table pointer high byte -> 'd'
                ld      (zAbsVar.VoiceTblPtr),de        ; Set master copy of this value in local memory
                ld      a,(ix+5)                        ; Get main tempo value
                ld      (zAbsVar.TempoMod),a            ; Store it at (zComRange+12h)
                ld      b,a                             ; tempo -> 'b'
                ld      a,(zAbsVar.SpeedUpFlag)         ; Get found speed shoe flag (zComRange+14h) (preloaded before this)
                or      a                               ; test it
                ld      a,b                             ; Restore normal song tempo
                jr      z,.nospeedshoes                 ; if the speed shoe flag was zero, skip this step
                ld      a,(zAbsVar.TempoTurbo)          ; Put the corresponding speed shoe tempo for song

.nospeedshoes:
                ld      (zAbsVar.CurrentTempo),a        ; Current tempo for TempoWait
                ld      (zAbsVar.TempoTimeout),a        ; Tempo accumulator for TempoWait
                ld      a,5
                ld      (zPALUpdTick),a                 ; reset PAL update tick to 5 (update immediately)
                push    ix
                pop     hl                              ; hl = ix (BGM's starting address)
                ld      de,6
                add     hl,de                           ; +06h (to DAC pointer)
                ld      a,(ix+2)                        ; Get number of FM+DAC channels this BGM has
                or      a                               ; Test it
                jp      z,zInitBGMPSG                   ; If zero, then don't init any
                ld      b,a                             ; 'a' -> 'b' (num FM+DAC channels this song, for loop)
                push    iy                              ; Save 'iy'
                ld      iy,zTracksSongStart             ; 'iy' points to start of track memory
                ld      c,(ix+4)                        ; Get tempo divider -> 'c'
; The bugfix in zInitMusicPlayback does this, already
                ld      de,zFMDACInitBytes              ; 'de' points to zFMDACInitBytes

.bgm_fmloadloop:
                ld      (iy+zTrack.PlaybackControl),82h  ; Set "track is playing" bit and "track at rest" bit
; The bugfix in zInitMusicPlayback does this, already
                ld      a,(de)                          ; Get current byte from zFMDACInitBytes -> 'a'
                inc     de                              ; will get next byte from zFMDACInitBytes next time
                ld      (iy+zTrack.VoiceControl),a      ; Store this byte to "voice control" byte
                ld      (iy+zTrack.TempoDivider),c      ; Store timing divisor from header for this track
                ld      (iy+zTrack.StackPointer),zTrack.GoSubStack  ; set "gosub" (coord flag F8h) stack init value (starts at end of this track's memory)
                ld      (iy+zTrack.AMSFMSPan),0C0h      ; default Panning / AMS / FMS settings (only stereo L/R enabled)
                ld      (iy+zTrack.DurationTimeout),1   ; set current duration timeout to 1 (should expire next update, play first note, etc.)
; The bugfix in zInitMusicPlayback does this, already
                push    de                              ; saving zFMDACInitBytes pointer
                push    bc                              ; saving number of channels and tempo divider ('bc' gets needlessly damaged by 'ldi' instructions coming up)
                ld      a,iyl                           ; current track pointer low byte -> 'a'
                add     a,zTrack.DataPointerLow
                ld      e,a
                adc     a,iyu
                sub     e
                ld      d,a                             ; de = iy + 3 ('de' is pointing to track offset address)
                ldi                                     ; *de++ = *hl++ (copy track address low byte from header to track's copy of this value)
                ldi                                     ; *de++ = *hl++ (copy track address high byte from header to track's copy of this value)
                ldi                                     ; *de++ = *hl++ (default key offset, typically 0, can be set later by coord flag E9)
                ldi                                     ; *de++ = *hl++ (track default volume)
                ld      de,zTrack.len                   ; size of all tracks -> 'de'
                add     iy,de                           ; offset to next track!
                pop     bc                              ; restore 'bc' (number of channels and tempo divider)
; The bugfix in zInitMusicPlayback does this, already
                pop     de                              ; restore 'de' (zFMDACInitBytes current pointer)
                djnz    .bgm_fmloadloop                 ; loop for all tracks we're init'ing
; End of FM+DAC track init loop

                pop     iy                              ; restore 'iy'
                ld      a,(ix+2)                        ; 'ix' still points to start of BGM; get number of FM+DAC -> 'a'
                cp      7                               ; Does it equal 7?  (6 FM channels)
                jr      nz,.silencefm6                  ; If not, skip this next part
                xor     a                               ; Clear 'a'
                ld      c,a                             ; c = 0
                jr      .writesilence                   ; jump to .writesilence

.silencefm6:
; Silence FM Channel 6 specifically if it's not in use
; A later call to zFMNoteOff does this, already
                ld      a,28h                           ; Key on/off FM register
                ld      c,6                             ; FM channel 6
                rst     zWriteFMI                       ; All operators off
; The added zFMSilenceChannel does this, already
                ld      a,42h                           ; Starting at FM Channel 6 Operator 1 Total Level register
                ld      c,0FFh                          ; Silence value
                ld      b,4                             ; Write to all four FM Channel 6 operators

; Set all TL values to silence!
.silencefm6loop:
                rst     zWriteFMII
                add     a,4                             ; Next operator
                djnz    .silencefm6loop

; Panning isn't normally set until zSetVoice
; This is a problem for the DAC track since it never uses zSetVoice
; (or at least it shouldn't), so we reset the panning here
                ld      a,0B6h                          ; Set Panning / AMS / FMS
                ld      c,0C0h                          ; default Panning / AMS / FMS settings (only stereo L/R enabled)
                rst     zWriteFMII                      ; Set it!
                ld      a,80h                           ; FM Channel 6 is NOT in use (will enable DAC)
                ld      c,a                             ; Set this as value to be used in FM register write coming up

; zloc_87E
.writesilence:
                ld      (zAbsVar.DACEnabled),a          ; Note whether FM Channel 6 is in use (enables DAC if not)
                ld      a,2Bh                           ; Set DAC Enable appropriately
                rst     zWriteFMI                       ; Set it!

; End of DAC/FM init, begin PSG init

; zloc_884
zInitBGMPSG:
                ld      a,(ix+3)                        ; Get number of PSG tracks
                or      a                               ; Test it
                jp      z,zInitSFX                      ; If zero, skip this part!
                ld      b,a                             ; 'a' -> 'b' (num PSG tracks this song, for loop)
                push    iy                              ; Save 'iy'
                ld      iy,zSongPSG1                    ; 'iy' points to start of PSG track memory (7 prior tracks were DAC and 6 FM)
                ld      c,(ix+4)                        ; Get tempo divider -> 'c'
; The bugfix in zInitMusicPlayback does this, already
                ld      de,zPSGInitBytes                ; 'de' points to zPSGInitBytes

.bgm_psgloadloop:
                ld      (iy+zTrack.PlaybackControl),82h  ; Set "track is playing" bit and "track at rest" bit
; The bugfix in zInitMusicPlayback does this, already
                ld      a,(de)                          ; Get current byte from zPSGInitBytes -> 'a'
                inc     de                              ; will get next byte from zPSGInitBytes next time
                ld      (iy+zTrack.VoiceControl),a      ; Store this byte to "voice control" byte
                ld      (iy+zTrack.TempoDivider),c      ; Store timing divisor from header for this track
                ld      (iy+zTrack.StackPointer),zTrack.GoSubStack  ; "gosub" stack init value
                ld      (iy+zTrack.DurationTimeout),1   ; set current duration timeout to 1 (should expire next update, play first note, etc.)
; The bugfix in zInitMusicPlayback does this, already
                push    de                              ; saving zPSGInitBytes pointer
                push    bc                              ; saving number of channels and tempo divider ('bc' gets needlessly damaged by 'ldi' instructions coming up)
                ld      a,iyl                           ; current track pointer low byte -> 'a'
                add     a,zTrack.DataPointerLow
                ld      e,a
                adc     a,iyu
                sub     e
                ld      d,a                             ; de = iy + 3 ('de' is pointing to track offset address)
                ldi                                     ; *de++ = *hl++ (copy track address low byte from header to track's copy of this value)
                ldi                                     ; *de++ = *hl++ (copy track address high byte from header to track's copy of this value)
                ldi                                     ; *de++ = *hl++ (default key offset, typically 0, can be set later by coord flag E9)
                ldi                                     ; *de++ = *hl++ (track default volume)
                inc     hl                              ; Get default PSG tone
                ld      a,(hl)                          ; -> 'a'
                inc     hl                              ; This byte is usually the same as the prior, unused
                ld      (iy+zTrack.VoiceIndex),a        ; Store current PSG tone
                ld      de,zTrack.len                   ; size of all tracks -> 'de'
                add     iy,de                           ; offset to next track!
                pop     bc                              ; restore 'bc' (number of channels and tempo divider)
; The bugfix in zInitMusicPlayback does this, already
                pop     de                              ; restore 'de' (zPSGInitBytes current pointer)
                djnz    .bgm_psgloadloop                ; loop for all tracks we're init'ing

                pop     iy                              ; restore 'iy'
; End of PSG tracks init, begin SFX tracks init

; zloc_8D0
zInitSFX:
                ld      ix,zTracksSFXStart              ; 'ix' points to start of SFX track memory (10 prior tracks were DAC, 6 FM, 3 PSG)
                ld      b,SFX_TRACK_COUNT               ; 6 SFX tracks total (3FM, 3PSG)
                ld      de,zTrack.len                   ; size between tracks

; zloc_8D9
zInitSFXLoop:
                bit     7,(ix+zTrack.PlaybackControl)   ; Is this track currently playing?
                jr      z,zSFXFinishSetup               ; If not, jump ahead (no work to do!)
                ld      a,(ix+zTrack.VoiceControl)      ; Get "voice control" byte
                or      a                               ; Test it
                jp      m,.sfxpsgchannel                ; If this is a PSG track, jump to .sfxpsgchannel
                sub     2                               ; Otherwise, subtract 2
                add     a,a                             ; ... multiply by 2 (preparing to index starting from FM 3 only)
                jr      .dosetup                        ; Jump ahead (general track setup)

.sfxpsgchannel:
                rra
                rra
                rra
                rra
                and     0Fh                             ; for PSG, just shift it down by 4 and we have its index!

; zloc_8F1
.dosetup:
                add     a,zMusicTrackOffs&0FFh          ; get offset into appropriate music track
                ld      (.trackstore+1),a               ; store into the following instruction (self-modifying code)

; zloc_8F6
.trackstore:
                ld      hl,(zMusicTrackOffs)            ; This loads address of corresponding MUSIC track (the track that this SFX track would normally play over)
                res     2,(hl)                          ; Clear the "SFX override" bit (Why??? According to S1's driver, this should be a 'set')

; zloc_8FB
zSFXFinishSetup:
                add     ix,de                           ; Next track
                djnz    zInitSFXLoop                    ; Loop for all tracks
; End of SFX tracks init

                ld      ix,zSongFMStart                 ; 'ix' points to first FM music track
                ld      b,MUSIC_FM_TRACK_COUNT          ; For all 6 of those

.fmnoteoffloop:
                call    zFMNoteOff                      ; Send Key Off
                add     ix,de                           ; Next track
                djnz    .fmnoteoffloop

                ld      b,MUSIC_PSG_TRACK_COUNT         ; For all 3 PSG tracks

.psgnoteoffloop:
                call    zPSGNoteOff                     ; Send Note Off
                add     ix,de                           ; Next track
                djnz    .psgnoteoffloop

                ret

; ---------------------------------------------------------------------------
; FM channel assignment bits
; zbyte_916
zFMDACInitBytes:
                db      6,   0,   1,   2,   4,   5,   6  ; first byte is for DAC; then notice the 0, 1, 2 then 4, 5, 6; this is the gap between parts I and II for YM2612 port writes

; Default values for PSG tracks
; zbyte_91D
zPSGInitBytes:
                db      80h,0A0h,0C0h                   ; Specifically, these configure writes to the PSG port for each channel

; zloc_920
zPlaySound_CheckRing:
                ld      c,a                             ; Store sound index -> 'c'
                ld      a,(ix+zVar.1upPlaying)          ; Get "is 1-up playing" flag
                or      (ix+zVar.FadeInFlag)            ; Or it with fading in flag
                jp      nz,zKillSFXPrio                 ; If either is set, SFX cannot be played!!
                xor     a
                ld      (zSpindashActiveFlag),a         ; Clear spindash sound flag
                ld      a,c                             ; Sound index -> 'a'
                cp      SndID_Ring                      ; is this the ring sound?
                jr      nz,zPlaySound_CheckGloop        ; if not, jump
; This is the ring sound
                ld      a,(zRingSpeaker)                ; 0 plays left, FFh plays right
                or      a                               ; Test it
                jr      nz,.ringchange                  ; If it's not zero, we skip this next step
                ld      c,SndID_RingLeft                ; do something different (probably speaker change)

.ringchange:
                cpl                                     ; If it was 0, it's now FFh, or vice versa
                ld      (zRingSpeaker),a                ; Store new ring speaker value (other side)
                jp      zPlaySound                      ; now play the play the ring sound
