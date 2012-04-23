
pro bw_animgif,stack,fname,_extra=eee

spawn,"mkdir blah-dir"
cd,'blah-dir'
writetifs,stack,fname,_extra=eee
spawn,"for i in *tif; do echo $i; j=`echo $i | sed 's/tif/ppm/'`; echo $j; tifftopnm $i > $j; done"
spawn,"rm *.tif"

spawn,"for i in *ppm; do echo $i; j=`echo $i | sed 's/ppm/gif/'`; echo $j; ppmtogif $i > $j; done"
spawn,"rm *.ppm"

print,"run gifsicle command:"
print,"$gifsicle -lforever --colors 256 *.gif > anim.gif"

end

