Obj01_Hurt:
                tst.w   (Debug_mode_flag).w
                beq.s   Obj01_Hurt_Normal
                btst    #button_B,(Ctrl_1_Press).w
                beq.s   Obj01_Hurt_Normal
                move.w  #1,(Debug_placement_mode).w
                clr.b   (Control_Locked).w
                rts
; ---------------------------------------------------------------------------
; loc_1B13A:
Obj01_Hurt_Normal:
                tst.b   routine_secondary(a0)
                bmi.w   Sonic_HurtInstantRecover
                jsr     (ObjectMove).l
                addi.w  #$30,y_vel(a0)
                btst    #status.player.underwater,status(a0)
                beq.s   +
                subi.w  #$20,y_vel(a0)
+
                cmpi.w  #-$100,(Camera_Min_Y_pos).w
                bne.s   +
                andi.w  #$7FF,y_pos(a0)
+
                bsr.w   Sonic_HurtStop
                bsr.w   Sonic_LevelBound
                bsr.w   Sonic_RecordPos
                bsr.w   Sonic_Animate
                bsr.w   LoadSonicDynPLC
                jmp     (DisplaySprite).l
; ===========================================================================
; loc_1B184:
Sonic_HurtStop:
                move.w  (Camera_Max_Y_pos).w,d0
                addi.w  #screen_height,d0
                cmp.w   y_pos(a0),d0
                blt.w   JmpTo_KillCharacter
                bsr.w   Sonic_DoLevelCollision
                btst    #status.player.in_air,status(a0)
                bne.s   GamePlayerSonicHurtDeathRespawn_Return
                moveq   #0,d0
                move.w  d0,y_vel(a0)
                move.w  d0,x_vel(a0)
                move.w  d0,inertia(a0)
                move.b  d0,obj_control(a0)
                move.b  #AniIDSonAni_Walk,anim(a0)
                subq.b  #2,routine(a0)                  ; => Obj01_Control
                move.w  #$78,invulnerable_time(a0)
                move.b  #0,spindash_flag(a0)

GamePlayerSonicHurtDeathRespawn_Return:
                rts

; ===========================================================================
; makes Sonic recover control after being hurt before landing
; seems to be unused
; loc_1B1CA:
Sonic_HurtInstantRecover:
                subq.b  #2,routine(a0)                  ; => Obj01_Control
                move.b  #0,routine_secondary(a0)
                bsr.w   Sonic_RecordPos
                bsr.w   Sonic_Animate
                bsr.w   LoadSonicDynPLC
                jmp     (DisplaySprite).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Sonic when he dies
; ...poor Sonic
; ---------------------------------------------------------------------------

; loc_1B1E6: Obj_01_Sub_6:
Obj01_Dead:
                tst.w   (Debug_mode_flag).w
                beq.s   +
                btst    #button_B,(Ctrl_1_Press).w
                beq.s   +
                move.w  #1,(Debug_placement_mode).w
                clr.b   (Control_Locked).w
                rts
+
                bsr.w   CheckGameOver
                jsr     (ObjectMoveAndFall).l
                bsr.w   Sonic_RecordPos
                bsr.w   Sonic_Animate
                bsr.w   LoadSonicDynPLC
                jmp     (DisplaySprite).l

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1B21C:
CheckGameOver:
                move.b  #1,(Scroll_lock).w
                move.b  #0,spindash_flag(a0)
                move.w  (Camera_Max_Y_pos).w,d0
                addi.w  #$100,d0
                cmp.w   y_pos(a0),d0
                bge.w   SonicHurtDeathRespawn_Return_Variant2
                move.b  #8,routine(a0)                  ; => Obj01_Gone
                move.w  #60,restart_countdown(a0)
                addq.b  #1,(Update_HUD_lives).w         ; update lives counter
                subq.b  #1,(Life_count).w               ; subtract 1 from number of lives
                bne.s   Obj01_ResetLevel                ; if it's not a game over, branch
                move.w  #0,restart_countdown(a0)
                move.b  #ObjID_GameOver,(GameOver_GameText+id).w  ; load Obj39 (game over text)
                move.b  #ObjID_GameOver,(GameOver_OverText+id).w  ; load Obj39 (game over text)
                move.b  #1,(GameOver_OverText+mapping_frame).w
                move.w  a0,(GameOver_GameText+parent).w
                clr.b   (Time_Over_flag).w
; loc_1B26E:
Obj01_Finished:
                clr.b   (Update_HUD_timer).w
                clr.b   (Update_HUD_timer_2P).w
                move.b  #8,routine(a0)                  ; => Obj01_Gone
                move.w  #MusID_GameOver,d0
                jsr     (PlayMusic).l
                moveq   #PLCID_GameOver,d0
                jmp     (LoadPLC).l
; End of function CheckGameOver

; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic when the level is restarted
; ---------------------------------------------------------------------------
; loc_1B28E:
Obj01_ResetLevel:
                tst.b   (Time_Over_flag).w
                beq.s   Obj01_ResetLevel_Part2
                move.w  #0,restart_countdown(a0)
                move.b  #ObjID_TimeOver,(TimeOver_TimeText+id).w  ; load Obj39
                move.b  #ObjID_TimeOver,(TimeOver_OverText+id).w  ; load Obj39
                move.b  #2,(TimeOver_TimeText+mapping_frame).w
                move.b  #3,(TimeOver_OverText+mapping_frame).w
                move.w  a0,(TimeOver_TimeText+parent).w
                bra.s   Obj01_Finished
; ---------------------------------------------------------------------------
Obj01_ResetLevel_Part2:
                tst.w   (Two_player_mode).w
                beq.s   SonicHurtDeathRespawn_Return_Variant2
                move.b  #0,(Scroll_lock).w
                move.b  #$A,routine(a0)                 ; => Obj01_Respawning
                move.w  (Saved_x_pos).w,x_pos(a0)
                move.w  (Saved_y_pos).w,y_pos(a0)
                move.w  (Saved_art_tile).w,art_tile(a0)
                move.w  (Saved_Solid_bits).w,top_solid_bit(a0)
                clr.w   (Ring_count).w
                clr.b   (Extra_life_flags).w
                move.b  #0,obj_control(a0)
                move.b  #5,anim(a0)
                move.w  #0,x_vel(a0)
                move.w  #0,y_vel(a0)
                move.w  #0,inertia(a0)
                move.b  #1<<status.player.in_air,status(a0)
                move.w  #0,move_lock(a0)
                move.w  #0,restart_countdown(a0)

SonicHurtDeathRespawn_Return_Variant2:
                rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic when he's offscreen and waiting for the level to restart
; ---------------------------------------------------------------------------
; loc_1B31C: Obj_01_Sub_8:
Obj01_Gone:
                tst.w   restart_countdown(a0)
                beq.s   +
                subq.w  #1,restart_countdown(a0)
                bne.s   +
                move.w  #1,(Level_Inactive_flag).w
+
                rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic when he's waiting for the camera to scroll back to where he respawned
; ---------------------------------------------------------------------------
; loc_1B330: Obj_01_Sub_A:
Obj01_Respawning:
                tst.w   (Camera_X_pos_diff).w
                bne.s   +
                tst.w   (Camera_Y_pos_diff).w
                bne.s   +
                move.b  #2,routine(a0)                  ; => Obj01_Control
+
                bsr.w   Sonic_Animate
                bsr.w   LoadSonicDynPLC
                jmp     (DisplaySprite).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to animate Sonic's sprites
; See also: AnimateSprite
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1B350:
