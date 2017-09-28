;+
; Routine for producing graphics of full k-w spectra. This
; function produces one panel for each spatial dimension 
; (e.g. kx v. w)
;
; NOTES
; -- This function should not require a project dictionary.
;
; TO DO
; -- Implement panel-specific colorbars.
; -- Check dimensions of data to determine whether to make
;    two or three panels.
; -- Add padding option for spatial coordinates
;    (e.g. nkx = next_power2(nx)).
;-
function kxyzw_images, data, $
                       dx=dx,dy=dy,dz=dz,dt=dt, $
                       scale=scale, $
                       colorbar_type=colorbar_type

  if n_elements(dx) eq 0 then dx = 1.0
  if n_elements(dy) eq 0 then dy = 1.0
  if n_elements(dz) eq 0 then dz = 1.0
  imgsize = size(data)
  n_dims = imgsize[0]-1
  nt = imgsize[n_dims+1]
  nw = next_power2(nt)
  nx = imgsize[1]
  ny = imgsize[2]
  if n_dims eq 3 then nz = imgsize[3]

  np = n_dims
  position = multi_position([np,1], $
                            edges=[0.12,0.10,0.80,0.80], $
                            buffers=[0.15,0.15])

  min_value = -60
  max_value = 0

  aspect_ratio = 1.0

  winsize = nw/2
  win = hanning(winsize,alpha=0.5)
  imgdata = fltarr(nx,ny,nw)*0.0
  imgdata[*,*,0:nt-1] = data
  for iw=0,winsize-1 do data[*,*,iw] *= win[iw]
  imgdata = abs(fft(imgdata,/center,/overwrite))
  imgdata = reverse(imgdata,3,/overwrite)

  ;;==Use index arrays to select planes within the image data
  x0 = [0,nx/2]
  x1 = [nx-1,nx/2]
  y0 = [ny/2,0]
  y1 = [ny/2,ny-1]
  w0 = [0,0]
  w1 = [nw-1,nw-1]
  pn = [nx,ny]
  pd = [dx,dy]

  xrange = [-2*!pi,2*!pi]
  xtickvalues = [xrange[0],0.5*xrange[0],0,0.5*xrange[1],xrange[1]]
  xmajor = n_elements(xtickvalues)
  xminor = 1
  xtickname = plusminus_labels(xtickvalues/!pi,format='f4.1')
  xtitle = ["$k_{zon}/\pi$ [m$^{-1}$]", $
            "$k_{ver}/\pi$ [m$^{-1}$]", $
            "$k_{par}/\pi$ [m$^{-1}$]"]

  yrange = [-1.0,1.0]
  ytickvalues = [yrange[0],0.5*yrange[0],0,0.5*yrange[1],yrange[1]]
  ymajor = n_elements(ytickvalues)
  yminor = 1
  ytickname = plusminus_labels(ytickvalues,format='f4.1')
  ytitle = "$f$ [kHz]"
  ydata = shift(freq_vec(nw,dt),-(nw/2+1))
  ydata /= 1e3

  aspect_ratio = 1.0
  if n_elements(xtickvalues) ge 2 && n_elements(xtickvalues) ge 2 then $
     aspect_ratio = float(xtickvalues[xmajor-1]-xtickvalues[0])/$
                    float(ytickvalues[ymajor-1]-ytickvalues[0])

  all_imgdata = imgdata
  for ip=0,np-1 do begin
     xdata = 2*!pi*shift(freq_vec(pn[ip],pd[ip]),-(pn[ip]/2+1))
     imgdata = reform(all_imgdata[x0[ip]:x1[ip],y0[ip]:y1[ip],w0[ip]:w1[ip]])
     imgdata /= max([max(imgdata[0:pn[ip]/2-1,*]), $
                     max(imgdata[pn[ip]/2+1:*,*])])
     imgdata = 10*alog10(imgdata^2)
     img = image(imgdata, $
                 xdata,ydata, $
                 position = position[*,ip], $
                 min_value = min_value, $
                 max_value = max_value, $
                 rgb_table = 39, $
                 axis_style = 1, $
                 aspect_ratio = aspect_ratio, $
                 xstyle = 1, $
                 ystyle = 1, $
                 xtitle = xtitle[ip], $
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
                 yticklen = 0.02/aspect_ratio, $
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
        ;; print, "FFT_KW_GRAPHICS: Panel-specific colorbar not implemented"
        major = 7
        clr = colorbar(title = "Power [dB]", $
                       target = img, $
                       orientation = 1, $
                       textpos = 1, $
                       tickdir = 1, $
                       ticklen = 0.2, $
                       major = major, $
                       font_name = "Times", $
                       font_size = 10.0)
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
