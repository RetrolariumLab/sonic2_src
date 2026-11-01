MusicPoint2:    startBank
                music_ptr Mus_CNZ_2P
                music_ptr Mus_EHZ
                music_ptr Mus_MTZ
                music_ptr Mus_CNZ
                music_ptr Mus_MCZ
                music_ptr Mus_MCZ_2P
                music_ptr Mus_ARZ
                music_ptr Mus_DEZ
                music_ptr Mus_SpecStage
                music_ptr Mus_Options
                music_ptr Mus_Ending
                music_ptr Mus_EndBoss
                music_ptr Mus_CPZ
                music_ptr Mus_Boss
                music_ptr Mus_SCZ
                music_ptr Mus_OOZ
                music_ptr Mus_WFZ
                music_ptr Mus_EHZ_2P
                music_ptr Mus_2PResult
                music_ptr Mus_SuperSonic
                music_ptr Mus_HTZ
                music_ptr Mus_ExtraLife
                music_ptr Mus_Title
                music_ptr Mus_EndLevel
                music_ptr Mus_GameOver
                music_ptr Mus_Invincible
                music_ptr Mus_Emerald
                music_ptr Mus_HPZ
                music_ptr Mus_Drowning
                music_ptr Mus_Credits

; loc_F803C:
Mus_HPZ:        include "build/music/90 - HPZ.inc"
Mus_Drowning:   include "build/music/9F - Drowning.inc"
Mus_Invincible: include "build/music/97 - Invincible.inc"
Mus_CNZ_2P:     include "build/music/88 - CNZ 2P.inc"
Mus_EHZ:        include "build/music/82 - EHZ.inc"
Mus_MTZ:        include "build/music/85 - MTZ.inc"
Mus_CNZ:        include "build/music/89 - CNZ.inc"
Mus_MCZ:        include "build/music/8B - MCZ.inc"
Mus_MCZ_2P:     include "build/music/83 - MCZ 2P.inc"
Mus_ARZ:        include "build/music/87 - ARZ.inc"
Mus_DEZ:        include "build/music/8A - DEZ.inc"
Mus_SpecStage:  include "build/music/92 - Special Stage.inc"
Mus_Options:    include "build/music/91 - Options.inc"
Mus_Ending:     include "build/music/95 - Ending.inc"
Mus_EndBoss:    include "build/music/94 - Final Boss.inc"
Mus_CPZ:        include "build/music/8E - CPZ.inc"
Mus_Boss:       include "build/music/93 - Boss.inc"
Mus_SCZ:        include "build/music/8D - SCZ.inc"
Mus_OOZ:        include "build/music/84 - OOZ.inc"
Mus_WFZ:        include "build/music/8F - WFZ.inc"
Mus_EHZ_2P:     include "build/music/8C - EHZ 2P.inc"
Mus_2PResult:   include "build/music/81 - 2 Player Menu.inc"
Mus_SuperSonic: include "build/music/96 - Super Sonic.inc"
Mus_HTZ:        include "build/music/86 - HTZ.inc"
Mus_Title:      include "build/music/99 - Title Screen.inc"
Mus_EndLevel:   include "build/music/9A - End of Act.inc"
Mus_ExtraLife:  include "build/music/98 - Extra Life.inc"
Mus_GameOver:   include "build/music/9B - Game Over.inc"
Mus_Emerald:    include "build/music/9D - Got Emerald.inc"
Mus_Credits:    include "build/music/9E - Credits.inc"

; ------------------------------------------------------------------------------------------
; Sound effect pointers
; ------------------------------------------------------------------------------------------
; WARNING the sound driver treats certain sounds specially
; going by the ID of the sound
; SndID_Ring, SndID_RingLeft, SndID_Gloop, SndID_SpindashRev
; are referenced by the sound driver directly
; If needed you can change this in s2.sounddriver.asm

; NOTE: the exact order of this list determines the priority of each sound, since it determines the sound's SndID
; a sound can get dropped if a higher-priority sound is already playing
; see zSFXPriority for the priority allocation itself
; loc_FEE91: SoundPoint:
