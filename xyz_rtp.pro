;+
; Interpolate data on a Cartesian grid to data on a polar grid.
;-
function xyz_rtp, xyz, $
                  dx=dx,dy=dy,dz=dz,dr=dr, $
                  n_theta=n_theta,n_phi=n_phi, $
                  shape=shape, $
                  missing=missing

  if n_elements(n_theta) eq 0 then n_theta = 360
  if n_elements(n_phi) eq 0 then n_phi = 1
  if n_elements(shape) eq 0 then shape = 'cone'
  if n_elements(missing) eq 0 then missing = 0.0

  xyz_size = size(xyz)
  n_dims = xyz_size[0]
  case n_dims of
     3: begin
        nx = xyz_size[1]/2
        ny = xyz_size[2]/2
        nz = xyz_size[3]/2
        nr = min([nx,ny,nz])
        if n_elements(dx) eq 0 then dx = 1.0/nx
        if n_elements(dy) eq 0 then dy = 1.0/ny
        if n_elements(dz) eq 0 then dz = 1.0/nz
        x_min = 2*!pi/dx/nx
        y_min = 2*!pi/dy/ny
        z_min = 2*!pi/dz/nz
     end
     2: begin
        nx = xyz_size[1]/2
        ny = xyz_size[2]/2
        nr = min([nx,ny])
        if n_elements(dx) eq 0 then dx = 1.0/nx
        if n_elements(dy) eq 0 then dy = 1.0/ny
        x_min = 2*!pi/dx/nx
        y_min = 2*!pi/dy/ny
     end
  endcase
  r_vals = dr*(1.0+dindgen(nr))

  case n_dims of 
     2: begin
        rtp = fltarr(nr,n_theta)
        for ir=0,nr-1 do begin
           t_size = 8*fix(r_vals[ir]/dr)
           t_vals = 2*!pi*dindgen(t_size)/t_size
           x_interp = cos(t_vals)*r_vals[ir]/x_min + nx/2
           y_interp = cos(t_vals)*r_vals[ir]/y_min + ny/2
           r_interp = interpolate(xyz, $
                                  x_interp,y_interp, $
                                  missing = missing)
           rtp[ir,*] = congrid(r_interp,n_theta,/interp)
        endfor
     end
     3: begin
        rtp = fltarr(nr,n_theta,n_phi)
        print, "XYZ_RTP: 3D not set up yet."
     end
  endcase

  return, rtp
end
