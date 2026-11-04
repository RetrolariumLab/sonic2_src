Tails_CheckSpindash:
                tst.b   spindash_flag(a0)
                bne.s   Tails_UpdateSpindash
                cmpi.b  #AniIDSonAni_Duck,anim(a0)
                bne.s   GamePlayerTailsSpindashAndSlopes_Return
                move.b  (Ctrl_2_Press_Logical).w,d0
                andi.b  #button_B_mask|button_C_mask|button_A_mask,d0
                beq.w   GamePlayerTailsSpindashAndSlopes_Return
                move.b  #AniIDSonAni_Spindash,anim(a0)
                move.w  #SndID_SpindashRev,d0
                jsr     (PlaySound).l
                addq.l  #4,sp
                move.b  #1,spindash_flag(a0)
                move.w  #0,spindash_counter(a0)
                cmpi.b  #12,air_left(a0)                ; if he's drowning, branch to not make dust
                blo.s   loc_1C754
                move.b  #2,(Tails_Dust+anim).w

loc_1C754:
                bsr.w   Tails_LevelBound
                bsr.w   AnglePos

GamePlayerTailsSpindashAndSlopes_Return:
                rts
; End of subroutine Tails_CheckSpindash

; ---------------------------------------------------------------------------
; Subrouting to update an already-charging spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C75E:
Tails_UpdateSpindash:
                move.b  (Ctrl_2_Held_Logical).w,d0
                btst    #button_down,d0
                bne.s   Tails_ChargingSpindash

; unleash the charged spindash and start rolling quickly:
                move.b  #$E,y_radius(a0)
                move.b  #7,x_radius(a0)
                move.b  #AniIDSonAni_Roll,anim(a0)
                addq.w  #1,y_pos(a0)                    ; add the difference between Tails' rolling and standing heights
                move.b  #0,spindash_flag(a0)
                moveq   #0,d0
                move.b  spindash_counter(a0),d0
                add.w   d0,d0
                move.w  Tails_SpindashSpeeds(pc,d0.w),inertia(a0)

; Determine how long to lag the camera for
; Notably, the faster Tails goes, the less the camera lags
; This is seemingly to prevent Tails from going off-screen
                move.w  inertia(a0),d0
                subi.w  #$800,d0                        ; $800 is the lowest spin dash speed
                add.w   d0,d0
                andi.w  #$1F00,d0                       ; This line is not necessary, as none of the removed bits are ever set in the first place
                neg.w   d0
                addi.w  #$2000,d0
                move.w  d0,(Horiz_scroll_delay_val_P2).w

                btst    #status.player.x_flip,status(a0)
                beq.s   +
                neg.w   inertia(a0)
+
                bset    #status.player.rolling,status(a0)
                move.b  #0,(Tails_Dust+anim).w
                move.w  #SndID_SpindashRelease,d0       ; spindash zoom sound
                jsr     (PlaySound).l
                bra.s   loc_1C828
; ===========================================================================
; word_1C7CE:
Tails_SpindashSpeeds:
                dc.w    $800                            ; 0
                dc.w    $880                            ; 1
                dc.w    $900                            ; 2
                dc.w    $980                            ; 3
                dc.w    $A00                            ; 4
                dc.w    $A80                            ; 5
                dc.w    $B00                            ; 6
                dc.w    $B80                            ; 7
                dc.w    $C00                            ; 8
; ===========================================================================
; loc_1C7E0:
Tails_ChargingSpindash:                                 ; If still charging the dash
                tst.w   spindash_counter(a0)
                beq.s   loc_1C7F8
                move.w  spindash_counter(a0),d0
                lsr.w   #5,d0
                sub.w   d0,spindash_counter(a0)
                bcc.s   loc_1C7F8
                move.w  #0,spindash_counter(a0)

loc_1C7F8:
                move.b  (Ctrl_2_Press_Logical).w,d0
                andi.b  #button_B_mask|button_C_mask|button_A_mask,d0
                beq.w   loc_1C828
                move.w  #(AniIDSonAni_Spindash<<8)|(AniIDSonAni_Walk<<0),anim(a0)
                move.w  #SndID_SpindashRev,d0
                jsr     (PlaySound).l
                addi.w  #$200,spindash_counter(a0)
                cmpi.w  #$800,spindash_counter(a0)
                blo.s   loc_1C828
                move.w  #$800,spindash_counter(a0)

loc_1C828:
                addq.l  #4,sp
                cmpi.w  #(screen_height/2)-16,(Camera_Y_pos_bias_P2).w
                beq.s   loc_1C83C
                bhs.s   +
                addq.w  #4,(Camera_Y_pos_bias_P2).w
+               subq.w  #2,(Camera_Y_pos_bias_P2).w

loc_1C83C:
                bsr.w   Tails_LevelBound
                bsr.w   AnglePos
                rts
; End of subroutine Tails_UpdateSpindash

; ---------------------------------------------------------------------------
; Subroutine to slow Tails walking up a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C846:
Tails_SlopeResist:
                move.b  angle(a0),d0
                addi.b  #$60,d0
                cmpi.b  #$C0,d0
                bhs.s   TailsSpindashSlopes_Return_Variant2
                move.b  angle(a0),d0
                jsr     (CalcSine).l
                muls.w  #$20,d0
                asr.l   #8,d0
                tst.w   inertia(a0)
                beq.s   TailsSpindashSlopes_Return_Variant2
                bmi.s   loc_1C876
                tst.w   d0
                beq.s   +
                add.w   d0,inertia(a0)                  ; change Tails' $14
+
                rts
; ---------------------------------------------------------------------------

loc_1C876:
                add.w   d0,inertia(a0)

TailsSpindashSlopes_Return_Variant2:
                rts
; End of subroutine Tails_SlopeResist

; ---------------------------------------------------------------------------
; Subroutine to push Tails down a slope while he's rolling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C87C:
Tails_RollRepel:
                move.b  angle(a0),d0
                addi.b  #$60,d0
                cmpi.b  #-$40,d0
                bhs.s   TailsSpindashSlopes_Return_Variant3
                move.b  angle(a0),d0
                jsr     (CalcSine).l
                muls.w  #$50,d0
                asr.l   #8,d0
                tst.w   inertia(a0)
                bmi.s   loc_1C8AC
                tst.w   d0
                bpl.s   loc_1C8A6
                asr.l   #2,d0

loc_1C8A6:
                add.w   d0,inertia(a0)
                rts
; ===========================================================================

loc_1C8AC:
                tst.w   d0
                bmi.s   loc_1C8B2
                asr.l   #2,d0

loc_1C8B2:
                add.w   d0,inertia(a0)

TailsSpindashSlopes_Return_Variant3:
                rts
; End of function Tails_RollRepel

; ---------------------------------------------------------------------------
; Subroutine to push Tails down a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C8B8:
Tails_SlopeRepel:
                nop
                tst.b   stick_to_convex(a0)
                bne.s   TailsSpindashSlopes_Return_Variant4
                tst.w   move_lock(a0)
                bne.s   loc_1C8F4
                move.b  angle(a0),d0
                addi.b  #$20,d0
                andi.b  #$C0,d0
                beq.s   TailsSpindashSlopes_Return_Variant4
                mvabs.w inertia(a0),d0
                cmpi.w  #$280,d0
                bhs.s   TailsSpindashSlopes_Return_Variant4
                clr.w   inertia(a0)
                bset    #status.player.in_air,status(a0)
                move.w  #$1E,move_lock(a0)

TailsSpindashSlopes_Return_Variant4:
                rts
; ===========================================================================

loc_1C8F4:
                subq.w  #1,move_lock(a0)
                rts
; End of function Tails_SlopeRepel

; ---------------------------------------------------------------------------
; Subroutine to return Tails' angle to 0 as he jumps
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C8FA:
Tails_JumpAngle:
                move.b  angle(a0),d0                    ; get Tails' angle
                beq.s   Tails_JumpFlip                  ; if already 0, branch
                bpl.s   loc_1C90A                       ; if higher than 0, branch

                addq.b  #2,d0                           ; increase angle
                bcc.s   BranchTo_Tails_JumpAngleSet
                moveq   #0,d0

BranchTo_Tails_JumpAngleSet                             ; BranchTo
                bra.s   Tails_JumpAngleSet
; ===========================================================================

loc_1C90A:
                subq.b  #2,d0                           ; decrease angle
                bcc.s   Tails_JumpAngleSet
                moveq   #0,d0

; loc_1C910:
Tails_JumpAngleSet:
                move.b  d0,angle(a0)
; End of function Tails_JumpAngle
; continue straight to Tails_JumpFlip

; ---------------------------------------------------------------------------
; Updates Tails' secondary angle if he's tumbling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C914:
Tails_JumpFlip:
                move.b  flip_angle(a0),d0
                beq.s   TailsSpindashSlopes_Return_Variant5
                tst.w   inertia(a0)
                bmi.s   Tails_JumpLeftFlip
; loc_1C920:
Tails_JumpRightFlip:
                move.b  flip_speed(a0),d1
                add.b   d1,d0
                bcc.s   BranchTo_Tails_JumpFlipSet
                subq.b  #1,flips_remaining(a0)
                bcc.s   BranchTo_Tails_JumpFlipSet
                move.b  #0,flips_remaining(a0)
                moveq   #0,d0

BranchTo_Tails_JumpFlipSet                              ; BranchTo
                bra.s   Tails_JumpFlipSet
; ===========================================================================
; loc_1C938:
Tails_JumpLeftFlip:
                tst.b   flip_turned(a0)
                bne.s   Tails_JumpRightFlip
                move.b  flip_speed(a0),d1
                sub.b   d1,d0
                bcc.s   Tails_JumpFlipSet
                subq.b  #1,flips_remaining(a0)
                bcc.s   Tails_JumpFlipSet
                move.b  #0,flips_remaining(a0)
                moveq   #0,d0
; loc_1C954:
Tails_JumpFlipSet:
                move.b  d0,flip_angle(a0)

TailsSpindashSlopes_Return_Variant5:
                rts
; End of function Tails_JumpFlip

; ---------------------------------------------------------------------------
; Subroutine for Tails to interact with the floor and walls when he's in the air
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1C95A: Tails_Floor:
