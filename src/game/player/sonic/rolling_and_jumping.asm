Sonic_RollSpeed:
                move.w  (Sonic_top_speed).w,d6
                asl.w   #1,d6
                move.w  (Sonic_acceleration).w,d5
                asr.w   #1,d5                           ; natural roll deceleration = 1/2 normal acceleration
                move.w  #$20,d4                         ; controlled roll deceleration... interestingly,
    ; this should be Sonic_deceleration/4 according to Tails_RollSpeed,
    ; which means Sonic is much better than Tails at slowing down his rolling when he's underwater
                _btst   #status_secondary.sliding,status_secondary(a0)
                _bne.w  Obj01_Roll_ResetScr
                tst.w   move_lock(a0)
                bne.s   Sonic_ApplyRollSpeed
                btst    #button_left,(Ctrl_1_Held_Logical).w  ; is left being pressed?
                beq.s   +                               ; if not, branch
                bsr.w   Sonic_RollLeft
+
                btst    #button_right,(Ctrl_1_Held_Logical).w  ; is right being pressed?
                beq.s   Sonic_ApplyRollSpeed            ; if not, branch
                bsr.w   Sonic_RollRight

; loc_1A7FC:
Sonic_ApplyRollSpeed:
                move.w  inertia(a0),d0
                beq.s   Sonic_CheckRollStop
                bmi.s   Sonic_ApplyRollSpeedLeft

; Sonic_ApplyRollSpeedRight:
                sub.w   d5,d0
                bcc.s   +
                move.w  #0,d0
+
                move.w  d0,inertia(a0)
                bra.s   Sonic_CheckRollStop
; ---------------------------------------------------------------------------
; loc_1A812:
Sonic_ApplyRollSpeedLeft:
                add.w   d5,d0
                bcc.s   +
                move.w  #0,d0
+
                move.w  d0,inertia(a0)

; loc_1A81E:
Sonic_CheckRollStop:
                tst.w   inertia(a0)
                bne.s   Obj01_Roll_ResetScr
                tst.b   pinball_mode(a0)                ; note: the spindash flag has a different meaning when Sonic's already rolling -- it's used to mean he's not allowed to stop rolling
                bne.s   Sonic_KeepRolling
                bclr    #status.player.rolling,status(a0)
                move.b  #$13,y_radius(a0)
                move.b  #9,x_radius(a0)
                move.b  #AniIDSonAni_Wait,anim(a0)
                subq.w  #5,y_pos(a0)
                bra.s   Obj01_Roll_ResetScr

; ---------------------------------------------------------------------------
; magically gives Sonic an extra push if he's going to stop rolling where it's not allowed
; (such as in an S-curve in HTZ or a stopper chamber in CNZ)
; loc_1A848:
Sonic_KeepRolling:
                move.w  #$400,inertia(a0)
                btst    #status.player.x_flip,status(a0)
                beq.s   Obj01_Roll_ResetScr
                neg.w   inertia(a0)

; resets the screen to normal while rolling, like Obj01_ResetScr
; loc_1A85A:
Obj01_Roll_ResetScr:
                cmpi.w  #(screen_height/2)-16,(Camera_Y_pos_bias).w  ; is screen in its default position?
                beq.s   Sonic_SetRollSpeeds             ; if yes, branch
                bhs.s   +                               ; depending on the sign of the difference,
                addq.w  #4,(Camera_Y_pos_bias).w        ; either add 2
+               subq.w  #2,(Camera_Y_pos_bias).w        ; or subtract 2

; loc_1A86C:
Sonic_SetRollSpeeds:
                move.b  angle(a0),d0
                jsr     (CalcSine).l
                muls.w  inertia(a0),d0
                asr.l   #8,d0
                move.w  d0,y_vel(a0)                    ; set y velocity based on $14 and angle
                muls.w  inertia(a0),d1
                asr.l   #8,d1
                cmpi.w  #$1000,d1
                ble.s   +
                move.w  #$1000,d1                       ; limit Sonic's speed rolling right
+
                cmpi.w  #-$1000,d1
                bge.s   +
                move.w  #-$1000,d1                      ; limit Sonic's speed rolling left
+
                move.w  d1,x_vel(a0)                    ; set x velocity based on $14 and angle
                bra.w   Obj01_CheckWallsOnGround
; End of function Sonic_RollSpeed

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A8A2:
Sonic_RollLeft:
                move.w  inertia(a0),d0
                beq.s   +
                bpl.s   Sonic_BrakeRollingRight
+
                bset    #status.player.x_flip,status(a0)
                move.b  #AniIDSonAni_Roll,anim(a0)      ; use "rolling" animation
                rts
; ---------------------------------------------------------------------------
; loc_1A8B8:
Sonic_BrakeRollingRight:
                sub.w   d4,d0                           ; reduce rightward rolling speed
                bcc.s   +
                move.w  #-$80,d0
+
                move.w  d0,inertia(a0)
                rts
; End of function Sonic_RollLeft

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A8C6:
Sonic_RollRight:
                move.w  inertia(a0),d0
                bmi.s   Sonic_BrakeRollingLeft
                bclr    #status.player.x_flip,status(a0)
                move.b  #AniIDSonAni_Roll,anim(a0)      ; use "rolling" animation
                rts
; ---------------------------------------------------------------------------
; loc_1A8DA:
Sonic_BrakeRollingLeft:
                add.w   d4,d0                           ; reduce leftward rolling speed
                bcc.s   +
                move.w  #$80,d0
+
                move.w  d0,inertia(a0)
                rts
; End of subroutine Sonic_RollRight

; ---------------------------------------------------------------------------
; Subroutine for moving Sonic left or right when he's in the air
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A8E8:
Sonic_ChgJumpDir:
                move.w  (Sonic_top_speed).w,d6
                move.w  (Sonic_acceleration).w,d5
                asl.w   #1,d5
                btst    #status.player.rolljumping,status(a0)  ; did Sonic jump from rolling?
                bne.s   Obj01_Jump_ResetScr             ; if yes, branch to skip midair control
                move.w  x_vel(a0),d0
                btst    #button_left,(Ctrl_1_Held_Logical).w
                beq.s   +                               ; if not holding left, branch

                bset    #status.player.x_flip,status(a0)
                sub.w   d5,d0                           ; add acceleration to the left
                move.w  d6,d1
                neg.w   d1
                cmp.w   d1,d0                           ; compare new speed with top speed
                bgt.s   +                               ; if new speed is less than the maximum, branch
                move.w  d1,d0                           ; limit speed in air going left, even if Sonic was already going faster (speed limit/cap)
+
                btst    #button_right,(Ctrl_1_Held_Logical).w
                beq.s   +                               ; if not holding right, branch

                bclr    #status.player.x_flip,status(a0)
                add.w   d5,d0                           ; accelerate right in the air
                cmp.w   d6,d0                           ; compare new speed with top speed
                blt.s   +                               ; if new speed is less than the maximum, branch
                move.w  d6,d0                           ; limit speed in air going right, even if Sonic was already going faster (speed limit/cap)
; Obj01_JumpMove:
+               move.w  d0,x_vel(a0)

; loc_1A932: Obj01_ResetScr2:
Obj01_Jump_ResetScr:
                cmpi.w  #(screen_height/2)-16,(Camera_Y_pos_bias).w  ; is screen in its default position?
                beq.s   Sonic_JumpPeakDecelerate        ; if yes, branch
                bhs.s   +                               ; depending on the sign of the difference,
                addq.w  #4,(Camera_Y_pos_bias).w        ; either add 2
+               subq.w  #2,(Camera_Y_pos_bias).w        ; or subtract 2

; loc_1A944:
Sonic_JumpPeakDecelerate:
                cmpi.w  #-$400,y_vel(a0)                ; is Sonic moving faster than -$400 upwards?
                blo.s   GamePlayerSonicRollingAndJumping_Return                    ; if yes, return
                move.w  x_vel(a0),d0
                move.w  d0,d1
                asr.w   #5,d1                           ; d1 = x_velocity / 32
                beq.s   GamePlayerSonicRollingAndJumping_Return                    ; return if d1 is 0
                bmi.s   Sonic_JumpPeakDecelerateLeft    ; branch if moving left

; Sonic_JumpPeakDecelerateRight:
                sub.w   d1,d0                           ; reduce x velocity by d1
                bcc.s   +
                move.w  #0,d0
+
                move.w  d0,x_vel(a0)
                rts
;-------------------------------------------------------------
; loc_1A966:
Sonic_JumpPeakDecelerateLeft:
                sub.w   d1,d0                           ; reduce x velocity by d1
                bcs.s   +
                move.w  #0,d0
+
                move.w  d0,x_vel(a0)

GamePlayerSonicRollingAndJumping_Return:
                rts
; End of subroutine Sonic_ChgJumpDir
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to prevent Sonic from leaving the boundaries of a level
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A974:
Sonic_LevelBound:
                move.l  x_pos(a0),d1
                move.w  x_vel(a0),d0
                ext.l   d0
                asl.l   #8,d0
                add.l   d0,d1
                swap    d1
                move.w  (Camera_Min_X_pos).w,d0
                addi.w  #$10,d0
                cmp.w   d1,d0                           ; has Sonic touched the left boundary?
                bhi.s   Sonic_Boundary_Sides            ; if yes, branch
                move.w  (Camera_Max_X_pos).w,d0
                addi.w  #screen_width-24,d0             ; screen width - Sonic's width_pixels
                tst.b   (Current_Boss_ID).w
                bne.s   +
                addi.w  #$40,d0
+
                cmp.w   d1,d0                           ; has Sonic touched the right boundary?
                bls.s   Sonic_Boundary_Sides            ; if yes, branch

; loc_1A9A6:
Sonic_Boundary_CheckBottom:
                move.w  (Camera_Max_Y_pos).w,d0
                addi.w  #screen_height,d0
                cmp.w   y_pos(a0),d0                    ; has Sonic touched the bottom boundary?
                blt.s   Sonic_Boundary_Bottom           ; if yes, branch
                rts
; ---------------------------------------------------------------------------
Sonic_Boundary_Bottom:                                  ;;
                jmpto   JmpTo_KillCharacter
; ===========================================================================

; loc_1A9BA:
Sonic_Boundary_Sides:
                move.w  d0,x_pos(a0)
                move.w  #0,2+x_pos(a0)                  ; subpixel x
                move.w  #0,x_vel(a0)
                move.w  #0,inertia(a0)
                bra.s   Sonic_Boundary_CheckBottom
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to start rolling when he's moving
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A9D2:
Sonic_Roll:
                _btst   #status_secondary.sliding,status_secondary(a0)
                _bne.s  Obj01_NoRoll
                mvabs.w inertia(a0),d0
                cmpi.w  #$80,d0                         ; is Sonic moving at $80 speed or faster?
                blo.s   Obj01_NoRoll                    ; if not, branch
                move.b  (Ctrl_1_Held_Logical).w,d0
                andi.b  #button_left_mask|button_right_mask,d0  ; is left/right being pressed?
                bne.s   Obj01_NoRoll                    ; if yes, branch
                btst    #button_down,(Ctrl_1_Held_Logical).w  ; is down being pressed?
                bne.s   Obj01_ChkRoll                   ; if yes, branch
; return_1A9F8:
Obj01_NoRoll:
                rts

; ---------------------------------------------------------------------------
; loc_1A9FA:
Obj01_ChkRoll:
                btst    #status.player.rolling,status(a0)  ; is Sonic already rolling?
                beq.s   Obj01_DoRoll                    ; if not, branch
                rts

; ---------------------------------------------------------------------------
; loc_1AA04:
Obj01_DoRoll:
                bset    #status.player.rolling,status(a0)
                move.b  #$E,y_radius(a0)
                move.b  #7,x_radius(a0)
                move.b  #AniIDSonAni_Roll,anim(a0)      ; use "rolling" animation
                addq.w  #5,y_pos(a0)
                move.w  #SndID_Roll,d0
                jsr     (PlaySound).l                   ; play rolling sound
                tst.w   inertia(a0)
                bne.s   GamePlayerSonicRollingAndJumping_Return_Variant2
                move.w  #$200,inertia(a0)

GamePlayerSonicRollingAndJumping_Return_Variant2:
                rts
; End of function Sonic_Roll

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AA38:
Sonic_Jump:
                move.b  (Ctrl_1_Press_Logical).w,d0
                andi.b  #button_B_mask|button_C_mask|button_A_mask,d0  ; is A, B or C pressed?
                beq.w   GamePlayerSonicRollingAndJumping_Return_Variant3                    ; if not, return
                moveq   #0,d0
                move.b  angle(a0),d0
                addi.b  #$80,d0
                bsr.w   CalcRoomOverHead
                cmpi.w  #6,d1                           ; does Sonic have enough room to jump?
                blt.w   GamePlayerSonicRollingAndJumping_Return_Variant3                    ; if not, branch
                move.w  #$680,d2
                tst.b   (Super_Sonic_flag).w
                beq.s   +
                move.w  #$800,d2                        ; set higher jump speed if super
+
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
                add.w   d1,x_vel(a0)                    ; make Sonic jump (in X... this adds nothing on level ground)
                muls.w  d2,d0
                asr.l   #8,d0
                add.w   d0,y_vel(a0)                    ; make Sonic jump (in Y)
                bset    #status.player.in_air,status(a0)
                bclr    #status.player.pushing,status(a0)
                addq.l  #4,sp
                move.b  #1,jumping(a0)
                clr.b   stick_to_convex(a0)
                move.w  #SndID_Jump,d0
                jsr     (PlaySound).l                   ; play jumping sound
; These lines are a remnant of the victory animation that would play
; when jumping at the end of a stage in the Sonic 1 prototype. Not only
; are these two lines now useless, they also cause Sonic to incorrectly
; reset to his standing collision when roll-jumping
                move.b  #$13,y_radius(a0)
                move.b  #9,x_radius(a0)
                btst    #status.player.rolling,status(a0)
                bne.s   Sonic_RollJump
                move.b  #$E,y_radius(a0)
                move.b  #7,x_radius(a0)
                move.b  #AniIDSonAni_Roll,anim(a0)      ; use "jumping" animation
                bset    #status.player.rolling,status(a0)
                addq.w  #5,y_pos(a0)

GamePlayerSonicRollingAndJumping_Return_Variant3:
                rts
; ---------------------------------------------------------------------------
; loc_1AAE8:
Sonic_RollJump:
                bset    #status.player.rolljumping,status(a0)  ; set the rolling+jumping flag
                rts
; End of function Sonic_Jump

; ---------------------------------------------------------------------------
; Subroutine letting Sonic control the height of the jump
; when the jump button is released
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; ===========================================================================
; loc_1AAF0:
Sonic_JumpHeight:
                tst.b   jumping(a0)                     ; is Sonic jumping?
                beq.s   Sonic_UpVelCap                  ; if not, branch

                move.w  #-$400,d1
                btst    #status.player.underwater,status(a0)  ; is Sonic underwater?
                beq.s   +                               ; if not, branch
                move.w  #-$200,d1
+
                cmp.w   y_vel(a0),d1                    ; is Sonic going up faster than d1?
                ble.s   +                               ; if not, branch
                move.b  (Ctrl_1_Held_Logical).w,d0
                andi.b  #button_B_mask|button_C_mask|button_A_mask,d0  ; is a jump button pressed?
                bne.s   +                               ; if yes, branch
                move.w  d1,y_vel(a0)                    ; immediately reduce Sonic's upward speed to d1
+
                tst.b   y_vel(a0)                       ; is Sonic exactly at the height of his jump?
                beq.s   Sonic_CheckGoSuper              ; if yes, test for turning into Super Sonic
                rts
; ---------------------------------------------------------------------------
; loc_1AB22:
Sonic_UpVelCap:
                tst.b   pinball_mode(a0)                ; is Sonic charging a spindash or in a rolling-only area?
                bne.s   GamePlayerSonicRollingAndJumping_Return_Variant4                    ; if yes, return
                cmpi.w  #-$FC0,y_vel(a0)                ; is Sonic moving up really fast?
                bge.s   GamePlayerSonicRollingAndJumping_Return_Variant4                    ; if not, return
                move.w  #-$FC0,y_vel(a0)                ; cap upward speed

GamePlayerSonicRollingAndJumping_Return_Variant4:
                rts
; End of subroutine Sonic_JumpHeight

; ---------------------------------------------------------------------------
; Subroutine called at the peak of a jump that transforms Sonic into Super Sonic
; if he has enough rings and emeralds
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AB38: test_set_SS:
Sonic_CheckGoSuper:
                tst.b   (Super_Sonic_flag).w            ; is Sonic already Super?
                bne.s   GamePlayerSonicRollingAndJumping_Return_Variant5                    ; if yes, branch
                cmpi.b  #7,(Emerald_count).w            ; does Sonic have exactly 7 emeralds?
                bne.s   GamePlayerSonicRollingAndJumping_Return_Variant5                    ; if not, branch
                cmpi.w  #50,(Ring_count).w              ; does Sonic have at least 50 rings?
                blo.s   GamePlayerSonicRollingAndJumping_Return_Variant5                    ; if not, branch

                move.b  #1,(Super_Sonic_palette).w
                move.b  #$F,(Palette_timer).w
                move.b  #1,(Super_Sonic_flag).w
                move.b  #$81,obj_control(a0)
                move.b  #AniIDSupSonAni_Transform,anim(a0)  ; use transformation animation
                move.b  #ObjID_SuperSonicStars,(SuperSonicStars+id).w  ; load Obj7E (Super Sonic stars object) at $FFFFD040
                move.w  #$A00,(Sonic_top_speed).w
                move.w  #$30,(Sonic_acceleration).w
                move.w  #$100,(Sonic_deceleration).w
                move.w  #0,invincibility_time(a0)
                bset    #status_secondary.invincible,status_secondary(a0)  ; make Sonic invincible
                move.w  #SndID_SuperTransform,d0
                jsr     (PlaySound).l                   ; Play transformation sound effect
                move.w  #MusID_SuperSonic,d0
                jmp     (PlayMusic).l                   ; load the Super Sonic song and return

; ---------------------------------------------------------------------------
GamePlayerSonicRollingAndJumping_Return_Variant5:
                rts
; End of subroutine Sonic_CheckGoSuper

; ---------------------------------------------------------------------------
; Subroutine doing the extra logic for Super Sonic
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1ABA6:
Sonic_Super:
                tst.b   (Super_Sonic_flag).w            ; Ignore all this code if not Super Sonic
                beq.w   GamePlayerSonicRollingAndJumping_Return_Variant6
                tst.b   (Update_HUD_timer).w
                beq.s   Sonic_RevertToNormal            ; ?
                subq.w  #1,(Super_Sonic_frame_count).w
                bpl.w   GamePlayerSonicRollingAndJumping_Return_Variant6
                move.w  #60,(Super_Sonic_frame_count).w  ; Reset frame counter to 60
                tst.w   (Ring_count).w
                beq.s   Sonic_RevertToNormal
                ori.b   #1,(Update_HUD_rings).w
                cmpi.w  #1,(Ring_count).w
                beq.s   +
                cmpi.w  #10,(Ring_count).w
                beq.s   +
                cmpi.w  #100,(Ring_count).w
                bne.s   ++
+
                ori.b   #$80,(Update_HUD_rings).w
+
                subq.w  #1,(Ring_count).w
                bne.s   GamePlayerSonicRollingAndJumping_Return_Variant6
; loc_1ABF2:
Sonic_RevertToNormal:
                move.b  #2,(Super_Sonic_palette).w      ; Remove rotating palette
                move.w  #$28,(Palette_frame).w
                move.b  #0,(Super_Sonic_flag).w
                move.b  #AniIDSonAni_Run,prev_anim(a0)  ; Force Sonic's animation to restart
                move.w  #1,invincibility_time(a0)       ; Remove invincibility
                move.w  #$600,(Sonic_top_speed).w
                move.w  #$C,(Sonic_acceleration).w
                move.w  #$80,(Sonic_deceleration).w
                btst    #status.player.underwater,status(a0)  ; Check if underwater, return if not
                beq.s   GamePlayerSonicRollingAndJumping_Return_Variant6
                move.w  #$300,(Sonic_top_speed).w
                move.w  #6,(Sonic_acceleration).w
                move.w  #$40,(Sonic_deceleration).w

GamePlayerSonicRollingAndJumping_Return_Variant6:
                rts
; End of subroutine Sonic_Super

; ---------------------------------------------------------------------------
; Subroutine to check for starting to charge a spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AC3E:
