; ---------------------------------------------------------------------------
; zbyte_FD8h
zSFXPriority:
                db      80h,70h,70h,70h,70h,70h,70h,70h,70h,70h,68h,70h,70h,70h,60h,70h
                db      70h,60h,70h,60h,70h,70h,70h,70h,70h,70h,70h,70h,70h,70h,70h,7Fh
                db      6Fh,70h,70h,70h,70h,70h,70h,70h,70h,70h,70h,70h,70h,6Fh,70h,70h
                db      70h,60h,60h,70h,70h,70h,70h,70h,70h,70h,60h,62h,60h,60h,60h,70h
                db      70h,70h,70h,70h,60h,60h,60h,6Fh,70h,70h,6Fh,6Fh,70h,71h,70h,70h
                db      6Fh

; zoff_1029 zPSG_Index zPSG_FlutterTbl
zPSG_EnvTbl:
; Basically, for any tone 0-11, dynamic volume adjustments are applied to produce a pseudo-decay,
; or sometimes a ramp up for "soft" sounds, or really any other volume effect you might want!

; Remember on PSG that the higher the value, the quieter it gets (it's attenuation, not volume);
; 0 is thus loudest, and increasing values decay, until level $F (silent)

                dw      zPSG_Env1, zPSG_Env2, zPSG_Env3, zPSG_Env4
                dw      zPSG_Env5, zPSG_Env6, zPSG_Env7, zPSG_Env8
                dw      zPSG_Env9, zPSG_Env10, zPSG_Env11, zPSG_Env12
                dw      zPSG_Env13

; byte_1043
zPSG_Env1:
                binclude "data/sound/psg/zPSG_Env1.bin"

; byte_105A
zPSG_Env2:
                binclude "data/sound/psg/zPSG_Env2.bin"

; byte_1061
zPSG_Env3:
                binclude "data/sound/psg/zPSG_Env3.bin"

; byte_1072
zPSG_Env4:
                binclude "data/sound/psg/zPSG_Env4.bin"

; The next two envelopes appear in a different order than in the list above

; byte_107D
zPSG_Env6:
                binclude "data/sound/psg/zPSG_Env6.bin"

; byte_108C
zPSG_Env5:
                binclude "data/sound/psg/zPSG_Env5.bin"

; byte_10B6
zPSG_Env7:
                binclude "data/sound/psg/zPSG_Env7.bin"

; byte_10D2
zPSG_Env8:
                binclude "data/sound/psg/zPSG_Env8.bin"

; byte_10FA
zPSG_Env9:
                binclude "data/sound/psg/zPSG_Env9.bin"

; byte_110B
zPSG_Env10:
                binclude "data/sound/psg/zPSG_Env10.bin"

; byte_1149
zPSG_Env11:
                binclude "data/sound/psg/zPSG_Env11.bin"

; byte_1165
zPSG_Env12:
                binclude "data/sound/psg/zPSG_Env12.bin"

; byte_11E5
zPSG_Env13:
                binclude "data/sound/psg/zPSG_Env13.bin"

; END of zPSG_EnvTbl -------------------------------

; Stuff for zMasterPlaylist
z80_bank_size       =       8000h
getZ80BankOffset    function label, label # z80_bank_size
getZ80BankBase      function label, label - getZ80BankOffset(label)
withinSameZ80Bank   function label1, label2, getZ80BankBase(label1) == getZ80BankBase(label2)

MusFlag_SlowerOnPAL     =       1 << 6                  ; Song should play slower on PAL consoles

music_metadata  macro   DATA,FLAGS
                    db      (withinSameZ80Bank(DATA.pointer, MusicPoint2)<<7)|((~~DATA.is_compressed)<<5)|(FLAGS)|(getZ80BankOffset(DATA.pointer)/2)
                endm

; zbyte_11F5h
zMasterPlaylist:
zMusIDPtr_2PResult:     music_metadata Mus_2PResult
zMusIDPtr_EHZ:          music_metadata Mus_EHZ
zMusIDPtr_MCZ_2P:       music_metadata Mus_MCZ_2P
zMusIDPtr_OOZ:          music_metadata Mus_OOZ
zMusIDPtr_MTZ:          music_metadata Mus_MTZ
zMusIDPtr_HTZ:          music_metadata Mus_HTZ
zMusIDPtr_ARZ:          music_metadata Mus_ARZ
zMusIDPtr_CNZ_2P:       music_metadata Mus_CNZ_2P
zMusIDPtr_CNZ:          music_metadata Mus_CNZ
zMusIDPtr_DEZ:          music_metadata Mus_DEZ
zMusIDPtr_MCZ:          music_metadata Mus_MCZ
zMusIDPtr_EHZ_2P:       music_metadata Mus_EHZ_2P
zMusIDPtr_SCZ:          music_metadata Mus_SCZ
zMusIDPtr_CPZ:          music_metadata Mus_CPZ
zMusIDPtr_WFZ:          music_metadata Mus_WFZ
zMusIDPtr_HPZ:          music_metadata Mus_HPZ
zMusIDPtr_Options:      music_metadata Mus_Options
zMusIDPtr_SpecStage:    music_metadata Mus_SpecStage
zMusIDPtr_Boss:         music_metadata Mus_Boss
zMusIDPtr_EndBoss:      music_metadata Mus_EndBoss
zMusIDPtr_Ending:       music_metadata Mus_Ending
zMusIDPtr_SuperSonic:   music_metadata Mus_SuperSonic
zMusIDPtr_Invincible:   music_metadata Mus_Invincible
zMusIDPtr_ExtraLife:    music_metadata Mus_ExtraLife
zMusIDPtr_Title:        music_metadata Mus_Title
zMusIDPtr_EndLevel:     music_metadata Mus_EndLevel
zMusIDPtr_GameOver:     music_metadata Mus_GameOver
zMusIDPtr_Continue:     music_metadata Mus_Continue
zMusIDPtr_Emerald:      music_metadata Mus_Emerald
zMusIDPtr_Credits:      music_metadata Mus_Credits
zMusIDPtr_Countdown:    music_metadata Mus_Drowning,MusFlag_SlowerOnPAL
zMusIDPtr__End:

; Tempo with speed shoe tempo for each song
; zbyte_1214
zSpedUpTempoTable:
                db      68h,0BEh,0FFh,0F0h
                db      0FFh,0DEh,0FFh,0DDh
                db      68h, 80h,0D6h, 7Bh
                db      7Bh,0FFh,0A8h,0FFh
                db      87h,0FFh,0FFh,0C9h
                db      97h,0FFh,0FFh,0CDh
                db      0CDh,0AAh,0F2h,0DBh
                db      0D5h,0F0h, 80h

dac_sample_pointer  macro   label
label.pointer       =       $
                    dw      zmake68kPtr(label)
                    dw      label.size
                endm

; DAC sample pointers and lengths
                ensure1byteoffset 2*2*7

; zDACPtr_Index zbyte_1233
zDACPtrTbl:
zDACLenTbl      =       zDACPtrTbl + 2
                dac_sample_pointer SndDAC_Kick
                dac_sample_pointer SndDAC_Snare
                dac_sample_pointer SndDAC_Clap
                dac_sample_pointer SndDAC_Scratch
                dac_sample_pointer SndDAC_Timpani
                dac_sample_pointer SndDAC_Tom
                dac_sample_pointer SndDAC_Bongo

; something else for DAC sounds
; First byte selects one of the DAC samples. The number that
; follows it is a wait time between each nibble written to the DAC
; (thus higher = slower)
                ensure1byteoffset 2*11h
; zbyte_124F
zDACMasterPlaylist:

; DAC samples IDs
offset          :=      zDACPtrTbl
ptrsize         :=      2+2
idstart         :=      81h

dac_sample_metadata     macro   label,sampleRateScale
sample_rate_scale       :=      1.0
                    if      "sampleRateScale"<>""
sample_rate_scale   :=      sampleRateScale
                    endif
                    db      id(label.pointer),dpcmLoopCounter(int(label.sample_rate*sample_rate_scale))
                endm

                dac_sample_metadata SndDAC_Kick         ; 81h
                dac_sample_metadata SndDAC_Snare,       ; 82h
                dac_sample_metadata SndDAC_Clap,        ; 83h
                dac_sample_metadata SndDAC_Scratch,     ; 84h
                dac_sample_metadata SndDAC_Timpani,     ; 85h
                dac_sample_metadata SndDAC_Tom,         ; 86h
                dac_sample_metadata SndDAC_Bongo,       ; 87h
                dac_sample_metadata SndDAC_Timpani, 1.30  ; 88h
                dac_sample_metadata SndDAC_Timpani, 1.20  ; 89h
                dac_sample_metadata SndDAC_Timpani, 0.97  ; 8Ah
                dac_sample_metadata SndDAC_Timpani, 0.95  ; 8Bh
                dac_sample_metadata SndDAC_Tom,     1.70  ; 8Ch
                dac_sample_metadata SndDAC_Tom,     1.30  ; 8Dh
                dac_sample_metadata SndDAC_Tom,     1.10  ; 8Eh
                dac_sample_metadata SndDAC_Bongo,   2.00  ; 8Fh
                dac_sample_metadata SndDAC_Bongo,   1.75  ; 90h
                dac_sample_metadata SndDAC_Bongo,   1.30  ; 91h

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; zsub_1271
