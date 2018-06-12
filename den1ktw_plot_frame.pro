function den1ktw_plot_frame, xdata,ydata, $
                             lun=lun, $
                             normalize=normalize, $
                             log=log, $
                             power=power, $
                             _EXTRA=ex

  if n_elements(lun) eq 0 then lun = -1
  if keyword_set(normalize) then ydata /= max(ydata)
  if keyword_set(power) then ydata = ydata^2
  if keyword_set(log) then ydata = 10*alog10(ydata)

  frm = plot(xdata,ydata,_EXTRA=ex)

  return, frm
end
