;+
; Routine for producing graphics of RMS (in time) spatial spectra.
;
; NOTES
; -- This function should not require a project dictionary.
;
; TO DO
; -- Allow for 3D data
; -- Implement panel-specific colorbars
;-
function fft_rms_graphics, data, $
                           dx=dx,dy=dy, $
                           colorbar_type=colorbar_type

  if n_elements(dx) eq 0 then dx = 1.0
  if n_elements(dy) eq 0 then dy = 1.0
  imgsize = size(data)
  nx = imgsize[1]
  ny = imgsize[2]
  nt = imgsize[imgsize[0]]
  xdata = (2*!pi/(nx*dx))*(findgen(nx) - 0.5*nx)
  ydata = (2*!pi/(ny*dy))*(findgen(ny) - 0.5*ny)

  np = 4
  position = multi_position([2,2], $
                            edges=[0.12,0.10,0.80,0.80], $
                            buffers=[0.05,0.15])

  trange = [[0,nt/4-1], $
            [nt/4,nt/2-1], $
            [nt/2,3*nt/4-1], $
            [3*nt/4,nt-1]]
  min_value = -30
  max_value = 0

  aspect_ratio = 1.0

  xrange = [-4*!pi,4*!pi]
  xtickvalues = [xrange[0],0.5*xrange[0],0,0.5*xrange[1],xrange[1]]
  xmajor = n_elements(xtickvalues)
  xminor = 1
  xtickname = plusminus_labels(xtickvalues/!pi,format='i')
  xtitle = "$k_{zon}/\pi$ [m$^{-1}$]"

  yrange = [-4*!pi,4*!pi]
  ytickvalues = [yrange[0],0.5*yrange[0],0,0.5*yrange[1],yrange[1]]
  ymajor = n_elements(ytickvalues)
  yminor = 1
  ytickname = plusminus_labels(ytickvalues/!pi,format='i')
  ytitle = "$k_{ver}/\pi$ [m$^{-1}$]"

  for it=0,nt-1 do data[*,*,it] = abs(fft(data[*,*,it],/center,/overwrite))

  for ip=0,np-1 do begin
     imgdata = rms(data[*,*,trange[0,ip]:trange[1,ip]],dim=3)
     imgdata /= max(imgdata)
     imgdata = 10*alog10(imgdata^2)
     
     img = image(imgdata,xdata,ydata, $
                 position = position[*,ip], $
                 min_value = min_value, $
                 max_value = max_value, $
                 rgb_table = 39, $
                 axis_style = 1, $
                 aspect_ratio = 1.0, $
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
                 xtickfont_size = 12.0, $
                 ytickfont_size = 12.0, $
                 font_size = 14.0, $
                 font_name = "Times", $
                 current = (ip gt 0), $
                 /buffer)

     if strcmp(colorbar_type,'panel',5) then begin
        print, "FFT_RMS_GRAPHICS: Panel-specific colorbar not implemented"
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
     tickname = plusminus_labels(tickvalues,format='i')
     clr = colorbar(title = "Power [dB]", $
                    target = img, $
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
