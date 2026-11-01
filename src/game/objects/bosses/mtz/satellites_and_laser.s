Obj53:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj53_Index(pc,d0.w),d1
                jmp     Obj53_Index(pc,d1.w)
; ===========================================================================
; off_3294E:
Obj53_Index:    offsetTable
                offsetTableEntry.w Obj53_Init           ; 0
                offsetTableEntry.w Obj53_Main           ; 2
                offsetTableEntry.w Obj53_BreakAway      ; 4
                offsetTableEntry.w Obj53_BounceAround   ; 6
                offsetTableEntry.w Obj53_Burst          ; 8
; ===========================================================================
; loc_32958:
Obj53_Init:
                movea.l a0,a1
                moveq   #6,d3
                moveq   #0,d2
                bra.s   +
; ===========================================================================
-               jsrto   JmpTo17_AllocateObject
                bne.s   ++
+
                move.b  #$20,width_pixels(a1)
                move.l  objoff_34(a0),objoff_34(a1)
                move.b  #ObjID_MTZBossOrb,id(a1)        ; load obj53
                move.l  #Obj54_MapUnc_32DC6,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_MTZBoss,0,0),art_tile(a1)
                ori.b   #1<<render_flags.level_fg,render_flags(a1)
                move.b  #3,priority(a1)
                addq.b  #2,routine(a1)                  ; => Obj53_Main
                move.b  #5,mapping_frame(a1)
                move.b  byte_329CC(pc,d2.w),objoff_28(a1)
                move.b  byte_329CC(pc,d2.w),objoff_3B(a1)
                move.b  byte_329D3(pc,d2.w),objoff_3A(a1)
                move.b  #$40,objoff_29(a1)
                move.b  #$87,collision_flags(a1)
                move.b  #2,collision_property(a1)
                move.b  #0,objoff_3C(a1)
                addq.w  #1,d2
                dbf     d3,-
+
                rts
; ===========================================================================
byte_329CC:
                dc.b    $24
                dc.b    $6C                             ; 1
                dc.b    $B4                             ; 2
                dc.b    $FC                             ; 3
                dc.b    $48                             ; 4
                dc.b    $90                             ; 5
                dc.b    $D8                             ; 6
byte_329D3:
                dc.b    0
                dc.b    1                               ; 1
                dc.b    1                               ; 2
                dc.b    0                               ; 3
                dc.b    1                               ; 4
                dc.b    1                               ; 5
                dc.b    0                               ; 6
                even
; ===========================================================================
; loc_329DA
Obj53_Main:
                movea.l objoff_34(a0),a1                ; a1=object
                move.w  y_pos(a1),objoff_2A(a0)
                subi_.w #4,objoff_2A(a0)
                move.w  x_pos(a1),objoff_38(a0)
                tst.b   objoff_38(a1)
                beq.s   Obj53_ClearBossCollision
                move.b  #0,objoff_38(a1)
                addi_.b #1,objoff_2C(a1)
                addq.b  #2,routine(a0)                  ; => Obj53_BreakAway
                move.b  #60,objoff_32(a0)
                move.b  #2,anim(a0)
                move.w  #-$400,y_vel(a0)
                move.w  #-$80,d1
                move.w  (MainCharacter+x_pos).w,d0
                sub.w   x_pos(a0),d0
                bpl.s   +
                neg.w   d1
+
                cmpi.w  #$2AF0,x_pos(a0)
                bhs.s   +
                move.w  #$80,d1
+
                cmpi.w  #$2BB0,x_pos(a0)
                blo.s   +
                move.w  #-$80,d1
+
                bclr    #render_flags.x_flip,render_flags(a0)
                tst.w   d1
                bmi.s   +
                bset    #render_flags.x_flip,render_flags(a0)
+
                move.w  d1,x_vel(a0)
                bra.s   +
; ===========================================================================
; loc_32A56
Obj53_ClearBossCollision:
                cmpi.b  #2,collision_property(a0)
                beq.s   +
                move.b  #0,collision_flags(a1)
+
                bsr.w   Obj53_OrbitBoss
                bsr.w   Obj53_SetAnimPriority
                jmpto   JmpTo40_DisplaySprite
; ===========================================================================
; loc_32A70
Obj53_OrbitBoss:
                move.b  objoff_29(a0),d0
                jsr     (CalcSine).l
                move.w  d0,d3
                moveq   #0,d1
                move.b  objoff_33(a1),d1
                muls.w  d1,d0
                move.w  d0,d5
                move.w  d0,d4
                move.b  objoff_39(a1),d2
                tst.b   objoff_3A(a1)
                beq.s   +
                move.w  #$10,d2
+
                muls.w  d3,d2
                move.w  objoff_38(a0),d6
                move.b  objoff_28(a0),d0
                jsr     (CalcSine).l
                muls.w  d0,d5
                swap    d5
                add.w   d6,d5
                move.w  d5,x_pos(a0)
                muls.w  d1,d4
                swap    d4
                move.w  d4,objoff_30(a0)
                move.w  objoff_2A(a0),d6
                move.b  objoff_3B(a0),d0
                tst.b   objoff_3A(a1)
                beq.s   +
                move.b  objoff_3C(a0),d0
+
                jsr     (CalcSine).l
                muls.w  d0,d2
                swap    d2
                add.w   d6,d2
                move.w  d2,y_pos(a0)
                addq.b  #4,objoff_28(a0)
                tst.b   objoff_3A(a1)
                bne.s   +
                addq.b  #8,objoff_3B(a0)
                rts
; ===========================================================================
+
                cmpi.b  #-1,objoff_3A(a1)
                beq.s   ++
                cmpi.b  #$80,objoff_3A(a1)
                bne.s   +
                subq.b  #2,objoff_3C(a0)
                bpl.s   MtzBossSatellitesAndLaser_Return
                clr.b   objoff_3C(a0)
+
                move.b  #0,objoff_3A(a1)
                rts
; ===========================================================================
+
                cmpi.b  #$40,objoff_3C(a0)
                bhs.s   MtzBossSatellitesAndLaser_Return
                addq.b  #2,objoff_3C(a0)

MtzBossSatellitesAndLaser_Return:
                rts
; ===========================================================================
; loc_32B1A
Obj53_SetAnimPriority:
                move.w  objoff_30(a0),d0
                bmi.s   ++
                cmpi.w  #$C,d0
                blt.s   +
                move.b  #3,mapping_frame(a0)
                move.b  #1,priority(a0)
                rts
; ===========================================================================
+
                move.b  #4,mapping_frame(a0)
                move.b  #2,priority(a0)
                rts
; ===========================================================================
+
                cmpi.w  #-$C,d0
                blt.s   +
                move.b  #4,mapping_frame(a0)
                move.b  #6,priority(a0)
                rts
; ===========================================================================
+
                move.b  #5,mapping_frame(a0)
                move.b  #7,priority(a0)
                rts
; ===========================================================================
; loc_32B64
Obj53_BreakAway:
                tst.b   objoff_32(a0)
                bmi.s   +
                subq.b  #1,objoff_32(a0)
                bpl.s   +
                move.b  #$DA,collision_flags(a0)
+
                jsrto   JmpTo6_ObjectMoveAndFall
                subi.w  #$20,y_vel(a0)
                cmpi.w  #$180,y_vel(a0)
                blt.s   +
                move.w  #$180,y_vel(a0)
+
                cmpi.w  #$4AC,y_pos(a0)
                blo.s   Obj53_Animate
                move.w  #$4AC,y_pos(a0)
                move.w  #$4AC,objoff_2E(a0)
                move.b  #1,objoff_2C(a0)
                addq.b  #2,routine(a0)
                bsr.w   Obj53_FaceLeader
; loc_32BB0
Obj53_Animate:
                bsr.w   +
                lea     (Ani_obj53).l,a1
                jsrto   JmpTo21_AnimateSprite
                jmpto   JmpTo40_DisplaySprite
; ===========================================================================
+
                cmpi.b  #-2,collision_property(a0)
                bgt.s   +                               ; rts
                move.b  #$14,mapping_frame(a0)
                move.b  #6,anim(a0)
                addq.b  #2,routine(a0)
+
                rts
; ===========================================================================
; loc_32BDC
Obj53_BounceAround:
                tst.b   objoff_32(a0)
                bmi.s   +
                subq.b  #1,objoff_32(a0)
                bpl.s   +
                move.b  #$DA,collision_flags(a0)
+
                bsr.w   Obj53_CheckPlayerHit
                cmpi.b  #$B,mapping_frame(a0)
; If Tails defeats one of the clones two frames after Sonic has been
; hit by one, the game will crash due to incrementing routine twice
                bne.s   Obj53_Animate
                move.b  objoff_2C(a0),d0
                jsr     (CalcSine).l
                neg.w   d0
                asr.w   #2,d0
                add.w   objoff_2E(a0),d0
                cmpi.w  #$4AC,d0
                bhs.s   ++
                move.w  d0,y_pos(a0)
                addq.b  #1,objoff_2C(a0)
                btst    #0,objoff_2C(a0)
                beq.w   JmpTo40_DisplaySprite
                moveq   #-1,d0
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                neg.w   d0
+
                add.w   d0,x_pos(a0)
                jmpto   JmpTo40_DisplaySprite
; ===========================================================================
+
                move.w  #$4AC,y_pos(a0)
                bsr.w   Obj53_FaceLeader
                move.b  #1,objoff_2C(a0)
                jmpto   JmpTo40_DisplaySprite
; ===========================================================================
; loc_32C4C
Obj53_FaceLeader:
                move.w  (MainCharacter+x_pos).w,d0
                sub.w   x_pos(a0),d0
                bpl.s   +
                bclr    #render_flags.x_flip,render_flags(a0)
                rts
; ===========================================================================
+
                bset    #render_flags.x_flip,render_flags(a0)
                rts
; ===========================================================================
; loc_32C66
Obj53_CheckPlayerHit:
                cmpi.b  #4,(MainCharacter+routine).w
                beq.s   +
                cmpi.b  #4,(Sidekick+routine).w
                bne.s   ++
+
                move.b  #$14,mapping_frame(a0)
                move.b  #6,anim(a0)
+
                cmpi.b  #-2,collision_property(a0)
                bgt.s   +
                move.b  #$14,mapping_frame(a0)
                move.b  #6,anim(a0)
+
                rts
; ===========================================================================
; loc_32C98
Obj53_Burst:
                move.b  #SndID_BossExplosion,d0
                jsrto   JmpTo10_PlaySound
                movea.l objoff_34(a0),a1                ; a1=object
                subi_.b #1,objoff_2C(a1)
                jmpto   JmpTo61_DeleteObject
; ===========================================================================
; loc_32CAE
Obj54_Laser:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_32CBC(pc,d0.w),d0
                jmp     off_32CBC(pc,d0.w)
; ===========================================================================
off_32CBC:      offsetTable
                offsetTableEntry.w Obj54_Laser_Init     ; 0
                offsetTableEntry.w Obj54_Laser_Main     ; 2
; ===========================================================================
; loc_32CC0
Obj54_Laser_Init:
                move.l  #Obj54_MapUnc_32DC6,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_MTZBoss,0,0),art_tile(a0)
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  #5,priority(a0)
                move.b  #$12,mapping_frame(a0)
                addq.b  #2,routine_secondary(a0)        ; => Obj54_Laser_Main
                movea.l objoff_34(a0),a1                ; a1=object
                move.b  #$50,width_pixels(a0)
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                addi_.w #7,y_pos(a0)
                subi_.w #4,x_pos(a0)
                move.w  #-$400,d0
                btst    #render_flags.x_flip,render_flags(a1)
                beq.s   +
                neg.w   d0
                addi_.w #8,x_pos(a0)
+
                move.w  d0,x_vel(a0)
                move.b  #$99,collision_flags(a0)
                move.b  #SndID_LaserBurst,d0
                jsrto   JmpTo10_PlaySound
; loc_32D2C
Obj54_Laser_Main:
                jsrto   JmpTo24_ObjectMove
                cmpi.w  #$2AB0,x_pos(a0)
                blo.w   JmpTo61_DeleteObject
                cmpi.w  #$2BF0,x_pos(a0)
                bhs.w   JmpTo61_DeleteObject
                jmpto   JmpTo40_DisplaySprite
; ===========================================================================
; loc_32D48
Obj54_LaserShooter:
                movea.l objoff_34(a0),a1                ; a1=object
                cmpi.b  #ObjID_MTZBoss,id(a1)
                bne.w   JmpTo61_DeleteObject
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                bclr    #render_flags.x_flip,render_flags(a0)
                btst    #render_flags.x_flip,render_flags(a1)
                beq.w   JmpTo40_DisplaySprite
                bset    #render_flags.x_flip,render_flags(a0)
                jmpto   JmpTo40_DisplaySprite

; ===========================================================================
; animation script
; off_32D7A:
Ani_obj53:      offsetTable
                offsetTableEntry.w MtzBossSatellitesAndLaser_Animation_Sequence0           ; 0
                offsetTableEntry.w MtzBossSatellitesAndLaser_Animation_Sequence1           ; 1
                offsetTableEntry.w MtzBossSatellitesAndLaser_Animation_Sequence2           ; 2
                offsetTableEntry.w MtzBossSatellitesAndLaser_Animation_Sequence3           ; 3
                offsetTableEntry.w MtzBossSatellitesAndLaser_Animation_Sequence4           ; 4
                offsetTableEntry.w MtzBossSatellitesAndLaser_Animation_Sequence5           ; 5
                offsetTableEntry.w MtzBossSatellitesAndLaser_Animation_Sequence6           ; 6
                offsetTableEntry.w MtzBossSatellitesAndLaser_Animation_Sequence7           ; 7
MtzBossSatellitesAndLaser_Animation_Sequence0:     dc.b    $F,  2,$FF
MtzBossSatellitesAndLaser_Animation_Sequence1:     dc.b    1,  0,  1,$FF
MtzBossSatellitesAndLaser_Animation_Sequence2:     dc.b    3,  5,  5,  5,  5,  5,  5,  5,  5,  6,  7,  6,  7,  6,  7,  8
                dc.b    9, $A, $B,$FE,  1               ; 16
MtzBossSatellitesAndLaser_Animation_Sequence3:     dc.b    7, $C, $D,$FF
MtzBossSatellitesAndLaser_Animation_Sequence4:     dc.b    7, $E, $F, $E, $F, $E, $F, $E, $F,$FD,  3
MtzBossSatellitesAndLaser_Animation_Sequence5:     dc.b    7,$10,$10,$10,$10,$10,$10,$10,$10,$FD,  3
MtzBossSatellitesAndLaser_Animation_Sequence6:     dc.b    1,$14,$FC
MtzBossSatellitesAndLaser_Animation_Sequence7:     dc.b    7,$11,$FF
                even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj54_MapUnc_32DC6: include "src/game/objects/bosses/mtz/data/mappings.s"
; ===========================================================================

                jmpTos0 JmpTo40_DisplaySprite,JmpTo61_DeleteObject,JmpTo17_AllocateObject,JmpTo10_PlaySound,JmpTo21_AnimateSprite,JmpTo11_LoadPLC,JmpTo8_AddPoints,JmpTo7_PlayLevelMusic,JmpTo7_LoadPLC_AnimalExplosion,JmpTo6_ObjectMoveAndFall,JmpTo24_ObjectMove

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 55 - OOZ boss
; ----------------------------------------------------------------------------
; OST Variables:
Obj55_status                =       objoff_2A           ; bitfield
Obj55_anim_frame_duration   =       objoff_2C           ; number of frames the laser shooter displays its shooting frame
Obj55_shot_count            =       objoff_38           ; number of lasers the shooter fires during its attack phase
Obj55_laser_pos             =       objoff_3E           ; bitfield, each of the first four bits stands for one of the possible y positions a laser can be fired from

Obj55_Wave_delay    =       objoff_32                   ; time before the next part of the wave is created
Obj55_Wave_parent   =       objoff_34                   ; pointer to main vehicle
Obj55_Wave_count    =       objoff_36                   ; number of waves to make

; Sprite_32F90:
