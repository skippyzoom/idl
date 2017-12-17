<<<<<<< HEAD
;+
; Routine for producing single- or multi-panel 
; images of EPPIC spatial data from a project 
; dictionary or data array.
;
; NOTES
; -- This function should remain independent of any project dictionary.
;
; TO DO
; -- Check for consistency between panel_layout and panel_index.
;-
function multi_image, imgdata,xdata,ydata, $
                      panel_index=panel_index, $
                      panel_layout=panel_layout, $
                      rgb_table=rgb_table, $
                      min_value=min_value, $
                      max_value=max_value, $
                      xtitle=xtitle, $
                      ytitle=ytitle, $
                      xshow=xshow, $
                      yshow=yshow, $
                      xrange=xrange, $
                      yrange=yrange
=======
function multi_image, imgdata,xdata,ydata,_EXTRA=ex
>>>>>>> new_pipeline

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
        ;; d_ex.remove, 'layout'
     endif
     if d_ex.haskey('position') then position = d_ex.position

     ;;==Declare image-handle array
     img = objarr(nt)

     ;;==Loop over time steps
     for it=0,nt-1 do begin

        ;;==Insert current time step for user-defined keywords
        if n_elements(layout) ne 0 then d_ex.layout = layout[*,it]
        if n_elements(position) ne 0 then d_ex.position = position[*,it]
        ;; ex = d_ex.tostruct()

        ;;==Create image panel(s)
        img[it] = image(imgdata[*,*,it],xdata,ydata, $
                        current = (it gt 0), $
                        /buffer, $
                        _EXTRA = d_ex.tostruct())
     endfor

     return, img
  endelse

end
