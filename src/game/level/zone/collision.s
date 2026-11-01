ColCurveMap:    BINCLUDE "data/collision/Curve and resistance mapping.bin"
                even
ColArrayVertical:   BINCLUDE "data/collision/Collision array - Vertical.bin"
ColArrayHorizontal: BINCLUDE "data/collision/Collision array - Horizontal.bin"
                even

; These are all compressed in the Kosinski format
ColP_EHZHTZ:    BINCLUDE "data/collision/EHZ and HTZ primary 16x16 collision index.kos"
                even
ColS_EHZHTZ:    BINCLUDE "data/collision/EHZ and HTZ secondary 16x16 collision index.kos"
                even
ColP_WZ:                                                ; BINCLUDE "data/collision/WZ primary 16x16 collision index.kos"
; even
ColP_MTZ:       BINCLUDE "data/collision/MTZ primary 16x16 collision index.kos"
                even
ColP_HPZ:                                               ; BINCLUDE "data/collision/HPZ primary 16x16 collision index.kos"
; even
ColS_HPZ:                                               ; BINCLUDE "data/collision/HPZ secondary 16x16 collision index.kos"
; even
ColP_OOZ:       BINCLUDE "data/collision/OOZ primary 16x16 collision index.kos"
                even
ColP_MCZ:       BINCLUDE "data/collision/MCZ primary 16x16 collision index.kos"
                even
ColP_CNZ:       BINCLUDE "data/collision/CNZ primary 16x16 collision index.kos"
                even
ColS_CNZ:       BINCLUDE "data/collision/CNZ secondary 16x16 collision index.kos"
                even
ColP_CPZDEZ:    BINCLUDE "data/collision/CPZ and DEZ primary 16x16 collision index.kos"
                even
ColS_CPZDEZ:    BINCLUDE "data/collision/CPZ and DEZ secondary 16x16 collision index.kos"
                even
ColP_ARZ:       BINCLUDE "data/collision/ARZ primary 16x16 collision index.kos"
                even
ColS_ARZ:       BINCLUDE "data/collision/ARZ secondary 16x16 collision index.kos"
                even
ColP_WFZSCZ:    BINCLUDE "data/collision/WFZ and SCZ primary 16x16 collision index.kos"
                even
ColS_WFZSCZ:    BINCLUDE "data/collision/WFZ and SCZ secondary 16x16 collision index.kos"
                even
ColP_Invalid:

;---------------------------------------------------------------------------------------
; Offset index of level layouts
; Two entries per zone, pointing to the level layouts for acts 1 and 2 of each zone
; respectively
;---------------------------------------------------------------------------------------
