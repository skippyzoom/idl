;+
; Script for reading a named data quantity from EPPIC simulations
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Set default values
@import_plane_defaults

;;==Extract a plane of data
if n_elements(name) ne 0 then $
   import_data_plane, name, $
                      timestep = long(time.index), $
                      axes = axes, $
                      ranges = ranges, $
                      rotate = rotate, $
                      info_path = info_path, $
                      data_path = data_path, $
                      data_type = data_type, $
                      f_out = fdata, $
                      x_out = xdata, $
                      y_out = ydata, $
                      nx_out = nx, $
                      ny_out = ny, $
                      dx_out = dx, $
                      dy_out = dy
