;+
; Images of electrostatic potential
;-
pro potential_images, pdata,xdata,ydata,xrng,yrng,info,image_string=image_string

  ;;==Defaults and guards
  if n_elements(image_string) eq 0 then image_string = ''

  ;;==Extract axis subsets
  xdata = xdata[xrng[0]:xrng[1]]
  ydata = ydata[yrng[0]:yrng[1]]

  ;;==Extract subimage
  gdata = pdata[xrng[0]:xrng[1],yrng[0]:yrng[1],*]

  ;;==Set up graphics parameters
  ct = get_custom_ct(1)
  rgb_table = [[ct.r],[ct.g],[ct.b]]
  ;; min_value = -max(abs(gdata))
  ;; max_value = +max(abs(gdata))
  min_value = -max(abs(gdata[*,*,1:*]))
  max_value = +max(abs(gdata[*,*,1:*]))

  ;;==Create image
  img = multi_image(gdata,xdata,ydata, $
                    position = info.position, $
                    axis_style = info.axis_style, $
                    title = info.title, $
                    rgb_table = rgb_table, $
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
              'phi'+image_string+'.pdf'

end
