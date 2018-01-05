;+
; Routine to plot electrostatic potential
; for eppic_full.pro
;-
pro eppic_full_phi, info

  ;;==Unpack info dictionary
  ;; xrng = info.xrng
  ;; yrng = info.yrng
  ;; zrng = info.zrng
  ;; xctr = info.xctr
  ;; yctr = info.yctr
  ;; zctr = info.zctr
  ;; xvec = info.xvec
  ;; yvec = info.yvec
  ;; zvec = info.zvec
  params = info.params
  position = info.position
  font_name = info.font_name
  path = info.path
  filepath = info.filepath
  planes = info.planes
  timestep = info.timestep
  xyz = info.xyz

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

  ;;==Create a hash for filenames
  filename = hash(['phi','emag'])

  case n_dims of 
     4: begin

        ;;==Transpose data
        if n_elements(xyz) eq 2 then xyz = [xyz,2]
        data = transpose(data,[xyz,3])

        ;;==Set up 2-D image
        n_planes = n_elements(planes)
        for ip=0,n_planes-1 do begin
           case 1B of 
              strcmp(planes[ip],'xy'): begin
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
              strcmp(planes[ip],'xz'): begin
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
              strcmp(planes[ip],'yz'): begin
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

           ;;==Store filenames
           filename['phi'] = 'phi_'+planes[ip]+'.pdf'
           filename['emag'] = 'emag_'+planes[ip]+'.pdf'

        endfor
     end
     3: begin

        ;;==Transpose data
        if n_elements(xyz) gt 2 then xyz = xyz[0:1]
        data = transpose(data,[xyz,2])        

        ;;==Set up 2-D image
        imgplane = reform(data)
        xdata = xvec
        ydata = yvec
        dx = params.dx
        dy = params.dy
        Ex0 = params.Ex0_external
        Ey0 = params.Ey0_external        

        ;;==Store filenames
        filename['phi'] = 'phi.pdf'
        filename['emag'] = 'emag.pdf'

     end
     else: print, "[EPPIC_PHI_IMAGES] Data must have 2 or 3 spatial dimensions."
  endcase

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
  filename = 'emag.pdf'
  image_save, img[0],filename=filepath+path_sep()+filename['emag']

IF 0 THEN BEGIN
  ;;==Check data dimensions (space and time)
  case n_dims of
     4: begin

        ;;==Transpose data
        if n_elements(xyz) eq 2 then xyz = [xyz,2]
        data = transpose(data,[xyz,3])

        ;;==Loop over planes
        for ip=0,n_planes-1 do begin

           ;;==Extract subarray
           case 1B of
              strcmp(planes[ip],'xy'): begin
                 imgdata = data[xrng[0]:xrng[1],yrng[0]:yrng[1],zctr,*]
                 xdata = xvec[xrng[0]:xrng[1]]
                 ydata = yvec[yrng[0]:yrng[1]]
                 dx = params.dx
                 dy = params.dy
              end
              strcmp(planes[ip],'xz'): begin
                 imgdata = data[xrng[0]:xrng[1],yctr,zrng[0]:zrng[1],*]
                 xdata = xvec[xrng[0]:xrng[1]]
                 ydata = zvec[zrng[0]:zrng[1]]
                 dx = params.dx
                 dy = params.dz
              end
              strcmp(planes[ip],'yz'): begin
                 imgdata = data[xctr,yrng[0]:yrng[1],zrng[0]:zrng[1],*]
                 ydata = yvec[yrng[0]:yrng[1]]
                 xdata = zvec[zrng[0]:zrng[1]]
                 dx = params.dy
                 dy = params.dz
              end
           endcase

           ;;==Set up data for phi image
           imgdata = reform(imgdata)
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
           filename = data_name+'_'+planes[ip]+'.pdf'
           image_save, img[0],filename=filepath+path_sep()+filename

           ;;==Set up data for |E| image
           ;; imgdata = smooth(imgdata,[0.5/dx,0.5/dy,1],/edge_wrap)
           efield = dictionary()
           for it=0,nt-1 do begin
              gradf = gradient(imgdata[*,*,it],dx=dx*params.nout_avg,dy=dy*params.nout_avg)
              efield.x = -1.0*gradf.x + Ex0
              efield.y = -1.0*gradf.y + Ey0
              ;; efield.x = -1.0*gradf.x
              ;; efield.y = -1.0*gradf.y
              imgdata[*,*,it] = sqrt(efield.x^2 + efield.y^2)
           endfor
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
           filename = 'emag_'+planes[ip]+'.pdf'
           image_save, img[0],filename=filepath+path_sep()+filename
        endfor ;;n_planes
     end
     3: begin

        ;;==Transpose data
        if n_elements(xyz) gt 2 then xyz = xyz[0:1]
        data = transpose(data,[xyz,2])

        ;;==Extract subarray
        imgdata = data[xrng[0]:xrng[1],yrng[0]:yrng[1],*]
        xdata = xvec[xrng[0]:xrng[1]]
        ydata = yvec[yrng[0]:yrng[1]]
        dx = params.dx
        dy = params.dy

        ;;==Set up data for phi image
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
        filename = 'phi.pdf'
        image_save, img[0],filename=filepath+path_sep()+filename

        ;;==Zero the image array
        imgdata *= 0.0

        ;;==Calculate |E|
        ;; imgdata = smooth(imgdata,[0.5/dx,0.5/dy,1],/edge_wrap)
        efield = dictionary()
        for it=0,nt-1 do begin
           gradf = gradient(data[*,*,it],dx=dx*params.nout_avg,dy=dy*params.nout_avg)
           efield.x = -1.0*gradf.x + params.Ex0_external
           efield.y = -1.0*gradf.y + params.Ey0_external
           ;; efield.x = -1.0*gradf.x
           ;; efield.y = -1.0*gradf.y
           data[*,*,it] = sqrt(efield.x^2 + efield.y^2)
        endfor

        ;;==Extract subarray
        imgdata = data[xrng[0]:xrng[1],yrng[0]:yrng[1],*]
        xdata = xvec[xrng[0]:xrng[1]]
        ydata = yvec[yrng[0]:yrng[1]]
        dx = params.dx
        dy = params.dy

        ;;==Set up data for |E| image
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
        filename = 'emag.pdf'
        image_save, img[0],filename=filepath+path_sep()+filename

     end
     else: print, "[EPPIC_FULL_PHI] Incorrect number of dimensions ("+ $
                  strcompress(n_dims,/remove_all)+ $
                  ", including time) to make an image."
  endcase
ENDIF ;;SKIP
end
