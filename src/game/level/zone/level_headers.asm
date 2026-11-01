LevelArtPointers:
                levartptrs PLCID_Ehz1,        PLCID_Ehz2,      PalID_EHZ,  ArtKos_EHZ, BM16_EHZ, BM128_EHZ  ; EHZ    ; EMERALD HILL ZONE
                levartptrs PLCID_MilesLife2P, PLCID_MilesLife, PalID_EHZ2, ArtKos_EHZ, BM16_EHZ, BM128_EHZ  ; Zone 1 ; LEVEL 1 (UNUSED)
                levartptrs PLCID_TailsLife2P, PLCID_TailsLife, PalID_WZ,   ArtKos_EHZ, BM16_EHZ, BM128_EHZ  ; WZ     ; WOOD ZONE (UNUSED)
                levartptrs PLCID_Unused1,     PLCID_Unused2,   PalID_EHZ3, ArtKos_EHZ, BM16_EHZ, BM128_EHZ  ; Zone 3 ; LEVEL 3 (UNUSED)
                levartptrs PLCID_Mtz1,        PLCID_Mtz2,      PalID_MTZ,  ArtKos_MTZ, BM16_MTZ, BM128_MTZ  ; MTZ1,2 ; METROPOLIS ZONE ACTS 1 & 2
                levartptrs PLCID_Mtz1,        PLCID_Mtz2,      PalID_MTZ,  ArtKos_MTZ, BM16_MTZ, BM128_MTZ  ; MTZ3   ; METROPOLIS ZONE ACT 3
                levartptrs PLCID_Wfz1,        PLCID_Wfz2,      PalID_WFZ,  ArtKos_SCZ, BM16_WFZ, BM128_WFZ  ; WFZ    ; WING FORTRESS ZONE
                levartptrs PLCID_Htz1,        PLCID_Htz2,      PalID_HTZ,  ArtKos_EHZ, BM16_EHZ, BM128_EHZ  ; HTZ    ; HILL TOP ZONE
                levartptrs PLCID_Hpz1,        PLCID_Hpz2,      PalID_HPZ,  ArtKos_HPZ, BM16_HPZ, BM128_HPZ  ; HPZ    ; HIDDEN PALACE ZONE (UNUSED)
                levartptrs PLCID_Unused3,     PLCID_Unused4,   PalID_EHZ4, ArtKos_EHZ, BM16_EHZ, BM128_EHZ  ; Zone 9 ; LEVEL 9 (UNUSED)
                levartptrs PLCID_Ooz1,        PLCID_Ooz2,      PalID_OOZ,  ArtKos_OOZ, BM16_OOZ, BM128_OOZ  ; OOZ    ; OIL OCEAN ZONE
                levartptrs PLCID_Mcz1,        PLCID_Mcz2,      PalID_MCZ,  ArtKos_MCZ, BM16_MCZ, BM128_MCZ  ; MCZ    ; MYSTIC CAVE ZONE
                levartptrs PLCID_Cnz1,        PLCID_Cnz2,      PalID_CNZ,  ArtKos_CNZ, BM16_CNZ, BM128_CNZ  ; CNZ    ; CASINO NIGHT ZONE
                levartptrs PLCID_Cpz1,        PLCID_Cpz2,      PalID_CPZ,  ArtKos_CPZ, BM16_CPZ, BM128_CPZ  ; CPZ    ; CHEMICAL PLANT ZONE
                levartptrs PLCID_Dez1,        PLCID_Dez2,      PalID_DEZ,  ArtKos_CPZ, BM16_CPZ, BM128_CPZ  ; DEZ    ; DEATH EGG ZONE
                levartptrs PLCID_Arz1,        PLCID_Arz2,      PalID_ARZ,  ArtKos_ARZ, BM16_ARZ, BM128_ARZ  ; ARZ    ; AQUATIC RUIN ZONE
                levartptrs PLCID_Scz1,        PLCID_Scz2,      PalID_SCZ,  ArtKos_SCZ, BM16_WFZ, BM128_WFZ  ; SCZ    ; SKY CHASE ZONE

                if      (cur_zone_id<>no_of_zones)&&(MOMPASS=1)
                message "Warning: Table LevelArtPointers has \{cur_zone_id/1.0} entries, but it should have \{no_of_zones/1.0} entries"
                endif
                !org    LevelArtPointers+cur_zone_id*12

; ---------------------------------------------------------------------------
; END Art_Ptrs_Array[17]

; ---------------------------------------------------------------------------
; PATTERN LOAD REQUEST LISTS
;
; Pattern load request lists are simple structures used to load
; Nemesis-compressed art for sprites
;
; The decompressor predictably moves down the list, so request 0 is processed first, etc
; This only matters if your addresses are bad and you overwrite art loaded in a previous request
;

; NOTICE: The load queue buffer can only hold $10 (16) load requests. None of the routines
; that load PLRs into the queue do any bounds checking, so it's possible to create a buffer
; overflow and completely screw up the variables stored directly after the queue buffer
; (in my experience this is a guaranteed crash or hang)
;
; Many levels queue more than 16 items overall,
; but they don't exceed the limit because
; their PLRs are split into multiple parts (like PlrList_Mtz1 and PlrList_Mtz2)
; and they fully process the first part before requesting the rest
;
; If you can find some extra RAM for it (which is easy in Sonic 2),
; you can increase this limit by increasing the size of Plc_Buffer
; ---------------------------------------------------------------------------

;---------------------------------------------------------------------------------------
; Table of pattern load request lists. Remember to use word-length data when adding lists
; otherwise you'll break the array
;---------------------------------------------------------------------------------------
; word_42660 ; OffInd_PlrLists:
