pro efield_images, phi,xdata,ydata,time,ranges,path,axes,rotate,dx,dy, $
                   data_out=data_out

  ;;==Extract a plane of potential data
  if n_elements(axes) eq 0 then axes = 'xy'
  if n_elements(phi) eq 0 then begin
     plane = eppic_data_plane('phi', $
                              timestep = fix(time.index), $
                              axes = axes, $
                              data_type = 4, $
                              data_isft = 0B, $
                              ranges = ranges, $
                              rotate = rotate, $
                              info_path = path, $
                              data_path = path+path_sep()+'parallel')
     phi = plane.remove('f')
     xdata = plane.remove('x')
     ydata = plane.remove('y')
  endif

  ;;==Get dimensions of data plane
  fsize = size(phi)
  nx = fsize[1]
  ny = fsize[2]
  nt = fsize[3]
  if n_elements(xdata) eq 0 then xdata = dx*indgen(nx)
  if n_elements(xdata) eq 0 then ydata = dy*indgen(ny)

  ;;==Make data available to calling routine
  data_out = plane

  ;;==Calculate E from phi
  efield = calc_grad_xyzt(phi,dx=dx,dy=dy,scale=-1.0)
  Ex = efield.x
  Ey = efield.y
  efield = !NULL

  ;;==Make frame(s) of Ex
  data_graphics, Ex,xdata,ydata, $
                 'efield_'+strmid(axes,0,1), $
                 time = time, $
                 frame_path = path+path_sep()+'frames', $
                 frame_name = 'efield_'+strmid(axes,0,1), $
                 frame_type = '.pdf', $
                 context = 'spatial'

  ;;==Make frame(s) of Ey
  data_graphics, Ey,xdata,ydata, $
                 'efield_'+strmid(axes,1,1), $
                 time = time, $
                 frame_path = path+path_sep()+'frames', $
                 frame_name = 'efield_'+strmid(axes,1,1), $
                 frame_type = '.pdf', $
                 context = 'spatial'

  ;;==Calculate magnitude
  Er = sqrt(Ex*Ex + Ey*Ey)

  ;;==Make frame(s) of Er
  data_graphics, Er,xdata,ydata, $
                 'efield_r'+axes, $
                 time = time, $
                 frame_path = path+path_sep()+'frames', $
                 frame_name = 'efield_r'+axes, $
                 frame_type = '.pdf', $
                 context = 'spatial'

  ;;==Calculate angle
  Et = atan(Ey,Ex)

  ;;==Make frame(s) of Er
  data_graphics, Et,xdata,ydata, $
                 'efield_t'+axes, $
                 time = time, $
                 frame_path = path+path_sep()+'frames', $
                 frame_name = 'efield_t'+axes, $
                 frame_type = '.pdf', $
                 context = 'spatial'

  ;;==Make plots of mean E-field components
  Ex_ymean = mean(Ex,dim=2)
  file_path = path+path_sep()+'test_frames'
  file_name = 'Ex_ymean'
  file_type = '.pdf'
  filename = expand_path(file_path)+path_sep()+ $
             file_name+file_type
  color = ['black', $
           ;; 'midnight blue', $
           'dark blue', $
           ;; 'medium blue', $
           'blue', $
           'dodger blue',$
           'deep sky blue']
  for it=0,nt-1 do $
     plt = plot(xdata,Ex_ymean[*,it], $
                xstyle = 1, $
                color = color[it], $
                /buffer, $
                overplot = (it gt 0))
  frame_save, plt,filename = filename

end
