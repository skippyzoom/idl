;+
; Script for reading denft1 from EPPIC simulations
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Load default values
@import_plane_defaults

;;==Extract a plane of data
import_data_plane, 'denft1', $
                   timestep = long(time.index), $
                   axes = axes, $
                   ranges = ranges, $
                   zero_point = zero_point, $
                   rotate = rotate, $
                   info_path = info_path, $
                   data_path = data_path, $
                   data_type = 6, $
                   data_isft = 1B, $
                   f_out = denft1, $
                   x_out = xdata, $
                   y_out = ydata, $
                   nx_out = nx, $
                   ny_out = ny, $
                   dx_out = dx, $
                   dy_out = dy
