;+
; Return error in centroid. This allows for a single interface. Could
; easily expand to 3D.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
function centroid_error, data,xcm,ycm, $
                         lun=lun, $
                         quiet=quiet, $
                         single_pixel=single_pixel, $
                         prop_to_f=prop_to_f

  dsize = size(data)
  nd = dsize[0]
  nx = dsize[1]
  ny = dsize[2]

  x = indgen(nx)
  y = indgen(ny)

  if keyword_set(prop_to_f) then begin
     dev_x = 0.0
     dev_y = 0.0
     for ix=0,nx-1 do begin
        for iy=0,ny-1 do begin
           dev_x += (data[ix,iy]*(x[ix]-xcm)/total(data))^2
           dev_y += (data[ix,iy]*(y[ix]-ycm)/total(data))^2
        endfor
     endfor
     dev_x = sqrt(dev_x)
     dev_y = sqrt(dev_y)
  endif
  if keyword_set(single_pixel) then begin
     dev_x = 1.0
     dev_y = 1.0
  endif

  return, [dev_x,dev_y]
end
