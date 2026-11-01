; ---------------------------------------------------------------------------
; Clocks
Master_Clock        =       53693175
M68000_Clock        =       Master_Clock/7
Z80_Clock           =       Master_Clock/15
FM_Sample_Rate      =       M68000_Clock/(6*6*4)
PSG_Sample_Rate     =       Z80_Clock/16

; ---------------------------------------------------------------------------
; VDP addressses
VDP_data_port       =       $C00000                     ; (8=r/w, 16=r/w)
VDP_control_port    =       $C00004                     ; (8=r/w, 16=r/w)
PSG_input           =       $C00011

; ---------------------------------------------------------------------------
; Z80 addresses
Z80_RAM             =       $A00000                     ; start of Z80 RAM
Z80_RAM_End         =       $A02000                     ; end of non-reserved Z80 RAM
Z80_Bus_Request     =       $A11100
Z80_Reset           =       $A11200

Security_Addr   =       $A14000

; ---------------------------------------------------------------------------
; I/O Area
HW_Version              =       $A10001
HW_Port_1_Data          =       $A10003
HW_Port_2_Data          =       $A10005
HW_Expansion_Data       =       $A10007
HW_Port_1_Control       =       $A10009
HW_Port_2_Control       =       $A1000B
HW_Expansion_Control    =       $A1000D
HW_Port_1_TxData        =       $A1000F
HW_Port_1_RxData        =       $A10011
HW_Port_1_SCtrl         =       $A10013
HW_Port_2_TxData        =       $A10015
HW_Port_2_RxData        =       $A10017
HW_Port_2_SCtrl         =       $A10019
HW_Expansion_TxData     =       $A1001B
HW_Expansion_RxData     =       $A1001D
HW_Expansion_SCtrl      =       $A1001F

; ---------------------------------------------------------------------------
; Art tile stuff
flip_x              =       (1<<11)
flip_y              =       (1<<12)
palette_bit_0       =       5
palette_bit_1       =       6
palette_line_0      =       (0<<13)
palette_line_1      =       (1<<13)
palette_line_2      =       (2<<13)
palette_line_3      =       (3<<13)
high_priority_bit   =       7
high_priority       =       (1<<15)
palette_mask        =       $6000
tile_mask           =       $07FF
nontile_mask        =       $F800
drawing_mask        =       $7FFF
