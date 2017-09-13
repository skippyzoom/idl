;+
; Routine for producing graphics of EPPIC density
; from a project dictionary or struct
;
; TO DO
; -- Set up for multiple species
; -- Incorporate scale and data units for colorbar
; -- Set up panel-specific colorbars. That will require 
;    making img an array of object references.
; -- Allow for 3D data
;-
function density_graphics, prj=prj, $
                           imgData=imgData,xData=xData,yData=yData, $
                           plotindex=plotindex,plotlayout=plotlayout, $
                           global_colorbar=global_colorbar

  case 1 of
     keyword_set(prj): begin
        print, "DENSITY_GRAPHICS: Using prj for graphics"
        imgData = prj.data.den1
        xData = prj.xvec
        yData = prj.yvec
        
     end
     keyword_set(imgData): begin
        print, "DENSITY_GRAPHICS: Using imgData for graphics"
        imgSize = size(imgData)
        xSize = imgSize[1]
        ySize = imgSize[2]
        if n_elements(xData) eq 0 then xData = indgen(xSize)
        if n_elements(yData) eq 0 then yData = indgen(ySize)
     end
     else: $
        message, "Please supply either imgData (array) "+ $
                 "or prj (struct or dictionary)"
  endcase

  if n_elements(plotindex) eq 0 then plotindex = 0
  np = n_elements(plotindex)
  if n_elements(plotlayout) eq 0 then plotlayout = [1,np]
  position = multi_position(plotlayout, $
                            edges=[0.12,0.10,0.80,0.80], $
                            buffers=[0.00,0.10])
  max_abs = max(abs(imgData))
  min_value = -max_abs
  max_value = max_abs

  xmajor = 5
  xminor = 1
  xSize = n_elements(xData)
  xtickvalues = (xData[1]+xData[xSize-1])*indgen(xmajor)/(xmajor-1)
  xtickname = strcompress(fix(xtickvalues),/remove_all)
  xrange = [xtickvalues[0],xtickvalues[xmajor-1]]
  ymajor = 5
  yminor = 1
  ySize = n_elements(yData)
  ytickvalues = (yData[1]+yData[ySize-1])*indgen(ymajor)/(ymajor-1)
  ytickname = strcompress(fix(ytickvalues),/remove_all)
  yrange = [ytickvalues[0],ytickvalues[ymajor-1]]

  for ip=0,np-1 do begin
     img = image(imgData[*,*,plotindex[ip]],xData,yData, $
                 position = position[*,ip], $
                 min_value = min_value, $
                 max_value = max_value, $
                 rgb_table = 5, $
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
                 yticklen = 0.02*prj.aspect_ratio, $
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
  endfor

  if keyword_set(global_colorbar) then begin
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
     clr = colorbar(title = "$\delta n/n_0$", $
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
