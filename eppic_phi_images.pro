;+
; This routine makes images from EPPIC phi data. 
; Other images that require phi should go here.
;-
pro eppic_phi_images, info

  ;;==Unpack info dictionary
  params = info.params
  position = info.position
  font_name = info.font_name
  path = info.path
  filepath = info.filepath
  planes = info.planes
  timestep = info.timestep

  ;;==Read data
  data = (load_eppic_data('phi',path=path,timestep=timestep))['phi']

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

     ;;==Create a hash for filenames
     filename = hash(['phi','emag'])

     ;;==Loop over 2-D image planes
     n_planes = (n_dims eq 4) ? n_elements(planes) : 1
     for ip=0,n_planes-1 do begin

        case n_dims of 
           4: begin

              ;;==Transpose data
              if n_elements(info.xyz) eq 2 then info.xyz = [info.xyz,2]
              data = transpose(data,[info.xyz,3])

              ;;==Set up 2-D image
              case 1B of 
                 strcmp(planes[ip],'xy') || strcmp(planes[ip],'yx'): begin
                    imgplane = reform(data[*,*,info.zctr,*])
                    xdata = info.xvec
                    ydata = info.yvec
                    xrng = info.xrng
                    yrng = info.yrng
                    dx = params.dx
                    dy = params.dy
                    Ex0 = params.Ex0_external
                    Ey0 = params.Ey0_external
                 end
                 strcmp(planes[ip],'xz') || strcmp(planes[ip],'zx'): begin
                    imgplane = reform(data[*,info.yctr,*,*])
                    xdata = info.xvec
                    ydata = info.zvec
                    xrng = info.xrng
                    yrng = info.zrng
                    dx = params.dx
                    dy = params.dz
                    Ex0 = params.Ex0_external
                    Ey0 = params.Ez0_external
                 end
                 strcmp(planes[ip],'yz') || strcmp(planes[ip],'zy'): begin
                    imgplane = reform(data[info.xctr,*,*,*])
                    xdata = info.yvec
                    ydata = info.zvec
                    xrng = info.yrng
                    yrng = info.zrng
                    dx = params.dy
                    dy = params.dz
                    Ex0 = params.Ey0_external
                    Ey0 = params.Ez0_external
                 end
              endcase

              ;;==Update imaging flag
              image_data_exists = 1B

              ;;==Store filenames
              filename['phi'] = 'phi_'+planes[ip]+'.pdf'
              filename['emag'] = 'emag_'+planes[ip]+'.pdf'

           end
           3: begin

              ;;==Transpose data
              if n_elements(info.xyz) gt 2 then info.xyz = info.xyz[0:1]
              data = transpose(data,[info.xyz,2])        

              ;;==Set up 2-D image
              imgplane = reform(data)
              xdata = info.xvec
              ydata = info.yvec
              xrng = info.xrng
              yrng = info.yrng
              dx = params.dx
              dy = params.dy
              Ex0 = params.Ex0_external
              Ey0 = params.Ey0_external        

              ;;==Update imaging flag
              image_data_exists = 1B

              ;;==Store filenames
              filename['phi'] = 'phi.pdf'
              filename['emag'] = 'emag.pdf'

           end
           else: print, "[EPPIC_PHI_IMAGES] Currently set up for 2 or 3 spatial dimensions."
        endcase

        if image_data_exists then begin

           ;;==Extract axis subsets
           xdata = xdata[xrng[0]:xrng[1]]
           ydata = ydata[yrng[0]:yrng[1]]

                                ;-----------;
                                ; phi image ;
                                ;-----------;

           ;;==Extract subimage
           imgdata = imgplane[xrng[0]:xrng[1],yrng[0]:yrng[1],*]

           ;;==Set up graphics parameters
           ct = get_custom_ct(1)
           rgb_table = [[ct.r],[ct.g],[ct.b]]
           min_value = -max(abs(imgdata))
           max_value = +max(abs(imgdata))

           ;;==Create image
           img = multi_image(imgdata,xdata,ydata, $
                             position = position, $
                             axis_style = axis_style, $
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
                                font_name = font_name, $
                                font_size = 8.0)

           ;;==Add path label
           txt = text(0.00,0.05,path, $
                      alignment = 0.0, $
                      target = img, $
                      font_name = font_name, $
                      font_size = 5.0)

           ;;==Save image
           image_save, img[0],filename=filepath+path_sep()+filename['phi']

                                ;------------;
                                ; emag image ;
                                ;------------;

           ;;==Calculate |E|
           ;; imgplane = smooth(imgplane,[0.5/dx,0.5/dy,1],/edge_wrap)
           efield = dictionary()
           for it=0,nt-1 do begin
              gradf = gradient(imgplane[*,*,it],dx=dx*params.nout_avg,dy=dy*params.nout_avg)
              efield.x = -1.0*gradf.x + params.Ex0_external
              efield.y = -1.0*gradf.y + params.Ey0_external
              ;; efield.x = -1.0*gradf.x
              ;; efield.y = -1.0*gradf.y
              imgplane[*,*,it] = sqrt(efield.x^2 + efield.y^2)
           endfor

           ;;==Extract subimage
           imgdata = imgplane[xrng[0]:xrng[1],yrng[0]:yrng[1],*]

           ;;==Set up graphics parameters
           rgb_table = 3
           min_value = 0
           max_value = max(imgdata)

           ;;==Create image
           img = multi_image(imgdata,xdata,ydata, $
                             position = position, $
                             axis_style = axis_style, $
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
                                font_name = font_name, $
                                font_size = 8.0)

           ;;==Add path label
           txt = text(0.00,0.05,path, $
                      alignment = 0.0, $
                      target = img, $
                      font_name = font_name, $
                      font_size = 5.0)

           ;;==Save image
           image_save, img[0],filename=filepath+path_sep()+filename['emag']

        endif ;;--image_data_exists
     endfor   ;;--n_planes
  endif $     ;;--n_dims gt 2
  else print, "[EPPIC_PHI_IMAGES] Could not create an image."

end
