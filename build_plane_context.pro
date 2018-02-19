function build_plane_context, info,plane=plane,context=context

  ;;==Defaults and guards
  if n_elements(plane) eq 0 then plane = 'xy'
  if n_elements(context) eq 0 then context = 0

  ;;==Convert context to an integer code
  context_error = 0B
  if isa(context,/string) then begin
     case 1B of 
        strcmp(context,'spatial'): context = 0
        strcmp(context,'spectral'): context = 1
        else: context_error = 1B
     endcase
  endif $
  else if where([0,1] eq context) eq -1 then context_error = 1B

  ;;==Alert user to error and set default
  if context_error then begin
     print, "[BUILD_PLANE_CONTEXT] Currently supported contexts:"
     print, "                      0 or 'spatial' (default)"
     print, "                      1 or 'spectral'"
     print, "                      Using default."
     context = 0
  endif

  ;;==Create rotation matrix
  r_ang = info.rot[plane]*!dtor
  r_mat = [[cos(r_ang),-sin(r_ang)], $
           [sin(r_ang),cos(r_ang)]]

  ;;==Build context
  case 1B of 
     strcmp(plane,'xy') || strcmp(plane,'yx'): begin
        len = [info.grid.nx,info.grid.ny]
        dif = [info.grid.dx,info.grid.dy]
        rng = [[info.ranges.x],[info.ranges.y]]
        if (info.rot[plane] / 90) mod 2 then begin
           len = reverse(len)
           dif = reverse(dif)
           rng = reverse(rng,2)
        endif
        case context of
           0: begin
              xdata = dif[0]*findgen(len[0])
              ydata = dif[1]*findgen(len[1])
           end
           1: begin
              xdata = (2*!pi/(dif[0]*len[0]))*(findgen(len[0])-0.5*len[0])
              ydata = (2*!pi/(dif[1]*len[1]))*(findgen(len[1])-0.5*len[1])
           end
        endcase
        E0 = r_mat ## [info.params.Ex0_external,info.params.Ey0_external]
     end
     strcmp(plane,'xz') || strcmp(plane,'zx'): begin
        len = [info.grid.nx,info.grid.nz]
        dif = [info.grid.dx,info.grid.dz]
        rng = [[info.ranges.x],[info.ranges.z]]
        if (info.rot[plane] / 90) mod 2 then begin
           len = reverse(len)
           dif = reverse(dif)
           rng = reverse(rng,2)
        endif
        case context of
           0: begin
              xdata = dif[0]*findgen(len[0])
              ydata = dif[1]*findgen(len[1])
           end
           1: begin
              xdata = (2*!pi/(dif[0]*len[0]))*(findgen(len[0])-0.5*len[0])
              ydata = (2*!pi/(dif[1]*len[1]))*(findgen(len[1])-0.5*len[1])
           end
        endcase
        E0 = r_mat ## [info.params.Ex0_external,info.params.Ez0_external]
     end
     strcmp(plane,'yz') || strcmp(plane,'zy'): begin
        len = [info.grid.ny,info.grid.nz]
        dif = [info.grid.dy,info.grid.dz]
        rng = [[info.ranges.y],[info.ranges.z]]
        if (info.rot[plane] / 90) mod 2 then begin
           len = reverse(len)
           dif = reverse(dif)
           rng = reverse(rng,2)
        endif
        case context of
           0: begin
              xdata = dif[0]*findgen(len[0])
              ydata = dif[1]*findgen(len[1])
           end
           1: begin
              xdata = (2*!pi/(dif[0]*len[0]))*(findgen(len[0])-0.5*len[0])
              ydata = (2*!pi/(dif[1]*len[1]))*(findgen(len[1])-0.5*len[1])
           end
        endcase
        E0 = r_mat ## [info.params.Ey0_external,info.params.Ez0_external]
     end
  endcase

  return, dictionary('xdata', xdata, $
                     'ydata', ydata, $
                     'xrange', rng[*,0], $
                     'yrange', rng[*,1], $
                     'dx', dif[0], $
                     'dy', dif[1], $
                     'E0', E0)

end
