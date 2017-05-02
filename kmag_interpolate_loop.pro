;+
; Loop over freq dimension to build array of
; (|k|,Theta,Omega[,Alpha]).
;
; NB: This rountine doesn't actually know if
;     the fft transformed the time dimension,
;     so it can equivalently return an array
;     of (|k|,Theta,time[,Alpha]).
;
; TO DO:
; -- Consider separate routines (via an IF or CASE)
;    for 2D and 3D, since that will affect
;    how to index fftArray.
;-
function kmag_interpolate_loop, fftArray, $
                                dx,dy,dz, $
                                _EXTRA=ex
  ;;==Ensure correct input
  if n_elements(fftArray) eq 0 then $
     message, "Please supply FFT array"

  ;;==Get physical dimension
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
  nOmega = fftSize[fftSize[0]]
  dummy = kmag_interpolate(fftArray[*,*,*,0],dx,dy,dz, $
                           _EXTRA=ex,/info)
  nk = n_elements(dummy.kVals)
  if tag_exist(ex,'nTheta',/top_level) then nTheta = ex.nTheta $
  else nTheta = 360
  if tag_exist(ex,'nAlpha',/top_level) then nAlpha = ex.nAlpha $
  else nAlpha = 1
  kmagFreq = fltarr(nk,nTheta,nOmega,nAlpha)

  ;;==Loop over time/freq
  for iw=0,nOmega-1 do begin
     dummy = kmag_interpolate(fftArray[*,*,*,iw],dx,dy,dz, $
                              _EXTRA=ex)
     kmagFreq[*,*,iw,*] = dummy.kmag
  endfor

  return, kmagFreq
end
