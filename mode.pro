FUNCTION Mode, array

   ; Calculates the MODE (value with the maximum frequency distribution) of an array.
   ; Works ONLY with integer data.

   On_Error, 2

   ; Check for arguments.
   IF N_Elements(array) EQ 0 THEN Message, 'Must pass an array argument.'

   ; Is the data an integer type? If not, exit.
   dataType = Size(array, /Type)
   IF ((dataType GT 3) AND (dataType LT 12)) THEN Message, 'Data is not INTEGER type.'

   ; Calculate the distribution frequency
   distfreq = Histogram(array, MIN=Min(array))

   ; Find the maximum of the frequency distribution.
   maxfreq = Max(distfreq)

   ; Find the mode.
   mode = Where(distfreq EQ maxfreq, count) + Min(array)

   ; Warn the user if the mode is not singular.
   IF count NE 1 THEN ok = Dialog_Message('The MODE is not singular.')

   RETURN, mode

END

; Main-level routine for testing purposes.
array = [1, 1, 2 , 4, 1, -3, 3, 2, 4, 5, 3, 2, 2, -1, 2, 6, -3]
Print, Mode(array)
END