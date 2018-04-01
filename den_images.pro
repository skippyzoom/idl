;;==Extract a plane of density data
if n_elements(axes) eq 0 then axes = 'xy'
   plane = eppic_data_plane('den1', $
                            timestep = fix(time.index), $
                            axes = axes, $
                            data_type = 4, $
                            data_isft = 0B, $
                            ranges = ranges, $
                            rotate = rotate, $
                            info_path = path, $
                            data_path = path+path_sep()+'parallel')

;;==Extract arrays
den = plane.remove('f')
xdata = plane.remove('x')
ydata = plane.remove('y')

;;==Get dimensions of data plane
fsize = size(den)
nx = fsize[1]
ny = fsize[2]
nt = fsize[3]

;;==Make frame(s)
data_graphics, den,xdata,ydata, $
               'den1', $
               time = time, $
               frame_path = path+path_sep()+'frames', $
               frame_name = 'den1', $
               frame_type = '.pdf', $
               context = 'spatial'
