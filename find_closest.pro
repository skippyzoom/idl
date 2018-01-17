;+
; Find the array value closest to target value
;
; EX:
;   array = [1.8,2.1,3.0]
;   target = 2.0
;   ind = find_closest(array,target)
;   print, array[ind]
;   IDL prints 2.10000
;
; NB: IDL has a function called value_locate() 
;     that works similarly and handles vectors.
;     Note, however, that value_locate()
;     requires that the search vector (i.e.
;     'array' here) be monotonically 
;     increasing.
;
; 21Feb2017: TARGET may be a vector
;-

function find_closest, array,target,double=double

  ;;==Ensure double precision, if requested
  if keyword_set(double) then begin
     array = double(array)
     target = double(target)
  endif

  ;;==Get number of target values
  n = n_elements(target)

  ;;==Find the location of closest value for each target value
  imin = lonarr(n)
  for i=0,n-1 do begin
     abs_diff = abs(array-target[i])
     min_val = min(abs_diff,tmp)
     imin[i] = tmp
  endfor

  ;;==Return a scalar if there's only one target value
  if n eq 1 then imin = imin[0]

  return, imin
end
