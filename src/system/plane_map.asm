PlaneMapToVRAM_H40:
                lea     (VDP_data_port).l,a6
                move.l  #vdpCommDelta(planeLoc(64,0,1)),d4  ; $800000

-               move.l  d0,VDP_control_port-VDP_data_port(a6)  ; move d0 to VDP_control_port
                move.w  d1,d3

-               move.w  (a1)+,(a6)                      ; from source address to destination in VDP
                dbf     d3,-                            ; next tile

                add.l   d4,d0                           ; increase destination address by $80 (1 line)
                dbf     d2,--                           ; next line

                rts
; End of function PlaneMapToVRAM_H40

; ---------------------------------------------------------------------------
; Alternate subroutine to transfer a plane map to VRAM
; (used for Special Stage background)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_142E: ShowVDPGraphics2: PlaneMapToVRAM2:
PlaneMapToVRAM_H80_SpecialStage:
                lea     (VDP_data_port).l,a6
                move.l  #vdpCommDelta(planeLoc(128,0,1)),d4  ; $1000000
-               move.l  d0,VDP_control_port-VDP_data_port(a6)
                move.w  d1,d3
-               move.w  (a1)+,(a6)
                dbf     d3,-
                add.l   d4,d0
                dbf     d2,--
                rts
; End of function PlaneMapToVRAM_H80_SpecialStage

; ---------------------------------------------------------------------------
; Subroutine for queueing VDP commands (seems to only queue transfers to VRAM),
; to be issued the next time ProcessDMAQueue is called
; Can be called a maximum of 18 times before the buffer needs to be cleared
; by issuing the commands (this subroutine DOES check for overflow)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_144E: DMA_68KtoVRAM: QueueCopyToVRAM: QueueVDPCommand: Add_To_DMA_Queue:
