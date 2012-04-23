pro hi,array,binsize=binsize,$
	xaxis=xaxis,yaxis=visual_density,mode=mode,silent=silent,_extra=extra
; by Edwin Sirko
; 2002-08-07. Added xaxis and yaxis to pass back to calling routine.
; 2003-11-21: found possible bug: starthere is wrong for negative values.

if n_elements(binsize) eq 0 then binsize=(max(array)-min(array))/20.

; This EZ histogram function will make histogramming easier.  
; ES 2000-02-27.  Features:
; - if your minimum data point is 4.26, histogram_ez will take the lowest
;   bin to be from 4.0 to 5.0 (with a binsize of 1), or 3.0 to 6.0 (with 
;   a binsize of 3) or 0.0 to 5.0 (with a binsize of 5).  In other words,
;   it's pretty damn smart.  [The IDL built-in histogram routine would
;   go from 4.26 to 5.26.]
; - it graphs it correctly and you don't have to worry about the x-axis
;   lining up, because histogram_ez worries for you.
; - if behavior of the histogram function didn't go to zero at the endpoints,
;   the old routine would screw up the graph.

; The min=starthere is to force the histogram plot to have
; its left edge coincide with a nice number.
starthere = long(min(array)/binsize) * binsize
density = histogram(array,binsize=binsize,min=starthere,$
	omax=omax,omin=omin)
; Find how many elements in density
number_unique = n_elements(density)

; Need to pad with zeros at either end so that the histogram doesn't
; get stranded in midair
visual_density = fltarr(number_unique+2)
visual_density(1:number_unique) = density
; the binsize scales it horizontally.
; the omin makes sure it lines up correctly
xaxis = (findgen(number_unique+2)-.5)*binsize + omin

if not keyword_set(silent) then $
plot,xaxis,visual_density,psym=10,xrange=[omin,omax],_extra=extra
null=max(visual_density,m)
mode=xaxis[m]
print,'Mode is:',mode,'+- ',binsize
return
end