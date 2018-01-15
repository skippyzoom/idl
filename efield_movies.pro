;+
; Movies of electric field
;-
pro efield_movies, pdata,xdata,ydata,xrng,yrng,dx,dy,Ex0,Ey0,nt,info,image_string=image_string

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
     Ex[*,*,it] = -1.0*gradf.x + Ex0
     Ey[*,*,it] = -1.0*gradf.y + Ey0
     Er[*,*,it] = sqrt(Ex[*,*,it]^2 + Ey[*,*,it]^2)
     Et[*,*,it] = atan(Ey[*,*,it],Ex[*,*,it])
  endfor

  ;;==Extract axis subsets
  xdata = xdata[xrng[0]:xrng[1]]
  ydata = ydata[yrng[0]:yrng[1]]

  ;;==Extract |E| subimage
  gdata = Er[xrng[0]:xrng[1],yrng[0]:yrng[1],*]

  ;;==Set up graphics parameters
  rgb_table = 3
  min_value = 0
  max_value = max(gdata[*,*,1:*])

  ;;==Create string array of times
  dsize = size(gdata)
  nt = dsize[dsize[0]]
  string_time = string(info.params.dt*info.params.nout* $
                       1e3* $
                       lindgen(nt), format='(f8.2)')
  string_time = "t = "+strcompress(string_time,/remove_all)+" ms"

  ;;==Create movie
  filename = info.filepath+path_sep()+ $
             'emag'+image_string+'.mp4'
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

end
