pro import_plane_params, path=path, $
                         lun=lun, $
                         axes=axes, $
                         rotate=rotate, $
                         data_isft=data_isft, $
                         x_out=x_out, $
                         y_out=y_out, $
                         nx_out=nx_out, $
                         ny_out=ny_out, $
                         dx_out=dx_out, $
                         dy_out=dy_out, $
                         Ex0_out=Ex0_out, $
                         Ey0_out=Ey0_out

  ;;==Defaults and guards
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(path) eq 0 then path = './'
  if n_elements(axes) eq 0 then axes = 'xy'
  if n_elements(rotate) eq 0 then rotate = 0

  ;;==Read simulation parameters
  params = set_eppic_params(path=path)

  ;;==Set differentials and E0 components
  case 1B of
     strcmp(axes,'xy') || strcmp(axes,'yx'): begin
        dx_out = params.dx
        dy_out = params.dy
        Ex0_out = params.Ex0_external
        Ey0_out = params.Ey0_external
     end
     strcmp(axes,'xz') || strcmp(axes,'zx'): begin
        dx_out = params.dx
        dy_out = params.dz
        Ex0_out = params.Ex0_external
        Ey0_out = params.Ez0_external
     end
     strcmp(axes,'yz') || strcmp(axes,'zy'): begin
        dx_out = params.dy
        dy_out = params.dz
        Ex0_out = params.Ey0_external
        Ey0_out = params.Ez0_external
     end
  endcase

  ;;==Rescale dx and dy if not FT data
  if ~keyword_set(data_isft) then begin
     dx_out *= params.nout_avg
     dy_out *= params.nout_avg
  endif

  ;;==Set nx and ny
  nx_out = fsize[1]
  ny_out = fsize[2]

  ;;==Build x- and y-axis vectors
  x_out = dx_out*(ranges[0] + indgen(nx_out))
  y_out = dy_out*(ranges[2] + indgen(ny_out))  

  ;;==Rotate, if necessary
  if rotate gt 0 then begin
     if rotate mod 2 then begin
        tmp = y_out
        y_out = x_out
        x_out = tmp
        tmp = ny_out
        ny_out = nx_out
        nx_out = tmp
        tmp = dy_out
        dy_out = dx_out
        dx_out = tmp
     endif
     E0 = [Ex0_out,Ey0_out]
     rot_ang = rotate*90*!dtor
     rot_mat = [[+cos(rot_ang),+sin(rot_ang)], $
                [-sin(rot_ang),+cos(rot_ang)]]
     tmp = rot_mat # E0
     Ex0_out = tmp[0]
     Ey0_out = tmp[1]
  endif

end
