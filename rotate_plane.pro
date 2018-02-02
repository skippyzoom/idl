;+
; Rotate a 2-D array and overwrite the original.
; If the rotation is an odd multiple of 90 degrees, also
; swap the X & Y dimensions.
; This routine was originally designed for image processing.
;-
pro rotate_plane, pdata,rot, $
                  xdata=xdata,ydata=ydata, $
                  xrng=xrng,yrng=yrng


  ;;==Defaults and guards
  have_axis_data = keyword_set(xdata) and keyword_set(ydata)
  if keyword_set(xdata) xor keyword_set(ydata) then $
     message, "[ROTATE_PLANE] Please provide xdata AND ydata or neither."
  have_axis_rng = keyword_set(xrng) and keyword_set(yrng)
  if keyword_set(xrng) xor keyword_set(yrng) then $
     message, "[ROTATE_PLANE] Please provide xrng AND yrng or neither."

  ;;==Check dimensions
  psize = size(pdata)
  n_dims = psize[0]
  if n_dims eq 3 then begin

     ;;==Get number of time steps
     nt = psize[n_dims]

     ;;==Rotation will swap X & Y dimensions
     if (rot mod 2) then begin
        nx = psize[2]
        ny = psize[1]
        if have_axis_data then begin
           tmp = xdata
           xdata = ydata
           ydata = tmp
        endif
        if have_axis_rng then begin
           tmp = xrng
           xrng = yrng
           yrng = tmp
        endif
        tmp = pdata
        pdata = make_array(nx,ny,nt,type=size(pdata,/type))
        for it=0,nt-1 do pdata[*,*,it] = rotate(tmp[*,*,it],rot)
        tmp = !NULL
     endif $
     ;;==Rotation will not swap X & Y dimensions
     else begin
        nx = psize[1]
        ny = psize[2]
        for it=0,nt-1 do pdata[*,*,it] = rotate(pdata[*,*,it],rot)
     endelse

  endif $
  else print, "[ROTATE_PLANE] Data must be 3D (nx,ny,nt)"

end
