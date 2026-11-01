Obj5D_Gunk:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  Obj5D_Gunk_States(pc,d0.w),d1
                jmp     Obj5D_Gunk_States(pc,d1.w)
; ===========================================================================
Obj5D_Gunk_States:  offsetTable
                offsetTableEntry.w Obj5D_Gunk_Init      ; 0
                offsetTableEntry.w Obj5D_Gunk_Main      ; 2
                offsetTableEntry.w Obj5D_Gunk_Droplets  ; 4
                offsetTableEntry.w Obj5D_Gunk_6         ; 6
                offsetTableEntry.w Obj5D_Gunk_8         ; 8
; ===========================================================================

Obj5D_Gunk_Init:
                addq.b  #2,routine_secondary(a0)        ; => Obj5D_Gunk_Main
; The hitbox for this object is a mess, allowing the player to avoid
; damage by simply ducking. Ideally, it would be realigned with the
; sprite, but this will have to do for now
; Funnily enough, the Official Players Guide brings this up on page 90
                move.b  #$20,y_radius(a0)
                move.b  #$19,anim(a0)
                move.w  #0,y_vel(a0)
                movea.l Obj5D_parent(a0),a1             ; a1=object
                movea.l Obj5D_parent(a1),a1
                btst    #2,Obj5D_status(a1)
                beq.s   Obj5D_Gunk_Main
                bclr    #2,Obj5D_status(a1)
                move.b  #6,routine_secondary(a0)        ; => Obj5D_Gunk_6
                move.w  #9,Obj5D_timer2(a0)

Obj5D_Gunk_Main:
                jsrto   JmpTo3_ObjectMoveAndFall
                jsr     (ObjCheckFloorDist).l
                tst.w   d1
                bmi.s   +                               ; branch, if hit the floor
                cmpi.w  #$518,y_pos(a0)
                bge.s   Obj5D_Gunk_OffScreen            ; branch, if fallen off screen
                lea     (Ani_Obj5D_Dripper).l,a1
                jsr     (AnimateSprite).l
                jmp     (DisplaySprite).l
; ===========================================================================
+
                add.w   d1,y_pos(a0)
                movea.l Obj5D_parent(a0),a1             ; a1=object
                movea.l Obj5D_parent(a1),a1
                bset    #2,Obj5D_status2(a1)
                bset    #4,Obj5D_status2(a1)
                move.b  #2,routine_secondary(a1)
                addq.b  #2,routine_secondary(a0)        ; => Obj5D_Gunk_Droplets
                move.b  #0,subtype(a0)
                move.w  #SndID_MegaMackDrop,d0
                jsrto   JmpTo5_PlaySound
                jmp     (DisplaySprite).l
; ===========================================================================

Obj5D_Gunk_OffScreen:
                movea.l Obj5D_parent(a0),a1             ; a1=object
                movea.l Obj5D_parent(a1),a1
                bset    #2,Obj5D_status2(a1)
                bset    #4,Obj5D_status2(a1)
                move.b  #2,routine_secondary(a1)
                jmpto   JmpTo51_DeleteObject
; ===========================================================================

Obj5D_Gunk_6:
                subi_.w #1,Obj5D_timer2(a0)
                bpl.s   +
                move.b  #2,priority(a0)
                move.b  #$25,mapping_frame(a0)
                movea.l Obj5D_parent(a0),a1             ; a1=object
                movea.l Obj5D_parent(a1),a1             ; a1=object
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                addq.b  #2,routine_secondary(a0)        ; => Obj5D_Gunk_8
                move.b  #8,anim_frame_duration(a0)
                bra.s   Obj5D_Gunk_8
; ===========================================================================
+
                jsrto   JmpTo23_ObjectMove
                lea     (Ani_Obj5D_Dripper).l,a1
                jsr     (AnimateSprite).l
                jmp     (DisplaySprite).l
; ===========================================================================

Obj5D_Gunk_8:
                subi_.b #1,anim_frame_duration(a0)
                bpl.s   +
                addi_.b #1,mapping_frame(a0)
                move.b  #8,anim_frame_duration(a0)
                cmpi.b  #$27,mapping_frame(a0)
                bgt.w   Obj5D_Gunk_OffScreen
                blt.s   +
                addi.b  #$C,anim_frame_duration(a0)
+
                movea.l Obj5D_parent(a0),a1             ; a1=object
                movea.l Obj5D_parent(a1),a1             ; a1=object
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                jmp     (DisplaySprite).l
; ===========================================================================

Obj5D_Gunk_Droplets:
                moveq   #0,d0
                move.b  subtype(a0),d0
                bne.w   Obj5D_Gunk_Droplets_Move
                addi.w  #$18,y_pos(a0)
                addi.w  #$C,x_pos(a0)
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                subi.w  #$18,x_pos(a0)
+
                move.b  #4,y_radius(a0)
                move.b  #4,x_radius(a0)
                addq.b  #1,subtype(a0)
                move.b  #9,mapping_frame(a0)
                move.w  y_vel(a0),d0
                lsr.w   #1,d0
                neg.w   d0
                move.w  d0,y_vel(a0)
                jsr     (RandomNumber).l
                asr.w   #6,d0
                bmi.s   +
                addi.w  #$200,d0
+
                addi.w  #-$100,d0
                move.w  d0,x_vel(a0)
                move.b  #0,collision_flags(a0)
                moveq   #3,d3

Obj5D_Gunk_Droplets_Loop:
                jsr     (AllocateObjectAfterCurrent).l
                bne.w   BranchTo_JmpTo34_DisplaySprite
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  a0,Obj5D_parent(a1)
                move.l  #Obj5D_MapUnc_2EADC,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_CPZBoss,3,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #2,priority(a1)
                move.l  x_pos(a0),x_pos(a1)
                move.l  y_pos(a0),y_pos(a1)
                move.b  #4,y_radius(a1)
                move.b  #4,x_radius(a1)
                move.b  #9,mapping_frame(a1)
                move.b  #$C,routine(a1)
                move.b  #4,routine_secondary(a1)
                move.b  #1,subtype(a1)
                move.w  y_vel(a0),y_vel(a1)
                move.b  collision_flags(a0),collision_flags(a1)
                jsr     (RandomNumber).l
                asr.w   #6,d0
                bmi.s   +
                addi.w  #$80,d0
+
                addi.w  #-$80,d0
                move.w  d0,x_vel(a1)
                swap    d0
                andi.w  #$3FF,d0
                sub.w   d0,y_vel(a1)
                dbf     d3,Obj5D_Gunk_Droplets_Loop

BranchTo_JmpTo34_DisplaySprite                          ; BranchTo
                jmpto   JmpTo34_DisplaySprite
; ===========================================================================

Obj5D_Gunk_Droplets_Move:
                jsrto   JmpTo3_ObjectMoveAndFall
                jsr     (ObjCheckFloorDist).l
                tst.w   d1
                bmi.s   +
                jmpto   JmpTo35_MarkObjGone
; ---------------------------------------------------------------------------
+
                jmpto   JmpTo51_DeleteObject
; ===========================================================================

; a bit of unused/dead code here
                add.w   d1,y_pos(a0)                    ; a0=object
                move.w  y_vel(a0),d0
                lsr.w   #1,d0
                neg.w   d0
                move.w  d0,y_vel(a0)
                jmpto   JmpTo34_DisplaySprite

; ===========================================================================

Obj5D_Robotnik:
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.l  x_pos(a1),x_pos(a0)
                move.l  y_pos(a1),y_pos(a0)
                move.b  status(a1),status(a0)
                move.b  render_flags(a1),render_flags(a0)
                move.b  Obj5D_invulnerable_time(a1),d0
                cmpi.b  #$1F,d0
                bne.s   +
                move.b  #2,anim(a0)
+
                cmpi.b  #4,(MainCharacter+routine).w
                beq.s   +
                cmpi.b  #4,(Sidekick+routine).w
                bne.s   Obj5D_Robotnik_End
+
                move.b  #3,anim(a0)

Obj5D_Robotnik_End:
                lea     (Ani_obj5D_b).l,a1
                jsr     (AnimateSprite).l
                jmp     (DisplaySprite).l
; ===========================================================================
; byte_2E94A:
Obj5D_Flame_Frames:
                dc.b    0
                dc.b    -1                              ; 1
                dc.b    1                               ; 2
                even
; ===========================================================================

Obj5D_Flame:
                btst    #status.npc.no_balancing,status(a0)
                bne.s   loc_2E9A8
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.l  x_pos(a1),x_pos(a0)
                move.l  y_pos(a1),y_pos(a0)
                move.b  status(a1),status(a0)
                move.b  render_flags(a1),render_flags(a0)
                subq.b  #1,anim_frame_duration(a0)
                bpl.s   loc_2E996
                move.b  #1,anim_frame_duration(a0)
                move.b  Obj5D_timer2(a0),d0
                addq.b  #1,d0
                cmpi.b  #2,d0
                ble.s   +
                moveq   #0,d0
+
                move.b  Obj5D_Flame_Frames(pc,d0.w),mapping_frame(a0)
                move.b  d0,Obj5D_timer2(a0)

loc_2E996:
                cmpi.b  #-1,mapping_frame(a0)
                bne.w   JmpTo34_DisplaySprite
                move.b  #0,mapping_frame(a0)
                rts
; ===========================================================================

loc_2E9A8:
                movea.l Obj5D_parent(a0),a1             ; a1=object
                btst    #6,Obj5D_status2(a1)
                bne.s   +
                rts
; ===========================================================================
+
; Eggman is supposed to start leaving a trail of smoke here, but
; this code is incorrect which prevents it from appearing
; This should be 'routine' instead of 'routine_secondary'
                addq.b  #2,routine_secondary(a0)
                move.l  #Obj5D_MapUnc_2EEA0,mappings(a0)
; ...and this should be 'make_art_tile(ArtTile_ArtNem_BossSmoke_1,1,0)' instead
                move.w  #make_art_tile(ArtTile_ArtNem_EggpodJets_1,0,0),art_tile(a0)
                jsrto   JmpTo60_Adjust2PArtPointer
                move.b  #0,mapping_frame(a0)
                move.b  #5,anim_frame_duration(a0)
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                addi_.w #4,y_pos(a0)
                subi.w  #$28,x_pos(a0)
                rts
; ===========================================================================
; Obj5D_1A:
Obj5D_Smoke_Puff:
                subq.b  #1,anim_frame_duration(a0)
                bpl.s   BranchTo2_JmpTo34_DisplaySprite
                move.b  #5,anim_frame_duration(a0)
                addq.b  #1,mapping_frame(a0)
                cmpi.b  #4,mapping_frame(a0)
                bne.w   BranchTo2_JmpTo34_DisplaySprite
                move.b  #0,mapping_frame(a0)
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.b  id(a1),d0
                beq.w   JmpTo51_DeleteObject            ; branch, if parent object is gone
                move.w  x_pos(a1),x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                addi_.w #4,y_pos(a0)
                subi.w  #$28,x_pos(a0)

BranchTo2_JmpTo34_DisplaySprite                         ; BranchTo
                jmpto   JmpTo34_DisplaySprite

; ===========================================================================
; animation script
; off_2EA3C:
Ani_Obj5D_Dripper:  offsetTable
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence0           ; 0
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence1           ; 1
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence2           ; 2
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence3           ; 3
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence4           ; 4
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence5           ; 5
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence6           ; 6
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence7           ; 7
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence8           ; 8
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence9           ; 9
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence10           ; $A
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence11           ; $B
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence12           ; $C
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence13           ; $D
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence14           ; $E
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence15           ; $F
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence16           ; $10
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence17           ; $11
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence18           ; $12
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence19           ; $13
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence20           ; $14
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence21           ; $15
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence22           ; $16
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence23           ; $17
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence24           ; $18
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence25           ; $19
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence26           ; $1A
CpzBossGunkAndVisuals_Animation_Sequence0:     dc.b    $F,  0,$FF
CpzBossGunkAndVisuals_Animation_Sequence1:     dc.b    $F,  1,$FF
CpzBossGunkAndVisuals_Animation_Sequence2:     dc.b    5,  2,  3,  2,$FF
CpzBossGunkAndVisuals_Animation_Sequence3:     dc.b    5,  2,  3,$FF
CpzBossGunkAndVisuals_Animation_Sequence4:     dc.b    2,  4,  5,  6,  7,  8,$FF
CpzBossGunkAndVisuals_Animation_Sequence5:     dc.b    3,  9,$FF
CpzBossGunkAndVisuals_Animation_Sequence6:     dc.b    $F, $A,$FF
CpzBossGunkAndVisuals_Animation_Sequence7:     dc.b    $F,$1C,$FF
CpzBossGunkAndVisuals_Animation_Sequence8:     dc.b    $F,$1E,$FF
CpzBossGunkAndVisuals_Animation_Sequence9:     dc.b    $F, $B,$FF
CpzBossGunkAndVisuals_Animation_Sequence10:     dc.b    3, $C, $C, $D, $D, $D, $D, $D, $C, $C,$FD,  9
CpzBossGunkAndVisuals_Animation_Sequence11:     dc.b    3, $E, $E, $F, $F, $F, $F, $F, $E, $E,$FF
CpzBossGunkAndVisuals_Animation_Sequence12:     dc.b    $F,$10,$FF
CpzBossGunkAndVisuals_Animation_Sequence13:     dc.b    $F,$11,$FF
CpzBossGunkAndVisuals_Animation_Sequence14:     dc.b    $F,$12,$FF
CpzBossGunkAndVisuals_Animation_Sequence15:     dc.b    $F,$13,$FF
CpzBossGunkAndVisuals_Animation_Sequence16:     dc.b    $F,$14,$FF
CpzBossGunkAndVisuals_Animation_Sequence17:     dc.b    $F,$15,$FF
CpzBossGunkAndVisuals_Animation_Sequence18:     dc.b    $F,$16,$FF
CpzBossGunkAndVisuals_Animation_Sequence19:     dc.b    $F,$17,$FF
CpzBossGunkAndVisuals_Animation_Sequence20:     dc.b    $F,$18,$FF
CpzBossGunkAndVisuals_Animation_Sequence21:     dc.b    $F,$19,$FF
CpzBossGunkAndVisuals_Animation_Sequence22:     dc.b    $F,$1A,$FF
CpzBossGunkAndVisuals_Animation_Sequence23:     dc.b    $F,$1B,$FF
CpzBossGunkAndVisuals_Animation_Sequence24:     dc.b    $F,$1C,$FF
CpzBossGunkAndVisuals_Animation_Sequence25:     dc.b    1,$1D,$1F,$FF
CpzBossGunkAndVisuals_Animation_Sequence26:     dc.b    $F,$1E,$FF
                even
; ----------------------------------------------------------------------------
; sprite mappings - uses ArtNem_CPZBoss
; ----------------------------------------------------------------------------
Obj5D_MapUnc_2EADC: include "src/game/objects/bosses/cpz/data/mappings_a.s"

; animation script
; off_2ED5C:
Ani_obj5D_b:    offsetTable
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence0_Variant2           ; 0
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence1_Variant2           ; 1
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence2_Variant2           ; 2
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence3_Variant2           ; 3
                offsetTableEntry.w CpzBossGunkAndVisuals_Animation_Sequence4_Variant2           ; 4
CpzBossGunkAndVisuals_Animation_Sequence0_Variant2:     dc.b    $F,  0,$FF
CpzBossGunkAndVisuals_Animation_Sequence1_Variant2:     dc.b    7,  1,  2,$FF
CpzBossGunkAndVisuals_Animation_Sequence2_Variant2:     dc.b    7,  5,  5,  5,  5,  5,  5,$FD,  1
CpzBossGunkAndVisuals_Animation_Sequence3_Variant2:     dc.b    7,  3,  4,  3,  4,  3,  4,$FD,  1
CpzBossGunkAndVisuals_Animation_Sequence4_Variant2:     dc.b    $F,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,$FD,  1
                even

; ----------------------------------------------------------------------------
; sprite mappings - uses ArtNem_Eggpod
; ----------------------------------------------------------------------------
Obj5D_MapUnc_2ED8C: include "src/game/objects/bosses/cpz/data/mappings_b.s"
; ----------------------------------------------------------------------------
; sprite mappings - uses ArtNem_EggpodJets
; ----------------------------------------------------------------------------
Obj5D_MapUnc_2EE88: include "src/game/objects/bosses/cpz/data/mappings_c.s"
; ----------------------------------------------------------------------------
; sprite mappings - uses ArtNem_BossSmoke
; ----------------------------------------------------------------------------
Obj5D_MapUnc_2EEA0: include "src/game/objects/bosses/cpz/data/mappings_d.s"
; ===========================================================================

                jmpTos  JmpTo34_DisplaySprite,JmpTo51_DeleteObject,JmpTo35_MarkObjGone,JmpTo5_PlaySound,JmpTo8_Adjust2PArtPointer2,JmpTo5_LoadPLC,JmpTo2_AddPoints,JmpTo60_Adjust2PArtPointer,JmpTo_PlayLevelMusic,JmpTo_LoadPLC_AnimalExplosion,JmpTo3_ObjectMoveAndFall,JmpTo23_ObjectMove

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 56 - EHZ boss
; the bottom part of the vehicle with the ability to fly is the parent object
; ----------------------------------------------------------------------------
; Sprite_2EF18:
