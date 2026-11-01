; ---------------------------------------------------------------------------
; VRAM and tile art base addresses
; VRAM Reserved regions
VRAM_Plane_A_Name_Table             =       $C000       ; Extends until $CFFF
VRAM_Plane_B_Name_Table             =       $E000       ; Extends until $EFFF
VRAM_Plane_A_Name_Table_2P          =       $A000       ; Extends until $AFFF
VRAM_Plane_B_Name_Table_2P          =       $8000       ; Extends until $8FFF
VRAM_Plane_Table_Size               =       $1000       ; 64 cells x 32 cells x 2 bytes per cell
VRAM_Sprite_Attribute_Table         =       $F800       ; Extends until $FA7F
VRAM_Sprite_Attribute_Table_Size    =       $0280       ; 640 bytes
VRAM_Horiz_Scroll_Table             =       $FC00       ; Extends until $FF7F
VRAM_Horiz_Scroll_Table_Size        =       224*2*2     ; 224 lines * 2 bytes per entry * 2 PNTs

; VRAM Reserved regions, Sega screen
VRAM_SegaScr_Plane_A_Name_Table     =       $C000       ; Extends until $DFFF
VRAM_SegaScr_Plane_B_Name_Table     =       $A000       ; Extends until $BFFF
VRAM_SegaScr_Plane_Table_Size       =       $2000       ; 128 cells x 32 cells x 2 bytes per cell

; VRAM Reserved regions, Special Stage
VRAM_SS_Plane_A_Name_Table1     =       $C000           ; Extends until $DFFF
VRAM_SS_Plane_A_Name_Table2     =       $8000           ; Extends until $9FFF
VRAM_SS_Plane_B_Name_Table      =       $A000           ; Extends until $BFFF
VRAM_SS_Plane_Table_Size        =       $2000           ; 128 cells x 32 cells x 2 bytes per cell

; VRAM Reserved regions, Title screen
VRAM_TtlScr_Plane_A_Name_Table  =       $C000           ; Extends until $CFFF
VRAM_TtlScr_Plane_B_Name_Table  =       $E000           ; Extends until $EFFF
VRAM_TtlScr_Plane_Table_Size    =       $1000           ; 64 cells x 32 cells x 2 bytes per cell

; VRAM Reserved regions, Ending sequence and credits
VRAM_EndSeq_Plane_A_Name_Table      =       $C000       ; Extends until $DFFF
VRAM_EndSeq_Plane_B_Name_Table1     =       $E000       ; Extends until $EFFF (plane size is 64x32)
VRAM_EndSeq_Plane_B_Name_Table2     =       $4000       ; Extends until $5FFF
VRAM_EndSeq_Plane_Table_Size        =       $2000       ; 64 cells x 64 cells x 2 bytes per cell

; VRAM Reserved regions, menu screen
VRAM_Menu_Plane_A_Name_Table    =       $C000           ; Extends until $CFFF
VRAM_Menu_Plane_B_Name_Table    =       $E000           ; Extends until $EFFF
VRAM_Menu_Plane_Table_Size      =       $1000           ; 64 cells x 32 cells x 2 bytes per cell

; From here on, art tiles are used; VRAM address is art tile * $20
ArtTile_VRAM_Start  =       $0000

; Common to 1p and 2p menus
ArtTile_ArtNem_FontStuff    =       $0010

; Sega screen
ArtTile_ArtNem_Sega_Logo    =       $0001
ArtTile_ArtNem_Trails       =       $0080
ArtTile_ArtUnc_Giant_Sonic  =       $0088

; Title screen
ArtTile_ArtNem_Title                =       $0000
ArtTile_ArtNem_TitleSprites         =       $0150
ArtTile_ArtNem_MenuJunk             =       $03F2
ArtTile_ArtNem_Player1VS2           =       $0402
ArtTile_ArtNem_CreditText           =       $0500
ArtTile_ArtNem_FontStuff_TtlScr     =       $0680

; Credits screen
ArtTile_ArtNem_CreditText_CredScr   =       $0001

; Menu background
ArtTile_ArtNem_MenuBox  =       $0070

; Level select icons
ArtTile_ArtNem_LevelSelectPics  =       $0090

; 2p results screen
ArtTile_ArtNem_1P2PWins                 =       $0070
ArtTile_ArtNem_SpecialPlayerVSPlayer    =       $03DF
ArtTile_ArtNem_2p_Signpost              =       $05E8
ArtTile_TwoPlayerResults                =       $0600

; Special stage stuff
ArtTile_ArtNem_SpecialEmerald       =       $0174
ArtTile_ArtNem_SpecialMessages      =       $01A2
ArtTile_ArtNem_SpecialHUD           =       $01FA
ArtTile_ArtNem_SpecialFlatShadow    =       $023C
ArtTile_ArtNem_SpecialDiagShadow    =       $0262
ArtTile_ArtNem_SpecialSideShadow    =       $029C
ArtTile_ArtNem_SpecialExplosion     =       $02B5
ArtTile_ArtNem_SpecialSonic         =       $02E5
ArtTile_ArtNem_SpecialTails         =       $0300
ArtTile_ArtNem_SpecialTails_Tails   =       $0316
ArtTile_ArtNem_SpecialRings         =       $0322
ArtTile_ArtNem_SpecialStart         =       $038A
ArtTile_ArtNem_SpecialBomb          =       $038A
ArtTile_ArtNem_SpecialStageResults  =       $0590
ArtTile_ArtNem_SpecialBack          =       $0700
ArtTile_ArtNem_SpecialStars         =       $077F
ArtTile_ArtNem_SpecialTailsText     =       $07A4

; Ending
ArtTile_EndingCharacter             =       $0019
ArtTile_ArtNem_EndingFinalTornado   =       $0156
ArtTile_ArtNem_EndingPics           =       $0328
ArtTile_ArtNem_EndingMiniTornado    =       $0493

; S1 Ending
ArtTile_ArtNem_S1EndFlicky      =       $05A5
ArtTile_ArtNem_S1EndRabbit      =       $0553
ArtTile_ArtNem_S1EndPenguin     =       $0573
ArtTile_ArtNem_S1EndSeal        =       $0585
ArtTile_ArtNem_S1EndPig         =       $0593
ArtTile_ArtNem_S1EndChicken     =       $0565
ArtTile_ArtNem_S1EndSquirrel    =       $05B3

; Continue screen
ArtTile_ArtNem_ContinueTails        =       $0500
ArtTile_ArtNem_ContinueText         =       $0500
ArtTile_ArtNem_ContinueText_2       =       ArtTile_ArtNem_ContinueText + $24
ArtTile_ArtNem_MiniContinue         =       $0524
ArtTile_ContinueScreen_Additional   =       $0590
ArtTile_ContinueCountdown           =       $06FC

; ---------------------------------------------------------------------------
; Level art stuff
ArtTile_ArtKos_LevelArt             =       $0000
ArtTile_ArtKos_NumTiles_EHZ         =       $0393
ArtTile_ArtKos_NumTiles_CPZ         =       $0364
ArtTile_ArtKos_NumTiles_ARZ         =       $03F6
ArtTile_ArtKos_NumTiles_CNZ         =       $0331
ArtTile_ArtKos_NumTiles_HTZ_Main    =       $01FC       ; Until this tile, equal to EHZ tiles
ArtTile_ArtKos_NumTiles_HTZ_Sup     =       $0183       ; Overwrites several EHZ tiles
ArtTile_ArtKos_NumTiles_HTZ         =       ArtTile_ArtKos_NumTiles_HTZ_Main + ArtTile_ArtKos_NumTiles_HTZ_Sup - 1
ArtTile_ArtKos_NumTiles_MCZ         =       $03A9
ArtTile_ArtKos_NumTiles_OOZ         =       $02AA
ArtTile_ArtKos_NumTiles_MTZ         =       $0319
ArtTile_ArtKos_NumTiles_SCZ         =       $036E
ArtTile_ArtKos_NumTiles_WFZ_Main    =       $0307       ; Until this tile, equal to SCZ tiles
ArtTile_ArtKos_NumTiles_WFZ_Sup     =       $0073       ; Overwrites several SCZ tiles
ArtTile_ArtKos_NumTiles_WFZ         =       ArtTile_ArtKos_NumTiles_WFZ_Main + ArtTile_ArtKos_NumTiles_WFZ_Sup - 1
ArtTile_ArtKos_NumTiles_DEZ         =       $0326       ; Skips several CPZ tiles

; ---------------------------------------------------------------------------
; Shared badniks and objects

; Objects that use the same art tiles on all levels in which
; they are loaded, even if not all levels load them
ArtTile_ArtNem_WaterSurface     =       $0400
ArtTile_ArtNem_Button           =       $0424
ArtTile_ArtNem_HorizSpike       =       $042C
ArtTile_ArtNem_Spikes           =       $0434
ArtTile_ArtNem_DignlSprng       =       $043C
ArtTile_ArtNem_LeverSpring      =       $0440
ArtTile_ArtNem_VrtclSprng       =       $045C
ArtTile_ArtNem_HrzntlSprng      =       $0470

; EHZ, HTZ
ArtTile_ArtKos_Checkers     =       ArtTile_ArtKos_LevelArt+$0158
ArtTile_ArtUnc_Flowers1     =       $0394
ArtTile_ArtUnc_Flowers2     =       $0396
ArtTile_ArtUnc_Flowers3     =       $0398
ArtTile_ArtUnc_Flowers4     =       $039A
ArtTile_ArtNem_Buzzer       =       $03D2

; WFZ, SCZ
ArtTile_ArtNem_WfzHrzntlPrpllr  =       $03CD
ArtTile_ArtNem_Clouds           =       $054F
ArtTile_ArtNem_WfzVrtclPrpllr   =       $0561
ArtTile_ArtNem_Balkrie          =       $0565

; ---------------------------------------------------------------------------
; Level-specific objects and badniks

; EHZ
ArtTile_ArtUnc_EHZPulseBall     =       $039C
ArtTile_ArtNem_Waterfall        =       $039E
ArtTile_ArtNem_EHZ_Bridge       =       $03B6
ArtTile_ArtNem_Buzzer_Fireball  =       $03BE           ; Actually unused
ArtTile_ArtNem_Coconuts         =       $03EE
ArtTile_ArtNem_Masher           =       $0414
ArtTile_ArtUnc_EHZMountains     =       $0500

; MTZ
ArtTile_ArtNem_Shellcracker         =       $031C
ArtTile_ArtUnc_Lava                 =       $0340
ArtTile_ArtUnc_MTZCylinder          =       $034C
ArtTile_ArtUnc_MTZAnimBack_1        =       $035C
ArtTile_ArtUnc_MTZAnimBack_2        =       $0362
ArtTile_ArtNem_MtzSupernova         =       $0368
ArtTile_ArtNem_MtzWheel             =       $0378
ArtTile_ArtNem_MtzWheelIndent       =       $03F0
ArtTile_ArtNem_LavaCup              =       $03F9
ArtTile_ArtNem_BoltEnd_Rope         =       $03FD
ArtTile_ArtNem_MtzSteam             =       $0405
ArtTile_ArtNem_MtzSpikeBlock        =       $0414
ArtTile_ArtNem_MtzSpike             =       $041C
ArtTile_ArtNem_MtzMantis            =       $043C
ArtTile_ArtNem_MtzAsstBlocks        =       $0500
ArtTile_ArtNem_MtzLavaBubble        =       $0536
ArtTile_ArtNem_MtzCog               =       $055F
ArtTile_ArtNem_MtzSpinTubeFlash     =       $056B

; WFZ
ArtTile_ArtNem_WfzScratch               =       $0379
ArtTile_ArtNem_WfzTiltPlatforms         =       $0393
ArtTile_ArtNem_WfzVrtclLazer            =       $039F
ArtTile_ArtNem_WfzWallTurret            =       $03AB
ArtTile_ArtNem_WfzHrzntlLazer           =       $03C3
ArtTile_ArtNem_WfzConveyorBeltWheel     =       $03EA
ArtTile_ArtNem_WfzHook                  =       $03FA
ArtTile_ArtNem_WfzHook_Fudge            =       ArtTile_ArtNem_WfzHook + 4  ; Bad mappings
ArtTile_ArtNem_WfzBeltPlatform          =       $040E
ArtTile_ArtNem_WfzGunPlatform           =       $041A
ArtTile_ArtNem_WfzUnusedBadnik          =       $0450
ArtTile_ArtNem_WfzLaunchCatapult        =       $045C
ArtTile_ArtNem_WfzSwitch                =       $0461
ArtTile_ArtNem_WfzThrust                =       $0465
ArtTile_ArtNem_WfzFloatingPlatform      =       $046D
ArtTile_ArtNem_BreakPanels              =       $048C

; SCZ
ArtTile_ArtNem_Turtloid     =       $038A
ArtTile_ArtNem_Nebula       =       $036E

; HTZ
ArtTile_ArtNem_Rexon            =       $037E
ArtTile_ArtNem_HtzFireball1     =       $039E
ArtTile_ArtNem_HtzRock          =       $03B2
ArtTile_ArtNem_HtzSeeSaw        =       $03C6
ArtTile_ArtNem_Sol              =       $03DE
ArtTile_ArtNem_HtzZipline       =       $03E6
ArtTile_ArtNem_HtzFireball2     =       $0416
ArtTile_ArtNem_HtzValveBarrier  =       $0426
ArtTile_ArtUnc_HTZMountains     =       $0500
ArtTile_ArtUnc_HTZClouds        =       ArtTile_ArtUnc_HTZMountains + $18
ArtTile_ArtNem_Spiker           =       $0520

; OOZ
ArtTile_ArtUnc_OOZPulseBall         =       $02B6
ArtTile_ArtUnc_OOZSquareBall1       =       $02BA
ArtTile_ArtUnc_OOZSquareBall2       =       $02BE
ArtTile_ArtUnc_Oil1                 =       $02C2
ArtTile_ArtUnc_Oil2                 =       $02D2
ArtTile_ArtNem_OOZBurn              =       $02E2
ArtTile_ArtNem_OOZElevator          =       $02F4
ArtTile_ArtNem_SpikyThing           =       $030C
ArtTile_ArtNem_BurnerLid            =       $032C
ArtTile_ArtNem_StripedBlocksVert    =       $0332
ArtTile_ArtNem_Oilfall              =       $0336
ArtTile_ArtNem_Oilfall2             =       $0346
ArtTile_ArtNem_BallThing            =       $0354
ArtTile_ArtNem_LaunchBall           =       $0368
ArtTile_ArtNem_OOZPlatform          =       $039D
ArtTile_ArtNem_PushSpring           =       $03C5
ArtTile_ArtNem_OOZSwingPlat         =       $03E3
ArtTile_ArtNem_StripedBlocksHoriz   =       $03FF
ArtTile_ArtNem_OOZFanHoriz          =       $0403
ArtTile_ArtNem_Aquis                =       $0500
ArtTile_ArtNem_Octus                =       $0538

; MCZ
ArtTile_ArtNem_Flasher          =       $03A8
ArtTile_ArtNem_Crawlton         =       $03C0
ArtTile_ArtNem_Crate            =       $03D4
ArtTile_ArtNem_MCZCollapsePlat  =       $03F4
ArtTile_ArtNem_VineSwitch       =       $040E
ArtTile_ArtNem_VinePulley       =       $041E
ArtTile_ArtNem_MCZGateLog       =       $043C

; CNZ
ArtTile_ArtNem_Crawl            =       $0340
ArtTile_ArtNem_BigMovingBlock   =       $036C
ArtTile_ArtNem_CNZSnake         =       $037C
ArtTile_ArtNem_CNZBonusSpike    =       $0380
ArtTile_ArtNem_CNZElevator      =       $0384
ArtTile_ArtNem_CNZCage          =       $0388
ArtTile_ArtNem_CNZHexBumper     =       $0394
ArtTile_ArtNem_CNZRoundBumper   =       $039A
ArtTile_ArtNem_CNZFlipper       =       $03B2
ArtTile_ArtNem_CNZMiniBumper    =       $03E6
ArtTile_ArtNem_CNZDiagPlunger   =       $0402
ArtTile_ArtNem_CNZVertPlunger   =       $0422

; Specific to 1p CNZ
ArtTile_ArtUnc_CNZFlipTiles_1   =       $0330
ArtTile_ArtUnc_CNZFlipTiles_2   =       $0540
ArtTile_ArtUnc_CNZSlotPics_1    =       $0550
ArtTile_ArtUnc_CNZSlotPics_2    =       $0560
ArtTile_ArtUnc_CNZSlotPics_3    =       $0570

; Specific to 2p CNZ
ArtTile_ArtUnc_CNZFlipTiles_1_2p    =       $0330
ArtTile_ArtUnc_CNZFlipTiles_2_2p    =       $0740
ArtTile_ArtUnc_CNZSlotPics_1_2p     =       $0750
ArtTile_ArtUnc_CNZSlotPics_2_2p     =       $0760
ArtTile_ArtUnc_CNZSlotPics_3_2p     =       $0770

; CPZ
ArtTile_ArtUnc_CPZAnimBack              =       $0370
ArtTile_ArtNem_CPZMetalThings           =       $0373
ArtTile_ArtNem_ConstructionStripes_2    =       $0394
ArtTile_ArtNem_CPZBooster               =       $039C
ArtTile_ArtNem_CPZElevator              =       $03A0
ArtTile_ArtNem_CPZAnimatedBits          =       $03B0
ArtTile_ArtNem_CPZTubeSpring            =       $03E0
ArtTile_ArtNem_CPZStairBlock            =       $0418
ArtTile_ArtNem_CPZMetalBlock            =       $0430
ArtTile_ArtNem_CPZDroplet               =       $043C
ArtTile_ArtNem_Grabber                  =       $0500
ArtTile_ArtNem_Spiny                    =       $052D

; DEZ
ArtTile_ArtUnc_DEZAnimBack              =       $0326
ArtTile_ArtNem_ConstructionStripes_1    =       $0328

; ARZ
ArtTile_ArtNem_ARZBarrierThing  =       $03F8
ArtTile_ArtNem_Leaves           =       $0410
ArtTile_ArtNem_ArrowAndShooter  =       $0417
ArtTile_ArtUnc_Waterfall3       =       $0428
ArtTile_ArtUnc_Waterfall2       =       $042C
ArtTile_ArtUnc_Waterfall1_1     =       $0430
ArtTile_ArtNem_Whisp            =       $0500
ArtTile_ArtNem_Grounder         =       $0509
ArtTile_ArtNem_ChopChop         =       $053B
ArtTile_ArtUnc_Waterfall1_2     =       $0557
ArtTile_ArtNem_BigBubbles       =       $055B

; ---------------------------------------------------------------------------
; Bosses
; Common tiles for some bosses (any for which no eggpod tiles are defined,
; except for WFZ and DEZ bosses)
ArtTile_ArtNem_Eggpod_4     =       $0500
; Common tiles for all bosses
ArtTile_ArtNem_FieryExplosion   =       $0580

; CPZ boss
ArtTile_ArtNem_EggpodJets_1     =       $0418
ArtTile_ArtNem_Eggpod_3         =       $0420
ArtTile_ArtNem_CPZBoss          =       $0500
ArtTile_ArtNem_BossSmoke_1      =       $0570

; EHZ boss
ArtTile_ArtNem_Eggpod_1     =       $03A0
ArtTile_ArtNem_EHZBoss      =       $0400
ArtTile_ArtNem_EggChoppers  =       $056C

; HTZ boss
ArtTile_ArtNem_Eggpod_2     =       $03C1
ArtTile_ArtNem_HTZBoss      =       $0421
ArtTile_ArtNem_BossSmoke_2  =       $05E4

; ARZ boss
ArtTile_ArtNem_ARZBoss  =       $03E0

; MCZ boss
ArtTile_ArtNem_MCZBoss          =       $03C0
ArtTile_ArtUnc_FallingRocks     =       $0560

; CNZ boss
ArtTile_ArtNem_CNZBoss          =       $0407
ArtTile_ArtNem_CNZBoss_Fudge    =       ArtTile_ArtNem_CNZBoss - $60  ; Badly reused mappings

; MTZ boss
ArtTile_ArtNem_MTZBoss          =       $037C
ArtTile_ArtNem_EggpodJets_2     =       $0560

; OOZ boss
ArtTile_ArtNem_OOZBoss  =       $038C

; WFZ and DEZ
ArtTile_ArtNem_RobotnikUpper    =       $0500
ArtTile_ArtNem_RobotnikRunning  =       $0518
ArtTile_ArtNem_RobotnikLower    =       $0564

; WFZ boss
ArtTile_ArtNem_WFZBoss  =       $0379

; DEZ
ArtTile_ArtNem_DEZBoss      =       $0330
ArtTile_ArtNem_DEZWindow    =       $0378
ArtTile_ArtNem_SilverSonic  =       $0380

; ---------------------------------------------------------------------------
; Universal locations

; Animals
ArtTile_ArtNem_Animal_1     =       $0580
ArtTile_ArtNem_Animal_2     =       $0594

; Game over
ArtTile_ArtNem_Game_Over    =       $04DE

; Titlecard
ArtTile_ArtNem_TitleCard    =       $0580
ArtTile_LevelName           =       $05DE

; End of level
ArtTile_ArtNem_Signpost         =       $0434
ArtTile_HUD_Bonus_Score         =       $0520
ArtTile_ArtNem_Perfect          =       $0540
ArtTile_ArtNem_ResultsText      =       $05B0
ArtTile_ArtUnc_Signpost         =       $05E8
ArtTile_ArtNem_MiniCharacter    =       $05F4
ArtTile_ArtNem_Capsule          =       $0680

; Tornado
ArtTile_ArtNem_Tornado          =       $0500
ArtTile_ArtNem_TornadoThruster  =       $0561

; Some common objects; these are loaded on all aquatic levels
ArtTile_ArtNem_Explosion            =       $05A4
ArtTile_ArtNem_Bubbles              =       $05E8
ArtTile_ArtNem_SuperSonic_stars     =       $05F2

; Universal (used on all standard levels)
ArtTile_ArtNem_Checkpoint           =       $047C
ArtTile_ArtNem_TailsDust            =       $048C
ArtTile_ArtNem_SonicDust            =       $049C
ArtTile_ArtNem_Numbers              =       $04AC
ArtTile_ArtNem_Shield               =       $04BE
ArtTile_ArtNem_Invincible_stars     =       $04DE
ArtTile_ArtNem_Powerups             =       $0680
ArtTile_ArtNem_Ring                 =       $06BC
ArtTile_ArtNem_HUD                  =       ArtTile_ArtNem_Powerups + $4A
ArtTile_ArtUnc_Sonic                =       $0780
ArtTile_ArtUnc_Tails                =       $07A0
ArtTile_ArtUnc_Tails_Tails          =       $07B0

; ---------------------------------------------------------------------------
; HUD. The HUD components are linked in a chain, and linked to
; power-ups, because the mappings of monitors and lives counter(s)
; depend on one another. If you want to alter these (for example,
; because you need the VRAM for something else), you will probably
; have to edit the mappings (or move the power-ups and HUD as a
; single block unit)
ArtTile_HUD_Score_E                     =       ArtTile_ArtNem_HUD + $18
ArtTile_HUD_Score                       =       ArtTile_HUD_Score_E + 2
ArtTile_HUD_Rings                       =       ArtTile_ArtNem_HUD + $30
ArtTile_HUD_Minutes                     =       ArtTile_ArtNem_HUD + $28
ArtTile_HUD_Seconds                     =       ArtTile_HUD_Minutes + 4
ArtTile_ArtNem_2p_life_counter          =       ArtTile_ArtNem_HUD + $2A
ArtTile_ArtNem_2p_life_counter_lives    =       ArtTile_ArtNem_2p_life_counter + 9
ArtTile_ArtNem_life_counter             =       ArtTile_ArtNem_HUD + $10A
ArtTile_ArtNem_life_counter_lives       =       ArtTile_ArtNem_life_counter + 9

; ---------------------------------------------------------------------------
; 2p-mode HUD
ArtTile_Art_HUD_Text_2P     =       ArtTile_ArtNem_HUD
ArtTile_Art_HUD_Numbers_2P  =       ArtTile_HUD_Score_E

; ---------------------------------------------------------------------------
; Unused objects, objects with mappings never loaded, objects with
; missing mappings and/or tiles, objects whose mappings and/or tiles
; are never loaded
ArtTile_ArtNem_MZ_Platform      =       $02B8
ArtTile_ArtUnc_HPZPulseOrb_1    =       $02E8
ArtTile_ArtUnc_HPZPulseOrb_2    =       $02F0
ArtTile_ArtUnc_HPZPulseOrb_3    =       $02F8
ArtTile_ArtNem_HPZ_Bridge       =       $0300
ArtTile_ArtNem_HPZ_Waterfall    =       $0315
ArtTile_ArtNem_HPZPlatform      =       $034A
ArtTile_ArtNem_HPZOrb           =       $035A
ArtTile_ArtNem_HPZ_Emerald      =       $0392
ArtTile_ArtNem_GHZ_Spiked_Log   =       $0398
ArtTile_ArtNem_Unknown          =       $03FA
ArtTile_ArtNem_BigRing          =       $0400
ArtTile_ArtNem_FloatPlatform    =       $0418
ArtTile_ArtNem_BigRing_Flash    =       $0462
ArtTile_ArtNem_EndPoints        =       $04B6
ArtTile_ArtNem_BreakWall        =       $0590
ArtTile_ArtNem_GHZ_Purple_Rock  =       $06C0
