;+
; Convenience script for reading EPPIC phi data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Set default values
@read_plane_defaults

;;==Extract a plane of data
plane = read_data_plane('phi', $
                        timestep = fix(time.index), $
                        axes = axes, $
                        data_type = 4, $
                        data_isft = 0B, $
                        ranges = ranges, $
                        rotate = rotate, $
                        info_path = path, $
                        data_path = path+path_sep()+'parallel')

;;==Extract the data array for convenience
phi = plane.remove('f')
xdata = plane.remove('x')
ydata = plane.remove('y')
dx = plane.remove('dx')
dy = plane.remove('dy')
plane = !NULL
