Tails_Move:
                move.w  (Tails_top_speed).w,d6
                move.w  (Tails_acceleration).w,d5
                move.w  (Tails_deceleration).w,d4
                _btst   #status_secondary.sliding,status_secondary(a0)
                _bne.w  Obj02_Traction
                tst.w   move_lock(a0)
                bne.w   Obj02_ResetScr
                btst    #button_left,(Ctrl_2_Held_Logical).w  ; is left being pressed?
                beq.s   Obj02_NotLeft                   ; if not, branch
                bsr.w   Tails_MoveLeft
; loc_1C0D4:
Obj02_NotLeft:
                btst    #button_right,(Ctrl_2_Held_Logical).w  ; is right being pressed?
                beq.s   Obj02_NotRight                  ; if not, branch
                bsr.w   Tails_MoveRight
; loc_1C0E0:
Obj02_NotRight:
                move.b  angle(a0),d0
                addi.b  #$20,d0
                andi.b  #$C0,d0                         ; is Tails on a slope?
                bne.w   Obj02_ResetScr                  ; if yes, branch
                tst.w   inertia(a0)                     ; is Tails moving?
                bne.w   Obj02_ResetScr                  ; if yes, branch
                bclr    #status.player.pushing,status(a0)
                move.b  #AniIDSonAni_Wait,anim(a0)      ; use "standing" animation
                btst    #status.player.on_object,status(a0)
                beq.s   Tails_Balance
                moveq   #0,d0
                move.b  interact(a0),d0
                if      object_size=$40
                lsl.w   #object_size_bits,d0
                else
                mulu.w  #object_size,d0
                endif
                lea     (Object_RAM).w,a1               ; a1=character
                lea     (a1,d0.w),a1                    ; a1=object
                _btst   #status.npc.no_balancing,status(a1)
                _bne.s  Tails_Lookup
                moveq   #0,d1
                move.b  width_pixels(a1),d1
                move.w  d1,d2
                add.w   d2,d2
                subq.w  #4,d2
                add.w   x_pos(a0),d1
                sub.w   x_pos(a1),d1
                cmpi.w  #4,d1
                blt.s   Tails_BalanceOnObjLeft
                cmp.w   d2,d1
                bge.s   Tails_BalanceOnObjRight
                bra.s   Tails_Lookup
; ---------------------------------------------------------------------------
; balancing checks for Tails
; loc_1C142:
Tails_Balance:
                jsr     (ChkFloorEdge).l
                cmpi.w  #$C,d1
                blt.s   Tails_Lookup
                cmpi.b  #3,next_tilt(a0)
                bne.s   Tails_BalanceLeft
; loc_1C156:
Tails_BalanceOnObjRight:
                bclr    #status.player.x_flip,status(a0)
                bra.s   Tails_BalanceDone
; ---------------------------------------------------------------------------
; loc_1C15E:
Tails_BalanceLeft:
                cmpi.b  #3,tilt(a0)
                bne.s   Tails_Lookup
; loc_1C166:
Tails_BalanceOnObjLeft:
                bset    #status.player.x_flip,status(a0)
; loc_1C16C:
Tails_BalanceDone:
                move.b  #AniIDSonAni_Balance,anim(a0)
                bra.s   Obj02_ResetScr
; ---------------------------------------------------------------------------
; loc_1C174:
Tails_Lookup:
                btst    #button_up,(Ctrl_2_Held_Logical).w  ; is up being pressed?
                beq.s   Tails_Duck                      ; if not, branch
                move.b  #AniIDSonAni_LookUp,anim(a0)    ; use "looking up" animation
                addq.w  #1,(Tails_Look_delay_counter).w
                cmpi.w  #$78,(Tails_Look_delay_counter).w
                blo.s   Obj02_ResetScr_Part2
                move.w  #$78,(Tails_Look_delay_counter).w
                cmpi.w  #$C8,(Camera_Y_pos_bias_P2).w
                beq.s   Obj02_UpdateSpeedOnGround
                addq.w  #2,(Camera_Y_pos_bias_P2).w
                bra.s   Obj02_UpdateSpeedOnGround
; ---------------------------------------------------------------------------
; loc_1C1A2:
Tails_Duck:
                btst    #button_down,(Ctrl_2_Held_Logical).w  ; is down being pressed?
                beq.s   Obj02_ResetScr                  ; if not, branch
                move.b  #AniIDSonAni_Duck,anim(a0)      ; use "ducking" animation
                addq.w  #1,(Tails_Look_delay_counter).w
                cmpi.w  #$78,(Tails_Look_delay_counter).w
                blo.s   Obj02_ResetScr_Part2
                move.w  #$78,(Tails_Look_delay_counter).w
                cmpi.w  #8,(Camera_Y_pos_bias_P2).w
                beq.s   Obj02_UpdateSpeedOnGround
                subq.w  #2,(Camera_Y_pos_bias_P2).w
                bra.s   Obj02_UpdateSpeedOnGround

; ===========================================================================
; moves the screen back to its normal position after looking up or down
; loc_1C1D0:
Obj02_ResetScr:
                move.w  #0,(Tails_Look_delay_counter).w
; loc_1C1D6:
Obj02_ResetScr_Part2:
                cmpi.w  #(screen_height/2)-16,(Camera_Y_pos_bias_P2).w  ; is screen in its default position?
                beq.s   Obj02_UpdateSpeedOnGround       ; if yes, branch
                bhs.s   +                               ; depending on the sign of the difference,
                addq.w  #4,(Camera_Y_pos_bias_P2).w     ; either add 2
+               subq.w  #2,(Camera_Y_pos_bias_P2).w     ; or subtract 2

; ---------------------------------------------------------------------------
; updates Tails' speed on the ground
; ---------------------------------------------------------------------------
; loc_1C1E8:
Obj02_UpdateSpeedOnGround:
                move.b  (Ctrl_2_Held_Logical).w,d0
                andi.b  #button_left_mask|button_right_mask,d0  ; is left/right pressed?
                bne.s   Obj02_Traction                  ; if yes, branch
                move.w  inertia(a0),d0
                beq.s   Obj02_Traction
                bmi.s   Obj02_SettleLeft

; slow down when facing right and not pressing a direction
; Obj02_SettleRight:
                sub.w   d5,d0
                bcc.s   +
                move.w  #0,d0
+
                move.w  d0,inertia(a0)
                bra.s   Obj02_Traction
; ---------------------------------------------------------------------------
; slow down when facing left and not pressing a direction
; loc_1C208:
Obj02_SettleLeft:
                add.w   d5,d0
                bcc.s   +
                move.w  #0,d0
+
                move.w  d0,inertia(a0)

; increase or decrease speed on the ground
; loc_1C214:
Obj02_Traction:
                move.b  angle(a0),d0
                jsr     (CalcSine).l
                muls.w  inertia(a0),d1
                asr.l   #8,d1
                move.w  d1,x_vel(a0)
                muls.w  inertia(a0),d0
                asr.l   #8,d0
                move.w  d0,y_vel(a0)

; stops Tails from running through walls that meet the ground
; loc_1C232:
Obj02_CheckWallsOnGround:
                move.b  angle(a0),d0
                addi.b  #$40,d0
                bmi.s   GamePlayerTailsGroundMovement_Return
                move.b  #$40,d1
                tst.w   inertia(a0)
                beq.s   GamePlayerTailsGroundMovement_Return
                bmi.s   +
                neg.w   d1
+
                move.b  angle(a0),d0
                add.b   d1,d0
                move.w  d0,-(sp)
                bsr.w   CalcRoomInFront
                move.w  (sp)+,d0
                tst.w   d1
                bpl.s   GamePlayerTailsGroundMovement_Return
                asl.w   #8,d1
                addi.b  #$20,d0
                andi.b  #$C0,d0
                beq.s   loc_1C29E
                cmpi.b  #$40,d0
                beq.s   loc_1C28C
                cmpi.b  #$80,d0
                beq.s   loc_1C286
                add.w   d1,x_vel(a0)
                bset    #status.player.pushing,status(a0)
                move.w  #0,inertia(a0)
                rts
; ---------------------------------------------------------------------------

loc_1C286:
                sub.w   d1,y_vel(a0)
                rts
; ---------------------------------------------------------------------------

loc_1C28C:
                sub.w   d1,x_vel(a0)
                bset    #status.player.pushing,status(a0)
                move.w  #0,inertia(a0)
                rts
; ---------------------------------------------------------------------------
loc_1C29E:
                add.w   d1,y_vel(a0)

GamePlayerTailsGroundMovement_Return:
                rts
; End of subroutine Tails_Move

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C2A4:
Tails_MoveLeft:
                move.w  inertia(a0),d0
                beq.s   +
                bpl.s   Tails_TurnLeft                  ; if Tails is already moving to the right, branch
+
                bset    #status.player.x_flip,status(a0)
                bne.s   +
                bclr    #status.player.pushing,status(a0)
                move.b  #AniIDSonAni_Run,prev_anim(a0)  ; force walking animation to restart if it's already in-progress
+
                sub.w   d5,d0                           ; add acceleration to the left
                move.w  d6,d1
                neg.w   d1
                cmp.w   d1,d0                           ; compare new speed with top speed
                bgt.s   +                               ; if new speed is less than the maximum, branch
                add.w   d5,d0                           ; remove this frame's acceleration change
                cmp.w   d1,d0                           ; compare speed with top speed
                ble.s   +                               ; if speed was already greater than the maximum, branch
                move.w  d1,d0                           ; limit speed on ground going left
+
                move.w  d0,inertia(a0)
                move.b  #AniIDSonAni_Walk,anim(a0)      ; use walking animation
                rts
; ---------------------------------------------------------------------------
; loc_1C2DE:
Tails_TurnLeft:
                sub.w   d4,d0
                bcc.s   +
                move.w  #-$80,d0
+
                move.w  d0,inertia(a0)
; These three instructions partially overwrite the inertia value in
; 'd0'! This causes the character to trigger their skidding
; animation at different speeds depending on whether they're going
; right or left. To fix this, make these instructions use 'd1'
; instead
                move.b  angle(a0),d0
                addi.b  #$20,d0
                andi.b  #$C0,d0
                bne.s   GamePlayerTailsGroundMovement_Return_Variant2
                cmpi.w  #$400,d0
                blt.s   GamePlayerTailsGroundMovement_Return_Variant2
                move.b  #AniIDSonAni_Stop,anim(a0)      ; use "stopping" animation
                bclr    #status.player.x_flip,status(a0)
                move.w  #SndID_Skidding,d0
                jsr     (PlaySound).l
                cmpi.b  #12,air_left(a0)
                blo.s   GamePlayerTailsGroundMovement_Return_Variant2                    ; if he's drowning, branch to not make dust
                move.b  #6,(Tails_Dust+routine).w
                move.b  #$15,(Tails_Dust+mapping_frame).w

GamePlayerTailsGroundMovement_Return_Variant2:
                rts
; End of subroutine Tails_MoveLeft

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C32A:
Tails_MoveRight:
                move.w  inertia(a0),d0
                bmi.s   Tails_TurnRight
                bclr    #status.player.x_flip,status(a0)
                beq.s   +
                bclr    #status.player.pushing,status(a0)
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
                move.w  d0,inertia(a0)
                move.b  #AniIDSonAni_Walk,anim(a0)      ; use walking animation
                rts
; ---------------------------------------------------------------------------
; loc_1C35E:
Tails_TurnRight:
                add.w   d4,d0
                bcc.s   +
                move.w  #$80,d0
+
                move.w  d0,inertia(a0)
; These three instructions partially overwrite the inertia value in
; 'd0'! This causes the character to trigger their skidding
; animation at different speeds depending on whether they're going
; right or left. To fix this, make these instructions use 'd1'
; instead
                move.b  angle(a0),d0
                addi.b  #$20,d0
                andi.b  #$C0,d0
                bne.s   GamePlayerTailsGroundMovement_Return_Variant3
                cmpi.w  #-$400,d0
                bgt.s   GamePlayerTailsGroundMovement_Return_Variant3
                move.b  #AniIDSonAni_Stop,anim(a0)      ; use "stopping" animation
                bset    #status.player.x_flip,status(a0)
                move.w  #SndID_Skidding,d0              ; use "stopping" sound
                jsr     (PlaySound).l
                cmpi.b  #12,air_left(a0)
                blo.s   GamePlayerTailsGroundMovement_Return_Variant3                    ; if he's drowning, branch to not make dust
                move.b  #6,(Tails_Dust+routine).w
                move.b  #$15,(Tails_Dust+mapping_frame).w

GamePlayerTailsGroundMovement_Return_Variant3:
                rts
; End of subroutine Tails_MoveRight

; ---------------------------------------------------------------------------
; Subroutine to change Tails' speed as he rolls
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C3AA:
