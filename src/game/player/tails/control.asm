Obj02:
; a0=character
                cmpi.w  #2,(Player_mode).w
                bne.s   +
                move.w  (Camera_Min_X_pos).w,(Tails_Min_X_pos).w
                move.w  (Camera_Max_X_pos).w,(Tails_Max_X_pos).w
                move.w  (Camera_Max_Y_pos).w,(Tails_Max_Y_pos).w
+
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj02_Index(pc,d0.w),d1
                jmp     Obj02_Index(pc,d1.w)
; ===========================================================================
; off_1B8CC: Obj02_States:
Obj02_Index:    offsetTable
                offsetTableEntry.w Obj02_Init           ; 0
                offsetTableEntry.w Obj02_Control        ; 2
                offsetTableEntry.w Obj02_Hurt           ; 4
                offsetTableEntry.w Obj02_Dead           ; 6
                offsetTableEntry.w Obj02_Gone           ; 8
                offsetTableEntry.w Obj02_Respawning     ; $A
; ===========================================================================
; loc_1B8D8: Obj02_Main:
Obj02_Init:
                addq.b  #2,routine(a0)                  ; => Obj02_Normal
                move.b  #$F,y_radius(a0)                ; this sets Tails' collision height (2*pixels) to less than Sonic's height
                move.b  #9,x_radius(a0)
                move.l  #MapUnc_Tails,mappings(a0)
                move.b  #2,priority(a0)
                move.b  #$18,width_pixels(a0)
                move.b  #1<<render_flags.on_screen|1<<render_flags.level_fg,render_flags(a0)  ; render_flags(Tails) = $80 | initial render_flags(Sonic)
                move.w  #$600,(Tails_top_speed).w       ; set Tails' top speed
                move.w  #$C,(Tails_acceleration).w      ; set Tails' acceleration
                move.w  #$80,(Tails_deceleration).w     ; set Tails' deceleration
                cmpi.w  #2,(Player_mode).w
                bne.s   Obj02_Init_2Pmode
                tst.b   (Last_star_pole_hit).w
                bne.s   Obj02_Init_Continued
; only happens when not starting at a checkpoint:
                move.w  #make_art_tile(ArtTile_ArtUnc_Tails,0,0),art_tile(a0)
                bsr.w   Adjust2PArtPointer
                move.b  #$C,top_solid_bit(a0)
                move.b  #$D,lrb_solid_bit(a0)
                move.w  x_pos(a0),(Saved_x_pos).w
                move.w  y_pos(a0),(Saved_y_pos).w
                move.w  art_tile(a0),(Saved_art_tile).w
                move.w  top_solid_bit(a0),(Saved_Solid_bits).w
                bra.s   Obj02_Init_Continued
; ===========================================================================
; loc_1B952:
Obj02_Init_2Pmode:
                move.w  #make_art_tile(ArtTile_ArtUnc_Tails,0,0),art_tile(a0)
                bsr.w   Adjust2PArtPointer
                move.w  (MainCharacter+top_solid_bit).w,top_solid_bit(a0)
                tst.w   (MainCharacter+art_tile).w
                bpl.s   Obj02_Init_Continued
                ori.w   #high_priority,art_tile(a0)
; loc_1B96E:
Obj02_Init_Continued:
                move.w  x_pos(a0),(Saved_x_pos_2P).w
                move.w  y_pos(a0),(Saved_y_pos_2P).w
                move.w  art_tile(a0),(Saved_art_tile_2P).w
                move.w  top_solid_bit(a0),(Saved_Solid_bits_2P).w
                move.b  #0,flips_remaining(a0)
                move.b  #4,flip_speed(a0)
                move.b  #30,air_left(a0)
                move.w  #0,(Tails_CPU_routine).w        ; set AI state to TailsCPU_Init
                move.w  #0,(Tails_control_counter).w
                move.w  #0,(Tails_respawn_counter).w
                move.b  #ObjID_TailsTails,(Tails_Tails+id).w  ; load Obj05 (Tails' Tails) at $FFFFD000
                move.w  a0,(Tails_Tails+parent).w       ; set its parent object to this

; ---------------------------------------------------------------------------
; Normal state for Tails
; ---------------------------------------------------------------------------
; loc_1B9B4:
Obj02_Control:
                cmpa.w  #MainCharacter,a0
                bne.s   Obj02_Control_Joypad2
                move.w  (Ctrl_1_Logical).w,(Ctrl_2_Logical).w
                tst.b   (Control_Locked).w              ; are controls locked?
                bne.s   Obj02_Control_Part2             ; if yes, branch
                move.w  (Ctrl_1).w,(Ctrl_2_Logical).w   ; copy new held buttons, to enable joypad control
                move.w  (Ctrl_1).w,(Ctrl_1_Logical).w
                bra.s   Obj02_Control_Part2
; ---------------------------------------------------------------------------
; loc_1B9D4:
Obj02_Control_Joypad2:
                tst.b   (Control_Locked_P2).w
                bne.s   +
                move.w  (Ctrl_2).w,(Ctrl_2_Logical).w
+
                tst.w   (Two_player_mode).w
                bne.s   Obj02_Control_Part2
                bsr.w   TailsCPU_Control
; loc_1B9EA:
Obj02_Control_Part2:
                btst    #0,obj_control(a0)              ; is Tails flying, or interacting with another object that holds him in place or controls his movement somehow?
                bne.s   +                               ; if yes, branch to skip Tails' control
                moveq   #0,d0
                move.b  status(a0),d0
                andi.w  #1<<status.player.in_air|1<<status.player.rolling,d0  ; %0000 %0110
                move.w  Obj02_Modes(pc,d0.w),d1
                jsr     Obj02_Modes(pc,d1.w)            ; run Tails' movement control code
+
                cmpi.w  #-$100,(Camera_Min_Y_pos).w     ; is vertical wrapping enabled?
                bne.s   +                               ; if not, branch
                andi.w  #$7FF,y_pos(a0)                 ; perform wrapping of Sonic's y position
+
                bsr.s   Tails_Display
                bsr.w   Tails_RecordPos
                bsr.w   Tails_Water
                move.b  (Primary_Angle).w,next_tilt(a0)
                move.b  (Secondary_Angle).w,tilt(a0)
                tst.b   (WindTunnel_flag).w
                beq.s   +
                tst.b   anim(a0)
                bne.s   +
                move.b  prev_anim(a0),anim(a0)
+
                bsr.w   Tails_Animate
                tst.b   obj_control(a0)
                bmi.s   +
                jsr     (TouchResponse).l
+
                bra.w   LoadTailsDynPLC

; ===========================================================================
; secondary states under state Obj02_Normal
; off_1BA4E:
Obj02_Modes:    offsetTable
                offsetTableEntry.w Obj02_MdNormal       ; 0 - not airborne or rolling
                offsetTableEntry.w Obj02_MdAir          ; 2 - airborne
                offsetTableEntry.w Obj02_MdRoll         ; 4 - rolling
                offsetTableEntry.w Obj02_MdJump         ; 6 - jumping
; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1BA56:
Tails_Display:
                move.w  invulnerable_time(a0),d0
                beq.s   Obj02_Display
                subq.w  #1,invulnerable_time(a0)
                lsr.w   #3,d0
                bcc.s   Obj02_ChkInvinc
; loc_1BA64:
Obj02_Display:
                jsr     (DisplaySprite).l
; loc_1BA6A:
Obj02_ChkInvinc:                                        ; Checks if invincibility has expired and disables it if it has
                btst    #status_secondary.invincible,status_secondary(a0)
                beq.s   Obj02_ChkShoes
                tst.w   invincibility_time(a0)
                beq.s   Obj02_ChkShoes
                subq.w  #1,invincibility_time(a0)
                bne.s   Obj02_ChkShoes
                tst.b   (Current_Boss_ID).w             ; Don't change music if in a boss fight
                bne.s   Obj02_RmvInvin
                cmpi.b  #12,air_left(a0)                ; Don't change music if drowning
                blo.s   Obj02_RmvInvin
                move.w  (Level_Music).w,d0
                jsr     (PlayMusic).l
; loc_1BA96:
Obj02_RmvInvin:
                bclr    #status_secondary.invincible,status_secondary(a0)
; loc_1BA9C:
Obj02_ChkShoes:                                         ; Checks if Speed Shoes have expired and disables them if they have
                btst    #status_secondary.speed_shoes,status_secondary(a0)
                beq.s   Obj02_ExitChk
                tst.w   speedshoes_time(a0)
                beq.s   Obj02_ExitChk
                subq.w  #1,speedshoes_time(a0)
                bne.s   Obj02_ExitChk
                move.w  #$600,(Tails_top_speed).w
                move.w  #$C,(Tails_acceleration).w
                move.w  #$80,(Tails_deceleration).w
; Obj02_RmvSpeed:
                bclr    #status_secondary.speed_shoes,status_secondary(a0)
                move.w  #MusID_SlowDown,d0              ; Slow down tempo
                jmp     (PlayMusic).l
; ===========================================================================
; return_1BAD2:
Obj02_ExitChk:
                rts
; End of subroutine Tails_Display

; ---------------------------------------------------------------------------
; Tails' AI code for the Sonic and Tails mode 1-player game
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1BAD4:
