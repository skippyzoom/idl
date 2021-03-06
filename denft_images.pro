;+
; Images of EPPIC Fourier-transformed density
;-
pro denft_images, pdata,xdata,ydata,xrng,yrng,dist_name,info,image_string=image_string

  ;;==Defaults and guards
  if n_elements(image_string) eq 0 then image_string = ''

  ;;==Extract axis subsets
  xdata = xdata[xrng[0]:xrng[1]]
  ydata = ydata[yrng[0]:yrng[1]]

  ;;==Extract subimage
  gdata = pdata[xrng[0]:xrng[1],yrng[0]:yrng[1],*]
  gdata = real_part(gdata)
  gdata = 10*alog10((gdata/max(gdata))^2)
  imgsize = size(gdata,/dim)
  gdata = shift(gdata,imgsize[0]/2,imgsize[1]/2,0)

  ;;==Set up graphics parameters
  rgb_table = 39
  min_value = min(gdata,/nan)
  max_value = max(gdata,/nan)

  ;;==Create image
  img = multi_image(gdata,xdata,ydata, $
                    xrange = [-2*!pi,2*!pi], $
                    yrange = [0,2*!pi], $
                    title = info.title, $
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
              dist_name+image_string+'.pdf'


end
