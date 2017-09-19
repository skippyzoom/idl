;+
; Routine for producing graphics of EPPIC potential
; from a project dictionary or data array.
;
; NOTES
; -- This function should not require a project dictionary.
;
; TO DO
; -- Set up panel-specific colorbars. May require 
;    making img an array of object references.
; -- Allow for 3D data
; -- Allow target to be a struct containing image, x, & y.
;-
function potential_graphics, target=target, $
                             imgdata=imgdata,xdata=xdata,ydata=ydata, $
                             plotindex=plotindex,plotlayout=plotlayout, $
                             colorbar_type=colorbar_type

  case 1 of
     keyword_set(target): begin
        print, "POTENTIAL_GRAPHICS: Using project dictionary for graphics"
        if target.data.haskey('phi') then begin
           imgdata = target.data['phi']
           xdata = target.xvec
           ydata = target.yvec
        endif else begin
           print, "POTENTIAL_GRAPHICS: Did not find phi. Returning."
           return, !NULL
        endelse        
     end
     keyword_set(imgdata): begin
        print, "POTENTIAL_GRAPHICS: Using imgdata array for graphics"
        imgsize = size(imgdata)
        xsize = imgsize[1]
        ysize = imgsize[2]
        if n_elements(xdata) eq 0 then xdata = indgen(xsize)
        if n_elements(ydata) eq 0 then ydata = indgen(ysize)
     end
     else: $
        message, "Please supply either imgdata array "+ $
                 "or project dictionary"
  endcase

  if n_elements(plotindex) eq 0 then plotindex = 0
  np = n_elements(plotindex)
  if n_elements(plotlayout) eq 0 then plotlayout = [1,np]
  position = multi_position(plotlayout, $
                            edges=[0.12,0.10,0.80,0.80], $
                            buffers=[0.00,0.10])
  max_abs = max(abs(imgdata))
  min_value = -max_abs
  max_value = max_abs

  ct = get_custom_ct(1) & rgb_table = [[ct.r],[ct.g],[ct.b]]

  xmajor = 5
  xminor = 1
  xsize = n_elements(xdata)
  xtickvalues = (xdata[1]+xdata[xsize-1])*indgen(xmajor)/(xmajor-1)
  xtickname = strcompress(fix(xtickvalues),/remove_all)
  xrange = [xtickvalues[0],xtickvalues[xmajor-1]]
  ymajor = 5
  yminor = 1
  ysize = n_elements(ydata)
  ytickvalues = (ydata[1]+ydata[ysize-1])*indgen(ymajor)/(ymajor-1)
  ytickname = strcompress(fix(ytickvalues),/remove_all)
  yrange = [ytickvalues[0],ytickvalues[ymajor-1]]

  for ip=0,np-1 do begin
     img = image(imgdata[*,*,plotindex[ip]],xdata,ydata, $
                 position = position[*,ip], $
                 min_value = min_value, $
                 max_value = max_value, $
                 rgb_table = rgb_table, $
                 axis_style = 1, $
                 aspect_ratio = 1.0, $
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
                 yticklen = 0.02*target.aspect_ratio, $
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
        print, "POTENTIAL_GRAPHICS: Panel-specific colorbar not implemented"
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
     tickname = plusminus_labels(tickvalues,format='f8.2')
     title = "$\phi$"
     if keyword_set(target) && target.haskey('units') then $
        title += " "+target.units['phi']
     clr = colorbar(title = title, $
                    position = [x0,y0,x1,y1], $
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
end
