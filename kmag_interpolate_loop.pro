;+
; Loop over freq dimension to build array of
; (|k|,Theta,Omega[,Alpha]).
;
; NB: This rountine doesn't actually know if
;     the fft transformed the time dimension,
;     so it can equivalently return an array
;     of (|k|,Theta,time[,Alpha]).
;
;-
function kmag_interpolate_loop, fftArray, $
                                dx,dy,dz, $
                                _EXTRA=ex
  ;;==Ensure correct input
  if n_elements(fftArray) eq 0 then $
     message, "Please supply FFT array"

  ;;==Get physical dimension
  ;; fftArray = reform(fftArray)
  ;; fftSize = size(fftArray)
  fftSize = size(reform(fftArray))
  ndim_space = fftSize[0]-1
  if ndim_space ne 2 and ndim_space ne 3 then $
     message, "Input must be 2D or 3D"

  ;;==Defaults and guards
  if n_elements(dx) eq 0 then message, "Please supply dx > 0"
  if n_elements(dy) eq 0 then message, "Please supply dy > 0"
  if ndim_space eq 3 and n_elements(dz) eq 0 then $
     message, "Please supply dz > 0"

  ;;==Get sizes for output array
  ;--> Update this after adding /info keyword to kmag_interpolate?
  nOmega = fftSize[fftSize[0]]
  dummy = kmag_interpolate(fftArray[*,*,*,0],dx,dy,dz, $
                           _EXTRA=ex)
  nk = n_elements(dummy.kVals)
  if tag_exist(ex,'nTheta',/top_level) then nTheta = ex.nTheta $
  else nTheta = 360
  if tag_exist(ex,'nAlpha',/top_level) then nAlpha = ex.nAlpha $
  else nAlpha = 1
  ;; if n_elements(ex.nTheta) eq 0 then nTheta = 360 $
  ;; else nTheta = ex.nTheta
  ;; if n_elements(ex.nAlpha) eq 0 then nAlpha = 1 $
  ;; else nAlpha = ex.nAlpha
  kmagOmega = fltarr(nk,nTheta,nOmega,nAlpha)

  ;;==Loop over time/freq
  for iw=0,nOmega-1 do begin
     dummy = kmag_interpolate(fftArray[*,*,*,iw],dx,dy,dz, $
                              _EXTRA=ex)
     kmagOmega[*,*,iw,*] = dummy.kmag
  endfor

  return, kmagOmega
end
