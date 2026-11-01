Tails_RecordPos:
                move.w  (Tails_Pos_Record_Index).w,d0
                lea     (Tails_Pos_Record_Buf).w,a1
                lea     (a1,d0.w),a1
                move.w  x_pos(a0),(a1)+
                move.w  y_pos(a0),(a1)+
                addq.b  #4,(Tails_Pos_Record_Index+1).w

                rts
; End of subroutine Tails_RecordPos

; ---------------------------------------------------------------------------
; Subroutine for Tails when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1BF52:
Tails_Water:
                tst.b   (Water_flag).w                  ; does level have water?
                bne.s   Obj02_InWater                   ; if yes, branch

GamePlayerTailsEnvironment_Return:
                rts
; ---------------------------------------------------------------------------
; loc_1BF5A:
Obj02_InWater:
                move.w  (Water_Level_1).w,d0
                cmp.w   y_pos(a0),d0                    ; is Sonic above the water?
                bge.s   Obj02_OutWater                  ; if yes, branch

                bset    #status.player.underwater,status(a0)  ; set underwater flag
                bne.s   GamePlayerTailsEnvironment_Return  ; if already underwater, branch

                movea.l a0,a1
                bsr.w   ResumeMusic
                move.b  #ObjID_SmallBubbles,(Tails_BreathingBubbles+id).w  ; load Obj0A (tail's breathing bubbles) at $FFFFD0C0
                move.b  #$81,(Tails_BreathingBubbles+subtype).w
                move.l  a0,(Tails_BreathingBubbles+obj0a_character).w  ; set its parent to be this (obj0A uses $3C instead of $3E for some reason)
                move.w  #$300,(Tails_top_speed).w
                move.w  #6,(Tails_acceleration).w
                move.w  #$40,(Tails_deceleration).w
                asr     x_vel(a0)
                asr     y_vel(a0)
                asr     y_vel(a0)
                beq.s   GamePlayerTailsEnvironment_Return
                move.w  #(1<<8)|(0<<0),(Tails_Dust+anim).w  ; splash animation
                move.w  #SndID_Splash,d0                ; splash sound
                jmp     (PlaySound).l
; ---------------------------------------------------------------------------
; loc_1BFB2:
Obj02_OutWater:
                bclr    #status.player.underwater,status(a0)  ; unset underwater flag
                beq.s   GamePlayerTailsEnvironment_Return  ; if already above water, branch

                movea.l a0,a1
                bsr.w   ResumeMusic
                move.w  #$600,(Tails_top_speed).w
                move.w  #$C,(Tails_acceleration).w
                move.w  #$80,(Tails_deceleration).w

                cmpi.b  #4,routine(a0)                  ; is Tails falling back from getting hurt?
                beq.s   +                               ; if yes, branch
                asl     y_vel(a0)
+
                tst.w   y_vel(a0)
                beq.w   GamePlayerTailsEnvironment_Return
                move.w  #(1<<8)|(0<<0),(Tails_Dust+anim).w  ; splash animation
                movea.l a0,a1
                bsr.w   ResumeMusic
                cmpi.w  #-$1000,y_vel(a0)
                bgt.s   +
                move.w  #-$1000,y_vel(a0)               ; limit upward y velocity exiting the water
+
                move.w  #SndID_Splash,d0                ; splash sound
                jmp     (PlaySound).l
; End of subroutine Tails_Water

; ===========================================================================
; ---------------------------------------------------------------------------
; Start of subroutine Obj02_MdNormal
; Called if Tails is neither airborne nor rolling this frame
; ---------------------------------------------------------------------------
; loc_1C00A:
Obj02_MdNormal:
                bsr.w   Tails_CheckSpindash
                bsr.w   Tails_Jump
                bsr.w   Tails_SlopeResist
                bsr.w   Tails_Move
                bsr.w   Tails_Roll
                bsr.w   Tails_LevelBound
                jsr     (ObjectMove).l
                bsr.w   AnglePos
                bsr.w   Tails_SlopeRepel
                rts
; End of subroutine Obj02_MdNormal
; ===========================================================================
; Start of subroutine Obj02_MdAir
; Called if Tails is airborne, but not in a ball (thus, probably not jumping)
; loc_1C032: Obj02_MdJump
Obj02_MdAir:
                bsr.w   Tails_JumpHeight
                bsr.w   Tails_ChgJumpDir
                bsr.w   Tails_LevelBound
                jsr     (ObjectMoveAndFall).l
                btst    #status.player.underwater,status(a0)  ; is Tails underwater?
                beq.s   +                               ; if not, branch
                subi.w  #$28,y_vel(a0)                  ; reduce gravity by $28 ($38-$28=$10)
+
                bsr.w   Tails_JumpAngle
                bsr.w   Tails_DoLevelCollision
                rts
; End of subroutine Obj02_MdAir
; ===========================================================================
; Start of subroutine Obj02_MdRoll
; Called if Tails is in a ball, but not airborne (thus, probably rolling)
; loc_1C05C:
Obj02_MdRoll:
                tst.b   pinball_mode(a0)
                bne.s   +
                bsr.w   Tails_Jump
+
                bsr.w   Tails_RollRepel
                bsr.w   Tails_RollSpeed
                bsr.w   Tails_LevelBound
                jsr     (ObjectMove).l
                bsr.w   AnglePos
                bsr.w   Tails_SlopeRepel
                rts
; End of subroutine Obj02_MdRoll
; ===========================================================================
; Start of subroutine Obj02_MdJump
; Called if Tails is in a ball and airborne (he could be jumping but not necessarily)
; Notes: This is identical to Obj02_MdAir, at least at this outer level
; Why they gave it a separate copy of the code, I don't know
; loc_1C082: Obj02_MdJump2:
Obj02_MdJump:
                bsr.w   Tails_JumpHeight
                bsr.w   Tails_ChgJumpDir
                bsr.w   Tails_LevelBound
                jsr     (ObjectMoveAndFall).l
                btst    #status.player.underwater,status(a0)  ; is Tails underwater?
                beq.s   +                               ; if not, branch
                subi.w  #$28,y_vel(a0)                  ; reduce gravity by $28 ($38-$28=$10)
+
                bsr.w   Tails_JumpAngle
                bsr.w   Tails_DoLevelCollision
                rts
; End of subroutine Obj02_MdJump

; ---------------------------------------------------------------------------
; Subroutine to make Tails walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C0AC:
