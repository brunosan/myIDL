FUNCTION Fnumber, value, ndigits,decimal
;+
; NAME:
;       NNUMBER
; PURPOSE:
;      convert a float with ndigit leading zeros and decimal numbers into string
;I should fix when is 0.99 and only one decimal (sum 1 to the integer)
siz=n_elements(value)

salida=''
for i=0,siz-1 do begin
signo=''
IF value[i] LT 0 then signo='-'
value[i]=abs(value[i])
ente=fix(value[i])
;stop
deci=abs((value[i]-ente))*10^decimal
;deci=fix(round(deci))
deci=fix((deci))

sval=nnumber(ente,ndigits)+'.'+nnumber(deci,decimal)
IF decimal EQ 0 then sval=nnumber(ente,ndigits)
salida=[salida,signo+sval]
endfor
salida=salida[1:*]
  return,salida
END
