Obj6F:                                                  ; (note: screen-space obj)
                moveq   #0,d0
                moveq   #0,d6
                move.b  routine(a0),d0
                move.w  Obj6F_Index(pc,d0.w),d1
                jmp     Obj6F_Index(pc,d1.w)
; ===========================================================================
; off_143D0:
Obj6F_Index:    offsetTable
                offsetTableEntry.w Obj6F_Init           ; 0
                offsetTableEntry.w Obj6F_InitEmeraldText  ; 2
                offsetTableEntry.w Obj6F_InitResultTitle  ; 4
                offsetTableEntry.w Obj6F_Emerald0       ; 6
                offsetTableEntry.w Obj6F_Emerald1       ; 8
                offsetTableEntry.w Obj6F_Emerald2       ; $A
                offsetTableEntry.w Obj6F_Emerald3       ; $C
                offsetTableEntry.w Obj6F_Emerald4       ; $E
                offsetTableEntry.w Obj6F_Emerald5       ; $10
                offsetTableEntry.w Obj6F_Emerald6       ; $12
                offsetTableEntry.w BranchTo3_Obj34_MoveTowardsTargetPosition  ; $14
                offsetTableEntry.w Obj6F_P1Rings        ; $16
                offsetTableEntry.w Obj6F_P2Rings        ; $18
                offsetTableEntry.w Obj6F_DeleteIfNotEmerald  ; $1A
                offsetTableEntry.w Obj6F_TimedDisplay   ; $1C
                offsetTableEntry.w Obj6F_TallyScore     ; $1E
                offsetTableEntry.w Obj6F_TimedDisplay   ; $20
                offsetTableEntry.w Obj6F_DisplayOnly    ; $22
                offsetTableEntry.w Obj6F_TimedDisplay   ; $24
                offsetTableEntry.w Obj6F_TimedDisplay   ; $26
                offsetTableEntry.w Obj6F_TallyPerfect   ; $28
                offsetTableEntry.w Obj6F_PerfectBonus   ; $2A
                offsetTableEntry.w Obj6F_TimedDisplay   ; $2C
                offsetTableEntry.w Obj6F_DisplayOnly    ; $2E
                offsetTableEntry.w Obj6F_InitAndMoveSuperMsg  ; $30
                offsetTableEntry.w Obj6F_MoveTowardsSourcePosition  ; $32
                offsetTableEntry.w Obj6F_MoveAndDisplay  ; $34
; ===========================================================================
; loc_14406
Obj6F_Init:
                tst.l   (Plc_Buffer).w
                beq.s   +
                rts
; ===========================================================================
+
                movea.l a0,a1
                lea     Obj6F_SubObjectMetaData(pc),a2
                moveq   #bytesToXcnt(Obj6F_SubObjectMetaData_End-Obj6F_SubObjectMetaData, results_screen_object_size),d1

-               _move.b id(a0),id(a1)                   ; load obj6F
                move.w  (a2),x_pixel(a1)
                move.w  (a2)+,titlecard_x_source(a1)
                move.w  (a2)+,titlecard_x_target(a1)
                move.w  (a2)+,y_pixel(a1)
                move.b  (a2)+,routine(a1)
                move.b  (a2)+,mapping_frame(a1)
                move.l  #Obj6F_MapUnc_14ED0,mappings(a1)
                move.b  #$78,width_pixels(a1)
                move.b  #0,render_flags(a1)
                lea     next_object(a1),a1              ; go to next object ; a1=object
                dbf     d1,-                            ; loop

; loc_14450
Obj6F_InitEmeraldText:
                tst.b   (Got_Emerald).w
                beq.s   +
                move.b  #4,mapping_frame(a0)            ; "Chaos Emerald"
+
                cmpi.b  #7,(Emerald_count).w
                bne.s   +
                move.b  #$19,mapping_frame(a0)          ; "Chaos Emeralds"
+
                move.w  titlecard_x_target(a0),d0
                cmp.w   x_pixel(a0),d0
                bne.s   BranchTo2_Obj34_MoveTowardsTargetPosition
                move.b  #$1C,routine(a0)                ; => Obj6F_TimedDisplay
                move.w  #$B4,anim_frame_duration(a0)

BranchTo2_Obj34_MoveTowardsTargetPosition               ; BranchTo
                bra.w   Obj34_MoveTowardsTargetPosition
; ===========================================================================
; loc_14484
Obj6F_InitResultTitle:
                cmpi.b  #7,(Emerald_count).w
                bne.s   +
                moveq   #$16,d0                         ; "Sonic has all the"
                bra.s   ++
; ===========================================================================
+
                tst.b   (Got_Emerald).w
                beq.w   DeleteObject
                moveq   #1,d0                           ; "Sonic got a"
+
                cmpi.w  #2,(Player_mode).w
                bne.s   +
                addq.w  #1,d0                           ; "Miles got a" or "Miles has all the"
                btst    #7,(Graphics_Flags).w
                beq.s   +
                addq.w  #1,d0                           ; "Tails got a" or "Tails has all the"
+
                move.b  d0,mapping_frame(a0)
                bra.w   Obj34_MoveTowardsTargetPosition
; ===========================================================================
; loc_144B6
Obj6F_Emerald6:
                addq.w  #1,d6
; loc_144B8
Obj6F_Emerald5:
                addq.w  #1,d6
; loc_144BA
Obj6F_Emerald4:
                addq.w  #1,d6
; loc_144BC
Obj6F_Emerald3:
                addq.w  #1,d6
; loc_144BE
Obj6F_Emerald2:
                addq.w  #1,d6
; loc_144C0
Obj6F_Emerald1:
                addq.w  #1,d6
; loc_144C2
Obj6F_Emerald0:
                lea     (Got_Emeralds_array).w,a1
                tst.b   (a1,d6.w)
                beq.w   DeleteObject
                btst    #0,(Vint_runcount+3).w
                beq.s   +
                bsr.w   DisplaySprite
+
                rts
; ===========================================================================
; loc_144DC
Obj6F_P2Rings:
                tst.w   (Player_mode).w
                bne.w   DeleteObject
                cmpi.b  #$26,(SpecialStageResults+routine).w  ; Do we need space for perfect countdown?
                beq.w   DeleteObject                    ; Branch if yes
                moveq   #$E,d0                          ; "Miles rings"
                btst    #7,(Graphics_Flags).w
                beq.s   +
                addq.w  #1,d0                           ; "Tails rings"
+
                lea     (Bonus_Countdown_2).w,a1
                bra.s   loc_1455A
; ===========================================================================
; loc_14500
Obj6F_P1Rings:
                cmpi.b  #$26,(SpecialStageResults+routine).w  ; Do we need space for perfect countdown?
                bne.s   +                               ; Branch if not
                move.w  #5000,(Bonus_Countdown_1).w     ; Perfect bonus
                move.b  #$2A,routine(a0)                ; => Obj6F_PerfectBonus
                move.w  #spriteScreenPositionYCentered(48),y_pixel(a0)
                st.b    (Update_Bonus_score).w          ; set to -1 (update)
                move.w  #SndID_Signpost,d0
                jsr     (PlaySound).l
                move.w  #$5A,(SpecialStageResults+anim_frame_duration).w
                bra.w   Obj6F_PerfectBonus
; ===========================================================================
+
                move.w  (Player_mode).w,d0
                beq.s   ++
                move.w  #spriteScreenPositionYCentered(48),y_pixel(a0)
                subq.w  #1,d0
                beq.s   ++
                moveq   #$E,d0                          ; "Miles rings"
                btst    #7,(Graphics_Flags).w
                beq.s   +
                addq.w  #1,d0                           ; "Tails rings"
+
                lea     (Bonus_Countdown_2).w,a1
                bra.s   loc_1455A
; ===========================================================================
+
                moveq   #$D,d0                          ; "Sonic rings"
                lea     (Bonus_Countdown_1).w,a1

loc_1455A:
                tst.w   (a1)
                bne.s   +
                addq.w  #5,d0                           ; Rings text with zero points
+
                move.b  d0,mapping_frame(a0)

BranchTo3_Obj34_MoveTowardsTargetPosition               ; BranchTo
                bra.w   Obj34_MoveTowardsTargetPosition
; ===========================================================================
; loc_14568
Obj6F_DeleteIfNotEmerald:
                tst.b   (Got_Emerald).w
                beq.w   DeleteObject
                bra.s   BranchTo3_Obj34_MoveTowardsTargetPosition
; ===========================================================================
; loc_14572
Obj6F_TimedDisplay:
                subq.w  #1,anim_frame_duration(a0)
                bne.s   BranchTo19_DisplaySprite
                addq.b  #2,routine(a0)

BranchTo19_DisplaySprite                                ; BranchTo
                bra.w   DisplaySprite
; ===========================================================================
; loc_14580
Obj6F_TallyScore:
                bsr.w   DisplaySprite
                move.b  #1,(Update_Bonus_score).w
                moveq   #0,d0
                tst.w   (Bonus_Countdown_1).w
                beq.s   +
                addi.w  #10,d0
                subq.w  #1,(Bonus_Countdown_1).w
+
                tst.w   (Bonus_Countdown_2).w
                beq.s   +
                addi.w  #10,d0
                subq.w  #1,(Bonus_Countdown_2).w
+
                tst.w   (Total_Bonus_Countdown).w
                beq.s   +
                addi.w  #10,d0
                subi.w  #10,(Total_Bonus_Countdown).w
+
                tst.w   d0
                bne.s   +++
                move.w  #SndID_TallyEnd,d0
                jsr     (PlaySound).l
                addq.b  #2,routine(a0)                  ; => Obj6F_TimedDisplay
                move.w  #$78,anim_frame_duration(a0)
                tst.w   (Perfect_rings_flag).w
                bne.s   +
                cmpi.w  #2,(Player_mode).w
                beq.s   ++                              ; rts
                tst.b   (Got_Emerald).w
                beq.s   ++                              ; rts
                cmpi.b  #7,(Emerald_count).w
                bne.s   ++                              ; rts
                move.b  #$30,routine(a0)                ; => Obj6F_InitAndMoveSuperMsg
                rts
; ===========================================================================
+
                move.b  #$24,routine(a0)                ; => Obj6F_TimedDisplay
                move.w  #$5A,anim_frame_duration(a0)
/
                rts
; ===========================================================================
+
                jsr     (AddPoints).l
                move.b  (Vint_runcount+3).w,d0
                andi.b  #3,d0
                bne.s   -                               ; rts
                move.w  #SndID_Blip,d0
                jmp     (PlaySound).l
; ===========================================================================
; loc_1461C
Obj6F_DisplayOnly:
                move.w  #1,(Level_Inactive_flag).w
                bra.w   DisplaySprite
; ===========================================================================
; loc_14626
Obj6F_TallyPerfect:
                bsr.w   DisplaySprite
                move.b  #1,(Update_Bonus_score).w
                moveq   #0,d0
                tst.w   (Bonus_Countdown_1).w
                beq.s   +
                addi.w  #20,d0
                subi.w  #20,(Bonus_Countdown_1).w
+
                tst.w   d0
                beq.s   +
                jsr     (AddPoints).l
                move.b  (Vint_runcount+3).w,d0
                andi.b  #3,d0
                bne.s   ++                              ; rts
                move.w  #SndID_Blip,d0
                jmp     (PlaySound).l
; ===========================================================================
+
                move.w  #SndID_TallyEnd,d0
                jsr     (PlaySound).l
                addq.b  #4,routine(a0)
                move.w  #$78,anim_frame_duration(a0)
                cmpi.w  #2,(Player_mode).w
                beq.s   +                               ; rts
                tst.b   (Got_Emerald).w
                beq.s   +                               ; rts
                cmpi.b  #7,(Emerald_count).w
                bne.s   +                               ; rts
                move.b  #$30,routine(a0)                ; => Obj6F_InitAndMoveSuperMsg
+
                rts
; ===========================================================================
; loc_14692
Obj6F_PerfectBonus:
                moveq   #$11,d0                         ; "Perfect bonus"
                btst    #3,(Vint_runcount+3).w
                beq.s   +
                moveq   #$15,d0                         ; null text
+
                move.b  d0,mapping_frame(a0)
                bra.w   DisplaySprite
; ===========================================================================
; loc_146A6
Obj6F_InitAndMoveSuperMsg:
                move.b  #$32,next_object+routine(a0)    ; => Obj6F_MoveTowardsSourcePosition
                move.w  x_pixel(a0),d0
                cmp.w   titlecard_x_source(a0),d0
                bne.s   Obj6F_MoveTowardsSourcePosition
                move.b  #$14,next_object+routine(a0)    ; => BranchTo3_Obj34_MoveTowardsTargetPosition
                subq.w  #8,next_object+y_pixel(a0)
                move.b  #$1A,next_object+mapping_frame(a0)  ; "Now Sonic can"
                move.b  #$34,routine(a0)                ; => Obj6F_MoveAndDisplay
                subq.w  #8,y_pixel(a0)
                move.b  #$1B,mapping_frame(a0)          ; "Change into"
                lea     (SpecialStageResults2).w,a1
                _move.b id(a0),id(a1)                   ; load obj6F; (uses screen-space)
                clr.w   x_pixel(a1)
                move.w  #spriteScreenPositionXCentered(0),titlecard_x_target(a1)
                move.w  #spriteScreenPositionYCentered(-60),y_pixel(a1)
                move.b  #$14,routine(a1)                ; => BranchTo3_Obj34_MoveTowardsTargetPosition
                move.b  #$1C,mapping_frame(a1)          ; "Super Sonic"
                move.l  #Obj6F_MapUnc_14ED0,mappings(a1)
                move.b  #$78,width_pixels(a1)
                move.b  #0,render_flags(a1)
                bra.w   DisplaySprite
; ===========================================================================
; Modified copy of `Obj34_MoveTowardsTargetPosition`. It has a higher speed
; and moves the object toward its source instead of its destination
; loc_14714 Obj6F_MoveToTargetPos
Obj6F_MoveTowardsSourcePosition:
                moveq   #$20,d0                         ; Movement speed
                move.w  x_pixel(a0),d1
                cmp.w   titlecard_x_source(a0),d1
                beq.s   .display
                bhi.s   +
                neg.w   d0
+
                sub.w   d0,x_pixel(a0)
; If target lies very far off-screen, then don't bother trying to display it
; This is because the sprite coordinates are prone to overflow and underflow
                cmpi.w  #$200,x_pixel(a0)
                bhi.s   .return
; BranchTo20_DisplaySprite
.display:
                bra.w   DisplaySprite
.return:
                rts
; ===========================================================================
; loc_14736
Obj6F_MoveAndDisplay:
                move.w  x_pixel(a0),d0
                cmp.w   titlecard_x_target(a0),d0
                bne.w   Obj34_MoveTowardsTargetPosition
                move.w  #$B4,anim_frame_duration(a0)
                move.b  #$20,routine(a0)                ; => Obj6F_TimedDisplay
                bra.w   DisplaySprite
; ===========================================================================
; byte_14752
Obj6F_SubObjectMetaData:
; start X,          target X, start Y, routine, map frame
                results_screen_object spriteScreenPositionX(screen_width+128), spriteScreenPositionXCentered(0),     -70,       2,         0  ; "Special Stage"
                results_screen_object 0, spriteScreenPositionXCentered(0),     -88,       4,         1  ; "Sonic got a"
                results_screen_object spriteScreenPositionXCentered( -8),                                     0,     -44,       6,         5  ; Emerald 0
                results_screen_object spriteScreenPositionXCentered( 16),                                     0,     -32,       8,         6  ; Emerald 1
                results_screen_object spriteScreenPositionXCentered( 16),                                     0,      -8,      $A,         7  ; Emerald 2
                results_screen_object spriteScreenPositionXCentered( -8),                                     0,       4,      $C,         8  ; Emerald 3
                results_screen_object spriteScreenPositionXCentered(-32),                                     0,      -8,      $E,         9  ; Emerald 4
                results_screen_object spriteScreenPositionXCentered(-32),                                     0,     -32,     $10,        $A  ; Emerald 5
                results_screen_object spriteScreenPositionXCentered( -8),                                     0,     -20,     $12,        $B  ; Emerald 6
                results_screen_object spriteScreenPositionX(screen_width+368), spriteScreenPositionXCentered(0),      24,     $14,        $C  ; Score
                results_screen_object spriteScreenPositionX(screen_width+384), spriteScreenPositionXCentered(0),      40,     $16,        $D  ; Sonic Rings
                results_screen_object spriteScreenPositionX(screen_width+400), spriteScreenPositionXCentered(0),      56,     $18,        $E  ; Miles Rings
                results_screen_object spriteScreenPositionX(screen_width+416), spriteScreenPositionXCentered(0),      72,     $1A,       $10  ; Gems Bonus
Obj6F_SubObjectMetaData_End:

; -------------------------------------------------------------------------------
; sprite mappings - zone title cards
; Note: if you modify these mappings, also adjust the characters
; loaded into VRAM in TitleCardLetters
; -------------------------------------------------------------------------------
; Obj34_MapUnc_147BA:
MapUnc_TitleCards:  mappingsTable
.zone_names:        zoneOrderedOffsetTable 2,1
                zoneOffsetTableEntry.w TC_EHZ           ; Emerald Hill Zone
                zoneOffsetTableEntry.w TC_EHZ           ; XXX unused (unknown)
                zoneOffsetTableEntry.w TC_EHZ           ; XXX unused (Wood Zone)
                zoneOffsetTableEntry.w TC_EHZ           ; XXX unused (unknown)
                zoneOffsetTableEntry.w TC_MTZ           ; Metropolis Zone Act 1 and 2
                zoneOffsetTableEntry.w TC_MTZ           ; Metropolis Zone Act 3
                zoneOffsetTableEntry.w TC_WFZ           ; Wing Fortress Zone
                zoneOffsetTableEntry.w TC_HTZ           ; Hill Top Zone
                zoneOffsetTableEntry.w TC_HPZ           ; XXX Hidden Palace Zone
                zoneOffsetTableEntry.w TC_EHZ           ; XXX unused (Cyber City Zone)
                zoneOffsetTableEntry.w TC_OOZ           ; Oil Ocean Zone
                zoneOffsetTableEntry.w TC_MCZ           ; Mystic Cave Zone
                zoneOffsetTableEntry.w TC_CNZ           ; Casino Night Zone
                zoneOffsetTableEntry.w TC_CPZ           ; Chemical Plant Zone
                zoneOffsetTableEntry.w TC_DEZ           ; Death Egg Zone
                zoneOffsetTableEntry.w TC_ARZ           ; Aquatic Ruin Zone
                zoneOffsetTableEntry.w TC_SCZ           ; Sky Chase Zone
                zoneTableEnd
                mappingsTableEntry.w TC_ZONE            ; "ZONE" text
                mappingsTableEntry.w TC_No1             ; Act number 1
                mappingsTableEntry.w TC_No2             ; Act number 2
                mappingsTableEntry.w TC_No3             ; Act number 3
                mappingsTableEntry.w TC_STH             ; "SONIC THE HEDGEHOG" text
                mappingsTableEntry.w TC_RedStripes      ; Red stripes

; word_147E8:
TC_EHZ:         spriteHeader                            ; EMERALD HILL
                spritePiece -$3D, 0, 2, 2, $580, 0, 0, 0, 1  ; E
                spritePiece -$30, 0, 3, 2, $5DE, 0, 0, 0, 1  ; M
                spritePiece -$18, 0, 2, 2, $580, 0, 0, 0, 1  ; E
                spritePiece -8, 0, 2, 2, $5E4, 0, 0, 0, 1  ; R
                spritePiece 8, 0, 2, 2, $5E8, 0, 0, 0, 1  ; A
                spritePiece $18, 0, 2, 2, $5EC, 0, 0, 0, 1  ; L
                spritePiece $28, 0, 2, 2, $5F0, 0, 0, 0, 1  ; D

                spritePiece $48, 0, 2, 2, $5F4, 0, 0, 0, 1  ; H
                spritePiece $58, 0, 1, 2, $5F8, 0, 0, 0, 1  ; I
                spritePiece $60, 0, 2, 2, $5EC, 0, 0, 0, 1  ; L
                spritePiece $70, 0, 2, 2, $5EC, 0, 0, 0, 1  ; L
TC_EHZ_End

; word_14842:
TC_MTZ:         spriteHeader                            ; METROPOLIS
                spritePiece -$20, 0, 3, 2, $5DE, 0, 0, 0, 1  ; M
                spritePiece -8, 0, 2, 2, $580, 0, 0, 0, 1  ; E
                spritePiece 8, 0, 2, 2, $5E4, 0, 0, 0, 1  ; T
                spritePiece $18, 0, 2, 2, $5E8, 0, 0, 0, 1  ; R
                spritePiece $28, 0, 2, 2, $588, 0, 0, 0, 1  ; O
                spritePiece $38, 0, 2, 2, $5EC, 0, 0, 0, 1  ; P
                spritePiece $48, 0, 2, 2, $588, 0, 0, 0, 1  ; O
                spritePiece $58, 0, 2, 2, $5F0, 0, 0, 0, 1  ; L
                spritePiece $68, 0, 1, 2, $5F4, 0, 0, 0, 1  ; I
                spritePiece $70, 0, 2, 2, $5F6, 0, 0, 0, 1  ; S
TC_MTZ_End

; word_14894:
TC_HTZ:         spriteHeader                            ; HILL TOP
                spritePiece 8, 0, 2, 2, $5DE, 0, 0, 0, 1  ; H
                spritePiece $18, 0, 1, 2, $5E2, 0, 0, 0, 1  ; I
                spritePiece $20, 0, 2, 2, $5E4, 0, 0, 0, 1  ; L
                spritePiece $30, 0, 2, 2, $5E4, 0, 0, 0, 1  ; L

                spritePiece $51, 0, 2, 2, $5E8, 0, 0, 0, 1  ; T
                spritePiece $60, 0, 2, 2, $588, 0, 0, 0, 1  ; O
                spritePiece $70, 0, 2, 2, $5EC, 0, 0, 0, 1  ; P
TC_HTZ_End

; word_148CE:
TC_HPZ:         spriteHeader                            ; HIDDEN PALACE
                spritePiece -$48, 0, 2, 2, $5DE, 0, 0, 0, 1  ; H
                spritePiece -$38, 0, 1, 2, $5E2, 0, 0, 0, 1  ; I
                spritePiece -$30, 0, 2, 2, $5E4, 0, 0, 0, 1  ; D
                spritePiece -$20, 0, 2, 2, $5E4, 0, 0, 0, 1  ; D
                spritePiece -$10, 0, 2, 2, $580, 0, 0, 0, 1  ; E
                spritePiece 0, 0, 2, 2, $584, 0, 0, 0, 1  ; N

                spritePiece $20, 0, 2, 2, $5E8, 0, 0, 0, 1  ; P
                spritePiece $30, 0, 2, 2, $5EC, 0, 0, 0, 1  ; A
                spritePiece $40, 0, 2, 2, $5F0, 0, 0, 0, 1  ; L
                spritePiece $50, 0, 2, 2, $5EC, 0, 0, 0, 1  ; A
                spritePiece $60, 0, 2, 2, $5F4, 0, 0, 0, 1  ; C
                spritePiece $70, 0, 2, 2, $580, 0, 0, 0, 1  ; E
TC_HPZ_End

; word_14930:
TC_OOZ:         spriteHeader                            ; OIL OCEAN
                spritePiece -5, 0, 2, 2, $588, 0, 0, 0, 1  ; O
                spritePiece $B, 0, 1, 2, $5DE, 0, 0, 0, 1  ; I
                spritePiece $13, 0, 2, 2, $5E0, 0, 0, 0, 1  ; L

                spritePiece $33, 0, 2, 2, $588, 0, 0, 0, 1  ; O
                spritePiece $43, 0, 2, 2, $5E4, 0, 0, 0, 1  ; C
                spritePiece $53, 0, 2, 2, $580, 0, 0, 0, 1  ; E
                spritePiece $60, 0, 2, 2, $5E8, 0, 0, 0, 1  ; A
                spritePiece $70, 0, 2, 2, $584, 0, 0, 0, 1  ; N
TC_OOZ_End

; word_14972:
TC_MCZ:         spriteHeader                            ; MYSTIC CAVE
                spritePiece -$30, 0, 3, 2, $5DE, 0, 0, 0, 1  ; M
                spritePiece -$18, 0, 2, 2, $5E4, 0, 0, 0, 1  ; Y
                spritePiece -8, 0, 2, 2, $5E8, 0, 0, 0, 1  ; S
                spritePiece 8, 0, 2, 2, $5EC, 0, 0, 0, 1  ; T
                spritePiece $18, 0, 1, 2, $5F0, 0, 0, 0, 1  ; I
                spritePiece $20, 0, 2, 2, $5F2, 0, 0, 0, 1  ; C

                spritePiece $41, 0, 2, 2, $5F2, 0, 0, 0, 1  ; C
                spritePiece $50, 0, 2, 2, $5F6, 0, 0, 0, 1  ; A
                spritePiece $60, 0, 2, 2, $5FA, 0, 0, 0, 1  ; V
                spritePiece $70, 0, 2, 2, $580, 0, 0, 0, 1  ; E
TC_MCZ_End

; word_149C4:
TC_CNZ:         spriteHeader                            ; CASINO NIGHT
                spritePiece -$2F, 0, 2, 2, $5DE, 0, 0, 0, 1  ; C
                spritePiece -$20, 0, 2, 2, $5E2, 0, 0, 0, 1  ; A
                spritePiece -$10, 0, 2, 2, $5E6, 0, 0, 0, 1  ; S
                spritePiece 0, 0, 1, 2, $5EA, 0, 0, 0, 1  ; I
                spritePiece 8, 0, 2, 2, $584, 0, 0, 0, 1  ; N
                spritePiece $18, 0, 2, 2, $588, 0, 0, 0, 1  ; O

                spritePiece $38, 0, 2, 2, $584, 0, 0, 0, 1  ; N
                spritePiece $48, 0, 1, 2, $5EA, 0, 0, 0, 1  ; I
                spritePiece $50, 0, 2, 2, $5EC, 0, 0, 0, 1  ; G
                spritePiece $60, 0, 2, 2, $5F0, 0, 0, 0, 1  ; H
                spritePiece $70, 0, 2, 2, $5F4, 0, 0, 0, 1  ; T
TC_CNZ_End

; word_14A1E:
TC_CPZ:         spriteHeader                            ; CHEMICAL PLANT
                spritePiece -$5C, 0, 2, 2, $5DE, 0, 0, 0, 1  ; C
                spritePiece -$4C, 0, 2, 2, $5E2, 0, 0, 0, 1  ; H
                spritePiece -$3C, 0, 2, 2, $580, 0, 0, 0, 1  ; E
                spritePiece -$2F, 0, 3, 2, $5E6, 0, 0, 0, 1  ; M
                spritePiece -$17, 0, 1, 2, $5EC, 0, 0, 0, 1  ; I
                spritePiece -$F, 0, 2, 2, $5DE, 0, 0, 0, 1  ; C
                spritePiece 0, 0, 2, 2, $5EE, 0, 0, 0, 1  ; A
                spritePiece $10, 0, 2, 2, $5F2, 0, 0, 0, 1  ; L

                spritePiece $31, 0, 2, 2, $5F6, 0, 0, 0, 1  ; P
                spritePiece $41, 0, 2, 2, $5F2, 0, 0, 0, 1  ; L
                spritePiece $50, 0, 2, 2, $5EE, 0, 0, 0, 1  ; A
                spritePiece $60, 0, 2, 2, $584, 0, 0, 0, 1  ; N
                spritePiece $70, 0, 2, 2, $5FA, 0, 0, 0, 1  ; T
TC_CPZ_End

; word_14A88:
TC_ARZ:         spriteHeader                            ; AQUATIC RUIN
                spritePiece -$2E, 0, 2, 2, $5DE, 0, 0, 0, 1  ; A
                spritePiece -$1E, 0, 2, 2, $5E2, 0, 0, 0, 1  ; Q
                spritePiece -$E, 0, 2, 2, $5E6, 0, 0, 0, 1  ; U
                spritePiece 0, 0, 2, 2, $5DE, 0, 0, 0, 1  ; A
                spritePiece $10, 0, 2, 2, $5EA, 0, 0, 0, 1  ; T
                spritePiece $20, 0, 1, 2, $5EE, 0, 0, 0, 1  ; I
                spritePiece $28, 0, 2, 2, $5F0, 0, 0, 0, 1  ; C

                spritePiece $48, 0, 2, 2, $5F4, 0, 0, 0, 1  ; R
                spritePiece $58, 0, 2, 2, $5E6, 0, 0, 0, 1  ; U
                spritePiece $68, 0, 1, 2, $5EE, 0, 0, 0, 1  ; I
                spritePiece $70, 0, 2, 2, $584, 0, 0, 0, 1  ; N
TC_ARZ_End

; word_14AE2:
TC_SCZ:         spriteHeader                            ; SKY CHASE
                spritePiece -$10, 0, 2, 2, $5DE, 0, 0, 0, 1  ; S
                spritePiece 0, 0, 2, 2, $5E2, 0, 0, 0, 1  ; K
                spritePiece $10, 0, 2, 2, $5E6, 0, 0, 0, 1  ; Y

                spritePiece $30, 0, 2, 2, $5EA, 0, 0, 0, 1  ; C
                spritePiece $40, 0, 2, 2, $5EE, 0, 0, 0, 1  ; H
                spritePiece $50, 0, 2, 2, $5F2, 0, 0, 0, 1  ; A
                spritePiece $60, 0, 2, 2, $5DE, 0, 0, 0, 1  ; S
                spritePiece $70, 0, 2, 2, $580, 0, 0, 0, 1  ; E
TC_SCZ_End

; word_14B24:
TC_WFZ:         spriteHeader                            ; WING FORTRESS
                spritePiece -$4F, 0, 3, 2, $5DE, 0, 0, 0, 1  ; W
                spritePiece -$38, 0, 1, 2, $5E4, 0, 0, 0, 1  ; I
                spritePiece -$30, 0, 2, 2, $584, 0, 0, 0, 1  ; N
                spritePiece -$20, 0, 2, 2, $5E6, 0, 0, 0, 1  ; G

                spritePiece 1, 0, 2, 2, $5EA, 0, 0, 0, 1  ; F
                spritePiece $10, 0, 2, 2, $588, 0, 0, 0, 1  ; O
                spritePiece $20, 0, 2, 2, $5EE, 0, 0, 0, 1  ; R
                spritePiece $30, 0, 2, 2, $5F2, 0, 0, 0, 1  ; T
                spritePiece $40, 0, 2, 2, $5EE, 0, 0, 0, 1  ; R
                spritePiece $50, 0, 2, 2, $580, 0, 0, 0, 1  ; E
                spritePiece $5F, 0, 2, 2, $5F6, 0, 0, 0, 1  ; S
                spritePiece $6F, 0, 2, 2, $5F6, 0, 0, 0, 1  ; S
TC_WFZ_End

; word_14B86:
TC_DEZ:         spriteHeader                            ; DEATH EGG
                spritePiece -$E, 0, 2, 2, $5DE, 0, 0, 0, 1  ; D
                spritePiece 2, 0, 2, 2, $580, 0, 0, 0, 1  ; E
                spritePiece $10, 0, 2, 2, $5E2, 0, 0, 0, 1  ; A
                spritePiece $20, 0, 2, 2, $5E6, 0, 0, 0, 1  ; T
                spritePiece $30, 0, 2, 2, $5EA, 0, 0, 0, 1  ; H

                spritePiece $51, 0, 2, 2, $580, 0, 0, 0, 1  ; E
                spritePiece $60, 0, 2, 2, $5EE, 0, 0, 0, 1  ; G
                spritePiece $70, 0, 2, 2, $5EE, 0, 0, 0, 1  ; G
TC_DEZ_End

; Miscellaneous title card mappings

; word_14BC8:
TC_ZONE:        spriteHeader                            ; ZONE
                spritePiece 1, 0, 2, 2, $58C, 0, 0, 0, 1  ; Z
                spritePiece $10, 0, 2, 2, $588, 0, 0, 0, 1  ; O
                spritePiece $20, 0, 2, 2, $584, 0, 0, 0, 1  ; N
                spritePiece $30, 0, 2, 2, $580, 0, 0, 0, 1  ; E
TC_ZONE_End

; word_14BEA:
TC_No1:         spriteHeader                            ; Act number 1
                spritePiece 0, 0, 2, 4, $590, 0, 0, 1, 1  ; 1
TC_No1_End

; word_14BF4:
TC_No2:         spriteHeader                            ; Act number 2
                spritePiece 0, 0, 3, 4, $598, 0, 0, 1, 1  ; 2
TC_No2_End

; word_14BFE:
TC_No3:         spriteHeader                            ; Act number 3
                spritePiece 0, 0, 3, 4, $5A4, 0, 0, 1, 1  ; 3
TC_No3_End

; word_14C08:
TC_STH:         spriteHeader                            ; "SONIC THE HEDGEHOG" text
                spritePiece -$48, 0, 4, 2, $5B0, 0, 0, 0, 1
                spritePiece -$28, 0, 4, 2, $5B8, 0, 0, 0, 1
                spritePiece -8, 0, 4, 2, $5C0, 0, 0, 0, 1
                spritePiece $18, 0, 4, 2, $5C8, 0, 0, 0, 1
                spritePiece $38, 0, 2, 2, $5D0, 0, 0, 0, 1
TC_STH_End

; word_14C32:
TC_RedStripes:  spriteHeader                            ; Red stripes
                spritePiece 0, -$70, 1, 4, $5D4, 0, 0, 0, 1
                spritePiece 0, -$50, 1, 4, $5D4, 0, 0, 0, 1
                spritePiece 0, -$30, 1, 4, $5D4, 0, 0, 0, 1
                spritePiece 0, -$10, 1, 4, $5D4, 0, 0, 0, 1
                spritePiece 0, $10, 1, 4, $5D4, 0, 0, 0, 1
                spritePiece 0, $30, 1, 4, $5D4, 0, 0, 0, 1
                spritePiece 0, $50, 1, 4, $5D4, 0, 0, 0, 1
TC_RedStripes_End

                even

; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj39_MapUnc_14C6C: include "src/ui/objects/game_over/data/mappings.s"

; -------------------------------------------------------------------------------
; sprite mappings - end-of-level results screen title cards
; Note: only the following letters are included in the font art
; A, C, G, H, I, L, M, R, S, T, U
; -------------------------------------------------------------------------------
; Obj3A_MapUnc_14CBC:
MapUnc_EOLTitleCards:   mappingsTable
                mappingsTableEntry.w EOL_Sonic          ; "SONIC GOT" text
                mappingsTableEntry.w EOL_Miles          ; "MILES GOT" text (Japanese region)
                mappingsTableEntry.w EOL_Tails          ; "TAILS GOT" text (international region)
                mappingsTableEntry.w EOL_Through        ; "THROUGH" text
                mappingsTableEntry.w EOL_Act            ; "ACT" text

                mappingsTableEntry.w TC_ZONE            ; "ZONE" text
                mappingsTableEntry.w TC_No1             ; "1" text
                mappingsTableEntry.w TC_No2             ; "2" text
                mappingsTableEntry.w TC_No3             ; "3" text

                mappingsTableEntry.w EOL_Total          ; Total text
                mappingsTableEntry.w EOL_TimeBonus      ; Time Bonus text
                mappingsTableEntry.w EOL_RingBonus      ; Ring Bonus text
                mappingsTableEntry.w EOL_SonFrame1      ; Mini Sonic, frame 1
                mappingsTableEntry.w EOL_SonFrame2      ; Mini Sonic, frame 2
                mappingsTableEntry.w EOL_Perfect        ; Perfect text

; word_14CDA:
EOL_Sonic:      spriteHeader                            ; SONIC GOT
                spritePiece -$40, 0, 2, 2, $5D0, 0, 0, 0, 1  ; S
                spritePiece -$30, 0, 2, 2, $588, 0, 0, 0, 1  ; O
                spritePiece -$20, 0, 2, 2, $584, 0, 0, 0, 1  ; N
                spritePiece -$10, 0, 1, 2, $5C0, 0, 0, 0, 1  ; I
                spritePiece -8, 0, 2, 2, $5B4, 0, 0, 0, 1  ; C

                spritePiece $10, 0, 2, 2, $5B8, 0, 0, 0, 1  ; G
                spritePiece $20, 0, 2, 2, $588, 0, 0, 0, 1  ; O
                spritePiece $2F, 0, 2, 2, $5D4, 0, 0, 0, 1  ; T
EOL_Sonic_End

; word_14D1C:
EOL_Miles:      spriteHeader                            ; MILES GOT
                spritePiece -$44, 0, 3, 2, $5C6, 0, 0, 0, 1  ; M
                spritePiece -$2C, 0, 1, 2, $5C0, 0, 0, 0, 1  ; I
                spritePiece -$24, 0, 2, 2, $5C2, 0, 0, 0, 1  ; L
                spritePiece -$14, 0, 2, 2, $580, 0, 0, 0, 1  ; E
                spritePiece -4, 0, 2, 2, $5D0, 0, 0, 0, 1  ; S

                spritePiece $14, 0, 2, 2, $5B8, 0, 0, 0, 1  ; G
                spritePiece $24, 0, 2, 2, $588, 0, 0, 0, 1  ; O
                spritePiece $33, 0, 2, 2, $5D4, 0, 0, 0, 1  ; T
EOL_Miles_End

; word_14D5E:
EOL_Tails:      spriteHeader                            ; TAILS GOT
                spritePiece -$3D, 0, 2, 2, $5D4, 0, 0, 0, 1  ; T
                spritePiece -$30, 0, 2, 2, $5B0, 0, 0, 0, 1  ; A
                spritePiece -$20, 0, 1, 2, $5C0, 0, 0, 0, 1  ; I
                spritePiece -$18, 0, 2, 2, $5C2, 0, 0, 0, 1  ; L
                spritePiece -8, 0, 2, 2, $5D0, 0, 0, 0, 1  ; S

                spritePiece $10, 0, 2, 2, $5B8, 0, 0, 0, 1  ; G
                spritePiece $20, 0, 2, 2, $588, 0, 0, 0, 1  ; O
                spritePiece $2F, 0, 2, 2, $5D4, 0, 0, 0, 1  ; T
EOL_Tails_End

; word_14DA0:
EOL_Through:    spriteHeader                            ; THROUGH
                spritePiece -$38, 0, 2, 2, $5D4, 0, 0, 0, 1  ; T
                spritePiece -$28, 0, 2, 2, $5BC, 0, 0, 0, 1  ; H
                spritePiece -$18, 0, 2, 2, $5CC, 0, 0, 0, 1  ; R
                spritePiece -8, 0, 2, 2, $588, 0, 0, 0, 1  ; O
                spritePiece 8, 0, 2, 2, $5D8, 0, 0, 0, 1  ; U
                spritePiece $18, 0, 2, 2, $5B8, 0, 0, 0, 1  ; G
                spritePiece $28, 0, 2, 2, $5BC, 0, 0, 0, 1  ; H
EOL_Through_End

; word_14DDA:
EOL_Act:        spriteHeader                            ; ACT
                spritePiece 0, 0, 2, 2, $5B0, 0, 0, 0, 1  ; A
                spritePiece $10, 0, 2, 2, $5B4, 0, 0, 0, 1  ; C
                spritePiece $1F, 0, 2, 2, $5D4, 0, 0, 0, 1  ; T
EOL_Act_End

; Miscellaneous end-of-level results screen title cards mappings

; word_14DF4:
EOL_Total:      spriteHeader                            ; Total text
                spritePiece -$48, 0, 3, 2, $5E6, 0, 0, 1, 1
                spritePiece -$30, 0, 2, 2, $5EC, 0, 0, 1, 1
                spritePiece -$2C, 0, 2, 2, $5F0, 0, 0, 0, 1
                spritePiece $38, 0, 4, 2, $520, 0, 0, 0, 1
                spritePiece $58, 0, 1, 2, $6F0, 0, 0, 0, 1
EOL_Total_End

; word_14E1E:
EOL_TimeBonus:  spriteHeader                            ; Time Bonus text
                spritePiece -$5C, 0, 4, 2, $6DA, 0, 0, 1, 1
                spritePiece -$34, 0, 4, 2, $5DE, 0, 0, 1, 1
                spritePiece -$14, 0, 1, 2, $6CA, 0, 0, 1, 1
                spritePiece -$18, 0, 2, 2, $5F0, 0, 0, 0, 1
                spritePiece $38, 0, 4, 2, $528, 0, 0, 0, 1
                spritePiece $58, 0, 1, 2, $6F0, 0, 0, 0, 1
EOL_TimeBonus_End

; word_14E50:
EOL_RingBonus:  spriteHeader                            ; Ring Bonus text
                spritePiece -$5C, 0, 4, 2, $6D2, 0, 0, 1, 1
                spritePiece -$34, 0, 4, 2, $5DE, 0, 0, 1, 1
                spritePiece -$14, 0, 1, 2, $6CA, 0, 0, 1, 1
                spritePiece -$18, 0, 2, 2, $5F0, 0, 0, 0, 1
                spritePiece $38, 0, 4, 2, $530, 0, 0, 0, 1
                spritePiece $58, 0, 1, 2, $6F0, 0, 0, 0, 1
EOL_RingBonus_End

; word_14E82:
EOL_SonFrame1:  spriteHeader                            ; Mini Sonic, frame 1
                spritePiece 0, 0, 2, 3, $5F4, 0, 0, 0, 1
EOL_SonFrame1_End

; word_14E8C:
EOL_SonFrame2:  spriteHeader                            ; Mini Sonic, frame 2
                spritePiece 0, 0, 2, 3, $5FA, 0, 0, 0, 1
EOL_SonFrame2_End

; word_14E96:
EOL_Perfect:    spriteHeader                            ; Perfect text
                spritePiece -$68, 0, 4, 2, $540, 0, 0, 1, 1
                spritePiece -$48, 0, 3, 2, $548, 0, 0, 1, 1
                spritePiece -$28, 0, 4, 2, $5DE, 0, 0, 1, 1
                spritePiece -8, 0, 1, 2, $6CA, 0, 0, 1, 1
                spritePiece -$C, 0, 2, 2, $5F0, 0, 0, 0, 1
                spritePiece $38, 0, 4, 2, $538, 0, 0, 0, 1
                spritePiece $58, 0, 1, 2, $6F0, 0, 0, 0, 1
EOL_Perfect_End

                even

; -------------------------------------------------------------------------------
; sprite mappings
; -------------------------------------------------------------------------------
Obj6F_MapUnc_14ED0: include "src/game/special_stage/objects/results/data/mappings.s"
; ===========================================================================

; loc_15584: ; level title card drawing function called from Vint
