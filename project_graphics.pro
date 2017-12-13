pro project_graphics, context

  ;;==Get general info
  path = context.info.path
  timestep = context.info.timestep

  ;;==Get image hash keys
  imgkeys = context.image.keys()

  ;-->DEV
  id = 0

  ;;==Read single data quantity
  data_name = context.image[imgkeys[id]].data.name
  data = (load_eppic_data(data_name, $
                          path=path, $
                          timestep=timestep))[data_name]

  ;;==Get data dimensions
  data_size = size(data)
  n_dims = data_size[0]
  nt = data_size[n_dims]
  switch n_dims-1 of
     3: nz = data_size[3]
     2: ny = data_size[2]
     1: nx = data_size[1]
  endswitch

  ;;==Read simulation parameters, etc.
  params = set_eppic_params(path=path)
  grid = set_grid(path=path)
  nt_max = calc_timesteps(path=path,grid=grid)

  ;;==Construct time step strings
  ts_str = string(1e3*params.dt*timestep,format='(f7.2)')
  ts_str = "t = "+strcompress(ts_str,/remove_all)+" ms"

  ;;==Check image dimensions
  case n_dims-1 of
     3: begin

        ;;==Create a list of 2-D planes for 3-D data
        planes = ['yz']         ;DEV
        n_planes = n_elements(planes)

        ;;==Calculate forward/inverse FFT, if requested
        if keyword_set(fft_direction) then begin
           for it=0,nt-1 do begin
              data[*,*,*,it] = real_part(fft(data[*,*,*,it], $
                                             fft_direction,/overwrite))
           endfor
        endif
        
        ;;==Loop over planes
        for ip=0,n_planes-1 do begin

           ;;==Construct panel layout array for this plane
           if context.info.haskey('layout') then begin
              layout = context.info.layout
              if n_elements(layout) ne 0 then begin
                 input = layout
                 layout = intarr(3,nt)
                 for it=0,nt-1 do layout[*,it] = [input[0],input[1],it+1]
              endif
           endif

           ;;==Modify file name
           filename = strip_extension(filename)+'_'+planes[ip]+'.'+ext

           ;;==Extract appropriate subarray
           case 1B of
              strcmp(planes[ip],'xy'): begin
                 imgdata = reform(data[*,*,origin['xy'],*])
              end
              strcmp(planes[ip],'xz'): begin
                 imgdata = reform(data[*,origin['xz'],*,*])
              end
              strcmp(planes[ip],'yz'): begin
                 imgdata = reform(data[origin['yz'],*,*,*])
              end
           endcase

           ;;==Create image
           ;;-->Update multi_image and use that here?

           ;;==Add a colorbar

           ;;==Add path label

           ;;==Save the image

        endfor ;;-->Planes

     end
     2: begin
     end
  endcase ;;-->Dimensions
STOP
end
