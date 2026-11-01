Sonic_Move:
                move.w  (Sonic_top_speed).w,d6          ; load Sonic's current top speed
                move.w  (Sonic_acceleration).w,d5       ; load Sonic's current acceleration
                move.w  (Sonic_deceleration).w,d4       ; load Sonic's current deceleration
                _btst   #status_secondary.sliding,status_secondary(a0)  ; is Sonic sliding?
                _bne.w  Obj01_Traction                  ; if yes, branch
                tst.w   move_lock(a0)                   ; is D-Pad input locked?
                bne.w   Obj01_ResetScr                  ; if yes, branch
                btst    #button_left,(Ctrl_1_Held_Logical).w  ; is left being pressed?
                beq.s   Obj01_NotLeft                   ; if not, branch
                bsr.w   Sonic_MoveLeft                  ; else, branch
; loc_1A382:
Obj01_NotLeft:
                btst    #button_right,(Ctrl_1_Held_Logical).w  ; is right being pressed?
                beq.s   Obj01_NotRight                  ; if not, branch
                bsr.w   Sonic_MoveRight                 ; else, branch
; loc_1A38E:
Obj01_NotRight:
                move.b  angle(a0),d0                    ; load Sonic's current angle
                addi.b  #$20,d0                         ; rotate it 45 degrees clockwise
                andi.b  #$C0,d0                         ; snap to nearest multiple of 90 degrees
                bne.w   Obj01_ResetScr                  ; if Sonic is on a slope, then branch
                tst.w   inertia(a0)                     ; is Sonic moving?
                bne.w   Obj01_ResetScr                  ; if yes, branch
                bclr    #status.player.pushing,status(a0)  ; clear pushing flag
                move.b  #AniIDSonAni_Wait,anim(a0)      ; use "standing" animation
                btst    #status.player.on_object,status(a0)  ; is Sonic standing on a platform object?
                beq.w   Sonic_Balance                   ; if not, branch
                moveq   #0,d0                           ; clear d0
                move.b  interact(a0),d0                 ; get OST index of object Sonic is currently standing on
                if      object_size=$40
                lsl.w   #object_size_bits,d0            ; multiply by $40
                else
                mulu.w  #object_size,d0                 ; multiply by object_size
                endif
                lea     (Object_RAM).w,a1               ; load object space (a1=character)
                lea     (a1,d0.w),a1                    ; load stood-on object (a1=object)
                _btst   #status.npc.no_balancing,status(a1)
                _bne.w  Sonic_Lookup
                moveq   #0,d1                           ; clear d1
                move.b  width_pixels(a1),d1             ; get physical width of stood-on object
                move.w  d1,d2                           ; copy width
                add.w   d2,d2                           ; double it
                subq.w  #2,d2                           ; minus 4
                add.w   x_pos(a0),d1                    ; get Sonic's current X-position
                sub.w   x_pos(a1),d1                    ; subtract stood-on object's X-position
                tst.b   (Super_Sonic_flag).w            ; is Sonic in his Super form?
                bne.w   SuperSonic_Balance              ; if yes, branch
                cmpi.w  #2,d1                           ; is Sonic within 2px of the objects left edge?
                blt.s   Sonic_BalanceOnObjLeft          ; if yes, branch
                cmp.w   d2,d1                           ; is Sonic within 2px of the objects right edge?
                bge.s   Sonic_BalanceOnObjRight         ; if yes, branch
                bra.w   Sonic_Lookup                    ; else, branch
; ---------------------------------------------------------------------------
; loc_1A3FE:
SuperSonic_Balance:
                cmpi.w  #2,d1                           ; is Super Sonic within 2px of the objects left edge?
                blt.w   SuperSonic_BalanceOnObjLeft     ; if yes, branch
                cmp.w   d2,d1                           ; is Super Sonic within 2px of the objects right edge?
                bge.w   SuperSonic_BalanceOnObjRight    ; if yes, branch
                bra.w   Sonic_Lookup                    ; else, branch
; ---------------------------------------------------------------------------
; balancing checks for when you're on the right edge of an object
; loc_1A410:
Sonic_BalanceOnObjRight:
                btst    #status.player.x_flip,status(a0)  ; is Sonic facing right?
                bne.s   +                               ; if not, branch
                move.b  #AniIDSonAni_Balance,anim(a0)   ; set Sonic's animation to "Balance"
                addq.w  #6,d2
                cmp.w   d2,d1
                blt.w   Obj01_ResetScr
                move.b  #AniIDSonAni_Balance2,anim(a0)  ; set Sonic's animation to "Balance2"
                bra.w   Obj01_ResetScr
; on right edge of object but facing left:
+               move.b  #AniIDSonAni_Balance3,anim(a0)  ; set Sonic's animation to "Balance3"
                addq.w  #6,d2
                cmp.w   d2,d1
                blt.w   Obj01_ResetScr
                move.b  #AniIDSonAni_Balance4,anim(a0)  ; set Sonic's animation to "Balance4"
                bclr    #status.player.x_flip,status(a0)  ; clear X-flip flag (face right)
                bra.w   Obj01_ResetScr
; ---------------------------------------------------------------------------
; balancing checks for when you're on the left edge of an object
; loc_1A44E:
Sonic_BalanceOnObjLeft:
                btst    #status.player.x_flip,status(a0)  ; is Sonic facing left?
                beq.s   +                               ; if not, branch
                move.b  #AniIDSonAni_Balance,anim(a0)   ; set Sonic's animation to "Balance"
                cmpi.w  #-4,d1
                bge.w   Obj01_ResetScr
                move.b  #AniIDSonAni_Balance2,anim(a0)  ; set Sonic's animation to "Balance2"
                bra.w   Obj01_ResetScr
; on left edge of object but facing right:
+               move.b  #AniIDSonAni_Balance3,anim(a0)  ; set Sonic's animation to "Balance3"
                cmpi.w  #-4,d1
                bge.w   Obj01_ResetScr
                move.b  #AniIDSonAni_Balance4,anim(a0)  ; set Sonic's animation to "Balance4"
                bset    #status.player.x_flip,status(a0)  ; set X-flip flag (face left)
                bra.w   Obj01_ResetScr
; ---------------------------------------------------------------------------
; balancing checks for when you're on the edge of part of the level
; loc_1A48C:
Sonic_Balance:
                jsr     (ChkFloorEdge).l                ; get distance of Sonic to nearest floor
                cmpi.w  #$C,d1                          ; is he within $C (12px) to floor?
                blt.w   Sonic_Lookup                    ; if yes, don't do balance animation (would look awkward)
                tst.b   (Super_Sonic_flag).w            ; is Sonic in his Super form?
                bne.w   SuperSonic_Balance2             ; if yes, branch
                cmpi.b  #3,next_tilt(a0)
                bne.s   Sonic_BalanceLeft
                btst    #status.player.x_flip,status(a0)  ; is Sonic facing right?
                bne.s   +                               ; if not, branch
                move.b  #AniIDSonAni_Balance,anim(a0)   ; set Sonic's animation to "Balance"
                move.w  x_pos(a0),d3
                subq.w  #6,d3
                jsr     (ChkFloorEdge_Part2).l
                cmpi.w  #$C,d1
                blt.w   Obj01_ResetScr
                move.b  #AniIDSonAni_Balance2,anim(a0)  ; set Sonic's animation to "Balance2"
                bra.w   Obj01_ResetScr
; on right edge but facing left:
+               move.b  #AniIDSonAni_Balance3,anim(a0)  ; set Sonic's animation to "Balance3"
                move.w  x_pos(a0),d3
                subq.w  #6,d3
                jsr     (ChkFloorEdge_Part2).l
                cmpi.w  #$C,d1
                blt.w   Obj01_ResetScr
                move.b  #AniIDSonAni_Balance4,anim(a0)  ; set Sonic's animation to "Balance4"
                bclr    #status.player.x_flip,status(a0)
                bra.w   Obj01_ResetScr
; ---------------------------------------------------------------------------
Sonic_BalanceLeft:
                cmpi.b  #3,tilt(a0)
                bne.s   Sonic_Lookup
                btst    #status.player.x_flip,status(a0)  ; is Sonic facing left?
                beq.s   +                               ; if not, branch
                move.b  #AniIDSonAni_Balance,anim(a0)   ; set Sonic's animation to "Balance"
                move.w  x_pos(a0),d3
                addq.w  #6,d3
                jsr     (ChkFloorEdge_Part2).l
                cmpi.w  #$C,d1
                blt.w   Obj01_ResetScr
                move.b  #AniIDSonAni_Balance2,anim(a0)  ; set Sonic's animation to "Balance2"
                bra.w   Obj01_ResetScr
; on left edge but facing right:
+               move.b  #AniIDSonAni_Balance3,anim(a0)  ; set Sonic's animation to "Balance3"
                move.w  x_pos(a0),d3
                addq.w  #6,d3
                jsr     (ChkFloorEdge_Part2).l
                cmpi.w  #$C,d1
                blt.w   Obj01_ResetScr
                move.b  #AniIDSonAni_Balance4,anim(a0)  ; set Sonic's animation to "Balance4"
                bset    #status.player.x_flip,status(a0)  ; set X-flip flag (face left)
                bra.w   Obj01_ResetScr
; ---------------------------------------------------------------------------
; loc_1A55E:
SuperSonic_Balance2:
                cmpi.b  #3,next_tilt(a0)
                bne.s   loc_1A56E

; loc_1A566:
SuperSonic_BalanceOnObjRight:
                bclr    #status.player.x_flip,status(a0)  ; clear X-flip flag (face right)
                bra.s   loc_1A57C
; ---------------------------------------------------------------------------
loc_1A56E:
                cmpi.b  #3,tilt(a0)
                bne.s   Sonic_Lookup

; loc_1A576:
SuperSonic_BalanceOnObjLeft:
                bset    #status.player.x_flip,status(a0)  ; set X-flip flag (face left)

loc_1A57C:
                move.b  #AniIDSonAni_Balance,anim(a0)   ; set Sonic's animation to "Balance"
                bra.s   Obj01_ResetScr
; ---------------------------------------------------------------------------
; loc_1A584:
Sonic_Lookup:
                btst    #button_up,(Ctrl_1_Held_Logical).w  ; is up being pressed?
                beq.s   Sonic_Duck                      ; if not, branch
                move.b  #AniIDSonAni_LookUp,anim(a0)    ; use "looking up" animation
                addq.w  #1,(Sonic_Look_delay_counter).w
                cmpi.w  #$78,(Sonic_Look_delay_counter).w
                blo.s   Obj01_ResetScr_Part2
                move.w  #$78,(Sonic_Look_delay_counter).w
                cmpi.w  #$C8,(Camera_Y_pos_bias).w
                beq.s   Obj01_UpdateSpeedOnGround
                addq.w  #2,(Camera_Y_pos_bias).w
                bra.s   Obj01_UpdateSpeedOnGround
; ---------------------------------------------------------------------------
; loc_1A5B2:
Sonic_Duck:
                btst    #button_down,(Ctrl_1_Held_Logical).w  ; is down being pressed?
                beq.s   Obj01_ResetScr                  ; if not, branch
                move.b  #AniIDSonAni_Duck,anim(a0)      ; use "ducking" animation
                addq.w  #1,(Sonic_Look_delay_counter).w
                cmpi.w  #$78,(Sonic_Look_delay_counter).w
                blo.s   Obj01_ResetScr_Part2
                move.w  #$78,(Sonic_Look_delay_counter).w
                cmpi.w  #8,(Camera_Y_pos_bias).w
                beq.s   Obj01_UpdateSpeedOnGround
                subq.w  #2,(Camera_Y_pos_bias).w
                bra.s   Obj01_UpdateSpeedOnGround

; ===========================================================================
; moves the screen back to its normal position after looking up or down
; loc_1A5E0:
Obj01_ResetScr:
                move.w  #0,(Sonic_Look_delay_counter).w
; loc_1A5E6:
Obj01_ResetScr_Part2:
                cmpi.w  #(screen_height/2)-16,(Camera_Y_pos_bias).w  ; is screen in its default position?
                beq.s   Obj01_UpdateSpeedOnGround       ; if yes, branch
                bhs.s   +                               ; depending on the sign of the difference,
                addq.w  #4,(Camera_Y_pos_bias).w        ; either add 2
+               subq.w  #2,(Camera_Y_pos_bias).w        ; or subtract 2

; ---------------------------------------------------------------------------
; updates Sonic's speed on the ground
; ---------------------------------------------------------------------------
; sub_1A5F8:
Obj01_UpdateSpeedOnGround:
                tst.b   (Super_Sonic_flag).w            ; is Sonic in his Super form?
                beq.w   +                               ; if not, branch
                move.w  #$C,d5                          ; hardcoded Super Sonic deceleration override
+
                move.b  (Ctrl_1_Held_Logical).w,d0      ; load currently held buttons
                andi.b  #button_left_mask|button_right_mask,d0  ; is left/right pressed?
                bne.s   Obj01_Traction                  ; if yes, branch
                move.w  inertia(a0),d0                  ; get Sonic's current ground speed
                beq.s   Obj01_Traction                  ; is he standing still? if yes, branch
                bmi.s   Obj01_SettleLeft                ; is he moving to the left? if yes, branch

; slow down when facing right and not pressing a direction
; Obj01_SettleRight:
                sub.w   d5,d0                           ; reduce current rightward speed by acceleration
                bcc.s   +                               ; if result is still to the right, branch
                move.w  #0,d0                           ; reset speed to zero on sign change
+
                move.w  d0,inertia(a0)                  ; set Sonic's new ground speed
                bra.s   Obj01_Traction                  ; skip over
; ---------------------------------------------------------------------------
; slow down when facing left and not pressing a direction
; loc_1A624:
Obj01_SettleLeft:
                add.w   d5,d0                           ; reduce current leftward speed by acceleration
                bcc.s   +                               ; if result is still to the left, branch
                move.w  #0,d0                           ; reset speed to zero on sign change
+
                move.w  d0,inertia(a0)                  ; set Sonic's new ground speed

; increase or decrease speed on the ground
; loc_1A630:
Obj01_Traction:
                move.b  angle(a0),d0                    ; get Sonic's current angle in relation to the floor
                jsr     (CalcSine).l                    ; get sine and cosine values based on angle
                muls.w  inertia(a0),d1                  ; multiply cosine value by current ground speed
                asr.l   #8,d1                           ; shift result up a byte
                move.w  d1,x_vel(a0)                    ; set new X-velocity
                muls.w  inertia(a0),d0                  ; multiply sine value by current ground spee
                asr.l   #8,d0                           ; shift result up a byte
                move.w  d0,y_vel(a0)                    ; set new Y-velocity

; stops Sonic from running through walls that meet the ground
; loc_1A64E:
Obj01_CheckWallsOnGround:
                move.b  angle(a0),d0                    ; get Sonic's current angle in relation to the floor
                addi.b  #$40,d0                         ; rotate it by 90 degrees
                bmi.s   GamePlayerSonicGroundMovement_Return  ; if Sonic is upside down, branch (to prevent potential collision issues with loops)
                move.b  #$40,d1                         ; Rotate 90 degrees clockwise
                tst.w   inertia(a0)                     ; Check inertia
                beq.s   GamePlayerSonicGroundMovement_Return  ; If not moving, don't do anything
                bmi.s   +                               ; If negative, branch
                neg.w   d1                              ; Otherwise, we want to rotate counterclockwise
+
                move.b  angle(a0),d0                    ; get Sonic's current angle in relation to the floor
                add.b   d1,d0                           ; rotate it by 90 degrees depending on directional speed
                move.w  d0,-(sp)                        ; backup d0
                bsr.w   CalcRoomInFront                 ; calculate distance to the wall in front of Sonic (if any)
                move.w  (sp)+,d0                        ; restore d0
                tst.w   d1                              ; has Sonic touched a wall?
                bpl.s   GamePlayerSonicGroundMovement_Return  ; if not, branch
                asl.w   #8,d1                           ; convert diff to wall into 8.8 fixed point for adjusting velocity
                addi.b  #$20,d0                         ; rotate angle by 45 degrees clockwise
                andi.b  #$C0,d0                         ; snap angle to nearest multiple of 90 degrees
                beq.s   loc_1A6BA                       ; if Sonic is facing down, branch
                cmpi.b  #$40,d0                         ; is Sonic facing left?
                beq.s   loc_1A6A8                       ; if yes, branch
                cmpi.b  #$80,d0                         ; is Sonic facing up?
                beq.s   loc_1A6A2                       ; if yes, branch
; d0 is $C0, Sonic is facing right
                add.w   d1,x_vel(a0)                    ; adjust X-velocity to prevent Sonic from walking into the wall
                bset    #status.player.pushing,status(a0)  ; set pushing flag
                move.w  #0,inertia(a0)                  ; clear ground speed
                rts
; ---------------------------------------------------------------------------
loc_1A6A2:                                              ; d0 is $80, Sonic is facing up
                sub.w   d1,y_vel(a0)                    ; adjust Y-velocity to prevent Sonic from walking into the ceiling
                rts
; ---------------------------------------------------------------------------
loc_1A6A8:                                              ; d0 is $40, Sonic is facing left
                sub.w   d1,x_vel(a0)                    ; adjust X-velocity to prevent Sonic from walking into the wall
                bset    #status.player.pushing,status(a0)  ; set pushing flag
                move.w  #0,inertia(a0)                  ; clear ground speed
                rts
; ---------------------------------------------------------------------------
loc_1A6BA:                                              ; d0 is $00, Sonic is facing down
                add.w   d1,y_vel(a0)                    ; adjust Y-velocity to prevent Sonic from walking into the floor

GamePlayerSonicGroundMovement_Return:
                rts
; End of subroutine Sonic_Move

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A6C0:
Sonic_MoveLeft:
                move.w  inertia(a0),d0                  ; get Sonic's current ground speed
                beq.s   +                               ; is Sonic standing still? if yes, branch
                bpl.s   Sonic_TurnLeft                  ; if Sonic is already moving to the right, branch
+
                bset    #status.player.x_flip,status(a0)  ; set X-flip flag (Sonic is facing left)
                bne.s   +                               ; if he already was facing left, branch
                bclr    #status.player.pushing,status(a0)  ; clear pushing flag
                move.b  #AniIDSonAni_Run,prev_anim(a0)  ; force walking animation to restart if it's already in-progress
+
                sub.w   d5,d0                           ; add acceleration to the left
                move.w  d6,d1                           ; get current top speed
                neg.w   d1                              ; negate it for left-side check
                cmp.w   d1,d0                           ; compare new speed with top speed
                bgt.s   +                               ; if new speed is less than the maximum, branch
                add.w   d5,d0                           ; remove this frame's acceleration change
                cmp.w   d1,d0                           ; compare speed with top speed
                ble.s   +                               ; if speed was already greater than the maximum, branch
                move.w  d1,d0                           ; limit speed on ground going left
+
                move.w  d0,inertia(a0)                  ; set new ground speed
                move.b  #AniIDSonAni_Walk,anim(a0)      ; use walking animation
                rts
; ---------------------------------------------------------------------------
; loc_1A6FA:
Sonic_TurnLeft:
                sub.w   d4,d0                           ; apply deceleration to current speed
                bcc.s   +                               ; if still decelerating, branch
                move.w  #-$80,d0                        ; set minimum speed on sign change
+
                move.w  d0,inertia(a0)                  ; set new ground speed
; These three instructions partially overwrite the inertia value in
; 'd0'! This causes the character to trigger their skidding
; animation at different speeds depending on whether they're going
; right or left. To fix this, make these instructions use 'd1'
; instead
                move.b  angle(a0),d0                    ; get Sonic's current angle (and partially overwrite d0...)
                addi.b  #$20,d0                         ; rotate by 45 degrees clockwise
                andi.b  #$C0,d0                         ; snap to nearest multiple of 90 degrees
                bne.s   GamePlayerSonicGroundMovement_Return_Variant2  ; if Sonic is on a wall or ceiling, prevent stopping animation
                cmpi.w  #$400,d0                        ; has Sonic changed direction while being really fast?
                blt.s   GamePlayerSonicGroundMovement_Return_Variant2  ; if not, don't play skidding animation/sound
                move.b  #AniIDSonAni_Stop,anim(a0)      ; use "stopping" animation
                bclr    #status.player.x_flip,status(a0)  ; clear X-flip flag (Sonic is now facing right)
                move.w  #SndID_Skidding,d0              ; load skidding sound
                jsr     (PlaySound).l                   ; play skidding sound
                cmpi.b  #12,air_left(a0)                ; is Sonic drowning?
                blo.s   GamePlayerSonicGroundMovement_Return_Variant2  ; if yes, branch
                move.b  #6,(Sonic_Dust+routine).w       ; set Obj08's routine to skidding
                move.b  #$15,(Sonic_Dust+mapping_frame).w  ; set skidding dust's frame

GamePlayerSonicGroundMovement_Return_Variant2:
                rts
; End of subroutine Sonic_MoveLeft

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A746:
Sonic_MoveRight:
                move.w  inertia(a0),d0                  ; get Sonic's current ground speed
                bmi.s   Sonic_TurnRight                 ; if Sonic is already moving to the left, branch
                bclr    #status.player.x_flip,status(a0)  ; clear X-flip flag (Sonic is facing right)
                beq.s   +                               ; if he already was facing right, branch
                bclr    #status.player.pushing,status(a0)  ; clear pushing flag
                move.b  #AniIDSonAni_Run,prev_anim(a0)  ; force walking animation to restart if it's already in-progress
+
                add.w   d5,d0                           ; add acceleration to the right
                cmp.w   d6,d0                           ; compare new speed with top speed
                blt.s   +                               ; if new speed is less than the maximum, branch
                sub.w   d5,d0                           ; remove this frame's acceleration change
                cmp.w   d6,d0                           ; compare speed with top speed
                bge.s   +                               ; if speed was already greater than the maximum, branch
                move.w  d6,d0                           ; limit speed on ground going right
+
                move.w  d0,inertia(a0)                  ; set new ground speed
                move.b  #AniIDSonAni_Walk,anim(a0)      ; use walking animation
                rts
; ---------------------------------------------------------------------------
; loc_1A77A:
Sonic_TurnRight:
                add.w   d4,d0                           ; apply deceleration to current speed
                bcc.s   +                               ; if still decelerating, branch
                move.w  #$80,d0                         ; set minimum speed on sign change
+
                move.w  d0,inertia(a0)                  ; set new ground speed
; These three instructions partially overwrite the inertia value in
; 'd0'! This causes the character to trigger their skidding
; animation at different speeds depending on whether they're going
; right or left. To fix this, make these instructions use 'd1'
; instead
                move.b  angle(a0),d0                    ; get Sonic's current angle (and partially overwrite d0...)
                addi.b  #$20,d0                         ; rotate by 45 degrees clockwise
                andi.b  #$C0,d0                         ; snap to nearest multiple of 90 degrees
                bne.s   GamePlayerSonicGroundMovement_Return_Variant3  ; if Sonic is on a wall or ceiling, prevent stopping animation
                cmpi.w  #-$400,d0                       ; has Sonic changed direction while being really fast?
                bgt.s   GamePlayerSonicGroundMovement_Return_Variant3  ; if not, don't play skidding animation/sound
                move.b  #AniIDSonAni_Stop,anim(a0)      ; use "stopping" animation
                bset    #status.player.x_flip,status(a0)  ; set X-flip flag (Sonic is now facing left)
                move.w  #SndID_Skidding,d0              ; load skidding sound
                jsr     (PlaySound).l                   ; play skidding sound
                cmpi.b  #12,air_left(a0)                ; is Sonic drowning?
                blo.s   GamePlayerSonicGroundMovement_Return_Variant3  ; if yes, branch
                move.b  #6,(Sonic_Dust+routine).w       ; set Obj08's routine to skidding
                move.b  #$15,(Sonic_Dust+mapping_frame).w  ; set skidding dust's frame

GamePlayerSonicGroundMovement_Return_Variant3:
                rts
; End of subroutine Sonic_MoveRight

; ---------------------------------------------------------------------------
; Subroutine to change Sonic's speed as he rolls
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1A7C6:
