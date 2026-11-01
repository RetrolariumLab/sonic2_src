ObjC6:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  ObjC6_Index(pc,d0.w),d1
                jmp     ObjC6_Index(pc,d1.w)
; ===========================================================================
; off_3CEDE: ObjC6_States:
ObjC6_Index:    offsetTable
                offsetTableEntry.w ObjC6_Init           ; 0
                offsetTableEntry.w ObjC6_State2         ; 2
                offsetTableEntry.w ObjC6_State3         ; 4
                offsetTableEntry.w ObjC6_State4         ; 6
; ===========================================================================
; loc_3CEE6:
ObjC6_Init:
                bsr.w   LoadSubObject
                move.b  subtype(a0),d0
                subi.b  #$A4,d0
                move.b  d0,routine(a0)                  ; => ObjC6_State2, ObjC6_State3, or ObjC6_State4??
                rts
; ===========================================================================
; loc_3CEF8:
ObjC6_State2:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  ObjC6_State2_States(pc,d0.w),d1
                jmp     ObjC6_State2_States(pc,d1.w)
; ===========================================================================
; off_3CF06:
ObjC6_State2_States:    offsetTable
                offsetTableEntry.w ObjC6_State2_State1  ; 0
                offsetTableEntry.w ObjC6_State2_State2  ; 2
                offsetTableEntry.w ObjC6_State2_State3  ; 4
                offsetTableEntry.w ObjC6_State2_State4  ; 6
                offsetTableEntry.w ObjC6_State2_State5  ; 8
; ===========================================================================
; loc_3CF10:
ObjC6_State2_State1:                                    ; a1=object (set in loc_3D94C)
                addq.b  #2,routine_secondary(a0)        ; => ObjC6_State2_State2
                lea     (EggmanBoss_EggmanChildSlot3E).l,a2
                bsr.w   LoadChildObject
                move.w  #$3F8,x_pos(a1)
                move.w  #$160,y_pos(a1)
                move.w  a0,(DEZ_Eggman).w
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
; loc_3CF32:
ObjC6_State2_State2:
                bsr.w   Obj_GetOrientationToPlayer
                addi.w  #$5C,d2
                cmpi.w  #$B8,d2
                blo.s   loc_3CF44
                jmpto   JmpTo45_DisplaySprite
; ---------------------------------------------------------------------------
loc_3CF44:
                addq.b  #2,routine_secondary(a0)        ; => ObjC6_State2_State3
                move.w  #$18,objoff_2A(a0)
                move.b  #1,mapping_frame(a0)
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
; loc_3CF58:
ObjC6_State2_State3:
                subq.w  #1,objoff_2A(a0)
                bmi.s   loc_3CF62
                jmpto   JmpTo45_DisplaySprite
; ---------------------------------------------------------------------------
loc_3CF62:
                addq.b  #2,routine_secondary(a0)        ; => ObjC6_State2_State4
                bset    #status.npc.misc,status(a0)
                move.w  #$200,x_vel(a0)
                move.w  #$10,objoff_2A(a0)
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
; loc_3CF7C:
ObjC6_State2_State4:
                cmpi.w  #$810,x_pos(a0)
                bhs.s   loc_3CFC0
                bsr.w   Obj_GetOrientationToPlayer
                addi.w  #$50,d2
                cmpi.w  #$A0,d2
                bhs.s   +
                move.w  x_pos(a1),d0
                addi.w  #$50,d0
                move.w  d0,x_pos(a0)
+
                subq.w  #1,objoff_2A(a0)
                bpl.s   +
                move.w  #$20,objoff_2A(a0)
                bsr.w   EggmanBoss_SpawnChild
+
                jsrto   JmpTo26_ObjectMove
                lea     (Ani_objC5_objC6).l,a1
                jsrto   JmpTo25_AnimateSprite
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_3CFC0:
                move.b  #2,mapping_frame(a0)
                clr.w   x_vel(a0)
                _btst   #render_flags.on_screen,render_flags(a0)
                _beq.s  +
                addq.b  #2,routine_secondary(a0)        ; => ObjC6_State2_State5
                move.w  #$80,x_vel(a0)
                move.w  #-$200,y_vel(a0)
                move.b  #2,mapping_frame(a0)
                move.w  #$50,objoff_2A(a0)
                bset    #status.npc.p1_standing,status(a0)
+
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
; loc_3CFF6:
ObjC6_State2_State5:
                subq.w  #1,objoff_2A(a0)
                bmi.w   JmpTo65_DeleteObject
                addi.w  #$10,y_vel(a0)
                jsrto   JmpTo26_ObjectMove
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

EggmanBoss_SpawnChild:
                lea     (EggmanBoss_EggmanChildSlot3C).l,a2
                bsr.w   LoadChildObject
                move.b  #$AA,subtype(a1)                ; <== ObjC6_SubObjData
                move.b  #5,mapping_frame(a1)
                move.w  #-$100,x_vel(a1)
                subi.w  #$18,y_pos(a1)
                move.w  #8,objoff_2A(a1)
                rts
; ===========================================================================
; loc_3D036:
ObjC6_State3:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  ObjC6_State3_States(pc,d0.w),d1
                jmp     ObjC6_State3_States(pc,d1.w)
; ===========================================================================
; off_3D044:
ObjC6_State3_States:    offsetTable
                offsetTableEntry.w ObjC6_State3_State1  ; 0
                offsetTableEntry.w ObjC6_State3_State2  ; 2
                offsetTableEntry.w ObjC6_State3_State3  ; 4
; ===========================================================================
; loc_3D04A:
ObjC6_State3_State1:
                movea.w objoff_2C(a0),a1                ; a1=object
                btst    #status.npc.misc,status(a1)
                bne.s   loc_3D05E
                bsr.w   EggmanBoss_UpdateSolidCollision
                jmpto   JmpTo45_DisplaySprite
; ---------------------------------------------------------------------------
loc_3D05E:
                addq.b  #2,routine_secondary(a0)        ; => ObjC6_State3_State2
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
; loc_3D066:
ObjC6_State3_State2:
                bsr.w   EggmanBoss_UpdateSolidCollision
                lea     (Ani_objC6).l,a1
                jsrto   JmpTo25_AnimateSprite
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
; loc_3D078:
ObjC6_State3_State3:
                lea     (MainCharacter).w,a1            ; a1=character
                bclr    #status.npc.p1_pushing,status(a1)
                jmpto   JmpTo65_DeleteObject
; ===========================================================================

EggmanBoss_UpdateSolidCollision:
                move.w  x_pos(a0),-(sp)
                move.w  #$13,d1
                move.w  #$20,d2
                move.w  #$20,d3
                move.w  (sp)+,d4
                jmpto   JmpTo27_SolidObject
; ===========================================================================
; loc_3D09C:
ObjC6_State4:
                subq.w  #1,objoff_2A(a0)
                bmi.w   JmpTo65_DeleteObject
                addi.w  #$10,y_vel(a0)
                jsrto   JmpTo26_ObjectMove
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================
; off_3D0B2:
ObjC6_SubObjData3:
                subObjData ObjC6_MapUnc_3D0EE,make_art_tile(ArtTile_ArtKos_LevelArt,0,0),1<<render_flags.level_fg,5,$18,0
; off_3D0BC:
ObjC6_SubObjData4:
                subObjData ObjC6_MapUnc_3D1DE,make_art_tile(ArtTile_ArtNem_ConstructionStripes_1,1,0),1<<render_flags.level_fg,1,8,0
; off_3D0C6:
ObjC6_SubObjData:
                subObjData ObjC6_MapUnc_3D0EE,make_art_tile(ArtTile_ArtKos_LevelArt,0,0),1<<render_flags.level_fg,5,4,0
EggmanBoss_EggmanChildSlot3E:   childObjectData objoff_3E, ObjID_Eggman, $A8
EggmanBoss_EggmanChildSlot3C:   childObjectData objoff_3C, ObjID_Eggman, $AA
; animation script
; off_3D0D8:
Ani_objC5_objC6:offsetTable
                offsetTableEntry.w EggmanBoss_Animation_Sequence0  ; 0
                offsetTableEntry.w EggmanBoss_Animation_Sequence1  ; 1
EggmanBoss_Animation_Sequence0: dc.b    5,  2,  3,  4,$FF,  0
EggmanBoss_Animation_Sequence1: dc.b    5,  6,  7,$FF
                even
; animation script
; off_3D0E6:
Ani_objC6:      offsetTable
                offsetTableEntry.w +                    ; 0
+               dc.b    1,  0,  1,  2,  3,$FA
                even
; ----------------------------------------------------------------------------
; sprite mappings ; Robotnik running
; ----------------------------------------------------------------------------
ObjC6_MapUnc_3D0EE:
Map_objC6_a:    mappingsTable
                mappingsTableEntry.w Map_objC6_a_0010
                mappingsTableEntry.w Map_objC6_a_002A
                mappingsTableEntry.w Map_objC6_a_0044
                mappingsTableEntry.w Map_objC6_a_006E
                mappingsTableEntry.w Map_objC6_a_0090
                mappingsTableEntry.w Map_objC6_a_00B2
                mappingsTableEntry.w Map_objC6_a_00BC
                mappingsTableEntry.w Map_objC6_a_00D6

Map_objC6_a_0010:   spriteHeader
                spritePiece -$10, -$1A, 4, 2, $500, 0, 0, 0, 0
                spritePiece -$10, -$A, 4, 3, $564, 0, 0, 0, 0
                spritePiece -$10, $E, 4, 2, $570, 0, 0, 0, 0
Map_objC6_a_0010_End

Map_objC6_a_002A:   spriteHeader
                spritePiece -$10, -$1A, 4, 2, $510, 0, 0, 0, 0
                spritePiece -$10, -$A, 4, 3, $564, 0, 0, 0, 0
                spritePiece -$10, $E, 4, 2, $570, 0, 0, 0, 0
Map_objC6_a_002A_End

Map_objC6_a_0044:   spriteHeader
                spritePiece -$20, -$14, 2, 1, $518, 0, 0, 0, 0
                spritePiece -$10, -$1C, 4, 2, $51A, 0, 0, 0, 0
                spritePiece -$10, -$C, 4, 3, $522, 0, 0, 0, 0
                spritePiece -$18, 4, 1, 2, $52E, 0, 0, 0, 0
                spritePiece $10, 4, 2, 2, $530, 0, 0, 0, 0
Map_objC6_a_0044_End

Map_objC6_a_006E:   spriteHeader
                spritePiece -$20, -$14, 2, 1, $518, 0, 0, 0, 0
                spritePiece -$10, -$1C, 4, 2, $51A, 0, 0, 0, 0
                spritePiece -$10, -$C, 4, 3, $534, 0, 0, 0, 0
                spritePiece -8, $C, 2, 2, $540, 0, 0, 0, 0
Map_objC6_a_006E_End

Map_objC6_a_0090:   spriteHeader
                spritePiece -$20, -$14, 2, 1, $518, 0, 0, 0, 0
                spritePiece -$10, -$1C, 4, 3, $544, 0, 0, 0, 0
                spritePiece -$10, -4, 4, 4, $550, 0, 0, 0, 0
                spritePiece $10, $C, 1, 2, $560, 0, 0, 0, 0
Map_objC6_a_0090_End

Map_objC6_a_00B2:   spriteHeader
                spritePiece -8, -4, 2, 1, $562, 0, 0, 0, 0
Map_objC6_a_00B2_End

Map_objC6_a_00BC:   spriteHeader
                spritePiece -$10, -$1A, 4, 2, $508, 0, 0, 0, 0
                spritePiece -$10, -$A, 4, 3, $564, 0, 0, 0, 0
                spritePiece -$10, $E, 4, 2, $570, 0, 0, 0, 0
Map_objC6_a_00BC_End

Map_objC6_a_00D6:   spriteHeader
                spritePiece -$10, -$19, 4, 2, $508, 0, 0, 0, 0
                spritePiece -$10, -9, 4, 3, $564, 0, 0, 0, 0
                spritePiece -$10, $F, 4, 2, $578, 0, 0, 0, 0
Map_objC6_a_00D6_End

                even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjC6_MapUnc_3D1DE:
Map_objC6_b:    mappingsTable
                mappingsTableEntry.w Map_objC6_b_0008
                mappingsTableEntry.w Map_objC6_b_002A
                mappingsTableEntry.w Map_objC6_b_0044
                mappingsTableEntry.w Map_objC6_b_0056

Map_objC6_b_0008:   spriteHeader
                spritePiece -8, -$20, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, 0, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, $10, 2, 2, 0, 0, 0, 0, 0
Map_objC6_b_0008_End

Map_objC6_b_002A:   spriteHeader
                spritePiece -8, -$20, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, -$10, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, 0, 2, 2, 0, 0, 0, 0, 0
Map_objC6_b_002A_End

Map_objC6_b_0044:   spriteHeader
                spritePiece -8, -$20, 2, 2, 0, 0, 0, 0, 0
                spritePiece -8, -$10, 2, 2, 0, 0, 0, 0, 0
Map_objC6_b_0044_End

Map_objC6_b_0056:   spriteHeader
                spritePiece -8, -$20, 2, 2, 0, 0, 0, 0, 0
Map_objC6_b_0056_End

                even

; ===========================================================================
; ----------------------------------------------------------------------------
; Object C8 - Crawl (shield badnik) from CNZ
; ----------------------------------------------------------------------------
; Sprite_3D23E:
