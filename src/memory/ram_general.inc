; ---------------------------------------------------------------------------
; I run the main 68k RAM addresses through this function
; to let them work in both 16-bit and 32-bit addressing modes
ramaddr         function x,-(-x)&$FFFFFFFF

; ---------------------------------------------------------------------------
; RAM variables - General
                phase   ramaddr($FFFF0000)              ; Pretend we're in the RAM
RAM_Start:
RAM_Mirror_Start                =       (RAM_Start&$FFFFFF)-$10000  ; lower mirror used by original layout and demo code
Intentional_Crash_OddAddress    =       1               ; original deliberate odd-address word access

Chunk_Table:    ds.b    $8000                           ; was "Metablock_Table"
Chunk_Table_End:

Level_Layout:   ds.b    $1000
Level_Layout_End:

Block_Table:    ds.w    $C00
Block_Table_End:

TempArray_LayerDef:     ds.b    $200                    ; used by some layer deformation routines
Decomp_Buffer:          ds.b    $200
Object_Display_Lists:   ds.b    object_display_list_size*total_object_display_lists  ; in custom format before being converted and stored in Sprite_Table/Sprite_Table_P2
Object_Display_Lists_End:

Object_RAM:                                             ; The various objects in the game are loaded in this area
    ; Each game mode uses different objects, so some slots are reused
    ; The section below declares labels for the objects used in main gameplay
    ; Objects for other game modes are declared further down
Reserved_Object_RAM:
MainCharacter:                                          ; first object (usually Sonic except in a Tails Alone game)
                ds.b    object_size
Sidekick:                                               ; second object (Tails in a Sonic and Tails game)
                ds.b    object_size
TitleCard:
TitleCard_ZoneName:                                     ; level title card: zone name
GameOver_GameText:                                      ; "GAME" from GAME OVER
TimeOver_TimeText:                                      ; "TIME" from TIME OVER
                ds.b    object_size
TitleCard_Zone:                                         ; level title card: "ZONE"
GameOver_OverText:                                      ; "OVER" from GAME OVER
TimeOver_OverText:                                      ; "OVER" from TIME OVER
                ds.b    object_size
TitleCard_ActNumber:                                    ; level title card: act number
                ds.b    object_size
TitleCard_Background:                                   ; level title card: background
                ds.b    object_size
TitleCard_Bottom:                                       ; level title card: yellow part at the bottom
                ds.b    object_size
TitleCard_Left:                                         ; level title card: red part on the left
                ds.b    object_size

    ; Reserved object RAM, free slots
                ds.b    object_size
                ds.b    object_size
                ds.b    object_size
                ds.b    object_size
                ds.b    object_size

CPZPylon:                                               ; Pylon in the foreground in CPZ
                ds.b    object_size
WaterSurface1:                                          ; First water surface
Oil:                                                    ; Oil at the bottom of OOZ
                ds.b    object_size
WaterSurface2:                                          ; Second water surface
                ds.b    object_size
Reserved_Object_RAM_End:

Dynamic_Object_RAM:                                     ; Dynamic object RAM
                ds.b    $70*object_size
Dynamic_Object_RAM_End:
; 2P mode reserves 6 'blocks' of 12 RAM slots at the end
Dynamic_Object_RAM_2P_End   =       Dynamic_Object_RAM_End - ($C * 6) * object_size

Object_RAM_End:

SS_Shared_RAM:

LevelOnly_Object_RAM:
Tails_Tails:                                            ; address of the Tail's Tails object
                ds.b    object_size
SuperSonicStars:
                ds.b    object_size
Sonic_BreathingBubbles:                                 ; Sonic's breathing bubbles
                ds.b    object_size
Tails_BreathingBubbles:                                 ; Tails' breathing bubbles
                ds.b    object_size
Sonic_Dust:                                             ; Sonic's spin dash dust
                ds.b    object_size
Tails_Dust:                                             ; Tails' spin dash dust
                ds.b    object_size
Sonic_Shield:
                ds.b    object_size
Tails_Shield:
                ds.b    object_size
Sonic_InvincibilityStars:
                ds.b    object_size
                ds.b    object_size
                ds.b    object_size
                ds.b    object_size
Tails_InvincibilityStars:
                ds.b    object_size
                ds.b    object_size
                ds.b    object_size
                ds.b    object_size
LevelOnly_Object_RAM_End:

                ds.b    $200                            ; unused

Primary_Collision:      ds.b    $300
Secondary_Collision:    ds.b    $300

SS_Shared_RAM_End:

VDP_Command_Buffer:         ds.w    7*$12               ; stores 18 ($12) VDP commands to issue the next time ProcessDMAQueue is called
VDP_Command_Buffer_Slot:    ds.l    1                   ; stores the address of the next open slot for a queued VDP command

Sprite_Table_P2:    ds.b    $280                        ; Sprite attribute table buffer for the bottom split screen in 2-player mode
                ds.b    $80                             ; unused, but SAT buffer can spill over into this area when there are too many sprites on-screen

HorizontalScrollBuffer  struct  dots
                ds.l    screen_height                   ; Total lines on the screen
                ds.l    16                              ; A bug/optimisation in 'Swscrl_CPZ' causes these values to be overflowed into
                ds.b    $40                             ; These are just unused
HorizontalScrollBuffer  endstruct

Horiz_Scroll_Buf:   HorizontalScrollBuffer

Sonic_Stat_Record_Buf:  ds.b    $100

Sonic_Pos_Record_Buf:   ds.b    $100
Sonic_Pos_Record_Buf_End:

Tails_Pos_Record_Buf:   ds.b    $100
Tails_Pos_Record_Buf_End:

CNZ_saucer_data:    ds.b    $40                         ; the number of saucer bumpers in a group which have been destroyed. Used to decide when to give 500 points instead of 10
CNZ_saucer_data_End:
                ds.b    $C0                             ; $FFFFE740-$FFFFE7FF ; unused as far as I can tell
Ring_Positions: ds.b    $600
Ring_Positions_End:

Camera_RAM:

Camera_Positions:
Camera_X_pos:       ds.l    1
Camera_Y_pos:       ds.l    1
Camera_BG_X_pos:    ds.l    1                           ; only used sometimes as the layer deformation makes it sort of redundant
Camera_BG_Y_pos:    ds.l    1
Camera_BG2_X_pos:   ds.l    1                           ; used in CPZ
Camera_BG2_Y_pos:   ds.l    1                           ; used in CPZ
Camera_BG3_X_pos:   ds.l    1                           ; unused (only initialised at beginning of level)?
Camera_BG3_Y_pos:   ds.l    1                           ; unused (only initialised at beginning of level)?
Camera_Positions_End:

Camera_Positions_P2:
Camera_X_pos_P2:        ds.l    1
Camera_Y_pos_P2:        ds.l    1
Camera_BG_X_pos_P2:     ds.l    1                       ; only used sometimes as the layer deformation makes it sort of redundant
Camera_BG_Y_pos_P2:     ds.l    1
Camera_BG2_X_pos_P2:    ds.l    1                       ; unused (only initialised at beginning of level)?
Camera_BG2_Y_pos_P2:    ds.l    1                       ; unused (only initialised at beginning of level)?
Camera_BG3_X_pos_P2:    ds.l    1                       ; unused (only initialised at beginning of level)?
Camera_BG3_Y_pos_P2:    ds.l    1                       ; unused (only initialised at beginning of level)?
Camera_Positions_P2_End:

Block_Crossed_Flags:
Horiz_block_crossed_flag:       ds.b    1               ; toggles between 0 and $10 when you cross a block boundary horizontally
Verti_block_crossed_flag:       ds.b    1               ; toggles between 0 and $10 when you cross a block boundary vertically
Horiz_block_crossed_flag_BG:    ds.b    1               ; toggles between 0 and $10 when background camera crosses a block boundary horizontally
Verti_block_crossed_flag_BG:    ds.b    1               ; toggles between 0 and $10 when background camera crosses a block boundary vertically
Horiz_block_crossed_flag_BG2:   ds.b    1               ; used in CPZ
                ds.b    1                               ; $FFFFEE45 ; seems unused
Horiz_block_crossed_flag_BG3:   ds.b    1
                ds.b    1                               ; $FFFFEE47 ; seems unused
Block_Crossed_Flags_End:

Block_Crossed_Flags_P2:
Horiz_block_crossed_flag_P2:    ds.b    1               ; toggles between 0 and $10 when you cross a block boundary horizontally
Verti_block_crossed_flag_P2:    ds.b    1               ; toggles between 0 and $10 when you cross a block boundary vertically
                ds.b    6                               ; $FFFFEE4A-$FFFFEE4F ; seems unused
Block_Crossed_Flags_P2_End:

Scroll_Flags_All:
Scroll_flags:       ds.w    1                           ; bitfield ; bit 0 = redraw top row, bit 1 = redraw bottom row, bit 2 = redraw left-most column, bit 3 = redraw right-most column
Scroll_flags_BG:    ds.w    1                           ; bitfield ; bits 0-3 as above, bit 4 = redraw top row (except leftmost block), bit 5 = redraw bottom row (except leftmost block), bits 6-7 = as bits 0-1
Scroll_flags_BG2:   ds.w    1                           ; bitfield ; essentially unused; bit 0 = redraw left-most column, bit 1 = redraw right-most column
Scroll_flags_BG3:   ds.w    1                           ; bitfield ; for CPZ; bits 0-3 as Scroll_flags_BG but using Y-dependent BG camera; bits 4-5 = bits 2-3; bits 6-7 = bits 2-3
Scroll_Flags_All_End:

Scroll_Flags_All_P2:
Scroll_flags_P2:        ds.w    1                       ; bitfield ; bit 0 = redraw top row, bit 1 = redraw bottom row, bit 2 = redraw left-most column, bit 3 = redraw right-most column
Scroll_flags_BG_P2:     ds.w    1                       ; bitfield ; bits 0-3 as above, bit 4 = redraw top row (except leftmost block), bit 5 = redraw bottom row (except leftmost block), bits 6-7 = as bits 0-1
Scroll_flags_BG2_P2:    ds.w    1                       ; bitfield ; essentially unused; bit 0 = redraw left-most column, bit 1 = redraw right-most column
Scroll_flags_BG3_P2:    ds.w    1                       ; bitfield ; for CPZ; bits 0-3 as Scroll_flags_BG but using Y-dependent BG camera; bits 4-5 = bits 2-3; bits 6-7 = bits 2-3
Scroll_Flags_All_P2_End:

Camera_Positions_Copy:
Camera_RAM_copy:    ds.l    2                           ; copied over every V-int
Camera_BG_copy:     ds.l    2                           ; copied over every V-int
Camera_BG2_copy:    ds.l    2                           ; copied over every V-int
Camera_BG3_copy:    ds.l    2                           ; copied over every V-int
Camera_Positions_Copy_End:

Camera_Positions_Copy_P2:
Camera_P2_copy: ds.l    8                               ; copied over every V-int
Camera_Positions_Copy_P2_End:

Scroll_Flags_Copy_All:
Scroll_flags_copy:      ds.w    1                       ; copied over every V-int
Scroll_flags_BG_copy:   ds.w    1                       ; copied over every V-int
Scroll_flags_BG2_copy:  ds.w    1                       ; copied over every V-int
Scroll_flags_BG3_copy:  ds.w    1                       ; copied over every V-int
Scroll_Flags_Copy_All_End:

Scroll_Flags_Copy_All_P2:
Scroll_flags_copy_P2:       ds.w    1                   ; copied over every V-int
Scroll_flags_BG_copy_P2:    ds.w    1                   ; copied over every V-int
Scroll_flags_BG2_copy_P2:   ds.w    1                   ; copied over every V-int
Scroll_flags_BG3_copy_P2:   ds.w    1                   ; copied over every V-int
Scroll_Flags_Copy_All_P2_End:

Camera_Difference:
Camera_X_pos_diff:  ds.w    1                           ; (new X pos - old X pos) * 256
Camera_Y_pos_diff:  ds.w    1                           ; (new Y pos - old Y pos) * 256
Camera_Difference_End:

Camera_BG_X_pos_diff:   ds.w    1                       ; Effective camera change used in WFZ ending and HTZ screen shake
Camera_BG_Y_pos_diff:   ds.w    1                       ; Effective camera change used in WFZ ending and HTZ screen shake

Camera_Difference_P2:
Camera_X_pos_diff_P2:   ds.w    1                       ; (new X pos - old X pos) * 256
Camera_Y_pos_diff_P2:   ds.w    1                       ; (new Y pos - old Y pos) * 256
Camera_Difference_P2_End:

Screen_Shaking_Flag_HTZ:    ds.b    1                   ; activates screen shaking code in HTZ's layer deformation routine
Screen_Shaking_Flag:        ds.b    1                   ; activates screen shaking code (if existent) in layer deformation routine
Scroll_lock:                ds.b    1                   ; set to 1 to stop all scrolling for P1
Scroll_lock_P2:             ds.b    1                   ; set to 1 to stop all scrolling for P2
Camera_Min_X_pos_target:    ds.w    1                   ; unused, except on write in LevelSizeLoad
Camera_Max_X_pos_target:    ds.w    1                   ; unused
Camera_Min_Y_pos_target:    ds.w    1                   ; same as above. The write being a long also overwrites the address below
Camera_Max_Y_pos_target:    ds.w    1

Camera_Boundaries:
Camera_Min_X_pos:   ds.w    1
Camera_Max_X_pos:   ds.w    1
Camera_Min_Y_pos:   ds.w    1
Camera_Max_Y_pos:   ds.w    1
Camera_Boundaries_End:

Camera_Delay:
Horiz_scroll_delay_val: ds.w    1                       ; if its value is a, where a != 0, X scrolling will be based on the player's X position a-1 frames ago
Sonic_Pos_Record_Index: ds.w    1                       ; into Sonic_Pos_Record_Buf and Sonic_Stat_Record_Buf
Camera_Delay_End:

Camera_Delay_P2:
Horiz_scroll_delay_val_P2:  ds.w    1
Tails_Pos_Record_Index:     ds.w    1                   ; into Tails_Pos_Record_Buf
Camera_Delay_P2_End:

Camera_Y_pos_bias:  ds.w    1                           ; added to y position for lookup/lookdown, $60 is center
Camera_Y_pos_bias_End:

Camera_Y_pos_bias_P2:   ds.w    1                       ; for Tails
Camera_Y_pos_bias_P2_End:

Deform_lock:    ds.b    1                               ; set to 1 to stop all deformation
                ds.b    1                               ; $FFFFEEDD ; seems unused
Camera_Max_Y_Pos_Changing:  ds.b    1
Dynamic_Resize_Routine:     ds.b    1
                ds.b    2                               ; $FFFFEEE0-$FFFFEEE1
Camera_BG_X_offset:     ds.w    1                       ; Used to control background scrolling in X in WFZ ending and HTZ screen shake
Camera_BG_Y_offset:     ds.w    1                       ; Used to control background scrolling in Y in WFZ ending and HTZ screen shake
HTZ_Terrain_Delay:      ds.w    1                       ; During HTZ screen shake, this is a delay between rising and sinking terrain during which there is no shaking
HTZ_Terrain_Direction:  ds.b    1                       ; During HTZ screen shake, 0 if terrain/lava is rising, 1 if lowering
                ds.b    3                               ; $FFFFEEE9-$FFFFEEEB ; seems unused
Vscroll_Factor_P2_HInt: ds.l    1
Camera_X_pos_copy:      ds.l    1
Camera_Y_pos_copy:      ds.l    1

Camera_Boundaries_P2:
Tails_Min_X_pos:    ds.w    1
Tails_Max_X_pos:    ds.w    1
Tails_Min_Y_pos:    ds.w    1                           ; seems not actually implemented (only written to)
Tails_Max_Y_pos:    ds.w    1
Camera_Boundaries_P2_End:

Camera_RAM_End:

Block_cache:            ds.w    512/16*2                ; Width of plane in blocks, with each block getting two words
Ring_consumption_table: ds.b    $80                     ; contains RAM addresses of rings currently being consumed
Ring_consumption_table_End:

Underwater_target_palette:          ds.b    palette_line_size  ; This is used by the screen-fading subroutines
Underwater_target_palette_line2:    ds.b    palette_line_size  ; While Underwater_palette contains the blacked-out palette caused by the fading,
Underwater_target_palette_line3:    ds.b    palette_line_size  ; Underwater_target_palette will contain the palette the screen will ultimately fade in to
Underwater_target_palette_line4:    ds.b    palette_line_size

Underwater_palette:         ds.b    palette_line_size   ; main palette for underwater parts of the screen
Underwater_palette_line2:   ds.b    palette_line_size
Underwater_palette_line3:   ds.b    palette_line_size
Underwater_palette_line4:   ds.b    palette_line_size

                ds.b    $500                            ; $FFFFF100-$FFFFF5FF ; unused, leftover from the Sonic 1 sound driver (and used by it when you port it to Sonic 2)

Game_Mode:      ds.b    1                               ; see GameModesArray (master level trigger, Mstr_Lvl_Trigger)
                ds.b    1                               ; unused
Ctrl_1_Logical:                                         ; 2 bytes
Ctrl_1_Held_Logical:    ds.b    1                       ; 1 byte
Ctrl_1_Press_Logical:   ds.b    1                       ; 1 byte
Ctrl_1:                                                 ; 2 bytes
Ctrl_1_Held:            ds.b    1                       ; 1 byte ; (pressed and held were switched around before)
Ctrl_1_Press:           ds.b    1                       ; 1 byte
Ctrl_2:                                                 ; 2 bytes
Ctrl_2_Held:            ds.b    1                       ; 1 byte
Ctrl_2_Press:           ds.b    1                       ; 1 byte
                ds.b    4                               ; $FFFFF608-$FFFFF60B ; seems unused
VDP_Reg1_val:   ds.w    1                               ; normal value of VDP register #1 when display is disabled
                ds.b    6                               ; $FFFFF60E-$FFFFF613 ; seems unused
Demo_Time_left: ds.w    1                               ; 2 bytes

Vscroll_Factor:
Vscroll_Factor_FG:      ds.w    1
Vscroll_Factor_BG:      ds.w    1
unk_F61A:               ds.l    1                       ; Only ever cleared, never used
Vscroll_Factor_P2:
Vscroll_Factor_P2_FG:   ds.w    1
Vscroll_Factor_P2_BG:   ds.w    1
Teleport_timer:         ds.b    1                       ; timer for teleport effect
Teleport_flag:          ds.b    1                       ; set when a teleport is in progress
Hint_counter_reserve:   ds.w    1                       ; Must contain a VDP command word, preferably a write to register $0A. Executed every V-INT
Palette_fade_range:                                     ; Range affected by the palette fading routines
Palette_fade_start:     ds.b    1                       ; Offset from the start of the palette to tell what range of the palette will be affected in the palette fading routines
Palette_fade_length:    ds.b    1                       ; Number of entries to change in the palette fading routines

MiscLevelVariables:
VIntSubE_RunCount:  ds.b    1
                ds.b    1                               ; $FFFFF629 ; seems unused
Vint_routine:   ds.b    1                               ; was "Delay_Time" ; routine counter for V-int
                ds.b    1                               ; $FFFFF62B ; seems unused
Sprite_count:   ds.b    1                               ; the number of sprites drawn in the current frame
                ds.b    5                               ; $FFFFF62D-$FFFFF631 ; seems unused
PalCycle_Frame: ds.w    1                               ; ColorID loaded in PalCycle
PalCycle_Timer: ds.w    1                               ; number of frames until next PalCycle call
RNG_seed:       ds.l    1                               ; used for random number generation
Game_paused:    ds.w    1
                ds.b    4                               ; $FFFFF63C-$FFFFF63F ; seems unused
DMA_data_thunk: ds.w    1                               ; Used as a RAM holder for the final DMA command word. Data will NOT be preserved across V-INTs, so consider this space reserved
                ds.w    1                               ; $FFFFF642-$FFFFF643 ; seems unused
Hint_flag:      ds.w    1                               ; unless this is 1, H-int won't run

Water_Level_1:          ds.w    1
Water_Level_2:          ds.w    1
Water_Level_3:          ds.w    1
Water_on:               ds.b    1                       ; is set based on Water_flag
Water_routine:          ds.b    1
Water_fullscreen_flag:  ds.b    1                       ; was "Water_move"
Do_Updates_in_H_int:    ds.b    1

PalCycle_Frame_CNZ:     ds.w    1
PalCycle_Frame2:        ds.w    1
PalCycle_Frame3:        ds.w    1
PalCycle_Frame2_CNZ:    ds.w    1
                ds.b    4                               ; $FFFFF658-$FFFFF65B ; seems unused
Palette_frame:          ds.w    1
Palette_timer:          ds.b    1                       ; was "Palette_frame_count"
Super_Sonic_palette:    ds.b    1                       ; 0 = off | 1 = fading | -1 = fading done

DEZ_Eggman:                                             ; Word
DEZ_Shake_Timer:                                        ; Word
WFZ_LevEvent_Subrout:                                   ; Word
SegaScr_PalDone_Flag:                                   ; Byte (cleared once as a word)
Credits_Trigger:        ds.b    1                       ; cleared as a word a couple times
Ending_PalCycle_flag:   ds.b    1

SegaScr_VInt_Subrout:
Ending_VInt_Subrout:
WFZ_BG_Y_Speed: ds.w    1
                ds.w    1                               ; $FFFFF664-$FFFFF665 ; seems unused
PalCycle_Timer2:    ds.w    1
PalCycle_Timer3:    ds.w    1

Ctrl_2_Logical:                                         ; 2 bytes
Ctrl_2_Held_Logical:        ds.b    1                   ; 1 byte
Ctrl_2_Press_Logical:       ds.b    1                   ; 1 byte
Sonic_Look_delay_counter:   ds.w    1                   ; 2 bytes
Tails_Look_delay_counter:   ds.w    1                   ; 2 bytes
Super_Sonic_frame_count:    ds.w    1
Camera_ARZ_BG_X_pos:        ds.l    1
                ds.b    $A                              ; $FFFFF676-$FFFFF67F ; seems unused
MiscLevelVariables_End

Plc_Buffer:     ds.b    6*16                            ; Pattern load queue (each entry is 6 bytes)
Plc_Buffer_Only_End:
    ; these seem to store nemesis decompression state so PLC processing can be spread out across frames
Plc_PtrNemCode:         ds.l    1                       ; pointer for nemesis decompression code
Plc_RepeatCount:        ds.l    1
Plc_PaletteIndex:       ds.l    1
Plc_PreviousRow:        ds.l    1
Plc_DataWord:           ds.l    1
Plc_ShiftValue:         ds.l    1
Plc_PatternsLeft:       ds.w    1                       ; amount of current entry remaining to decompress
Plc_FramePatternsLeft:  ds.w    1
                ds.b    4                               ; seems unused
Plc_Buffer_End:

Misc_Variables:
                ds.w    1                               ; unused

; extra variables for the second player (CPU) in 1-player mode
Tails_control_counter:  ds.w    1                       ; how long until the CPU takes control
Tails_respawn_counter:  ds.w    1
                ds.w    1                               ; unused
Tails_CPU_routine:  ds.w    1
Tails_CPU_target_x: ds.w    1
Tails_CPU_target_y: ds.w    1
Tails_interact_ID:  ds.b    1                           ; object ID of last object stood on
Tails_CPU_jumping:  ds.b    1

Rings_manager_routine:  ds.b    1
Level_started_flag:     ds.b    1

Ring_Manager_Addresses:
Ring_start_addr:    ds.w    1
Ring_end_addr:      ds.w    1
Ring_Manager_Addresses_End:

Ring_Manager_Addresses_P2:
Ring_start_addr_P2: ds.w    1
Ring_end_addr_P2:   ds.w    1
Ring_Manager_Addresses_P2_End:

CNZ_Bumper_routine: ds.b    1
CNZ_Bumper_UnkFlag: ds.b    1                           ; Set only, never used again

Bumper_Manager_Addresses:
CNZ_Visible_bumpers_start:  ds.l    1
CNZ_Visible_bumpers_end:    ds.l    1
Bumper_Manager_Addresses_End:

Bumper_Manager_Addresses_P2:
CNZ_Visible_bumpers_start_P2:   ds.l    1
CNZ_Visible_bumpers_end_P2:     ds.l    1
Bumper_Manager_Addresses_P2_End:

Screen_redraw_flag:     ds.b    1                       ; if whole screen needs to redraw, such as when you destroy that piston before the boss in WFZ
CPZ_UnkScroll_Timer:    ds.b    1                       ; Used only in unused CPZ scrolling function
WFZ_SCZ_Fire_Toggle:    ds.b    1
                ds.b    1                               ; $FFFFF72F ; seems unused
Water_flag:     ds.b    1                               ; if the level has water or oil
                ds.b    1                               ; $FFFFF731 ; seems unused
Demo_button_index_2P:   ds.w    1                       ; index into button press demo data, for player 2
Demo_press_counter_2P:  ds.w    1                       ; frames remaining until next button press, for player 2
Tornado_Velocity_X:     ds.w    1                       ; speed of Tails' plane in SCZ ($FFFFF736)
Tornado_Velocity_Y:     ds.w    1

Boss_variables:
Boss_spawn_delay:   ds.b    1                           ; Boss spawn delay timer
                ds.b    4                               ; $FFFFF73B-$FFFFF73E
Boss_CollisionRoutine:  ds.b    1
Boss_AnimationArray:    ds.b    $10                     ; up to $10 bytes; 2 bytes per entry
Ending_Routine:
Boss_X_pos:             ds.w    1
                ds.w    1                               ; Boss_MoveObject reads a long, but all other places in the game use only the high word
Boss_Y_pos:     ds.w    1
                ds.w    1                               ; same here
Boss_X_vel:     ds.w    1
Boss_Y_vel:     ds.w    1
Boss_Countdown: ds.w    1
                ds.w    1                               ; $FFFFF75E-$FFFFF75F ; unused
Boss_variables_end:

Sonic_Speeds:
Sonic_top_speed:    ds.w    1
Sonic_acceleration: ds.w    1
Sonic_deceleration: ds.w    1
Sonic_Speeds_End:

Sonic_LastLoadedDPLC:   ds.b    1                       ; mapping frame number when Sonic last had his tiles requested to be transferred from ROM to VRAM. can be set to a dummy value like -1 to force a refresh DMA. was: Sonic_mapping_frame
                ds.b    1                               ; $FFFFF767 ; seems unused
Primary_Angle:  ds.b    1
                ds.b    1                               ; $FFFFF769 ; seems unused
Secondary_Angle:    ds.b    1
                ds.b    1                               ; $FFFFF76B ; seems unused
Obj_placement_routine:  ds.b    1
                ds.b    1                               ; $FFFFF76D ; seems unused
Camera_X_pos_last:  ds.w    1                           ; Camera_X_pos_coarse from the previous frame
Camera_X_pos_last_End:

Object_Manager_Addresses:
Obj_load_addr_right:    ds.l    1                       ; contains the address of the next object to load when moving right
Obj_load_addr_left:     ds.l    1                       ; contains the address of the last object loaded when moving left
Object_Manager_Addresses_End:

Object_Manager_Addresses_P2:
Obj_load_addr_right_P2: ds.l    1
Obj_load_addr_left_P2:  ds.l    1
Object_Manager_Addresses_P2_End:

Object_manager_2P_RAM:                                  ; The next 16 bytes belong to this
Object_RAM_block_indices:       ds.b    6               ; seems to be an array of horizontal chunk positions, used for object position range checks
Player_1_loaded_object_blocks:  ds.b    3
Player_2_loaded_object_blocks:  ds.b    3

Camera_X_pos_last_P2:   ds.w    1
Camera_X_pos_last_P2_End:

Obj_respawn_index_P2:   ds.b    2                       ; respawn table indices of the next objects when moving left or right for the second player
Obj_respawn_index_P2_End:
Object_manager_2P_RAM_End:

Demo_button_index:  ds.w    1                           ; index into button press demo data, for player 1
Demo_press_counter: ds.b    1                           ; frames remaining until next button press, for player 1
                ds.b    1                               ; $FFFFF793 ; seems unused
PalChangeSpeed: ds.w    1
Collision_addr: ds.l    1
                ds.b    $D                              ; $FFFFF79A-$FFFFF7A6 ; seems unused
Boss_defeated_flag: ds.b    1
                ds.b    2                               ; $FFFFF7A8-$FFFFF7A9 ; seems unused
Current_Boss_ID:    ds.b    1
                ds.b    5                               ; $FFFFF7AB-$FFFFF7AF ; seems unused
MTZ_Platform_Cog_X:         ds.w    1                   ; X position of moving MTZ platform for cog animation
MTZCylinder_Angle_Sonic:    ds.b    1
MTZCylinder_Angle_Tails:    ds.b    1
                ds.b    $A                              ; $FFFFF7B4-$FFFFF7BD ; seems unused
BigRingGraphics:    ds.w    1                           ; S1 holdover
                ds.b    7                               ; $FFFFF7C0-$FFFFF7C6 ; seems unused
WindTunnel_flag:    ds.b    1
                ds.b    1                               ; $FFFFF7C8 ; seems unused
WindTunnel_holding_flag:    ds.b    1
                ds.b    2                               ; $FFFFF7CA-$FFFFF7CB ; seems unused
Control_Locked: ds.b    1
f_bigring:      ds.b    1                               ; Leftover from Sonic 1
                ds.b    1                               ; $FFFFF7CE ; seems unused
Control_Locked_P2:      ds.b    1
Chain_Bonus_counter:    ds.w    1                       ; counts up when you destroy things that give points, resets when you touch the ground
Bonus_Countdown_1:      ds.w    1                       ; level results time bonus or special stage Sonic ring bonus
Bonus_Countdown_2:      ds.w    1                       ; level results ring bonus or special stage Tails ring bonus
Update_Bonus_score:     ds.b    1
                ds.b    3                               ; $FFFFF7D7-$FFFFF7D9 ; seems unused

Camera_X_pos_coarse:    ds.w    1                       ; (Camera_X_pos - 128) / 256
Camera_X_pos_coarse_End:

Camera_X_pos_coarse_P2: ds.w    1
Camera_X_pos_coarse_P2_End:

Tails_LastLoadedDPLC:       ds.b    1                   ; mapping frame number when Tails last had his tiles requested to be transferred from ROM to VRAM. can be set to a dummy value like -1 to force a refresh DMA
TailsTails_LastLoadedDPLC:  ds.b    1                   ; mapping frame number when Tails' tails last had their tiles requested to be transferred from ROM to VRAM. can be set to a dummy value like -1 to force a refresh DMA
ButtonVine_Trigger:         ds.b    $10                 ; 16 bytes flag array, #subtype byte set when button/vine of respective subtype activated
Anim_Counters:              ds.b    $10                 ; $FFFFF7F0-$FFFFF7FF
Misc_Variables_End:

Sprite_Table:   ds.b    $280                            ; Sprite attribute table buffer
Sprite_Table_End:
                ds.b    $80                             ; unused, but SAT buffer can spill over into this area when there are too many sprites on-screen

Normal_palette:         ds.b    palette_line_size       ; main palette for non-underwater parts of the screen
Normal_palette_line2:   ds.b    palette_line_size
Normal_palette_line3:   ds.b    palette_line_size
Normal_palette_line4:   ds.b    palette_line_size
Normal_palette_End:

Target_palette:         ds.b    palette_line_size       ; This is used by the screen-fading subroutines
Target_palette_line2:   ds.b    palette_line_size       ; While Normal_palette contains the blacked-out palette caused by the fading,
Target_palette_line3:   ds.b    palette_line_size       ; Target_palette will contain the palette the screen will ultimately fade in to
Target_palette_line4:   ds.b    palette_line_size
Target_palette_End:

Object_Respawn_Table:
Obj_respawn_index:  ds.b    2                           ; respawn table indices of the next objects when moving left or right for the first player
Obj_respawn_index_End:
Obj_respawn_data:   ds.b    $BE                         ; For stock S2, $80 is enough
Obj_respawn_data_End:
                ds.b    $140                            ; Stack; the first $BE bytes are cleared by ObjectsManager_Init, with possibly disastrous consequences. At least $A0 bytes are needed
System_Stack:

CrossResetRAM:                                          ; RAM in this region will not be cleared after a soft reset

SS_2p_Flag:             ds.w    1                       ; $FFFFFE00-$FFFFFE01 ; seems unused
Level_Inactive_flag:    ds.w    1                       ; (2 bytes)
Level_frame_counter:    ds.w    1                       ; (2 bytes) (previously known as Timer_frames)
Debug_object:           ds.b    1
                ds.b    1                               ; $FFFFFE07 ; seems unused
Debug_placement_mode:   ds.b    1
                ds.b    1                               ; the whole word is tested, but the debug mode code uses only the low byte
Debug_Accel_Timer:  ds.b    1
Debug_Speed:        ds.b    1
Vint_runcount:      ds.l    1

Current_ZoneAndAct:                                     ; 2 bytes
Current_Zone:   ds.b    1                               ; 1 byte
Current_Act:    ds.b    1                               ; 1 byte
Life_count:     ds.b    1
                ds.b    3                               ; $FFFFFE13-$FFFFFE15 ; seems unused

Current_Special_StageAndAct:                            ; 2 bytes
Current_Special_Stage:  ds.b    1
Current_Special_Act:    ds.b    1
Continue_count:         ds.b    1
Super_Sonic_flag:       ds.b    1
Time_Over_flag:         ds.b    1
Extra_life_flags:       ds.b    1

; If set, the respective HUD element will be updated
Update_HUD_lives:   ds.b    1
Update_HUD_rings:   ds.b    1
Update_HUD_timer:   ds.b    1
Update_HUD_score:   ds.b    1

Ring_count:     ds.w    1                               ; 2 bytes
Timer:                                                  ; 4 bytes
Timer_minute_word:                                      ; 2 bytes
                ds.b    1                               ; filler
Timer_minute:   ds.b    1                               ; 1 byte
Timer_second:   ds.b    1                               ; 1 byte
Timer_frame:    ds.b    1                               ; 1 byte

Score:          ds.l    1                               ; 4 bytes
                ds.b    6                               ; $FFFFFE2A-$FFFFFE2F ; seems unused
Last_star_pole_hit:             ds.b    1               ; 1 byte -- max activated starpole ID in this act
Saved_Last_star_pole_hit:       ds.b    1
Saved_x_pos:                    ds.w    1
Saved_y_pos:                    ds.w    1
Saved_Ring_count:               ds.w    1
Saved_Timer:                    ds.l    1
Saved_art_tile:                 ds.w    1
Saved_Solid_bits:               ds.w    1
Saved_Camera_X_pos:             ds.w    1
Saved_Camera_Y_pos:             ds.w    1
Saved_Camera_BG_X_pos:          ds.w    1
Saved_Camera_BG_Y_pos:          ds.w    1
Saved_Camera_BG2_X_pos:         ds.w    1
Saved_Camera_BG2_Y_pos:         ds.w    1
Saved_Camera_BG3_X_pos:         ds.w    1
Saved_Camera_BG3_Y_pos:         ds.w    1
Saved_Water_Level:              ds.w    1
Saved_Water_routine:            ds.b    1
Saved_Water_move:               ds.b    1
Saved_Extra_life_flags:         ds.b    1
Saved_Extra_life_flags_2P:      ds.b    1               ; stored, but never restored
Saved_Camera_Max_Y_pos:         ds.w    1
Saved_Dynamic_Resize_Routine:   ds.b    1

                ds.b    5                               ; $FFFFFE59-$FFFFFE5D ; seems unused
Oscillating_Numbers:
Oscillation_Control:    ds.w    1
Oscillating_variables:
Oscillating_Data:       ds.w    $20

Logspike_anim_counter:      ds.b    1
Logspike_anim_frame:        ds.b    1
Rings_anim_counter:         ds.b    1
Rings_anim_frame:           ds.b    1
Unknown_anim_counter:       ds.b    1                   ; I think this was $FFFFFEC4 in the alpha
Unknown_anim_frame:         ds.b    1
Ring_spill_anim_counter:    ds.b    1                   ; scattered rings
Ring_spill_anim_frame:      ds.b    1
Ring_spill_anim_accum:      ds.w    1
                ds.b    6                               ; $FFFFFEA9-$FFFFFEAF ; seems unused, but cleared once
Oscillating_variables_End
                ds.b    $10                             ; $FFFFFEB0-$FFFFFEBF ; seems unused

; values for the second player (some of these only apply to 2-player games)
Tails_Speeds:
Tails_top_speed:    ds.w    1                           ; Tails_max_vel
Tails_acceleration: ds.w    1
Tails_deceleration: ds.w    1
Tails_Speeds_End:

Life_count_2P:          ds.b    1
Extra_life_flags_2P:    ds.b    1
Update_HUD_lives_2P:    ds.b    1
Update_HUD_rings_2P:    ds.b    1
Update_HUD_timer_2P:    ds.b    1
Update_HUD_score_2P:    ds.b    1                       ; mostly unused
Time_Over_flag_2P:      ds.b    1
                ds.b    3                               ; $FFFFFECD-$FFFFFECF ; seems unused
Ring_count_2P:  ds.w    1
Timer_2P:                                               ; 4 bytes
Timer_minute_word_2P:                                   ; 2 bytes
                ds.b    1                               ; filler
Timer_minute_2P:    ds.b    1                           ; 1 byte
Timer_second_2P:    ds.b    1                           ; 1 byte
Timer_frame_2P:     ds.b    1                           ; 1 byte
Score_2P:           ds.l    1
                ds.b    6                               ; $FFFFFEDA-$FFFFFEDF ; seems unused
Last_star_pole_hit_2P:          ds.b    1
Saved_Last_star_pole_hit_2P:    ds.b    1
Saved_x_pos_2P:                 ds.w    1
Saved_y_pos_2P:                 ds.w    1
Saved_Ring_count_2P:            ds.w    1
Saved_Timer_2P:                 ds.l    1
Saved_art_tile_2P:              ds.w    1
Saved_Solid_bits_2P:            ds.w    1
Rings_Collected:                ds.w    1               ; number of rings collected during an act in two player mode
Rings_Collected_2P:             ds.w    1
Monitors_Broken:                ds.w    1               ; number of monitors broken during an act in two player mode
Monitors_Broken_2P:             ds.w    1
Loser_Time_Left:                                        ; 2 bytes
                ds.b    1                               ; seconds
                ds.b    1                               ; frames

                ds.b    $16                             ; $FFFFFEFA-$FFFFFF0F ; seems unused
Results_Screen_2P:  ds.w    1                           ; 0 = act, 1 = zone, 2 = game, 3 = SS, 4 = SS all
                ds.b    $E                              ; $FFFFFF12-$FFFFFF1F ; seems unused

Results_Data_2P:                                        ; $18 (24) bytes
EHZ_Results_2P: ds.b    6                               ; 6 bytes
MCZ_Results_2P: ds.b    6                               ; 6 bytes
CNZ_Results_2P: ds.b    6                               ; 6 bytes
SS_Results_2P:  ds.b    6                               ; 6 bytes
Results_Data_2P_End:

SS_Total_Won:   ds.b    2                               ; 2 bytes (player 1 then player 2)
                ds.b    6                               ; $FFFFFF3A-$FFFFFF3F ; seems unused
Perfect_rings_left: ds.w    1
Perfect_rings_flag: ds.w    1
                ds.b    8                               ; $FFFFFF44-$FFFFFF4B ; seems unused

CreditsScreenIndex:
SlotMachineInUse:       ds.w    1
SlotMachineVariables:                                   ; $12 values
SlotMachine_Routine:    ds.b    1
SlotMachine_Timer:      ds.b    1
                ds.b    1                               ; $FFFFFF50 ; seems unused except for 1 write
SlotMachine_Index:      ds.b    1
SlotMachine_Reward:     ds.w    1
SlotMachine_Slot1Pos:   ds.w    1
SlotMachine_Slot1Speed: ds.b    1
SlotMachine_Slot1Rout:  ds.b    1
SlotMachine_Slot2Pos:   ds.w    1
SlotMachine_Slot2Speed: ds.b    1
SlotMachine_Slot2Rout:  ds.b    1
SlotMachine_Slot3Pos:   ds.w    1
SlotMachine_Slot3Speed: ds.b    1
SlotMachine_Slot3Rout:  ds.b    1

                ds.b    $10                             ; $FFFFFF60-$FFFFFF6F ; seems unused

Player_mode:    ds.w    1                               ; 0 = Sonic and Tails, 1 = Sonic, 2 = Tails
Player_option:  ds.w    1                               ; 0 = Sonic and Tails, 1 = Sonic, 2 = Tails

Two_player_items:   ds.w    1
                ds.b    $A                              ; $FFFFFF76-$FFFFFF7F ; seems unused

LevSel_HoldTimer:       ds.w    1
Level_select_zone:      ds.w    1
Sound_test_sound:       ds.w    1
Title_screen_option:    ds.b    1
                ds.b    1                               ; $FFFFFF87 ; unused
Current_Zone_2P:        ds.b    1
Current_Act_2P:         ds.b    1
Two_player_mode_copy:   ds.w    1
Options_menu_box:       ds.b    1
                ds.b    1                               ; $FFFFFF8D ; unused
Total_Bonus_Countdown:  ds.w    1

Level_Music:        ds.w    1
Bonus_Countdown_3:  ds.w    1
                ds.b    4                               ; $FFFFFF94-$FFFFFF97 ; seems unused
Game_Over_2P:   ds.w    1

                ds.b    6                               ; $FFFFFF9A-$FFFFFF9F ; seems unused

SS2p_RingBuffer:    ds.w    6
                ds.b    4                               ; $FFFFFFAC-$FFFFFFAF ; seems unused
Got_Emerald:        ds.b    1
Emerald_count:      ds.b    1
Got_Emeralds_array: ds.b    8                           ; Technically this is only 7 bytes long, but an 8th byte is cleared
                ds.b    6                               ; $FFFFFFBA-$FFFFFFBF ; filler
Next_Extra_life_score:      ds.l    1
Next_Extra_life_score_2P:   ds.l    1
Level_Has_Signpost:         ds.w    1                   ; 1 = signpost, 0 = boss or nothing
Signpost_prev_frame:        ds.b    1
                ds.b    1                               ; $FFFFFFCB ; seems unused
Camera_Min_Y_pos_Debug_Copy:    ds.w    1
Camera_Max_Y_pos_Debug_Copy:    ds.w    1

Level_select_flag:          ds.b    1
Slow_motion_flag:           ds.b    1                   ; This NEEDs to be after Level_select_flag because of the call to CheckCheats
Debug_options_flag:         ds.b    1                   ; if set, allows you to enable debug mode and "night mode"
S1_hidden_credits_flag:     ds.b    1                   ; Leftover from Sonic 1. This NEEDs to be after Debug_options_flag because of the call to CheckCheats
Correct_cheat_entries:      ds.w    1
Correct_cheat_entries_2:    ds.w    1                   ; for 14 continues or 7 emeralds codes

Two_player_mode:                ds.w    1               ; flag (0 for main game)
unk_FFDA:                       ds.w    1               ; Written to once at title screen, never read from
CnzBumper_LastIncomingAngle:    ds.b    1               ; Written to near CnzBumper_CalculateReflectedLaunch, never read from
CnzBumper_LastMirroredAngle:    ds.b    1               ; Written to near CnzBumper_CalculateReflectedLaunch, never read from
CnzBumper_LastLaunchTrigAngle:  ds.b    1               ; Written to near CnzBumper_CalculateReflectedLaunch, never read from
CnzBumper_LastIncidenceDelta:   ds.b    1               ; Written to near CnzBumper_CalculateReflectedLaunch, never read from

; Values in these variables are passed to the sound driver during V-INT
; They use a playlist index, not a sound test index
SoundQueue      STRUCT  DOTS
Music0:         ds.b    1
SFX0:           ds.b    1
SFX1:           ds.b    1
SFX2:           ds.b    1                               ; This one is never used, since nothing ever gets written to it
Music1:         ds.b    1
SoundQueue      ENDSTRUCT

Sound_Queue:    SoundQueue

                ds.b    $B                              ; $FFFFFFE5-$FFFFFFEF ; seems unused

Demo_mode_flag:     ds.w    1                           ; 1 if a demo is playing (2 bytes)
Demo_number:        ds.w    1                           ; which demo will play next (2 bytes)
Ending_demo_number: ds.w    1                           ; zone for the ending demos (2 bytes, unused)
                ds.w    1
Graphics_Flags:     ds.w    1                           ; misc. bitfield
Debug_mode_flag:    ds.w    1                           ; (2 bytes)
Checksum_fourcc:    ds.l    1                           ; (4 bytes)

CrossResetRAM_End:

RAM_End

                if      * > 0                           ; Don't declare more space than the RAM can contain!
                fatal   "The RAM variable declarations are too large by $\{*} bytes."
                endif
                dephase
