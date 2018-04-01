;;==Extract a plane of potential data
if n_elements(axes) eq 0 then axes = 'xy'
;; if n_elements(phi) eq 0 then $
   plane = eppic_data_plane('phi', $
                            timestep = fix(time.index), $
                            axes = axes, $
                            data_type = 4, $
                            data_isft = 0B, $
                            ranges = ranges, $
                            rotate = rotate, $
                            info_path = path, $
                            data_path = path+path_sep()+'parallel')

;;==Extract arrays
phi = plane.remove('f')
xdata = plane.remove('x')
ydata = plane.remove('y')

;;==Get dimensions of data plane
fsize = size(phi)
nx = fsize[1]
ny = fsize[2]
nt = fsize[3]

;;==Make movie
data_graphics, phi,xdata,ydata, $
               'phi', $
               time = time, $
               movie_path = path+path_sep()+'movies', $
               movie_name = 'phi', $
               movie_type = '.mp4', $
               context = 'spatial'
