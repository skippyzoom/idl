;+
; Import a logically (2+1)-D plane of data from an EPPIC run.
;-
pro import_data_plane, data_name, $
                       timestep=timestep, $
                       axes=axes, $
                       ranges=ranges, $
                       rotate=rotate, $
                       info_path=info_path, $
                       f_out=f_out, $
                       x_out=x_out, $
                       y_out=y_out, $
                       nx_out=nx_out, $
                       ny_out=ny_out, $
                       dx_out=dx_out, $
                       dy_out=dy_out, $
                       _EXTRA=ex

  ;;==Defaults and guards
  if n_elements(timestep) eq 0 then timestep = 0
  nts = n_elements(timestep)
  if n_elements(axes) eq 0 then axes = 'xy'
  ;; if n_elements(ranges) eq 0 then ranges = [0,1,0,1,0,1]
  ;; if n_elements(ranges) eq 4 then ranges = [ranges,0,1]
  ;; if n_elements(data_type) eq 0 then data_type = 4
  ;; if n_elements(data_isft) eq 0 then data_isft = 0B
  if n_elements(rotate) eq 0 then rotate = 0
  if n_elements(info_path) eq 0 then info_path = './'
  ;; if n_elements(data_path) eq 0 then data_path = './'
  if n_elements(lun) eq 0 then lun = -1

  ;;==Read simulation parameters
  params = set_eppic_params(path=info_path)

  ;;==Extract appropriate 2-D ranges
  case 1B of 
     strcmp(axes,'xy') || strcmp(axes,'yx'): begin
        x0 = ranges[0]
        xf = ranges[1]
        y0 = ranges[2]
        yf = ranges[3]
        z0 = 0
        zf = 1
     end
     strcmp(axes,'xz') || strcmp(axes,'zx'): begin
        x0 = ranges[0]
        xf = ranges[1]
        y0 = 0
        yf = 1
        z0 = ranges[2]
        zf = ranges[3]
     end
     strcmp(axes,'yz') || strcmp(axes,'zy'): begin
        x0 = 0
        xf = 1
        y0 = ranges[0]
        yf = ranges[1]
        z0 = ranges[2]
        zf = ranges[3]
     end
  endcase

  ;;==Read data at each time step
  if strcmp(data_name,'e',1,/fold_case) then $
     read_name = 'phi' $
  else $
     read_name = data_name
  f_out = read_ph5(data_name, $
                   timestep = timestep, $
                   ranges = [x0,xf,y0,yf,z0,zf], $
                   lun = lun, $
                   info_path = info_path, $
                   _EXTRA = ex)

  case 1B of
     strcmp(axes,'xy') || strcmp(axes,'yx'): begin
        dx_out = params.dx*params.nout_avg
        dy_out = params.dy*params.nout_avg
        nx_out = params.nx*params.nsubdomains
        ny_out = params.ny
        x_out = dx_out*(x0 + indgen(nx_out))
        y_out = dy_out*(y0 + indgen(ny_out))
     end
     strcmp(axes,'xz') || strcmp(axes,'zx'): begin
        dx_out = params.dx*params.nout_avg
        dy_out = params.dz*params.nout_avg
        nx_out = params.nx*params.nsubdomains
        ny_out = params.nz
        x_out = dx_out*(x0 + indgen(nx_out))
        y_out = dy_out*(z0 + indgen(ny_out))
     end
     strcmp(axes,'yz') || strcmp(axes,'zy'): begin
        dx_out = params.dy*params.nout_avg
        dy_out = params.dz*params.nout_avg
        nx_out = params.ny
        ny_out = params.nz
        x_out = dx_out*(y0 + indgen(nx_out))
        y_out = dy_out*(z0 + indgen(ny_out))
     end
  endcase

  ;;==Rotate data, if requested
  if rotate gt 0 then begin
     if rotate mod 2 then begin
        tmp = y_out
        y_out = x_out
        x_out = tmp
        fsize = size(f_out)
        tmp = f_out
        f_out = make_array(fsize[2],fsize[1],fsize[3],type=fsize[4],/nozero)
        for it=0,fsize[3]-1 do f_out[*,*,it] = rotate(tmp[*,*,it],rotate)
     endif $
     else for it=0,fsize[3]-1 do f_out[*,*,it] = rotate(f_out[*,*,it],rotate)
  endif


end
