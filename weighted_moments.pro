;+
; Calculate the weighted moments of a distribution
;
; This is the LEAST EFFICIENT way to do it but it's a start.
; It also makes it easier to debug.
;
; There should be a way to do this in one pass via the 
; binomial theorem. See eppic/src/moment.cc
;
; HISTORY
; --Created 11Feb2017 (may)
;-



function weighted_moments, values,weights, $
                           standard_deviation=standard_deviation

   nw = n_elements(weights) 
   wm = fltarr(5)*0.0
   for i=0,nw-1 do begin   ;Zeroth moment: sum
      w = weights[i]
      wm[0] += w
   endfor
   for i=0,nw-1 do begin   ;First moment: mean
      w = weights[i]
      x = values[i]
      wm[1] += w*x
   endfor
   wm[1] /= wm[0]
   for i=0,nw-1 do begin   ;Second moment: variance
      w = weights[i]
      x = values[i]
      wm[2] += w*(x-wm[1])^2
   endfor
   wm[2] /= wm[0]
   for i=0,nw-1 do begin   ;Third moment: skewness
      w = weights[i]
      x = values[i]
      wm[3] += w*(x-wm[1])^3
   endfor
   wm[3] /= wm[0]*sqrt(wm[2])^3
   for i=0,nw-1 do begin   ;Fourth moment: kurtosis
      w = weights[i]
      x = values[i]
      wm[4] += w*(x-wm[1])^4
   endfor
   wm[4] /= wm[0]*sqrt(wm[2])^4

   if keyword_set(standard_deviation) then wm[2] = sqrt(wm[2])

   return, wm

end
