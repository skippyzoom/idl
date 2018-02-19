;+
; Create multi-panel images from an input array.
; This function assumes that the input is arranged
; as (nx,ny,nt), and loops over the nt dimension.
;
; RETURN VALUE: This function returns an object 
; array of image handles which the caller can use
; to add colorbars, text, etc. That means that it
; is the caller's responsibility to save the image.
;-
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
     endif
     if d_ex.haskey('position') then position = d_ex.position
     if d_ex.haskey('title') then begin
        case n_elements(d_ex.title) of
           0: title = make_array(nt,value='')
           1: title = make_array(nt,value=d_ex.title)
           nt: title = d_ex.title
           else: title = !NULL
        endcase
     endif

     ;;==Declare image-handle array
     img = objarr(nt)

     ;;==Loop over time steps
     for it=0,nt-1 do begin

        ;;==Insert current time step for user-defined keywords
        if n_elements(layout) ne 0 then d_ex.layout = layout[*,it]
        if n_elements(position) ne 0 then d_ex.position = position[*,it]
        if n_elements(title) ne 0 then d_ex.title = title[it]

        ;;==Create image panel(s)
        img[it] = image(imgdata[*,*,it],xdata,ydata, $
                        current = (it gt 0), $
                        /buffer, $
                        _EXTRA = d_ex.tostruct())
     endfor

     return, img
  endelse

end
