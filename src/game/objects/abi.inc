; ---------------------------------------------------------------------------
; Object Status Table offsets (for everything between Object_RAM and Primary_Collision)
; ---------------------------------------------------------------------------
; universally followed object conventions:
id              =       0                               ; object ID (if you change this, change insn1op and insn2op in s2.macrosetup.asm, if you still use them)
render_flags    =       1                               ; bitfield ; bit 7 = onscreen flag, bit 0 = x mirror, bit 1 = y mirror, bit 2 = coordinate system, bit 6 = render subobjects
art_tile        =       2                               ; and 3 ; start of sprite's art
mappings        =       4                               ; and 5 and 6 and 7
x_pos           =       8                               ; and 9 ... some objects use $A and $B as well when extra precision is required (see ObjectMove) ... for screen-space objects this is called x_pixel instead
x_sub           =       $A                              ; and $B
y_pos           =       $C                              ; and $D ... some objects use $E and $F as well when extra precision is required ... screen-space objects use y_pixel instead
y_sub           =       $E                              ; and $F
priority        =       $18                             ; 0 = front
width_pixels    =       $19
mapping_frame   =       $1A
; ---------------------------------------------------------------------------
; conventions followed by most objects:
x_vel                   =       $10                     ; and $11 ; horizontal velocity
y_vel                   =       $12                     ; and $13 ; vertical velocity
y_radius                =       $16                     ; collision height / 2
x_radius                =       $17                     ; collision width / 2
anim_frame              =       $1B
anim                    =       $1C
prev_anim               =       $1D
anim_frame_duration     =       $1E
status                  =       $22                     ; note: exact meaning depends on the object... for Sonic/Tails: bit 0: left-facing. bit 1: in-air. bit 2: spinning. bit 3: on-object. bit 4: roll-jumping. bit 5: pushing. bit 6: underwater
routine                 =       $24
routine_secondary       =       $25
angle                   =       $26                     ; angle about the z axis (360 degrees = 256)
; ---------------------------------------------------------------------------
; conventions followed by many objects but NOT Sonic/Tails:
collision_flags     =       $20
collision_property  =       $21
respawn_index       =       $23
subtype             =       $28
; ---------------------------------------------------------------------------
; conventions specific to Sonic/Tails (Obj01, Obj02, and ObjDB):
; note: $1F, $20, and $21 are unused and available (however, $1F is cleared by loc_A53A and ObjB2_Landed_on_plane)
inertia             =       $14                         ; and $15 ; directionless representation of speed... not updated in the air
flip_angle          =       $27                         ; angle about the x axis (360 degrees = 256) (twist/tumble)
air_left            =       $28
flip_turned         =       $29                         ; 0 for normal, 1 to invert flipping (it's a 180 degree rotation about the axis of Sonic's spine, so he stays in the same position but looks turned around)
obj_control         =       $2A                         ; 0 for normal, 1 for hanging or for resting on a flipper, $81 for going through CNZ/OOZ/MTZ tubes or stopped in CNZ cages or stoppers or flying if Tails
status_secondary    =       $2B
flips_remaining     =       $2C                         ; number of flip revolutions remaining
flip_speed          =       $2D                         ; number of flip revolutions per frame / 256
move_lock           =       $2E                         ; and $2F ; horizontal control lock, counts down to 0
invulnerable_time   =       $30                         ; and $31 ; time remaining until you stop blinking
invincibility_time  =       $32                         ; and $33 ; remaining
speedshoes_time     =       $34                         ; and $35 ; remaining
next_tilt           =       $36                         ; angle on ground in front of sprite
tilt                =       $37                         ; angle on ground
stick_to_convex     =       $38                         ; 0 for normal, 1 to make Sonic stick to convex surfaces like the rotating discs in Sonic 1 and 3 (unused in Sonic 2 but fully functional)
spindash_flag       =       $39                         ; 0 for normal, 1 for charging a spindash or forced rolling
pinball_mode        =       spindash_flag
spindash_counter    =       $3A                         ; and $3B
restart_countdown   =       spindash_counter            ; and 1+spindash_counter
jumping             =       $3C
interact            =       $3D                         ; RAM address of the last object Sonic stood on, minus $FFFFB000 and divided by $40
top_solid_bit       =       $3E                         ; the bit to check for top solidity (either $C or $E)
lrb_solid_bit       =       $3F                         ; the bit to check for left/right/bottom solidity (either $D or $F)
; ---------------------------------------------------------------------------
; conventions followed by several objects but NOT Sonic/Tails:
y_pixel         =       2+x_pos                         ; and 3+x_pos ; y coordinate for objects using screen-space coordinate system
x_pixel         =       x_pos                           ; and 1+x_pos ; x coordinate for objects using screen-space coordinate system
parent          =       objoff_3E                       ; and $3F ; address of object that owns or spawned this one, if applicable
; TODO: $2C is often parent instead (see LoadChildObject); consider defining parent2 = $2C and changing some objoff_2Cs to that
; ---------------------------------------------------------------------------
; conventions followed by some/most bosses:
boss_subtype            =       objoff_A
boss_invulnerable_time  =       objoff_14
boss_sine_count         =       mapping_frame
boss_routine            =       angle
boss_defeated           =       objoff_2C
boss_hitcount2          =       objoff_32
boss_hurt_sonic         =       objoff_38               ; flag set by collision response routine when Sonic has just been hurt (by boss?)
; ---------------------------------------------------------------------------
; when childsprites are activated (i.e. bit #6 of render_flags set)
next_subspr             =       $6
mainspr_mapframe        =       objoff_B
mainspr_width           =       objoff_E
mainspr_childsprites    =       objoff_F                ; amount of child sprites
mainspr_height          =       objoff_14
subspr_data             =       $10
sub2_x_pos              =       subspr_data+next_subspr*0+0  ; x_vel
sub2_y_pos              =       subspr_data+next_subspr*0+2  ; y_vel
sub2_mapframe           =       subspr_data+next_subspr*0+5
sub3_x_pos              =       subspr_data+next_subspr*1+0  ; y_radius
sub3_y_pos              =       subspr_data+next_subspr*1+2  ; priority
sub3_mapframe           =       subspr_data+next_subspr*1+5  ; anim_frame
sub4_x_pos              =       subspr_data+next_subspr*2+0  ; anim
sub4_y_pos              =       subspr_data+next_subspr*2+2  ; anim_frame_duration
sub4_mapframe           =       subspr_data+next_subspr*2+5  ; collision_property
sub5_x_pos              =       subspr_data+next_subspr*3+0  ; status
sub5_y_pos              =       subspr_data+next_subspr*3+2  ; routine
sub5_mapframe           =       subspr_data+next_subspr*3+5
sub6_x_pos              =       subspr_data+next_subspr*4+0  ; subtype
sub6_y_pos              =       subspr_data+next_subspr*4+2
sub6_mapframe           =       subspr_data+next_subspr*4+5
sub7_x_pos              =       subspr_data+next_subspr*5+0
sub7_y_pos              =       subspr_data+next_subspr*5+2
sub7_mapframe           =       subspr_data+next_subspr*5+5
sub8_x_pos              =       subspr_data+next_subspr*6+0
sub8_y_pos              =       subspr_data+next_subspr*6+2
sub8_mapframe           =       subspr_data+next_subspr*6+5
sub9_x_pos              =       subspr_data+next_subspr*7+0
sub9_y_pos              =       subspr_data+next_subspr*7+2
sub9_mapframe           =       subspr_data+next_subspr*7+5
; ---------------------------------------------------------------------------
; unknown or inconsistently used offsets that are not applicable to Sonic/Tails:
; (provided because rearrangement of the above values sometimes requires making space in here too)
objoff_A        =       x_sub+0                         ; note: x_pos can be 4 bytes, but sometimes the last 2 bytes of x_pos are used for other unrelated things
objoff_B        =       x_sub+1                         ; unused
objoff_E        =       y_sub+0                         ; unused
objoff_F        =       y_sub+1                         ; unused
objoff_10       =       x_vel
objoff_14       =       inertia+0
objoff_15       =       inertia+1
objoff_1F       =       anim_frame_duration+1
objoff_23       =       respawn_index
objoff_27       =       $27
objoff_28       =       subtype                         ; overlaps subtype, but a few objects use it for other things anyway
                enum    objoff_29=$29,objoff_2A=$2A,objoff_2B=$2B,objoff_2C=$2C,objoff_2D=$2D,objoff_2E=$2E,objoff_2F=$2F
                enum    objoff_30=$30,objoff_31=$31,objoff_32=$32,objoff_33=$33,objoff_34=$34,objoff_35=$35,objoff_36=$36,objoff_37=$37
                enum    objoff_38=$38,objoff_39=$39,objoff_3A=$3A,objoff_3B=$3B,objoff_3C=$3C,objoff_3D=$3D,objoff_3E=$3E,objoff_3F=$3F
; ---------------------------------------------------------------------------
; Special Stage object properties:
ss_dplc_timer           =       respawn_index
ss_x_pos                =       objoff_2A
ss_x_sub                =       objoff_2C
ss_y_pos                =       objoff_2E
ss_y_sub                =       objoff_30
ss_init_flip_timer      =       objoff_32
ss_flip_timer           =       objoff_33
ss_z_pos                =       objoff_34
ss_hurt_timer           =       objoff_36
ss_slide_timer          =       objoff_37
ss_parent               =       objoff_38
ss_rings_base           =       objoff_3C               ; word
ss_rings_hundreds       =       objoff_3C
ss_rings_tens           =       objoff_3D
ss_rings_units          =       objoff_3E
ss_last_angle_index     =       objoff_3F
; ---------------------------------------------------------------------------
; Sonic 1 equivalency table for SSTs:
obRender        =       render_flags
obGfx           =       art_tile
obMap           =       mappings
obX             =       x_pos
obScreenY       =       x_sub
obY             =       y_pos
obVelX          =       x_vel
obVelY          =       y_vel
obInertia       =       inertia
obHeight        =       y_radius
obWidth         =       x_radius
obPriority      =       priority
obActWid        =       width_pixels
obFrame         =       mapping_frame
obAniFrame      =       anim_frame
obAnim          =       anim
obPrevAni       =       prev_anim                       ; used to be called obNextAni in Sonic 1
obTimeFrame     =       anim_frame_duration
obColType       =       collision_flags
obColProp       =       collision_property
obStatus        =       status
obRespawnNo     =       respawn_index
obRoutine       =       routine
ob2ndRout       =       routine_secondary
obAngle         =       angle
obSubtype       =       subtype

; the following were specific to Sonic in Sonic 1
flashtime       =       invulnerable_time
inv_time        =       invincibility_time
shoetime        =       speedshoes_time
standonobject   =       interact

; ---------------------------------------------------------------------------
; property of all objects:
object_size_bits    =       6
object_size         =       1<<object_size_bits         ; the size of an object
next_object         =       object_size

; ---------------------------------------------------------------------------
; render_flags bitfield

render_flags.x_flip             =       0               ; Sprite mirrored horizontally
render_flags.y_flip             =       1               ; Sprite mirrored vertically
render_flags.level_fg           =       2               ; Move with level foreground
render_flags.level_bg           =       3               ; Move with level background; leftover from Sonic 1
render_flags.explicit_height    =       4               ; Draw culling uses `y_radius` instead of guessing a height
render_flags.static_mappings    =       5               ; Mappings pointer points directly to a lone sprite piece instead of a list of sprites
render_flags.multi_sprite       =       6               ; Object SST holds metadata for multiple sprites
render_flags.on_screen          =       7               ; Object is on-screen and was rendered on the previous frame

; ---------------------------------------------------------------------------
; status bitfield

status.player.x_flip                    =       render_flags.x_flip  ; Facing left
status.player.in_air                    =       1       ; Airborne
status.player.rolling                   =       2       ; Spinning, i.e. jumping or rolling
status.player.on_object                 =       3       ; Stood on an object rather than the level
status.player.rolljumping               =       4       ; Jumping whilst rolling; locks the player's controls
status.player.pushing                   =       5       ; Pressing against an object
status.player.underwater                =       6       ; Submersed
status.player.prevent_tails_respawn     =       7       ; Prevents AI Tails from respawning

status.player.ss.x_flip     =       render_flags.x_flip  ; Sprite mirrored horizontally
status.player.ss.y_flip     =       render_flags.y_flip  ; Sprite mirrored vertically
status.player.ss.jumping    =       2                   ; Jumping
status.player.ss.slowing    =       6                   ; Coming to a stop after moving or landing

status.npc.x_flip           =       render_flags.x_flip  ; Facing right
status.npc.y_flip           =       render_flags.y_flip  ; Facing up
status.npc.misc             =       2                   ; Used for various purposes by bosses
status.npc.p1_standing      =       3                   ; Stood on by player 1
status.npc.p2_standing      =       4                   ; Stood on by player 2
status.npc.p1_pushing       =       5                   ; Pushed by player 1
status.npc.p2_pushing       =       6                   ; Pushed by player 2
status.npc.no_balancing     =       7                   ; Prevents player from performing their balancing animation whilst stood upon this object. Also set when the object is destroyed by the player

; ---------------------------------------------------------------------------
; status_secondary bitfield

status_secondary.shield         =       0
status_secondary.invincible     =       1
status_secondary.speed_shoes    =       2
status_secondary.sliding        =       7

; Ugly old constants, kept for backwards-compatibility

; status_secondary variable bit numbers
status_sec_hasShield:       EQU     status_secondary.shield
status_sec_isInvincible:    EQU     status_secondary.invincible
status_sec_hasSpeedShoes:   EQU     status_secondary.speed_shoes
status_sec_isSliding:       EQU     status_secondary.sliding
; status_secondary variable masks (1 << x == pow(2, x))
status_sec_hasShield_mask:      EQU     1<<status_sec_hasShield  ; $01
status_sec_isInvincible_mask:   EQU     1<<status_sec_isInvincible  ; $02
status_sec_hasSpeedShoes_mask:  EQU     1<<status_sec_hasSpeedShoes  ; $04
status_sec_isSliding_mask:      EQU     1<<status_sec_isSliding  ; $80

; ---------------------------------------------------------------------------
; Bits 3-6 of an object's status after a SolidObject call is a
; bitfield with the following meaning:
p1_standing_bit     =       status.npc.p1_standing
p2_standing_bit     =       p1_standing_bit + 1

p1_standing     =       1<<p1_standing_bit
p2_standing     =       1<<p2_standing_bit

pushing_bit_delta   =       status.npc.p1_pushing-status.npc.p1_standing
p1_pushing_bit      =       p1_standing_bit + pushing_bit_delta
p2_pushing_bit      =       p1_pushing_bit + 1

p1_pushing      =       1<<p1_pushing_bit
p2_pushing      =       1<<p2_pushing_bit

standing_mask   =       p1_standing|p2_standing
pushing_mask    =       p1_pushing|p2_pushing

; ---------------------------------------------------------------------------
; The high word of d6 after a SolidObject call is a bitfield
; with the following meaning:
p1_touch_side_bit   =       0
p2_touch_side_bit   =       p1_touch_side_bit + 1

p1_touch_side   =       1<<p1_touch_side_bit
p2_touch_side   =       1<<p2_touch_side_bit

touch_side_mask     =       p1_touch_side|p2_touch_side

p1_touch_bottom_bit     =       p1_touch_side_bit + pushing_bit_delta
p2_touch_bottom_bit     =       p1_touch_bottom_bit + 1

p1_touch_bottom     =       1<<p1_touch_bottom_bit
p2_touch_bottom     =       1<<p2_touch_bottom_bit

touch_bottom_mask   =       p1_touch_bottom|p2_touch_bottom

p1_touch_top_bit    =       p1_touch_bottom_bit + pushing_bit_delta
p2_touch_top_bit    =       p1_touch_top_bit + 1

p1_touch_top    =       1<<p1_touch_top_bit
p2_touch_top    =       1<<p2_touch_top_bit

touch_top_mask  =       p1_touch_top|p2_touch_top

; ---------------------------------------------------------------------------
; Scroll Flags
scroll_flag_fg_up       =       0
scroll_flag_fg_down     =       1
scroll_flag_fg_left     =       2
scroll_flag_fg_right    =       3

scroll_flag_bg1_up                  =       0
scroll_flag_bg1_down                =       scroll_flag_bg1_up + 1
scroll_flag_bg1_left                =       2
scroll_flag_bg1_right               =       scroll_flag_bg1_left + 1
scroll_flag_bg1_up_whole_row        =       4
scroll_flag_bg1_down_whole_row      =       scroll_flag_bg1_up_whole_row + 1
scroll_flag_bg1_up_whole_row_2      =       6
scroll_flag_bg1_down_whole_row_2    =       scroll_flag_bg1_up_whole_row_2 + 1

scroll_flag_bg2_left    =       0
scroll_flag_bg2_right   =       1

scroll_flag_bg3_left    =       0
scroll_flag_bg3_right   =       1

scroll_flag_advanced_bg_up      =       0
scroll_flag_advanced_bg_down    =       1
scroll_flag_advanced_bg1_left   =       2
scroll_flag_advanced_bg1_right  =       3
scroll_flag_advanced_bg2_left   =       4
scroll_flag_advanced_bg2_right  =       5
scroll_flag_advanced_bg3_left   =       6
scroll_flag_advanced_bg3_right  =       7

; ---------------------------------------------------------------------------
; Controller Buttons
;
; Buttons bit numbers
button_up:      EQU     0
button_down:    EQU     1
button_left:    EQU     2
button_right:   EQU     3
button_B:       EQU     4
button_C:       EQU     5
button_A:       EQU     6
button_start:   EQU     7
; Buttons masks (1 << x == pow(2, x))
button_up_mask:     EQU     1<<button_up                ; $01
button_down_mask:   EQU     1<<button_down              ; $02
button_left_mask:   EQU     1<<button_left              ; $04
button_right_mask:  EQU     1<<button_right             ; $08
button_B_mask:      EQU     1<<button_B                 ; $10
button_C_mask:      EQU     1<<button_C                 ; $20
button_A_mask:      EQU     1<<button_A                 ; $40
button_start_mask:  EQU     1<<button_start             ; $80

; ---------------------------------------------------------------------------
; Casino night bumpers
bumper_id       =       0
bumper_x        =       2
bumper_y        =       4
next_bumper     =       6
prev_bumper_x   =       bumper_x-next_bumper
