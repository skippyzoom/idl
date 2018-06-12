function den1ktw_image_frame, fdata,tdata,vdata, $
                              lun=lun, $
                              power=power, $
                              normalize=normalize, $
                              log=log, $
                              _EXTRA=ex

  if n_elements(lun) eq 0 then lun = -1
  if keyword_set(normalize) then fdata /= max(fdata)
  if keyword_set(power) then fdata = fdata^2
  if keyword_set(log) then fdata = 10*alog10(fdata)

  frm = image(fdata,tdata,vdata,_EXTRA=ex)

  return, frm
end
