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
; -- Give user more control over min/max value. 
;    Panel-specific colorbars will require panel-specific
;    min/max, so this may need to connect to colorbar_type.
; -- Check for consistency between plot_layout and plot_index.
; -- Allow user to set middle of colorbar to zero? Some data
;    ranges cause the middle to be a very small +/- number,
;    which causes plusminus_labels to add a sign even though
;    the tick name after formatting is '0.0'. There is a
;    work-around in place, so this isn't urgent.
;-
function data_image, imgdata,xdata,ydata, $
                     plot_index=plot_index, $
                     plot_layout=plot_layout, $
                     rgb_table=rgb_table, $
                     min_value=min_value, $
                     max_value=max_value, $
                     xtitle=xtitle, $
                     ytitle=ytitle, $
                     xrange=xrange, $
                     yrange=yrange, $
                     colorbar_type=colorbar_type, $
                     colorbar_title=colorbar_title

  if n_elements(imgdata) eq 0 then begin
     print, "DATA_IMAGE: Please supply image array. No graphics produced."
     return, !NULL
  endif $
  else begin
     
     ;;==Get data dimensions
     imgsize = size(imgdata)
     xsize = imgsize[1]
     ysize = imgsize[2]
     if n_elements(xdata) eq 0 then xdata = indgen(xsize)
     if n_elements(ydata) eq 0 then ydata = indgen(ysize)

     ;;==Defaults and guards
     if n_elements(plot_index) eq 0 then plot_index = 0
     np = n_elements(plot_index)
     if n_elements(plot_layout) eq 0 then plot_layout = [1,np]
     if n_elements(rgb_table) eq 0 then rgb_table = 0
     if n_elements(min_value) eq 0 then min_value = !NULL
     if n_elements(max_value) eq 0 then max_value = !NULL
     if n_elements(xtitle) eq 0 then xtitle = ''
     if n_elements(ytitle) eq 0 then ytitle = ''
     if n_elements(colorbar_type) eq 0 then colorbar_type = 'global'
     if n_elements(colorbar_title) eq 0 then colorbar_title = ''

     ;;==Set up graphics parameters
     position = multi_position(plot_layout, $
                               edges=[0.12,0.10,0.80,0.80], $
                               buffers=[0.00,0.10])

     ;; max_abs = max(abs(imgdata))
     ;; min_value = -max_abs
     ;; max_value = max_abs

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

     aspect_ratio = 1.0

     ;;==Create image panel(s)
     for ip=0,np-1 do begin
        img = image(imgdata[*,*,plot_index[ip]],xdata,ydata, $
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
                    yticklen = 0.02*aspect_ratio, $
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

        if strcmp(colorbar_type,'panel',5) then begin
           print, "DATA_IMAGE: Panel-specific colorbar not implemented"
        endif
     endfor

     if strcmp(colorbar_type,'global',6) then begin
        major = 7
        width = 0.0225
        height = 0.20
        buffer = 0.03
        x0 = max(position[2,*])+buffer
        x1 = x0+width
        y0 = 0.50*(1-height)
        y1 = 0.50*(1+height)
        ;; tickvalues = min_value + $
        ;;              (max_value-min_value)*findgen(major)/(major-1)
        tickvalues = img.min_value[0] + $
                     (img.max_value[0]-img.min_value[0])*findgen(major)/(major-1)
        ;;-->This is kind of a hack
        if (major mod 2) ne 0 && (img.min_value[0]+img.max_value[0] eq 0) then $
           tickvalues[major/2] = 0.0
        ;;<--
        tickname = plusminus_labels(tickvalues,format='f8.2')
        clr = colorbar(position = [x0,y0,x1,y1], $
                       title = colorbar_title, $
                       orientation = 1, $
                       tickvalues = tickvalues, $
                       tickname = tickname, $
                       textpos = 1, $
                       tickdir = 1, $
                       ticklen = 0.2, $
                       major = major, $
                       font_name = "Times", $
                       font_size = 8.0)
     endif

     return, img
  endelse

end
