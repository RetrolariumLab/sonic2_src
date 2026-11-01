Obj5D:
                moveq   #0,d0
                move.b  routine(a0),d0
                move.w  Obj5D_Index(pc,d0.w),d1
                jmp     Obj5D_Index(pc,d1.w)
; ===========================================================================
; off_2D742:
Obj5D_Index:    offsetTable
                offsetTableEntry.w Obj5D_Init           ; 0
                offsetTableEntry.w Obj5D_Main           ; 2
                offsetTableEntry.w Obj5D_Pipe           ; 4
                offsetTableEntry.w Obj5D_Pipe_Pump      ; 6
                offsetTableEntry.w Obj5D_Pipe_Retract   ; 8
                offsetTableEntry.w Obj5D_Dripper        ; $A
                offsetTableEntry.w Obj5D_Gunk           ; $C
                offsetTableEntry.w Obj5D_PipeSegment    ; $E
                offsetTableEntry.w Obj5D_Container      ; $10
                offsetTableEntry.w Obj5D_Pump           ; $12
                offsetTableEntry.w Obj5D_FallingParts   ; $14
                offsetTableEntry.w Obj5D_Robotnik       ; $16
                offsetTableEntry.w Obj5D_Flame          ; $18
                offsetTableEntry.w Obj5D_Smoke_Puff     ; $1A
; ===========================================================================
; loc_2D75E:
Obj5D_Init:
; main vehicle
                move.l  #Obj5D_MapUnc_2ED8C,mappings(a0)
                move.w  #make_art_tile(ArtTile_ArtNem_Eggpod_3,1,0),art_tile(a0)
                ori.b   #1<<render_flags.level_fg,render_flags(a0)
                move.b  #$20,width_pixels(a0)
                move.w  #$2B80,x_pos(a0)
                move.w  #$4B0,y_pos(a0)
                move.b  #3,priority(a0)
                move.b  #$F,collision_flags(a0)
                move.b  #8,collision_property(a0)
                addq.b  #2,routine(a0)                  ; => Obj5D_Main
                move.w  x_pos(a0),Obj5D_x_pos_next(a0)
                move.w  y_pos(a0),Obj5D_y_pos_next(a0)
                bclr    #3,Obj5D_status(a0)
                jsrto   JmpTo60_Adjust2PArtPointer

; Robotnik sitting in his eggmobile
                jsr     (AllocateObjectAfterCurrent).l
                bne.w   loc_2D8AC
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  a0,Obj5D_parent(a1)
                move.l  a1,Obj5D_parent(a0)
                move.l  #Obj5D_MapUnc_2ED8C,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_Eggpod_3,0,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #3,priority(a1)
                move.l  x_pos(a0),x_pos(a1)
                move.l  y_pos(a0),y_pos(a1)
                move.b  #$16,routine(a1)                ; => Obj5D_Robotnik
                move.b  #1,anim(a1)
                move.b  render_flags(a0),render_flags(a1)
                jsrto   JmpTo8_Adjust2PArtPointer2
                tst.b   subtype(a0)
                bmi.w   loc_2D8AC

; eggmobile's exhaust flame
                jsr     (AllocateObjectAfterCurrent).l
                bne.w   loc_2D8AC
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  a0,Obj5D_parent(a1)
                move.l  #Obj5D_MapUnc_2EE88,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_EggpodJets_1,0,0),art_tile(a1)
                jsrto   JmpTo8_Adjust2PArtPointer2
                move.b  #1,anim_frame_duration(a0)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #3,priority(a1)
                move.l  x_pos(a0),x_pos(a1)
                move.l  y_pos(a0),y_pos(a1)
                move.b  #$18,routine(a1)                ; => Obj5D_Flame
                move.b  render_flags(a0),render_flags(a1)

; large pump mechanism on top of eggmobile
                jsr     (AllocateObjectAfterCurrent).l
                bne.s   loc_2D8AC
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  a0,Obj5D_parent(a1)
                move.l  #Obj5D_MapUnc_2EADC,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_CPZBoss,1,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #2,priority(a1)
                move.l  x_pos(a0),x_pos(a1)
                move.l  y_pos(a0),y_pos(a1)
                move.b  #$12,routine(a1)                ; => Obj5D_Pump

loc_2D8AC:
; glass container that dumps mega mack on player
                jsr     (AllocateObjectAfterCurrent).l
                bne.s   loc_2D908
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  a0,Obj5D_parent(a1)
                move.l  #Obj5D_MapUnc_2EADC,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_CPZBoss,1,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #4,priority(a1)
                move.l  x_pos(a0),x_pos(a1)
                move.l  y_pos(a0),y_pos(a1)
                subi.w  #$38,y_pos(a1)
                subi.w  #$10,x_pos(a1)
                move.w  #-$10,Obj5D_x_vel(a1)
                addi.b  #$10,routine(a1)                ; => Obj5D_Container
                move.b  #6,anim(a1)

loc_2D908:
; pipe used to suck mega mack from tube below
                jsr     (AllocateObjectAfterCurrent).l
                bne.s   CpzBossController_Return
                _move.b #ObjID_CPZBoss,id(a1)           ; load obj5D
                move.l  a0,Obj5D_parent(a1)
                move.l  #Obj5D_MapUnc_2EADC,mappings(a1)
                move.w  #make_art_tile(ArtTile_ArtNem_CPZBoss,1,0),art_tile(a1)
                move.b  #1<<render_flags.level_fg,render_flags(a1)
                move.b  #$20,width_pixels(a1)
                move.b  #4,priority(a1)
                move.l  x_pos(a0),x_pos(a1)
                move.l  y_pos(a0),y_pos(a1)
                move.b  #4,routine(a1)                  ; => Obj5D_Pipe

CpzBossController_Return:
                rts
; ===========================================================================

Obj5D_Main:
                bsr.w   Obj5D_LookAtChar
                moveq   #0,d0
                move.b  routine_secondary(a0),d0
                move.w  Obj5D_Main_Index(pc,d0.w),d1
                jsr     Obj5D_Main_Index(pc,d1.w)
                lea     (Ani_obj5D_b).l,a1
                jsr     (AnimateSprite).l
                move.b  status(a0),d0
                andi.b  #1<<status.npc.x_flip|1<<status.npc.y_flip,d0
                andi.b  #~(1<<render_flags.x_flip|1<<render_flags.y_flip),render_flags(a0)
                or.b    d0,render_flags(a0)
                jmp     (DisplaySprite).l
; ===========================================================================
Obj5D_Main_Index:   offsetTable
                offsetTableEntry.w Obj5D_Main_Descend   ; 0
                offsetTableEntry.w Obj5D_Main_MoveTowardTarget  ; 2
                offsetTableEntry.w Obj5D_Main_Wait      ; 4
                offsetTableEntry.w Obj5D_Main_FollowPlayer  ; 6
                offsetTableEntry.w Obj5D_Main_Explode   ; 8
                offsetTableEntry.w Obj5D_Main_StopExploding  ; $A
                offsetTableEntry.w Obj5D_Main_Retreat   ; $C
; ===========================================================================
; Makes the boss look in Sonic's direction under certain circumstances

Obj5D_LookAtChar:
                cmpi.b  #8,routine_secondary(a0)
                bge.s   +
                move.w  (MainCharacter+x_pos).w,d0
                sub.w   x_pos(a0),d0
                bgt.s   ++
                bclr    #status.npc.x_flip,status(a0)
+
                rts
; ---------------------------------------------------------------------------
+
                bset    #status.npc.x_flip,status(a0)
                rts
; ===========================================================================
; Obj5D_Main_8:
Obj5D_Main_Explode:
                subq.w  #1,Obj5D_defeat_timer(a0)
                bpl.w   Obj5D_Main_CreateExplosion
                bset    #status.npc.x_flip,status(a0)
                bclr    #status.npc.no_balancing,status(a0)
                clr.w   x_vel(a0)
                addq.b  #2,routine_secondary(a0)        ; => Obj5D_Main_StopExploding
                move.w  #-$26,Obj5D_defeat_timer(a0)
                rts
; ===========================================================================
; Obj5D_Main_A:
Obj5D_Main_StopExploding:
                addq.w  #1,Obj5D_defeat_timer(a0)
                beq.s   +
                bpl.s   ++
; Fall slightly
                addi.w  #$18,y_vel(a0)
                bra.s   Obj5D_Main_A_End
; ---------------------------------------------------------------------------
+
; Stop falling
                clr.w   y_vel(a0)
                bra.s   Obj5D_Main_A_End
; ---------------------------------------------------------------------------
+
                cmpi.w  #$30,Obj5D_defeat_timer(a0)
                blo.s   +
                beq.s   ++
                cmpi.w  #$38,Obj5D_defeat_timer(a0)
                blo.s   Obj5D_Main_A_End
                addq.b  #2,routine_secondary(a0)        ; => Obj5D_Main_Retreat
                bra.s   Obj5D_Main_A_End
; ---------------------------------------------------------------------------
+
; Rise slightly
                subi_.w #8,y_vel(a0)
                bra.s   Obj5D_Main_A_End
; ---------------------------------------------------------------------------
+
; Stop rising
                clr.w   y_vel(a0)
                jsrto   JmpTo_PlayLevelMusic
                jsrto   JmpTo_LoadPLC_AnimalExplosion

Obj5D_Main_A_End:
                bsr.w   Obj5D_Main_Move
                bra.w   Obj5D_Main_Pos_and_Collision
; ===========================================================================
; Obj5D_Main_C:
Obj5D_Main_Retreat:
                bset    #6,Obj5D_status2(a0)
                move.w  #$400,x_vel(a0)
                move.w  #-$40,y_vel(a0)
                cmpi.w  #$2C30,(Camera_Max_X_pos).w
                bhs.s   +
                addq.w  #2,(Camera_Max_X_pos).w
                bra.s   Obj5D_Main_C_End
; ===========================================================================
+
                _btst   #render_flags.on_screen,render_flags(a0)
                _beq.s  Obj5D_Main_Delete

Obj5D_Main_C_End:
                bsr.w   Obj5D_Main_Move
                bra.w   Obj5D_Main_Pos_and_Collision
; ===========================================================================

Obj5D_Main_Delete:
                addq.l  #4,sp
                movea.l Obj5D_parent(a0),a1             ; a1=object
                jsr     (DeleteObject2).l
                jmp     (DeleteObject).l
; ===========================================================================
; Obj5D_Main_0:
Obj5D_Main_Descend:
; Strangely, there is code here for Eggman to descend into the arena
; just like he does in Green Hill Zone in Sonic 1. Because Eggman
; spawns off-screen, the player never gets to see him do this
; The reason for this is that this entire function is copied from
; Green Hill Zone's boss (see `BGHZ_ShipStart` in the Sonic 1
; disassembly)
                move.w  #$100,y_vel(a0)
                bsr.w   Obj5D_Main_Move
                cmpi.w  #$4C0,Obj5D_y_pos_next(a0)
                bne.s   Obj5D_Main_Pos_and_Collision
                move.w  #0,y_vel(a0)
                addq.b  #2,routine_secondary(a0)        ; => Obj5D_Main_MoveTowardTarget

Obj5D_Main_Pos_and_Collision:
; do hovering motion using sine wave
                move.b  Obj5D_hover_counter(a0),d0
                jsr     (CalcSine).l
                asr.w   #6,d0
                add.w   Obj5D_y_pos_next(a0),d0         ; get y position for next frame, add sine value
                move.w  d0,y_pos(a0)                    ; set y and x positions
                move.w  Obj5D_x_pos_next(a0),x_pos(a0)
                addq.b  #2,Obj5D_hover_counter(a0)

                cmpi.b  #8,routine_secondary(a0)        ; exploding or retreating?
                bhs.s   CpzBossController_Return_Variant2                    ; if yes, branch
                _btst   #status.npc.no_balancing,status(a0)
                _bne.s  Obj5D_Defeated                  ; branch, if boss is defeated
                tst.b   collision_flags(a0)
                bne.s   CpzBossController_Return_Variant2                    ; branch, if collisions are not turned off

; if collisions are turned off, it means the boss was hit
                tst.b   Obj5D_invulnerable_time(a0)
                bne.s   +                               ; branch, if still invulnerable
                move.b  #32,Obj5D_invulnerable_time(a0)
                move.w  #SndID_BossHit,d0
                jsr     (PlaySound).l
+
; Make the boss sprite flash by alternating the black
; colour in palette line 3 between black and white
                lea     (Normal_palette_line2+2).w,a1
                moveq   #0,d0                           ; color black
                tst.w   (a1)                            ; test palette entry
                bne.s   +                               ; branch, if it's not black
                move.w  #$EEE,d0                        ; color white
+
                move.w  d0,(a1)                         ; set color for flashing effect

                subq.b  #1,Obj5D_invulnerable_time(a0)
                bne.s   CpzBossController_Return_Variant2
                move.b  #$F,collision_flags(a0)         ; restore collisions
                bclr    #1,Obj5D_status(a0)

CpzBossController_Return_Variant2:
                rts
; ===========================================================================
; called when status bit 7 is set (check Touch_Enemy_Part2)

Obj5D_Defeated:
                moveq   #100,d0
                jsrto   JmpTo2_AddPoints
                move.b  #8,routine_secondary(a0)        ; => Obj5D_Main_Explode
                move.w  #60*3-1,Obj5D_defeat_timer(a0)
                movea.l Obj5D_parent(a0),a1             ; a1=object
                move.b  #4,anim(a1)
                moveq   #PLCID_Capsule,d0
                jmpto   JmpTo5_LoadPLC
; ===========================================================================
                rts
; ===========================================================================

Obj5D_Main_Move:
                move.l  Obj5D_x_pos_next(a0),d2
                move.l  Obj5D_y_pos_next(a0),d3
                move.w  x_vel(a0),d0
                ext.l   d0
                asl.l   #8,d0
                add.l   d0,d2
                move.w  y_vel(a0),d0
                ext.l   d0
                asl.l   #8,d0
                add.l   d0,d3
                move.l  d2,Obj5D_x_pos_next(a0)
                move.l  d3,Obj5D_y_pos_next(a0)
                rts
; ===========================================================================
; Creates an explosion every 8 frames at a random position relative to boss
; Obj5D_Main_Explode:
Obj5D_Main_CreateExplosion:
                move.b  (Vint_runcount+3).w,d0
                andi.b  #7,d0
                bne.s   +                               ; rts
                jsr     (AllocateObject).l
                bne.s   +                               ; rts
                _move.b #ObjID_BossExplosion,id(a1)     ; load obj58
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
                jsr     (RandomNumber).l
                move.w  d0,d1
                moveq   #0,d1
                move.b  d0,d1
                lsr.b   #2,d1
                subi.w  #$20,d1
                add.w   d1,x_pos(a1)
                lsr.w   #8,d0
                lsr.b   #2,d0
                subi.w  #$20,d0
                add.w   d0,y_pos(a1)
+
                rts
; ===========================================================================
; Creates an explosion

Obj5D_Main_Explode2:
                jsr     (AllocateObject).l
                bne.s   +                               ; rts
                _move.b #ObjID_BossExplosion,id(a1)     ; load obj58
; This code suggests that the intended effect is for each piece of
; the boss to explode before falling off. However, this does not work
; as the `x_pos` and `y_pos` values do not match the actual physical
; locations of the pieces. In fact, most pieces' X and Y positions are
; in the middle of the Eggmobile, completely ruining the effect
; issue that would be complicated to fix
                move.w  x_pos(a0),x_pos(a1)
                move.w  y_pos(a0),y_pos(a1)
+
                rts
; ===========================================================================
; Obj5D_Main_2:
Obj5D_Main_MoveTowardTarget:
                btst    #3,Obj5D_status(a0)             ; is boss on the left side of the arena?
                bne.s   +                               ; if yes, branch
                move.w  #$2B30,d0                       ; right side of arena
                bra.s   ++
; ---------------------------------------------------------------------------
+
                move.w  #$2A50,d0                       ; left side of arena
+
                move.w  d0,d1
                sub.w   Obj5D_x_pos_next(a0),d0
                bpl.s   +
                neg.w   d0                              ; get absolute value
+
                cmpi.w  #3,d0
                ble.s   Obj5D_Main_2_Stop               ; branch, if boss is within 3 pixels to his target
                cmp.w   Obj5D_x_pos_next(a0),d1
                bgt.s   Obj5D_Main_2_MoveRight

; Obj5D_Main_2_MoveLeft:
                move.w  #-$300,x_vel(a0)
                bra.s   Obj5D_Main_2_End
; ---------------------------------------------------------------------------

Obj5D_Main_2_MoveRight:
                move.w  #$300,x_vel(a0)

Obj5D_Main_2_End:
                bsr.w   Obj5D_Main_Move
                bra.w   Obj5D_Main_Pos_and_Collision
; ===========================================================================

Obj5D_Main_2_Stop:
; Once again, there's some strange code that changes Eggman's
; behaviour if he's above or below his target. Because Eggman is
; always at the expected Y position, this behaviour is never seen
; in-game
                cmpi.w  #$4C0,Obj5D_y_pos_next(a0)
                bne.w   Obj5D_Main_Pos_and_Collision

                move.w  #0,x_vel(a0)
                move.w  #0,y_vel(a0)                    ; Halt Eggman's vertical movement... not that he had any to begin with
                addq.b  #2,routine_secondary(a0)        ; => Obj5D_Main_Wait
                bchg    #3,Obj5D_status(a0)             ; indicate boss is now at the other side
                bset    #0,Obj5D_status2(a0)            ; action 0
                bra.w   Obj5D_Main_Pos_and_Collision
; ===========================================================================
; when status2 bit 0 set, wait for something
; Obj5D_Main_4:
Obj5D_Main_Wait:
                btst    #0,Obj5D_status2(a0)            ; action 0?
                beq.s   +                               ; if not, branch
                bra.w   Obj5D_Main_Pos_and_Collision
; ---------------------------------------------------------------------------
+
                addq.b  #2,routine_secondary(a0)        ; => Obj5D_Main_FollowPlayer
                bra.w   Obj5D_Main_Pos_and_Collision
; ===========================================================================
; Obj5D_Main_6:
Obj5D_Main_FollowPlayer:
                move.w  (MainCharacter+x_pos).w,d0
                addi.w  #76,d0                          ; Keep a distance of 76 pixels when following the player
                cmp.w   Obj5D_x_pos_next(a0),d0
                bgt.s   Obj5D_Main_6_MoveRight
                beq.w   Obj5D_Main_Pos_and_Collision

; Obj5D_Main_6_MoveLeft:
                subi.l  #$10000,Obj5D_x_pos_next(a0)    ; move left one pixel
; stop at left boundary
                cmpi.w  #$2A28,Obj5D_x_pos_next(a0)
                bgt.w   Obj5D_Main_Pos_and_Collision
                move.w  #$2A28,Obj5D_x_pos_next(a0)
                bra.w   Obj5D_Main_Pos_and_Collision
; ---------------------------------------------------------------------------

Obj5D_Main_6_MoveRight:
                addi.l  #$10000,Obj5D_x_pos_next(a0)    ; move right one pixel
; stop at right boundary
                cmpi.w  #$2B70,Obj5D_x_pos_next(a0)
                blt.w   Obj5D_Main_Pos_and_Collision
                move.w  #$2B70,Obj5D_x_pos_next(a0)
                bra.w   Obj5D_Main_Pos_and_Collision
; ===========================================================================
