;+
; Images of electric field
;-
pro efield_images, imgplane,xdata,ydata,xrng,yrng,dx,dy,Ex0,Ey0,nt,info,image_string=image_string

  ;;==Defaults and guards
  if n_elements(image_string) eq 0 then image_string = ''

  ;;==Smooth 2-D plane
  ;; imgplane = smooth(imgplane,[0.5/dx,0.5/dy,1],/edge_wrap)

  ;;==Calculate E-field components
  Ex = fltarr(size(imgplane,/dim))
  Ey = fltarr(size(imgplane,/dim))
  Er = fltarr(size(imgplane,/dim))
  Et = fltarr(size(imgplane,/dim))
  for it=0,nt-1 do begin
     gradf = gradient(imgplane[*,*,it],dx=dx*info.params.nout_avg,dy=dy*info.params.nout_avg)
     Ex[*,*,it] = -1.0*gradf.x + info.params.Ex0_external
     Ey[*,*,it] = -1.0*gradf.y + info.params.Ey0_external
     Er[*,*,it] = sqrt(Ex[*,*,it]^2 + Ey[*,*,it]^2)
     Et[*,*,it] = atan(Ey[*,*,it],Ex[*,*,it])
  endfor

  ;;==Calculate vertical average of horizontal field
  gdata = mean(Ex[*,*,nt-1],dim=2)

  ;;==Create plot
  plt = plot(xdata,gdata,'k-', $
             axis_style = 1, $
             /buffer)
  
  ;;==Save plot
  image_save, plt,filename=info.filepath+path_sep()+ $
              'ex_mean_tf'+image_string+'.pdf'
  
  ;;==Extract |E| subimage
  gdata = Er[xrng[0]:xrng[1],yrng[0]:yrng[1],*]

  ;;==Set up graphics parameters
  rgb_table = 3
  min_value = 0
  max_value = max(gdata)

  ;;==Create image
  img = multi_image(gdata,xdata,ydata, $
                    position = info.position, $
                    axis_style = info.axis_style, $
                    rgb_table = rgb_table, $
                    min_value = min_value, $
                    max_value = max_value)

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

end
