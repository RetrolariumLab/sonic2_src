Obj57:
                moveq   #0,d0
                move.b  boss_subtype(a0),d0
                move.w  Obj57_Index(pc,d0.w),d1
                jmp     Obj57_Index(pc,d1.w)
; ===========================================================================
; off_30FB2:
Obj57_Index:    offsetTable
                offsetTableEntry.w Obj57_Init           ; 0 - Init
                offsetTableEntry.w Obj57_Main           ; 2 - Main Vehicle
                offsetTableEntry.w Obj57_FallingStuff   ; 4 - Spikes & Stones
; ===========================================================================
; loc_30FB8:
Obj57_Init:
                move.l  #Obj57_MapUnc_316EC,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_MCZBoss,0,0),art_tile(a0)
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
; Multi-sprite objects cannot use the 'priority' SST as it is
; overwritten by 'sub3_y_pos'
                move.b  #3,priority(a0)                 ; gets overwritten
                move.w  #$21A0,x_pos(a0)
                move.w  #$560,y_pos(a0)
                move.b  #5,mainspr_mapframe(a0)
                addq.b  #2,boss_subtype(a0)
                move.b  #2,boss_routine(a0)
                bset    #render_flags.multi_sprite,render_flags(a0)  ; use subobjects for rendering
                move.b  #4,mainspr_childsprites(a0)
                move.b  #$F,collision_flags(a0)
                move.b  #8,boss_hitcount2(a0)
                move.w  x_pos(a0),(Boss_X_pos).w
                move.w  y_pos(a0),(Boss_Y_pos).w
                move.w  #$C0,(Boss_Y_vel).w             ; move down
                move.b  #0,(Boss_CollisionRoutine).w
                move.b  #1,(Screen_Shaking_Flag).w
                move.b  #$40,mainspr_width(a0)
                move.w  x_pos(a0),sub2_x_pos(a0)
                move.w  y_pos(a0),sub2_y_pos(a0)
                move.b  #2,sub2_mapframe(a0)
                move.w  x_pos(a0),sub3_x_pos(a0)
                move.w  y_pos(a0),sub3_y_pos(a0)
                move.b  #1,sub3_mapframe(a0)
                move.w  x_pos(a0),sub4_x_pos(a0)
                move.w  y_pos(a0),sub4_y_pos(a0)
                move.b  #$E,sub4_mapframe(a0)
                move.w  x_pos(a0),sub5_x_pos(a0)
                move.w  y_pos(a0),sub5_y_pos(a0)
                move.b  #2,sub5_mapframe(a0)
                subi.w  #$28,sub5_x_pos(a0)
                move.w  #$28,(Boss_Countdown).w
                move.w  #-$380,obj57_sub5_y_vel(a0)
                move.w  #-$380,obj57_sub2_y_vel(a0)

                bsr.w   Obj57_InitAnimationData
                rts
; ===========================================================================
; loc_31090:
Obj57_InitAnimationData:
                lea     (Boss_AnimationArray).w,a2
                move.b  #2,(a2)+                        ; hover thingies (fire on)
                move.b  #0,(a2)+
                move.b  #3,(a2)+                        ; digger 1 (vertical)
                move.b  #0,(a2)+
                move.b  #$10,(a2)+                      ; main vehicle
                move.b  #0,(a2)+
                move.b  #$D,(a2)+                       ; main vehicle center (including Robotnik's face)
                move.b  #0,(a2)+
                move.b  #3,(a2)+                        ; digger 2 (vertical)
                move.b  #0,(a2)+
                rts
; ===========================================================================
; loc_310BE:
Obj57_Main:                                             ; Main Vehicle
                moveq   #0,d0
                move.b  boss_routine(a0),d0
                move.w  Obj57_Main_Index(pc,d0.w),d1
                jmp     Obj57_Main_Index(pc,d1.w)
; ===========================================================================
; off_310CC:
Obj57_Main_Index:   offsetTable
                offsetTableEntry.w Obj57_Main_Sub0      ; 0 - boss just moving up
                offsetTableEntry.w Obj57_Main_Sub2      ; 2 - boss moving down, stuff falling down
                offsetTableEntry.w Obj57_Main_Sub4      ; 4 - moving down, stop stuff falling down
                offsetTableEntry.w Obj57_Main_Sub6      ; 6 - digger transition (rotation), moving back and forth
                offsetTableEntry.w Obj57_Main_Sub8      ; 8 - boss defeated, standing still, exploding
                offsetTableEntry.w Obj57_Main_SubA      ; $A - slowly hovering down, no explosions
                offsetTableEntry.w Obj57_Main_SubC      ; $C - moving away fast
; ===========================================================================
; loc_310DA:
Obj57_Main_Sub0:                                        ; boss just moving up
                subi_.w #1,(Boss_Countdown).w           ; countdown
                bpl.s   Obj57_Main_Sub0_Continue
                move.b  #0,(Boss_AnimationArray+5).w    ; reset anim main vehicle
                bsr.w   Boss_MoveObject
                cmpi.w  #$560,(Boss_Y_pos).w            ; a little above top screen boundary
                bgt.s   Obj57_Main_Sub0_Continue        ; if below that, branch
                move.w  #$100,(Boss_Y_vel).w
                move.w  (MainCharacter+x_pos).w,d3
                cmpi.w  #$2190,d3
                bhs.s   +
                move.w  #$2200,d3
                bra.s   ++
; ===========================================================================
+
                move.w  #$2120,d3
+
                move.w  d3,(Boss_X_pos).w
                addq.b  #2,boss_routine(a0)             ; stuff falling down
                bclr    #render_flags.x_flip,render_flags(a0)
                move.w  (MainCharacter+x_pos).w,d0
                sub.w   (Boss_X_pos).w,d0
                bmi.s   Obj57_Main_Sub0_Continue
                bset    #render_flags.x_flip,render_flags(a0)
; loc_3112C:
Obj57_Main_Sub0_Continue:                               ; if countdown finished or boss below $560
                cmpi.w  #$28,(Boss_Countdown).w
                bne.s   +
                move.b  #0,(Boss_CollisionRoutine).w
+
                cmpi.w  #$620,(Boss_Y_pos).w            ; if above, screenshaking & stones
                bge.s   Obj57_Main_Sub0_Standard
                move.b  #1,(Screen_Shaking_Flag).w
                bsr.w   Obj57_SpawnStoneSpike

Obj57_Main_Sub0_Standard:
                move.w  (Boss_Y_pos).w,y_pos(a0)
                move.w  (Boss_X_pos).w,x_pos(a0)
                bsr.w   Obj57_HandleHits
                lea     (Ani_obj57).l,a1
                bsr.w   AnimateBoss
                bsr.w   Obj57_TransferPositions
                jmpto   JmpTo38_DisplaySprite
; ===========================================================================
; loc_3116E:
Obj57_Main_Sub2:                                        ; boss moving down, stuff falling down
                bsr.w   Boss_MoveObject
                bsr.w   Obj57_SpawnStoneSpike
                cmpi.w  #$620,(Boss_Y_pos).w            ; if below
                blt.s   Obj57_Main_Sub2_Standard
                addq.b  #2,boss_routine(a0)             ; ...next routine
                move.b  #0,(Screen_Shaking_Flag).w      ; no screen shaking

Obj57_Main_Sub2_Standard:
                move.w  (Boss_Y_pos).w,y_pos(a0)
                move.w  (Boss_X_pos).w,x_pos(a0)
                bsr.w   Obj57_HandleHits
                lea     (Ani_obj57).l,a1
                bsr.w   AnimateBoss
                bsr.w   Obj57_TransferPositions
                jmpto   JmpTo38_DisplaySprite
; ===========================================================================
; loc_311AA:
Obj57_Main_Sub4:                                        ; moving down, stop stuff falling down
                bsr.w   Boss_MoveObject
                cmpi.w  #$660,(Boss_Y_pos).w
                blt.s   Obj57_Main_Sub4_Standard        ; if above, keep moving down
                move.w  #$660,(Boss_Y_pos).w            ; if below, routine 6 + new anim
                addq.b  #2,boss_routine(a0)
                lea     (Boss_AnimationArray).w,a1
                andi.b  #$F0,2(a1)
                ori.b   #6,2(a1)                        ; (6) prepare for digger rotation to diag/hztl
                andi.b  #$F0,8(a1)
                ori.b   #6,8(a1)                        ; (6) prepare for digger rotation to diag/hztl
                andi.b  #$F0,6(a1)
                ori.b   #$D,6(a1)                       ; (D) Robotnik face normal
                move.b  #$20,5(a1)                      ; main vehicle light on
                move.w  #$64,(Boss_Countdown).w
                move.b  #$30,1(a1)                      ; hover thingies fire off
                bclr    #render_flags.x_flip,render_flags(a0)
                move.w  (MainCharacter+x_pos).w,d0
                sub.w   (Boss_X_pos).w,d0
                bmi.s   +
                bset    #render_flags.x_flip,render_flags(a0)
+
                move.w  #-$200,(Boss_X_vel).w           ; boss moving horizontally
                move.w  #0,(Boss_Y_vel).w
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   Obj57_Main_Sub4_Standard
                neg.w   (Boss_X_vel).w

Obj57_Main_Sub4_Standard:
                move.w  (Boss_Y_pos).w,y_pos(a0)
                move.w  (Boss_X_pos).w,x_pos(a0)
                bsr.w   Obj57_HandleHits
                lea     (Ani_obj57).l,a1
                bsr.w   AnimateBoss
                bsr.w   Obj57_TransferPositions
                jmpto   JmpTo38_DisplaySprite
; ===========================================================================
; loc_3124A:
Obj57_Main_Sub6:                                        ; digger transition (rotation), moving back and forth
                subi_.w #1,(Boss_Countdown).w
                cmpi.w  #$28,(Boss_Countdown).w
                bgt.w   Obj57_Main_Sub6_Standard
                move.b  #1,(Boss_CollisionRoutine).w
                tst.w   (Boss_Countdown).w
                bpl.w   Obj57_Main_Sub6_Standard
                tst.b   boss_hurt_sonic(a0)             ; has Sonic just been hurt?
                beq.s   +
                sf      boss_hurt_sonic(a0)             ; if yes, clear this flag
                bra.s   Obj57_Main_Sub6_ReAscend1
; ===========================================================================
+
                bsr.w   Boss_MoveObject
                cmpi.w  #$2120,(Boss_X_pos).w
                bgt.s   +
                move.w  #$2120,(Boss_X_pos).w
                bra.s   Obj57_Main_Sub6_ReAscend2
; ===========================================================================
+
                cmpi.w  #$2200,(Boss_X_pos).w
                blt.s   Obj57_Main_Sub6_Standard
                move.w  #$2200,(Boss_X_pos).w
                bra.s   Obj57_Main_Sub6_ReAscend2
; ===========================================================================
; loc_31298:
Obj57_Main_Sub6_ReAscend1:                              ; that's a dumb name for a label
                lea     (Boss_AnimationArray).w,a1
                move.b  #$30,7(a1)                      ; face grin after hurting Sonic
; loc_312A2:
Obj57_Main_Sub6_ReAscend2:                              ; set to routine 0 and make boss move up again
                move.w  #0,(Boss_X_vel).w
                move.b  #0,boss_routine(a0)
                lea     (Boss_AnimationArray).w,a1
                andi.b  #$F0,2(a1)
                ori.b   #$B,2(a1)                       ; (B) prepare for digger rotation to diag/vert
                andi.b  #$F0,8(a1)
                ori.b   #$B,8(a1)                       ; (B) prepare for digger rotation to diag/vert
                move.b  #0,1(a1)                        ; hover thingies fire on
                andi.b  #$F0,6(a1)
                ori.b   #$D,6(a1)                       ; (D) Robotnik face normal
                move.w  #$64,(Boss_Countdown).w
                move.w  #-$C0,(Boss_Y_vel).w            ; move up

Obj57_Main_Sub6_Standard:
                move.w  (Boss_Y_pos).w,y_pos(a0)
                move.w  (Boss_X_pos).w,x_pos(a0)
                bsr.w   Obj57_HandleHits
                lea     (Ani_obj57).l,a1
                bsr.w   AnimateBoss
                bsr.w   Obj57_TransferPositions
                jmpto   JmpTo38_DisplaySprite
; ===========================================================================
; loc_3130A:
Obj57_TransferPositions:
                move.w  x_pos(a0),d0
                move.w  y_pos(a0),d1
                move.w  d0,sub3_x_pos(a0)
                move.w  d1,sub3_y_pos(a0)
                move.w  d0,sub4_x_pos(a0)
                move.w  d1,sub4_y_pos(a0)
                tst.b   boss_defeated(a0)
                bne.s   Obj57_FallApart                 ; if boss defeated
                move.w  d0,sub5_x_pos(a0)
                move.w  d1,sub5_y_pos(a0)
                move.w  d0,sub2_x_pos(a0)
                move.w  d1,sub2_y_pos(a0)
                move.w  d1,obj57_sub5_y_pos2(a0)
                move.w  d1,obj57_sub2_y_pos2(a0)
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                addi.w  #$28,sub5_x_pos(a0)
                rts
; ===========================================================================
+
                subi.w  #$28,sub5_x_pos(a0)
                rts
; ===========================================================================
; loc_31358:
Obj57_FallApart:                                        ; make the digger thingies fall down
                cmpi.w  #$78,(Boss_Countdown).w
                bgt.s   MczBoss_Return
                subi_.w #1,sub5_x_pos(a0)
                move.l  obj57_sub5_y_pos2(a0),d0
                move.w  obj57_sub5_y_vel(a0),d1
                addi.w  #$38,obj57_sub5_y_vel(a0)
                ext.l   d1
                asl.l   #8,d1
                add.l   d1,d0
                move.l  d0,obj57_sub5_y_pos2(a0)
                move.w  obj57_sub5_y_pos2(a0),sub5_y_pos(a0)
                cmpi.w  #$6F0,sub5_y_pos(a0)
                blt.s   +
                move.w  #0,obj57_sub5_y_vel(a0)
+                                                       ; second one
                addi_.w #1,sub2_x_pos(a0)
                move.l  obj57_sub2_y_pos2(a0),d0
                move.w  obj57_sub2_y_vel(a0),d1
                addi.w  #$38,obj57_sub2_y_vel(a0)
                ext.l   d1
                asl.l   #8,d1
                add.l   d1,d0
                move.l  d0,obj57_sub2_y_pos2(a0)
                move.w  obj57_sub2_y_pos2(a0),sub2_y_pos(a0)
                cmpi.w  #$6F0,sub2_y_pos(a0)
                blt.s   MczBoss_Return
                move.w  #0,obj57_sub2_y_vel(a0)

MczBoss_Return:
                rts
; ===========================================================================
; loc_313C6:
Obj57_SpawnStoneSpike:                                  ; decide whether stone or spike
                move.b  (Vint_runcount+3).w,d1          ; not so random number?
                sf      d2
                andi.b  #$1F,d1
                beq.s   Obj57_LoadStoneSpike
                andi.b  #7,d1
                bne.s   MczBoss_Return_Variant2
                st.b    d2
; loc_313DA:
Obj57_LoadStoneSpike:
                jsrto   JmpTo4_RandomNumber
                swap    d1
                andi.w  #$1FF,d1
                addi.w  #$20F0,d1
                cmpi.w  #$2230,d1
                bgt.s   Obj57_LoadStoneSpike
                jsrto   JmpTo15_AllocateObject
                bne.s   MczBoss_Return_Variant2
                move.b  #ObjID_MCZBoss,id(a1)           ; load obj57
                move.b  #4,boss_subtype(a1)
                move.w  d1,x_pos(a1)
                move.w  #$5F0,y_pos(a1)
                move.l  #Obj57_MapUnc_316EC,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtUnc_FallingRocks,0,0),art_tile(a1)
                ori.b   #1<<render_flags.level_fg,render_flags(a1)
                move.b  #3,priority(a1)
                move.b  #$D,mapping_frame(a1)
                tst.b   d2
                bne.s   MczBoss_Return_Variant2         ; stone
                move.b  #$14,mapping_frame(a1)          ; spike
                move.b  #$B1,collision_flags(a1)

MczBoss_Return_Variant2:
                rts
; ===========================================================================
; loc_3143A:
Obj57_HandleHits:
                bsr.w   Obj57_HandleHits_Main
                cmpi.b  #$1F,boss_invulnerable_time(a0)
                bne.s   +                               ; rts
                lea     (Boss_AnimationArray).w,a1
                move.b  #$C0,7(a1)                      ; face grin when hit
+
                rts
; ===========================================================================
; loc_31452:
Obj57_AddSinusOffset:                                   ; called from routine $A and $C
                move.b  boss_sine_count(a0),d0          ; sinus offset something
                jsr     (CalcSine).l
                asr.w   #6,d0
                add.w   (Boss_Y_pos).w,d0
                move.w  d0,y_pos(a0)
                move.w  (Boss_X_pos).w,x_pos(a0)
                addq.b  #2,boss_sine_count(a0)          ; increment frame counter for sinus offset
; loc_31470:
Obj57_HandleHits_Main:
                cmpi.b  #8,boss_routine(a0)
                bhs.s   MczBoss_Return_Variant3         ; skip if boss already defeated
                tst.b   boss_hitcount2(a0)
                beq.s   Obj57_FinalDefeat
                tst.b   collision_flags(a0)
                bne.s   MczBoss_Return_Variant3
                tst.b   boss_invulnerable_time(a0)
                bne.s   +
                move.b  #$20,boss_invulnerable_time(a0)  ; set invincibility timer
                move.w  #SndID_BossHit,d0
                jsr     (PlaySound).l
+
                lea     (Normal_palette_line2+2).w,a1
                moveq   #0,d0
                tst.w   (a1)
                bne.s   +
                move.w  #$EEE,d0
+
                move.w  d0,(a1)
                subq.b  #1,boss_invulnerable_time(a0)
                bne.s   MczBoss_Return_Variant3
                move.b  #$F,collision_flags(a0)

MczBoss_Return_Variant3:
                rts
; ===========================================================================
; loc_314B8:
Obj57_FinalDefeat:
                moveq   #100,d0
                jsrto   JmpTo6_AddPoints
                move.w  #$B3,(Boss_Countdown).w
                move.b  #8,boss_routine(a0)             ; routine boss defeated
                moveq   #PLCID_Capsule,d0
                jsrto   JmpTo9_LoadPLC
                rts
; ===========================================================================
; loc_314D2:
Obj57_Main_Sub8:                                        ; boss defeated, standing still, exploding
                st.b    boss_defeated(a0)
                move.b  #0,(Screen_Shaking_Flag).w
                subq.w  #1,(Boss_Countdown).w           ; countdown initially $B3
                bmi.s   +                               ; branch if countdown finished
                move.b  #$13,sub4_mapframe(a0)          ; burnt face
                move.b  #7,mainspr_mapframe(a0)
                bsr.w   Boss_LoadExplosion
                bra.s   Obj57_Main_Sub8_Standard
; ===========================================================================
+
                bset    #render_flags.x_flip,render_flags(a0)
                clr.w   (Boss_X_vel).w
                clr.w   (Boss_Y_vel).w
                addq.b  #2,boss_routine(a0)             ; next routine
                move.b  #$12,sub4_mapframe(a0)          ; face grin when hit
                move.w  #-$12,(Boss_Countdown).w

Obj57_Main_Sub8_Standard:
                move.w  (Boss_Y_pos).w,y_pos(a0)
                move.w  (Boss_X_pos).w,x_pos(a0)
                bsr.w   Obj57_TransferPositions
                jmpto   JmpTo38_DisplaySprite
; ===========================================================================
; loc_31526:
Obj57_Main_SubA:                                        ; slowly hovering down, no explosions
                addq.w  #1,(Boss_Countdown).w           ; countdown initially -$12
                beq.s   ++                              ; reset y_vel
                bpl.s   +++
                cmpi.w  #$620,(Boss_Y_pos).w
                bhs.s   +
                subq.w  #1,(Boss_Countdown).w
+
                addi.w  #$10,(Boss_Y_vel).w             ; add gravity
                bra.s   Obj57_Main_SubA_Standard
; ===========================================================================
+
                clr.w   (Boss_Y_vel).w
                bra.s   Obj57_Main_SubA_Standard
; ===========================================================================
+
                cmpi.w  #$18,(Boss_Countdown).w
                blo.s   +                               ; accelerate boss upwards
                beq.s   ++                              ; reset y_vel, PlayLevelMusic
                cmpi.w  #$20,(Boss_Countdown).w
                blo.s   Obj57_Main_SubA_Standard
                lea     (Boss_AnimationArray).w,a1
                move.b  #$D,7(a1)                       ; face grin when hit
; This should be 'a1' instead of 'a2'. A random part of RAM gets
; written to instead
                _move.b #2,0(a2)
                move.b  #0,1(a1)                        ; hover thingies fire off
                addq.b  #2,boss_routine(a0)
                bra.s   Obj57_Main_SubA_Standard
; ===========================================================================
+
                subi_.w #8,(Boss_Y_vel).w
                bra.s   Obj57_Main_SubA_Standard
; ===========================================================================
+
                clr.w   (Boss_Y_vel).w
                jsrto   JmpTo5_PlayLevelMusic
                jsrto   JmpTo5_LoadPLC_AnimalExplosion
; loc_3158A:
Obj57_Main_SubA_Standard:
                bsr.w   Boss_MoveObject
                bsr.w   Obj57_AddSinusOffset
                move.w  (Boss_Y_pos).w,y_pos(a0)
                move.w  (Boss_X_pos).w,x_pos(a0)
                bsr.w   Obj57_TransferPositions
                jmpto   JmpTo38_DisplaySprite
; ===========================================================================
; loc_315A6:
Obj57_Main_SubC:                                        ; moving away fast
                move.w  #$400,(Boss_X_vel).w
                move.w  #-$40,(Boss_Y_vel).w            ; escape to the right
                cmpi.w  #$2240,(Camera_Max_X_pos).w
                beq.s   +
                addq.w  #2,(Camera_Max_X_pos).w
                bra.s   Obj57_Main_SubC_Standard
; ===========================================================================
+
                _btst   #render_flags.on_screen,render_flags(a0)
                _beq.s  JmpTo56_DeleteObject            ; if off screen
; loc_315C6:
Obj57_Main_SubC_Standard:
                bsr.w   Boss_MoveObject
                bsr.w   Obj57_AddSinusOffset
                move.w  (Boss_Y_pos).w,y_pos(a0)
                move.w  (Boss_X_pos).w,x_pos(a0)
                lea     (Ani_obj57).l,a1
                bsr.w   AnimateBoss
                bsr.w   Obj57_TransferPositions
                jmpto   JmpTo38_DisplaySprite
; ===========================================================================

JmpTo56_DeleteObject                                    ; JmpTo
                jmp     (DeleteObject).l
; ===========================================================================
; loc_315F2:
Obj57_FallingStuff:                                     ; Spikes & Stones
                jsrto   JmpTo5_ObjectMoveAndFall
                subi.w  #$28,sub2_y_pos(a0)             ; decrease gravity
                cmpi.w  #$6F0,y_pos(a0)                 ; if below boundary, delete
                bgt.w   JmpTo57_DeleteObject
                jmpto   JmpTo38_DisplaySprite

; ===========================================================================
; off_3160A: Obj57_AnimIndex:
Ani_obj57:      offsetTable
                offsetTableEntry.w MczBoss_Animation_Sequence0  ; 0 - main vehicle
                offsetTableEntry.w MczBoss_Animation_Sequence1  ; 1 - digger diagonal
                offsetTableEntry.w MczBoss_Animation_Sequence2  ; 2 - hover fire thingies to keep boss in air
                offsetTableEntry.w MczBoss_Animation_Sequence3  ; 3 - digger vertical animated 1 -> (4)
                offsetTableEntry.w MczBoss_Animation_Sequence4  ; 4 - digger vertical animated 2 -> (5)
                offsetTableEntry.w MczBoss_Animation_Sequence5  ; 5 - digger vertical animated 3 (loop)
                offsetTableEntry.w MczBoss_Animation_Sequence6  ; 6 - digger vertical animated 4 -> (7)
                offsetTableEntry.w MczBoss_Animation_Sequence7  ; 7 - digger vertical + diagonal transition -> (8)
                offsetTableEntry.w MczBoss_Animation_Sequence8  ; 8 - digger horizontal animated 1 -> (9)
                offsetTableEntry.w MczBoss_Animation_Sequence9  ; 9 - digger horizontal animated 2 -> (A)
                offsetTableEntry.w MczBoss_Animation_Sequence10  ; A - digger horizontal animated 3 (loop)
                offsetTableEntry.w MczBoss_Animation_Sequence11  ; B - digger horizontal animated 4 -> (C)
                offsetTableEntry.w MczBoss_Animation_Sequence12  ; C - digger horizontal + diagonal transition -> (3)
                offsetTableEntry.w MczBoss_Animation_Sequence13  ; D - center vehicle, Robotnik's face normal
                offsetTableEntry.w MczBoss_Animation_Sequence14  ; E - center vehicle, Robotnik's face when hit
MczBoss_Animation_Sequence0:    dc.b    $F,  1,$FF      ; light off
                dc.b    0,$FC,  2                       ; light on; (3) subanimation
MczBoss_Animation_Sequence1:    dc.b    5,  8,$FF
MczBoss_Animation_Sequence2:    dc.b    1,  5,  6,$FF   ; fire on
                dc.b    7,$FC,  3                       ; fire off; (4) subanimation
MczBoss_Animation_Sequence3:    dc.b    1,  2,  2,  2,  2,  2,  3,  3,  3,  3,  3,  4,  4,  4,  4,$FD,  4
MczBoss_Animation_Sequence4:    dc.b    1,  2,  2,  2,  2,  3,  3,  3,  4,  4,  4,  2,  2,  3,  3,$FD,  5
MczBoss_Animation_Sequence5:    dc.b    1,  4,  2,  3,  4,$FC,  1
MczBoss_Animation_Sequence6:    dc.b    1,  2,  3,  4,  4,  2,  2,  3,  3,  3,  4,  4,  4,  2,  2,  2,$FD,  7
MczBoss_Animation_Sequence7:    dc.b    1,  2,  3,  3,  3,  3,  4,  4,  4,  4,  4,  2,  8,  8,  8,$FD,  8
MczBoss_Animation_Sequence8:    dc.b    1,  9,  9,  9,  9,  9, $A, $A, $A, $A, $A, $B, $B, $B, $B,$FD,  9
MczBoss_Animation_Sequence9:    dc.b    1,  9,  9,  9,  9, $A, $A, $A, $B, $B, $B,  9,  9, $A, $A,$FD, $A
MczBoss_Animation_Sequence10:   dc.b    1, $B,  9, $A, $B,$FC,  1
MczBoss_Animation_Sequence11:   dc.b    1,  9, $A, $B, $B,  9,  9, $A, $A, $A, $B, $B, $B,  9,  9,  9,$FD, $C
MczBoss_Animation_Sequence12:   dc.b    1,  9, $A, $A, $A, $A, $B, $B, $B, $B, $B,  9,  8,  8,  8,  8,$FD,  3
MczBoss_Animation_Sequence13:   dc.b    7, $E, $F,$FF
                dc.b    $10,$11,$10,$11,$10,$11,$10,$11,$FF  ; (4) subanimation (grin after hurting Sonic)
                dc.b    $12,$12,$12,$12,$12,$12,$12,$12,$12,$FF  ; (D) subanimation (grin when hit)
MczBoss_Animation_Sequence14:   dc.b    7,$12,$FF
                even
; ----------------------------------------------------------------------------
; sprite mappings
; ----------------------------------------------------------------------------
Obj57_MapUnc_316EC:
Map_obj57:      mappingsTable
                mappingsTableEntry.w Map_obj57_002A
                mappingsTableEntry.w Map_obj57_0054
                mappingsTableEntry.w Map_obj57_007E
                mappingsTableEntry.w Map_obj57_0090
                mappingsTableEntry.w Map_obj57_00A2
                mappingsTableEntry.w Map_obj57_00B4
                mappingsTableEntry.w Map_obj57_00C6
                mappingsTableEntry.w Map_obj57_00D8
                mappingsTableEntry.w Map_obj57_00E2
                mappingsTableEntry.w Map_obj57_010C
                mappingsTableEntry.w Map_obj57_011E
                mappingsTableEntry.w Map_obj57_0130
                mappingsTableEntry.w Map_obj57_0142
                mappingsTableEntry.w Map_obj57_014C
                mappingsTableEntry.w Map_obj57_0156
                mappingsTableEntry.w Map_obj57_0168
                mappingsTableEntry.w Map_obj57_017A
                mappingsTableEntry.w Map_obj57_018C
                mappingsTableEntry.w Map_obj57_019E
                mappingsTableEntry.w Map_obj57_01B0
                mappingsTableEntry.w Map_obj57_01C2

Map_obj57_002A: spriteHeader
                spritePiece -$10, -8, 4, 4, $148, 0, 0, 1, 0
                spritePiece $10, -8, 2, 4, $158, 0, 0, 1, 0
                spritePiece $10, -$18, 2, 2, $164, 0, 0, 0, 0
                spritePiece -$28, -8, 3, 3, 9, 0, 0, 1, 0
                spritePiece -8, -$28, 3, 2, $21, 0, 0, 0, 0
Map_obj57_002A_End

Map_obj57_0054: spriteHeader
                spritePiece -$10, -8, 4, 4, $148, 0, 0, 1, 0
                spritePiece $10, -8, 2, 4, $158, 0, 0, 1, 0
                spritePiece $10, -$18, 2, 2, $164, 0, 0, 0, 0
                spritePiece -$28, -8, 3, 3, 0, 0, 0, 1, 0
                spritePiece -8, -$28, 3, 2, $21, 0, 0, 0, 0
Map_obj57_0054_End

Map_obj57_007E: spriteHeader
                spritePiece $C, -$30, 2, 4, $27, 0, 0, 1, 0
                spritePiece 8, -$10, 3, 4, $3F, 0, 0, 1, 0
Map_obj57_007E_End

Map_obj57_0090: spriteHeader
                spritePiece $C, -$30, 2, 4, $2F, 0, 0, 1, 0
                spritePiece 8, -$10, 3, 4, $4B, 0, 0, 1, 0
Map_obj57_0090_End

Map_obj57_00A2: spriteHeader
                spritePiece $C, -$30, 2, 4, $37, 0, 0, 1, 0
                spritePiece 8, -$10, 3, 4, $57, 0, 0, 1, 0
Map_obj57_00A2_End

Map_obj57_00B4: spriteHeader
                spritePiece -8, $12, 3, 1, $12, 0, 0, 0, 0
                spritePiece -8, $1A, 3, 1, $15, 0, 0, 0, 0
Map_obj57_00B4_End

Map_obj57_00C6: spriteHeader
                spritePiece -8, $12, 3, 1, $12, 0, 0, 0, 0
                spritePiece -8, $1A, 3, 3, $18, 0, 0, 0, 0
Map_obj57_00C6_End

Map_obj57_00D8: spriteHeader
                spritePiece -8, $12, 3, 1, $12, 0, 0, 0, 0
Map_obj57_00D8_End

Map_obj57_00E2: spriteHeader
                spritePiece -8, -$20, 3, 2, $63, 0, 0, 1, 0
                spritePiece 0, -$10, 1, 2, $69, 0, 0, 1, 0
                spritePiece 8, -$10, 4, 4, $6B, 0, 0, 1, 0
                spritePiece $28, -8, 1, 3, $7B, 0, 0, 1, 0
                spritePiece $18, $10, 2, 1, $7E, 0, 0, 1, 0
Map_obj57_00E2_End

Map_obj57_010C: spriteHeader
                spritePiece -$10, -4, 4, 2, $80, 0, 0, 1, 0
                spritePiece $10, -8, 4, 3, $98, 0, 0, 1, 0
Map_obj57_010C_End

Map_obj57_011E: spriteHeader
                spritePiece -$10, -4, 4, 2, $88, 0, 0, 1, 0
                spritePiece $10, -8, 4, 3, $A4, 0, 0, 1, 0
Map_obj57_011E_End

Map_obj57_0130: spriteHeader
                spritePiece -$10, -4, 4, 2, $90, 0, 0, 1, 0
                spritePiece $10, -8, 4, 3, $B0, 0, 0, 1, 0
Map_obj57_0130_End

Map_obj57_0142: spriteHeader
                spritePiece -$10, -$10, 4, 4, $BC, 0, 0, 2, 0
Map_obj57_0142_End

Map_obj57_014C: spriteHeader
                spritePiece -8, -8, 2, 2, 0, 0, 0, 2, 0
Map_obj57_014C_End

Map_obj57_0156: spriteHeader
                spritePiece -$10, -$18, 4, 2, $170, 0, 0, 0, 0
                spritePiece -$20, -$18, 2, 2, $168, 0, 0, 0, 0
Map_obj57_0156_End

Map_obj57_0168: spriteHeader
                spritePiece -$10, -$18, 4, 2, $178, 0, 0, 0, 0
                spritePiece -$20, -$18, 2, 2, $168, 0, 0, 0, 0
Map_obj57_0168_End

Map_obj57_017A: spriteHeader
                spritePiece -$10, -$18, 4, 2, $180, 0, 0, 0, 0
                spritePiece -$20, -$18, 2, 2, $16C, 0, 0, 0, 0
Map_obj57_017A_End

Map_obj57_018C: spriteHeader
                spritePiece -$10, -$18, 4, 2, $188, 0, 0, 0, 0
                spritePiece -$20, -$18, 2, 2, $16C, 0, 0, 0, 0
Map_obj57_018C_End

Map_obj57_019E: spriteHeader
                spritePiece -$10, -$18, 4, 2, $190, 0, 0, 0, 0
                spritePiece -$20, -$18, 2, 2, $16C, 0, 0, 0, 0
Map_obj57_019E_End

Map_obj57_01B0: spriteHeader
                spritePiece -$10, -$18, 4, 2, $198, 0, 0, 0, 0
                spritePiece -$20, -$18, 2, 2, $16C, 0, 0, 0, 0
Map_obj57_01B0_End

Map_obj57_01C2: spriteHeader
                spritePiece -4, -$10, 1, 4, 4, 0, 0, 2, 0
Map_obj57_01C2_End

                even
; ===========================================================================

                jmpTos  JmpTo38_DisplaySprite,JmpTo57_DeleteObject,JmpTo15_AllocateObject,JmpTo4_RandomNumber,JmpTo9_LoadPLC,JmpTo6_AddPoints,JmpTo5_PlayLevelMusic,JmpTo5_LoadPLC_AnimalExplosion,JmpTo5_ObjectMoveAndFall

; ===========================================================================
; ----------------------------------------------------------------------------
; Object 51 - CNZ boss
; ----------------------------------------------------------------------------
; Sprite_318F0:
