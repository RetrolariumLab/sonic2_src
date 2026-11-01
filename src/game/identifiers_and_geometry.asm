; ---------------------------------------------------------------------------
; Constants that can be used instead of hard-coded IDs for various things
; The "id" function allows to remove elements from an array/table without having
; to change the IDs everywhere in the code

cur_zone_id     :=      0                               ; the zone ID currently being declared
cur_zone_str    :=      "0"                             ; string representation of the above

; macro to declare a zone ID
; this macro also declares constants of the form zone_id_X, where X is the ID of the zone in stock Sonic 2
; in order to allow level offset tables to be made dynamic
zoneID                  macro   zoneID,{INTLABEL}
__LABEL__               =       zoneID
zone_id_{cur_zone_str}  =       zoneID
cur_zone_id             :=      cur_zone_id+1
cur_zone_str            :=      "\{cur_zone_id}"
                    endm

; Zone IDs. These MUST be declared in the order in which their IDs are in stock Sonic 2, otherwise zone offset tables will screw up
emerald_hill_zone       zoneID  $00
zone_1                  zoneID  $01
wood_zone               zoneID  $02
zone_3                  zoneID  $03
metropolis_zone         zoneID  $04
metropolis_zone_2       zoneID  $05
wing_fortress_zone      zoneID  $06
hill_top_zone           zoneID  $07
hidden_palace_zone      zoneID  $08
zone_9                  zoneID  $09
oil_ocean_zone          zoneID  $0A
mystic_cave_zone        zoneID  $0B
casino_night_zone       zoneID  $0C
chemical_plant_zone     zoneID  $0D
death_egg_zone          zoneID  $0E
aquatic_ruin_zone       zoneID  $0F
sky_chase_zone          zoneID  $10

; set the number of zones
no_of_zones     =       cur_zone_id

; Zone and act IDs
emerald_hill_zone_act_1     =       (emerald_hill_zone<<8)|$00
emerald_hill_zone_act_2     =       (emerald_hill_zone<<8)|$01
chemical_plant_zone_act_1   =       (chemical_plant_zone<<8)|$00
chemical_plant_zone_act_2   =       (chemical_plant_zone<<8)|$01
aquatic_ruin_zone_act_1     =       (aquatic_ruin_zone<<8)|$00
aquatic_ruin_zone_act_2     =       (aquatic_ruin_zone<<8)|$01
casino_night_zone_act_1     =       (casino_night_zone<<8)|$00
casino_night_zone_act_2     =       (casino_night_zone<<8)|$01
hill_top_zone_act_1         =       (hill_top_zone<<8)|$00
hill_top_zone_act_2         =       (hill_top_zone<<8)|$01
mystic_cave_zone_act_1      =       (mystic_cave_zone<<8)|$00
mystic_cave_zone_act_2      =       (mystic_cave_zone<<8)|$01
oil_ocean_zone_act_1        =       (oil_ocean_zone<<8)|$00
oil_ocean_zone_act_2        =       (oil_ocean_zone<<8)|$01
metropolis_zone_act_1       =       (metropolis_zone<<8)|$00
metropolis_zone_act_2       =       (metropolis_zone<<8)|$01
metropolis_zone_act_3       =       (metropolis_zone_2<<8)|$00
sky_chase_zone_act_1        =       (sky_chase_zone<<8)|$00
wing_fortress_zone_act_1    =       (wing_fortress_zone<<8)|$00
death_egg_zone_act_1        =       (death_egg_zone<<8)|$00
; Prototype zone and act IDs
wood_zone_act_1             =       (wood_zone<<8)|$00
wood_zone_act_2             =       (wood_zone<<8)|$01
hidden_palace_zone_act_1    =       (hidden_palace_zone<<8)|$00
hidden_palace_zone_act_2    =       (hidden_palace_zone<<8)|$01

; ---------------------------------------------------------------------------
; some variables and functions to help define those constants (redefined before a new set of IDs)
offset          :=      0                               ; this is the start of the pointer table
ptrsize         :=      1                               ; this is the size of a pointer (should be 1 if the ID is a multiple of the actual size)
idstart         :=      0                               ; value to add to all IDs

; function using these variables
id              function ptr,((ptr-offset)/ptrsize+idstart)

; V-Int routines
offset          :=      Vint_SwitchTbl
ptrsize         :=      1
idstart         :=      0

VintID_Lag          =       id(Vint_Lag_ptr)            ; 0
VintID_SEGA         =       id(Vint_SEGA_ptr)           ; 2
VintID_Title        =       id(Vint_Title_ptr)          ; 4
VintID_Unused6      =       id(Vint_Unused6_ptr)        ; 6
VintID_Level        =       id(Vint_Level_ptr)          ; 8
VintID_S2SS         =       id(Vint_S2SS_ptr)           ; A
VintID_TitleCard    =       id(Vint_TitleCard_ptr)      ; C
VintID_UnusedE      =       id(Vint_UnusedE_ptr)        ; E
VintID_Pause        =       id(Vint_Pause_ptr)          ; 10
VintID_Fade         =       id(Vint_Fade_ptr)           ; 12
VintID_PCM          =       id(Vint_PCM_ptr)            ; 14
VintID_Menu         =       id(Vint_Menu_ptr)           ; 16
VintID_Ending       =       id(Vint_Ending_ptr)         ; 18
VintID_CtrlDMA      =       id(Vint_CtrlDMA_ptr)        ; 1A

; Game modes
offset          :=      GameModesArray
ptrsize         :=      1
idstart         :=      0

GameModeID_SegaScreen       =       id(GameMode_SegaScreen)  ; 0
GameModeID_TitleScreen      =       id(GameMode_TitleScreen)  ; 4
GameModeID_Demo             =       id(GameMode_Demo)   ; 8
GameModeID_Level            =       id(GameMode_Level)  ; C
GameModeID_SpecialStage     =       id(GameMode_SpecialStage)  ; 10
GameModeID_ContinueScreen   =       id(GameMode_ContinueScreen)  ; 14
GameModeID_2PResults        =       id(GameMode_2PResults)  ; 18
GameModeID_2PLevelSelect    =       id(GameMode_2PLevelSelect)  ; 1C
GameModeID_EndingSequence   =       id(GameMode_EndingSequence)  ; 20
GameModeID_OptionsMenu      =       id(GameMode_OptionsMenu)  ; 24
GameModeID_LevelSelect      =       id(GameMode_LevelSelect)  ; 28
GameModeFlag_TitleCard      =       7                   ; flag bit
GameModeID_TitleCard        =       1<<GameModeFlag_TitleCard  ; flag mask

; palette IDs
offset          :=      PalPointers
ptrsize         :=      8
idstart         :=      0

PalID_SEGA      =       id(PalPtr_SEGA)                 ; 0
PalID_Title     =       id(PalPtr_Title)                ; 1
PalID_MenuB     =       id(PalPtr_MenuB)                ; 2
PalID_BGND      =       id(PalPtr_BGND)                 ; 3
PalID_EHZ       =       id(PalPtr_EHZ)                  ; 4
PalID_EHZ2      =       id(PalPtr_EHZ2)                 ; 5
PalID_WZ        =       id(PalPtr_WZ)                   ; 6
PalID_EHZ3      =       id(PalPtr_EHZ3)                 ; 7
PalID_MTZ       =       id(PalPtr_MTZ)                  ; 8
PalID_MTZ2      =       id(PalPtr_MTZ2)                 ; 9
PalID_WFZ       =       id(PalPtr_WFZ)                  ; A
PalID_HTZ       =       id(PalPtr_HTZ)                  ; B
PalID_HPZ       =       id(PalPtr_HPZ)                  ; C
PalID_EHZ4      =       id(PalPtr_EHZ4)                 ; D
PalID_OOZ       =       id(PalPtr_OOZ)                  ; E
PalID_MCZ       =       id(PalPtr_MCZ)                  ; F
PalID_CNZ       =       id(PalPtr_CNZ)                  ; 10
PalID_CPZ       =       id(PalPtr_CPZ)                  ; 11
PalID_DEZ       =       id(PalPtr_DEZ)                  ; 12
PalID_ARZ       =       id(PalPtr_ARZ)                  ; 13
PalID_SCZ       =       id(PalPtr_SCZ)                  ; 14
PalID_HPZ_U     =       id(PalPtr_HPZ_U)                ; 15
PalID_CPZ_U     =       id(PalPtr_CPZ_U)                ; 16
PalID_ARZ_U     =       id(PalPtr_ARZ_U)                ; 17
PalID_SS        =       id(PalPtr_SS)                   ; 18
PalID_MCZ_B     =       id(PalPtr_MCZ_B)                ; 19
PalID_CNZ_B     =       id(PalPtr_CNZ_B)                ; 1A
PalID_SS1       =       id(PalPtr_SS1)                  ; 1B
PalID_SS2       =       id(PalPtr_SS2)                  ; 1C
PalID_SS3       =       id(PalPtr_SS3)                  ; 1D
PalID_SS4       =       id(PalPtr_SS4)                  ; 1E
PalID_SS5       =       id(PalPtr_SS5)                  ; 1F
PalID_SS6       =       id(PalPtr_SS6)                  ; 20
PalID_SS7       =       id(PalPtr_SS7)                  ; 21
PalID_SS1_2p    =       id(PalPtr_SS1_2p)               ; 22
PalID_SS2_2p    =       id(PalPtr_SS2_2p)               ; 23
PalID_SS3_2p    =       id(PalPtr_SS3_2p)               ; 24
PalID_OOZ_B     =       id(PalPtr_OOZ_B)                ; 25
PalID_Menu      =       id(PalPtr_Menu)                 ; 26
PalID_Result    =       id(PalPtr_Result)               ; 27

; PLC IDs
offset          :=      ArtLoadCues
ptrsize         :=      2
idstart         :=      0

PLCID_Std1              =       id(PLCptr_Std1)         ; 0
PLCID_Std2              =       id(PLCptr_Std2)         ; 1
PLCID_StdWtr            =       id(PLCptr_StdWtr)       ; 2
PLCID_GameOver          =       id(PLCptr_GameOver)     ; 3
PLCID_Ehz1              =       id(PLCptr_Ehz1)         ; 4
PLCID_Ehz2              =       id(PLCptr_Ehz2)         ; 5
PLCID_MilesLife2P       =       id(PLCptr_MilesLife2P)  ; 6
PLCID_MilesLife         =       id(PLCptr_MilesLife)    ; 7
PLCID_TailsLife2P       =       id(PLCptr_TailsLife2P)  ; 8
PLCID_TailsLife         =       id(PLCptr_TailsLife)    ; 9
PLCID_Unused1           =       id(PLCptr_Unused1)      ; A
PLCID_Unused2           =       id(PLCptr_Unused2)      ; B
PLCID_Mtz1              =       id(PLCptr_Mtz1)         ; C
PLCID_Mtz2              =       id(PLCptr_Mtz2)         ; D
PLCID_Wfz1              =       id(PLCptr_Wfz1)         ; 10
PLCID_Wfz2              =       id(PLCptr_Wfz2)         ; 11
PLCID_Htz1              =       id(PLCptr_Htz1)         ; 12
PLCID_Htz2              =       id(PLCptr_Htz2)         ; 13
PLCID_Hpz1              =       id(PLCptr_Hpz1)         ; 14
PLCID_Hpz2              =       id(PLCptr_Hpz2)         ; 15
PLCID_Unused3           =       id(PLCptr_Unused3)      ; 16
PLCID_Unused4           =       id(PLCptr_Unused4)      ; 17
PLCID_Ooz1              =       id(PLCptr_Ooz1)         ; 18
PLCID_Ooz2              =       id(PLCptr_Ooz2)         ; 19
PLCID_Mcz1              =       id(PLCptr_Mcz1)         ; 1A
PLCID_Mcz2              =       id(PLCptr_Mcz2)         ; 1B
PLCID_Cnz1              =       id(PLCptr_Cnz1)         ; 1C
PLCID_Cnz2              =       id(PLCptr_Cnz2)         ; 1D
PLCID_Cpz1              =       id(PLCptr_Cpz1)         ; 1E
PLCID_Cpz2              =       id(PLCptr_Cpz2)         ; 1F
PLCID_Dez1              =       id(PLCptr_Dez1)         ; 20
PLCID_Dez2              =       id(PLCptr_Dez2)         ; 21
PLCID_Arz1              =       id(PLCptr_Arz1)         ; 22
PLCID_Arz2              =       id(PLCptr_Arz2)         ; 23
PLCID_Scz1              =       id(PLCptr_Scz1)         ; 24
PLCID_Scz2              =       id(PLCptr_Scz2)         ; 25
PLCID_Results           =       id(PLCptr_Results)      ; 26
PLCID_Signpost          =       id(PLCptr_Signpost)     ; 27
PLCID_CpzBoss           =       id(PLCptr_CpzBoss)      ; 28
PLCID_EhzBoss           =       id(PLCptr_EhzBoss)      ; 29
PLCID_HtzBoss           =       id(PLCptr_HtzBoss)      ; 2A
PLCID_ArzBoss           =       id(PLCptr_ArzBoss)      ; 2B
PLCID_MczBoss           =       id(PLCptr_MczBoss)      ; 2C
PLCID_CnzBoss           =       id(PLCptr_CnzBoss)      ; 2D
PLCID_MtzBoss           =       id(PLCptr_MtzBoss)      ; 2E
PLCID_OozBoss           =       id(PLCptr_OozBoss)      ; 2F
PLCID_FieryExplosion    =       id(PLCptr_FieryExplosion)  ; 30
PLCID_DezBoss           =       id(PLCptr_DezBoss)      ; 31
PLCID_EhzAnimals        =       id(PLCptr_EhzAnimals)   ; 32
PLCID_MczAnimals        =       id(PLCptr_MczAnimals)   ; 33
PLCID_HtzAnimals        =       id(PLCptr_HtzAnimals)   ; 34
PLCID_MtzAnimals        =       id(PLCptr_MtzAnimals)   ; 34
PLCID_WfzAnimals        =       id(PLCptr_WfzAnimals)   ; 34
PLCID_DezAnimals        =       id(PLCptr_DezAnimals)   ; 35
PLCID_HpzAnimals        =       id(PLCptr_HpzAnimals)   ; 36
PLCID_OozAnimals        =       id(PLCptr_OozAnimals)   ; 37
PLCID_SczAnimals        =       id(PLCptr_SczAnimals)   ; 38
PLCID_CnzAnimals        =       id(PLCptr_CnzAnimals)   ; 39
PLCID_CpzAnimals        =       id(PLCptr_CpzAnimals)   ; 3A
PLCID_ArzAnimals        =       id(PLCptr_ArzAnimals)   ; 3B
PLCID_SpecialStage      =       id(PLCptr_SpecialStage)  ; 3C
PLCID_SpecStageBombs    =       id(PLCptr_SpecStageBombs)  ; 3D
PLCID_WfzBoss           =       id(PLCptr_WfzBoss)      ; 3E
PLCID_Tornado           =       id(PLCptr_Tornado)      ; 3F
PLCID_Capsule           =       id(PLCptr_Capsule)      ; 40
PLCID_Explosion         =       id(PLCptr_Explosion)    ; 41
PLCID_ResultsTails      =       id(PLCptr_ResultsTails)  ; 42

; Object IDs
offset          :=      Obj_Index
ptrsize         :=      4
idstart         :=      1

ObjID_Sonic             =       id(ObjPtr_Sonic)        ; 01
ObjID_Tails             =       id(ObjPtr_Tails)        ; 02
ObjID_PlaneSwitcher     =       id(ObjPtr_PlaneSwitcher)  ; 03
ObjID_WaterSurface      =       id(ObjPtr_WaterSurface)  ; 04
ObjID_TailsTails        =       id(ObjPtr_TailsTails)   ; 05
ObjID_Spiral            =       id(ObjPtr_Spiral)       ; 06
ObjID_Oil               =       id(ObjPtr_Oil)          ; 07
ObjID_SpindashDust      =       id(ObjPtr_SpindashDust)  ; 08
ObjID_Splash            =       id(ObjPtr_Splash)       ; 08
ObjID_SonicSS           =       id(ObjPtr_SonicSS)      ; 09
ObjID_SmallBubbles      =       id(ObjPtr_SmallBubbles)  ; 0A
ObjID_TippingFloor      =       id(ObjPtr_TippingFloor)  ; 0B
ObjID_Signpost          =       id(ObjPtr_Signpost)     ; 0D
ObjID_TitleIntro        =       id(ObjPtr_TitleIntro)   ; 0E
ObjID_TitleMenu         =       id(ObjPtr_TitleMenu)    ; 0F
ObjID_TailsSS           =       id(ObjPtr_TailsSS)      ; 10
ObjID_Bridge            =       id(ObjPtr_Bridge)       ; 11
ObjID_HPZEmerald        =       id(ObjPtr_HPZEmerald)   ; 12
ObjID_HPZWaterfall      =       id(ObjPtr_HPZWaterfall)  ; 13
ObjID_Seesaw            =       id(ObjPtr_Seesaw)       ; 14
ObjID_SwingingPlatform  =       id(ObjPtr_SwingingPlatform)  ; 15
ObjID_HTZLift           =       id(ObjPtr_HTZLift)      ; 16
ObjID_ARZPlatform       =       id(ObjPtr_ARZPlatform)  ; 18
ObjID_EHZPlatform       =       id(ObjPtr_EHZPlatform)  ; 18
ObjID_CPZPlatform       =       id(ObjPtr_CPZPlatform)  ; 19
ObjID_OOZMovingPform    =       id(ObjPtr_OOZMovingPform)  ; 19
ObjID_WFZPlatform       =       id(ObjPtr_WFZPlatform)  ; 19
ObjID_HPZCollapsPform   =       id(ObjPtr_HPZCollapsPform)  ; 1A
ObjID_SpeedBooster      =       id(ObjPtr_SpeedBooster)  ; 1B
ObjID_Scenery           =       id(ObjPtr_Scenery)      ; 1C
ObjID_BridgeStake       =       id(ObjPtr_BridgeStake)  ; 1C
ObjID_FallingOil        =       id(ObjPtr_FallingOil)   ; 1C
ObjID_BlueBalls         =       id(ObjPtr_BlueBalls)    ; 1D
ObjID_CPZSpinTube       =       id(ObjPtr_CPZSpinTube)  ; 1E
ObjID_CollapsPform      =       id(ObjPtr_CollapsPform)  ; 1F
ObjID_LavaBubble        =       id(ObjPtr_LavaBubble)   ; 20
ObjID_2PResults         =       id(ObjPtr_2PResults)    ; 21
ObjID_ArrowShooter      =       id(ObjPtr_ArrowShooter)  ; 22
ObjID_FallingPillar     =       id(ObjPtr_FallingPillar)  ; 23
ObjID_ARZBubbles        =       id(ObjPtr_ARZBubbles)   ; 24
ObjID_Ring              =       id(ObjPtr_Ring)         ; 25
ObjID_Monitor           =       id(ObjPtr_Monitor)      ; 26
ObjID_Explosion         =       id(ObjPtr_Explosion)    ; 27
ObjID_Animal            =       id(ObjPtr_Animal)       ; 28
ObjID_Points            =       id(ObjPtr_Points)       ; 29
ObjID_Stomper           =       id(ObjPtr_Stomper)      ; 2A
ObjID_RisingPillar      =       id(ObjPtr_RisingPillar)  ; 2B
ObjID_LeavesGenerator   =       id(ObjPtr_LeavesGenerator)  ; 2C
ObjID_Barrier           =       id(ObjPtr_Barrier)      ; 2D
ObjID_MonitorContents   =       id(ObjPtr_MonitorContents)  ; 2E
ObjID_SmashableGround   =       id(ObjPtr_SmashableGround)  ; 2F
ObjID_RisingLava        =       id(ObjPtr_RisingLava)   ; 30
ObjID_LavaMarker        =       id(ObjPtr_LavaMarker)   ; 31
ObjID_BreakableBlock    =       id(ObjPtr_BreakableBlock)  ; 32
ObjID_BreakableRock     =       id(ObjPtr_BreakableRock)  ; 32
ObjID_OOZPoppingPform   =       id(ObjPtr_OOZPoppingPform)  ; 33
ObjID_TitleCard         =       id(ObjPtr_TitleCard)    ; 34
ObjID_InvStars          =       id(ObjPtr_InvStars)     ; 35
ObjID_Spikes            =       id(ObjPtr_Spikes)       ; 36
ObjID_LostRings         =       id(ObjPtr_LostRings)    ; 37
ObjID_Shield            =       id(ObjPtr_Shield)       ; 38
ObjID_GameOver          =       id(ObjPtr_GameOver)     ; 39
ObjID_TimeOver          =       id(ObjPtr_TimeOver)     ; 39
ObjID_Results           =       id(ObjPtr_Results)      ; 3A
ObjID_OOZLauncher       =       id(ObjPtr_OOZLauncher)  ; 3D
ObjID_EggPrison         =       id(ObjPtr_EggPrison)    ; 3E
ObjID_Fan               =       id(ObjPtr_Fan)          ; 3F
ObjID_Springboard       =       id(ObjPtr_Springboard)  ; 40
ObjID_Spring            =       id(ObjPtr_Spring)       ; 41
ObjID_SteamSpring       =       id(ObjPtr_SteamSpring)  ; 42
ObjID_SlidingSpike      =       id(ObjPtr_SlidingSpike)  ; 43
ObjID_RoundBumper       =       id(ObjPtr_RoundBumper)  ; 44
ObjID_OOZSpring         =       id(ObjPtr_OOZSpring)    ; 45
ObjID_OOZBall           =       id(ObjPtr_OOZBall)      ; 46
ObjID_Button            =       id(ObjPtr_Button)       ; 47
ObjID_LauncherBall      =       id(ObjPtr_LauncherBall)  ; 48
ObjID_EHZWaterfall      =       id(ObjPtr_EHZWaterfall)  ; 49
ObjID_Octus             =       id(ObjPtr_Octus)        ; 4A
ObjID_Buzzer            =       id(ObjPtr_Buzzer)       ; 4B
ObjID_Aquis             =       id(ObjPtr_Aquis)        ; 50
ObjID_CNZBoss           =       id(ObjPtr_CNZBoss)      ; 51
ObjID_HTZBoss           =       id(ObjPtr_HTZBoss)      ; 52
ObjID_MTZBossOrb        =       id(ObjPtr_MTZBossOrb)   ; 53
ObjID_MTZBoss           =       id(ObjPtr_MTZBoss)      ; 54
ObjID_OOZBoss           =       id(ObjPtr_OOZBoss)      ; 55
ObjID_EHZBoss           =       id(ObjPtr_EHZBoss)      ; 56
ObjID_MCZBoss           =       id(ObjPtr_MCZBoss)      ; 57
ObjID_BossExplosion     =       id(ObjPtr_BossExplosion)  ; 58
ObjID_SSEmerald         =       id(ObjPtr_SSEmerald)    ; 59
ObjID_SSMessage         =       id(ObjPtr_SSMessage)    ; 5A
ObjID_SSRingSpill       =       id(ObjPtr_SSRingSpill)  ; 5B
ObjID_Masher            =       id(ObjPtr_Masher)       ; 5C
ObjID_CPZBoss           =       id(ObjPtr_CPZBoss)      ; 5D
ObjID_SSHUD             =       id(ObjPtr_SSHUD)        ; 5E
ObjID_StartBanner       =       id(ObjPtr_StartBanner)  ; 5F
ObjID_EndingController  =       id(ObjPtr_EndingController)  ; 5F
ObjID_SSRing            =       id(ObjPtr_SSRing)       ; 60
ObjID_SSBomb            =       id(ObjPtr_SSBomb)       ; 61
ObjID_SSShadow          =       id(ObjPtr_SSShadow)     ; 63
ObjID_MTZTwinStompers   =       id(ObjPtr_MTZTwinStompers)  ; 64
ObjID_MTZLongPlatform   =       id(ObjPtr_MTZLongPlatform)  ; 65
ObjID_MTZSpringWall     =       id(ObjPtr_MTZSpringWall)  ; 66
ObjID_MTZSpinTube       =       id(ObjPtr_MTZSpinTube)  ; 67
ObjID_SpikyBlock        =       id(ObjPtr_SpikyBlock)   ; 68
ObjID_Nut               =       id(ObjPtr_Nut)          ; 69
ObjID_MCZRotPforms      =       id(ObjPtr_MCZRotPforms)  ; 6A
ObjID_MTZMovingPforms   =       id(ObjPtr_MTZMovingPforms)  ; 6A
ObjID_MTZPlatform       =       id(ObjPtr_MTZPlatform)  ; 6B
ObjID_CPZSquarePform    =       id(ObjPtr_CPZSquarePform)  ; 6B
ObjID_Conveyor          =       id(ObjPtr_Conveyor)     ; 6C
ObjID_FloorSpike        =       id(ObjPtr_FloorSpike)   ; 6D
ObjID_LargeRotPform     =       id(ObjPtr_LargeRotPform)  ; 6E
ObjID_SSResults         =       id(ObjPtr_SSResults)    ; 6F
ObjID_Cog               =       id(ObjPtr_Cog)          ; 70
ObjID_MTZLavaBubble     =       id(ObjPtr_MTZLavaBubble)  ; 71
ObjID_HPZBridgeStake    =       id(ObjPtr_HPZBridgeStake)  ; 71
ObjID_PulsingOrb        =       id(ObjPtr_PulsingOrb)   ; 71
ObjID_CNZConveyorBelt   =       id(ObjPtr_CNZConveyorBelt)  ; 72
ObjID_RotatingRings     =       id(ObjPtr_RotatingRings)  ; 73
ObjID_InvisibleBlock    =       id(ObjPtr_InvisibleBlock)  ; 74
ObjID_MCZBrick          =       id(ObjPtr_MCZBrick)     ; 75
ObjID_SlidingSpikes     =       id(ObjPtr_SlidingSpikes)  ; 76
ObjID_MCZBridge         =       id(ObjPtr_MCZBridge)    ; 77
ObjID_CPZStaircase      =       id(ObjPtr_CPZStaircase)  ; 78
ObjID_Starpost          =       id(ObjPtr_Starpost)     ; 79
ObjID_SidewaysPform     =       id(ObjPtr_SidewaysPform)  ; 7A
ObjID_PipeExitSpring    =       id(ObjPtr_PipeExitSpring)  ; 7B
ObjID_CPZPylon          =       id(ObjPtr_CPZPylon)     ; 7C
ObjID_SuperSonicStars   =       id(ObjPtr_SuperSonicStars)  ; 7E
ObjID_VineSwitch        =       id(ObjPtr_VineSwitch)   ; 7F
ObjID_MovingVine        =       id(ObjPtr_MovingVine)   ; 80
ObjID_MCZDrawbridge     =       id(ObjPtr_MCZDrawbridge)  ; 81
ObjID_SwingingPform     =       id(ObjPtr_SwingingPform)  ; 82
ObjID_ARZRotPforms      =       id(ObjPtr_ARZRotPforms)  ; 83
ObjID_ForcedSpin        =       id(ObjPtr_ForcedSpin)   ; 84
ObjID_PinballMode       =       id(ObjPtr_PinballMode)  ; 84
ObjID_LauncherSpring    =       id(ObjPtr_LauncherSpring)  ; 85
ObjID_Flipper           =       id(ObjPtr_Flipper)      ; 86
ObjID_SSNumberOfRings   =       id(ObjPtr_SSNumberOfRings)  ; 87
ObjID_SSTailsTails      =       id(ObjPtr_SSTailsTails)  ; 88
ObjID_ARZBoss           =       id(ObjPtr_ARZBoss)      ; 89
ObjID_WFZPalSwitcher    =       id(ObjPtr_WFZPalSwitcher)  ; 8B
ObjID_Whisp             =       id(ObjPtr_Whisp)        ; 8C
ObjID_GrounderInWall    =       id(ObjPtr_GrounderInWall)  ; 8D
ObjID_GrounderInWall2   =       id(ObjPtr_GrounderInWall2)  ; 8E
ObjID_GrounderWall      =       id(ObjPtr_GrounderWall)  ; 8F
ObjID_GrounderRocks     =       id(ObjPtr_GrounderRocks)  ; 90
ObjID_ChopChop          =       id(ObjPtr_ChopChop)     ; 91
ObjID_Spiker            =       id(ObjPtr_Spiker)       ; 92
ObjID_SpikerDrill       =       id(ObjPtr_SpikerDrill)  ; 93
ObjID_Rexon             =       id(ObjPtr_Rexon)        ; 94
ObjID_Sol               =       id(ObjPtr_Sol)          ; 95
ObjID_Rexon2            =       id(ObjPtr_Rexon2)       ; 96
ObjID_RexonHead         =       id(ObjPtr_RexonHead)    ; 97
ObjID_Projectile        =       id(ObjPtr_Projectile)   ; 98
ObjID_Nebula            =       id(ObjPtr_Nebula)       ; 99
ObjID_Turtloid          =       id(ObjPtr_Turtloid)     ; 9A
ObjID_TurtloidRider     =       id(ObjPtr_TurtloidRider)  ; 9B
ObjID_BalkiryJet        =       id(ObjPtr_BalkiryJet)   ; 9C
ObjID_Coconuts          =       id(ObjPtr_Coconuts)     ; 9D
ObjID_Crawlton          =       id(ObjPtr_Crawlton)     ; 9E
ObjID_Shellcracker      =       id(ObjPtr_Shellcracker)  ; 9F
ObjID_ShellcrackerClaw  =       id(ObjPtr_ShellcrackerClaw)  ; A0
ObjID_Slicer            =       id(ObjPtr_Slicer)       ; A1
ObjID_SlicerPincers     =       id(ObjPtr_SlicerPincers)  ; A2
ObjID_Flasher           =       id(ObjPtr_Flasher)      ; A3
ObjID_Asteron           =       id(ObjPtr_Asteron)      ; A4
ObjID_Spiny             =       id(ObjPtr_Spiny)        ; A5
ObjID_SpinyOnWall       =       id(ObjPtr_SpinyOnWall)  ; A6
ObjID_Grabber           =       id(ObjPtr_Grabber)      ; A7
ObjID_GrabberLegs       =       id(ObjPtr_GrabberLegs)  ; A8
ObjID_GrabberBox        =       id(ObjPtr_GrabberBox)   ; A9
ObjID_GrabberString     =       id(ObjPtr_GrabberString)  ; AA
ObjID_Balkiry           =       id(ObjPtr_Balkiry)      ; AC
ObjID_CluckerBase       =       id(ObjPtr_CluckerBase)  ; AD
ObjID_Clucker           =       id(ObjPtr_Clucker)      ; AE
ObjID_MechaSonic        =       id(ObjPtr_MechaSonic)   ; AF
ObjID_SonicOnSegaScr    =       id(ObjPtr_SonicOnSegaScr)  ; B0
ObjID_SegaHideTM        =       id(ObjPtr_SegaHideTM)   ; B1
ObjID_Tornado           =       id(ObjPtr_Tornado)      ; B2
ObjID_Cloud             =       id(ObjPtr_Cloud)        ; B3
ObjID_VPropeller        =       id(ObjPtr_VPropeller)   ; B4
ObjID_HPropeller        =       id(ObjPtr_HPropeller)   ; B5
ObjID_TiltingPlatform   =       id(ObjPtr_TiltingPlatform)  ; B6
ObjID_VerticalLaser     =       id(ObjPtr_VerticalLaser)  ; B7
ObjID_WallTurret        =       id(ObjPtr_WallTurret)   ; B8
ObjID_Laser             =       id(ObjPtr_Laser)        ; B9
ObjID_WFZWheel          =       id(ObjPtr_WFZWheel)     ; BA
ObjID_WFZShipFire       =       id(ObjPtr_WFZShipFire)  ; BC
ObjID_SmallMetalPform   =       id(ObjPtr_SmallMetalPform)  ; BD
ObjID_LateralCannon     =       id(ObjPtr_LateralCannon)  ; BE
ObjID_WFZStick          =       id(ObjPtr_WFZStick)     ; BF
ObjID_SpeedLauncher     =       id(ObjPtr_SpeedLauncher)  ; C0
ObjID_BreakablePlating  =       id(ObjPtr_BreakablePlating)  ; C1
ObjID_Rivet             =       id(ObjPtr_Rivet)        ; C2
ObjID_TornadoSmoke      =       id(ObjPtr_TornadoSmoke)  ; C3
ObjID_TornadoSmoke2     =       id(ObjPtr_TornadoSmoke2)  ; C4
ObjID_WFZBoss           =       id(ObjPtr_WFZBoss)      ; C5
ObjID_Eggman            =       id(ObjPtr_Eggman)       ; C6
ObjID_Eggrobo           =       id(ObjPtr_Eggrobo)      ; C7
ObjID_Crawl             =       id(ObjPtr_Crawl)        ; C8
ObjID_TtlScrPalChanger  =       id(ObjPtr_TtlScrPalChanger)  ; C9
ObjID_CutScene          =       id(ObjPtr_CutScene)     ; CA
ObjID_EndingSeqClouds   =       id(ObjPtr_EndingSeqClouds)  ; CB
ObjID_EndingSeqTrigger  =       id(ObjPtr_EndingSeqTrigger)  ; CC
ObjID_EndingSeqBird     =       id(ObjPtr_EndingSeqBird)  ; CD
ObjID_EndingSeqSonic    =       id(ObjPtr_EndingSeqSonic)  ; CE
ObjID_EndingSeqTails    =       id(ObjPtr_EndingSeqTails)  ; CE
ObjID_TornadoHelixes    =       id(ObjPtr_TornadoHelixes)  ; CF
ObjID_CNZRectBlocks     =       id(ObjPtr_CNZRectBlocks)  ; D2
ObjID_BombPrize         =       id(ObjPtr_BombPrize)    ; D3
ObjID_CNZBigBlock       =       id(ObjPtr_CNZBigBlock)  ; D4
ObjID_Elevator          =       id(ObjPtr_Elevator)     ; D5
ObjID_PointPokey        =       id(ObjPtr_PointPokey)   ; D6
ObjID_Bumper            =       id(ObjPtr_Bumper)       ; D7
ObjID_BonusBlock        =       id(ObjPtr_BonusBlock)   ; D8
ObjID_Grab              =       id(ObjPtr_Grab)         ; D9
ObjID_ContinueText      =       id(ObjPtr_ContinueText)  ; DA
ObjID_ContinueIcons     =       id(ObjPtr_ContinueIcons)  ; DA
ObjID_ContinueChars     =       id(ObjPtr_ContinueChars)  ; DB
ObjID_RingPrize         =       id(ObjPtr_RingPrize)    ; DC

; Music IDs
offset          :=      zMasterPlaylist
ptrsize         :=      1
idstart         :=      $81
; $80 is reserved for silence, so if you make idstart $80 or less,
; you may need to insert a dummy zMusIDPtr in the $80 slot

MusID__First        =       idstart
MusID_2PResult      =       id(zMusIDPtr_2PResult)      ; 81
MusID_EHZ           =       id(zMusIDPtr_EHZ)           ; 82
MusID_MCZ_2P        =       id(zMusIDPtr_MCZ_2P)        ; 83
MusID_OOZ           =       id(zMusIDPtr_OOZ)           ; 84
MusID_MTZ           =       id(zMusIDPtr_MTZ)           ; 85
MusID_HTZ           =       id(zMusIDPtr_HTZ)           ; 86
MusID_ARZ           =       id(zMusIDPtr_ARZ)           ; 87
MusID_CNZ_2P        =       id(zMusIDPtr_CNZ_2P)        ; 88
MusID_CNZ           =       id(zMusIDPtr_CNZ)           ; 89
MusID_DEZ           =       id(zMusIDPtr_DEZ)           ; 8A
MusID_MCZ           =       id(zMusIDPtr_MCZ)           ; 8B
MusID_EHZ_2P        =       id(zMusIDPtr_EHZ_2P)        ; 8C
MusID_SCZ           =       id(zMusIDPtr_SCZ)           ; 8D
MusID_CPZ           =       id(zMusIDPtr_CPZ)           ; 8E
MusID_WFZ           =       id(zMusIDPtr_WFZ)           ; 8F
MusID_HPZ           =       id(zMusIDPtr_HPZ)           ; 90
MusID_Options       =       id(zMusIDPtr_Options)       ; 91
MusID_SpecStage     =       id(zMusIDPtr_SpecStage)     ; 92
MusID_Boss          =       id(zMusIDPtr_Boss)          ; 93
MusID_EndBoss       =       id(zMusIDPtr_EndBoss)       ; 94
MusID_Ending        =       id(zMusIDPtr_Ending)        ; 95
MusID_SuperSonic    =       id(zMusIDPtr_SuperSonic)    ; 96
MusID_Invincible    =       id(zMusIDPtr_Invincible)    ; 97
MusID_ExtraLife     =       id(zMusIDPtr_ExtraLife)     ; 98
MusID_Title         =       id(zMusIDPtr_Title)         ; 99
MusID_EndLevel      =       id(zMusIDPtr_EndLevel)      ; 9A
MusID_GameOver      =       id(zMusIDPtr_GameOver)      ; 9B
MusID_Continue      =       id(zMusIDPtr_Continue)      ; 9C
MusID_Emerald       =       id(zMusIDPtr_Emerald)       ; 9D
MusID_Credits       =       id(zMusIDPtr_Credits)       ; 9E
MusID_Countdown     =       id(zMusIDPtr_Countdown)     ; 9F
MusID__End          =       id(zMusIDPtr__End)          ; A0

; Sound IDs
offset          :=      SoundIndex
ptrsize         :=      2
idstart         :=      $A0
; $80 is reserved for silence, so if you make idstart $80 or less,
; you may need to insert a dummy SndPtr in the $80 slot

SndID__First            =       idstart
SndID_Jump              =       id(SndPtr_Jump)         ; A0
SndID_Checkpoint        =       id(SndPtr_Checkpoint)   ; A1
SndID_SpikeSwitch       =       id(SndPtr_SpikeSwitch)  ; A2
SndID_Hurt              =       id(SndPtr_Hurt)         ; A3
SndID_Skidding          =       id(SndPtr_Skidding)     ; A4
SndID_MissileDissolve   =       id(SndPtr_MissileDissolve)  ; A5
SndID_HurtBySpikes      =       id(SndPtr_HurtBySpikes)  ; A6
SndID_Sparkle           =       id(SndPtr_Sparkle)      ; A7
SndID_Beep              =       id(SndPtr_Beep)         ; A8
SndID_Bwoop             =       id(SndPtr_Bwoop)        ; A9
SndID_Splash            =       id(SndPtr_Splash)       ; AA
SndID_Swish             =       id(SndPtr_Swish)        ; AB
SndID_BossHit           =       id(SndPtr_BossHit)      ; AC
SndID_InhalingBubble    =       id(SndPtr_InhalingBubble)  ; AD
SndID_ArrowFiring       =       id(SndPtr_ArrowFiring)  ; AE
SndID_LavaBall          =       id(SndPtr_LavaBall)     ; AE
SndID_Shield            =       id(SndPtr_Shield)       ; AF
SndID_LaserBeam         =       id(SndPtr_LaserBeam)    ; B0
SndID_Zap               =       id(SndPtr_Zap)          ; B1
SndID_Drown             =       id(SndPtr_Drown)        ; B2
SndID_FireBurn          =       id(SndPtr_FireBurn)     ; B3
SndID_Bumper            =       id(SndPtr_Bumper)       ; B4
SndID_Ring              =       id(SndPtr_Ring)         ; B5
SndID_RingRight         =       id(SndPtr_RingRight)    ; B5
SndID_SpikesMove        =       id(SndPtr_SpikesMove)   ; B6
SndID_Rumbling          =       id(SndPtr_Rumbling)     ; B7
SndID_Smash             =       id(SndPtr_Smash)        ; B9
SndID_DoorSlam          =       id(SndPtr_DoorSlam)     ; BB
SndID_SpindashRelease   =       id(SndPtr_SpindashRelease)  ; BC
SndID_Hammer            =       id(SndPtr_Hammer)       ; BD
SndID_Roll              =       id(SndPtr_Roll)         ; BE
SndID_ContinueJingle    =       id(SndPtr_ContinueJingle)  ; BF
SndID_CasinoBonus       =       id(SndPtr_CasinoBonus)  ; C0
SndID_Explosion         =       id(SndPtr_Explosion)    ; C1
SndID_WaterWarning      =       id(SndPtr_WaterWarning)  ; C2
SndID_EnterGiantRing    =       id(SndPtr_EnterGiantRing)  ; C3
SndID_BossExplosion     =       id(SndPtr_BossExplosion)  ; C4
SndID_TallyEnd          =       id(SndPtr_TallyEnd)     ; C5
SndID_RingSpill         =       id(SndPtr_RingSpill)    ; C6
SndID_Flamethrower      =       id(SndPtr_Flamethrower)  ; C8
SndID_Bonus             =       id(SndPtr_Bonus)        ; C9
SndID_SpecStageEntry    =       id(SndPtr_SpecStageEntry)  ; CA
SndID_SlowSmash         =       id(SndPtr_SlowSmash)    ; CB
SndID_Spring            =       id(SndPtr_Spring)       ; CC
SndID_Blip              =       id(SndPtr_Blip)         ; CD
SndID_RingLeft          =       id(SndPtr_RingLeft)     ; CE
SndID_Signpost          =       id(SndPtr_Signpost)     ; CF
SndID_CNZBossZap        =       id(SndPtr_CNZBossZap)   ; D0
SndID_Signpost2P        =       id(SndPtr_Signpost2P)   ; D3
SndID_OOZLidPop         =       id(SndPtr_OOZLidPop)    ; D4
SndID_SlidingSpike      =       id(SndPtr_SlidingSpike)  ; D5
SndID_CNZElevator       =       id(SndPtr_CNZElevator)  ; D6
SndID_PlatformKnock     =       id(SndPtr_PlatformKnock)  ; D7
SndID_BonusBumper       =       id(SndPtr_BonusBumper)  ; D8
SndID_LargeBumper       =       id(SndPtr_LargeBumper)  ; D9
SndID_Gloop             =       id(SndPtr_Gloop)        ; DA
SndID_PreArrowFiring    =       id(SndPtr_PreArrowFiring)  ; DB
SndID_Fire              =       id(SndPtr_Fire)         ; DC
SndID_ArrowStick        =       id(SndPtr_ArrowStick)   ; DD
SndID_Helicopter        =       id(SndPtr_Helicopter)   ; DE
SndID_SuperTransform    =       id(SndPtr_SuperTransform)  ; DF
SndID_SpindashRev       =       id(SndPtr_SpindashRev)  ; E0
SndID_Rumbling2         =       id(SndPtr_Rumbling2)    ; E1
SndID_CNZLaunch         =       id(SndPtr_CNZLaunch)    ; E2
SndID_Flipper           =       id(SndPtr_Flipper)      ; E3
SndID_HTZLiftClick      =       id(SndPtr_HTZLiftClick)  ; E4
SndID_Leaves            =       id(SndPtr_Leaves)       ; E5
SndID_MegaMackDrop      =       id(SndPtr_MegaMackDrop)  ; E6
SndID_DrawbridgeMove    =       id(SndPtr_DrawbridgeMove)  ; E7
SndID_QuickDoorSlam     =       id(SndPtr_QuickDoorSlam)  ; E8
SndID_DrawbridgeDown    =       id(SndPtr_DrawbridgeDown)  ; E9
SndID_LaserBurst        =       id(SndPtr_LaserBurst)   ; EA
SndID_Scatter           =       id(SndPtr_Scatter)      ; EB
SndID_LaserFloor        =       id(SndPtr_LaserFloor)   ; EB
SndID_Teleport          =       id(SndPtr_Teleport)     ; EC
SndID_Error             =       id(SndPtr_Error)        ; ED
SndID_MechaSonicBuzz    =       id(SndPtr_MechaSonicBuzz)  ; EE
SndID_LargeLaser        =       id(SndPtr_LargeLaser)   ; EF
SndID_OilSlide          =       id(SndPtr_OilSlide)     ; F0
SndID__End              =       id(SndPtr__End)         ; F1

; Sound command IDs
offset          :=      zCommandIndex
ptrsize         :=      4
idstart         :=      $F8

CmdID__First        =       idstart
MusID_StopSFX       =       id(CmdPtr_StopSFX)          ; F8
MusID_FadeOut       =       id(CmdPtr_FadeOut)          ; F9
SndID_SegaSound     =       id(CmdPtr_SegaSound)        ; FA
MusID_SpeedUp       =       id(CmdPtr_SpeedUp)          ; FB
MusID_SlowDown      =       id(CmdPtr_SlowDown)         ; FC
MusID_Stop          =       id(CmdPtr_Stop)             ; FD
CmdID__End          =       id(CmdPtr__End)             ; FE

MusID_Pause     =       $7E+$80                         ; FE
MusID_Unpause   =       $7F+$80                         ; FF

                    if      MOMPASS > 1                 ; Avoid undefined symbol errors by checking only after the first pass
                    if      MusID__End > SndID__First
                    fatal   "You have too many SndPtrs. MusID__End ($\{MusID__End}) can't exceed SndID__First ($\{SndID__First})."
                    endif
                    if      SndID__End > CmdID__First
                    fatal   "You have too many SndPtrs. SndID__End ($\{SndID__End}) can't exceed CmdID__First ($\{CmdID__First})."
                    endif
                    endif

; 2P VS results screens
offset          :=      TwoPlayerResultsPointers
ptrsize         :=      8
idstart         :=      0

VsRSID_Act      =       id(VsResultsScreen_Act)         ; 0
VsRSID_Zone     =       id(VsResultsScreen_Zone)        ; 1
VsRSID_Game     =       id(VsResultsScreen_Game)        ; 2
VsRSID_SS       =       id(VsResultsScreen_SS)          ; 3
VsRSID_SSZone   =       id(VsResultsScreen_SSZone)      ; 4

; Animation IDs
offset          :=      SonicAniData
ptrsize         :=      2
idstart         :=      0

AniIDSonAni_Walk            =       id(SonAni_Walk_ptr)  ; 0 ;   0
AniIDSonAni_Run             =       id(SonAni_Run_ptr)  ; 1 ;   1
AniIDSonAni_Roll            =       id(SonAni_Roll_ptr)  ; 2 ;   2
AniIDSonAni_Roll2           =       id(SonAni_Roll2_ptr)  ; 3 ;   3
AniIDSonAni_Push            =       id(SonAni_Push_ptr)  ; 4 ;   4
AniIDSonAni_Wait            =       id(SonAni_Wait_ptr)  ; 5 ;   5
AniIDSonAni_Balance         =       id(SonAni_Balance_ptr)  ; 6 ;   6
AniIDSonAni_LookUp          =       id(SonAni_LookUp_ptr)  ; 7 ;   7
AniIDSonAni_Duck            =       id(SonAni_Duck_ptr)  ; 8 ;   8
AniIDSonAni_Spindash        =       id(SonAni_Spindash_ptr)  ; 9 ;   9
AniIDSonAni_Blink           =       id(SonAni_Blink_ptr)  ; 10 ;  $A ; Exclusive to Sonic
AniIDSonAni_GetUp           =       id(SonAni_GetUp_ptr)  ; 11 ;  $B ; Exclusive to Sonic
AniIDSonAni_Balance2        =       id(SonAni_Balance2_ptr)  ; 12 ;  $C ; Exclusive to Sonic
AniIDSonAni_Stop            =       id(SonAni_Stop_ptr)  ; 13 ;  $D
AniIDSonAni_Float           =       id(SonAni_Float_ptr)  ; 14 ;  $E
AniIDSonAni_Float2          =       id(SonAni_Float2_ptr)  ; 15 ;  $F
AniIDSonAni_Spring          =       id(SonAni_Spring_ptr)  ; 16 ; $10
AniIDSonAni_Hang            =       id(SonAni_Hang_ptr)  ; 17 ; $11
AniIDSonAni_Dash2           =       id(SonAni_Dash2_ptr)  ; 18 ; $12 ; Unused
AniIDSonAni_Dash3           =       id(SonAni_Dash3_ptr)  ; 19 ; $13 ; Unused
AniIDSonAni_Hang2           =       id(SonAni_Hang2_ptr)  ; 20 ; $14
AniIDSonAni_Bubble          =       id(SonAni_Bubble_ptr)  ; 21 ; $15
AniIDSonAni_DeathBW         =       id(SonAni_DeathBW_ptr)  ; 22 ; $16
AniIDSonAni_Drown           =       id(SonAni_Drown_ptr)  ; 23 ; $17
AniIDSonAni_Death           =       id(SonAni_Death_ptr)  ; 24 ; $18
AniIDSonAni_Hurt            =       id(SonAni_Hurt_ptr)  ; 25 ; $19
AniIDSonAni_Hurt2           =       id(SonAni_Hurt2_ptr)  ; 26 ; $1A
AniIDSonAni_Slide           =       id(SonAni_Slide_ptr)  ; 27 ; $1B
AniIDSonAni_Blank           =       id(SonAni_Blank_ptr)  ; 28 ; $1C
AniIDSonAni_Balance3        =       id(SonAni_Balance3_ptr)  ; 29 ; $1D ; Exclusive to Sonic
AniIDSonAni_Balance4        =       id(SonAni_Balance4_ptr)  ; 30 ; $1E ; Exclusive to Sonic
AniIDSupSonAni_Transform    =       id(SupSonAni_Transform_ptr)  ; 31 ; $1F ; Exclusive to Sonic
AniIDSonAni_Lying           =       id(SonAni_Lying_ptr)  ; 32 ; $20 ; Exclusive to Sonic
AniIDSonAni_LieDown         =       id(SonAni_LieDown_ptr)  ; 33 ; $21 ; Exclusive to Sonic

offset          :=      TailsAniData
ptrsize         :=      2
idstart         :=      0

AniIDTailsAni_HaulAss   =       id(TailsAni_HaulAss_ptr)  ; 31 ; $1F
AniIDTailsAni_Fly       =       id(TailsAni_Fly_ptr)    ; 32 ; $20

; Other sizes
palette_line_size   =       $10*2                       ; 16 word entries

tile_width                  =       8
tile_height                 =       8
tile_height_2p              =       tile_height*2
block_width                 =       tile_width*2
block_height                =       tile_height*2
chunk_width                 =       block_width*8
chunk_height                =       block_height*8
screen_width                =       tile_width*40       ; H40 mode
screen_height               =       tile_height*28      ; V28 mode
screen_width_ss             =       tile_width*32       ; H32 mode
screen_height_ss            =       tile_height*28      ; V28 mode
gameplay_plane_width        =       tile_width*64       ; 64x32 plane size
gameplay_plane_height       =       tile_height*32      ; 64x32 plane size
gameplay_plane_height_2p    =       tile_height_2p*32   ; 64x32 plane size

; The VDP's sprite coordinates place the top-left pixel of the screen at $80,$80,
; these constants are to help deobfuscate that
sprite_left_boundary    =       $80
sprite_top_boundary     =       $80
; Interlace Mode 2 has its top-left coordinate at $80,$100 instead
sprite_top_boundary_2p  =       sprite_top_boundary*2

; Sprite queue
object_display_list_size_bits       =       7
object_display_list_size            =       1<<object_display_list_size_bits  ; How big a list is
total_object_display_lists_bits     =       3
total_object_display_lists          =       1<<total_object_display_lists_bits  ; How many lists there are
