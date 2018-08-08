function ktw_image_frame, fdata,xdata,ydata, $
                          lun=lun, $
                          power=power, $
                          normalize=normalize, $
                          log=log, $
                          _EXTRA=ex

  if n_elements(lun) eq 0 then lun = -1
  if keyword_set(normalize) then fdata /= max(fdata)
  if keyword_set(power) then fdata = fdata^2
  if keyword_set(log) then fdata = 10*alog10(fdata)

  if n_elements(xdata) gt 0 && $
     n_elements(ydata) gt 0 then $
        frm = image(fdata,xdata,ydata,_EXTRA=ex) $
  else $
     frm = image(fdata,_EXTRA=ex)

  return, frm
end
