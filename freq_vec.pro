;+
; Build vector of frequencies appropriate to IDL's FFT.
; See www.harrisgeospatial.com/docs/fft.html
;-
function freq_vec, n,t
  x = findgen((n - 1)/2) + 1
  n_is_even = (n mod 2) eq 0
  if n_is_even then $
     freq = [0.0, x, n/2, -n/2 + x]/(n*t) $
  else $
     freq = [0.0, x, -(n/2 + 1) + x]/(n*t)
  return, freq
end
