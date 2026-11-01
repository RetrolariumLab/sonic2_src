; end of 'ROM'
                if      (*-StartOfRom)&(*-StartOfRom-1)
                cnop    -1,2<<lastbit(*-StartOfRom-1)
                dc.b    $00
paddingSoFar    :=      paddingSoFar+1
                else
                even
                endif
EndOfRom:
                if      MOMPASS=2
; "About" because it will be off by the same amount that Size_of_Snd_driver_guess is incorrect (if you changed it), and because I may have missed a small amount of internal padding somewhere
                message "ROM size is $\{EndOfRom-StartOfRom} bytes (\{(EndOfRom-StartOfRom)/1024.0} KiB). About $\{paddingSoFar} bytes are padding. "
                endif
; share these symbols externally (WARNING: don't rename, move or remove these labels!)
                shared  movewZ80CompSize
                END
