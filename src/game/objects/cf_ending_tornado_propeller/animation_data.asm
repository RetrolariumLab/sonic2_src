Ani_objCF:      offsetTable
                offsetTableEntry.w EndingPropeller_Animation_Sequence0            ; 0
                offsetTableEntry.w EndingPropeller_Animation_Sequence1            ; 1
                offsetTableEntry.w EndingPropeller_Animation_Sequence2            ; 2
EndingPropeller_Animation_Sequence0:      dc.b    3,  0,  0,  1,$FA,  0
EndingPropeller_Animation_Sequence1:      dc.b    3,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  3,  3,  4,$FA,  0
EndingPropeller_Animation_Sequence2:      dc.b    1,  5,  6,$FF
                even
; -----------------------------------------------------------------------------
; sprite mappings
; -----------------------------------------------------------------------------
ObjCF_MapUnc_ADA2:  include "src/game/objects/cf_ending_tornado_propeller/data/mappings_objcf.asm"
; --------------------------------------------------------------------------------------
; Enigma compressed art mappings
; "Sonic the Hedgehog 2" mappings  ; MapEng_B23A:
                even
