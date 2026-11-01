Level:
; fading out from previous game mode
                bset    #GameModeFlag_TitleCard,(Game_Mode).w  ; add $80 to screen mode (for pre level sequence)

                tst.w   (Demo_mode_flag).w              ; is an ending sequence demo running? (unused)
                bmi.s   Level_NoMusicFade               ; if yes, don't fade out music
                move.b  #MusID_FadeOut,d0               ; queue music fade-out command
                bsr.w   PlaySound                       ; fade out music

Level_NoMusicFade:
                bsr.w   ClearPLC                        ; clear any remaining PLC entries
                bsr.w   Pal_FadeToBlack                 ; fade out from the previous screen
; ---------------------------------------------------------------------------

; load title cards, queue PLCs, setup screen, play music
                tst.w   (Demo_mode_flag).w              ; is an ending sequence demo running? (unused)
                bmi.s   Level_ClrRam                    ; if yes, don't load title screen or main level patterns

                move    #$2700,sr                       ; disable interrupts
                bsr.w   ClearScreen                     ; wipe the screen
                jsr     (LoadTitleCard).l               ; load title card patterns
                move    #$2300,sr                       ; enable interrupts
                moveq   #0,d0                           ; clear d0
                move.w  d0,(Level_frame_counter).w      ; reset frames since level start to 0
                move.b  (Current_Zone).w,d0             ; get current Zone ID

; multiply d0 by 12, the size of a level art load block
                add.w   d0,d0
                add.w   d0,d0
                move.w  d0,d1
                add.w   d0,d0
                add.w   d1,d0

                lea     (LevelArtPointers).l,a2         ; load level art pointers
                lea     (a2,d0.w),a2                    ; get relevant header for current level
                moveq   #0,d0                           ; clear d0
                move.b  (a2),d0                         ; get first PLC entry
                beq.s   Level_NoPLC                     ; if it's null, branch (never the case)
                bsr.w   LoadPLC                         ; load level patterns for current Zone

Level_NoPLC:
                moveq   #PLCID_Std2,d0                  ; load secondary standard patterns (monitors, etc.)
                bsr.w   LoadPLC                         ; (these can be overwritten by stuff like the signpost art)
                bsr.w   Level_SetPlayerMode             ; set the player mode (overwritten in 2P and demos)

                moveq   #PLCID_MilesLife2P,d0           ; load Miles' 2P life graphics
                tst.w   (Two_player_mode).w             ; is this two-player mode?
                bne.s   +                               ; if not, branch
                cmpi.w  #2,(Player_mode).w              ; is this a Tails Alone game?
                bne.s   Level_ClrRam                    ; if not, branch
                addq.w  #PLCID_MilesLife-PLCID_MilesLife2P,d0  ; load Miles' life graphics
+
                tst.b   (Graphics_Flags).w              ; is this a Japanese console?
                bpl.s   +                               ; if yes, branch
                addq.w  #PLCID_TailsLife2P-PLCID_MilesLife2P,d0  ; load Tails' life graphics
+
                bsr.w   LoadPLC                         ; load requested patterns

; loc_3F48:
Level_ClrRam:
                clearRAM Object_Display_Lists,Object_Display_Lists_End  ; clear object display lists RAM
                clearRAM Object_RAM,LevelOnly_Object_RAM_End  ; clear object RAM and level-only object RAM
                clearRAM MiscLevelVariables,MiscLevelVariables_End  ; clear level variable RAM (camera position, etc.)
                clearRAM Misc_Variables,Misc_Variables_End  ; clear various miscellanous RAM
                clearRAM Oscillating_Data,Oscillating_variables_End  ; clear various timing and screen RAM (for animated tiles, etc.)
; The '+C0' shouldn't be here; CNZ_saucer_data is only $40 bytes large
                clearRAM CNZ_saucer_data,CNZ_saucer_data_End+$C0  ; clear CNZ saucer RAM (and way more than necessary)

                cmpi.w  #chemical_plant_zone_act_2,(Current_ZoneAndAct).w  ; is this CPZ2?
                beq.s   Level_InitWater                 ; if yes, branch
                cmpi.b  #aquatic_ruin_zone,(Current_Zone).w  ; is this ARZ?
                beq.s   Level_InitWater                 ; if yes, branch
                cmpi.b  #hidden_palace_zone,(Current_Zone).w  ; is this HPZ?
                bne.s   +                               ; if not, branch

Level_InitWater:
                move.b  #1,(Water_flag).w               ; enable water
                move.w  #0,(Two_player_mode).w          ; disable two-player mode
+
                lea     (VDP_control_port).l,a6         ; load VDP control port
                move.w  #$8B03,(a6)                     ; line scroll mode (per-row horizontally, full-screen vertically)
                move.w  #$8200|(VRAM_Plane_A_Name_Table/$400),(a6)  ; set foreground nametable address
                move.w  #$8400|(VRAM_Plane_B_Name_Table/$2000),(a6)  ; set background nametable address
                move.w  #$8500|(VRAM_Sprite_Attribute_Table/$200),(a6)  ; set sprite table address
                move.w  #$9001,(a6)                     ; 64-cell hscroll size
                move.w  #$8004,(a6)                     ; use 8-colour mode
                move.w  #$8720,(a6)                     ; set background colour (line 3; colour 0)
                move.w  #$8C81,(a6)                     ; disable interlace and S/H mode

                tst.b   (Debug_options_flag).w          ; has debug cheat been entered?
                beq.s   Level_Chk2P                     ; if not, branch
                btst    #button_C,(Ctrl_1_Held).w       ; is C button held?
                beq.s   Level_ChkDebug                  ; if not, branch
                move.w  #$8C89,(a6)                     ; disable interlace and enable S/H mode

Level_ChkDebug:
                btst    #button_A,(Ctrl_1_Held).w       ; is A button held?
                beq.s   Level_Chk2P                     ; if not, branch
                move.b  #1,(Debug_mode_flag).w          ; enable debug mode

Level_Chk2P:
                move.w  #$8ADF,(Hint_counter_reserve).w  ; set palette change position (for water)
                tst.w   (Two_player_mode).w             ; is this two-player mode?
                beq.s   Level_ChkWater                  ; if not, branch
                move.w  #$8A6B,(Hint_counter_reserve).w  ; set screen change position (for player 2)
                move.w  #$8014,(a6)                     ; 8-colour mode, horizontal interrupts enabled
                move.w  #$8C87,(a6)                     ; enable interlace and disable S/H

Level_ChkWater:
                move.w  (Hint_counter_reserve).w,(a6)   ; write to VDP

                clr.w   (VDP_Command_Buffer).w          ; clear VDP command buffer
                move.l  #VDP_Command_Buffer,(VDP_Command_Buffer_Slot).w  ; clear VDP command buffer slot
                tst.b   (Water_flag).w                  ; is this a water level?
                beq.s   Level_LoadPal                   ; if not, branch
                move.w  #$8014,(a6)                     ; 8-colour mode, horizontal interrupts enabled
                moveq   #0,d0                           ; clear d0
                move.w  (Current_ZoneAndAct).w,d0       ; get current Zone and Act
                subi.w  #hidden_palace_zone_act_1,d0    ; ignore all stages before HPZ1
                ror.b   #1,d0                           ; rotate bits right by 1
                lsr.w   #6,d0                           ; shift bits right by 6 (2 acts per zone, word-sized)
                andi.w  #$FFFE,d0                       ; quick-and-dirty alignment?
                lea     (WaterHeight).l,a1              ; load water height array
                move.w  (a1,d0.w),d0                    ; get water height entries for current stage
                move.w  d0,(Water_Level_1).w            ; set water height (actual)
                move.w  d0,(Water_Level_2).w            ; set water height (ignoring surface sway)
                move.w  d0,(Water_Level_3).w            ; set water height (target)
                clr.b   (Water_routine).w               ; clear water routine counter
                clr.b   (Water_fullscreen_flag).w       ; clear water state
                move.b  #1,(Water_on).w                 ; enable water
; loc_407C:
Level_LoadPal:
                moveq   #PalID_BGND,d0                  ; load Sonic's palette
                bsr.w   PalLoad_Now                     ; ...directly to active palette (for title cards)
                tst.b   (Water_flag).w                  ; does level have water?
                beq.s   Level_GetBgm                    ; if not, branch
                moveq   #PalID_HPZ_U,d0                 ; palette number $15 (HPZ)
                cmpi.b  #hidden_palace_zone,(Current_Zone).w  ; is this actually Hidden Palace?
                beq.s   Level_WaterPal                  ; if yes, branch
                moveq   #PalID_CPZ_U,d0                 ; palette number $16 (CPZ)
                cmpi.b  #chemical_plant_zone,(Current_Zone).w  ; is this actually Chemical Plant?
                beq.s   Level_WaterPal                  ; if yes, branch
                moveq   #PalID_ARZ_U,d0                 ; palette number $17 (ARZ)
; loc_409E:
Level_WaterPal:
                bsr.w   PalLoad_Water_Now               ; load underwater palette
                tst.b   (Last_star_pole_hit).w          ; are we respawning from a checkpoint?
                beq.s   Level_GetBgm                    ; if not, branch
                move.b  (Saved_Water_move).w,(Water_fullscreen_flag).w  ; restore water state from checkpoint
; loc_40AE:
Level_GetBgm:
                tst.w   (Demo_mode_flag).w              ; is this a credits demo?
                bmi.s   Level_SkipTtlCard               ; if yes, don't load title cards or change music

                moveq   #0,d0                           ; clear d0
                move.b  (Current_Zone).w,d0             ; get current Zone ID
                lea_    MusicList,a1                    ; load music playlist
                tst.w   (Two_player_mode).w             ; is this two-player mode?
                beq.s   Level_PlayBgm                   ; if not, branch
                lea_    MusicList2,a1                   ; load 2P music playlist
; loc_40C8:
Level_PlayBgm:
                move.b  (a1,d0.w),d0                    ; get music ID for current level
                move.w  d0,(Level_Music).w              ; store level music
                bsr.w   PlayMusic                       ; play music
                move.b  #ObjID_TitleCard,(TitleCard+id).w  ; load title card object
; ---------------------------------------------------------------------------
; loc_40DA:
Level_TtlCard:                                          ; move in title cards, stay on them until PLCs have finished
                move.b  #VintID_TitleCard,(Vint_routine).w  ; set VBlank routine to $0C
                bsr.w   WaitForVint                     ; wait until VBlank has finished
                jsr     (RunObjects).l                  ; execute title cards object
                jsr     (BuildSprites).l                ; build sprites to show title cards
                bsr.w   RunPLC_RAM                      ; decompress level graphics
                move.w  (TitleCard_ZoneName+x_pos).w,d0  ; get current position of the "ZONE NAME" element of the title cards
                cmp.w   (TitleCard_ZoneName+titlecard_x_target).w,d0  ; as "ZONE NAME" element reached its target position?
                bne.s   Level_TtlCard                   ; if not, loop until it has
                tst.l   (Plc_Buffer).w                  ; have patterns been fully decompressed and loaded?
                bne.s   Level_TtlCard                   ; if not, loop until it has
; ---------------------------------------------------------------------------

; PLCs have finished, load/initialize remaining data

; This was added in Sonic 2 to stop VBlank from interrupting in the
; middle of a transfer, resulting in potential visual corruption
                move.b  #VintID_TitleCard,(Vint_routine).w  ; set VBlank routine to $0C
                bsr.w   WaitForVint                     ; wait until VBlank has finished

                jsr     (Hud_Base).l                    ; load basic HUD graphics

Level_SkipTtlCard:
                moveq   #PalID_BGND,d0                  ; load Sonic's palette to the fade-in buffer
                bsr.w   PalLoad_ForFade                 ; (basically useless since Sonic 2 doesn't fade-in into levels)
                bsr.w   LevelSizeLoad                   ; load level size and set default level boundaries
                jsrto   JmpTo_DeformBgLayer             ; initialize background deformation
                clr.w   (Vscroll_Factor_FG).w           ; draw an extra column at the left side of the screen during level start
                move.w  #-screen_height,(Vscroll_Factor_P2_FG).w  ; repeat for player 2

                clearRAM Horiz_Scroll_Buf,Horiz_Scroll_Buf+HorizontalScrollBuffer.len  ; clear the horizontal scroll buffer

                bsr.w   LoadZoneTiles                   ; load main level graphics
                jsrto   JmpTo_loadZoneBlockMaps         ; load block mappings and palettes
                jsr     (LoadAnimatedBlocks).l          ; load animated block mappings
                jsrto   JmpTo_DrawInitialBG             ; fully draw the foreground and background once before the level starts
                jsr     (ConvertCollisionArray).l       ; call a routine that immediately returns (this is a disabled development function)
                bsr.w   LoadCollisionIndexes            ; set collision index for current zone
                bsr.w   WaterEffects                    ; initialize water features
                bsr.w   InitPlayers                     ; load Sonic, Tails, and related objects

; Level_ChkWater:
                move.w  #0,(Ctrl_1_Logical).w           ; clear button input states for Sonic
                move.w  #0,(Ctrl_2_Logical).w           ; clear button input states for Tails
                move.w  #0,(Ctrl_1).w                   ; clear actual button input states for controller 1
                move.w  #0,(Ctrl_2).w                   ; clear actual button input states for controller 2
                move.b  #1,(Control_Locked).w           ; lock controls for controller 1
                move.b  #1,(Control_Locked_P2).w        ; lock controls for controller 2
                move.b  #0,(Level_started_flag).w       ; mark level as not having started

                tst.b   (Water_flag).w                  ; does level have water?
                beq.s   +                               ; if not, branch
                move.b  #ObjID_WaterSurface,(WaterSurface1+id).w  ; load water surface object A
                move.w  #$60,(WaterSurface1+x_pos).w    ; set base X-position for surface A
                move.b  #ObjID_WaterSurface,(WaterSurface2+id).w  ; load water surface object B
                move.w  #$120,(WaterSurface2+x_pos).w   ; set base X-position for surface B
+
                cmpi.b  #chemical_plant_zone,(Current_Zone).w  ; is this CPZ?
                bne.s   +                               ; if not, branch
                move.b  #ObjID_CPZPylon,(CPZPylon+id).w  ; load CPZ plyon object
+
                cmpi.b  #oil_ocean_zone,(Current_Zone).w  ; is this OOZ?
                bne.s   Level_ClrHUD                    ; if not, branch
                move.b  #ObjID_Oil,(Oil+id).w           ; load OOZ oil object
; Level_LoadObj: misnomer now
Level_ClrHUD:
                moveq   #0,d0                           ; clear d0
                tst.b   (Last_star_pole_hit).w          ; are we starting from a lamppost?
                bne.s   Level_FromCheckpoint            ; if yes, branch
                move.w  d0,(Ring_count).w               ; clear rings
                move.l  d0,(Timer).w                    ; clear time
                move.b  d0,(Extra_life_flags).w         ; clear extra lives counter
                move.w  d0,(Ring_count_2P).w            ; ditto for player 2
                move.l  d0,(Timer_2P).w                 ; and ditto
                move.b  d0,(Extra_life_flags_2P).w      ; and ditto
; loc_41E4:
Level_FromCheckpoint:
                move.b  d0,(Time_Over_flag).w           ; clear time over flag
                move.b  d0,(Time_Over_flag_2P).w        ; ditto for player 2
                move.b  d0,(SlotMachine_Routine).w      ; clear CNZ slots routine
                move.w  d0,(SlotMachineInUse).w         ; clear CNZ slots-in-use flag
                move.w  d0,(Debug_placement_mode).w     ; exit debug mode if necessary
                move.w  d0,(Level_Inactive_flag).w      ; clear level restart flag
                move.b  d0,(Teleport_timer).w           ; clear teleport timer
                move.b  d0,(Teleport_flag).w            ; clear teleport flag
                move.w  d0,(Rings_Collected).w          ; clear rings collected by player 1
                move.w  d0,(Rings_Collected_2P).w       ; clear rings collected by player 2
                move.w  d0,(Monitors_Broken).w          ; clear monitors broken by player 1
                move.w  d0,(Monitors_Broken_2P).w       ; clear monitors broken by player 2
                move.w  d0,(Loser_Time_Left).w          ; clear 2P time limit
                bsr.w   OscillateNumInit                ; initialize oscillation values
                move.b  #1,(Update_HUD_score).w         ; update score counter
                move.b  #1,(Update_HUD_rings).w         ; update rings counter
                move.b  #1,(Update_HUD_timer).w         ; update player 1 time counter
                move.b  #1,(Update_HUD_timer_2P).w      ; update player 2 time counter

                jsr     (ObjectsManager).l              ; initialize object positions
                jsr     (RingsManager).l                ; initialize ring positions
                jsr     (SpecialCNZBumpers).l           ; initialize bumper positions
                jsr     (RunObjects).l                  ; execute level objects
                jsr     (BuildSprites).l                ; build sprites to show level objects
                jsrto   JmpTo_AniArt_Load               ; load animated stage artwork
                bsr.w   SetLevelEndType                 ; determine if we should be using a signpost or capsule

                move.w  #0,(Demo_button_index).w        ; clear button push counters for player 1 in demos
                move.w  #0,(Demo_button_index_2P).w     ; clear button push counters for player 2 in demos
                lea     (DemoScriptPointers).l,a1       ; load demo data
                moveq   #0,d0                           ; clear d0
                move.b  (Current_Zone).w,d0             ; get current Zone ID
                lsl.w   #2,d0                           ; multiply by 4 for longword-based indexing
                movea.l (a1,d0.w),a1                    ; get demo pointer for current level
                tst.w   (Demo_mode_flag).w              ; are we in an ending demo? (unused)
                bpl.s   Level_Demo                      ; if not, branch
                lea     (EndingDemoScriptPointers).l,a1  ; load (dummied out) ending demo data
                move.w  (Ending_demo_number).w,d0       ; get current credits page
                subq.w  #1,d0                           ; subtract by 1
                lsl.w   #2,d0                           ; multiply by 4 for longword-based indexing
                movea.l (a1,d0.w),a1                    ; get demo pointer for current credits page

Level_Demo:
                move.b  1(a1),(Demo_press_counter).w    ; load initial demo key press duration for player 1
                if      emerald_hill_zone<>0
                cmpi.b  #emerald_hill_zone,(Current_Zone).w  ; is this EHZ1? (different check incase of shifting IDs)
                else
                tst.b   (Current_Zone).w                ; is this EHZ1?
                endif
                bne.s   +                               ; if not, branch
                lea     (Demo_EHZ_Tails).l,a1           ; load player 2 inputs for demo
                move.b  1(a1),(Demo_press_counter_2P).w  ; load initial demo key press duration for player 2
+
                move.w  #1640,(Demo_Time_left).w        ; run regular demo for 27 seconds
                tst.w   (Demo_mode_flag).w              ; are we in an ending demo? (unused)
                bpl.s   +                               ; if not, branch
                move.w  #540,(Demo_Time_left).w         ; run credits demos for 9 seconds each
                cmpi.w  #4,(Ending_demo_number).w       ; is this credits demo 4? (Labyrinth in Sonic 1)
                bne.s   +                               ; if not, branch
                move.w  #510,(Demo_Time_left).w         ; run this specific demo for 0.5 seconds less
+
                tst.b   (Water_flag).w                  ; is this a water level?
                beq.s   ++                              ; if not, branch
                moveq   #PalID_HPZ_U,d0                 ; palette number $15 (HPZ)
                cmpi.b  #hidden_palace_zone,(Current_Zone).w  ; is this actually HPZ?
                beq.s   +                               ; if not, branch
                moveq   #PalID_CPZ_U,d0                 ; palette number $16 (CPZ)
                cmpi.b  #chemical_plant_zone,(Current_Zone).w  ; is this actually CPZ?
                beq.s   +                               ; if not, branch
                moveq   #PalID_ARZ_U,d0                 ; palette number $17 (ARZ)
+
                bsr.w   PalLoad_Water_ForFade           ; load underwater palette (again useless)
+
                move.w  #-1,(TitleCard_ZoneName+titlecard_leaveflag).w  ; mark "ZONE NAME" element to leave
                move.b  #$E,(TitleCard_Left+routine).w  ; make the left part move offscreen
                move.w  #$A,(TitleCard_Left+titlecard_location).w  ; ??? not sure

-               move.b  #VintID_TitleCard,(Vint_routine).w  ; set VBlank routine to $0C
                bsr.w   WaitForVint                     ; wait until VBlank has finished
                jsr     (RunObjects).l                  ; execute title cards object
                jsr     (BuildSprites).l                ; build sprites to show title cards
                bsr.w   RunPLC_RAM                      ; decompress level graphics

                tst.b   (TitleCard_Background+id).w     ; is the title card background still present?
                bne.s   -                               ; if not, loop until it leaves

                lea     (TitleCard).w,a1                ; load title card object into a1
                move.b  #$16,TitleCard_ZoneName-TitleCard+routine(a1)  ; set "ZONE NAME" element routine to leave
                move.w  #$2D,TitleCard_ZoneName-TitleCard+anim_frame_duration(a1)  ; ...after 45 frames
                move.b  #$16,TitleCard_Zone-TitleCard+routine(a1)  ; set "ZONE" element routine to leave
                move.w  #$2D,TitleCard_Zone-TitleCard+anim_frame_duration(a1)  ; ...after 45 frames
                tst.b   TitleCard_ActNumber-TitleCard+id(a1)  ; is the "ACT X" element present?
                beq.s   +                               ; if not, branch
                move.b  #$16,TitleCard_ActNumber-TitleCard+routine(a1)  ; set "ACT X" element routine to leave
                move.w  #$2D,TitleCard_ActNumber-TitleCard+anim_frame_duration(a1)  ; ...after 45 frames
+               move.b  #0,(Control_Locked).w           ; unlock player 1's controls
                move.b  #0,(Control_Locked_P2).w        ; unlock player 2's controls
                move.b  #1,(Level_started_flag).w       ; mark level as having started

; Level_StartGame: loc_435A:
                bclr    #GameModeFlag_TitleCard,(Game_Mode).w  ; subtract $80 from mode to end pre-level stuff
; enter main loop

; ---------------------------------------------------------------------------
; Main level loop (when all title card and loading sequences are finished)
; ---------------------------------------------------------------------------
; loc_4360:
Level_MainLoop:
                bsr.w   PauseGame                       ; handle pausing the game when pressing start
                move.b  #VintID_Level,(Vint_routine).w  ; set VBlank routine to $08
                bsr.w   WaitForVint                     ; wait until VBlank has finished
                addq.w  #1,(Level_frame_counter).w      ; add 1 to level timer

                bsr.w   MoveSonicInDemo                 ; simulate controls in demos (immediately returns outside demos)
                bsr.w   WaterEffects                    ; apply water features
                jsr     (RunObjects).l                  ; execute all objects in object RAM

                tst.w   (Level_Inactive_flag).w         ; is the level set to restart?
                bne.w   Level                           ; if yes, branch

                jsrto   JmpTo_DeformBgLayer             ; scroll planes and do background deformation
                bsr.w   UpdateWaterSurface              ; update water surface position (swaying motion)
                jsr     (RingsManager).l                ; run the ring manager to load rings
                cmpi.b  #casino_night_zone,(Current_Zone).w  ; is this CNZ?
                bne.s   +                               ; if not, branch
                jsr     (SpecialCNZBumpers).l           ; run the bumper manager to load CNZ bumpers
+
                jsrto   JmpTo_AniArt_Load               ; run animated stage artwork
                bsr.w   PalCycle_Load                   ; run palette cycles
                bsr.w   RunPLC_RAM                      ; run PLC, if any
                bsr.w   OscillateNumDo                  ; advance oscillation values
                bsr.w   ChangeRingFrame                 ; advance animation timers
                bsr.w   CheckLoadSignpostArt            ; check if signpost art needs to be loaded and lock left boundary
                jsr     (BuildSprites).l                ; build sprite table
                jsr     (ObjectsManager).l              ; run the object manager to load level objects

                cmpi.b  #GameModeID_Demo,(Game_Mode).w  ; are we in a demo?
                beq.s   Level_ChkDemo                   ; if yes, branch
                cmpi.b  #GameModeID_Level,(Game_Mode).w  ; is game mode still set to level?
                beq.w   Level_MainLoop                  ; if yes, loop level game mode
                rts                                     ; if game mode changed, return to MainGameLoop
; ---------------------------------------------------------------------------

Level_ChkDemo:
                tst.w   (Level_Inactive_flag).w         ; is level set to restart?
                bne.s   Level_EndDemo                   ; if yes, branch
                tst.w   (Demo_Time_left).w              ; is there time left on the demo?
                beq.s   Level_EndDemo                   ; if not, branch
                cmpi.b  #GameModeID_Demo,(Game_Mode).w  ; is game mode still demo?
                beq.w   Level_MainLoop                  ; if yes, loop level game mode
                move.b  #GameModeID_SegaScreen,(Game_Mode).w  ; otherwise, return to Sega screen
                rts                                     ; return to MainGameLoop
; ---------------------------------------------------------------------------

Level_EndDemo:
                cmpi.b  #GameModeID_Demo,(Game_Mode).w  ; is game mode still demo?
                bne.s   Level_FadeDemo                  ; if not, slowly fade-out demo
                move.b  #GameModeID_SegaScreen,(Game_Mode).w  ; return to Sega screen
; Surprisingly, they did remove the Sonic 1 ending demo logic here

Level_FadeDemo:
                move.w  #1*60,(Demo_Time_left).w        ; run fade-out for one second
                move.w  #$3F,(Palette_fade_range).w     ; set palette fade-out position and size
                clr.w   (PalChangeSpeed).w              ; do first palette dimming immediately

Level_FDLoop:
                move.b  #VintID_Level,(Vint_routine).w  ; set VBlank routine to $08
                bsr.w   WaitForVint                     ; wait until VBlank has finished
                bsr.w   MoveSonicInDemo                 ; continue updating demo controls during fade-out
                jsr     (RunObjects).l                  ; continue executing objects during fade-out
                jsr     (BuildSprites).l                ; continue building sprites during fade-out
                jsr     (ObjectsManager).l              ; continue running object manager during fade-out

                subq.w  #1,(PalChangeSpeed).w           ; decrement palette fade-out delay
                bpl.s   Level_FDLoop_NoDim              ; if time remains, branch
                move.w  #2,(PalChangeSpeed).w           ; reset palette fade-out delay
                bsr.w   Pal_FadeToBlack.UpdateAllColours  ; dim palette further

Level_FDLoop_NoDim:
                tst.w   (Demo_Time_left).w              ; has fade-out loop finished?
                bne.s   Level_FDLoop                    ; if not, loop
                rts                                     ; return to MainGameLoop
; End of function Level

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to set the player mode, which is forced to Sonic and Tails in
; the demo mode and in 2P mode
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_4450:
Level_SetPlayerMode:
                cmpi.b  #GameModeID_TitleCard|GameModeID_Demo,(Game_Mode).w  ; pre-level demo mode?
                beq.s   +                               ; if yes, branch
                tst.w   (Two_player_mode).w             ; 2P mode?
                bne.s   +                               ; if yes, branch
                move.w  (Player_option).w,(Player_mode).w  ; use the option chosen in the Options screen
                rts
+
                move.w  #0,(Player_mode).w              ; force Sonic and Tails
                rts
; End of function Level_SetPlayerMode

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_446E:
InitPlayers:
                move.w  (Player_mode).w,d0
                bne.s   InitPlayers_Alone               ; branch if this isn't a Sonic and Tails game

                move.b  #ObjID_Sonic,(MainCharacter+id).w  ; load Obj01 Sonic object at $FFFFB000
                move.b  #ObjID_SpindashDust,(Sonic_Dust+id).w  ; load Obj08 Sonic's spindash dust/splash object at $FFFFD100

                cmpi.b  #wing_fortress_zone,(Current_Zone).w
                beq.s   +                               ; skip loading Tails if this is WFZ
                cmpi.b  #death_egg_zone,(Current_Zone).w
                beq.s   +                               ; skip loading Tails if this is DEZ
                cmpi.b  #sky_chase_zone,(Current_Zone).w
                beq.s   +                               ; skip loading Tails if this is SCZ

                move.b  #ObjID_Tails,(Sidekick+id).w    ; load Obj02 Tails object at $FFFFB040
                move.w  (MainCharacter+x_pos).w,(Sidekick+x_pos).w
                move.w  (MainCharacter+y_pos).w,(Sidekick+y_pos).w
                subi.w  #$20,(Sidekick+x_pos).w
                addi_.w #4,(Sidekick+y_pos).w
                move.b  #ObjID_SpindashDust,(Tails_Dust+id).w  ; load Obj08 Tails' spindash dust/splash object at $FFFFD140
+
                rts
; ===========================================================================
; loc_44BE:
InitPlayers_Alone:                                      ; either Sonic or Tails but not both
                subq.w  #1,d0
                bne.s   InitPlayers_TailsAlone          ; branch if this is a Tails alone game

                move.b  #ObjID_Sonic,(MainCharacter+id).w  ; load Obj01 Sonic object at $FFFFB000
                move.b  #ObjID_SpindashDust,(Sonic_Dust+id).w  ; load Obj08 Sonic's spindash dust/splash object at $FFFFD100
                rts
; ===========================================================================
; loc_44D0:
InitPlayers_TailsAlone:
                move.b  #ObjID_Tails,(MainCharacter+id).w  ; load Obj02 Tails object at $FFFFB000
                move.b  #ObjID_SpindashDust,(Tails_Dust+id).w  ; load Obj08 Tails' spindash dust/splash object at $FFFFD100
                addi_.w #4,(MainCharacter+y_pos).w
                rts
; End of function InitPlayers

; ---------------------------------------------------------------------------
; Subroutine to move the water or oil surface sprites to where the screen is at
; (the closest match I could find to this subroutine in Sonic 1 is Obj1B_Action)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_44E4:
