Obj03:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj03_Index(pc,d0.w),d1
                jsr     Obj03_Index(pc,d1.w)
                jmp     (MarkObjGone3).l
; ===========================================================================
; off_1FCF0:
Obj03_Index:    offsetTable
                offsetTableEntry.w Obj03_Init           ; 0
                offsetTableEntry.w Obj03_MainX          ; 2
                offsetTableEntry.w Obj03_MainY          ; 4
; ===========================================================================
; loc_1FCF6:
Obj03_Init:
                addq.b  #2,routine(a0)                  ; => Obj03_MainX
                move.l  #Obj03_MapUnc_1FFB8,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_Ring,1,0),art_tile(a0)
                jsrto   JmpTo7_Adjust2PArtPointer
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  #$10,width_pixels(a0)
                move.b  #5,priority(a0)
                move.b  subtype(a0),d0
                btst    #2,d0
                beq.s   Obj03_Init_CheckX
; Obj03_Init_CheckY:
                addq.b  #2,routine(a0)                  ; => Obj03_MainY
                andi.w  #7,d0
                move.b  d0,mapping_frame(a0)
                andi.w  #3,d0
                add.w   d0,d0
                move.w  word_1FD68(pc,d0.w),planeswitch_radius(a0)
                move.w  y_pos(a0),d1
                lea     (MainCharacter).w,a1            ; a1=character
                cmp.w   y_pos(a1),d1
                bhs.s   +
                move.b  #1,planeswitch_p1_flag(a0)
+
                lea     (Sidekick).w,a1                 ; a1=character
                cmp.w   y_pos(a1),d1
                bhs.s   +
                move.b  #1,planeswitch_p2_flag(a0)
+
                bra.w   Obj03_MainY
; ===========================================================================
word_1FD68:
                dc.w    $20
                dc.w    $40                             ; 1
                dc.w    $80                             ; 2
                dc.w    $100                            ; 3
; ===========================================================================
; loc_1FD70:
Obj03_Init_CheckX:
                andi.w  #3,d0
                move.b  d0,mapping_frame(a0)
                add.w   d0,d0
                move.w  word_1FD68(pc,d0.w),planeswitch_radius(a0)
                move.w  x_pos(a0),d1
                lea     (MainCharacter).w,a1            ; a1=character
                cmp.w   x_pos(a1),d1
                bhs.s   +
                move.b  #1,planeswitch_p1_flag(a0)
+
                lea     (Sidekick).w,a1                 ; a1=character
                cmp.w   x_pos(a1),d1
                bhs.s   +
                move.b  #1,planeswitch_p2_flag(a0)
+

; loc_1FDA4:
Obj03_MainX:
                tst.w   (Debug_placement_mode).w
                bne.w   SharedCollisionSwitcher_Return
                move.w  x_pos(a0),d1
                lea     planeswitch_p1_flag(a0),a2
                lea     (MainCharacter).w,a1            ; a1=character
                bsr.s   +
                lea     (Sidekick).w,a1                 ; a1=character

+               tst.b   (a2)+
                bne.s   Obj03_MainX_Alt
                cmp.w   x_pos(a1),d1
                bhi.w   SharedCollisionSwitcher_Return
                move.b  #1,-1(a2)
                move.w  y_pos(a0),d2
                move.w  d2,d3
                move.w  planeswitch_radius(a0),d4
                sub.w   d4,d2
                add.w   d4,d3
                move.w  y_pos(a1),d4
                cmp.w   d2,d4
                blt.w   SharedCollisionSwitcher_Return
                cmp.w   d3,d4
                bge.w   SharedCollisionSwitcher_Return
                move.b  subtype(a0),d0
                bpl.s   +
                btst    #status.player.in_air,status(a1)
                bne.w   SharedCollisionSwitcher_Return
+
                btst    #render_flags.x_flip,render_flags(a0)
                bne.s   +
                move.b  #$C,top_solid_bit(a1)
                move.b  #$D,lrb_solid_bit(a1)
                btst    #3,d0
                beq.s   +
                move.b  #$E,top_solid_bit(a1)
                move.b  #$F,lrb_solid_bit(a1)
+
                andi.w  #drawing_mask,art_tile(a1)
                btst    #5,d0
                beq.s   SharedCollisionSwitcher_Return
                ori.w   #high_priority,art_tile(a1)
                bra.s   SharedCollisionSwitcher_Return
; ===========================================================================
; loc_1FE38:
Obj03_MainX_Alt:
                cmp.w   x_pos(a1),d1
                bls.w   SharedCollisionSwitcher_Return
                move.b  #0,-1(a2)
                move.w  y_pos(a0),d2
                move.w  d2,d3
                move.w  planeswitch_radius(a0),d4
                sub.w   d4,d2
                add.w   d4,d3
                move.w  y_pos(a1),d4
                cmp.w   d2,d4
                blt.w   SharedCollisionSwitcher_Return
                cmp.w   d3,d4
                bge.w   SharedCollisionSwitcher_Return
                move.b  subtype(a0),d0
                bpl.s   +
                btst    #status.player.in_air,status(a1)
                bne.w   SharedCollisionSwitcher_Return
+
                btst    #render_flags.x_flip,render_flags(a0)
                bne.s   +
                move.b  #$C,top_solid_bit(a1)
                move.b  #$D,lrb_solid_bit(a1)
                btst    #4,d0
                beq.s   +
                move.b  #$E,top_solid_bit(a1)
                move.b  #$F,lrb_solid_bit(a1)
+
                andi.w  #drawing_mask,art_tile(a1)
                btst    #6,d0
                beq.s   SharedCollisionSwitcher_Return
                ori.w   #high_priority,art_tile(a1)

SharedCollisionSwitcher_Return:
                rts
; ===========================================================================

Obj03_MainY:
                tst.w   (Debug_placement_mode).w
                bne.w   SharedCollisionSwitcher_Return_Variant2
                move.w  y_pos(a0),d1
                lea     planeswitch_p1_flag(a0),a2
                lea     (MainCharacter).w,a1            ; a1=character
                bsr.s   +
                lea     (Sidekick).w,a1                 ; a1=character

+               tst.b   (a2)+
                bne.s   Obj03_MainY_Alt
                cmp.w   y_pos(a1),d1
                bhi.w   SharedCollisionSwitcher_Return_Variant2
                move.b  #1,-1(a2)
                move.w  x_pos(a0),d2
                move.w  d2,d3
                move.w  planeswitch_radius(a0),d4
                sub.w   d4,d2
                add.w   d4,d3
                move.w  x_pos(a1),d4
                cmp.w   d2,d4
                blt.w   SharedCollisionSwitcher_Return_Variant2
                cmp.w   d3,d4
                bge.w   SharedCollisionSwitcher_Return_Variant2
                move.b  subtype(a0),d0
                bpl.s   +
                btst    #status.player.in_air,status(a1)
                bne.w   SharedCollisionSwitcher_Return_Variant2
+
                btst    #render_flags.x_flip,render_flags(a0)
                bne.s   +
                move.b  #$C,top_solid_bit(a1)
                move.b  #$D,lrb_solid_bit(a1)
                btst    #3,d0
                beq.s   +
                move.b  #$E,top_solid_bit(a1)
                move.b  #$F,lrb_solid_bit(a1)
+
                andi.w  #drawing_mask,art_tile(a1)
                btst    #5,d0
                beq.s   SharedCollisionSwitcher_Return_Variant2
                ori.w   #high_priority,art_tile(a1)
                bra.s   SharedCollisionSwitcher_Return_Variant2
; ===========================================================================
; loc_1FF42:
Obj03_MainY_Alt:
                cmp.w   y_pos(a1),d1
                bls.w   SharedCollisionSwitcher_Return_Variant2
                move.b  #0,-1(a2)
                move.w  x_pos(a0),d2
                move.w  d2,d3
                move.w  planeswitch_radius(a0),d4
                sub.w   d4,d2
                add.w   d4,d3
                move.w  x_pos(a1),d4
                cmp.w   d2,d4
                blt.w   SharedCollisionSwitcher_Return_Variant2
                cmp.w   d3,d4
                bge.w   SharedCollisionSwitcher_Return_Variant2
                move.b  subtype(a0),d0
                bpl.s   +
                btst    #status.player.in_air,status(a1)
                bne.w   SharedCollisionSwitcher_Return_Variant2
+
                btst    #render_flags.x_flip,render_flags(a0)
                bne.s   +
                move.b  #$C,top_solid_bit(a1)
                move.b  #$D,lrb_solid_bit(a1)
                btst    #4,d0
                beq.s   +
                move.b  #$E,top_solid_bit(a1)
                move.b  #$F,lrb_solid_bit(a1)
+
                andi.w  #drawing_mask,art_tile(a1)
                btst    #6,d0
                beq.s   SharedCollisionSwitcher_Return_Variant2
                ori.w   #high_priority,art_tile(a1)

SharedCollisionSwitcher_Return_Variant2:
                rts
; ===========================================================================
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Obj03_MapUnc_1FFB8:
Map_obj03:      mappingsTable
                mappingsTableEntry.w Map_obj03_0010
                mappingsTableEntry.w Map_obj03_0032
                mappingsTableEntry.w Map_obj03_0054
                mappingsTableEntry.w Map_obj03_0054
                mappingsTableEntry.w Map_obj03_0076
                mappingsTableEntry.w Map_obj03_0098
                mappingsTableEntry.w Map_obj03_00BA
                mappingsTableEntry.w Map_obj03_00BA

Map_obj03_0010: spriteHeader
                spritePiece -8, -$20, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, 0, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, $10, 2, 2, 0, 0, 0, 0, 0
Map_obj03_0010_End

Map_obj03_0032: spriteHeader
                spritePiece -8, -$40, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, -$20, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, 0, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, $30, 2, 2, 0, 0, 0, 0, 0
Map_obj03_0032_End

Map_obj03_0054: spriteHeader
                spritePiece -8, -$80, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, -$20, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, 0, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, $70, 2, 2, 0, 0, 0, 0, 0
Map_obj03_0054_End

Map_obj03_0076: spriteHeader
                spritePiece -$20, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$10, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece 0, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece $10, -8, 2, 2, 0, 0, 0, 0, 0
Map_obj03_0076_End

Map_obj03_0098: spriteHeader
                spritePiece -$40, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$20, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece 0, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece $30, -8, 2, 2, 0, 0, 0, 0, 0
Map_obj03_0098_End

Map_obj03_00BA: spriteHeader
                spritePiece -$80, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece -$20, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece 0, -8, 2, 2, 0, 0, 0, 0, 0
                spritePiece $70, -8, 2, 2, 0, 0, 0, 0, 0
Map_obj03_00BA_End

                even
; ===========================================================================

                jmpTos  JmpTo7_Adjust2PArtPointer

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 0B - Section of pipe that tips you off from CPZ
; ----------------------------------------------------------------------------
; Sprite_2009C:
