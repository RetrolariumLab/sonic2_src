zSaxmanDec:
                exx
                ld      bc,0
                ld      de,0
                exx
                ld      de,zMusicData
                ld      c,(hl)
                inc     hl
                ld      b,(hl)                          ; bc = (hl) i.e. "size of song"
                inc     hl
                ld      (zGetNextByte+1),hl             ; modify inst. @ zGetNextByte -- set to beginning of decompression stream
                inc     bc
                ld      (zDecEndOrGetByte+1),bc         ; modify inst. @ zDecEndOrGetByte -- set to length of song, +1

; zloc_1288
zSaxmanReadLoop:
                exx                                     ; shadow reg set
                srl     c                               ; c >> 1 (active control byte)
                srl     b                               ; b >> 1 (just a mask that lets us know when we need to reload)
                bit     0,b                             ; test next bit of 'b'
                jr      nz,.skip_fetching_descriptor    ; if it's set, we still have bits left in 'c', so continue
; If you get here, we're out of bits in 'c'!
                call    zDecEndOrGetByte                ; get next byte -> 'a'
                ld      c,a                             ; a -> 'c'
                ld      b,0FFh                          ; b = FFh (8 new bits in 'c')

.skip_fetching_descriptor:
                bit     0,c                             ; test next bit of 'c'
                exx                                     ; normal reg set
                jr      z,.is_dictionary_reference      ; if bit not set, it's a compression bit; jump accordingly
; If you get here, there's a non-compressed byte
                call    zDecEndOrGetByte                ; get next byte -> 'a'
                ld      (de),a                          ; store it directly to the target memory address
                inc     de                              ; de++
                exx                                     ; shadow reg set
                inc     de                              ; Also increase shadow-side 'de'... relative pointer only, does not point to output Z80_RAM
                exx                                     ; normal reg set
                jr      zSaxmanReadLoop                 ; loop back around

.is_dictionary_reference:
                call    zDecEndOrGetByte                ; get next byte -> 'a'
                ld      c,a                             ; a -> 'c' (low byte of target address)
                call    zDecEndOrGetByte                ; get next byte -> 'a'
                ld      b,a                             ; a -> 'b' (high byte of target address + count)
                and     0Fh                             ; keep only lower four bits
                add     a,3                             ; add 3 (minimum 3 bytes are to be read in this mode)
                push    af                              ; save 'a'
                ld      a,b                             ; b -> 'a' (low byte of target address)
                rlca
                rlca
                rlca
                rlca
                and     0Fh                             ; basically (b >> 4) & 0xF (upper four bits now exclusively as lower four bits)
                ld      b,a                             ; a -> 'b' (only upper four bits of value make up part of the address)
                ld      a,c
                add     a,12h
                ld      c,a
                adc     a,b
                sub     c
                and     0Fh
                ld      b,a                             ; bc += 12h
                pop     af                              ; restore 'a' (byte count to read; no less than 3)
                exx                                     ; shadow reg set
                push    de                              ; keep current 'de' (relative pointer) value
                ld      l,a                             ; how many bytes we will read -> 'hl'
                ld      h,0
                add     hl,de                           ; add current relative pointer
                ex      de,hl                           ; effectively, de += a
                exx                                     ; normal reg set
                pop     hl                              ; shadow 'de' -> 'hl' (relative pointer, prior to all bytes read, relative)
                or      a                               ; Clear carry
                sbc     hl,bc                           ; hl -= bc
                jr      nc,.is_not_zero_fill            ; if result positive, jump ahead
                ex      de,hl                           ; current output pointer -> 'hl'
                ld      b,a                             ; how many bytes to load -> 'b'

.fill_zero_loop:
                ld      (hl),0                          ; fill in zeroes that many times
                inc     hl
                djnz    .fill_zero_loop

                ex      de,hl                           ; output pointer updated
                jr      zSaxmanReadLoop                 ; loop back around

.is_not_zero_fill:
                ld      hl,zMusicData                   ; point at beginning of decompression point
                add     hl,bc                           ; move ahead however many bytes
                ld      c,a
                ld      b,0
                ldir
                jr      zSaxmanReadLoop
; End of function zSaxmanDec

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; This is an ugly countdown to zero implemented in repeatedly modifying code!!
; But basically, it starts at the full length of the song +1 (so it can decrement)
; and waits until 'hl' decrements to zero
; zsub_12E8
zDecEndOrGetByte:
                ld      hl,0                            ; Self-modified code: starts at full length of song +1, waits until it gets to 1
                dec     hl                              ; ...where this will be zero
                ld      (zDecEndOrGetByte+1),hl         ; Self-modified code: update the count in case it's not zero
                ld      a,h
                or      l
                jr      z,zDecEnd                       ; If 'h' and 'l' both equal zero, we quit!!

; zloc_12F3
zGetNextByte:
                ld      hl,0                            ; Self-modified code: get address of next compressed byte
                ld      a,(hl)                          ; put it into -> 'a'
                inc     hl                              ; next byte
                ld      (zGetNextByte+1),hl             ; change inst @ zGetNextByte so it loads next compressed byte
                ret                                     ; still going

; zloc_12FC
zDecEnd:
                pop     hl                              ; throws away return address to this function call so that next 'ret' exits decompressor (we're done!)
                ret                                     ; Exit decompressor
; End of function zDecEndOrGetByte

; ---------------------------------------------------------------------------
; space for a few global variables

zPALUpdTick:                    db      0               ; zbyte_12FE ; This counts from 0 to 5 to periodically "double update" for PAL systems (basically every 6 frames you need to update twice to keep up)
zCurDAC:                        db      0               ; zbyte_12FF ; seems to indicate DAC sample playing status
zCurSong:                       db      0               ; zbyte_1300 ; currently playing song index
zDoSFXFlag:                     db      0               ; zbyte_1301 ; flag to indicate we're updating SFX (and thus use custom voice table); set to anything but 0 while doing SFX, 0 when not
zRingSpeaker:                   db      0               ; zbyte_1302 ; stereo alternation flag. 0 = next one plays on left, -1 = next one plays on right
zGloopFlag:                     db      0               ; zbyte_1303 ; if -1, don't play the gloop sound next time
zSpindashPlayingCounter:        db      0               ; zbyte_1304
zSpindashExtraFrequencyIndex:   db      0               ; zbyte_1305
zSpindashActiveFlag:            db      0               ; zbyte_1306 ; -1 if spindash charge was the last sound that played
zPaused:                        db      0               ; zbyte_1307 ; 0 = normal, -1 = pause all sound and music

; end of Z80 'ROM'
                if      $>zMusicData
                fatal   "Your Z80 code won't fit before the music.. It's \{$-zMusicData}h bytes past the start of music data \{zMusicData}h"
                endif
