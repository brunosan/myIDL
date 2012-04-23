pro histo,tab1,mini,maxi,bin,abs=abs,cumul=cumul,overplot=overplot
;+
; FUNCTION: This procedure displays the histogram of 
;           the array tab1.
;
; INPUTS  : tab1 --> array (NO DEFAULT)
;         : mini --> minimum value (NO DEFAULT)
;         : maxi --> maximum value (NO DEFAULT)
;         : mini --> size on the bin (NO DEFAULT)
;
; OUTPUTS : diplay
;
; OPTIONS : default   --> percentage 
;           /abs      --> compute the histogram in number of values
;           /cumul    --> compute the cumulative histogram 
;           /overplot --> overplot the histogram  
;
; USE     : histo, array1, 0,500,1, /cumul
;
; CONTACT : Didier JOURDAN   didier@esrg.ucsb.edu
;-
;
; compute histogram of the values
;
hist=histogram(tab1,binsize=bin,min=mini,max=maxi)
;
ifin=n_elements(hist)
sum=fltarr(ifin)
ytitl1="!17histogram in number"
ytitl2=" "
;
; keyword abs active : number of values
;
if (keyword_set(abs) eq 0) then begin
  hist=float(hist)/total(hist)
  ytitl1="!17histogram in percentage"
endif
;
; keyword abs active : cumulative histogram
;
if (keyword_set(cumul) ne 0) then begin
  for i=0,ifin-1 do begin
    sum(i)=total(hist(0:i))
  endfor
  hist=sum
  ytitl2="!17cumulative "
endif
;
; set ytitle
;
ytitl=string(ytitl2,ytitl1)
ytitl=strcompress(ytitl)
if (keyword_set(overplot) eq 0) then begin
;
; plot
;
   plot, findgen(ifin)*bin+mini+bin/2.,hist,psym=10, $
   ytitle=ytitl, $
   xrange=[mini,maxi]
endif else begin
;
; overplot
;
  oplot, findgen(ifin)*bin+mini+bin/2.,hist,psym=10, $
   ytitle=ytitl, $
   xrange=[mini,maxi]
endelse
return
end


