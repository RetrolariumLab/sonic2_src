AniArt_Load:
                moveq   #0,d0
                move.b  (Current_Zone).w,d0
                add.w   d0,d0
                add.w   d0,d0
                move.w  PLC_DYNANM+2(pc,d0.w),d1
                lea     PLC_DYNANM(pc,d1.w),a2
                move.w  PLC_DYNANM(pc,d0.w),d0
                jmp     PLC_DYNANM(pc,d0.w)
; ===========================================================================
                rts
; ===========================================================================

; ---------------------------------------------------------------------------
; ZONE ANIMATION PROCEDURES AND SCRIPTS
;
; Each zone gets two entries in this jump table. The first entry points to the
; zone's animation procedure (usually Dynamic_Normal, but some zones have special
; procedures for complicated animations). The second points to the zone's animation
; script
;
; Note that Animated_Null is not a valid animation script, so don't pair it up
; with anything except Dynamic_Null, or bad things will happen (for example, a bus error exception)
; ---------------------------------------------------------------------------
PLC_DYNANM:     zoneOrderedOffsetTable 2,2
                zoneOffsetTableEntry.w Dynamic_Normal   ; EHZ
                zoneOffsetTableEntry.w Animated_EHZ

                zoneOffsetTableEntry.w Dynamic_Null     ; Zone 1
                zoneOffsetTableEntry.w Animated_Null

                zoneOffsetTableEntry.w Dynamic_Null     ; WZ
                zoneOffsetTableEntry.w Animated_Null

                zoneOffsetTableEntry.w Dynamic_Null     ; Zone 3
                zoneOffsetTableEntry.w Animated_Null

                zoneOffsetTableEntry.w Dynamic_Normal   ; MTZ1,2
                zoneOffsetTableEntry.w Animated_MTZ

                zoneOffsetTableEntry.w Dynamic_Normal   ; MTZ3
                zoneOffsetTableEntry.w Animated_MTZ

                zoneOffsetTableEntry.w Dynamic_Null     ; WFZ
                zoneOffsetTableEntry.w Animated_Null

                zoneOffsetTableEntry.w Dynamic_HTZ      ; HTZ
                zoneOffsetTableEntry.w Animated_HTZ

                zoneOffsetTableEntry.w Dynamic_Normal   ; HPZ
                zoneOffsetTableEntry.w Animated_HPZ

                zoneOffsetTableEntry.w Dynamic_Null     ; Zone 9
                zoneOffsetTableEntry.w Animated_Null

                zoneOffsetTableEntry.w Dynamic_Normal   ; OOZ
                zoneOffsetTableEntry.w Animated_OOZ

                zoneOffsetTableEntry.w Dynamic_Null     ; MCZ
                zoneOffsetTableEntry.w Animated_Null

                zoneOffsetTableEntry.w Dynamic_CNZ      ; CNZ
                zoneOffsetTableEntry.w Animated_CNZ

                zoneOffsetTableEntry.w Dynamic_Normal   ; CPZ
                zoneOffsetTableEntry.w Animated_CPZ

                zoneOffsetTableEntry.w Dynamic_Normal   ; DEZ
                zoneOffsetTableEntry.w Animated_DEZ

                zoneOffsetTableEntry.w Dynamic_ARZ      ; ARZ
                zoneOffsetTableEntry.w Animated_ARZ

                zoneOffsetTableEntry.w Dynamic_Null     ; SCZ
                zoneOffsetTableEntry.w Animated_Null
                zoneTableEnd
; ===========================================================================

Dynamic_Null:
                rts
; ===========================================================================

Dynamic_HTZ:
; More unused two-player code
                tst.w   (Two_player_mode).w
                bne.w   Dynamic_Normal

; .doMountainArt:
; Upload dynamic mountain art
                lea     (Anim_Counters).w,a3
                moveq   #0,d0
                move.w  (Camera_X_pos).w,d1
                neg.w   d1
                asr.w   #3,d1
                move.w  (Camera_X_pos).w,d0
                lsr.w   #4,d0
                add.w   d1,d0
                subi.w  #$10,d0
                divu.w  #$30,d0
                swap    d0
                cmp.b   1(a3),d0
                beq.s   .skipMountainArt
                move.b  d0,1(a3)
                move.w  d0,d2
                andi.w  #7,d0
                add.w   d0,d0
                add.w   d0,d0
                add.w   d0,d0
                move.w  d0,d1
                add.w   d0,d0
                add.w   d1,d0
                andi.w  #$38,d2
                lsr.w   #2,d2
                add.w   d2,d0
                lea     .offsets(pc,d0.w),a4
                moveq   #5,d5
                move.w  #tiles_to_bytes(ArtTile_ArtUnc_HTZMountains),d4
; loc_3FD7C:
.mountainLoop:
                moveq   #-1,d1
                move.w  (a4)+,d1
                andi.l  #$FFFFFF,d1
                move.w  d4,d2
                moveq   #tiles_to_words(4),d3           ; DMA transfer length (in words)
                jsr     (QueueDMATransfer).l
                addi.w  #$80,d4
                dbf     d5,.mountainLoop
; BranchTo_loc_3FE5C ; BranchTo
.skipMountainArt:
                bra.w   .doCloudArt
; ===========================================================================
; HTZ mountain art main RAM addresses?
; word_3FD9C:
.offsets:
                dc.w    $80, $180, $280, $580, $600, $700  ; 6
                dc.w    $80, $180, $280, $580, $600, $700  ; 12
                dc.w    $980, $A80, $B80, $C80, $D00, $D80  ; 18
                dc.w    $980, $A80, $B80, $C80, $D00, $D80  ; 24
                dc.w    $E80,$1180,$1200,$1280,$1300,$1380  ; 30
                dc.w    $E80,$1180,$1200,$1280,$1300,$1380  ; 36
                dc.w    $1400,$1480,$1500,$1580,$1600,$1900  ; 42
                dc.w    $1400,$1480,$1500,$1580,$1600,$1900  ; 48
                dc.w    $1D00,$1D80,$1E00,$1F80,$2400,$2580  ; 54
                dc.w    $1D00,$1D80,$1E00,$1F80,$2400,$2580  ; 60
                dc.w    $2600,$2680,$2780,$2B00,$2F00,$3280  ; 66
                dc.w    $2600,$2680,$2780,$2B00,$2F00,$3280  ; 72
                dc.w    $3600,$3680,$3780,$3C80,$3D00,$3F00  ; 78
                dc.w    $3600,$3680,$3780,$3C80,$3D00,$3F00  ; 84
                dc.w    $3F80,$4080,$4480,$4580,$4880,$4900  ; 90
                dc.w    $3F80,$4080,$4480,$4580,$4880,$4900  ; 96
; ===========================================================================
; loc_3FE5C:
.doCloudArt:
; Upload dynamic cloud art
                lea     (TempArray_LayerDef).w,a1
                move.w  (Camera_X_pos).w,d2
                neg.w   d2
                asr.w   #3,d2
                move.l  a2,-(sp)
                lea     (ArtUnc_HTZClouds).l,a0
                lea     (Chunk_Table+$7C00).l,a2
                moveq   #16-1,d1
; loc_3FE78:
.cloudLoop:
                move.w  (a1)+,d0
                neg.w   d0
                add.w   d2,d0
                andi.w  #$1F,d0
                lsr.w   #1,d0
                bcc.s   +
                addi.w  #$200,d0
+
                lea     (a0,d0.w),a4
                lsr.w   #1,d0
                bcs.s   .odd

; .even:
; The same as below, but does not safely handle odd addresses
                rept    3
                move.l  (a4)+,(a2)+
                adda.w  #$40-4,a2
                endm
                move.l  (a4)+,(a2)+
                suba.w  #$40*3,a2
                adda.w  #$20,a0
                dbf     d1,.cloudLoop
                bra.s   .done
; ===========================================================================
; loc_3FEB4:
.odd:
; The same as below, but safely handles odd addresses
                rept    3
                rept    4
                move.b  (a4)+,(a2)+
                endm
                adda.w  #$40-4,a2
                endm
                rept    4
                move.b  (a4)+,(a2)+
                endm
                suba.w  #$40*3,a2
                adda.w  #$20,a0
                dbf     d1,.cloudLoop
; loc_3FEEC:
.done:
                move.l  #(Chunk_Table+$7C00) & $FFFFFF,d1
                move.w  #tiles_to_bytes(ArtTile_ArtUnc_HTZClouds),d2
                move.w  #tiles_to_words(8),d3           ; DMA transfer length (in words)
                jsr     (QueueDMATransfer).l
                movea.l (sp)+,a2
                addq.w  #2,a3
                bra.w   Dynamic_Normal.customCounters
; ===========================================================================

Dynamic_CNZ:
                tst.b   (Current_Boss_ID).w
                beq.s   +
                rts
; ---------------------------------------------------------------------------
+
                lea     (Animated_CNZ).l,a2
                tst.w   (Two_player_mode).w
                beq.s   Dynamic_Normal
                lea     (Animated_CNZ_2P).l,a2
                bra.s   Dynamic_Normal
; ===========================================================================

Dynamic_ARZ:
                tst.b   (Current_Boss_ID).w
                beq.s   Dynamic_Normal
                rts
; ===========================================================================
