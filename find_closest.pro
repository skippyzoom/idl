;+
; Find the array value closest to target value
;
; EX:
;   array = [1.8,2.1,3.0]
;   target = 2.0
;   ind = findClosest(array,target)
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

;; function find_closest, array,target,double=double
;;   if keyword_set(double) then begin
;;      array = double(array)
;;      target = double(target)
;;   endif
;;   absDiff = abs(array-target)
;;   minVal = min(absDIff,iMin)
;;   return, iMin
;; end

function find_closest, array,target,double=double
  if keyword_set(double) then begin
     array = double(array)
     target = double(target)
  endif
  n = n_elements(target)
  iMin = lonarr(n)
  for i=0,n-1 do begin
     absDiff = abs(array-target[i])
     minVal = min(absDiff,tmp)
     iMin[i] = tmp
  endfor
  
  if n eq 1 then iMin = iMin[0]
  return, iMin
end
