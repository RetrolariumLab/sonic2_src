MapEng_EndGameLogo: BINCLUDE "data/mappings/misc/Sonic 2 end of game logo.eni"
                even

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_B262
ShowCreditsScreen:
                lea     Credits_PageLayouts(pc),a1
                move.w  (CreditsScreenIndex).w,d0
                lsl.w   #2,d0
                move.l  (a1,d0.w),d0
                movea.l d0,a1

Credits_DrawPageLayout:
                move    #$2700,sr
                lea     (VDP_data_port).l,a6
-
                move.l  (a1)+,d0
                bmi.s   ++
                movea.l d0,a2
                move.w  (a1)+,d0
                bsr.s   Credits_MakeVramWriteCommand
                move.l  d0,4(a6)
                move.b  (a2)+,d0
                lsl.w   #8,d0
-
                move.b  (a2)+,d0
                bmi.s   +
                move.w  d0,(a6)
                bra.s   -
; ===========================================================================
+               bra.s   --
; ===========================================================================
+
                move    #$2300,sr
                rts
; End of function ShowCreditsScreen

; ---------------------------------------------------------------------------
; Subroutine to convert a VRAM address into a 32-bit VRAM write command word
; Input:
; d0 VRAM address (word)
; Output:
; d0 32-bit VDP command word for a VRAM write to specified address
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Credits_MakeVramWriteCommand:
                andi.l  #$FFFF,d0
                lsl.l   #2,d0
                lsr.w   #2,d0
                ori.w   #vdpComm($0000,VRAM,WRITE)>>16,d0
                swap    d0
                rts
; End of function Credits_MakeVramWriteCommand

; ===========================================================================

; macro for declaring pointer/position structures for intro/credit text
vram_pnt        :=      VRAM_Plane_A_Name_Table
creditsPtrs     macro   addr,pos
                        if      "addr"<>""
                        dc.l    addr
                        dc.w    vram_pnt + pos
                        shift
                        shift
                        creditsPtrs ALLARGS
                        else
                        dc.w    -1
                        endif
                    endm

textLoc         function col,line,(($80 * line) + (2 * col))

; intro text pointers (one intro screen)
vram_pnt        :=      VRAM_TtlScr_Plane_A_Name_Table
