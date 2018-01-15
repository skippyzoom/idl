;+
; Images of electric field
;-
pro efield_images, pdata,xdata,ydata,xrng,yrng,dx,dy,Ex0,Ey0,nt,info,image_string=image_string

  ;;==Defaults and guards
  if n_elements(image_string) eq 0 then image_string = ''
  pdata_in = pdata
  xdata_in = xdata
  ydata_in = ydata

  ;;==Smooth 2-D plane
  ;; pdata = smooth(pdata,[0.5/dx,0.5/dy,1],/edge_wrap)

  ;;==Calculate E-field components
  Ex = fltarr(size(pdata,/dim))
  Ey = fltarr(size(pdata,/dim))
  Er = fltarr(size(pdata,/dim))
  Et = fltarr(size(pdata,/dim))
  for it=0,nt-1 do begin
     gradf = gradient(pdata[*,*,it],dx=dx*info.params.nout_avg,dy=dy*info.params.nout_avg)
     ;; Ex[*,*,it] = -1.0*gradf.x + info.params.Ex0_external
     ;; Ey[*,*,it] = -1.0*gradf.y + info.params.Ey0_external
     Ex[*,*,it] = -1.0*gradf.x + Ex0
     Ey[*,*,it] = -1.0*gradf.y + Ey0
     Er[*,*,it] = sqrt(Ex[*,*,it]^2 + Ey[*,*,it]^2)
     Et[*,*,it] = atan(Ey[*,*,it],Ex[*,*,it])
  endfor

  ;;==Calculate vertical average of horizontal field
  gdata = 1e3*mean(Ex[*,*,[0,nt/2,nt-1]],dim=2)

  ;;==Create plot
  plt = plot(xdata,gdata[*,0],'k-', $
             axis_style = 1, $
             xstyle = 1, $
             xtitle = "Distance [m]", $
             ytitle = "|E| [mV/m]", $
             /buffer)
  opl = plot(xdata,gdata[*,1],'b-', $
             /overplot)
  opl = plot(xdata,gdata[*,2],'r-', $
             /overplot)
  ;;==Save plot
  image_save, plt,filename=info.filepath+path_sep()+ $
              'ex_mean_tf'+image_string+'.pdf'

  ;;==Extract axis subsets
  xdata = xdata[xrng[0]:xrng[1]]
  ydata = ydata[yrng[0]:yrng[1]]
  
  ;;==Extract |E| subimage
  gdata = Er[xrng[0]:xrng[1],yrng[0]:yrng[1],*]

  ;;==Set up graphics parameters
  rgb_table = 3
  min_value = 0
  ;; max_value = max(gdata)
  ;; max_value = min([max(gdata),3*max(abs([Ex0,Ey0]))])
  max_value = max(gdata[*,*,1:*])

  ;;==Create image
  img = multi_image(gdata,xdata,ydata, $
                    position = info.position, $
                    axis_style = info.axis_style, $
                    rgb_table = rgb_table, $
                    title = info.title, $
                    min_value = min_value, $
                    max_value = max_value)

  ;;==Edit axes
  nc = info.layout[0]
  nr = info.layout[1]
  for it=0,n_elements(info.timestep)-1 do begin
     ax = img[it].axes
     ax[1].hide = (it mod nc ne 0)
  endfor

  ;;==Add colorbar(s)
  img = multi_colorbar(img,'global', $
                       width = 0.0225, $
                       height = 0.40, $
                       buffer = 0.03, $
                       orientation = 1, $
                       textpos = 1, $
                       tickdir = 1, $
                       ticklen = 0.2, $
                       major = 7, $
                       font_name = info.font_name, $
                       font_size = 8.0)

  ;;==Add path label
  txt = text(0.00,0.05,info.path, $
             alignment = 0.0, $
             target = img, $
             font_name = info.font_name, $
             font_size = 5.0)

  ;;==Save image
  image_save, img[0],filename=info.filepath+path_sep()+ $
              'emag'+image_string+'.pdf'

  ;;==Restore original data
  pdata = pdata_in
  xdata = xdata_in
  ydata = ydata_in

end
