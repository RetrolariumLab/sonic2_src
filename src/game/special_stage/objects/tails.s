Obj10:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj10_Index(pc,d0.w),d1
                jmp     Obj10_Index(pc,d1.w)
; ===========================================================================
; off_347FA:
Obj10_Index:    offsetTable
                offsetTableEntry.w Obj10_Init           ; 0
                offsetTableEntry.w Obj10_MdNormal       ; 1
                offsetTableEntry.w Obj10_MdJump         ; 2
                offsetTableEntry.w Obj10_Index          ; 3 - invalid
                offsetTableEntry.w Obj10_MdAir          ; 4
; ===========================================================================
; loc_34804:
Obj10_Init:
                addq.b  #2,routine(a0)
                moveq   #0,d0
                move.w  d0,ss_x_pos(a0)
                move.w  #$80,d1
                move.w  d1,ss_y_pos(a0)
                add.w   (SS_Offset_X).w,d0
                move.w  d0,x_pos(a0)
                add.w   (SS_Offset_Y).w,d1
                move.w  d1,y_pos(a0)
                move.b  #$E,y_radius(a0)
                move.b  #7,x_radius(a0)
                move.l  #Obj10_MapUnc_34B3E,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_SpecialTails,2,0),art_tile(a0)
                move.b  #1<<render_flags.level_fg,render_flags(a0)
                move.b  #2,priority(a0)
                move.w  #$80,ss_z_pos(a0)
                tst.w   (Player_mode).w
                beq.s   loc_34864
                move.b  #3,priority(a0)
                move.w  #$6E,ss_z_pos(a0)

loc_34864:
                move.w  #$400,ss_init_flip_timer(a0)
                move.b  #$40,angle(a0)
                move.b  #1,(Tails_LastLoadedDPLC).w
                clr.b   collision_property(a0)
                clr.b   ss_dplc_timer(a0)
                bsr.w   LoadSSTailsDynPLC
                movea.l #SpecialStageShadow_Tails,a1
                move.b  #ObjID_SSShadow,id(a1)          ; load obj63 (shadow) at $FFFFB180
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                addi.w  #$18,y_pos(a1)
                move.l  #Obj63_MapUnc_34492,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_SpecialFlatShadow,3,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #4,priority(a1)
                move.l  a0,ss_parent(a1)
                movea.l #SpecialStageTails_Tails,a1
                move.b  #ObjID_SSTailsTails,id(a1)      ; load obj88
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                move.l  #Obj88_MapUnc_34DA8,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_SpecialTails_Tails,2,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  priority(a0),priority(a1)
                subi_.b #1,priority(a1)
                move.l  a0,ss_parent(a1)
                movea.l a1,a0
                move.b  #1,(TailsTails_LastLoadedDPLC).w
                clr.b   ss_dplc_timer(a0)
                movea.l ss_parent(a0),a0                ; load 0bj address
                rts
; ===========================================================================

Obj10_MdNormal:
                tst.b   routine_secondary(a0)
                bne.s   Obj10_Hurt
                bsr.w   SSTailsCPU_Control
                lea     (Ctrl_2_Held_Logical).w,a2
                tst.w   (Player_mode).w
                beq.s   +
                lea     (Ctrl_1_Held_Logical).w,a2
+
                bsr.w   SSPlayer_Move
                bsr.w   SSPlayer_Traction
                moveq   #1,d0
                bsr.w   SSPlayerSwapPositions
                bsr.w   SSObjectMove
                bsr.w   SSAnglePos
                lea     (Ctrl_2_Press_Logical).w,a2
                tst.w   (Player_mode).w
                beq.s   +
                lea     (Ctrl_1_Press_Logical).w,a2
+
                bsr.w   SSPlayer_Jump
                bsr.w   SSPlayer_SetAnimation
                lea     (Tails_Animation).l,a1
                bsr.w   SSPlayer_Animate
                bsr.w   SSPlayer_Collision
                bra.w   LoadSSTailsDynPLC
; ===========================================================================

Obj10_Hurt:
                bsr.w   SSHurt_Animation
                bsr.w   SSPlayerSwapPositions
                bsr.w   SSObjectMove
                bsr.w   SSAnglePos
                bra.w   LoadSSTailsDynPLC
; ===========================================================================

SSTailsCPU_Control:
                tst.b   (SS_2p_Flag).w
                bne.s   +
                tst.w   (Player_mode).w
                beq.s   ++
+
                rts
; ===========================================================================
+
                move.b  (Ctrl_2_Held_Logical).w,d0
                andi.b  #button_up_mask|button_down_mask|button_left_mask|button_right_mask|button_B_mask|button_C_mask|button_A_mask,d0
                beq.s   +
                moveq   #0,d0
                moveq   #bytesToXcnt(SS_Ctrl_Record_Buf_End-SS_Ctrl_Record_Buf,4*2),d1
                lea     (SS_Ctrl_Record_Buf).w,a1
-
; The pointer does not increment, preventing the 'SS_Ctrl_Record_Buf'
; buffer from being cleared!
                move.l  d0,(a1)
                move.l  d0,(a1)
                dbf     d1,-
                move.w  #$B4,(Tails_control_counter).w
                rts
; ===========================================================================
+
                tst.w   (Tails_control_counter).w
                beq.s   +
                subq.w  #1,(Tails_control_counter).w
                rts
; ===========================================================================
+
                lea     (SS_Ctrl_Record_Buf_End-2).w,a1  ; Last value
                move.w  (a1),(Ctrl_2_Logical).w
                rts
; ===========================================================================
dword_349B8:
                dc.l    (SSRAM_ArtNem_SpecialSonicAndTails & $FFFFFF) + tiles_to_bytes($183)  ; Tails in upright position, $3D tiles
                dc.l    (SSRAM_ArtNem_SpecialSonicAndTails & $FFFFFF) + tiles_to_bytes($1C0)  ; Tails in diagonal position, $A4 tiles
                dc.l    (SSRAM_ArtNem_SpecialSonicAndTails & $FFFFFF) + tiles_to_bytes($264)  ; Tails in horizontal position, $3A tiles
                dc.l    (SSRAM_ArtNem_SpecialSonicAndTails & $FFFFFF) + tiles_to_bytes($29E)  ; Tails in ball form, $10 tiles
; ===========================================================================

LoadSSTailsDynPLC:
                move.b  ss_dplc_timer(a0),d0
                beq.s   +
                subq.b  #1,d0
                move.b  d0,ss_dplc_timer(a0)
                andi.b  #1,d0
                beq.s   +
                rts
; ===========================================================================
+
                jsrto   JmpTo43_DisplaySprite
                lea     dword_349B8(pc),a3
                lea     (Tails_LastLoadedDPLC).w,a4
                move.w  #tiles_to_bytes(ArtTile_ArtNem_SpecialTails),d4
                moveq   #$12,d1
                bra.w   LoadSSPlayerDynPLC
; ===========================================================================

Obj10_MdJump:
                lea     (Ctrl_2_Held_Logical).w,a2
                tst.w   (Player_mode).w
                beq.s   +
                lea     (Ctrl_1_Held_Logical).w,a2
+
                bsr.w   SSPlayer_ChgJumpDir
                bsr.w   SSObjectMoveAndFall
                bsr.w   SSPlayer_DoLevelCollision
                bsr.w   SSPlayerSwapPositions
                bsr.w   SSAnglePos
                bsr.w   SSPlayer_JumpAngle
                lea     (Tails_Animation).l,a1
                bsr.w   SSPlayer_Animate
                bra.s   LoadSSTailsDynPLC
; ===========================================================================

Obj10_MdAir:
                lea     (Ctrl_2_Held_Logical).w,a2
                tst.w   (Player_mode).w
                beq.s   +
                lea     (Ctrl_1_Held_Logical).w,a2
+
                bsr.w   SSPlayer_ChgJumpDir
                bsr.w   SSObjectMoveAndFall
                bsr.w   SSPlayer_JumpAngle
                bsr.w   SSPlayer_DoLevelCollision
                bsr.w   SSPlayerSwapPositions
                bsr.w   SSAnglePos
                bsr.w   SSPlayer_SetAnimation
                lea     (Tails_Animation).l,a1
                bsr.w   SSPlayer_Animate
                bra.w   LoadSSTailsDynPLC
; ===========================================================================
; ----------------------------------------------------------------------------
; Object 88 - Tails' tails in Special Stage
; ----------------------------------------------------------------------------
; Sprite_34A5C:
Obj88:
                movea.l ss_parent(a0),a1                ; load obj address of Tails
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                move.b  render_flags(a1),render_flags(a0)
                move.b  status(a1),status(a0)
                move.b  anim(a1),anim(a0)
                move.b  priority(a1),d0
                subq.b  #1,d0
                move.b  d0,priority(a0)
                cmpi.b  #3,anim(a0)
                bhs.s   Tails_Return
                lea     (Ani_obj88).l,a1
                jsrto   JmpTo23_AnimateSprite
                bra.w   LoadSSTailsTailsDynPLC
; ===========================================================================

Tails_Return:
                rts
; ===========================================================================
dword_34AA0:
                dc.l    (SSRAM_ArtNem_SpecialSonicAndTails & $FFFFFF) + tiles_to_bytes($2AE)  ; Tails' tails when he is in upright position, $35 tiles
                dc.l    (SSRAM_ArtNem_SpecialSonicAndTails & $FFFFFF) + tiles_to_bytes($2E3)  ; Tails' tails when he is in diagonal position, $3B tiles
                dc.l    (SSRAM_ArtNem_SpecialSonicAndTails & $FFFFFF) + tiles_to_bytes($31E)  ; Tails' tails when he is in horizontal position, $35 tiles
; ===========================================================================

LoadSSTailsTailsDynPLC:
                movea.l ss_parent(a0),a1                ; load obj address of Tails
                move.b  ss_dplc_timer(a1),d0
                beq.s   +
                andi.b  #1,d0
                beq.s   +
                rts
; ===========================================================================
+
                jsrto   JmpTo43_DisplaySprite
                moveq   #0,d0
                move.b  mapping_frame(a0),d0
                cmp.b   (TailsTails_LastLoadedDPLC).w,d0
                beq.s   Tails_Return_Variant2
                move.b  d0,(TailsTails_LastLoadedDPLC).w
                moveq   #0,d6
                cmpi.b  #7,d0
                blt.s   loc_34AE4
                addq.w  #4,d6
                cmpi.b  #$E,d0
                blt.s   loc_34AE4
                addq.w  #4,d6

loc_34AE4:
                move.l  dword_34AA0(pc,d6.w),d6
                addi.w  #$24,d0
                add.w   d0,d0
                lea     (Obj09_MapRUnc_345FA).l,a2
                adda.w  (a2,d0.w),a2
                move.w  #tiles_to_bytes(ArtTile_ArtNem_SpecialTails_Tails),d2
                moveq   #0,d1
                move.w  (a2)+,d1
                move.w  d1,d3
                lsr.w   #8,d3
                andi.w  #$F0,d3
                addi.w  #$10,d3
                andi.w  #$FFF,d1
                lsl.w   #1,d1
                add.l   d6,d1
                jsr     (QueueDMATransfer).l

Tails_Return_Variant2:
                rts
; ===========================================================================
Tails_Animation:    offsetTable
                offsetTableEntry.w Tails_Animation_Sequence0  ; 0
                offsetTableEntry.w Tails_Animation_Sequence1  ; 1
                offsetTableEntry.w Tails_Animation_Sequence2  ; 2
                offsetTableEntry.w Tails_Animation_Sequence3  ; 3
Tails_Animation_Sequence0:
                dc.b    3,  0,  1,  2,  3,$FF
Tails_Animation_Sequence1:
                dc.b    3,  4,  5,  6,  7,  8,  9, $A, $B,$FF
Tails_Animation_Sequence2:
                dc.b    3, $C, $D, $E, $F,$FF
Tails_Animation_Sequence3:
                dc.b    1,$10,$11,$FF
                even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj10_MapUnc_34B3E:
Map_obj10:      mappingsTable
                mappingsTableEntry.w Map_obj10_0024
                mappingsTableEntry.w Map_obj10_003E
                mappingsTableEntry.w Map_obj10_0060
                mappingsTableEntry.w Map_obj10_0082
                mappingsTableEntry.w Map_obj10_00AC
                mappingsTableEntry.w Map_obj10_00C6
                mappingsTableEntry.w Map_obj10_00E8
                mappingsTableEntry.w Map_obj10_0112
                mappingsTableEntry.w Map_obj10_0134
                mappingsTableEntry.w Map_obj10_0156
                mappingsTableEntry.w Map_obj10_0180
                mappingsTableEntry.w Map_obj10_01AA
                mappingsTableEntry.w Map_obj10_01CC
                mappingsTableEntry.w Map_obj10_01DE
                mappingsTableEntry.w Map_obj10_01F8
                mappingsTableEntry.w Map_obj10_020A
                mappingsTableEntry.w Map_obj10_0224
                mappingsTableEntry.w Map_obj10_0236

Map_obj10_0024: spriteHeader
                spritePiece -$C, -$18, 3, 3, 0, 0, 0, 0, 1
                spritePiece -$C, 0, 3, 2, 9, 0, 0, 0, 1
                spritePiece -$C, $10, 1, 1, $F, 0, 0, 0, 1
Map_obj10_0024_End

Map_obj10_003E: spriteHeader
                spritePiece -$10, -$18, 4, 1, 0, 0, 0, 0, 1
                spritePiece -$D, -$10, 3, 2, 4, 0, 0, 0, 1
                spritePiece -$10, 0, 4, 1, $A, 0, 0, 0, 1
                spritePiece -8, 8, 2, 2, $E, 0, 0, 0, 1
Map_obj10_003E_End

Map_obj10_0060: spriteHeader
                spritePiece -$10, -$18, 4, 1, 0, 0, 0, 0, 1
                spritePiece -$D, -$10, 3, 2, 4, 0, 0, 0, 1
                spritePiece -$10, 0, 4, 1, $A, 0, 0, 0, 1
                spritePiece -8, 8, 2, 2, $E, 0, 0, 0, 1
Map_obj10_0060_End

Map_obj10_0082: spriteHeader
                spritePiece -$10, -$18, 4, 1, 0, 1, 0, 0, 1
                spritePiece -$B, -$10, 3, 2, 4, 1, 0, 0, 1
                spritePiece -$10, 0, 4, 1, $A, 0, 0, 0, 1
                spritePiece -8, 8, 2, 2, $E, 0, 0, 0, 1
                spritePiece 8, $10, 1, 1, $12, 0, 0, 0, 1
Map_obj10_0082_End

Map_obj10_00AC: spriteHeader
                spritePiece 0, -$1F, 2, 2, 0, 0, 0, 0, 1
                spritePiece -8, -$F, 4, 2, 4, 0, 0, 0, 1
                spritePiece -$14, 1, 4, 2, $C, 0, 0, 0, 1
Map_obj10_00AC_End

Map_obj10_00C6: spriteHeader
                spritePiece 0, -$1F, 1, 2, 0, 0, 0, 0, 1
                spritePiece -9, -$F, 4, 2, 2, 0, 0, 0, 1
                spritePiece -$11, 1, 3, 3, $A, 0, 0, 0, 1
                spritePiece 7, 1, 1, 2, $13, 0, 0, 0, 1
Map_obj10_00C6_End

Map_obj10_00E8: spriteHeader
                spritePiece 0, -$18, 1, 1, 0, 0, 0, 0, 1
                spritePiece -8, -$14, 3, 1, 1, 0, 0, 0, 1
                spritePiece -$10, -$C, 4, 2, 4, 0, 0, 0, 1
                spritePiece $10, -$C, 1, 1, $C, 0, 0, 0, 1
                spritePiece -$10, 4, 3, 2, $D, 0, 0, 0, 1
Map_obj10_00E8_End

Map_obj10_0112: spriteHeader
                spritePiece 1, -$17, 1, 1, 0, 0, 0, 0, 1
                spritePiece -$10, -$F, 4, 4, 1, 0, 0, 0, 1
                spritePiece $10, -7, 1, 1, $11, 0, 0, 0, 1
                spritePiece -$10, $11, 2, 1, $12, 0, 0, 0, 1
Map_obj10_0112_End

Map_obj10_0134: spriteHeader
                spritePiece 0, -$1E, 2, 2, 0, 0, 0, 0, 1
                spritePiece -8, -$E, 4, 1, 4, 0, 0, 0, 1
                spritePiece -$10, -6, 2, 4, 8, 0, 0, 0, 1
                spritePiece 0, -6, 3, 2, $10, 0, 0, 0, 1
Map_obj10_0134_End

Map_obj10_0156: spriteHeader
                spritePiece 0, -$18, 1, 1, 0, 0, 0, 0, 1
                spritePiece -$10, -$10, 4, 2, 1, 0, 0, 0, 1
                spritePiece $10, -8, 1, 1, 9, 0, 0, 0, 1
                spritePiece -$10, 0, 4, 2, $A, 0, 0, 0, 1
                spritePiece -$10, $10, 2, 1, $12, 0, 0, 0, 1
Map_obj10_0156_End

Map_obj10_0180: spriteHeader
                spritePiece 0, -$18, 1, 1, 0, 0, 0, 0, 1
                spritePiece -$10, -$10, 4, 3, 1, 0, 0, 0, 1
                spritePiece $10, -8, 1, 1, $D, 0, 0, 0, 1
                spritePiece -$18, 8, 4, 1, $E, 0, 0, 0, 1
                spritePiece -$10, $10, 2, 1, $12, 0, 0, 0, 1
Map_obj10_0180_End

Map_obj10_01AA: spriteHeader
                spritePiece 0, -$18, 1, 1, 0, 0, 0, 0, 1
                spritePiece -$10, -$10, 4, 3, 1, 0, 0, 0, 1
                spritePiece $10, -8, 1, 1, $D, 0, 0, 0, 1
                spritePiece -$18, 8, 4, 2, $E, 0, 0, 0, 1
Map_obj10_01AA_End

Map_obj10_01CC: spriteHeader
                spritePiece -$14, -8, 3, 3, 0, 0, 0, 0, 1
                spritePiece 4, -$10, 2, 4, 9, 0, 0, 0, 1
Map_obj10_01CC_End

Map_obj10_01DE: spriteHeader
                spritePiece -$14, -8, 2, 2, 0, 0, 0, 0, 1
                spritePiece -$C, 8, 1, 1, 4, 0, 0, 0, 1
                spritePiece -4, -$10, 3, 4, 5, 0, 0, 0, 1
Map_obj10_01DE_End

Map_obj10_01F8: spriteHeader
                spritePiece -$14, -9, 1, 2, 0, 0, 0, 0, 1
                spritePiece -$C, -$10, 4, 4, 2, 0, 0, 0, 1
Map_obj10_01F8_End

Map_obj10_020A: spriteHeader
                spritePiece -$14, -8, 1, 3, 0, 0, 0, 0, 1
                spritePiece -$C, -$10, 1, 3, 3, 0, 0, 0, 1
                spritePiece -4, -$10, 3, 4, 6, 0, 0, 0, 1
Map_obj10_020A_End

Map_obj10_0224: spriteHeader
                spritePiece -$10, -$10, 2, 4, 0, 0, 0, 0, 1
                spritePiece 0, -$10, 2, 4, 0, 1, 0, 0, 1
Map_obj10_0224_End

Map_obj10_0236: spriteHeader
                spritePiece -$10, -$10, 2, 4, 0, 0, 0, 0, 1
                spritePiece 0, -$10, 2, 4, 0, 1, 0, 0, 1
Map_obj10_0236_End

                even

; animation script
; off_34D86:
Ani_obj88:      offsetTable
                offsetTableEntry.w Tails_Animation_Sequence0_Variant2  ; 0
                offsetTableEntry.w Tails_Animation_Sequence1_Variant2  ; 1
                offsetTableEntry.w Tails_Animation_Sequence2_Variant2  ; 2
Tails_Animation_Sequence0_Variant2: dc.b    3,  0,  1,  2,  3,  4,  5,  6,$FF
Tails_Animation_Sequence1_Variant2: dc.b    3,  7,  8,  9, $A, $B, $C, $D,$FF
Tails_Animation_Sequence2_Variant2: dc.b    3, $E, $F,$10,$11,$12,$13,$14,$FF
                even
; ----------------------------------------------------------------------------
; sprite mappings for Tails' tails in special stage
; ----------------------------------------------------------------------------
Obj88_MapUnc_34DA8:
Map_obj88:      mappingsTable
                mappingsTableEntry.w Map_obj88_002A
                mappingsTableEntry.w Map_obj88_0034
                mappingsTableEntry.w Map_obj88_003E
                mappingsTableEntry.w Map_obj88_0048
                mappingsTableEntry.w Map_obj88_0052
                mappingsTableEntry.w Map_obj88_005C
                mappingsTableEntry.w Map_obj88_0066
                mappingsTableEntry.w Map_obj88_0070
                mappingsTableEntry.w Map_obj88_007A
                mappingsTableEntry.w Map_obj88_0084
                mappingsTableEntry.w Map_obj88_008E
                mappingsTableEntry.w Map_obj88_0098
                mappingsTableEntry.w Map_obj88_00A2
                mappingsTableEntry.w Map_obj88_00AC
                mappingsTableEntry.w Map_obj88_00B6
                mappingsTableEntry.w Map_obj88_00C0
                mappingsTableEntry.w Map_obj88_00CA
                mappingsTableEntry.w Map_obj88_00D4
                mappingsTableEntry.w Map_obj88_00DE
                mappingsTableEntry.w Map_obj88_00E8
                mappingsTableEntry.w Map_obj88_00F2

Map_obj88_002A: spriteHeader
                spritePiece -6, -6, 2, 3, 0, 0, 0, 0, 1
Map_obj88_002A_End

Map_obj88_0034: spriteHeader
                spritePiece -8, 0, 3, 3, 0, 0, 0, 0, 1
Map_obj88_0034_End

Map_obj88_003E: spriteHeader
                spritePiece -8, 8, 3, 2, 0, 0, 0, 0, 1
Map_obj88_003E_End

Map_obj88_0048: spriteHeader
                spritePiece -9, -1, 2, 3, 0, 0, 0, 0, 1
Map_obj88_0048_End

Map_obj88_0052: spriteHeader
                spritePiece -$B, -9, 2, 4, 0, 0, 0, 0, 1
Map_obj88_0052_End

Map_obj88_005C: spriteHeader
                spritePiece -$10, -9, 3, 3, 0, 0, 0, 0, 1
Map_obj88_005C_End

Map_obj88_0066: spriteHeader
                spritePiece -$10, -9, 3, 3, 0, 0, 0, 0, 1
Map_obj88_0066_End

Map_obj88_0070: spriteHeader
                spritePiece -$C, 0, 3, 3, 0, 0, 0, 0, 1
Map_obj88_0070_End

Map_obj88_007A: spriteHeader
                spritePiece -$D, 8, 3, 2, 0, 0, 0, 0, 1
Map_obj88_007A_End

Map_obj88_0084: spriteHeader
                spritePiece -$F, 0, 2, 3, 0, 0, 0, 0, 1
Map_obj88_0084_End

Map_obj88_008E: spriteHeader
                spritePiece -$C, -8, 2, 4, 0, 0, 0, 0, 1
Map_obj88_008E_End

Map_obj88_0098: spriteHeader
                spritePiece -$E, -8, 3, 4, 0, 0, 0, 0, 1
Map_obj88_0098_End

Map_obj88_00A2: spriteHeader
                spritePiece -$D, -8, 3, 3, 0, 0, 0, 0, 1
Map_obj88_00A2_End

Map_obj88_00AC: spriteHeader
                spritePiece -$C, -8, 3, 3, 0, 0, 0, 0, 1
Map_obj88_00AC_End

Map_obj88_00B6: spriteHeader
                spritePiece -$16, -4, 3, 2, 0, 0, 0, 0, 1
Map_obj88_00B6_End

Map_obj88_00C0: spriteHeader
                spritePiece -$13, -8, 3, 3, 0, 0, 0, 0, 1
Map_obj88_00C0_End

Map_obj88_00CA: spriteHeader
                spritePiece -$13, -8, 2, 3, 0, 0, 0, 0, 1
Map_obj88_00CA_End

Map_obj88_00D4: spriteHeader
                spritePiece -$13, -9, 3, 2, 0, 0, 0, 0, 1
Map_obj88_00D4_End

Map_obj88_00DE: spriteHeader
                spritePiece -$1B, -$B, 4, 2, 0, 0, 0, 0, 1
Map_obj88_00DE_End

Map_obj88_00E8: spriteHeader
                spritePiece -$13, -$10, 3, 3, 0, 0, 0, 0, 1
Map_obj88_00E8_End

Map_obj88_00F2: spriteHeader
                spritePiece -$13, -$10, 3, 3, 0, 0, 0, 0, 1
Map_obj88_00F2_End

                even
; ===========================================================================

                jmpTos  JmpTo43_DisplaySprite,JmpTo23_AnimateSprite

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 61 - Bombs from Special Stage
; ----------------------------------------------------------------------------
; Sprite_34EB0:
