Tails_DoLevelCollision:
                move.l  #Primary_Collision,(Collision_addr).w
                cmpi.b  #$C,top_solid_bit(a0)
                beq.s   +
                move.l  #Secondary_Collision,(Collision_addr).w
+
                move.b  lrb_solid_bit(a0),d5
                move.w  x_vel(a0),d1
                move.w  y_vel(a0),d2
                jsr     (CalcAngle).l
                subi.b  #$20,d0
                andi.b  #$C0,d0
                cmpi.b  #$40,d0
                beq.w   Tails_HitLeftWall
                cmpi.b  #$80,d0
                beq.w   Tails_HitCeilingAndWalls
                cmpi.b  #$C0,d0
                beq.w   Tails_HitRightWall
                bsr.w   CheckLeftWallDist
                tst.w   d1
                bpl.s   +
                sub.w   d1,x_pos(a0)
                move.w  #0,x_vel(a0)                    ; stop Tails since he hit a wall
+
                bsr.w   CheckRightWallDist
                tst.w   d1
                bpl.s   +
                add.w   d1,x_pos(a0)
                move.w  #0,x_vel(a0)                    ; stop Tails since he hit a wall
+
                bsr.w   Sonic_CheckFloor
                tst.w   d1
                bpl.s   GamePlayerTailsAirCollision_Return
                move.b  y_vel(a0),d2
                addq.b  #8,d2
                neg.b   d2
                cmp.b   d2,d1
                bge.s   +
                cmp.b   d2,d0
                blt.s   GamePlayerTailsAirCollision_Return
+
                add.w   d1,y_pos(a0)
                move.b  d3,angle(a0)
                bsr.w   Tails_ResetOnFloor
                move.b  d3,d0
                addi.b  #$20,d0
                andi.b  #$40,d0
                bne.s   loc_1CA18
                move.b  d3,d0
                addi.b  #$10,d0
                andi.b  #$20,d0
                beq.s   loc_1CA0A
                asr     y_vel(a0)
                bra.s   loc_1CA2C
; ===========================================================================

loc_1CA0A:
                move.w  #0,y_vel(a0)
                move.w  x_vel(a0),inertia(a0)
                rts
; ===========================================================================

loc_1CA18:
                move.w  #0,x_vel(a0)                    ; stop Tails since he hit a wall
                cmpi.w  #$FC0,y_vel(a0)
                ble.s   loc_1CA2C
                move.w  #$FC0,y_vel(a0)

loc_1CA2C:
                move.w  y_vel(a0),inertia(a0)
                tst.b   d3
                bpl.s   GamePlayerTailsAirCollision_Return
                neg.w   inertia(a0)

GamePlayerTailsAirCollision_Return:
                rts
; ===========================================================================
; loc_1CA3C:
Tails_HitLeftWall:
                bsr.w   CheckLeftWallDist
                tst.w   d1
                bpl.s   Tails_HitCeiling                ; branch if distance is positive (not inside wall)
                sub.w   d1,x_pos(a0)
                move.w  #0,x_vel(a0)                    ; stop Tails since he hit a wall
                move.w  y_vel(a0),inertia(a0)
                rts
; ===========================================================================
; loc_1CA56:
Tails_HitCeiling:
                bsr.w   Sonic_CheckCeiling
                tst.w   d1
                bpl.s   Tails_HitFloor                  ; branch if distance is positive (not inside ceiling)
                sub.w   d1,y_pos(a0)
                tst.w   y_vel(a0)
                bpl.s   TailsAirCollision_Return_Variant2
                move.w  #0,y_vel(a0)                    ; stop Tails in y since he hit a ceiling

TailsAirCollision_Return_Variant2:
                rts
; ===========================================================================
; loc_1CA70:
Tails_HitFloor:
                tst.w   y_vel(a0)
                bmi.s   TailsAirCollision_Return_Variant3
                bsr.w   Sonic_CheckFloor
                tst.w   d1
                bpl.s   TailsAirCollision_Return_Variant3
                add.w   d1,y_pos(a0)
                move.b  d3,angle(a0)
                bsr.w   Tails_ResetOnFloor
                move.w  #0,y_vel(a0)
                move.w  x_vel(a0),inertia(a0)

TailsAirCollision_Return_Variant3:
                rts
; ===========================================================================
; loc_1CA98:
Tails_HitCeilingAndWalls:
                bsr.w   CheckLeftWallDist
                tst.w   d1
                bpl.s   +
                sub.w   d1,x_pos(a0)
                move.w  #0,x_vel(a0)                    ; stop Tails since he hit a wall
+
                bsr.w   CheckRightWallDist
                tst.w   d1
                bpl.s   +
                add.w   d1,x_pos(a0)
                move.w  #0,x_vel(a0)                    ; stop Tails since he hit a wall
+
                bsr.w   Sonic_CheckCeiling
                tst.w   d1
                bpl.s   TailsAirCollision_Return_Variant4
                sub.w   d1,y_pos(a0)
                move.b  d3,d0
                addi.b  #$20,d0
                andi.b  #$40,d0
                bne.s   loc_1CADC
                move.w  #0,y_vel(a0)                    ; stop Tails in y since he hit a ceiling
                rts
; ===========================================================================

loc_1CADC:
                move.b  d3,angle(a0)
                bsr.w   Tails_ResetOnFloor
                move.w  y_vel(a0),inertia(a0)
                tst.b   d3
                bpl.s   TailsAirCollision_Return_Variant4
                neg.w   inertia(a0)

TailsAirCollision_Return_Variant4:
                rts
; ===========================================================================
; loc_1CAF4:
Tails_HitRightWall:
                bsr.w   CheckRightWallDist
                tst.w   d1
                bpl.s   Tails_HitCeiling2
                add.w   d1,x_pos(a0)
                move.w  #0,x_vel(a0)                    ; stop Tails since he hit a wall
                move.w  y_vel(a0),inertia(a0)
                rts
; ===========================================================================
; identical to Tails_HitCeiling
; loc_1CB0E:
Tails_HitCeiling2:
                bsr.w   Sonic_CheckCeiling
                tst.w   d1
                bpl.s   Tails_HitFloor2
                sub.w   d1,y_pos(a0)
                tst.w   y_vel(a0)
                bpl.s   TailsAirCollision_Return_Variant5
                move.w  #0,y_vel(a0)                    ; stop Tails in y since he hit a ceiling

TailsAirCollision_Return_Variant5:
                rts
; ===========================================================================
; identical to Tails_HitFloor
; loc_1CB28:
Tails_HitFloor2:
                tst.w   y_vel(a0)
                bmi.s   TailsAirCollision_Return_Variant6
                bsr.w   Sonic_CheckFloor
                tst.w   d1
                bpl.s   TailsAirCollision_Return_Variant6
                add.w   d1,y_pos(a0)
                move.b  d3,angle(a0)
                bsr.w   Tails_ResetOnFloor
                move.w  #0,y_vel(a0)
                move.w  x_vel(a0),inertia(a0)

TailsAirCollision_Return_Variant6:
                rts
; End of function Tails_DoLevelCollision

; ---------------------------------------------------------------------------
; Subroutine to reset Tails' mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1CB50:
Tails_ResetOnFloor:
                tst.b   pinball_mode(a0)
                bne.s   Tails_ResetOnFloor_Part3
                move.b  #AniIDSonAni_Walk,anim(a0)
; loc_1CB5C:
Tails_ResetOnFloor_Part2:
                btst    #status.player.rolling,status(a0)
                beq.s   Tails_ResetOnFloor_Part3
                bclr    #status.player.rolling,status(a0)
                move.b  #$F,y_radius(a0)                ; this slightly increases Tails' collision height to standing
                move.b  #9,x_radius(a0)
                move.b  #AniIDSonAni_Walk,anim(a0)      ; use running/walking/standing animation
                subq.w  #1,y_pos(a0)                    ; move Tails up 1 pixel so the increased height doesn't push him slightly into the ground
; loc_1CB80:
Tails_ResetOnFloor_Part3:
                bclr    #status.player.in_air,status(a0)
                bclr    #status.player.pushing,status(a0)
                bclr    #status.player.rolljumping,status(a0)
                move.b  #0,jumping(a0)
                move.w  #0,(Chain_Bonus_counter).w
+
                move.b  #0,flip_angle(a0)
                move.b  #0,flip_turned(a0)
                move.b  #0,flips_remaining(a0)
                move.w  #0,(Tails_Look_delay_counter).w
                cmpi.b  #AniIDSonAni_Hang2,anim(a0)
                bne.s   TailsAirCollision_Return_Variant7
                move.b  #AniIDSonAni_Walk,anim(a0)

TailsAirCollision_Return_Variant7:
                rts
; End of subroutine Tails_ResetOnFloor

; ===========================================================================
; ---------------------------------------------------------------------------
; Tails when he gets hurt
; ---------------------------------------------------------------------------
; loc_1CBC6:
