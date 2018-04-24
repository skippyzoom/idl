;+
; Import a logically (2+1)-D plane of data from an EPPIC run.
;-
pro import_data_plane, data_name, $
                       lun=lun, $
                       axes=axes, $
                       rotate=rotate, $
                       ranges=ranges, $
                       data_isft=data_isft, $
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
  if n_elements(axes) eq 0 then axes = 'xy'
  if n_elements(rotate) eq 0 then rotate = 0
  if n_elements(info_path) eq 0 then info_path = './'
  if n_elements(lun) eq 0 then lun = -1

  ;;==Read simulation parameters
  params = set_eppic_params(path=info_path)

  ;;==Read data at each time step
  f_out = read_ph5_plane(data_name, $
                         lun = lun, $
                         axes = axes, $
                         ranges = ranges, $
                         data_isft = data_isft, $
                         info_path = info_path, $
                         _EXTRA = ex)

  fsize = size(f_out)
  case 1B of
     strcmp(axes,'xy') || strcmp(axes,'yx'): begin
        dx_out = params.dx*params.nout_avg
        dy_out = params.dy*params.nout_avg
     end
     strcmp(axes,'xz') || strcmp(axes,'zx'): begin
        dx_out = params.dx*params.nout_avg
        dy_out = params.dz*params.nout_avg
     end
     strcmp(axes,'yz') || strcmp(axes,'zy'): begin
        dx_out = params.dy*params.nout_avg
        dy_out = params.dz*params.nout_avg
     end
  endcase
  nx_out = fsize[1]
  ny_out = fsize[2]
  x_out = dx_out*(ranges[0] + indgen(nx_out))
  y_out = dy_out*(ranges[2] + indgen(ny_out))

  ;;==Rotate data, if requested
  if ~keyword_set(data_isft) then begin
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
        else for it=0,fsize[3]-1 do $
           f_out[*,*,it] = rotate(f_out[*,*,it],rotate)
     endif
  endif

end
