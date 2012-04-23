FUNCTION power,dataset,window=wind,torder=to,nomean=nom,wx=wx,wy=wy
;+
; NAME:
;	POWER
; PURPOSE:  
;       calculate power of a given data set.The data set can be one or
;       two dimensional.There are quite a number of different data
;       windows and other method available to calculate the power of
;       a data series.Anyone who uses this routine is asked to provide
;       himself with the necessary information about that topic.
;       For further information see:
;           Blackman,Tukey : The measurement of power spectra , Dover
;           Chatfield      : The analysis of time series , Chapman & Hall
;           Press et al.   : Numerical Recipes , p.420 ff , Cambridge U.P.
;*CATEGORY:            @CAT-#  4 10@
;	Power Spectra , FFT
; CALLING SEQUENCE:
;	result=POWER(Data,[keywords])
; INPUTS:
;	Data         : 1 or 2-dim Array with Data
; OPTIONAL INPUTS: (KEYWORDS)
;	WINDOW=win   : One of the strings (case insensitive)
;		       'Bartlett','Hanning','Hamming',Parzen' or 'Welch'
;		       'Cosine <p>'
;		       See Literature for explanation; 
;		       'Cosine <p>' : window with cos -edges extending
;		       over <p> percentage of the data vector (letting
;		       unchanged 100-2*<p> % of the inner part of the data);
;		       if <p> is omitted (WINDOW='cosine') or 0 <= p < 10,
;		       p will be set to 10; if p < 0, the cos -edges will
;		       affect the |p| innermost points of the data (each
;		       dimension of array Data).
;       /NOMEAN      : If set, don't subtract average
;	TORDER=order : polynomial trend removal of order torder is to be 
;		       applied.
; OUTPUTS:
; 	1 or 2-dim Real Array of half dimensions of Data;
;	if an error was detected, the string 'undefined' will be returned.
; OPTIONAL OUTPUTS: (KEYWORDS)
;       WX=wx        : return window function for 1st dimension; 
;		       size of vector wx same as size of 1st dim. of dataset.
;       WY=wy        : return window function for 2nd dimension (meaningful 
;		       only if dataset is 2-dim); 
;		       size of vector wy same as size of 2nd dim. of dataset.
; COMMON BLOCKS:
;       none
; SIDE EFFECTS:
; 	none
; RESTRICTIONS:
; 	none
; PROCEDURE:
; 	subtract average of data (except nomean is set)
;	if torder is set: Trend removal
;	1 or 2-dim FFT using built-in IDL-routine
;	return normalized square of absolute FFT-values
; MODIFICATION HISTORY:
; AUTHORS : Robert Greimel , University of Graz,Austria, Dpt. of Astronomy
;           Peter Suetterlin , Kiepenheuer Institut fuer Sonnenphysik, 
;                              Freiburg , FRG
;           25-Mar-1990
;  changes : 1-Jan-1991  PS
;            16-Dec-1992 H. Schleicher, KIS : 
;	                 use norm for normalization (not num^2);
;	                 Cosine window, optional output wx, wy.
;                        
;---
on_error,1
; get information about the dataset
;
s=size(dataset)
if (s(0) eq 0) then begin errtxt='dataset is scalar' & goto,errexit & endif
if (s(0) gt 2) then begin 
  errtxt='dimension of dataset exceeds 2' & goto,errexit
endif
if (s(0) eq 2 and (s(1) eq 1 or s(2) eq 1)) then begin
  s(0)=1
  s(1)=s(1)>s(2)
endif
num=n_elements(dataset)
;
; get window function
;
if not keyword_set(wind) then begin
  wx=replicate(1.,s(1))
  if (s(0) ge 2) then wy=replicate(1.,s(2))
  norm=float(num)^2
  goto,windowend
endif
if (size(wind))(0) ne 0 then begin 
    errtxt='keyword WINDOW: parameter not a scalar string' & goto,errexit
endif
case (size(wind))(1) of
  2: begin
     if wind eq 1 then begin 
        win='cosine' & wcos=0.1  ; default for /WINDOW 
     endif else begin
         errtxt='keyword WINDOW: parameter not a scalar string' & goto,errexit
     endelse
     end
  7: begin
     win=strlowcase(strcompress(wind,/rem))
     j=strpos(win,'cosine')
     if j ge 0 then begin
        wcos=0.1  ; default cosine window edge size 10 % of data vector size
        if strlen(win) gt 6 then begin
           reads,strmid(win,j+6,99),wcos & win='cosine'
        endif
    endif
    end
  else: begin 
        errtxt='keyword WINDOW: parameter not a scalar string' & goto,errexit
        end
endcase
;
case win of
  'bartlett':begin
              wx=1-abs((findgen(s(1))-0.5*(s(1)-1))/(0.5*(s(1)-1)))
              if (s(0) ge 2) then $
                wy=1-abs((findgen(s(2))-0.5*(s(2)-1))/(0.5*(s(2)-1)))
            end
  'hamming':begin
              wx=0.54-0.46*cos(2*!pi*findgen(s(1))/(s(1)-1))
              if (s(0) ge 2) then $
                wy=0.54-0.46*cos(2*!pi*findgen(s(2))/(s(2)-1))
            end
  'hanning':begin
              wx=0.5*(1-cos(2*!pi*findgen(s(1))/(s(1)-1)))
              if (s(0) ge 2) then wy=0.5*(1-cos(2*!pi*findgen(s(2))/(s(2)-1)))
            end
  'parzen': begin
              wx=1-abs((findgen(s(1))-0.5*(s(1)-1))/(0.5*(s(1)+1)))
              if (s(0) ge 2) then $
                wy=1-abs((findgen(s(2))-0.5*(s(2)-1))/(0.5*(s(2)+1)))
            end
  'welch':  begin
              wx=1-((findgen(s(1))-0.5*(s(1)-1))/(0.5*(s(1)+1)))^2
              if (s(0) ge 2) then $
                wy=1-((findgen(s(2))-0.5*(s(2)-1))/(0.5*(s(2)+1)))^2
            end
  'cosine': begin
              wx=replicate(1.,s(1)) & if (s(0) ge 2) then wy=replicate(1.,s(2))
              if wcos ge 0. then begin
	         wcos=wcos/100. > 0.1 & i1=(fix(s(1)*wcos)-1) > 1
              endif else           i1=fix(-wcos+0.5) > 1
	      i2=(s(1)-i1-1) < (s(1)-2)
	      wx(0:i1-1)=0.5*(1.+cos(!pi*(findgen(i1)-i1)/float(i1+1)))
            wx(i2+1:*)=0.5*(1.+cos(!pi*(1.+findgen(s(1)-i2-1))/float(s(1)-i2)))
              if (s(0) ge 2) then begin
	         if wcos ge 0. then i1=(fix(s(2)*wcos)-1) > 1
		 i2=(s(2)-i1-1) < (s(2)-2)
		 wy(0:i1-1)=0.5*(1.+cos(!pi*(findgen(i1)-i1)/float(i1+1)))
	    wy(i2+1:*)=0.5*(1.+cos(!pi*(1.+findgen(s(2)-i2-1))/float(s(2)-i2)))
              endif
            end
  else:     begin
              errtxt='This window is not available: '+win & goto,errexit
            end
endcase
windowend:
;
if (s(0) eq 1) then norm=float(num)*total(wx*wx)
if (s(0) eq 2) then norm=float(num)*total((wx#wy)^2)
;
; trend removal of order to 
;
if (keyword_set(to)) then begin
  if (s(0) eq 1) then begin
    coef=poly_fit(indgen(s(1)),dataset,to,fit)
    data=dataset-fit
    fit=0b
  endif
  if (s(0) eq 2) then data=dataset-surface_fit(dataset,to)
endif else begin
  if (not (keyword_set(nom))) then begin
    data=dataset-(total(dataset)/num)
  endif else data=dataset
endelse
;
; fft , either from detrended or original data
;
if (s(0) eq 1) then fdat=fft(data*wx,1) else fdat=fft(data*(wx#wy),1)
data=0b
;
; calculate power of data set
;
nfreq=s(1)/2 & even = s(1) mod 2 eq 0
fdat=abs(fdat)^2
;
case s(0) of
  1: begin
     p=fdat(0:nfreq) ; ? nfreq-1 ?
     if even then p(1:*)=p(1:*)+reverse(fdat(nfreq:*)) $
             else p(1:*)=p(1:*)+reverse(fdat(nfreq+1:*))
     end
  2: begin
     nfreq2=s(2)/2 & even2 = s(2) mod 2 eq 0
     p=fdat(0:nfreq,*)
     if even then p(1:*,*)=p(1:*,*)+reverse(fdat(nfreq:*,*)) $
             else p(1:*,*)=p(1:*,*)+reverse(fdat(nfreq+1:*,*))
     fdat=p
     p=fdat(*,0:nfreq2)
     if even2 then $
        p(*,1:*)=p(*,1:*)+transpose(reverse(transpose(fdat(*,nfreq2:*)))) $
                         else $
        p(*,1:*)=p(*,1:*)+transpose(reverse(transpose(fdat(*,nfreq2+1:*))))
    end
endcase
;
return,p/float(norm)  ; regular exit
;
errexit:
print,'% POWER: '+errtxt
return,'undefined'
;
end









