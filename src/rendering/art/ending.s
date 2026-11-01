MapEng_Ending1: BINCLUDE "data/mappings/misc/End of game sequence frame 1.eni"
                even
MapEng_Ending2: BINCLUDE "data/mappings/misc/End of game sequence frame 2.eni"
                even
MapEng_Ending3: BINCLUDE "data/mappings/misc/End of game sequence frame 3.eni"
                even
MapEng_Ending4: BINCLUDE "data/mappings/misc/End of game sequence frame 4.eni"
                even
MapEng_EndingTailsPlane:    BINCLUDE "data/mappings/misc/Closeup of Tails flying plane in ending sequence.eni"
                even
MapEng_EndingSonicPlane:    BINCLUDE "data/mappings/misc/Closeup of Sonic flying plane in ending sequence.eni"
                even

; Strange unused mappings (duplicates of MapEng_EndGameLogo)
                rept    9
                BINCLUDE "data/mappings/misc/Sonic 2 end of game logo.eni"
                even
                endm

ArtNem_EndingPics:  BINCLUDE "data/art/nemesis/Movie sequence at end of game.nem"
                even
ArtNem_EndingFinalTornado:  BINCLUDE "data/art/nemesis/Final image of Tornado with it and Sonic facing screen.nem"
                even
ArtNem_EndingMiniTornado:   BINCLUDE "data/art/nemesis/Small pictures of Tornado in final ending sequence.nem"
                even
ArtNem_EndingSonic: BINCLUDE "data/art/nemesis/Small pictures of Sonic and final image of Sonic.nem"
                even
ArtNem_EndingSuperSonic:    BINCLUDE "data/art/nemesis/Small pictures of Sonic and final image of Sonic in Super Sonic mode.nem"
                even
ArtNem_EndingTails: BINCLUDE "data/art/nemesis/Final image of Tails.nem"
                even
ArtNem_EndingTitle: BINCLUDE "data/art/nemesis/Sonic the Hedgehog 2 image at end of credits.nem"
                even

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; LEVEL ART AND BLOCK MAPPINGS (16x16 and 128x128)
;
; #define BLOCK_TBL_LEN  // table length unknown
; #define BIGBLOCK_TBL_LEN // table length unknown
; typedef uint16_t uword
;
; struct blockMapElement {
; uword unk : 5;    // u
; uword patternIndex : 11; };  // i
; // uuuu uiii iiii iiii
;
; blockMapElement (*blockMapTable)[BLOCK_TBL_LEN][4] = 0xFFFF9000
;
; struct bigBlockMapElement {
; uword : 4
; uword blockMapIndex : 12; };  //I
; // 0000 IIII IIII IIII
;
; bigBlockMapElement (*bigBlockMapTable)[BIGBLOCK_TBL_LEN][64] = 0xFFFF0000
;
; /*
; This data determines how the level blocks will be constructed graphically. There are
; two kinds of block mappings: 16x16 and 128x128
;
; 16x16 blocks are made up of four cells arranged in a square (thus, 16x16 pixels)
; Two bytes are used to define each cell, so the block is 8 bytes long. It can be
; represented by the bitmap blockMapElement, of which the members are:
;
; unk
; These bits have to do with pattern orientation. I do not know their exact
; meaning
; patternIndex
; The pattern's address divided by $20. Otherwise said: an index into the
; pattern array
;
; Each mapping can be expressed as an array of four blockMapElements, while the
; whole table is expressed as a two-dimensional array of blockMapElements (blockMapTable)
; The maps are read in left-to-right, top-to-bottom order
;
; 128x128 maps are basically lists of indices into blockMapTable. The levels are built
; out of these "big blocks", rather than the "small" 16x16 blocks. bigBlockMapTable is,
; predictably, the table of big block mappings
; Each big block is 8 16x16 blocks, or 16 cells, square. This produces a total of 16
; blocks or 64 cells
; As noted earlier, each element of the table provides 'i' for blockMapTable[i][j]
; */

; All of these are compressed in the Kosinski format
