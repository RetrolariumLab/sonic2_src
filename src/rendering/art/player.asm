ArtUnc_Sonic:   BINCLUDE "data/art/uncompressed/Sonic's art.bin"
                align   tiles_to_bytes(1)
ArtUnc_Tails:   BINCLUDE "data/art/uncompressed/Tails's art.bin"

MapUnc_Sonic:   include "src/game/player/sonic/data/mappings_sonic.asm"

MapRUnc_Sonic:  include "src/game/player/sonic/data/dplc_sonic.asm"

ArtNem_Shield:  BINCLUDE "data/art/nemesis/Shield.nem"
                even
ArtNem_Invincible_stars:    BINCLUDE "data/art/nemesis/Invincibility stars.nem"
                even
ArtUnc_SplashAndDust:   BINCLUDE "data/art/uncompressed/Splash and skid dust.bin"

ArtNem_SuperSonic_stars:    BINCLUDE "data/art/nemesis/Super Sonic stars.nem"
                even
MapUnc_Tails:   include "src/game/player/tails/data/mappings_tails.asm"

MapRUnc_Tails:  include "src/game/player/tails/data/dplc_tails.asm"

;---------------------------------------------------------------------------------------
; Sega Screen Assets
;---------------------------------------------------------------------------------------
