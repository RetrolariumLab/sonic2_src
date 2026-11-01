SpecialCNZBumpers_Act1:
                BINCLUDE "data/level/objects/CNZ 1 bumpers.bin"  ; byte_1781A

SpecialCNZBumpers_Act2:
                BINCLUDE "data/level/objects/CNZ 2 bumpers.bin"  ; byte_1795E
; ===========================================================================

                jmpTos                                  ; Empty

; ===========================================================================
; ---------------------------------------------------------------------------
; Objects Manager
; Subroutine that keeps track of any objects that need to remember
; their state, such as monitors or enemies
;
; input variables:
; -none-
;
; writes:
; d0, d1
; d2 = respawn index of object to load
; d6 = camera position
;
; a0 = address in object placement list
; a2 = respawn table
; ---------------------------------------------------------------------------

; loc_17AA4
