pro multi_image_test, imgdata,xdata,ydata,_EXTRA=ex

  ;;==Make sure image data exists
  if n_elements(imgdata) eq 0 then begin
     print, "[MULTI_IMAGE] Please supply image array. No graphics produced."
     return, !NULL
  endif $
  else begin
     
     ;;==Get data dimensions
     imgsize = size(imgdata)
     xsize = imgsize[1]
     ysize = imgsize[2]
     tsize = imgsize[imgsize[0]]
     if n_elements(xdata) eq 0 then xdata = indgen(xsize)
     if n_elements(ydata) eq 0 then ydata = indgen(ysize)

     ;;==Create image panel(s)
     img = objarr(tsize)
     for it=0,tsize-1 do begin
        img[it] = image(imgdata[*,*,it],xdata,ydata, $
                        current = (it gt 0),/buffer, $
                        _EXTRA=ex)
     endfor

     return, img
  endelse

end
