; ---------------------------------------------------------------------------

; zloc_167
zStartDAC:
                im      1                               ; set interrupt mode 1
                call    zClearTrackPlaybackMem
                ei                                      ; enable interrupts
                ld      iy,zDACDecodeTbl
                ld      de,0
; This controls the update rate for the DAC
; My speculation for the rate at which the DAC updates:
; Z80 clock = 3.57954MHz = 3579540Hz (not sure?)
; zWaitLoop (immediately below) is waiting for someone to set
; 'de' (length of DAC sample) to non-zero

; The DAC code is sync'ed with VBLANK somehow, but I haven't quite got that
; one figure out yet ... tests on emulator seem to confirm it though
; Next, there are "djnz" loops which do busy-waits.  (Two of them, which is
; where the '2' comes from in my guess equation.)  The DACMasterPlaylist
; appears to use '1' as the lowest input value to these functions.  (Which,
; given the djnz, would be the fastest possible value.)
; The rate seems to be calculated by 3579540Hz / (60Hz + (speed * 4)) / 2

; This "waitLoop" waits if the DAC has no data, or else it drops out!

; zloc_174:
zWaitLoop:
                ld      a,d                             ; 4
                or      e                               ; 4
                jr      z,zWaitLoop                     ; 7 ; As long as 'de' (length of sample) = 0, wait

; 'hl' is the pointer to the sample, 'de' is the length of the sample,
; and 'iy' points to the translation table; let's go

; The "djnz $" loops control the playback rate of the DAC
; (the higher the 'b' value, the slower it will play)

; As for the actual encoding of the data, it is described by jman2050:

; "As for how the data is compressed, lemme explain that real quick:
; First, it is a lossy compression. So if you recompress a PCM sample this way,
; you will lose precision in data. Anyway, what happens is that each compressed data
; is separated into nybbles (1 4-bit section of a byte). This first nybble of data is
; read, and used as an index to a table containing the following data:
; 0,1,2,4,8,$10,$20,$40,$80,$FF,$FE,$FC,$F8,$F0,$E0,$C0."   [zDACDecodeTbl / zbyte_1B3]
; "So if the nybble were equal to F, it'd extract $C0 from the table. If it were 8,
; it would extract $80 from the table. ... Anyway, there is also another byte of data
; that we'll call 'd'. At the start of decompression, d is $80. What happens is that d
; is then added to the data extracted from the table using the nybble. So if the nybble
; were 4, the 8 would be extracted from the table, then added to d, which is $80,
; resulting in $88. This result is then put back into d, then fed into the YM2612 for
; processing. Then the next nybble is read, the data is extracted from the table, then
; is added to d (remember, d is now changed because of the previous operation), then is
; put back into d, then is fed into the YM2612. This process is repeated until the number
; of bytes as defined in the table above are read and decompressed."

; In our case, the so-called 'd' value is shadow register 'a'

zWriteToDAC:
; According to Kabuto, the Z80 suffers a delay of approximately 3.3 cycles for each ROM access
; https://plutiedev.com/mirror/kabuto-hardware-notes#bus-system
                djnz    $                               ; 8 ; Busy wait for specific amount of time in 'b'

                di                                      ; 4 ; disable interrupts (while updating DAC)
                ld      a,2Ah                           ; 7 ; DAC port
                ld      (zYM2612_A0),a                  ; 13 ; Set DAC port register
                ld      a,(hl)                          ; 7+3 ; Get next DAC byte
                rlca                                    ; 4
                rlca                                    ; 4
                rlca                                    ; 4
                rlca                                    ; 4
                and     0Fh                             ; 7 ; UPPER 4-bit offset into zDACDecodeTbl
                ld      (.highnybble+2),a               ; 13 ; store into the instruction after .highnybble (self-modifying code)
                ex      af,af'                          ; 4 ; shadow register 'a' is the 'd' value for 'jman2050' encoding

; zloc_18B
.highnybble:
                add     a,(iy+0)                        ; 19 ; Get byte from zDACDecodeTbl (self-modified to proper index)
                ld      (zYM2612_D0),a                  ; 13 ; Write this byte to the DAC
                ex      af,af'                          ; 4 ; back to regular registers
                ld      b,c                             ; 4 ; reload 'b' with wait value
                ei                                      ; 4 ; enable interrupts (done updating DAC, busy waiting for next update)

                djnz    $                               ; 8 ; Busy wait for specific amount of time in 'b'

                di                                      ; 4 ; disable interrupts (while updating DAC)
                push    af                              ; 11
                pop     af                              ; 11
                ld      a,2Ah                           ; 7 ; DAC port
                ld      (zYM2612_A0),a                  ; 13 ; Set DAC port register
                ld      b,c                             ; 4 ; reload 'b' with wait value
                ld      a,(hl)                          ; 7+3 ; Get next DAC byte
                inc     hl                              ; 6 ; Next byte in DAC stream
                dec     de                              ; 6 ; One less byte
                and     0Fh                             ; 7 ; LOWER 4-bit offset into zDACDecodeTbl
                ld      (.lownybble+2),a                ; 13 ; store into the instruction after .lownybble (self-modifying code)
                ex      af,af'                          ; 4 ; shadow register 'a' is the 'd' value for 'jman2050' encoding

; zloc_1A8
.lownybble:
                add     a,(iy+0)                        ; 19 ; Get byte from zDACDecodeTbl (self-modified to proper index)
                ld      (zYM2612_D0),a                  ; 13 ; Write this byte to the DAC
                ex      af,af'                          ; 4 ; back to regular registers
                ei                                      ; 4 ; enable interrupts (done updating DAC, busy waiting for next update)
                jp      zWaitLoop                       ; 10 ; Back to the wait loop; if there's more DAC to write, we come back down again!
    ; 295
; 295 cycles for two samples. dpcmLoopCounter should use 295 divided by 2
; ---------------------------------------------------------------------------
; 'jman2050' DAC decode lookup table
; zbyte_1B3
zDACDecodeTbl:
                db      0,1,2,4,8,16,32,64,128,255,254,252,248,240,224,192

; The following two tables are used for when an SFX terminates
; its track to properly restore the music track it temporarily took
; over.  Note that an important rule here is that no SFX may use
; DAC, FM Channel 1, FM Channel 2, or FM Channel 6, period
; Thus there's also only SFX tracks starting at FM Channel 3

; The zeroes appear after FM 3 because it calculates the offsets into
; these tables by their channel assignment, where between Channel 3
; and Channel 4 there is a gap numerically

                ensure1byteoffset 10h
; zbyte_1C3
zMusicTrackOffs:
; These are offsets to different music tracks starting with FM3
                dw      zSongFM3,      0000h,  zSongFM4,  zSongFM5  ; FM3, 0, FM4, FM5
                dw      zSongPSG1, zSongPSG2, zSongPSG3, zSongPSG3  ; PSG1, PSG2, PSG3, PSG3 (noise alternate)

                ensure1byteoffset 10h
; zbyte_1D3
zSFXTrackOffs:
; These are offsets to different sound effect tracks starting with FM3
                dw      zSFX_FM3,      0000h,  zSFX_FM4,  zSFX_FM5  ; FM3, 0, FM4, FM5
                dw      zSFX_PSG1, zSFX_PSG2, zSFX_PSG3, zSFX_PSG3  ; PSG1, PSG2, PSG3, PSG3 (noise alternate)
