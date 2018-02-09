function build_imgplane, data,info,plane=plane,context=context

  dsize = size(data)
  n_dims = dsize[0]

  if n_elements(info) eq 0 then $ ;-->Consider making this function independent of info
     message, "[BUILD_IMGPLANE] Please supply info dictionary."
  if n_dims gt 3 then $         ;-->Eventually want to handle (3+1)-D data
     message, "[BUILD_IMGPLANE] Currently only supports (2+1)-D data."

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

  ;;==Alert user to context error and set default
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

  ;;==Extract data subarray
  ;; if (info.rot[plane] / 90) mod 2 then $
  ;;    data = data[rng[0,1]:rng[1,1],rng[0,0]:rng[1,0],*] $
  ;; else $
  ;;    data = data[rng[0,0]:rng[1,0],rng[0,1]:rng[1,1],*]
  data = data(info.ranges.x[0]:info.ranges.x[1], $
              info.ranges.y[0]:info.ranges.y[1],*)

  ;;==Update dimensions
  dsize = size(data)
  nt = dsize[n_dims]
  nx = dsize[1]
  ny = dsize[2]
STOP
  ;;==Rotate data, if requested
  if (info.rot[plane] / 90) mod 2 then begin
     tmp = data
     data = make_array(nx,ny,nt,type=size(data,/type))
     for it=0,nt-1 do data[*,*,it] = rotate(tmp[*,*,it],info.rot[plane])
STOP
  endif

  return, dictionary('data', data, $
                     'xdata', xdata, $
                     'ydata', ydata, $
                     'xrange', rng[*,0], $
                     'yrange', rng[*,1], $
                     'dx', dif[0], $
                     'dy', dif[1], $
                     'E0', E0)

end
