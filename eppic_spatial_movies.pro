;+
; Movies of spatial data from and EPPIC run
;-
pro eppic_spatial_movies, pdata,xdata,ydata, $
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

     ;;==Create string array of times
     dsize = size(gdata)
     nt = dsize[dsize[0]]
     string_time = string(info.params.dt*info.params.nout* $
                          1e3* $
                          lindgen(nt), format='(f8.2)')
     string_time = "t = "+strcompress(string_time,/remove_all)+" ms"

     ;;==Create movie
     filename = info.filepath+path_sep()+ $
                data_name+image_string+'.mp4'
     data_movie, gdata,xdata,ydata, $
                 filename = filename, $
                 title = string_time, $
                 rgb_table = rgb_table, $
                 min_value = min_value, $
                 max_value = max_value, $
                 expand = 3, $
                 rescale = 0.8

     ;;==Restore original data
     pdata = pdata_in
     xdata = xdata_in
     ydata = ydata_in

  endif $
  else print, "[EPPIC_SPATIAL_MOVIES] pdata must have dimensions (x,y,t)."

end
