;+
; This routine makes images from EPPIC denft data. 
; Other images that require denft should go here.
;-
pro eppic_denft_images, info

  ;;==Loop over available distributions
  n_dist = info.params.ndist
  for id=0,n_dist-1 do begin
     dist_name = 'denft'+strcompress(id,/remove_all)

     ;;==Read data
     data = (load_eppic_data(dist_name,path=info.path,timestep=info.timestep))[dist_name]

     ;;==Get data dimensions
     data_size = size(data)
     n_dims = data_size[0]
     nt = data_size[n_dims]
     switch n_dims-1 of
        3: nz = data_size[3]
        2: ny = data_size[2]
        1: nx = data_size[1]
     endswitch

     ;;==Check dimensions
     if n_dims gt 2 then begin

        ;;==Set imaging flag
        image_data_exists = 0B

        ;;==Loop over 2-D image planes
        n_planes = (n_dims eq 4) ? n_elements(info.planes) : 1
        for ip=0,n_planes-1 do begin

           case n_dims of 
              4: begin

                 ;;==Transpose data
                 if n_elements(info.xyz) eq 2 then info.xyz = [info.xyz,2]
                 data = transpose(data,[info.xyz,3])

                 ;;==Set up 2-D image
                 case 1B of 
                    strcmp(info.planes[ip],'xy') || strcmp(info.planes[ip],'yx'): begin
                       imgplane = reform(data[*,*,info.zctr,*])
                       len = info.grid.nx*info.params.nout_avg
                       tmp = findgen(len)-0.5*len
                       xdata = (2*!pi/(info.grid.dx*len))*tmp
                       len = info.grid.ny*info.params.nout_avg
                       tmp = findgen(len)-0.5*len
                       ydata = (2*!pi/(info.grid.dy*len))*tmp
                       xrng = info.xrng
                       yrng = info.yrng
                    end
                    strcmp(info.planes[ip],'xz') || strcmp(info.planes[ip],'zx'): begin
                       imgplane = reform(data[*,info.yctr,*,*])
                       len = info.grid.nx*info.params.nout_avg
                       tmp = findgen(len)-0.5*len
                       xdata = (2*!pi/(info.grid.dx*len))*tmp
                       len = info.grid.nz*info.params.nout_avg
                       tmp = findgen(len)-0.5*len
                       ydata = (2*!pi/(info.grid.dz*len))*tmp
                       xrng = info.xrng
                       yrng = info.zrng
                    end
                    strcmp(info.planes[ip],'yz') || strcmp(info.planes[ip],'zy'): begin
                       imgplane = reform(data[info.xctr,*,*,*])
                       len = info.grid.ny*info.params.nout_avg
                       tmp = findgen(len)-0.5*len
                       xdata = (2*!pi/(info.grid.dy*len))*tmp
                       len = info.grid.nz*info.params.nout_avg
                       tmp = findgen(len)-0.5*len
                       ydata = (2*!pi/(info.grid.dz*len))*tmp
                       xrng = info.yrng
                       yrng = info.zrng
                    end
                 endcase
                 tmp = !NULL
                 len = !NULL

                 ;;==Update imaging flag
                 image_data_exists = 1B

                 ;;==Save string for filenames
                 plane_string = '_'+info.planes[ip]

              end
              3: begin

                 ;;==Transpose data
                 if n_elements(info.xyz) gt 2 then info.xyz = info.xyz[0:1]
                 data = transpose(data,[info.xyz,2])        

                 ;;==Set up 2-D image
                 imgplane = reform(data)
                 len = info.grid.nx*info.params.nout_avg
                 tmp = findgen(len)-0.5*len
                 xdata = (2*!pi/(info.grid.dx*len))*tmp
                 len = info.grid.ny*info.params.nout_avg
                 tmp = findgen(len)-0.5*len
                 ydata = (2*!pi/(info.grid.dy*len))*tmp
                 xrng = info.xrng
                 yrng = info.yrng
                 tmp = !NULL
                 len = !NULL

                 ;;==Update imaging flag
                 image_data_exists = 1B

                 ;;==Save string for filenames
                 plane_string = ''

              end
              else: print, "[EPPIC_DENFT_IMAGES] Data must have 2 or 3 spatial dimensions."
           endcase

           if image_data_exists then begin

              ;;==Extract axis subsets
              xdata = xdata[xrng[0]:xrng[1]]
              ydata = ydata[yrng[0]:yrng[1]]

              ;;==Extract subimage
              imgdata = imgplane[xrng[0]:xrng[1],yrng[0]:yrng[1],*]
              imgdata = real_part(imgdata)
              imgdata = 10*alog10((imgdata/max(imgdata))^2)
              imgsize = size(imgdata,/dim)
              imgdata = shift(imgdata,imgsize[0]/2,imgsize[1]/2,0)

              ;;==Set up graphics parameters
              rgb_table = 39
              min_value = min(imgdata,/nan)
              max_value = max(imgdata,/nan)

              ;;==Create image
              img = multi_image(imgdata,xdata,ydata, $
                                xrange = [-2*!pi,2*!pi], $
                                yrange = [0,2*!pi], $
                                position = info.position, $
                                axis_style = info.axis_style, $
                                rgb_table = rgb_table, $
                                min_value = min_value, $
                                max_value = max_value)

              ;;==Add colorbar(s)
              img = multi_colorbar(img,'global', $
                                   width = 0.0225, $
                                   height = 0.40, $
                                   buffer = 0.03, $
                                   orientation = 1, $
                                   textpos = 1, $
                                   tickdir = 1, $
                                   ticklen = 0.2, $
                                   major = 7, $
                                   font_name = info.font_name, $
                                   font_size = 8.0)

              ;;==Add path label
              txt = text(0.00,0.05,info.path, $
                         alignment = 0.0, $
                         target = img, $
                         font_name = info.font_name, $
                         font_size = 5.0)

              ;;==Save image
              image_save, img[0],filename=info.filepath+path_sep()+ $
                          dist_name+plane_string+'.pdf'

           endif ;;--image_data_exists
        endfor   ;;--n_planes
     endif $     ;;--n_dims gt 2
     else print, "[EPPIC_DENFT_IMAGES] Could not create an image."

  endfor ;;n_dist
end
