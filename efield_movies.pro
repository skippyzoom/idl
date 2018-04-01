;;==Extract a plane of potential data
if n_elements(axes) eq 0 then axes = 'xy'
if n_elements(phi) eq 0 then $
   plane = eppic_data_plane('phi', $
                            timestep = fix(time.index), $
                            axes = axes, $
                            data_type = 4, $
                            data_isft = 0B, $
                            ranges = ranges, $
                            rotate = rotate, $
                            info_path = path, $
                            data_path = path+path_sep()+'parallel')

;;==Calculate E from phi
if n_elements(phi) eq 0 then $
   phi = plane.remove('f')
if n_elements(phi) eq 0 then $
   xdata = plane.remove('x')
if n_elements(phi) eq 0 then $
   ydata = plane.remove('y')

efield = calc_grad_xyzt(phi, $
                        dx = plane.dx, dy = plane.dy, $
                        scale = -1.0)
Ex = efield.x
Ey = efield.y
efield = !NULL

;;==Make movie of Ex
data_graphics, Ex,xdata,ydata, $
               'efield_'+strmid(axes,0,1), $
               time = time, $
               movie_path = path+path_sep()+'movies', $
               movie_name = 'efield_'+strmid(axes,0,1), $
               movie_type = '.mp4', $
               context = 'spatial'

;;==Make movie of Ey
data_graphics, Ey,xdata,ydata, $
               'efield_'+strmid(axes,1,1), $
               time = time, $
               movie_path = path+path_sep()+'movies', $
               movie_name = 'efield_'+strmid(axes,1,1), $
               movie_type = '.mp4', $
               context = 'spatial'

;;==Calculate magnitude
Er = sqrt(Ex*Ex + Ey*Ey)

;;==Make movie of Er
data_graphics, Er,xdata,ydata, $
               'efield_r'+axes, $
               time = time, $
               movie_path = path+path_sep()+'movies', $
               movie_name = 'efield_r'+axes, $
               movie_type = '.mp4', $
               context = 'spatial'

;;==Calculate angle
Et = atan(Ey,Ex)

;;==Make movie of Er
data_graphics, Et,xdata,ydata, $
               'efield_t'+axes, $
               time = time, $
               movie_path = path+path_sep()+'movies', $
               movie_name = 'efield_t'+axes, $
               movie_type = '.mp4', $
               context = 'spatial'
