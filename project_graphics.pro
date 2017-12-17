pro project_graphics, context,filepath=filepath

  ;;==Defaults and guards
  if n_elements(context) eq 0 || ~isa(context,'dictionary') then $
     message, "[PROJECT_GRAPHICS] Please supply a graphics context dictionary"

  ;;==Get general info
  path = context.global.path
  timestep = context.global.timestep

  ;;==Get image hash keys
  imgkeys = context.image.keys()
  n_images = context.image.count()

  for id=0,n_images-1 do begin
     
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
           planes = ['yz']      ;DEV
           n_planes = n_elements(planes)

           ;;==Calculate forward/inverse FFT, if requested
           if context.image[imgkeys[id]].data.haskey('fft_direction') && $
              context.image[imgkeys[id]].data.fft_direction ne 0 then begin
              for it=0,nt-1 do begin
                 data[*,*,*,it] = real_part(fft(data[*,*,*,it], $
                                                context.image[imgkeys[id]].data.fft_direction, $
                                                /overwrite))
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
                    grad_dx = grid.dx
                    grad_dy = grid.dy
                    if context.image[imgkeys[id]].data.haskey('gradient_f0') then begin
                       if n_elements(context.image[imgkeys[id]].data.gradient_f0) eq 1 then $
                          grad_f0 = [context.image[imgkeys[id]].data.gradient_f0, $
                                     context.image[imgkeys[id]].data.gradient_f0] $
                       else $
                          grad_f0 = [context.image[imgkeys[id]].data.gradient_f0[0], $
                                     context.image[imgkeys[id]].data.gradient_f0[1]]
                    endif else grad_f0 = [0.0,0.0]
                 end
                 strcmp(planes[ip],'xz'): begin
                    imgdata = data[xrng[0]:xrng[1],yctr,zrng[0]:zrng[1],*]
                    xdata = xvec[xrng[0]:xrng[1]]
                    ydata = zvec[zrng[0]:zrng[1]]
                    grad_dx = grid.dx
                    grad_dy = grid.dz
                    if context.image[imgkeys[id]].data.haskey('gradient_f0') then begin
                       if n_elements(context.image[imgkeys[id]].data.gradient_f0) eq 1 then $
                          grad_f0 = [context.image[imgkeys[id]].data.gradient_f0, $
                                     context.image[imgkeys[id]].data.gradient_f0] $
                       else $
                          grad_f0 = [context.image[imgkeys[id]].data.gradient_f0[0], $
                                     context.image[imgkeys[id]].data.gradient_f0[2]]
                    endif else grad_f0 = [0.0,0.0]
                 end
                 strcmp(planes[ip],'yz'): begin
                    imgdata = data[xctr,yrng[0]:yrng[1],zrng[0]:zrng[1],*]
                    xdata = yvec[yrng[0]:yrng[1]]
                    ydata = zvec[zrng[0]:zrng[1]]
                    grad_dx = grid.dy
                    grad_dy = grid.dz
                    if context.image[imgkeys[id]].data.haskey('gradient_f0') then begin
                       if n_elements(context.image[imgkeys[id]].data.gradient_f0) eq 1 then $
                          grad_f0 = [context.image[imgkeys[id]].data.gradient_f0, $
                                     context.image[imgkeys[id]].data.gradient_f0] $
                       else $
                          grad_f0 = [context.image[imgkeys[id]].data.gradient_f0[1], $
                                     context.image[imgkeys[id]].data.gradient_f0[2]]
                    endif else grad_f0 = [0.0,0.0]
                 end
                 else: message, "Did not recognize plane ("+plane[ip]+")"
              endcase
              imgdata = reform(imgdata)

              ;;==Calculate gradient, if requested
              if context.image[imgkeys[id]].data.haskey('gradient_scale') then begin
                 for it=0,nt-1 do begin
                    imgdata[*,*,it] = smooth(imgdata[*,*,it],[1.0/grad_dx,1.0/grad_dy],/edge_wrap) ;DEV
                    gradf = gradient(imgdata[*,*,it],dx=grad_dx[*],dy=grad_dy[*])
                    gradf.x *= context.image[imgkeys[id]].data.gradient_scale
                    gradf.y *= context.image[imgkeys[id]].data.gradient_scale
                    gradf.x += grad_f0[0]
                    gradf.y += grad_f0[1]
                    if context.image[imgkeys[id]].data.haskey('gradient_image') then begin
                       if strcmp(context.image[imgkeys[id]].data.gradient_image,'magnitude') then $
                          imgdata[*,*,it] = sqrt(gradf.x^2 + gradf.y^2)
                    endif
                 endfor
              endif

              ;;==Smooth data, if requested

              ;;==Create image
              if context.image[imgkeys[id]].data.haskey('scale') then $
                 imgdata *= context.image[imgkeys[id]].data.scale
              if strcmp(context.colorbar.keywords.type, 'global') then begin
                 context.image[imgkeys[id]].keywords.max_value = max(abs(imgdata))
                 if context.image[imgkeys[id]].data.haskey('rms') && $
                    context.image[imgkeys[id]].data.rms eq 1 then $
                       context.image[imgkeys[id]].keywords.min_value = 0 $
                 else $
                    context.image[imgkeys[id]].keywords.min_value = -max(abs(imgdata))
              endif
              imgkw = context.image[imgkeys[id]].keywords.tostruct()
              img = multi_image(imgdata,xdata,ydata,_EXTRA=imgkw)

              ;;==Add a colorbar
              if context.colorbar.keywords.haskey('type') then begin
                 type = context.colorbar.keywords.type
              endif else type = 'none'
              if context.colorbar.keywords.haskey('width') then begin
                 width = context.colorbar.keywords.width
              endif
              if context.colorbar.keywords.haskey('height') then begin
                 height = context.colorbar.keywords.height
              endif
              if context.colorbar.keywords.haskey('buffer') then begin
                 buffer = context.colorbar.keywords.buffer
              endif
              if context.image[imgkeys[id]].data.haskey('symbol') then $
                 title = context.image[imgkeys[id]].data.symbol $
              else $
                 title = imgkeys[id]
              if context.image[imgkeys[id]].data.haskey('units') then $
                 title += ' '+context.image[imgkeys[id]].data.units
              context.colorbar.keywords.title = title
              clrkw = context.colorbar.keywords.tostruct()
              img = multi_colorbar(img,type, $
                                   width = width, $
                                   height = height, $
                                   buffer = buffer, $
                                   _EXTRA = clrkw)

              ;;==Add path label
              txt = text(0.00,0.00,path, $
                         alignment = 0.5, $
                         target = img, $
                         font_name = 'Times', $
                         font_size = 5.0)

              ;;==Update file name
              filename = context.image[imgkeys[id]].data.filebase+ $
                         '_'+planes[ip]+'.'+context.global.ext

              ;;==Save the image
              image_save, img,filename=filepath+path_sep()+filename

              ;;==Create movie

           endfor ;;-->n_planes

        end
        2: begin
        end
     endcase ;;-->n_dims
  endfor ;;-->n_images
end
