ObjAD:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  ObjAD_Index(pc,d0.w),d1
                jmp     ObjAD_Index(pc,d1.w)
; ===========================================================================
; off_3942A:
ObjAD_Index:    offsetTable
                offsetTableEntry.w ObjAD_Init           ; 0
                offsetTableEntry.w ObjAD_Main           ; 2
; ===========================================================================
; loc_3942E:
ObjAD_Init:
                bsr.w   LoadSubObject
                move.b  #$C,mapping_frame(a0)
                rts
; ===========================================================================
; loc_3943A:
ObjAD_Main:
                move.w  #$1B,d1
                move.w  #8,d2
                move.w  #8,d3
                move.w  x_pos(a0),d4
                jsrto   JmpTo27_SolidObject
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================
; ----------------------------------------------------------------------------
; Object AE - Clucker (chicken badnik) from WFZ
; ----------------------------------------------------------------------------
; Sprite_39452:
ObjAE:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  ObjAE_Index(pc,d0.w),d1
                jmp     ObjAE_Index(pc,d1.w)
; ===========================================================================
; off_39460:
ObjAE_Index:    offsetTable
                offsetTableEntry.w ObjAE_Init           ; 0
                offsetTableEntry.w loc_39488            ; 2
                offsetTableEntry.w loc_394A2            ; 4
                offsetTableEntry.w loc_394D2            ; 6
                offsetTableEntry.w loc_394E0            ; 8
                offsetTableEntry.w loc_39508            ; $A
                offsetTableEntry.w loc_39516            ; $C
; ===========================================================================
; loc_3946E:
ObjAE_Init:
                bsr.w   LoadSubObject
                move.b  #$15,mapping_frame(a0)
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                bset    #status.npc.x_flip,status(a0)
+
                rts
; ===========================================================================

loc_39488:
                bsr.w   Obj_GetOrientationToPlayer
                addi.w  #$80,d2
                cmpi.w  #$100,d2
                blo.s   +
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================
+
                addq.b  #2,routine(a0)
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================

loc_394A2:
                move.b  routine(a0),d2
                lea     (Ani_objAE_a).l,a1
                jsrto   JmpTo25_AnimateSprite
                cmp.b   routine(a0),d2
                bne.s   +
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================
+
                lea     mapping_frame(a0),a1
                clr.l   (a1)                            ; Clear mapping_frame, anim_frame, anim, and prev_anim
                clr.w   anim_frame_duration-mapping_frame(a1)
                move.b  #8,(a1)
                move.b  #6,collision_flags(a0)
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================

loc_394D2:
                lea     (Ani_objAE_b).l,a1
                jsrto   JmpTo25_AnimateSprite
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================

loc_394E0:
                tst.b   objoff_2A(a0)
                beq.s   +
                subq.b  #1,objoff_2A(a0)
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================
+
                addq.b  #2,routine(a0)
                lea     mapping_frame(a0),a1
                clr.l   (a1)                            ; Clear mapping_frame, anim_frame, anim, and prev_anim
                clr.w   anim_frame_duration-mapping_frame(a1)
                move.b  #$B,(a1)
                bsr.w   Clucker_SpawnShot
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================

loc_39508:
                lea     (Ani_objAE_c).l,a1
                jsrto   JmpTo25_AnimateSprite
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================

loc_39516:
                move.b  #8,routine(a0)
                move.b  #$40,objoff_2A(a0)
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================

Clucker_SpawnShot:
                jsrto   JmpTo25_AllocateObjectAfterCurrent
                bne.s   ++                              ; rts
                _move.b #ObjID_Projectile,id(a1)        ; load obj98
                move.b  #$D,mapping_frame(a1)
                move.b  #$46,subtype(a1)                ; <==  ObjAD_SubObjData3
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                addi.w  #$B,y_pos(a1)
                move.w  #-$200,d0
                move.w  #-8,d1
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                neg.w   d0
                neg.w   d1
+
                move.w  d0,x_vel(a1)
                add.w   d1,x_pos(a1)
                lea_    Obj98_CluckerShotMove,a2
                move.l  a2,objoff_2A(a1)
+
                rts
; ===========================================================================
ObjAD_SubObjData:
                subObjData ObjAD_Obj98_MapUnc_395B4,make_art_tile(ArtTile_ArtNem_WfzScratch,0,0),1<<render_flags.level_fg,4,$18,0
ObjAD_SubObjData2:
                subObjData ObjAD_Obj98_MapUnc_395B4,make_art_tile(ArtTile_ArtNem_WfzScratch,0,0),1<<render_flags.level_fg,5,$10,0

; animation script
; off_3958A
Ani_objAE_a:    offsetTable
                offsetTableEntry.w +                    ; 0
+               dc.b    1,  0,  1,  2,  3,  4,  5,  6,  7,$FC
                even

; animation script
; off_39596
Ani_objAE_b:    offsetTable
                offsetTableEntry.w +                    ; 0
+               dc.b    1,  8,  9, $A, $B, $B, $B, $B,$FC
                even

; animation script
; off_395A2
Ani_objAE_c:    offsetTable
                offsetTableEntry.w +                    ; 0
+               dc.b    3, $A, $B,$FC
                even

; animation script
; off_395A8
Ani_CluckerShot:offsetTable
                offsetTableEntry.w +                    ; 0
+               dc.b    3, $D, $E, $F,$10,$11,$12,$13,$14,$FF
                even

; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjAD_Obj98_MapUnc_395B4:
Map_objAE:      mappingsTable
                mappingsTableEntry.w Map_objAE_002C
                mappingsTableEntry.w Map_objAE_0036
                mappingsTableEntry.w Map_objAE_0040
                mappingsTableEntry.w Map_objAE_004A
                mappingsTableEntry.w Map_objAE_005C
                mappingsTableEntry.w Map_objAE_006E
                mappingsTableEntry.w Map_objAE_0080
                mappingsTableEntry.w Map_objAE_0092
                mappingsTableEntry.w Map_objAE_00A4
                mappingsTableEntry.w Map_objAE_00BE
                mappingsTableEntry.w Map_objAE_00D8
                mappingsTableEntry.w Map_objAE_00F2
                mappingsTableEntry.w Map_objAE_010C
                mappingsTableEntry.w Map_objAE_011E
                mappingsTableEntry.w Map_objAE_0128
                mappingsTableEntry.w Map_objAE_0132
                mappingsTableEntry.w Map_objAE_013C
                mappingsTableEntry.w Map_objAE_0146
                mappingsTableEntry.w Map_objAE_0150
                mappingsTableEntry.w Map_objAE_015A
                mappingsTableEntry.w Map_objAE_0164
                mappingsTableEntry.w Map_objAE_016E

Map_objAE_002C: spriteHeader
                spritePiece -$10, $C, 4, 2, 0, 0, 0, 1, 0
Map_objAE_002C_End

Map_objAE_0036: spriteHeader
                spritePiece -$10, 8, 4, 2, 0, 0, 0, 1, 0
Map_objAE_0036_End

Map_objAE_0040: spriteHeader
                spritePiece -$10, 4, 4, 2, 0, 0, 0, 1, 0
Map_objAE_0040_End

Map_objAE_004A: spriteHeader
                spritePiece -$10, 0, 4, 2, 0, 0, 0, 1, 0
                spritePiece -$10, $10, 4, 2, 8, 0, 0, 1, 0
Map_objAE_004A_End

Map_objAE_005C: spriteHeader
                spritePiece -$10, -4, 4, 2, 0, 0, 0, 1, 0
                spritePiece -$10, $C, 4, 2, 8, 0, 0, 1, 0
Map_objAE_005C_End

Map_objAE_006E: spriteHeader
                spritePiece -$10, -8, 4, 2, 0, 0, 0, 1, 0
                spritePiece -$10, 8, 4, 2, 8, 0, 0, 1, 0
Map_objAE_006E_End

Map_objAE_0080: spriteHeader
                spritePiece -$10, -$C, 4, 2, 0, 0, 0, 1, 0
                spritePiece -$10, 4, 4, 2, 8, 0, 0, 1, 0
Map_objAE_0080_End

Map_objAE_0092: spriteHeader
                spritePiece -$10, -$10, 4, 2, 0, 0, 0, 1, 0
                spritePiece -$10, 0, 4, 2, 8, 0, 0, 1, 0
Map_objAE_0092_End

Map_objAE_00A4: spriteHeader
                spritePiece -$10, -$10, 4, 2, 0, 0, 0, 1, 0
                spritePiece -$10, 0, 4, 2, 8, 0, 0, 1, 0
                spritePiece -$12, 7, 1, 1, $10, 0, 0, 1, 0
Map_objAE_00A4_End

Map_objAE_00BE: spriteHeader
                spritePiece -$10, -$10, 4, 2, 0, 0, 0, 1, 0
                spritePiece -$10, 0, 4, 2, 8, 0, 0, 1, 0
                spritePiece -$14, 7, 1, 1, $10, 0, 0, 1, 0
Map_objAE_00BE_End

Map_objAE_00D8: spriteHeader
                spritePiece -$10, -$10, 4, 2, 0, 0, 0, 1, 0
                spritePiece -$10, 0, 4, 2, 8, 0, 0, 1, 0
                spritePiece -$16, 7, 1, 1, $10, 0, 0, 1, 0
Map_objAE_00D8_End

Map_objAE_00F2: spriteHeader
                spritePiece -$10, -$10, 4, 2, 0, 0, 0, 1, 0
                spritePiece -$10, 0, 4, 2, 8, 0, 0, 1, 0
                spritePiece -$18, 7, 1, 1, $10, 0, 0, 1, 0
Map_objAE_00F2_End

Map_objAE_010C: spriteHeader
                spritePiece -$18, -8, 3, 2, $11, 0, 0, 3, 0
                spritePiece 0, -8, 3, 2, $11, 1, 0, 3, 0
Map_objAE_010C_End

Map_objAE_011E: spriteHeader
                spritePiece -4, -4, 1, 1, $17, 0, 0, 0, 0
Map_objAE_011E_End

Map_objAE_0128: spriteHeader
                spritePiece -4, -4, 1, 1, $18, 0, 0, 0, 0
Map_objAE_0128_End

Map_objAE_0132: spriteHeader
                spritePiece -4, -4, 1, 1, $19, 0, 0, 0, 0
Map_objAE_0132_End

Map_objAE_013C: spriteHeader
                spritePiece -4, -4, 1, 1, $18, 0, 1, 0, 0
Map_objAE_013C_End

Map_objAE_0146: spriteHeader
                spritePiece -4, -4, 1, 1, $17, 0, 1, 0, 0
Map_objAE_0146_End

Map_objAE_0150: spriteHeader
                spritePiece -4, -4, 1, 1, $18, 1, 1, 0, 0
Map_objAE_0150_End

Map_objAE_015A: spriteHeader
                spritePiece -4, -4, 1, 1, $19, 1, 0, 0, 0
Map_objAE_015A_End

Map_objAE_0164: spriteHeader
                spritePiece -4, -4, 1, 1, $18, 1, 0, 0, 0
Map_objAE_0164_End

Map_objAE_016E: spriteHeader
                spritePiece -$10, $10, 4, 2, 0, 0, 0, 1, 0
Map_objAE_016E_End

                even

; ===========================================================================
; ----------------------------------------------------------------------------
; Object AF - Mecha Sonic / Silver Sonic from DEZ
; (also handles Eggman's remote-control window)
; ----------------------------------------------------------------------------
; Sprite_3972C:
