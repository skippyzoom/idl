;+
; Script for calculating E = -Grad[phi] from EPPIC simulations
;
; The component arrays represent the logical x and y components in the
; given plane, as set by the AXES variable.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Set default values
@import_plane_defaults

;;==Extract a plane of data
if n_elements(phi) eq 0 then $
   import_data_plane, 'phi', $
                      timestep = long(time.index), $
                      axes = axes, $
                      ranges = ranges, $
                      rotate = rotate, $
                      info_path = info_path, $
                      data_path = data_path, $
                      data_type = data_type, $
                      f_out = phi, $
                      x_out = xdata, $
                      y_out = ydata, $
                      nx_out = nx, $
                      ny_out = ny, $
                      dx_out = dx, $
                      dy_out = dy

;;==Calculate electric field
efield = calc_grad_xyzt(phi,dx=dx,dy=dy,scale=-1.0)

;;==Extract component arrays
Ex = efield.x
Ey = efield.y

;;==Free memory
delvar, efield

;;==Calculate magnitude and angle
Er = sqrt(Ex*Ex + Ey*Ey)
Et = atan(Ey,Ex)
