;+
; Script for reading den0 from EPPIC simulations
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Set default values
@import_plane_defaults

;;==Extract a plane of data
import_data_plane, 'den0', $
                   timestep = long(time.index), $
                   axes = axes, $
                   ranges = ranges, $
                   zero_point = zero_point, $
                   rotate = rotate, $
                   info_path = info_path, $
                   data_path = data_path, $
                   data_type = 4, $
                   data_isft = 0B, $
                   f_out = den0, $
                   x_out = xdata, $
                   y_out = ydata, $
                   nx_out = nx, $
                   ny_out = ny, $
                   dx_out = dx, $
                   dy_out = dy
