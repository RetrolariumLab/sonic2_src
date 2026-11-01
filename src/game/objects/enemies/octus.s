Obj4A:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj4A_Index(pc,d0.w),d1
                jmp     Obj4A_Index(pc,d1.w)
; ===========================================================================
; off_2CA22:
Obj4A_Index:    offsetTable
                offsetTableEntry.w Obj4A_Init           ; 0
                offsetTableEntry.w Obj4A_Main           ; 2
                offsetTableEntry.w Obj4A_Angry          ; 4 - unused
                offsetTableEntry.w Obj4A_Bullet         ; 6
; ===========================================================================
; loc_2CA2A:
Obj4A_Bullet:
                subi_.w #1,objoff_2C(a0)
                bmi.s   +
                rts
; ---------------------------------------------------------------------------
+
                jsrto   JmpTo19_ObjectMove
                lea     (Ani_obj4A).l,a1
                jsrto   JmpTo13_AnimateSprite
                jmpto   JmpTo32_MarkObjGone
; ===========================================================================
; loc_2CA46:
Obj4A_Angry:                                            ; Used by removed sub-object
                subq.w  #1,objoff_2C(a0)
                beq.w   JmpTo47_DeleteObject
                jmpto   JmpTo31_DisplaySprite

; ===========================================================================
; loc_2CA52:
Obj4A_Init:
                move.l  #Obj4A_MapUnc_2CBFE,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_Octus,1,0),art_tile(a0)
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  #$A,collision_flags(a0)
                move.b  #4,priority(a0)
                move.b  #$10,width_pixels(a0)
                move.b  #$B,y_radius(a0)
                move.b  #8,x_radius(a0)
                jsrto   JmpTo2_ObjectMoveAndFall
                jsr     (ObjCheckFloorDist).l
                tst.w   d1
                bpl.s   +
                add.w   d1,y_pos(a0)
                move.w  #0,y_vel(a0)
                addq.b  #2,routine(a0)
                move.w  x_pos(a0),d0
                sub.w   (MainCharacter+x_pos).w,d0
                bpl.s   +
                bchg    #status.npc.x_flip,status(a0)
+
                move.w  y_pos(a0),octus_start_position(a0)
                rts
; ===========================================================================
; loc_2CAB8:
Obj4A_Main:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  Obj4A_Main_Index(pc,d0.w),d1
                jsr     Obj4A_Main_Index(pc,d1.w)
                lea     (Ani_obj4A).l,a1
                jsrto   JmpTo13_AnimateSprite
                jmpto   JmpTo32_MarkObjGone
; ===========================================================================
; off_2CAD4:
Obj4A_Main_Index:   offsetTable
                offsetTableEntry.w Obj4A_WaitForCharacter  ; 0
                offsetTableEntry.w Obj4A_DelayBeforeMoveUp  ; 2
                offsetTableEntry.w Obj4A_MoveUp         ; 4
                offsetTableEntry.w Obj4A_Hover          ; 6
                offsetTableEntry.w Obj4A_MoveDown       ; 8
; ===========================================================================
; loc_2CADE:
Obj4A_WaitForCharacter:
                move.w  x_pos(a0),d0
                sub.w   (MainCharacter+x_pos).w,d0
                cmpi.w  #$80,d0
                bgt.s   +                               ; rts
                cmpi.w  #-$80,d0
                blt.s   +                               ; rts
                addq.b  #2,routine_secondary(a0)
                move.b  #3,anim(a0)
                move.w  #$20,objoff_2C(a0)
+
                rts
; ===========================================================================
; loc_2CB04:
Obj4A_DelayBeforeMoveUp:
                subq.w  #1,objoff_2C(a0)
                bmi.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,routine_secondary(a0)
                move.b  #4,anim(a0)
                move.w  #-$200,y_vel(a0)
                jmpto   JmpTo19_ObjectMove
; ===========================================================================
; loc_2CB20:
Obj4A_MoveUp:
                addi.w  #$10,y_vel(a0)
                bpl.s   +
                jmpto   JmpTo19_ObjectMove
; ===========================================================================
+
                addq.b  #2,routine_secondary(a0)
                move.w  #60,objoff_2C(a0)
                bra.w   Obj4A_FireBullet
; ===========================================================================
; loc_2CB3A:
Obj4A_Hover:
                subq.w  #1,objoff_2C(a0)
                bmi.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,routine_secondary(a0)
                rts
; ===========================================================================
; loc_2CB48:
Obj4A_MoveDown:
                addi.w  #$10,y_vel(a0)
                move.w  y_pos(a0),d0
                cmp.w   octus_start_position(a0),d0
                bhs.s   +
                jmpto   JmpTo19_ObjectMove
; ===========================================================================
+
                clr.b   routine_secondary(a0)
                clr.b   anim(a0)
                clr.w   y_vel(a0)
                move.b  #1,mapping_frame(a0)
                rts
; ===========================================================================
; loc_2CB70:
Obj4A_FireBullet:
; In the Simon Wai beta, the object loads another object
; here, which makes it look angry as it fires
; This object would have used Obj4A_Angry
                jsr     (AllocateObject).l
                bne.s   +                               ; rts
                _move.b #ObjID_Octus,id(a1)             ; load obj4A
                move.b  #6,routine(a1)
                move.l  #Obj4A_MapUnc_2CBFE,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_Octus,1,0),art_tile(a1)
                move.b  #4,priority(a1)
                move.b  #$10,width_pixels(a1)
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                move.w  #$F,objoff_2C(a1)
                move.b  render_flags(a0),render_flags(a1)
                move.b  status(a0),status(a1)
                move.b  #2,anim(a1)
                move.b  #$98,collision_flags(a1)
                move.w  #-$200,x_vel(a1)
                btst    #render_flags.x_flip,render_flags(a1)
                beq.s   +                               ; rts
                neg.w   x_vel(a1)
+
                rts
; ===========================================================================
; animation script
; off_2CBDC:
Ani_obj4A:      offsetTable
                offsetTableEntry.w EnemiesOctus_Animation_Sequence0  ; 0
                offsetTableEntry.w EnemiesOctus_Animation_Sequence1  ; 1
                offsetTableEntry.w EnemiesOctus_Animation_Sequence2  ; 2
                offsetTableEntry.w EnemiesOctus_Animation_Sequence3  ; 3
                offsetTableEntry.w EnemiesOctus_Animation_Sequence4  ; 4
EnemiesOctus_Animation_Sequence0:   dc.b    $F,  1,  0,$FF
EnemiesOctus_Animation_Sequence1:   dc.b    3,  1,  2,  3,$FF
EnemiesOctus_Animation_Sequence2:   dc.b    2,  5,  6,$FF
                even
EnemiesOctus_Animation_Sequence3:   dc.b    $F,  4,$FF
                even
EnemiesOctus_Animation_Sequence4:   dc.b    7,  0,  1,$FD,  1
                even
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Obj4A_MapUnc_2CBFE:
Map_obj4A:      mappingsTable
                mappingsTableEntry.w Map_obj4A_000E
                mappingsTableEntry.w Map_obj4A_0020
                mappingsTableEntry.w Map_obj4A_003A
                mappingsTableEntry.w Map_obj4A_0054
                mappingsTableEntry.w Map_obj4A_006E
                mappingsTableEntry.w Map_obj4A_0090
                mappingsTableEntry.w Map_obj4A_009A

Map_obj4A_000E: spriteHeader
                spritePiece -$10, -$15, 4, 2, 0, 0, 0, 0, 0
                spritePiece -$10, -5, 4, 2, 8, 0, 0, 0, 0
Map_obj4A_000E_End

Map_obj4A_0020: spriteHeader
                spritePiece -$10, -$10, 4, 2, 0, 0, 0, 0, 0
                spritePiece -$18, 0, 3, 2, $10, 0, 0, 0, 0
                spritePiece 0, 0, 3, 2, $16, 0, 0, 0, 0
Map_obj4A_0020_End

Map_obj4A_003A: spriteHeader
                spritePiece -$10, -$10, 4, 2, 0, 0, 0, 0, 0
                spritePiece -$18, 0, 3, 2, $1C, 0, 0, 0, 0
                spritePiece 0, 0, 3, 2, $22, 0, 0, 0, 0
Map_obj4A_003A_End

Map_obj4A_0054: spriteHeader
                spritePiece -$10, -$10, 4, 2, 0, 0, 0, 0, 0
                spritePiece -$18, 0, 3, 2, $28, 0, 0, 0, 0
                spritePiece 0, 0, 3, 2, $2E, 0, 0, 0, 0
Map_obj4A_0054_End

Map_obj4A_006E: spriteHeader
                spritePiece -9, -$10, 1, 2, $34, 0, 0, 0, 0
                spritePiece -$10, -$10, 4, 2, 0, 0, 0, 0, 0
                spritePiece -$18, 0, 3, 2, $10, 0, 0, 0, 0
                spritePiece 0, 0, 3, 2, $16, 0, 0, 0, 0
Map_obj4A_006E_End

Map_obj4A_0090: spriteHeader
                spritePiece -$10, -$E, 1, 2, $36, 0, 0, 0, 0
Map_obj4A_0090_End

Map_obj4A_009A: spriteHeader
                spritePiece -$10, -$E, 1, 2, $38, 0, 0, 0, 0
Map_obj4A_009A_End

                even
; ===========================================================================

                jmpTos0 JmpTo31_DisplaySprite,JmpTo47_DeleteObject,JmpTo32_MarkObjGone,JmpTo13_AnimateSprite,JmpTo2_ObjectMoveAndFall,JmpTo19_ObjectMove

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 50 - Aquis (seahorse badnik) from OOZ
; ---------------------------------------------------------------------------
; OST Variables:
Obj50_unknown1          =       objoff_2A               ; word
Obj50_shooting_flag     =       objoff_2D               ; byte ; if set, shooting is disabled
Obj50_shots_remaining   =       objoff_2E               ; word ; number of shots before retreating
Obj50_unknown2          =       objoff_30               ; word
Obj50_unknown3          =       objoff_32               ; word
Obj50_unknown4          =       objoff_34               ; word
Obj50_child             =       objoff_36               ; long ; pointer to wing object (main)
Obj50_parent            =       objoff_36               ; long ; pointer to main object (wing)
Obj50_waterlevel        =       objoff_3A               ; word
Obj50_timer             =       objoff_3C               ; byte ; time spent following the player before shooting and time to wait before actually shooting

; Sprite_2CCC8:
