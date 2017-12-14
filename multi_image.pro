function multi_image, imgdata,xdata,ydata,_EXTRA=ex

  ;;==Make sure image data exists
  if n_elements(imgdata) eq 0 then begin
     print, "[MULTI_IMAGE] Please supply image array. No graphics produced."
     return, !NULL
  endif $
  else begin
     
     ;;==Get data dimensions
     imgsize = size(imgdata)
     nx = imgsize[1]
     ny = imgsize[2]
     nt = imgsize[imgsize[0]]
     if n_elements(xdata) eq 0 then xdata = indgen(nx)
     if n_elements(ydata) eq 0 then ydata = indgen(ny)

     ;;==Extract the user keywords
     d_ex = dictionary(ex,/extract)
     if d_ex.haskey('layout') then begin
        layout = d_ex.layout
        if n_elements(layout) ne 0 then begin
           input = layout
           layout = intarr(3,nt)
           for it=0,nt-1 do layout[*,it] = [input[0],input[1],it+1]
        endif
        d_ex.remove, 'layout'
     endif

     ;;==Declare image-handle array
     img = objarr(nt)

     ;;==Loop over time steps
     for it=0,nt-1 do begin

        ;;==Insert current time step for user-defined keywords
        d_ex.layout = layout[*,it]
        ex = d_ex.tostruct()

        ;;==Create image panel(s)
        img[it] = image(imgdata[*,*,it],xdata,ydata, $
                        current = (it gt 0),/buffer, $
                        _EXTRA=ex)
     endfor

     return, img
  endelse

end
