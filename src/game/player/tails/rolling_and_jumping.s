Tails_RollSpeed:
                move.w  (Tails_top_speed).w,d6
                asl.w   #1,d6
                move.w  (Tails_acceleration).w,d5
                asr.w   #1,d5                           ; natural roll deceleration = 1/2 normal acceleration
; This code is outdated, matching the behaviour of Sonic in Sonic 1
; rather than in this game
                move.w  (Tails_deceleration).w,d4
                asr.w   #2,d4                           ; controlled roll deceleration
    ; interestingly, Tails is much worse at this than Sonic when underwater
                _btst   #status_secondary.sliding,status_secondary(a0)
                _bne.w  Obj02_Roll_ResetScr
                tst.w   move_lock(a0)
                bne.s   Tails_ApplyRollSpeed
                btst    #button_left,(Ctrl_2_Held_Logical).w  ; is left being pressed?
                beq.s   +                               ; if not, branch
                bsr.w   Tails_RollLeft
+
                btst    #button_right,(Ctrl_2_Held_Logical).w  ; is right being pressed?
                beq.s   Tails_ApplyRollSpeed            ; if not, branch
                bsr.w   Tails_RollRight

; loc_1C3E2:
Tails_ApplyRollSpeed:
                move.w  inertia(a0),d0
                beq.s   Tails_CheckRollStop
                bmi.s   Tails_ApplyRollSpeedLeft

; Tails_ApplyRollSpeedRight:
                sub.w   d5,d0
                bcc.s   +
                move.w  #0,d0
+
                move.w  d0,inertia(a0)
                bra.s   Tails_CheckRollStop
; ---------------------------------------------------------------------------
; loc_1C3F8:
Tails_ApplyRollSpeedLeft:
                add.w   d5,d0
                bcc.s   +
                move.w  #0,d0
+
                move.w  d0,inertia(a0)

; loc_1C404
Tails_CheckRollStop:
                tst.w   inertia(a0)
                bne.s   Obj02_Roll_ResetScr
                tst.b   pinball_mode(a0)                ; note: the spindash flag has a different meaning when Tails is already rolling -- it's used to mean he's not allowed to stop rolling
                bne.s   Tails_KeepRolling
                bclr    #status.player.rolling,status(a0)
                move.b  #$F,y_radius(a0)                ; sets standing height to only slightly higher than rolling height, unlike Sonic
                move.b  #9,x_radius(a0)
                move.b  #AniIDSonAni_Wait,anim(a0)
                subq.w  #1,y_pos(a0)
                bra.s   Obj02_Roll_ResetScr

; ---------------------------------------------------------------------------
; magically gives Tails an extra push if he's going to stop rolling where it's not allowed
; (such as in an S-curve in HTZ or a stopper chamber in CNZ)
; loc_1C42E:
Tails_KeepRolling:
                move.w  #$400,inertia(a0)
                btst    #status.player.x_flip,status(a0)
                beq.s   Obj02_Roll_ResetScr
                neg.w   inertia(a0)

; resets the screen to normal while rolling, like Obj02_ResetScr
; loc_1C440:
Obj02_Roll_ResetScr:
                cmpi.w  #(screen_height/2)-16,(Camera_Y_pos_bias_P2).w  ; is screen in its default position?
                beq.s   Tails_SetRollSpeed              ; if yes, branch
                bhs.s   +                               ; depending on the sign of the difference,
                addq.w  #4,(Camera_Y_pos_bias_P2).w     ; either add 2
+               subq.w  #2,(Camera_Y_pos_bias_P2).w     ; or subtract 2

; loc_1C452:
Tails_SetRollSpeed:
                move.b  angle(a0),d0
                jsr     (CalcSine).l
                muls.w  inertia(a0),d0
                asr.l   #8,d0
                move.w  d0,y_vel(a0)                    ; set y velocity based on $14 and angle
                muls.w  inertia(a0),d1
                asr.l   #8,d1
                cmpi.w  #$1000,d1
                ble.s   +
                move.w  #$1000,d1                       ; limit Tails' speed rolling right
+
                cmpi.w  #-$1000,d1
                bge.s   +
                move.w  #-$1000,d1                      ; limit Tails' speed rolling left
+
                move.w  d1,x_vel(a0)                    ; set x velocity based on $14 and angle
                bra.w   Obj02_CheckWallsOnGround
; End of function Tails_RollSpeed

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C488:
Tails_RollLeft:
                move.w  inertia(a0),d0
                beq.s   +
                bpl.s   Tails_BrakeRollingRight
+
                bset    #status.player.x_flip,status(a0)
                move.b  #AniIDSonAni_Roll,anim(a0)      ; use "rolling" animation
                rts
; ---------------------------------------------------------------------------
; loc_1C49E:
Tails_BrakeRollingRight:
                sub.w   d4,d0                           ; reduce rightward rolling speed
                bcc.s   +
                move.w  #-$80,d0
+
                move.w  d0,inertia(a0)
                rts
; End of function Tails_RollLeft

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C4AC:
Tails_RollRight:
                move.w  inertia(a0),d0
                bmi.s   Tails_BrakeRollingLeft
                bclr    #status.player.x_flip,status(a0)
                move.b  #AniIDSonAni_Roll,anim(a0)      ; use "rolling" animation
                rts
; ---------------------------------------------------------------------------
; loc_1C4C0:
Tails_BrakeRollingLeft:
                add.w   d4,d0                           ; reduce leftward rolling speed
                bcc.s   +
                move.w  #$80,d0
+
                move.w  d0,inertia(a0)
                rts
; End of subroutine Tails_RollRight

; ---------------------------------------------------------------------------
; Subroutine for moving Tails left or right when he's in the air
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C4CE:
Tails_ChgJumpDir:
                move.w  (Tails_top_speed).w,d6
                move.w  (Tails_acceleration).w,d5
                asl.w   #1,d5
                btst    #status.player.rolljumping,status(a0)  ; did Tails jump from rolling?
                bne.s   Obj02_Jump_ResetScr             ; if yes, branch to skip midair control
                move.w  x_vel(a0),d0
                btst    #button_left,(Ctrl_2_Held_Logical).w
                beq.s   +                               ; if not holding left, branch

                bset    #status.player.x_flip,status(a0)
                sub.w   d5,d0                           ; add acceleration to the left
                move.w  d6,d1
                neg.w   d1
                cmp.w   d1,d0                           ; compare new speed with top speed
                bgt.s   +                               ; if new speed is less than the maximum, branch
                move.w  d1,d0                           ; limit speed in air going left, even if Tails was already going faster (speed limit/cap)
+
                btst    #button_right,(Ctrl_2_Held_Logical).w
                beq.s   +                               ; if not holding right, branch

                bclr    #status.player.x_flip,status(a0)
                add.w   d5,d0                           ; accelerate right in the air
                cmp.w   d6,d0                           ; compare new speed with top speed
                blt.s   +                               ; if new speed is less than the maximum, branch
                move.w  d6,d0                           ; limit speed in air going right, even if Tails was already going faster (speed limit/cap)
; Obj02_JumpMove:
+               move.w  d0,x_vel(a0)

; loc_1C518: Obj02_ResetScr2:
Obj02_Jump_ResetScr:
                cmpi.w  #(screen_height/2)-16,(Camera_Y_pos_bias_P2).w  ; is screen in its default position?
                beq.s   Tails_JumpPeakDecelerate        ; if yes, branch
                bhs.s   +                               ; depending on the sign of the difference,
                addq.w  #4,(Camera_Y_pos_bias_P2).w     ; either add 2
+               subq.w  #2,(Camera_Y_pos_bias_P2).w     ; or subtract 2

; loc_1C52A:
Tails_JumpPeakDecelerate:
                cmpi.w  #-$400,y_vel(a0)                ; is Tails moving faster than -$400 upwards?
                blo.s   GamePlayerTailsRollingAndJumping_Return  ; if yes, return
                move.w  x_vel(a0),d0
                move.w  d0,d1
                asr.w   #5,d1                           ; d1 = x_velocity / 32
                beq.s   GamePlayerTailsRollingAndJumping_Return  ; return if d1 is 0
                bmi.s   Tails_JumpPeakDecelerateLeft

; Tails_JumpPeakDecelerateRight:
                sub.w   d1,d0                           ; reduce x velocity by d1
                bcc.s   +
                move.w  #0,d0
+
                move.w  d0,x_vel(a0)
                rts
; ---------------------------------------------------------------------------
; loc_1C54C:
Tails_JumpPeakDecelerateLeft:
                sub.w   d1,d0                           ; reduce x velocity by d1
                bcs.s   +
                move.w  #0,d0
+
                move.w  d0,x_vel(a0)

GamePlayerTailsRollingAndJumping_Return:
                rts
; End of subroutine Tails_ChgJumpDir
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to prevent Tails from leaving the boundaries of a level
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C55A:
Tails_LevelBound:
                move.l  x_pos(a0),d1
                move.w  x_vel(a0),d0
                ext.l   d0
                asl.l   #8,d0
                add.l   d0,d1
                swap    d1
                move.w  (Tails_Min_X_pos).w,d0
                addi.w  #$10,d0
                cmp.w   d1,d0                           ; has Tails touched the left boundary?
                bhi.s   Tails_Boundary_Sides            ; if yes, branch
                move.w  (Tails_Max_X_pos).w,d0
                addi.w  #screen_width-24,d0             ; screen width - Tails's width_pixels
                tst.b   (Current_Boss_ID).w
                bne.s   +
                addi.w  #$40,d0
+
                cmp.w   d1,d0                           ; has Tails touched the right boundary?
                bls.s   Tails_Boundary_Sides            ; if yes, branch

; loc_1C58C:
Tails_Boundary_CheckBottom:
                move.w  (Tails_Max_Y_pos).w,d0
                addi.w  #screen_height,d0
                cmp.w   y_pos(a0),d0                    ; has Tails touched the bottom boundary?
                blt.s   Tails_Boundary_Bottom           ; if yes, branch
                rts
; ---------------------------------------------------------------------------
Tails_Boundary_Bottom:                                  ;;
                jmpto   JmpTo2_KillCharacter
; ===========================================================================

; loc_1C5A0:
Tails_Boundary_Sides:
                move.w  d0,x_pos(a0)
                move.w  #0,2+x_pos(a0)                  ; subpixel x
                move.w  #0,x_vel(a0)
                move.w  #0,inertia(a0)
                bra.s   Tails_Boundary_CheckBottom
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine allowing Tails to start rolling when he's moving
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C5B8:
Tails_Roll:
                _btst   #status_secondary.sliding,status_secondary(a0)
                _bne.s  Obj02_NoRoll
                mvabs.w inertia(a0),d0
                cmpi.w  #$80,d0                         ; is Tails moving at $80 speed or faster?
                blo.s   Obj02_NoRoll                    ; if not, branch
                move.b  (Ctrl_2_Held_Logical).w,d0
                andi.b  #button_left_mask|button_right_mask,d0  ; is left/right being pressed?
                bne.s   Obj02_NoRoll                    ; if yes, branch
                btst    #button_down,(Ctrl_2_Held_Logical).w  ; is down being pressed?
                bne.s   Obj02_ChkRoll                   ; if yes, branch
; return_1C5DE:
Obj02_NoRoll:
                rts

; ---------------------------------------------------------------------------
; loc_1C5E0:
Obj02_ChkRoll:
                btst    #status.player.rolling,status(a0)  ; is Tails already rolling?
                beq.s   Obj02_DoRoll                    ; if not, branch
                rts

; ---------------------------------------------------------------------------
; loc_1C5EA:
Obj02_DoRoll:
                bset    #status.player.rolling,status(a0)
                move.b  #$E,y_radius(a0)
                move.b  #7,x_radius(a0)
                move.b  #AniIDSonAni_Roll,anim(a0)      ; use "rolling" animation
                addq.w  #1,y_pos(a0)
                move.w  #SndID_Roll,d0
                jsr     (PlaySound).l                   ; play rolling sound
                tst.w   inertia(a0)
                bne.s   TailsRollJump_Return_Variant2
                move.w  #$200,inertia(a0)

TailsRollJump_Return_Variant2:
                rts
; End of function Tails_Roll

; ---------------------------------------------------------------------------
; Subroutine allowing Tails to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C61E:
Tails_Jump:
                move.b  (Ctrl_2_Press_Logical).w,d0
                andi.b  #button_B_mask|button_C_mask|button_A_mask,d0  ; is A, B or C pressed?
                beq.w   TailsRollJump_Return_Variant3   ; if not, return
                moveq   #0,d0
                move.b  angle(a0),d0
                addi.b  #$80,d0
                bsr.w   CalcRoomOverHead
                cmpi.w  #6,d1                           ; does Tails have enough room to jump?
                blt.w   TailsRollJump_Return_Variant3   ; if not, branch
                move.w  #$680,d2
                btst    #status.player.underwater,status(a0)  ; Test if underwater
                beq.s   +
                move.w  #$380,d2                        ; set lower jump speed if underwater
+
                moveq   #0,d0
                move.b  angle(a0),d0
                subi.b  #$40,d0
                jsr     (CalcSine).l
                muls.w  d2,d1
                asr.l   #8,d1
                add.w   d1,x_vel(a0)                    ; make Tails jump (in X... this adds nothing on level ground)
                muls.w  d2,d0
                asr.l   #8,d0
                add.w   d0,y_vel(a0)                    ; make Tails jump (in Y)
                bset    #status.player.in_air,status(a0)
                bclr    #status.player.pushing,status(a0)
                addq.l  #4,sp
                move.b  #1,jumping(a0)
                clr.b   stick_to_convex(a0)
                move.w  #SndID_Jump,d0
                jsr     (PlaySound).l                   ; play jumping sound
; These lines are a remnant of the victory animation that would play
; when jumping at the end of a stage in the Sonic 1 prototype. Not only
; are these two lines now useless, they also cause Tails to incorrectly
; reset to his standing collision when roll-jumping
                move.b  #$F,y_radius(a0)
                move.b  #9,x_radius(a0)
                btst    #status.player.rolling,status(a0)
                bne.s   Tails_RollJump
                move.b  #$E,y_radius(a0)
                move.b  #7,x_radius(a0)
                move.b  #AniIDSonAni_Roll,anim(a0)      ; use "jumping" animation
                bset    #status.player.rolling,status(a0)
                addq.w  #1,y_pos(a0)

TailsRollJump_Return_Variant3:
                rts
; ---------------------------------------------------------------------------
; loc_1C6C4:
Tails_RollJump:
                bset    #status.player.rolljumping,status(a0)  ; set the rolling+jumping flag
                rts
; End of function Tails_Jump

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; ===========================================================================
; loc_1C6CC:
Tails_JumpHeight:
                tst.b   jumping(a0)                     ; is Tails jumping?
                beq.s   Tails_UpVelCap                  ; if not, branch

                move.w  #-$400,d1
                btst    #status.player.underwater,status(a0)  ; is Tails underwater?
                beq.s   +                               ; if not, branch
                move.w  #-$200,d1
+
                cmp.w   y_vel(a0),d1                    ; is Tails going up faster than d1?
                ble.s   +                               ; if not, branch
                move.b  (Ctrl_2_Held_Logical).w,d0
                andi.b  #button_B_mask|button_C_mask|button_A_mask,d0  ; is a jump button pressed?
                bne.s   +                               ; if yes, branch
                move.w  d1,y_vel(a0)                    ; immediately reduce Tails's upward speed to d1
+
                rts
; ---------------------------------------------------------------------------
; loc_1C6F8:
Tails_UpVelCap:
                tst.b   pinball_mode(a0)                ; is Tails charging a spindash or in a rolling-only area?
                bne.s   TailsRollJump_Return_Variant4   ; if yes, return
                cmpi.w  #-$FC0,y_vel(a0)                ; is Tails moving up really fast?
                bge.s   TailsRollJump_Return_Variant4   ; if not, return
                move.w  #-$FC0,y_vel(a0)                ; cap upward speed

TailsRollJump_Return_Variant4:
                rts
; End of subroutine Tails_JumpHeight

; ---------------------------------------------------------------------------
; Subroutine to check for starting to charge a spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C70E:
