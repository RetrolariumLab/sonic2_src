Obj5C:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj5C_Index(pc,d0.w),d1
                jsr     Obj5C_Index(pc,d1.w)
                jmpto   JmpTo34_MarkObjGone
; ===========================================================================
; off_2D3A6:
Obj5C_Index:    offsetTable
                offsetTableEntry.w Obj5C_Init           ; 0
                offsetTableEntry.w Obj5C_Main           ; 2
; ===========================================================================
; loc_2D3AA:
Obj5C_Init:
                addq.b  #2,routine(a0)
                move.l  #Obj5C_MapUnc_2D442,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_Masher,0,0),art_tile(a0)
                jsrto   JmpTo58_Adjust2PArtPointer
                move.b  #1<<render_flags.level_fg,render_flags(a0)
                move.b  #4,priority(a0)
                move.b  #9,collision_flags(a0)
                move.b  #$10,width_pixels(a0)
                move.w  #-$400,y_vel(a0)
                move.w  y_pos(a0),Obj5C_initial_y_pos(a0)  ; set initial (and lowest) y position
; loc_2D3E4:
Obj5C_Main:
                lea     (Ani_obj5C).l,a1
                jsrto   JmpTo16_AnimateSprite
                jsrto   JmpTo22_ObjectMove
                addi.w  #$18,y_vel(a0)                  ; apply gravity
                move.w  Obj5C_initial_y_pos(a0),d0
                cmp.w   y_pos(a0),d0                    ; has object reached its initial y position?
                bhs.s   +                               ; if not, branch
                move.w  d0,y_pos(a0)
                move.w  #-$500,y_vel(a0)                ; jump
+
                move.b  #1,anim(a0)
                subi.w  #$C0,d0
                cmp.w   y_pos(a0),d0
                bhs.s   +                               ; rts
                move.b  #0,anim(a0)
                tst.w   y_vel(a0)                       ; is object falling?
                bmi.s   +                               ; rts ; if not, branch
                move.b  #2,anim(a0)                     ; use closed mouth animation
+
                rts
; ===========================================================================
; animation script
; off_2D430:
Ani_obj5C:      offsetTable
                offsetTableEntry.w EnemiesMasher_Animation_Sequence0  ; 0
                offsetTableEntry.w EnemiesMasher_Animation_Sequence1  ; 1
                offsetTableEntry.w EnemiesMasher_Animation_Sequence2  ; 2
EnemiesMasher_Animation_Sequence0:  dc.b    7,  0,  1,$FF
EnemiesMasher_Animation_Sequence1:  dc.b    3,  0,  1,$FF
EnemiesMasher_Animation_Sequence2:  dc.b    7,  0,$FF
                even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj5C_MapUnc_2D442:
Map_obj5C:      mappingsTable
                mappingsTableEntry.w Map_obj5C_0004
                mappingsTableEntry.w Map_obj5C_001E

Map_obj5C_0004: spriteHeader
                spritePiece -$C, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece 4, -$10, 1, 2, 4, 0, 0, 0, 0
                spritePiece -$C, 0, 3, 2, $A, 0, 0, 0, 0
Map_obj5C_0004_End

Map_obj5C_001E: spriteHeader
                spritePiece -$C, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece 2, -$10, 2, 2, 6, 0, 0, 0, 0
                spritePiece -$C, 0, 3, 2, $10, 0, 0, 0, 0
Map_obj5C_001E_End

                even
; ===========================================================================

                jmpTos0 JmpTo34_MarkObjGone,JmpTo16_AnimateSprite,JmpTo58_Adjust2PArtPointer,JmpTo22_ObjectMove

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 58 - Boss explosion
; ----------------------------------------------------------------------------
; Sprite_2D494:
