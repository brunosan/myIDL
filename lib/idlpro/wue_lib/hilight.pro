pro hilight, tab, thresmin, thresmax, select=select, binsize=binsize
;+
; FUNCTION: This procedure 
;           - select values according to a user defined criterion
;           - display the selected values.
;           - display the histogram of the selected values in the
;             array tab.
;
; INPUTS  : tab1     --> 2 or 3 dimensional array (NO DEFAULT)
;         : thresmin --> minimum value for which the value 
;                        is selected (NO DEFAULT if use - see OPTIONS)
;         : thresmax --> maximum value for which the value 
;                        is selected (NO DEFAULT if use - see OPTIONS)
;
; OPTIONS : select  --> if thresmin and thresmax are ommitted 
;                       allows to specify the criterion based on a 
;                       different array features.
;           binsize --> defines the size of the bin for the
;                       histogram (DEFAULT = 1.)
;
; USE     : HILIGHT, ARRAY1, 10., 20., BINSIZE=1 : 
;               select and display on the the values in arrray1
;               between 10. and 20. 
;
;           HILIGHT, ARRAY1, SELECT=WHERE(ARRAY2 LE 5.43) :
;               select and display the values in the array1 where
;               array2 is less or equal than 5.43  
;
;
; CONTACT : Didier JOURDAN   didier@esrg.ucsb.edu
;-
;
; missing values
;
miss=9999.
;
sz=size(tab)
maxval=max(tab(where(tab ne miss)))
;
; rescale image
;
imagtab=bytscl(tab, min=0,max=maxval)
if (keyword_set(binsize) eq 0) then binsize=1.
if (keyword_set(select) eq 0) then begin
;
; keyword select not active
;
  if (keyword_set(thresmin) eq 0) and (keyword_set(thresmax) eq 0) then begin
    print, 'ERROR - must specify tresholds'
	return
  endif
;
;select values
;
  iw=where((tab ge thresmin) and (tab lt thresmax))
  minimum=min(tab(iw))
  maximum=max(tab(iw))
  if (minimum ge 0 and maximum gt 0) then begin
	minhisto=0
	minx=fix(minimum)-1
  endif
  if (minimum lt 0) then begin
	minhisto=fix(minimum)-1
	minx=minhisto
  endif
  maxhisto=fix(maximum)+1
  histotab=histogram(tab(iw),binsize=binsize,min=minhisto,max=maxhisto)
  mve,tab(iw)
endif else begin
;
;select keyword active
;
  iw=select
  minimum=min(tab(iw))
  maximum=max(tab(iw))
  if (minimum ge 0 and maximum gt 0) then begin
	minhisto=0
	minx=fix(minimum)-1
  endif
  if (minimum lt 0) then begin
	minhisto=fix(minimum)-1
	minx=minhisto
  endif
;
; compute histogram
;
  maxhisto=fix(maximum)+1
  histotab=histogram(tab(iw),binsize=binsize,min=minhisto,max=maxhisto)
  mve, tab(iw)
endelse
;
; display histogram
;
window,4,title='HISTOGRAM'
histoperc=float(histotab)/total(histotab)
x=findgen(n_elements(iw))*binsize+minhisto+binsize/2.
plot,x, histoperc*100, psym=10, font=17, xrange=[minx,maxhisto], xstyle=1, $
xtitle='image value',title='Histogram selected points', $
yrange=[0,max(histoperc*100)],  ytitle="Percentage"
;
; display location
;
window,2,xs=sz(1),ys=sz(2), title='LOCATE'
imagww=imagtab
imagww(iw)=(imagww(iw)+127) mod 256
flick,imagtab,imagww,10
wset,0
return
end

