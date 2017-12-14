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

  ;;==Extract dimensional info
  if strcmp(context.image[imgkeys[id]].data.grid, 'k') then begin
     xrng = context.grid.k.xrng
     yrng = context.grid.k.yrng
     zrng = context.grid.k.zrng
     xctr = context.grid.k.xctr
     yctr = context.grid.k.yctr
     zctr = context.grid.k.zctr
     xvec = context.grid.k.xvec
     yvec = context.grid.k.yvec
     zvec = context.grid.k.zvec
  endif $
  else begin
     xrng = context.grid.r.xrng
     yrng = context.grid.r.yrng
     zrng = context.grid.r.zrng
     xctr = context.grid.r.xctr
     yctr = context.grid.r.yctr
     zctr = context.grid.r.zctr
     xvec = context.grid.r.xvec
     yvec = context.grid.r.yvec
     zvec = context.grid.r.zvec
  endelse
  context.image[imgkeys[id]].data.remove, 'grid'  

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
              context.image[imgkeys[id]].keywords.layout = layout
           endif

           ;;==Modify file name
           filename = context.image[imgkeys[id]].data.filebase+ $
                      '_'+planes[ip]+'.'+context.info.ext

           ;;==Extract appropriate subarray
           case 1B of
              strcmp(planes[ip],'xy'): begin
                 imgdata = data[xrng[0]:xrng[1],yrng[0]:yrng[1],zctr,*]
                 imgdata = reform(imgdata)
                 xdata = xvec[xrng[0]:xrng[1]]
                 ydata = yvec[yrng[0]:yrng[1]]
              end
              strcmp(planes[ip],'xz'): begin
                 imgdata = data[xrng[0]:xrng[1],yctr,zrng[0]:zrng[1],*]
                 imgdata = reform(imgdata)
                 xdata = xvec[xrng[0]:xrng[1]]
                 ydata = zvec[zrng[0]:zrng[1]]
              end
              strcmp(planes[ip],'yz'): begin
                 imgdata = data[xctr,yrng[0]:yrng[1],zrng[0]:zrng[1],*]
                 imgdata = reform(imgdata)
                 xdata = yvec[yrng[0]:yrng[1]]
                 ydata = zvec[zrng[0]:zrng[1]]
              end
              else: message, "Did not recognize plane ("+plane[ip]+")"
           endcase

           ;;==Create image
           ;;-->Update multi_image and use that here?
           ;;   Eventually want to pass _EXTRA = imgkw, where 
           ;;   imgkw = context.image[imgkeys[id]].keywords.tostruct()
           ;;   after removing any non-IDL keywords. Time-dependent
           ;;   IDL keywords should remain in imgkw.           
           imgkw = context.image[imgkeys[id]].keywords.tostruct()
           img = multi_image(imgdata,xdata,ydata,_EXTRA=imgkw)

           ;;==Add a colorbar
           if context.info.colorbar.haskey('type') then begin
              context.info.colorbar.type
              context.info.colorbar.remove, 'type'
           endif $
           else type = 'none'
           clrkw = context.info.colorbar.tostruct()
           img = multi_colorbar(img,type,_EXTRA = clrkw)

           ;;==Add path label

           ;;==Save the image

        endfor ;;-->Planes

     end
     2: begin
     end
  endcase ;;-->Dimensions
STOP
end
