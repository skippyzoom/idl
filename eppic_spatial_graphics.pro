;+
; Spatial graphics of EPPIC data
;-
pro eppic_spatial_graphics, imgplane,info

  ;;==Get image sizes
  imgsize = size(imgplane.f)
  nx = imgsize[1]
  ny = imgsize[2]
  nt = imgsize[3]

  ;;==Initialize string for descriptive image names
  image_string = ''

  ;;==Transform spectral data at each time step
  if strcmp(info.data_context,'spectral') then begin
     for it=0,nt-1 do begin
        tmp = imgplane.f
        tmp[*,*,it] = fft(tmp[*,*,it],/overwrite,/inverse)
        imgplane.f = tmp
        tmp = !NULL
     endfor              
     image_string += '-ift'
  endif

  ;;==Append plane to image string
  ;; image_string += info.plane_string

  ;;==Create graphics of densities
  if strcmp(info.current_name,'den',3) then begin
     n0 = info.params['n0d'+strmid(info.current_name,3)]
     imgplane.f = smooth(imgplane.f,[3,3,1],/edge_wrap)
     scale = 100
     basename = info.filepath+path_sep()+ $
                info.image_name+image_string+info.plane_string
     ;; min_value = -max(abs(scale*imgplane.f))
     ;; max_value = +max(abs(scale*imgplane.f))
     min_value = -6
     max_value = +6
     eppic_xyt_graphics, scale*imgplane.f,imgplane.x,imgplane.y, $
                         info, $
                         lun = info.wlun, $
                         xrng = imgplane.xr, $
                         yrng = imgplane.yr, $
                         rgb_table = 74, $
                         min_value = min_value, $
                         max_value = max_value, $
                         basename = basename, $
                         /clip_y_axes, $
                         colorbar_title = "$\delta n/n_0$ [%]",$
                         expand = 3, $
                         rescale = 0.8, $
                         movie = info.movies

     if ~info.movies then begin
        if strcmp(info.current_plane,info.perp_to_B) then begin
           image_string = info.plane_string
           basename = info.filepath+path_sep()+ $
                      info.image_name+image_string+'_rms'+info.plane_string
           mean_field_plots, imgplane.x,imgplane.y, $
                             scale*imgplane.f,scale*n0*(1+imgplane.f), $
                             info, $
                             lun = info.wlun, $
                             rms = [0,0,1,1], $
                             basename = basename
        endif       ;;--perp_to_B
     endif          ;;--(not)movies
  endif

  if strcmp(info.current_name,'phi') then begin

     ;;==Create graphics of electrostatic potential
     scale = 1e3
     ;; image_string = info.plane_string
     ct = get_custom_ct(1)
     basename = info.filepath+path_sep()+ $
                info.image_name+image_string+info.plane_string
     min_value = -max(abs(scale*imgplane.f[*,*,1:*]))
     max_value = +max(abs(scale*imgplane.f[*,*,1:*]))
     ;; min_value = -600
     ;; max_value = +600
     eppic_xyt_graphics, scale*imgplane.f,imgplane.x,imgplane.y, $
                         info, $
                         lun = info.wlun, $
                         xrng = imgplane.xr, $
                         yrng = imgplane.yr, $
                         rgb_table = 70, $
                         min_value = min_value, $
                         max_value = max_value, $
                         basename = basename, $
                         /clip_y_axes, $
                         colorbar_title = "$\phi$ [mV]",$
                         expand = 3, $
                         rescale = 0.8, $
                         movie = info.movies

     ;;==Calculate E-field components
     Ex = fltarr(size(imgplane.f,/dim))
     Ey = fltarr(size(imgplane.f,/dim))
     for it=0,nt-1 do begin
        gradf = gradient(imgplane.f[*,*,it], $
                         dx = imgplane.dx*info.params.nout_avg, $
                         dy = imgplane.dy*info.params.nout_avg)
        Ex[*,*,it] = -1.0*gradf.x
        Ey[*,*,it] = -1.0*gradf.y
     endfor              

     ;;==Create images for perturbed and full field
     field_type = list('pert','full')
     n_types = field_type.count()
     for ii=0,n_types-1 do begin

        ;;==Add background field, if requested
        field_string = '-P'
        add_E0 = strcmp(field_type[ii],'full')
        if add_E0 then begin
           Ex += imgplane.E0[0]
           Ey += imgplane.E0[1]
           field_string = '-F'
        endif

        ;;==Construct magnitude and angle
        Er = sqrt(Ex^2 + Ey^2)
        Et = atan(Ey,Ex)

        ;;==Smooth E-field components
        s_width = 1
        if s_width gt 1 then begin
           Ex = smooth(Ex,[s_width,s_width,1],/edge_wrap)
           Ey = smooth(Ey,[s_width,s_width,1],/edge_wrap)
           Er = smooth(Er,[s_width,s_width,1],/edge_wrap)
           Et = smooth(Et,[s_width,s_width,1],/edge_wrap)
           image_string = info.plane_string+'-sw'+ $
                          strcompress(s_width,/remove_all)
        endif

        ;;==Create graphics of electric field
        scale = 1e3
        basename = info.filepath+path_sep()+ $
                   'efield'+field_string+'_x'+image_string+info.plane_string
        min_value = -max(abs(scale*Ex[*,*,1:*]))
        max_value = +max(abs(scale*Ex[*,*,1:*]))
        ;; min_value = -24
        ;; max_value = +24
        colorbar_title = strcmp(field_type[ii],'full') ? $
                         "$E_x$ [mV/m]" : "$\delta E_x$ [mV/m]"
        eppic_xyt_graphics, scale*Ex,imgplane.x,imgplane.y, $
                            info, $
                            lun = info.wlun, $
                            xrng = imgplane.xr, $
                            yrng = imgplane.yr, $
                            rgb_table = 70, $
                            min_value = min_value, $
                            max_value = max_value, $
                            basename = basename, $
                            /clip_y_axes, $
                            colorbar_title = colorbar_title,$
                            expand = 3, $
                            rescale = 0.8, $
                            movie = info.movies
        basename = info.filepath+path_sep()+ $
                   'efield'+field_string+'_y'+image_string+info.plane_string
        min_value = -max(abs(scale*Ey[*,*,1:*]))
        max_value = +max(abs(scale*Ey[*,*,1:*]))
        ;; min_value = -24
        ;; max_value = +24
        colorbar_title = strcmp(field_type[ii],'full') ? $
                         "$E_y$ [mV/m]" : "$\delta E_y$ [mV/m]"
        eppic_xyt_graphics, scale*Ey,imgplane.x,imgplane.y, $
                            info, $
                            lun = info.wlun, $
                            xrng = imgplane.xr, $
                            yrng = imgplane.yr, $
                            rgb_table = 70, $
                            min_value = min_value, $
                            max_value = max_value, $
                            basename = basename, $
                            /clip_y_axes, $
                            colorbar_title = colorbar_title,$
                            expand = 3, $
                            rescale = 0.8, $
                            movie = info.movies
        basename = info.filepath+path_sep()+ $
                   'efield'+field_string+'_r'+image_string+info.plane_string
        min_value = 0
        ;; max_value = max(scale*Er[*,*,1:*])
        max_value = 24
        colorbar_title = strcmp(field_type[ii],'full') ? $
                         "$|E|$ [mV/m]" : "$|\delta E|$ [mV/m]"
        eppic_xyt_graphics, scale*Er,imgplane.x,imgplane.y, $
                            info, $
                            lun = info.wlun, $
                            xrng = imgplane.xr, $
                            yrng = imgplane.yr, $
                            rgb_table = 3, $
                            min_value = min_value, $
                            max_value = max_value, $
                            basename = basename, $
                            /clip_y_axes, $
                            colorbar_title = colorbar_title, $
                            expand = 3, $
                            rescale = 0.8, $
                            movie = info.movies
        basename = info.filepath+path_sep()+ $
                   'efield'+field_string+'_t'+image_string+info.plane_string
        ct = get_custom_ct(2)
        min_value = -!pi
        max_value = +!pi
        colorbar_title = strcmp(field_type[ii],'full') ? $
                         "$\tan^{-1}(E)$ [rad]" : "$tan^{-1}(\delta E)$ [rad]"
        eppic_xyt_graphics, Et,imgplane.x,imgplane.y, $
                            info, $
                            lun = info.wlun, $
                            xrng = imgplane.xr, $
                            yrng = imgplane.yr, $
                            rgb_table = [[ct.r],[ct.g],[ct.b]], $
                            min_value = min_value, $
                            max_value = max_value, $
                            basename = basename, $
                            /clip_y_axes, $
                            colorbar_title = colorbar_title,$
                            expand = 3, $
                            rescale = 0.8, $
                            movie = info.movies

        ;;==Make plots in the plane perpendicular to B
        if ~info.movies then begin
           if strcmp(info.current_plane,info.perp_to_B) then begin
              image_string = info.plane_string
              basename = info.filepath+path_sep()+ $
                         'efield'+image_string+'_mean'+info.plane_string
              mean_field_plots, imgplane.x,imgplane.y, $
                                scale*Ex,scale*Ey, $
                                info, $
                                lun = info.wlun, $
                                basename = basename
           endif       ;;--perp_to_B
        endif          ;;--(not)movies
     endfor            ;;--field_type
  endif                ;;--phi           

end
