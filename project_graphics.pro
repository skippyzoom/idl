pro project_graphics, context,filepath=filepath

  ;;==Defaults and guards
  if n_elements(context) eq 0 || ~isa(context,'dictionary') then $
     message, "[PROJECT_GRAPHICS] Please supply a graphics context dictionary"

  ;;==Get general info
  path = context.global.path
  timestep = context.global.timestep

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

           ;;==Extract appropriate subarray
           case 1B of
              strcmp(planes[ip],'xy'): begin
                 imgdata = data[xrng[0]:xrng[1],yrng[0]:yrng[1],zctr,*]
                 xdata = xvec[xrng[0]:xrng[1]]
                 ydata = yvec[yrng[0]:yrng[1]]
              end
              strcmp(planes[ip],'xz'): begin
                 imgdata = data[xrng[0]:xrng[1],yctr,zrng[0]:zrng[1],*]
                 xdata = xvec[xrng[0]:xrng[1]]
                 ydata = zvec[zrng[0]:zrng[1]]
              end
              strcmp(planes[ip],'yz'): begin
                 imgdata = data[xctr,yrng[0]:yrng[1],zrng[0]:zrng[1],*]
                 xdata = yvec[yrng[0]:yrng[1]]
                 ydata = zvec[zrng[0]:zrng[1]]
              end
              else: message, "Did not recognize plane ("+plane[ip]+")"
           endcase
           imgdata = reform(imgdata)

           ;;==Create image
           if context.image[imgkeys[id]].data.haskey('scale') then $
              imgdata *= context.image[imgkeys[id]].data.scale
           if strcmp(context.colorbar.keywords.type, 'global') then begin
              context.image[imgkeys[id]].keywords.max_value = max(abs(imgdata))
              context.image[imgkeys[id]].keywords.min_value = -max(abs(imgdata))
           endif
           imgkw = context.image[imgkeys[id]].keywords.tostruct()
           img = multi_image(imgdata,xdata,ydata,_EXTRA=imgkw)

           ;;==Add a colorbar
           if context.colorbar.keywords.haskey('type') then begin
              type = context.colorbar.keywords.type
              context.colorbar.keywords.remove, 'type'
           endif else type = 'none'
           if context.colorbar.keywords.haskey('width') then begin
              width = context.colorbar.keywords.width
              context.colorbar.keywords.remove, 'width'
           endif
           if context.colorbar.keywords.haskey('height') then begin
              height = context.colorbar.keywords.height
              context.colorbar.keywords.remove, 'height'
           endif
           if context.colorbar.keywords.haskey('buffer') then begin
              buffer = context.colorbar.keywords.buffer
              context.colorbar.keywords.remove, 'buffer'
           endif
           if context.image[imgkeys[id]].data.haskey('units') then $
              context.colorbar.keywords.title = imgkeys[id]+ $
                                                ' '+ $
                                                context.image[imgkeys[id]].data.units
           clrkw = context.colorbar.keywords.tostruct()
           img = multi_colorbar(img,type, $
                                width = 0.0225, $
                                height = 0.20, $
                                buffer = 0.03, $
                                _EXTRA = clrkw)

           ;;==Add path label
           ;; txt = text(0.50,0.98,path, $
           txt = text(0.50,0.00,path, $
                      alignment = 0.5, $
                      target = img, $
                      font_name = 'Times', $
                      font_size = 5.0)

           ;;==Update file name
           filename = context.image[imgkeys[id]].data.filebase+ $
                      '_'+planes[ip]+'.'+context.global.ext

           ;;==Save the image
           image_save, img,filename=filepath+path_sep()+filename

        endfor ;;-->Planes

     end
     2: begin
     end
  endcase ;;-->Dimensions

end
