ObjC7:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  ObjC7_Index(pc,d0.w),d1
                jmp     ObjC7_Index(pc,d1.w)
; ===========================================================================
; off_3D4D6:
ObjC7_Index:    offsetTable
                offsetTableEntry.w ObjC7_Init           ; 0
                offsetTableEntry.w ObjC7_Body           ; 2
                offsetTableEntry.w ObjC7_Shoulder       ; 4
                offsetTableEntry.w ObjC7_FrontLowerLeg  ; 6
                offsetTableEntry.w ObjC7_FrontForearm   ; 8
                offsetTableEntry.w ObjC7_Arm            ; $A
                offsetTableEntry.w ObjC7_FrontThigh     ; $C
                offsetTableEntry.w ObjC7_Head           ; $E
                offsetTableEntry.w ObjC7_Jet            ; $10
                offsetTableEntry.w ObjC7_BackLowerLeg   ; $12
                offsetTableEntry.w ObjC7_BackForearm    ; $14
                offsetTableEntry.w ObjC7_BackThigh      ; $16
                offsetTableEntry.w ObjC7_TargettingSensor  ; $18
                offsetTableEntry.w ObjC7_TargettingLock  ; $1A
                offsetTableEntry.w ObjC7_EggmanBomb     ; $1C
                offsetTableEntry.w ObjC7_FallingPieces  ; $1E
                offsetTableEntry.w ObjC7_SetupEnding    ; $20
; ===========================================================================
; loc_3D4F8:
ObjC7_Init:
                lea     ObjC7_SubObjData(pc),a1
                bsr.w   LoadSubObject_Part3
                move.b  subtype(a0),routine(a0)
                rts
; ===========================================================================
; loc_3D508
ObjC7_Body:
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3D51A(pc,d0.w),d1
                jsr     off_3D51A(pc,d1.w)
                jmpto   JmpTo45_DisplaySprite
; ===========================================================================
off_3D51A:      offsetTable
                offsetTableEntry.w loc_3D52A            ; 0
                offsetTableEntry.w loc_3D5A8            ; 2
                offsetTableEntry.w loc_3D5C2            ; 4
                offsetTableEntry.w loc_3D5EA            ; 6
                offsetTableEntry.w loc_3D62E            ; 8
                offsetTableEntry.w loc_3D640            ; $A
                offsetTableEntry.w loc_3D684            ; $C
                offsetTableEntry.w loc_3D8D2            ; $E
; ===========================================================================

loc_3D52A:
                addq.b  #2,routine_secondary(a0)
                move.b  #3,mapping_frame(a0)
                move.b  #5,priority(a0)
                lea     (ChildObjC7_Shoulder).l,a2
                bsr.w   LoadChildObject
                lea     (ChildObjC7_FrontForearm).l,a2
                bsr.w   LoadChildObject
                lea     (ChildObjC7_FrontLowerLeg).l,a2
                bsr.w   LoadChildObject
                lea     (ChildObjC7_Arm).l,a2
                bsr.w   LoadChildObject
                lea     (ChildObjC7_FrontThigh).l,a2
                bsr.w   LoadChildObject
                lea     (ChildObjC7_Head).l,a2
                bsr.w   LoadChildObject
                lea     (ChildObjC7_Jet).l,a2
                bsr.w   LoadChildObject
                lea     (ChildObjC7_BackLowerLeg).l,a2
                bsr.w   LoadChildObject
                lea     (ChildObjC7_BackForearm).l,a2
                bsr.w   LoadChildObject
                lea     (ChildObjC7_BackThigh).l,a2
                bsr.w   LoadChildObject
                lea     (ObjC7_ChildDeltas).l,a1
                bra.w   ObjC7_PositionChildren
; ===========================================================================

loc_3D5A8:
                btst    #status.npc.misc,status(a0)
                bne.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,routine_secondary(a0)
                move.b  #60,anim_frame_duration(a0)
                moveq   #signextendB(MusID_FadeOut),d0
                jmpto   JmpTo12_PlaySound
; ===========================================================================

loc_3D5C2:
                subq.b  #1,anim_frame_duration(a0)
                bmi.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,routine_secondary(a0)
                move.b  #$79,anim_frame_duration(a0)
                move.w  #-$100,y_vel(a0)
                movea.w objoff_38(a0),a1                ; a1=object
                move.b  #4,routine_secondary(a1)
                moveq   #signextendB(MusID_EndBoss),d0
                jmpto   JmpTo5_PlayMusic
; ===========================================================================

loc_3D5EA:
                subq.b  #1,anim_frame_duration(a0)
                beq.s   +
                moveq   #signextendB(SndID_Rumbling),d0
                jsrto   JmpTo12_PlaySound
                jsrto   JmpTo26_ObjectMove
                lea     (ObjC7_ChildDeltas).l,a1
                bra.w   ObjC7_PositionChildren
; ---------------------------------------------------------------------------
+
                addq.b  #2,routine_secondary(a0)
                clr.w   y_vel(a0)
                move.b  #$1F,anim_frame_duration(a0)
                move.b  #$16,collision_flags(a0)
                move.b  #$C,collision_property(a0)
                bsr.w   ObjC7_InitCollision
                movea.w objoff_38(a0),a1                ; a1=object
                move.b  #6,routine_secondary(a1)
                rts
; ===========================================================================

loc_3D62E:
                bsr.w   ObjC7_CheckHit
                subq.b  #1,anim_frame_duration(a0)
                bmi.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,routine_secondary(a0)
                rts
; ===========================================================================

loc_3D640:
                bsr.w   ObjC7_CheckHit
                addq.b  #2,routine_secondary(a0)
                move.b  #$20,anim_frame_duration(a0)
                move.b  angle(a0),d0
                addq.b  #1,d0
                move.b  d0,angle(a0)
                andi.w  #3,d0
                move.b  byte_3D680(pc,d0.w),d0
                move.b  d0,anim(a0)
                clr.b   prev_anim(a0)
                cmpi.b  #2,d0
                bne.s   +                               ; rts
                movea.w objoff_38(a0),a1                ; a1=object
                move.b  #4,routine_secondary(a1)
                move.b  #2,anim(a1)
+
                rts
; ===========================================================================
byte_3D680:
                dc.b    2
                dc.b    0                               ; 1
                dc.b    2                               ; 2
                dc.b    4                               ; 3
                even
; ===========================================================================

loc_3D684:
                bsr.w   ObjC7_CheckHit
                moveq   #0,d0
                move.b  anim(a0),d0
                move.w  off_3D696(pc,d0.w),d1
                jmp     off_3D696(pc,d1.w)
; ===========================================================================
off_3D696:      offsetTable
                offsetTableEntry.w loc_3D6AA            ; 0
                offsetTableEntry.w loc_3D702            ; 2
                offsetTableEntry.w loc_3D83C            ; 4
; ===========================================================================
                subq.b  #1,anim_frame_duration(a0)
                bmi.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,anim(a0)
                rts
; ===========================================================================

loc_3D6AA:
                moveq   #0,d0
                move.b  prev_anim(a0),d0
                move.w  off_3D6B8(pc,d0.w),d1
                jmp     off_3D6B8(pc,d1.w)
; ===========================================================================
off_3D6B8:      offsetTable
                offsetTableEntry.w loc_3D6C0            ; 0
                offsetTableEntry.w loc_3D6CE            ; 2
                offsetTableEntry.w loc_3D6C0            ; 4
                offsetTableEntry.w loc_3D6E8            ; 6
; ===========================================================================

loc_3D6C0:
                subq.b  #1,anim_frame_duration(a0)
                bmi.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,prev_anim(a0)
                rts
; ===========================================================================

loc_3D6CE:
                lea     (DeathEggRobot_LimbMotionProgram5).l,a1
                bsr.w   DeathEggRobot_AdvanceLimbMotion
                bne.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,prev_anim(a0)
                move.b  #$40,anim_frame_duration(a0)
                rts
; ===========================================================================

loc_3D6E8:
                lea     (DeathEggRobot_LimbMotionProgram6).l,a1
                bsr.w   DeathEggRobot_AdvanceLimbMotion
                bne.s   +
                rts
; ---------------------------------------------------------------------------
+
                subq.b  #2,routine_secondary(a0)
                move.b  #$40,anim_frame_duration(a0)
                rts
; ===========================================================================

loc_3D702:
                moveq   #0,d0
                move.b  prev_anim(a0),d0
                move.w  off_3D710(pc,d0.w),d1
                jmp     off_3D710(pc,d1.w)
; ===========================================================================
off_3D710:      offsetTable
                offsetTableEntry.w loc_3D6C0            ; 0
                offsetTableEntry.w loc_3D720            ; 2
                offsetTableEntry.w loc_3D744            ; 4
                offsetTableEntry.w loc_3D6C0            ; 6
                offsetTableEntry.w loc_3D784            ; 8
                offsetTableEntry.w loc_3D7B8            ; $A
                offsetTableEntry.w loc_3D7F0            ; $C
                offsetTableEntry.w loc_3D82E            ; $C
; ===========================================================================

loc_3D720:
                lea     (DeathEggRobot_LimbMotionProgram4).l,a1
                bsr.w   DeathEggRobot_AdvanceLimbMotion
                bne.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,prev_anim(a0)
                move.b  #$80,anim_frame_duration(a0)
                clr.w   x_vel(a0)
                move.w  #-$200,y_vel(a0)
                rts
; ===========================================================================

loc_3D744:
                subq.b  #1,anim_frame_duration(a0)
                bmi.s   ++
                move.b  (Vint_runcount+3).w,d0
                andi.b  #$1F,d0
                bne.s   +
                moveq   #signextendB(SndID_Fire),d0
                jsrto   JmpTo_PlaySoundLocal
+
                jsrto   JmpTo26_ObjectMove
                lea     (ObjC7_ChildDeltas).l,a1
                bra.w   ObjC7_PositionChildren
; ---------------------------------------------------------------------------
+
                addq.b  #2,prev_anim(a0)
                clr.w   y_vel(a0)
                lea     (ChildObjC7_TargettingSensor).l,a2
                bsr.w   LoadChildObject
                clr.w   x_vel(a0)
                clr.w   objoff_28(a0)
                rts
; ===========================================================================

loc_3D784:
                move.w  objoff_28(a0),d0
                bne.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,prev_anim(a0)
                move.w  d0,x_pos(a0)
                bclr    #render_flags.x_flip,render_flags(a0)
                cmpi.w  #$780,d0
                bhs.s   +
                bset    #render_flags.x_flip,render_flags(a0)
+
                bsr.w   DeathEggRobot_SyncChildFacing
                move.w  #$800,y_vel(a0)
                move.b  #$20,anim_frame_duration(a0)
                rts
; ===========================================================================

loc_3D7B8:
                subq.b  #1,anim_frame_duration(a0)
                bmi.s   +
                jsrto   JmpTo26_ObjectMove
                lea     (ObjC7_ChildDeltas).l,a1
                bra.w   ObjC7_PositionChildren
; ---------------------------------------------------------------------------
+
                addq.b  #2,prev_anim(a0)
                clr.w   y_vel(a0)
                move.b  #1,(Screen_Shaking_Flag).w
                move.w  #$40,(DEZ_Shake_Timer).w
                movea.w objoff_38(a0),a1                ; a1=object
                move.b  #6,routine_secondary(a1)
                moveq   #signextendB(SndID_Smash),d0
                jmpto   JmpTo12_PlaySound
; ===========================================================================

loc_3D7F0:
                lea     (DeathEggRobot_LimbMotionProgram3).l,a1
                bsr.w   DeathEggRobot_AdvanceLimbMotion
                bne.s   +
                rts
; ---------------------------------------------------------------------------
+
                lea     (ObjC7_ChildDeltas).l,a1
                bsr.w   ObjC7_PositionChildren
                bsr.w   Obj_GetOrientationToPlayer
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                subq.w  #2,d0
+
                tst.w   d0
                bne.s   +
                subq.b  #2,routine_secondary(a0)
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,prev_anim(a0)
                move.b  #$60,anim_frame_duration(a0)
                bra.w   CreateEggmanBombs
; ===========================================================================

loc_3D82E:
                subq.b  #1,anim_frame_duration(a0)
                bmi.s   +
                rts
; ---------------------------------------------------------------------------
+
                subq.b  #2,routine_secondary(a0)
                rts
; ===========================================================================

loc_3D83C:
                moveq   #0,d0
                move.b  prev_anim(a0),d0
                move.w  off_3D84A(pc,d0.w),d1
                jmp     off_3D84A(pc,d1.w)
; ===========================================================================
off_3D84A:      offsetTable
                offsetTableEntry.w loc_3D6C0            ; 0
                offsetTableEntry.w loc_3D856            ; 2
                offsetTableEntry.w loc_3D6C0            ; 4
                offsetTableEntry.w loc_3D89E            ; 6
                offsetTableEntry.w loc_3D6C0            ; 8
                offsetTableEntry.w loc_3D8B8            ; $A
; ===========================================================================

loc_3D856:
                bset    #status.npc.p2_pushing,status(a0)
                lea     (DeathEggRobot_LimbMotionProgram1).l,a1
                bsr.w   DeathEggRobot_AdvanceLimbMotion
                bne.s   +
                rts
; ---------------------------------------------------------------------------
+
                bsr.w   Obj_GetOrientationToPlayer
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                subq.w  #2,d0
+
                tst.w   d0
                bne.s   +
                addq.b  #2,prev_anim(a0)
                move.b  #$40,anim_frame_duration(a0)
                bset    #status.npc.p2_standing,status(a0)
                rts
; ---------------------------------------------------------------------------
+
                move.b  #8,prev_anim(a0)
                move.b  #$20,anim_frame_duration(a0)
                bra.w   CreateEggmanBombs
; ===========================================================================

loc_3D89E:
                subq.b  #1,anim_frame_duration(a0)
                bmi.s   +
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,prev_anim(a0)
                bset    #status.npc.p1_pushing,status(a0)
                move.b  #$40,anim_frame_duration(a0)
                rts
; ===========================================================================

loc_3D8B8:
                lea     (DeathEggRobot_LimbMotionProgram2).l,a1
                bsr.w   DeathEggRobot_AdvanceLimbMotion
                bne.s   +
                rts
; ---------------------------------------------------------------------------
+
                subq.b  #2,routine_secondary(a0)
                bclr    #status.npc.p2_pushing,status(a0)
                rts
; ===========================================================================

loc_3D8D2:
                moveq   #0,d0
                move.b  anim(a0),d0
                move.w  off_3D8E0(pc,d0.w),d1
                jmp     off_3D8E0(pc,d1.w)
; ===========================================================================
off_3D8E0:      offsetTable
                offsetTableEntry.w loc_3D8E6            ; 0
                offsetTableEntry.w loc_3D922            ; 2
                offsetTableEntry.w loc_3D93C            ; 4
; ===========================================================================

loc_3D8E6:
                jsrto   JmpTo_Boss_LoadExplosion
                jsrto   JmpTo8_ObjectMoveAndFall
                move.w  y_pos(a0),d0
                cmpi.w  #$15C,d0
                bhs.s   +
                rts
; ---------------------------------------------------------------------------
+
                move.w  #$15C,y_pos(a0)
                move.w  y_vel(a0),d0
                bmi.s   +
                lsr.w   #2,d0
                cmpi.w  #$100,d0
                blo.s   +
                neg.w   d0
                move.w  d0,y_vel(a0)
                rts
; ---------------------------------------------------------------------------
+
                addq.b  #2,anim(a0)
                move.b  #$40,anim_frame_duration(a0)
                rts
; ===========================================================================

loc_3D922:
                subq.b  #1,anim_frame_duration(a0)
                bmi.s   +
                jmpto   JmpTo_Boss_LoadExplosion
; ---------------------------------------------------------------------------
+
                addq.b  #2,anim(a0)
                st.b    (Control_Locked).w
                move.w  #$1000,(Camera_Max_X_pos).w
                rts
; ===========================================================================

loc_3D93C:
                move.w  #(button_right_mask<<8)|button_right_mask,(Ctrl_1_Logical).w
                cmpi.w  #$840,(Camera_X_pos).w
                bhs.s   +
                rts
; ---------------------------------------------------------------------------
+
                move.b  #$20,routine(a0)
                clr.b   routine_secondary(a0)
                move.w  #$20,objoff_2A(a0)
                move.b  #1,(Screen_Shaking_Flag).w
                move.w  #$1000,(DEZ_Shake_Timer).w
                movea.w objoff_36(a0),a1                ; a1=object
                jmpto   JmpTo6_DeleteObject2
; ===========================================================================
; loc_3D970
ObjC7_SetupEnding:
                move.b  (Vint_runcount+3).w,d0
                andi.b  #$1F,d0
                bne.s   +
; PlaySound ends up being clogged up by the explosion sounds, both in
; the queue and sound channels, meaning this is effectively useless
                moveq   #signextendB(SndID_Rumbling2),d0
                jsrto   JmpTo12_PlaySound
                subq.w  #1,objoff_2A(a0)
+
                lea     (MainCharacter).w,a1            ; a1=character
                move.w  x_pos(a1),d0
                sub.w   objoff_2A(a0),d0
                move.w  d0,x_pos(a0)
                move.w  y_pos(a1),y_pos(a0)
                bsr.w   DeathEggRobot_SpawnRandomExplosion
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  off_3D9AC(pc,d0.w),d1
                jmp     off_3D9AC(pc,d1.w)
; ===========================================================================
off_3D9AC:      offsetTable
                offsetTableEntry.w loc_3D9B0            ; 0
                offsetTableEntry.w loc_3D9D6            ; 2
; ===========================================================================

loc_3D9B0:
                lea     (MainCharacter).w,a1            ; a1=character
                cmpi.w  #$EC0,x_pos(a1)
                bhs.s   loc_3D9BE
                rts
; ===========================================================================

loc_3D9BE:
                addq.b  #2,routine_secondary(a0)
                move.w  #$3F,(Palette_fade_range).w
                move.b  #$16,anim_frame_duration(a0)
                move.w  #$7FFF,(PalCycle_Timer).w
                rts
; ===========================================================================

loc_3D9D6:
                subq.b  #1,anim_frame_duration(a0)
                beq.w   +
                movea.l a0,a1
                lea     (Normal_palette).w,a0

                moveq   #$3F,d0
-               jsrto   JmpTo_Pal_FadeToWhite.UpdateColour
                dbf     d0,-
                movea.l a1,a0
                rts
; ---------------------------------------------------------------------------
+
                move.l  #$EEE0EEE,d0
                lea     (Normal_palette).w,a1

                moveq   #$1F,d6
-               move.l  d0,(a1)+
                dbf     d6,-

                moveq   #signextendB(MusID_FadeOut),d0
; PlaySound ends up being clogged up by the explosion sounds,
; preventing the music from fading out as it should
                jsrto   JmpTo12_PlaySound
                move.b  #GameModeID_EndingSequence,(Game_Mode).w  ; => EndingSequence
                jmpto   JmpTo65_DeleteObject
; ===========================================================================
