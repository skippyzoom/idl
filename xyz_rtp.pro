;+
; Interpolate data on a Cartesian grid to data on a polar grid.
;
; NOTES
; -- This function is based on kmag_interpolate.pro but 
;    nx, ny, and nz here correspond to nx/2... in that
;    function.
;-
function xyz_rtp, xyz, $
                  dx=dx,dy=dy,dz=dz, $
                  ;; n_theta=n_theta,n_phi=n_phi, $
                  theta_range=theta_range, $
                  phi_range=phi_range, $
                  shape=shape, $
                  missing=missing

  ;;==Defaults and guards
  ;; if n_elements(n_theta) eq 0 then n_theta = 360
  ;; n_theta = 360
  ;; print, "[XYZ_RTP] Currently only capable of interpolating over full 360 degrees."
  if n_elements(theta_range) eq 0 then theta_range = [0,360]
  n_theta = theta_range[1]-theta_range[0]
  ;; if n_elements(n_phi) eq 0 then n_phi = 1
  if n_elements(phi_range) eq 0 then phi_range = [0,180]
  n_phi = phi_range[1]-phi_range[0]
  if n_elements(shape) eq 0 then shape = 'cone'
  if n_elements(missing) eq 0 then missing = 0.0
  
  ;;==Initialize the output dictionary
  rtp = dictionary()

  ;;==Get dimensions of input
  xyz_size = size(xyz)
  n_dims = xyz_size[0]
  rtp['n_dims'] = n_dims

  ;;==Set up interpolation parameters
  case n_dims of
     2: begin
        nx = xyz_size[1]/2
        ny = xyz_size[2]/2
        nr = min([nx,ny])
        if n_elements(dx) eq 0 then dx = 1.0/nx
        if n_elements(dy) eq 0 then dy = 1.0/ny
        x_min = !pi/dx/nx
        y_min = !pi/dy/ny
        r_min = max([x_min,y_min])
     end
     3: begin
        nx = xyz_size[1]/2
        ny = xyz_size[2]/2
        nz = xyz_size[3]/2
        nr = min([nx,ny,nz])
        if n_elements(dx) eq 0 then dx = 1.0/nx
        if n_elements(dy) eq 0 then dy = 1.0/ny
        if n_elements(dz) eq 0 then dz = 1.0/nz
        x_min = !pi/dx/nx
        y_min = !pi/dy/ny
        z_min = !pi/dz/nz
        r_min = max([x_min,y_min,z_min])
     end
  endcase
  rtp['r_vals'] = r_min*(1.0+dindgen(nr))

  ;;==Perform the interpolation
  case n_dims of 
     2: begin
        rtp['t_vals'] = theta_range[0]+indgen(n_theta)
        data = fltarr(nr,n_theta)
        for ir=0,nr-1 do begin
           t_size = 8*fix(rtp.r_vals[ir]/min([x_min,y_min]))
           ;; t_interp = 2*!pi*dindgen(t_size)/t_size
           t_interp = theta_range[0]+(theta_range[1]-theta_range[0])*dindgen(t_size)/t_size
           t_interp *= !dtor
           x_interp = cos(t_interp)*rtp.r_vals[ir]/x_min + nx
           y_interp = sin(t_interp)*rtp.r_vals[ir]/y_min + ny
           data_tmp = interpolate(xyz, $
                                  x_interp,y_interp, $
                                  missing = missing)
           data[ir,*] = congrid(data_tmp,n_theta,/interp)
        endfor
        rtp['data'] = data
     end
     3: begin
        print, "XYZ_RTP: 3D not set up yet."
     end
  endcase

  return, rtp
end
