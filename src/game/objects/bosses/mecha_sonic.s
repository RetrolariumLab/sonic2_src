ObjAF:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  ObjAF_Index(pc,d0.w),d1
                jmp     ObjAF_Index(pc,d1.w)
; ===========================================================================
; off_3973A:
ObjAF_Index:    offsetTable
                offsetTableEntry.w ObjAF_Init           ; 0
                offsetTableEntry.w loc_397AC            ; 2
                offsetTableEntry.w loc_397E6            ; 4
                offsetTableEntry.w loc_397FE            ; 6
                offsetTableEntry.w loc_3984A            ; 8
                offsetTableEntry.w loc_398C0            ; $A
                offsetTableEntry.w loc_39B92            ; $C
                offsetTableEntry.w loc_39BBA            ; $E
                offsetTableEntry.w loc_39BCC            ; $10
                offsetTableEntry.w loc_39BE2            ; $12
                offsetTableEntry.w loc_39BEA            ; $14
                offsetTableEntry.w loc_39C02            ; $16
                offsetTableEntry.w loc_39C0A            ; $18
                offsetTableEntry.w loc_39C12            ; $1A
                offsetTableEntry.w loc_39C2A            ; $1C
                offsetTableEntry.w loc_39C42            ; $1E
                offsetTableEntry.w loc_39C50            ; $20
                offsetTableEntry.w loc_39CA0            ; $22
; ===========================================================================
; loc_3975E:
ObjAF_Init:
                bsr.w   LoadSubObject
                move.b  #$1B,y_radius(a0)
                move.b  #$10,x_radius(a0)
                move.b  #0,collision_flags(a0)
                move.b  #8,collision_property(a0)
                lea     (MechaSonicBoss_MechaSonicChildSlot3E).l,a2
                bsr.w   LoadChildObject
                move.b  #$E,routine(a1)
                lea     (MechaSonicBoss_MechaSonicChildSlot3C).l,a2
                bsr.w   LoadChildObject
                move.b  #$14,routine(a1)
                lea     (MechaSonicBoss_MechaSonicChildSlot3A).l,a2
                bsr.w   LoadChildObject
                move.b  #$1A,routine(a1)
                rts
; ===========================================================================

loc_397AC:
                move.w  (Camera_X_pos).w,d0
                cmpi.w  #$224,d0
                bhs.s   loc_397BA
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_397BA:
                addq.b  #2,routine(a0)
                move.w  #60,objoff_2A(a0)
                move.w  #$100,y_vel(a0)
                move.w  #$224,d0
                move.w  d0,(Camera_Min_X_pos).w
                move.w  d0,(Camera_Max_X_pos).w
                move.b  #9,(Current_Boss_ID).w
                moveq   #signextendB(MusID_FadeOut),d0
                jsrto   JmpTo12_PlaySound
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_397E6:
                subq.w  #1,objoff_2A(a0)
                bmi.s   loc_397F0
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_397F0:
                addq.b  #2,routine(a0)
                moveq   #signextendB(MusID_Boss),d0
                jsrto   JmpTo5_PlayMusic
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_397FE:
                move.b  (Vint_runcount+3).w,d0
                andi.b  #$1F,d0
                bne.s   loc_3980E
                moveq   #signextendB(SndID_Fire),d0
                jsrto   JmpTo12_PlaySound

loc_3980E:
                jsr     (ObjCheckFloorDist).l
                tst.w   d1
                bmi.s   loc_39830
                jsrto   JmpTo26_ObjectMove
                moveq   #0,d0
                moveq   #0,d1
                movea.w parent(a0),a1                   ; a1=object
                bsr.w   Obj_AlignChildXY
                bsr.w   MechaSonic_AlignLinkedChild
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_39830:
                add.w   d1,y_pos(a0)
                move.w  #0,y_vel(a0)
                move.b  #$1A,collision_flags(a0)
                bset    #status.npc.y_flip,status(a0)
                bra.w   loc_399D6
; ===========================================================================

loc_3984A:
                bsr.w   MechaSonic_UpdateDamageResponse
                bsr.w   MechaSonic_UpdateActiveFrameCollision
                subq.b  #1,objoff_2A(a0)
                beq.s   loc_39886
                cmpi.b  #$32,objoff_2A(a0)
                bne.s   loc_3986A
                moveq   #signextendB(SndID_MechaSonicBuzz),d0
                jsrto   JmpTo12_PlaySound
                jsrto   JmpTo45_DisplaySprite

loc_3986A:
                jsr     (ObjCheckFloorDist).l
                add.w   d1,y_pos(a0)
                lea     (MechaSonicBoss_Animation).l,a1
                bsr.w   AnimateSprite_Checked
                bsr.w   MechaSonic_AlignLinkedChild
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_39886:
                addq.b  #2,routine(a0)
                moveq   #0,d0
                move.b  objoff_2F(a0),d0
                andi.b  #$F,d0
                move.b  byte_398B0(pc,d0.w),routine_secondary(a0)
                addq.b  #1,objoff_2F(a0)
                clr.b   objoff_2E(a0)
                movea.w objoff_3C(a0),a1                ; a1=object
                move.b  #$16,routine(a1)
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
byte_398B0:
                dc.b    6
                dc.b    0                               ; 1
                dc.b    $10                             ; 2
                dc.b    6                               ; 3
                dc.b    6                               ; 4
                dc.b    $1E                             ; 5
                dc.b    0                               ; 6
                dc.b    $10                             ; 7
                dc.b    6                               ; 8
                dc.b    6                               ; 9
                dc.b    $10                             ; 10
                dc.b    6                               ; 11
                dc.b    0                               ; 12
                dc.b    6                               ; 13
                dc.b    $10                             ; 14
                dc.b    $1E                             ; 15
                even
; ===========================================================================

loc_398C0:
                bsr.w   MechaSonic_UpdateDamageResponse
                bsr.w   MechaSonic_UpdateActiveFrameCollision
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_398F2(pc,d0.w),d1
                jsr     off_398F2(pc,d1.w)
                moveq   #0,d0
                moveq   #0,d1
                movea.w parent(a0),a1                   ; a1=object
                bsr.w   Obj_AlignChildXY
                bsr.w   MechaSonic_AlignLinkedChild
                bsr.w   Obj_AlignChildXY
                jsrto   JmpTo26_ObjectMove
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
off_398F2:      offsetTable
                offsetTableEntry.w loc_3991E            ; 0
                offsetTableEntry.w loc_39946            ; 2
                offsetTableEntry.w loc_39976            ; 4
                offsetTableEntry.w loc_39A0A            ; 6
                offsetTableEntry.w loc_39A1C            ; 8
                offsetTableEntry.w loc_39A44            ; $A
                offsetTableEntry.w loc_39A68            ; $C
                offsetTableEntry.w loc_39A96            ; $E
                offsetTableEntry.w loc_39A0A            ; $10
                offsetTableEntry.w loc_39A1C            ; $12
                offsetTableEntry.w loc_39AAA            ; $14
                offsetTableEntry.w loc_39ACE            ; $16
                offsetTableEntry.w loc_39AF4            ; $18
                offsetTableEntry.w loc_39B28            ; $1A
                offsetTableEntry.w loc_39A96            ; $1C
                offsetTableEntry.w loc_39A0A            ; $1E
                offsetTableEntry.w loc_39A1C            ; $20
                offsetTableEntry.w loc_39AAA            ; $22
                offsetTableEntry.w loc_39ACE            ; $24
                offsetTableEntry.w loc_39B44            ; $26
                offsetTableEntry.w loc_39B28            ; $28
                offsetTableEntry.w loc_39A96            ; $2A
; ===========================================================================

loc_3991E:
                addq.b  #2,routine_secondary(a0)
                move.b  #3,mapping_frame(a0)
                move.b  #2,objoff_2C(a0)

loc_3992E:
                move.b  #$20,objoff_2A(a0)
                movea.w parent(a0),a1                   ; a1=object
                move.b  #$10,routine(a1)
                move.b  #1,anim(a1)
                rts
; ===========================================================================

loc_39946:
                subq.b  #1,objoff_2A(a0)
                bmi.s   loc_3994E
                rts
; ===========================================================================

loc_3994E:
                addq.b  #2,routine_secondary(a0)
                move.b  #$40,objoff_2A(a0)
                move.b  #1,anim(a0)
                move.w  #$800,d0
                bsr.w   MechaSonic_ToggleHorizontalVelocity
                movea.w parent(a0),a1                   ; a1=object
                move.b  #2,anim(a1)
                moveq   #signextendB(SndID_SpindashRelease),d0
                jmpto   JmpTo12_PlaySound
; ===========================================================================

loc_39976:
                subq.b  #1,objoff_2A(a0)
                bmi.s   loc_399C2
                cmpi.b  #$20,objoff_2A(a0)
                bne.s   loc_39994
                move.b  #2,anim(a0)
                movea.w parent(a0),a1                   ; a1=object
                move.b  #$12,routine(a1)

loc_39994:
                bsr.w   MechaSonic_ApplyHorizontalDrag
                lea     (MechaSonicBoss_Animation).l,a1
                bsr.w   AnimateSprite_Checked
                cmpi.b  #2,anim(a0)
                bne.s   MechaSonicBoss_Return
                cmpi.b  #2,anim_frame(a0)
                bne.s   MechaSonicBoss_Return
                cmpi.b  #3,anim_frame_duration(a0)
                bne.s   MechaSonicBoss_Return
                bchg    #render_flags.x_flip,render_flags(a0)

MechaSonicBoss_Return:
                rts
; ===========================================================================

loc_399C2:
                subq.b  #1,objoff_2C(a0)
                beq.s   loc_399D6
                move.b  #2,routine_secondary(a0)
                clr.w   x_vel(a0)
                bra.w   loc_3992E
; ===========================================================================

loc_399D6:
                move.b  #8,routine(a0)
                move.b  #0,anim(a0)
                move.b  #$64,objoff_2A(a0)
                clr.w   x_vel(a0)
                movea.w parent(a0),a1                   ; a1=object
                move.b  #$12,routine(a1)
                movea.w objoff_3C(a0),a1                ; a1=object
                move.b  #$18,routine(a1)
                moveq   #signextendB(SndID_MechaSonicBuzz),d0
                jsrto   JmpTo12_PlaySound
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_39A0A:
                addq.b  #2,routine_secondary(a0)
                move.b  #3,mapping_frame(a0)
                move.b  #3,anim(a0)
                rts
; ===========================================================================

loc_39A1C:
                lea     (MechaSonicBoss_Animation).l,a1
                bsr.w   AnimateSprite_Checked
                bne.s   loc_39A2A
                rts
; ===========================================================================

loc_39A2A:
                addq.b  #2,routine_secondary(a0)
                move.b  #$20,objoff_2A(a0)
                move.b  #4,anim(a0)
                moveq   #signextendB(SndID_LaserBeam),d0
                jsrto   JmpTo12_PlaySound
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_39A44:
                subq.b  #1,objoff_2A(a0)
                bmi.s   loc_39A56
                lea     (MechaSonicBoss_Animation).l,a1
                bsr.w   AnimateSprite_Checked
                rts
; ===========================================================================

loc_39A56:
                addq.b  #2,routine_secondary(a0)
                move.b  #$40,objoff_2A(a0)
                move.w  #$800,d0
                bra.w   MechaSonic_ToggleHorizontalVelocity
; ===========================================================================

loc_39A68:
                subq.b  #1,objoff_2A(a0)
                bmi.s   loc_39A7C
                bsr.w   MechaSonic_ApplyHorizontalDrag
                lea     (MechaSonicBoss_Animation).l,a1
                bra.w   AnimateSprite_Checked
; ===========================================================================

loc_39A7C:
                addq.b  #2,routine_secondary(a0)
                move.b  #5,anim(a0)
                bchg    #render_flags.x_flip,render_flags(a0)
                clr.w   x_vel(a0)
                clr.w   y_vel(a0)
                rts
; ===========================================================================

loc_39A96:
                lea     (MechaSonicBoss_Animation).l,a1
                bsr.w   AnimateSprite_Checked
                bne.w   BranchTo_loc_399D6
                rts
; ===========================================================================

BranchTo_loc_399D6                                      ; BranchTo
                bra.w   loc_399D6
; ===========================================================================

loc_39AAA:
                subq.b  #1,objoff_2A(a0)
                bmi.s   loc_39ABC
                lea     (MechaSonicBoss_Animation).l,a1
                bsr.w   AnimateSprite_Checked
                rts
; ===========================================================================

loc_39ABC:
                addq.b  #2,routine_secondary(a0)
                move.b  #$40,objoff_2A(a0)
                move.w  #$400,d0
                bra.w   MechaSonic_ToggleHorizontalVelocity
; ===========================================================================

loc_39ACE:
                subq.b  #1,objoff_2A(a0)
                cmpi.b  #60,objoff_2A(a0)
                bne.s   loc_39ADE
                bsr.w   MechaSonic_StartUpwardJump

loc_39ADE:
                lea     (MechaSonicBoss_Animation).l,a1
                bra.w   AnimateSprite_Checked
; ===========================================================================

MechaSonic_StartUpwardJump:
                addq.b  #2,routine_secondary(a0)
                move.w  #-$600,y_vel(a0)
                rts
; ===========================================================================

loc_39AF4:
                subq.b  #1,objoff_2A(a0)
                bmi.w   loc_39A7C
                jsr     (ObjCheckFloorDist).l
                tst.w   d1
                bpl.s   loc_39B0A
                bsr.w   MechaSonic_CompleteLandingA

loc_39B0A:
                addi.w  #$38,y_vel(a0)
                lea     (MechaSonicBoss_Animation).l,a1
                bra.w   AnimateSprite_Checked
; ===========================================================================

MechaSonic_CompleteLandingA:
                addq.b  #2,routine_secondary(a0)
                add.w   d1,y_pos(a0)
                clr.w   y_vel(a0)
                rts
; ===========================================================================

loc_39B28:
                subq.b  #1,objoff_2A(a0)
                bmi.w   loc_39A7C
                jsr     (ObjCheckFloorDist).l
                add.w   d1,y_pos(a0)
                lea     (MechaSonicBoss_Animation).l,a1
                bra.w   AnimateSprite_Checked
; ===========================================================================

loc_39B44:
                subq.b  #1,objoff_2A(a0)
                bmi.w   loc_39A7C
                tst.b   objoff_2E(a0)
                bne.s   loc_39B66
                tst.w   y_vel(a0)
                bmi.s   loc_39B66
                st.b    objoff_2E(a0)
                bsr.w   MechaSonic_SpawnProjectileBurst
                moveq   #signextendB(SndID_SpikeSwitch),d0
                jsrto   JmpTo12_PlaySound

loc_39B66:
                jsr     (ObjCheckFloorDist).l
                tst.w   d1
                bpl.s   loc_39B74
                bsr.w   MechaSonic_CompleteLandingB

loc_39B74:
                addi.w  #$38,y_vel(a0)
                lea     (MechaSonicBoss_Animation).l,a1
                bra.w   AnimateSprite_Checked
; ===========================================================================

MechaSonic_CompleteLandingB:
                addq.b  #2,routine_secondary(a0)
                add.w   d1,y_pos(a0)
                clr.w   y_vel(a0)
                rts
; ===========================================================================

loc_39B92:
                clr.b   collision_flags(a0)
                subq.w  #1,objoff_32(a0)
                bmi.s   loc_39BA4
                jsrto   JmpTo_Boss_LoadExplosion
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_39BA4:
                move.w  #$1000,(Camera_Max_X_pos).w
                addq.b  #2,(Dynamic_Resize_Routine).w
; 'Level_Music' is a word long, not a byte
; All this does is try to play Sound 0, which doesn't do anything
; This causes the Death Egg Music music to not resume after the
; Silver Sonic fight
                move.b  (Level_Music).w,d0
                jsrto   JmpTo5_PlayMusic
                jmpto   JmpTo65_DeleteObject
; ===========================================================================

loc_39BBA:
                bsr.w   LoadSubObject
                move.b  #8,width_pixels(a0)
                move.b  #0,collision_flags(a0)
                rts
; ===========================================================================

loc_39BCC:
                movea.w objoff_2C(a0),a1                ; a1=object
                bsr.w   InheritParentXYFlip
                lea     (MechaSonicBoss_Animation_Variant2).l,a1
                bsr.w   AnimateSprite_Checked
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_39BE2:
                andi.b  #~(1<<render_flags.on_screen)&$FF,render_flags(a0)
                rts
; ===========================================================================

loc_39BEA:
                bsr.w   LoadSubObject
                move.b  #8,width_pixels(a0)
                move.b  #$B,mapping_frame(a0)
                move.b  #3,priority(a0)
                rts
; ===========================================================================

loc_39C02:
                move.b  #0,collision_flags(a0)
                rts
; ===========================================================================

loc_39C0A:
                move.b  #$98,collision_flags(a0)
                rts
; ===========================================================================

loc_39C12:
                bsr.w   LoadSubObject
                move.b  #4,mapping_frame(a0)
                move.w  #$2C0,x_pos(a0)
                move.w  #$139,y_pos(a0)
                rts
; ===========================================================================

loc_39C2A:
                movea.w objoff_2C(a0),a1                ; a1=object
                bclr    #status.npc.y_flip,status(a1)
                bne.s   loc_39C3A
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_39C3A:
                addq.b  #2,routine(a0)
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_39C42:
                lea     (Ani_objAF_c).l,a1
                jsrto   JmpTo25_AnimateSprite
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_39C50:
                movea.w objoff_2C(a0),a1                ; a1=object
                lea     (MainCharacter).w,a2            ; a2=character
                btst    #status.npc.misc,status(a1)
                bne.s   loc_39C92
                move.b  #2,anim(a0)
                cmpi.b  #4,routine(a2)
                bne.s   loc_39C78
                move.b  #3,anim(a0)
                bra.w   loc_39C84
; ===========================================================================

loc_39C78:
                tst.b   collision_flags(a1)
                bne.s   loc_39C84
                move.b  #4,anim(a0)

loc_39C84:
                lea     (Ani_objAF_c).l,a1
                jsrto   JmpTo25_AnimateSprite
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_39C92:
                addq.b  #2,routine(a0)
                move.b  #1,anim(a0)
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================

loc_39CA0:
                lea     (Ani_objAF_c).l,a1
                jsrto   JmpTo25_AnimateSprite
                jmpto   JmpTo39_MarkObjGone
; ===========================================================================

MechaSonic_UpdateDamageResponse:
                tst.b   collision_property(a0)
                beq.s   loc_39CF0
                tst.b   collision_flags(a0)
                bne.s   MechaSonicBoss_Return_Variant2
                tst.b   objoff_30(a0)
                bne.s   loc_39CD0
                move.b  #$20,objoff_30(a0)
                move.w  #SndID_BossHit,d0
                jsr     (PlaySound).l

loc_39CD0:
                lea     (Normal_palette_line2+2).w,a1
                moveq   #0,d0
                tst.w   (a1)
                bne.s   loc_39CDE
                move.w  #$EEE,d0

loc_39CDE:
                move.w  d0,(a1)
                subq.b  #1,objoff_30(a0)
                bne.s   MechaSonicBoss_Return_Variant2
                clr.w   (Normal_palette_line2+2).w
                bsr.w   MechaSonic_SelectFrameCollision

MechaSonicBoss_Return_Variant2:
                rts
; ===========================================================================

loc_39CF0:
                moveq   #100,d0
                bsr.w   AddPoints
                move.w  #$FF,objoff_32(a0)
                move.b  #$C,routine(a0)
                clr.b   collision_flags(a0)
                bset    #status.npc.misc,status(a0)
                movea.w objoff_3C(a0),a1                ; a1=object
                jsrto   JmpTo6_DeleteObject2
                movea.w parent(a0),a1                   ; a1=object
                jmpto   JmpTo6_DeleteObject2
; ===========================================================================

MechaSonic_UpdateActiveFrameCollision:
                tst.b   collision_flags(a0)
                beq.w   EnemiesTurtloid_Return_Variant3

MechaSonic_SelectFrameCollision:
                move.b  mapping_frame(a0),d0
                cmpi.b  #6,d0
                beq.s   loc_39D42
                cmpi.b  #7,d0
                beq.s   loc_39D42
                cmpi.b  #8,d0
                beq.s   loc_39D42
                move.b  #$1A,collision_flags(a0)
                rts
; ===========================================================================

loc_39D42:
                move.b  #$9A,collision_flags(a0)
                rts
; ===========================================================================

MechaSonic_AlignLinkedChild:
                moveq   #$C,d0
                moveq   #-$C,d1
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   loc_39D58
                neg.w   d0

loc_39D58:
                movea.w objoff_3C(a0),a1                ; a1=object
                bra.w   Obj_AlignChildXY
; ===========================================================================

MechaSonic_ToggleHorizontalVelocity:
                tst.b   objoff_2D(a0)
                bne.s   loc_39D68
                neg.w   d0

loc_39D68:
                not.b   objoff_2D(a0)
                move.w  d0,x_vel(a0)
                rts
; ===========================================================================

MechaSonic_ApplyHorizontalDrag:
                moveq   #$20,d0
                tst.w   x_vel(a0)
                bmi.s   loc_39D7C
                neg.w   d0

loc_39D7C:
                add.w   d0,x_vel(a0)
                rts
; ===========================================================================

MechaSonic_SpawnProjectileBurst:
                move.b  #$4A,d2
                moveq   #MechaSonic_ProjSpawns.count_minus_one,d6
                lea     (MechaSonic_ProjSpawns).l,a2
                bra.w   Obj_CreateProjectiles
; ===========================================================================
MechaSonic_ProjSpawns:
                dc.b    0,-$18
                dc.b    0,  -3
                dc.b    $F
                dc.b    FALSE<<render_flags.x_flip

                dc.b    -$10,-$10
                dc.b    -2,  -2
                dc.b    $10
                dc.b    FALSE<<render_flags.x_flip

                dc.b    -$18,   0
                dc.b    -3,   0
                dc.b    $11
                dc.b    FALSE<<render_flags.x_flip

                dc.b    -$10, $10
                dc.b    -2,   2
                dc.b    $12
                dc.b    FALSE<<render_flags.x_flip

                dc.b    0, $18
                dc.b    0,   3
                dc.b    $13
                dc.b    FALSE<<render_flags.x_flip

                dc.b    $10, $10
                dc.b    2,   2
                dc.b    $14
                dc.b    FALSE<<render_flags.x_flip

                dc.b    $18,   0
                dc.b    3,   0
                dc.b    $15
                dc.b    FALSE<<render_flags.x_flip

                dc.b    $10, $F0
                dc.b    2,  -2
                dc.b    $16
                dc.b    FALSE<<render_flags.x_flip
MechaSonic_ProjSpawns.end:
MechaSonic_ProjSpawns.count_minus_one   =       ((MechaSonic_ProjSpawns.end - MechaSonic_ProjSpawns) / 6) - 1

MechaSonicBoss_MechaSonicChildSlot3E:   childObjectData objoff_3E, ObjID_MechaSonic, $48
MechaSonicBoss_MechaSonicChildSlot3C:   childObjectData objoff_3C, ObjID_MechaSonic, $48
MechaSonicBoss_MechaSonicChildSlot3A:   childObjectData objoff_3A, ObjID_MechaSonic, $A4
; off_39DCE:
ObjAF_SubObjData2:
                subObjData ObjAF_Obj98_MapUnc_39E68,make_art_tile(ArtTile_ArtNem_SilverSonic,1,0),1<<render_flags.level_fg,4,$10,$1A
; off_39DD8:
ObjAF_SubObjData3:
                subObjData ObjAF_MapUnc_3A08C,make_art_tile(ArtTile_ArtNem_DEZWindow,0,0),1<<render_flags.level_fg,6,$10,0

; animation script
MechaSonicBoss_Animation:   offsetTable
                offsetTableEntry.w MechaSonicBoss_Animation_Sequence0  ; 0
                offsetTableEntry.w MechaSonicBoss_Animation_Sequence1  ; 1
                offsetTableEntry.w MechaSonicBoss_Animation_Sequence2  ; 2
                offsetTableEntry.w MechaSonicBoss_Animation_Sequence3  ; 3
                offsetTableEntry.w MechaSonicBoss_Animation_Sequence4  ; 4
                offsetTableEntry.w MechaSonicBoss_Animation_Sequence5  ; 5
MechaSonicBoss_Animation_Sequence0:
                dc.b    2,  0,  1,  2,$FF,  0
MechaSonicBoss_Animation_Sequence1:
                dc.b    $45,  3,$FD,  0
MechaSonicBoss_Animation_Sequence2:
                dc.b    3,  4,  5,  4,  3,$FC
MechaSonicBoss_Animation_Sequence3:
                dc.b    3,  3,  3,  6,  6,  6,  7,  7,  7,  8,  8,  8,  6,  6,  7,  7
                dc.b    8,  8,  6,  7,  8,$FC           ; 16
MechaSonicBoss_Animation_Sequence4:
                dc.b    2,  6,  7,  8,$FF,  0
MechaSonicBoss_Animation_Sequence5:
                dc.b    3,  8,  7,  6,  8,  8,  7,  7,  6,  6,  8,  8,  8,  7,  7,  7
                dc.b    6,  6,  6,  3,  3,$FC           ; 16
                even

; animation script
MechaSonicBoss_Animation_Variant2:  offsetTable
                offsetTableEntry.w MechaSonic_AnimSeq0_Variant3  ; 0
                offsetTableEntry.w MechaSonic_AnimSeq1_Variant3  ; 1
                offsetTableEntry.w MechaSonic_AnimSeq2_Variant3  ; 2
MechaSonic_AnimSeq0_Variant3:
                dc.b    1, $B, $C,$FF
MechaSonic_AnimSeq1_Variant3:
                dc.b    1, $D, $E,$FF
MechaSonic_AnimSeq2_Variant3:
                dc.b    1,  9, $A,$FF
                even

; animation script
; off_39E42:
Ani_objAF_c:    offsetTable
                offsetTableEntry.w MechaSonic_AnimSeq0_Variant2  ; 0
                offsetTableEntry.w MechaSonic_AnimSeq1_Variant2  ; 1
                offsetTableEntry.w MechaSonic_AnimSeq2_Variant2  ; 2
                offsetTableEntry.w MechaSonic_AnimSeq3_Variant2  ; 3
                offsetTableEntry.w MechaSonic_AnimSeq4_Variant2  ; 4
MechaSonic_AnimSeq0_Variant2:   dc.b    3,  4,  3,  2,  1,  0,$FC,  0
MechaSonic_AnimSeq1_Variant2:   dc.b    3,  0,  1,  2,  3,  4,$FA,  0
MechaSonic_AnimSeq2_Variant2:   dc.b    3,  5,  5,$FF
MechaSonic_AnimSeq3_Variant2:   dc.b    3,  5,  6,$FF
MechaSonic_AnimSeq4_Variant2:   dc.b    3,  7,  7,$FF
                even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjAF_Obj98_MapUnc_39E68:
Map_objAF_a:    mappingsTable
                mappingsTableEntry.w Map_objAF_a_002E
                mappingsTableEntry.w Map_objAF_a_0058
                mappingsTableEntry.w Map_objAF_a_0082
                mappingsTableEntry.w Map_objAF_a_00AC
                mappingsTableEntry.w Map_objAF_a_00CE
                mappingsTableEntry.w Map_objAF_a_00F0
                mappingsTableEntry.w Map_objAF_a_0112
                mappingsTableEntry.w Map_objAF_a_0134
                mappingsTableEntry.w Map_objAF_a_0156
                mappingsTableEntry.w Map_objAF_a_0178
                mappingsTableEntry.w Map_objAF_a_018A
                mappingsTableEntry.w Map_objAF_a_019C
                mappingsTableEntry.w Map_objAF_a_01AE
                mappingsTableEntry.w Map_objAF_a_01C0
                mappingsTableEntry.w Map_objAF_a_01CA
                mappingsTableEntry.w Map_objAF_a_01D4
                mappingsTableEntry.w Map_objAF_a_01DE
                mappingsTableEntry.w Map_objAF_a_01E8
                mappingsTableEntry.w Map_objAF_a_01F2
                mappingsTableEntry.w Map_objAF_a_01FC
                mappingsTableEntry.w Map_objAF_a_0206
                mappingsTableEntry.w Map_objAF_a_0210
                mappingsTableEntry.w Map_objAF_a_021A

Map_objAF_a_002E:   spriteHeader
                spritePiece -$D, -$1C, 3, 2, 0, 0, 0, 0, 0
                spritePiece -$11, -$C, 4, 4, 6, 0, 0, 0, 0
                spritePiece -$14, $14, 4, 1, $16, 0, 0, 0, 0
                spritePiece -$C, -$1C, 2, 1, $6F, 0, 0, 0, 0
                spritePiece 4, -$1C, 2, 4, $71, 0, 0, 0, 0
Map_objAF_a_002E_End

Map_objAF_a_0058:   spriteHeader
                spritePiece -$D, -$1C, 3, 2, 0, 0, 0, 0, 0
                spritePiece -$11, -$C, 4, 4, 6, 0, 0, 0, 0
                spritePiece -$14, $14, 4, 1, $16, 0, 0, 0, 0
                spritePiece -$C, -$1C, 2, 1, $79, 0, 0, 0, 0
                spritePiece 4, -$1C, 2, 4, $7B, 0, 0, 0, 0
Map_objAF_a_0058_End

Map_objAF_a_0082:   spriteHeader
                spritePiece -$D, -$1C, 3, 2, 0, 0, 0, 0, 0
                spritePiece -$11, -$C, 4, 4, 6, 0, 0, 0, 0
                spritePiece -$14, $14, 4, 1, $16, 0, 0, 0, 0
                spritePiece -$C, -$1C, 2, 1, $83, 0, 0, 0, 0
                spritePiece 4, -$1C, 2, 4, $85, 0, 0, 0, 0
Map_objAF_a_0082_End

Map_objAF_a_00AC:   spriteHeader
                spritePiece -$14, -$1C, 4, 4, $1A, 0, 0, 0, 0
                spritePiece $C, -$1C, 1, 4, $2A, 0, 0, 0, 0
                spritePiece -$C, 4, 4, 3, $2E, 0, 0, 0, 0
                spritePiece -$14, $14, 1, 1, $3A, 0, 0, 0, 0
Map_objAF_a_00AC_End

Map_objAF_a_00CE:   spriteHeader
                spritePiece -$10, -$1C, 4, 3, $3B, 0, 0, 0, 0
                spritePiece -$18, 4, 1, 2, $47, 0, 0, 0, 0
                spritePiece -$10, -4, 4, 4, $49, 0, 0, 0, 0
                spritePiece $10, -4, 1, 4, $59, 0, 0, 0, 0
Map_objAF_a_00CE_End

Map_objAF_a_00F0:   spriteHeader
                spritePiece -$10, -$1C, 2, 3, $5D, 0, 0, 0, 0
                spritePiece 0, -$1C, 2, 3, $5D, 1, 0, 0, 0
                spritePiece -$18, -4, 3, 4, $63, 0, 0, 0, 0
                spritePiece 0, -4, 3, 4, $63, 1, 0, 0, 0
Map_objAF_a_00F0_End

Map_objAF_a_0112:   spriteHeader
                spritePiece -$18, -$12, 3, 3, $8D, 0, 0, 0, 0
                spritePiece 0, -$12, 3, 3, $96, 0, 0, 0, 0
                spritePiece -$18, 6, 3, 3, $96, 1, 1, 0, 0
                spritePiece 0, 6, 3, 3, $8D, 1, 1, 0, 0
Map_objAF_a_0112_End

Map_objAF_a_0134:   spriteHeader
                spritePiece -$18, -$12, 3, 3, $9F, 0, 0, 0, 0
                spritePiece 0, -$12, 3, 3, $A8, 0, 0, 0, 0
                spritePiece -$18, 6, 3, 3, $A8, 1, 1, 0, 0
                spritePiece 0, 6, 3, 3, $9F, 1, 1, 0, 0
Map_objAF_a_0134_End

Map_objAF_a_0156:   spriteHeader
                spritePiece -$18, -$12, 3, 3, $B1, 0, 0, 0, 0
                spritePiece 0, -$12, 3, 3, $BA, 0, 0, 0, 0
                spritePiece -$18, 6, 3, 3, $BA, 1, 1, 0, 0
                spritePiece 0, 6, 3, 3, $B1, 1, 1, 0, 0
Map_objAF_a_0156_End

Map_objAF_a_0178:   spriteHeader
                spritePiece $E, 4, 1, 1, $C3, 0, 0, 0, 0
                spritePiece $12, $14, 3, 1, $CB, 0, 0, 0, 0
Map_objAF_a_0178_End

Map_objAF_a_018A:   spriteHeader
                spritePiece $E, 4, 3, 1, $C4, 0, 0, 0, 0
                spritePiece $12, $14, 3, 1, $CE, 0, 0, 0, 0
Map_objAF_a_018A_End

Map_objAF_a_019C:   spriteHeader
                spritePiece -$C, $1C, 1, 1, $C7, 0, 0, 0, 0
                spritePiece -4, $1C, 1, 1, $C7, 0, 0, 0, 0
Map_objAF_a_019C_End

Map_objAF_a_01AE:   spriteHeader
                spritePiece -$C, $1C, 1, 3, $C8, 0, 0, 0, 0
                spritePiece -4, $1C, 1, 3, $C8, 0, 0, 0, 0
Map_objAF_a_01AE_End

Map_objAF_a_01C0:   spriteHeader
                spritePiece $12, $14, 3, 1, $CB, 0, 0, 0, 0
Map_objAF_a_01C0_End

Map_objAF_a_01CA:   spriteHeader
                spritePiece $12, $14, 3, 1, $CE, 0, 0, 0, 0
Map_objAF_a_01CA_End

Map_objAF_a_01D4:   spriteHeader
                spritePiece -4, -8, 1, 2, $D1, 0, 0, 0, 0
Map_objAF_a_01D4_End

Map_objAF_a_01DE:   spriteHeader
                spritePiece -8, -8, 2, 2, $D3, 0, 0, 0, 0
Map_objAF_a_01DE_End

Map_objAF_a_01E8:   spriteHeader
                spritePiece -8, -4, 2, 1, $D7, 0, 0, 0, 0
Map_objAF_a_01E8_End

Map_objAF_a_01F2:   spriteHeader
                spritePiece -8, -8, 2, 2, $D3, 0, 1, 0, 0
Map_objAF_a_01F2_End

Map_objAF_a_01FC:   spriteHeader
                spritePiece -4, -8, 1, 2, $D1, 0, 1, 0, 0
Map_objAF_a_01FC_End

Map_objAF_a_0206:   spriteHeader
                spritePiece -8, -8, 2, 2, $D3, 1, 1, 0, 0
Map_objAF_a_0206_End

Map_objAF_a_0210:   spriteHeader
                spritePiece -8, -4, 2, 1, $D7, 1, 0, 0, 0
Map_objAF_a_0210_End

Map_objAF_a_021A:   spriteHeader
                spritePiece -8, -8, 2, 2, $D3, 1, 0, 0, 0
Map_objAF_a_021A_End

                even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
ObjAF_MapUnc_3A08C:
Map_objAF_b:    mappingsTable
                mappingsTableEntry.w Map_objAF_b_0010
                mappingsTableEntry.w Map_objAF_b_003A
                mappingsTableEntry.w Map_objAF_b_0064
                mappingsTableEntry.w Map_objAF_b_008E
                mappingsTableEntry.w Map_objAF_b_00C8
                mappingsTableEntry.w Map_objAF_b_0102
                mappingsTableEntry.w Map_objAF_b_011C
                mappingsTableEntry.w Map_objAF_b_0136

Map_objAF_b_0010:   spriteHeader
                spritePiece -$10, -$C, 2, 3, 0, 0, 0, 1, 0
                spritePiece 0, -$C, 2, 3, 0, 1, 0, 1, 0
                spritePiece -$10, 4, 2, 1, 6, 0, 0, 1, 0
                spritePiece 0, 4, 2, 1, 6, 0, 0, 1, 0
                spritePiece -$10, -8, 4, 2, $190, 0, 0, 0, 0
Map_objAF_b_0010_End

Map_objAF_b_003A:   spriteHeader
                spritePiece -$10, -$C, 2, 3, 0, 0, 0, 1, 0
                spritePiece 0, -$C, 2, 3, 0, 1, 0, 1, 0
                spritePiece -$10, 0, 2, 1, 6, 0, 0, 1, 0
                spritePiece 0, 0, 2, 1, 6, 0, 0, 1, 0
                spritePiece -$10, -8, 4, 2, $190, 0, 0, 0, 0
Map_objAF_b_003A_End

Map_objAF_b_0064:   spriteHeader
                spritePiece -$10, -$C, 2, 3, 0, 0, 0, 1, 0
                spritePiece 0, -$C, 2, 3, 0, 1, 0, 1, 0
                spritePiece -$10, -4, 2, 1, 6, 0, 0, 1, 0
                spritePiece 0, -4, 2, 1, 6, 0, 0, 1, 0
                spritePiece -$10, -8, 4, 2, $190, 0, 0, 0, 0
Map_objAF_b_0064_End

Map_objAF_b_008E:   spriteHeader
                spritePiece -$10, -$C, 2, 3, 0, 0, 0, 1, 0
                spritePiece 0, -$C, 2, 3, 0, 1, 0, 1, 0
                spritePiece -$10, -8, 2, 1, 6, 0, 0, 1, 0
                spritePiece 0, -8, 2, 1, 6, 0, 0, 1, 0
                spritePiece -$10, 0, 2, 1, 6, 0, 0, 1, 0
                spritePiece 0, 0, 2, 1, 6, 0, 0, 1, 0
                spritePiece -$10, -8, 4, 2, $190, 0, 0, 0, 0
Map_objAF_b_008E_End

Map_objAF_b_00C8:   spriteHeader
                spritePiece -$10, -$C, 2, 3, 0, 0, 0, 1, 0
                spritePiece 0, -$C, 2, 3, 0, 1, 0, 1, 0
                spritePiece -$10, -$C, 2, 1, 6, 0, 0, 1, 0
                spritePiece 0, -$C, 2, 1, 6, 0, 0, 1, 0
                spritePiece -$10, -4, 2, 1, 6, 0, 0, 1, 0
                spritePiece 0, -4, 2, 1, 6, 0, 0, 1, 0
                spritePiece -$10, -8, 4, 2, $190, 0, 0, 0, 0
Map_objAF_b_00C8_End

Map_objAF_b_0102:   spriteHeader
                spritePiece -$10, -$C, 2, 3, 0, 0, 0, 1, 0
                spritePiece 0, -$C, 2, 3, 0, 1, 0, 1, 0
                spritePiece -$10, -8, 4, 2, $190, 0, 0, 0, 0
Map_objAF_b_0102_End

Map_objAF_b_011C:   spriteHeader
                spritePiece -$10, -$C, 2, 3, 0, 0, 0, 1, 0
                spritePiece 0, -$C, 2, 3, 0, 1, 0, 1, 0
                spritePiece -$10, -7, 4, 2, $190, 0, 0, 0, 0
Map_objAF_b_011C_End

Map_objAF_b_0136:   spriteHeader
                spritePiece -$10, -$C, 2, 3, 0, 0, 0, 1, 0
                spritePiece 0, -$C, 2, 3, 0, 1, 0, 1, 0
                spritePiece -$10, -8, 4, 2, $198, 0, 0, 0, 0
Map_objAF_b_0136_End

                even

; ===========================================================================
; ----------------------------------------------------------------------------
; Object B0 - Sonic on the Sega screen
; ----------------------------------------------------------------------------
; Sprite_3A1DC:
