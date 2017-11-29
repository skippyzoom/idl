;+
; Routine for producing single- or multi-panel 
; images of EPPIC spatial data from a project 
; dictionary or data array.
;
; NOTES
; -- This function should remain independent of any project dictionary.
;
; TO DO
; -- Set up panel-specific colorbars. May require 
;    making img an array of object references.
; -- Check for consistency between panel_layout and panel_index.
; -- Allow user to set middle of colorbar to zero? Some data
;    ranges cause the middle to be a very small +/- number,
;    which causes plusminus_labels to add a sign even though
;    the tick name after formatting is '0.0'. There is a
;    work-around in place, so this isn't urgent.
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
                     yrange=yrange, $
                     colorbar_type=colorbar_type, $
                     colorbar_title=colorbar_title

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

     ;;==Defaults and guards
     if n_elements(panel_index) eq 0 then panel_index = 0
     np = n_elements(panel_index)
     if n_elements(panel_layout) eq 0 then panel_layout = [1,np]
     if n_elements(rgb_table) eq 0 then rgb_table = 0
     if n_elements(min_value) eq 0 then min_value = !NULL
     if n_elements(max_value) eq 0 then max_value = !NULL
     if n_elements(xtitle) eq 0 then xtitle = ''
     if n_elements(ytitle) eq 0 then ytitle = ''
     if n_elements(xshow) eq 0 then xshow = 0B
     if n_elements(yshow) eq 0 then yshow = 0B
     if n_elements(colorbar_type) eq 0 then colorbar_type = 'global'
     if n_elements(colorbar_title) eq 0 then colorbar_title = ''

     ;;==Calculate positions
     position = multi_position(panel_layout, $
                               edges=[0.12,0.10,0.80,0.80], $
                               buffers=[0.00,0.10])

     ;;==Set up x-axis ticks
     if keyword_set(xrange) then begin
        xtickvalues = [xrange[0],0.5*xrange[0],0,0.5*xrange[1],xrange[1]]
        xmajor = n_elements(xtickvalues)
        xminor = 1
        xtickname = plusminus_labels(xtickvalues/!pi,format='i')
     endif else begin
        xmajor = 5
        xminor = 1
        xsize = n_elements(xdata)
        xtickvalues = xdata[0] + $
                      (1+xdata[xsize-1]-xdata[1])*indgen(xmajor)/(xmajor-1)
        xtickname = strcompress(fix(xtickvalues),/remove_all)
        xrange = [xtickvalues[0],xtickvalues[xmajor-1]]
     endelse

     ;;==Set up y-axis ticks
     if keyword_set(yrange) then begin
        ytickvalues = [yrange[0],0.5*yrange[0],0,0.5*yrange[1],yrange[1]]
        ymajor = n_elements(ytickvalues)
        yminor = 1
        ytickname = plusminus_labels(ytickvalues/!pi,format='i')
     endif else begin
        ymajor = 5
        yminor = 1
        ysize = n_elements(ydata)
        ytickvalues = ydata[0] + $
                      (1+ydata[ysize-1]-ydata[1])*indgen(ymajor)/(ymajor-1)
        ytickname = strcompress(fix(ytickvalues),/remove_all)
        yrange = [ytickvalues[0],ytickvalues[ymajor-1]]
     endelse

     ;;==Calculate aspect ratios for panels and ticks
     aspect_ratio = 1.0
     xy_ratio = (yrange[1]-yrange[0])/(xrange[1]-xrange[0])

     ;;==Create image panel(s)
     img = objarr(np)
     for ip=0,np-1 do begin
        timestep = (panel_index[ip] le tsize-1) ? panel_index[ip] : tsize-1
        img[ip] = image(imgdata[*,*,timestep],xdata,ydata, $
                        position = position[*,ip], $
                        min_value = min_value, $
                        max_value = max_value, $
                        rgb_table = rgb_table, $
                        axis_style = 1, $
                        aspect_ratio = aspect_ratio, $
                        xstyle = 1, $
                        ystyle = 1, $
                        xtitle = xtitle, $
                        ytitle = ytitle, $
                        xmajor = xmajor, $
                        xminor = xminor, $
                        ymajor = ymajor, $
                        yminor = yminor, $
                        xtickname = xtickname, $
                        ytickname = ytickname, $
                        xtickvalues = xtickvalues, $
                        ytickvalues = ytickvalues, $
                        xrange = xrange, $
                        yrange = yrange, $
                        xticklen = 0.02, $
                        yticklen = 0.02*xy_ratio, $
                        xsubticklen = 0.5, $
                        ysubticklen = 0.5, $
                        xtickdir = 1, $
                        ytickdir = 1, $
                        xtickfont_size = 10.0, $
                        ytickfont_size = 10.0, $
                        font_size = 11.0, $
                        font_name = "Times", $
                        current = (ip gt 0), $
                        /buffer)

     endfor

     return, img
  endelse

end
