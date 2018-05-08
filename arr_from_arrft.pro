;+
; Invert an EPPIC FT array to produce the equivalent coordinate-space
; array.
;-
function arr_from_arrft, arrft,rotate=rotate

  if n_elements(rotate) eq 0 then rotate = 0

  ;;==Create the data array based on FT array dimensions
  ftsize = size(arrft)
  if ftsize[0] eq 3 then $
     arr = fltarr(ftsize[1],ftsize[2],ftsize[3]) $
  else $
     arr = fltarr(ftsize[1],ftsize[2],ftsize[3],ftsize[4])

  ;;==Invert the FT array
  if ftsize[0] eq 3 then $
     for it=0,ftsize[ftsize[0]]-1 do $
        arr[*,*,it] = fft(arrft[*,*,it],/inverse) $
  else $
     for it=0,ftsize[ftsize[0]]-1 do $
        arr[*,*,*,it] = fft(arrft[*,*,*,it],/inverse)

  ;;==Rotate the data array, if requested
  if rotate ne 0 then begin
     fsize = size(arr)
     if rotate mod 2 then begin
        tmp = arr
        arr = make_array(fsize[2],fsize[1],fsize[3],type=fsize[4],/nozero)
        for it=0,fsize[3]-1 do arr[*,*,it] = rotate(tmp[*,*,it],rotate)
     endif $
     else for it=0,fsize[3]-1 do $
        arr[*,*,it] = rotate(arr[*,*,it],rotate)
  endif

  return, arr
end

