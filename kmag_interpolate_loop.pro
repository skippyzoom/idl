;+
; Loop over freq dimension to build array of
; (|k|,Theta,<Omega or t>[,Alpha]), where |k|
; is wavenumber magnitude, Theta is flow angle,
; Omega is frequency, t is time, and Alpha is
; aspect angle. The use of "<Omega or t>" implies 
; that thisfunction is ignorant of whether the 
; time dimension of data was transformed.
;
; TO DO:
; -- Consider separate routines (via an IF or CASE)
;    for 2D and 3D, since that will affect
;    how to index data.
;-
function kmag_interpolate_loop, data, $
                                dx=dx,dy=dy,dz=dz, $
                                _EXTRA=ex
  ;;==Ensure correct input
  if n_elements(data) eq 0 then $
     message, "Please supply FFT array"

  ;;==Get physical dimension
  fftSize = size(reform(data))
  ndim_space = fftSize[0]-1
  if ndim_space ne 2 and ndim_space ne 3 then $
     message, "Input must be 2D or 3D"

  ;;==Defaults and guards
  if n_elements(dx) eq 0 then message, "Please supply dx > 0"
  if n_elements(dy) eq 0 then message, "Please supply dy > 0"
  if ndim_space eq 3 and n_elements(dz) eq 0 then $
     message, "Please supply dz > 0"

  ;;==Get sizes for output array
  nTime = fftSize[fftSize[0]]
  info = kmag_interpolate(data[*,*,*,0], $
                           dx = dx, $
                           dy = dy, $
                           dz = dz, $
                           _EXTRA=ex,/info)
  nk = n_elements(info.kVals)
  if tag_exist(ex,'nTheta',/top_level) then nTheta = ex.nTheta $
  else nTheta = 360
  if tag_exist(ex,'nAlpha',/top_level) then nAlpha = ex.nAlpha $
  else nAlpha = 1
  array = fltarr(nk,nTheta,nTime,nAlpha)

  ;;==Loop over time/freq
  for it=0,nTime-1 do begin
     dummy = kmag_interpolate(data[*,*,*,it], $
                              dx = dx, $
                              dy = dy, $
                              dz = dz, $
                              _EXTRA=ex)
     array[*,*,it,*] = dummy.array
  endfor

  ;; return, {array: array,info: info}
  return, {array: array, $
           kVals: info.kVals, $
           nTheta: info.nTheta, $
           nAlpha: info.nAlpha, $
           aspect: info.aspect, $
           shape: info.shape}

end
