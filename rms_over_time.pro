;+
; Calculate the rms over a set of time ranges.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
function rms_over_time, f,r

  ;;==Get dimensions of range array
  rsize = size(r)
  nr = rsize[2]
  fdims = size(f,/dim)

  ;;==Set up RMS array
  f_rms = make_array([fdims[0:1],nr],type=size(f,/type))

  ;;==Calculate RMS array
  for ir=0,nr-1 do $
     f_rms[*,*,ir] = rms(f[*,*,r[0,ir]:r[1,ir]-1],dim=3)

  return, f_rms
end
