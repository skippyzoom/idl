;+
; Movies of density
;-
pro density_movies, pdata,xdata,ydata,xrng,yrng,dist_name,info,image_string=image_string

  ;;==Defaults and guards
  if n_elements(image_string) eq 0 then image_string = ''

  ;;==Extract axis subsets
  xdata = xdata[xrng[0]:xrng[1]]
  ydata = ydata[yrng[0]:yrng[1]]

  ;;==Extract subimage
  gdata = pdata[xrng[0]:xrng[1],yrng[0]:yrng[1],*]

  ;;==Set up graphics parameters
  rgb_table = 5
  min_value = -max(abs(gdata))
  max_value = +max(abs(gdata))

  ;;==Create string array of times
  dsize = size(gdata)
  nt = dsize[dsize[0]]
  string_time = string(info.params.dt*info.params.nout* $
                       1e3* $
                       lindgen(nt), format='(f8.2)')
  string_time = "t = "+strcompress(string_time,/remove_all)+" ms"

  ;;==Create movie
  filename = info.filepath+path_sep()+ $
             dist_name+image_string+'.mp4'
  data_movie, gdata,xdata,ydata, $
              filename = filename, $
              title = string_time, $
              rgb_table = rgb_table, $
              min_value = min_value, $
              max_value = max_value, $
              expand = 3, $
              rescale = 0.8

end
