;+
; Images of spatial data from and EPPIC run
;-
pro eppic_spatial_images, pdata,xdata,ydata, $
                          info, $
                          xrng=xrng, $
                          yrng=yrng, $
                          rgb_table=rgb_table, $
                          min_value=min_value, $
                          max_value=max_value, $
                          data_name=data_name, $
                          image_string=image_string

  ;;==Get data size
  data_size = size(pdata)
  n_dims = data_size[0]

  ;;==Check data size
  if n_dims eq 3 then begin
     nt = data_size[n_dims]
     nx = data_size[1]
     ny = data_size[2]

     ;;==Defaults and guards
     if n_elements(rgb_table) eq 0 then rgb_table = 0
     if n_elements(min_value) eq 0 then min_value = !NULL
     if n_elements(max_value) eq 0 then max_value = !NULL
     if n_elements(xrng) eq 0 then xrng = indgen(nx)
     if n_elements(yrng) eq 0 then yrng = indgen(ny)
     if n_elements(data_name) eq 0 then data_name = 'data'
     if n_elements(image_string) eq 0 then image_string = ''
     pdata_in = pdata
     xdata_in = xdata
     ydata_in = ydata

     ;;==Extract axis subsets
     xdata = xdata[xrng[0]:xrng[1]]
     ydata = ydata[yrng[0]:yrng[1]]

     ;;==Extract subimage
     gdata = pdata[xrng[0]:xrng[1],yrng[0]:yrng[1],*]

     ;;==Create image
     img = multi_image(gdata,xdata,ydata, $
                       position = info.position, $
                       title = info.title, $
                       axis_style = info.axis_style, $
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
                 data_name+image_string+'.pdf'

     ;;==Restore original data
     pdata = pdata_in
     xdata = xdata_in
     ydata = ydata_in

  endif $
  else print, "[EPPIC_SPATIAL_IMAGES] pdata must have dimensions (x,y,t)."

end
