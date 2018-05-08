;+
; Import a logically (2+1)-D plane of data from an EPPIC run.
;-
pro import_plane_data, data_name, $
                       lun=lun, $
                       path=path, $
                       axes=axes, $
                       rotate=rotate, $
                       ranges=ranges, $
                       data_isft=data_isft, $
                       f_out=f_out, $
                       x_out=x_out, $
                       y_out=y_out, $
                       nx_out=nx_out, $
                       ny_out=ny_out, $
                       dx_out=dx_out, $
                       dy_out=dy_out, $
                       _EXTRA=ex

  ;;==Defaults and guards
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(path) eq 0 then path = './'
  if n_elements(axes) eq 0 then axes = 'xy'
  if n_elements(rotate) eq 0 then rotate = 0

  ;;==Read simulation parameters
  params = set_eppic_params(path=path)

  ;;==Read data at each time step
  f_out = read_ph5_plane(data_name, $
                         lun = lun, $
                         axes = axes, $
                         ranges = ranges, $
                         data_isft = data_isft, $
                         info_path = path, $
                         _EXTRA = ex)

  ;;==Get size of data plane
  fsize = size(f_out)

  ;;==Set plane-appropriate parameters
  case 1B of
     strcmp(axes,'xy') || strcmp(axes,'yx'): begin
        dx_out = params.dx
        dy_out = params.dy
     end
     strcmp(axes,'xz') || strcmp(axes,'zx'): begin
        dx_out = params.dx
        dy_out = params.dz
     end
     strcmp(axes,'yz') || strcmp(axes,'zy'): begin
        dx_out = params.dy
        dy_out = params.dz
     end
  endcase
  if ~keyword_set(data_isft) then begin
     dx_out *= params.nout_avg
     dy_out *= params.nout_avg
  endif
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
