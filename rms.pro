;+
; Compute the RMS of input data.
; Accepts all keyword parameters to mean(). 
;-
function rms, data,_EXTRA=ex
  return, sqrt(mean(data^2,_EXTRA=ex))
end
