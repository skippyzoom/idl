;;==Extract a plane of potential data
if n_elements(axes) eq 0 then axes = 'xy'
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

;;==Make frame(s)
data_graphics, phi,xdata,ydata, $
               'phi', $
               time = time, $
               frame_path = path+path_sep()+'frames', $
               frame_name = 'phi', $
               frame_type = '.pdf', $
               context = 'spatial'
