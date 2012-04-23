function true_color,a
;
;  convert the type of an array to byte (like bytscl)
;  and transform its values using the current color table
;
on_error,2   ; return to caller
   tvlct,v1,v2,v3,/get          ;get current color table
   color_convert,v1,v2,v3,h1,h2,h3,/rgb_hls
   ct=bytscl(h2)
   ;  transform data using normalized "light" values
return,ct(bytscl(a))
end
