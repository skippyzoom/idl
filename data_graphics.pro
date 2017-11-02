;+
; Routine for producing graphics of EPPIC data
; from a project dictionary or data array.
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
; -- Check for consistency between plotlayout and plotindex.
; -- Allow user to set middle of colorbar to zero? Some data
;    ranges cause the middle to be a very small +/- number,
;    which causes plusminus_labels to add a sign even though
;    the tick name after formatting is '0.0'. There is a
;    work-around in place, so this isn't urgent.
;-
function data_graphics, imgdata,xdata,ydata, $
                        plotindex=plotindex, $
                        plotlayout=plotlayout, $
                        rgb_table=rgb_table, $
                        colorbar_type=colorbar_type, $
                        colorbar_title=colorbar_title

  if n_elements(imgdata) eq 0 then begin
     print, "DATA_GRAPHICS: Please supply image array. No graphics produced."
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
     if n_elements(plotindex) eq 0 then plotindex = 0
     np = n_elements(plotindex)
     if n_elements(plotlayout) eq 0 then plotlayout = [1,np]
     if n_elements(rgb_table) eq 0 then rgb_table = 0
     if n_elements(colorbar_type) eq 0 then colorbar_type = 'global'
     if n_elements(colorbar_title) eq 0 then colorbar_title = ''

     ;;==Set up graphics parameters
     position = multi_position(plotlayout, $
                               edges=[0.12,0.10,0.80,0.80], $
                               buffers=[0.00,0.10])
     max_abs = max(abs(imgdata))
     min_value = -max_abs
     max_value = max_abs

     xmajor = 5
     xminor = 1
     xsize = n_elements(xdata)
     xtickvalues = xdata[0] + $
                   (1+xdata[xsize-1]-xdata[1])*indgen(xmajor)/(xmajor-1)
     xtickname = strcompress(fix(xtickvalues),/remove_all)
     xrange = [xtickvalues[0],xtickvalues[xmajor-1]]
     ymajor = 5
     yminor = 1
     ysize = n_elements(ydata)
     ytickvalues = ydata[0] + $
                   (1+ydata[ysize-1]-ydata[1])*indgen(ymajor)/(ymajor-1)
     ytickname = strcompress(fix(ytickvalues),/remove_all)
     yrange = [ytickvalues[0],ytickvalues[ymajor-1]]

     aspect_ratio = 1.0

     ;;==Create image panel(s)
     for ip=0,np-1 do begin
        img = image(imgdata[*,*,plotindex[ip]],xdata,ydata, $
                    position = position[*,ip], $
                    min_value = min_value, $
                    max_value = max_value, $
                    rgb_table = rgb_table, $
                    axis_style = 1, $
                    aspect_ratio = aspect_ratio, $
                    xstyle = 1, $
                    ystyle = 1, $
                    xtitle = "Zonal [m]", $
                    ytitle = "Vertical [m]", $
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
                    xtickfont_size = 14.0, $
                    ytickfont_size = 14.0, $
                    font_size = 16.0, $
                    font_name = "Times", $
                    current = (ip gt 0), $
                    /buffer)

        if strcmp(colorbar_type,'panel',5) then begin
           print, "DATA_GRAPHICS: Panel-specific colorbar not implemented"
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
        tickvalues = min_value + $
                     (max_value-min_value)*findgen(major)/(major-1)
        ;;-->This is kind of a hack
        if (major mod 2) ne 0 && (min_value+max_value eq 0) then $
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
                       font_size = 10.0)
     endif

     return, img
  endelse

end
