ObjC7_InitCollision:
                lea     ObjC7_ChildOffsets(pc),a1
                lea     ObjC7_ChildCollision(pc),a2
                moveq   #0,d0

                moveq   #ObjC7_ChildCollision_End-ObjC7_ChildCollision-1,d6
-               move.b  (a1)+,d0
                movea.w (a0,d0.w),a3                    ; a3=object
                move.b  (a2)+,collision_flags(a3)
                dbf     d6,-

                rts
; ===========================================================================
; byte_3E10A
ObjC7_ChildCollision:
                dc.b    0
                dc.b    $8F                             ; 1
                dc.b    $9C                             ; 2
                dc.b    0                               ; 3
                dc.b    $86                             ; 4
                dc.b    $2A                             ; 5
                dc.b    $8B                             ; 6
                dc.b    $8F                             ; 7
                dc.b    $9C                             ; 8
                dc.b    $8B                             ; 9
ObjC7_ChildCollision_End
; byte_3E114
ObjC7_ChildOffsets:
                dc.b    objoff_2C
                dc.b    objoff_2E                       ; 1
                dc.b    objoff_30                       ; 2
                dc.b    objoff_32                       ; 3
                dc.b    objoff_34                       ; 4
                dc.b    objoff_36                       ; 5
                dc.b    objoff_38                       ; 6
                dc.b    objoff_3A                       ; 7
                dc.b    objoff_3C                       ; 8
                dc.b    objoff_3E                       ; 9
ObjC7_ChildOffsets_End
                even
; ===========================================================================
; loc_3E11E
ObjC7_RemoveCollision:
                lea     ObjC7_ChildOffsets(pc),a1
                moveq   #0,d0
                moveq   #ObjC7_ChildOffsets_End-ObjC7_ChildOffsets-1,d6

-               move.b  (a1)+,d0
                movea.w (a0,d0.w),a3                    ; a3=object
                clr.b   collision_flags(a3)
                dbf     d6,-
                rts
; ===========================================================================
; loc_3E136
CreateEggmanBombs:
                lea     EggmanBomb_InitSpeeds(pc),a3
                moveq   #1,d6

-               lea     (ChildObjC7_EggmanBomb).l,a2
                bsr.w   LoadChildObject
                move.w  (a3)+,d0
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                neg.w   d0
+
                move.w  d0,x_vel(a1)
                move.w  (a3)+,y_vel(a1)
                dbf     d6,-
                rts
; ===========================================================================
; word_3E160
EggmanBomb_InitSpeeds:
                dc.w    $60,-$800
                dc.w    $C0,-$A00
; ===========================================================================

DeathEggRobot_SyncChildFacing:
                move.b  render_flags(a0),d0
                andi.b  #1,d0
                moveq   #0,d1
                lea     byte_3E19E(pc),a1

-               move.b  (a1)+,d1
                beq.w   EnemiesTurtloid_Return_Variant3
                movea.w (a0,d1.w),a2                    ; a2=object
                move.b  render_flags(a2),d2
                andi.b  #$FE,d2
                or.b    d0,d2
                move.b  d2,render_flags(a2)
                move.b  status(a2),d2
                andi.b  #~(1<<status.npc.x_flip),d2
                or.b    d0,d2
                move.b  d2,status(a2)
                bra.s   -
; ===========================================================================
byte_3E19E:
                dc.b    objoff_2C, objoff_2E, objoff_30, objoff_32  ; 3
                dc.b    objoff_34, objoff_36, objoff_38, objoff_3A  ; 7
                dc.b    objoff_3C, objoff_3E, 0
                even
; ===========================================================================

DeathEggRobot_AdvanceLimbMotion:
                movea.l (a1)+,a2
                moveq   #0,d0
                move.b  anim_frame(a0),d0
                move.b  (a1,d0.w),d0
                move.b  d0,d1
                moveq   #0,d4
                andi.w  #$C0,d1
                beq.s   +
                bsr.w   DeathEggRobot_DispatchMotionFlags
+
                add.w   d0,d0
                adda.w  (a2,d0.w),a2
                move.b  (a2)+,d0
                move.b  (a2)+,d3
                move.b  objoff_1F(a0),d2
                addq.b  #1,d2
                cmp.b   d3,d2
                blo.s   +
                addq.b  #1,anim_frame(a0)
                moveq   #0,d2
+
                move.b  d2,objoff_1F(a0)
                moveq   #0,d5

-               move.b  (a2)+,d5
                movea.w (a0,d5.w),a3                    ; a3=object
                tst.w   d5
                bne.s   +
                movea.l a0,a3
+
                move.l  x_pos(a3),d2
                move.b  (a2)+,d1
                ext.w   d1
                asl.w   #4,d1
                btst    #render_flags.x_flip,render_flags(a0)
                beq.s   +
                neg.w   d1
+
                tst.w   d4
                beq.s   +
                neg.w   d1
+
                ext.l   d1
                asl.l   #8,d1
                add.l   d1,d2
                move.l  d2,x_pos(a3)
                move.l  y_pos(a3),d3
                move.b  (a2)+,d1
                ext.w   d1
                asl.w   #4,d1
                tst.w   d4
                beq.s   +
                neg.w   d1
+
                ext.l   d1
                asl.l   #8,d1
                add.l   d1,d3
                move.l  d3,y_pos(a3)
                dbf     d0,-

                moveq   #0,d1
                rts
; ===========================================================================

DeathEggRobot_ResetMotionFrame:
                clr.b   anim_frame(a0)
                moveq   #1,d1

DeathEggRobotBombCollision_Return:
                rts
; ===========================================================================

DeathEggRobot_DispatchMotionFlags:
                andi.b  #$3F,d0
                rol.b   #3,d1
                move.w  DeathEggRobot_MotionFlagHandlers-2(pc,d1.w),d1
                jmp     DeathEggRobot_MotionFlagHandlers(pc,d1.w)
; ===========================================================================
DeathEggRobot_MotionFlagHandlers:   offsetTable
                offsetTableEntry.w DeathEggRobot_PlayMotionSound
                offsetTableEntry.w DeathEggRobot_EnableMirroredMotion
                offsetTableEntry.w DeathEggRobot_RestartLimbMotion
; ===========================================================================

DeathEggRobot_PlayMotionSound:
                tst.b   objoff_1F(a0)
                bne.s   DeathEggRobotBombCollision_Return
                move.b  anim_frame(a0),d1
                addq.b  #1,d1
                move.b  (a1,d1.w),d0
                jsrto   JmpTo12_PlaySound               ; sound id most likely came from DeathEggRobot_LimbMotionProgram5 or DeathEggRobot_LimbMotionProgram6
                addq.b  #1,d1
                move.b  d1,anim_frame(a0)
                move.b  (a1,d1.w),d0
                move.b  d0,d1
                andi.b  #$C0,d1
                bne.s   DeathEggRobot_DispatchMotionFlags
                rts
; ===========================================================================

DeathEggRobot_EnableMirroredMotion:
                moveq   #1,d4
                rts
; ===========================================================================

DeathEggRobot_RestartLimbMotion:
                addq.w  #4,sp
                bra.s   DeathEggRobot_ResetMotionFrame
; ===========================================================================

DeathEggRobot_PositionFromParent:
                movea.w objoff_2C(a0),a2                ; a2=object
                move.w  x_pos(a2),d0
                move.w  (a1)+,d1
                btst    #render_flags.x_flip,render_flags(a2)
                beq.s   +
                neg.w   d1
+
                add.w   d1,d0
                move.w  d0,x_pos(a0)
                move.w  y_pos(a2),d0
                add.w   (a1)+,d0
                move.w  d0,y_pos(a0)
                rts
; ===========================================================================
; loc_3E2A8
