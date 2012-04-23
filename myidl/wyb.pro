pro wyb
;yellow-black color table

;from white (255,255,255) to black (0,0,0)
;from yellow(255,255,0) to black (0,0,0)

;(red,gree,blue)

steps = 60
scaleFactor = FINDGEN(steps) / (steps - 1)
   
; Do first 100 colors (white to yellow).
   
    ; Red vector: 255 -> 255
    redVector=REPLICATE(255, steps)

    ; Green vector: 255 -> 255
    greenVector=REPLICATE(255, steps)

    ; Blue vector: 255 -> 0
    blueVector = 255 + (0 - 255) * scaleFactor
   
steps=200-steps
scaleFactor = FINDGEN(steps) / (steps - 1)
; Do second 100 colors (yellow to black).
   
    ; Red vector: 255 -> 0
    redVector = [redVector, 255 + (0 - 255) * scaleFactor]

    ; Green vector: 255 -> 0
    greenVector = [greenVector, 255 + (0 - 255) * scaleFactor]
   
    ; Blue vector: 0 -> 0
    blueVector = [blueVector, REPLICATE(0, steps)]

redVector=reverse(redVector)
greenVector=reverse(greenVector)
blueVector=reverse(blueVector)

   TVLCT, redVector, greenVector, blueVector  


end