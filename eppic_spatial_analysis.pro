;+
; This routine makes graphics from EPPIC spatial data. 
;-
pro eppic_spatial_analysis, info,movies=movies

  ;;==Loop over requested data quantities
  for id=0,n_elements(info.data_names)-1 do begin

     ;;==Extract current quantity name
     data_name = info.data_names[id]
     
     ;;==Read data
     if keyword_set(movies) then $
        data = (load_eppic_data(data_name,path=info.path))[data_name] $
     else $
        data = (load_eppic_data(data_name,path=info.path, $
                                timestep=info.timestep))[data_name]

     ;;==Get data dimensions
     data_size = size(data)
     n_dims = data_size[0]
     nt = data_size[n_dims]
     nz = 1
     ny = 1
     nx = 1
     switch n_dims-1 of
        3: nz = data_size[3]
        2: ny = data_size[2]
        1: nx = data_size[1]
     endswitch

     ;;==Check dimensions
     if n_dims gt 2 then begin

        ;;==Make physically 3-D data logically 4-D data
        data_is_2D = 0B
        if n_dims eq 3 then begin
           data_is_2D = 1B
           data = reform(data,[nx,ny,1,nt])
           n_dims = size(data,/n_dim)
           info.planes = 'xy'
           info['perp_to_B'] = 'xy'
        endif

        ;;==Transpose data
        xyzt = info.xyz
        tmp = indgen(n_dims)
        n_xyzt = n_elements(xyzt)
        if n_xyzt lt 4 then xyzt = [xyzt,tmp[n_xyzt,*]]
        data = transpose(data,xyzt)

        ;;==Loop over 2-D image planes
        for ip=0,n_elements(info.planes)-1 do begin

           ;;==Set up 2-D image
           case 1B of 
              strcmp(info.planes[ip],'xy') || strcmp(info.planes[ip],'yx'): begin
                 imgplane = reform(data[*,*,info.zctr,*])
                 xdata = info.xvec
                 ydata = info.yvec
                 xrng = info.xrng
                 yrng = info.yrng
                 dx = info.params.dx
                 dy = info.params.dy
                 r_ang = info.rot.xy*!dtor
                 r_mat = [[cos(r_ang),-sin(r_ang)], $
                          [sin(r_ang),cos(r_ang)]]
                 E0 = r_mat ## [info.params.Ex0_external,info.params.Ey0_external]
              end
              strcmp(info.planes[ip],'xz') || strcmp(info.planes[ip],'zx'): begin
                 imgplane = reform(data[*,info.yctr,*,*])
                 xdata = info.xvec
                 ydata = info.zvec
                 xrng = info.xrng
                 yrng = info.zrng
                 dx = info.params.dx
                 dy = info.params.dz
                 r_ang = info.rot.xz*!dtor
                 r_mat = [[cos(r_ang),-sin(r_ang)], $
                          [sin(r_ang),cos(r_ang)]]
                 E0 = r_mat ## [params.info.Ex0_external,params.info.Ez0_external]
              end
              strcmp(info.planes[ip],'yz') || strcmp(info.planes[ip],'zy'): begin
                 imgplane = reform(data[info.xctr,*,*,*])
                 xdata = info.yvec
                 ydata = info.zvec
                 xrng = info.yrng
                 yrng = info.zrng
                 dx = info.params.dy
                 dy = info.params.dz
                 r_ang = info.rot.yz*!dtor
                 r_mat = [[cos(r_ang),-sin(r_ang)], $
                          [sin(r_ang),cos(r_ang)]]
                 E0 = r_mat ## [params.info.Ey0_external,params.info.Ez0_external]
              end
           endcase

           ;;==Save string for filenames
           if data_is_2D then plane_string = '' $
           else plane_string = '_'+info.planes[ip]

           ;;==Rotate data -->DEV
           if info.haskey('rot') then begin
              if ~data_is_2D then begin
                 print, "[EPPIC_SPATIAL_ANALYSIS] WARNING!!!"
                 print, "       Rotation not tested for 3 D"
              endif $
              else begin
                 rot = info.rot[info.planes[ip]]/90
                 if rot ne 0 then begin
                    tmp = imgplane
                    imgplane = fltarr(ny,nx,nt)
                    for it=0,nt-1 do begin
                       imgplane[*,*,it] = rotate(tmp[*,*,it],rot)
                    endfor
                    tmp = !NULL
                    tmp = xdata
                    xdata = ydata
                    ydata = tmp
                    tmp = xrng
                    xrng = yrng
                    yrng = tmp
                    tmp = !NULL                 
                 endif
              endelse
           endif

           ;;==Create graphics of densities
           image_string = plane_string
           if strcmp(data_name,'den',3) then begin
              scale = 100
              basename = info.filepath+path_sep()+ $
                         data_name+image_string
              ;; min_value = -max(abs(scale*imgplane))
              ;; max_value = +max(abs(scale*imgplane))
              min_value = -9
              max_value = +9
              eppic_xyt_graphics, scale*imgplane,xdata,ydata, $
                                  info, $
                                  xrng = xrng, $
                                  yrng = yrng, $
                                  rgb_table = 5, $
                                  min_value = min_value, $
                                  max_value = max_value, $
                                  basename = basename, $
                                  /clip_y_axes, $
                                  colorbar_title = "$\delta n/n_0$ [%]",$
                                  expand = 3, $
                                  rescale = 0.8, $
                                  movie = keyword_set(movies)

              if strcmp(info.planes[ip],info.perp_to_B) then begin
                 image_string = plane_string
                 basename = info.filepath+path_sep()+'den_rms'+image_string
                 mean_field_plots, xdata,ydata, $
                                   scale*imgplane,scale*imgplane, $
                                   /rms, $
                                   basename = basename
              endif ;;--perp_to_B
           endif

           if strcmp(data_name,'phi') then begin

              ;;==Create graphics of electrostatic potential
              scale = 1e3
              image_string = plane_string
              ct = get_custom_ct(1)
              basename = info.filepath+path_sep()+ $
                         data_name+image_string
              ;; min_value = -max(abs(scale*imgplane[*,*,1:*]))
              ;; max_value = +max(abs(scale*imgplane[*,*,1:*]))
              min_value = -600
              max_value = +600
              eppic_xyt_graphics, scale*imgplane,xdata,ydata, $
                                  info, $
                                  xrng = xrng, $
                                  yrng = yrng, $
                                  rgb_table = 70, $
                                  min_value = min_value, $
                                  max_value = max_value, $
                                  basename = basename, $
                                  /clip_y_axes, $
                                  colorbar_title = "$\phi$ [mV]",$
                                  expand = 3, $
                                  rescale = 0.8, $
                                  movie = keyword_set(movies)

              ;;==Calculate E-field components
              Ex = fltarr(size(imgplane,/dim))
              Ey = fltarr(size(imgplane,/dim))
              Er = fltarr(size(imgplane,/dim))
              Et = fltarr(size(imgplane,/dim))
              for it=0,nt-1 do begin
                 gradf = gradient(imgplane[*,*,it], $
                                  dx = dx*info.params.nout_avg, $
                                  dy = dy*info.params.nout_avg)
                 ;; Ex[*,*,it] = -1.0*gradf.x + E0[0]
                 ;; Ey[*,*,it] = -1.0*gradf.y + E0[1]
                 Ex[*,*,it] = -1.0*gradf.x
                 Ey[*,*,it] = -1.0*gradf.y
                 Er[*,*,it] = sqrt(Ex[*,*,it]^2 + Ey[*,*,it]^2)
                 Et[*,*,it] = atan(Ey[*,*,it],Ex[*,*,it])
              endfor              

              ;;==Smooth E-field components
              s_width = 1
              if s_width gt 1 then begin
                 Ex = smooth(Ex,[s_width,s_width,1],/edge_wrap)
                 Ey = smooth(Ey,[s_width,s_width,1],/edge_wrap)
                 Er = smooth(Er,[s_width,s_width,1],/edge_wrap)
                 Et = smooth(Et,[s_width,s_width,1],/edge_wrap)
                 image_string = plane_string+'-sw'+ $
                                strcompress(s_width,/remove_all)
              endif

              ;;==Create graphics of electric field
              scale = 1e3
              basename = info.filepath+path_sep()+ $
                         'efield_x-P'+image_string
              ;; min_value = -max(abs(scale*Ex[*,*,1:*]))
              ;; max_value = +max(abs(scale*Ex[*,*,1:*]))
              min_value = -24
              max_value = +24
              eppic_xyt_graphics, scale*Ex,xdata,ydata, $
                                  info, $
                                  xrng = xrng, $
                                  yrng = yrng, $
                                  rgb_table = 70, $
                                  min_value = min_value, $
                                  max_value = max_value, $
                                  basename = basename, $
                                  /clip_y_axes, $
                                  ;; colorbar_title = "$E_x$ [mV/m]",$
                                  colorbar_title = "$\delta E_x$ [mV/m]",$
                                  expand = 3, $
                                  rescale = 0.8, $
                                  movie = keyword_set(movies)
              basename = info.filepath+path_sep()+ $
                         'efield_y-P'+image_string
              ;; min_value = -max(abs(scale*Ey[*,*,1:*]))
              ;; max_value = +max(abs(scale*Ey[*,*,1:*]))
              min_value = -24
              max_value = +24
              eppic_xyt_graphics, scale*Ey,xdata,ydata, $
                                  info, $
                                  xrng = xrng, $
                                  yrng = yrng, $
                                  rgb_table = 70, $
                                  min_value = min_value, $
                                  max_value = max_value, $
                                  basename = basename, $
                                  /clip_y_axes, $
                                  ;; colorbar_title = "$E_y$ [mV/m]",$
                                  colorbar_title = "$\delta E_y$ [mV/m]",$
                                  expand = 3, $
                                  rescale = 0.8, $
                                  movie = keyword_set(movies)
              basename = info.filepath+path_sep()+ $
                         'efield_r-P'+image_string
              min_value = 0
              ;; max_value = max(scale*Er[*,*,1:*])
              max_value = 24
              eppic_xyt_graphics, scale*Er,xdata,ydata, $
                                  info, $
                                  xrng = xrng, $
                                  yrng = yrng, $
                                  rgb_table = 3, $
                                  min_value = min_value, $
                                  max_value = max_value, $
                                  basename = basename, $
                                  /clip_y_axes, $
                                  ;; colorbar_title = "$|E|$ [mV/m]",$
                                  colorbar_title = "$|\delta E|$ [mV/m]",$
                                  expand = 3, $
                                  rescale = 0.8, $
                                  movie = keyword_set(movies)
              basename = info.filepath+path_sep()+ $
                         'efield_t-P'+image_string
              ct = get_custom_ct(2)
              min_value = -!pi
              max_value = +!pi
              eppic_xyt_graphics, Et,xdata,ydata, $
                                  info, $
                                  xrng = xrng, $
                                  yrng = yrng, $
                                  rgb_table = [[ct.r],[ct.g],[ct.b]], $
                                  min_value = min_value, $
                                  max_value = max_value, $
                                  basename = basename, $
                                  /clip_y_axes, $
                                  ;; colorbar_title = "$\tan^{-1}(E)$ [rad]",$
                                  colorbar_title = "$tan^{-1}(\delta E)$ [rad]",$
                                  expand = 3, $
                                  rescale = 0.8, $
                                  movie = keyword_set(movies)

              ;;==Make plots in the plane perpendicular to B
              if ~keyword_set(movies) then begin
                 if strcmp(info.planes[ip],info.perp_to_B) then begin
                    image_string = plane_string
                    basename = info.filepath+path_sep()+'efield_means-P'+image_string
                    mean_field_plots, xdata,ydata,scale*Ex,scale*Ey,basename=basename
                 endif ;;--perp_to_B
              endif    ;;--movies
           endif       ;;--phi           
        endfor         ;;--planes
     endif $           ;;--n_dims
     else print, "[EPPIC_SPATIAL_ANALYSIS] Could not create an image."

  endfor ;;--data_names

end
