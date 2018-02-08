;+
; This routine makes images from EPPIC spectral data. 
;-
pro eppic_spectral_analysis, info,movies=movies,full_transform=full_transform

  ;;==Loop over requested data quantities
  for id=0,n_elements(info.data_names)-1 do begin

     ;;==Extract currect quantity name
     data_name = info.data_names[id]

     ;;==Loop over 2-D image planes
     for ip=0,n_elements(info.planes)-1 do begin

        ;;==Read 2-D image data
        if keyword_set(movies) then timestep = lindgen(nt_max) $
        else timestep = info.timestep
        imgplane = read_ph5_plane(data_name, $
                                  ext = '.h5', $
                                  timestep = timestep, $
                                  plane = info.planes[ip], $
                                  type = 6, $
                                  /eppic_ft_data, $
                                  path = expand_path(info.path+path_sep()+'parallel'), $
                                  /verbose)

        ;;==Check successful read
        using_spatial_data = 0B
        if size(data,/n_dim) eq 0 then begin

           ;;==Extract the name of the non-FT quantity
           pos = strpos(data_name,'ft')
           data_name = strmid(data_name,0,pos)+strmid(data_name,pos+2)

           imgplane = read_ph5_plane(data_name, $
                                     ext = '.h5', $
                                     timestep = timestep, $
                                     plane = info.planes[ip], $
                                     type = 4, $
                                     path = expand_path(info.path+path_sep()+'parallel'), $
                                     /verbose)

           ;;==Check successful read
           using_spatial_data = (size(data,/n_dim) ne 0) ? 1B : 0B

        endif

        ;;==Check dimensions
        imgsize = size(imgplane)
        n_dims = imgsize[0]
        if n_dims eq 3 then begin
           nx = imgsize[1]
           ny = imgsize[2]
           nt = imgsize[3]

           ;;==Set up 2-D auxiliary data
           pl_ctx = build_plane_context(info, $
                                        plane = info.planes[ip], $
                                        context = 'spectral')
STOP
           ;;==Save string for filenames
           if info.params.ndim_space eq 2 then plane_string = '' $
           else plane_string = '_'+info.planes[ip]

           ;;==Transform spatial data at each time step
           if using_spatial_data then begin
              for it=0,nt-1 do begin
                 imgplane[*,*,it] = fft(imgplane[*,*,it],/overwrite)
              endfor              
              data_name += 'fft'
           endif
           
           if keyword_set(full_transform) then begin

              ;;==Get new dimensions
              img_size = size(imgplane)
              ny = img_size[2]
              nx = img_size[1]

              ;;==Transform the time dimension
              nw = next_power2(nt)
              temp = make_array(nx,ny,nw,type=6,value=0.0)
              temp[*,*,0:nt-1] = imgplane
              imgplane = fft(temp,dim=3)
              temp = !NULL

              ;;==Set up data
              ;;--Extract the real part
              imgplane = real_part(imgplane)^2
              ;;--Recenter
              imgplane = shift(imgplane,nx/2,ny/2,nw/2)
              ;;--Zero the near-DC components (crude high-pass filter)
              dc_width = 8
              imgplane[nx/2-dc_width:nx/2+dc_width, $
                       ny/2-dc_width:ny/2+dc_width,*] = 0.0
              ;;--Smooth
              imgplane = smooth(imgplane,[5,5,1],/edge_wrap)
              ;;--Normalize
              imgplane = imgplane/max(imgplane)
              ;;--Convert to dB
              imgplane = 10*alog10(imgplane)
              ;;--Set non-finite values to a finite 'missing' value
              imgplane[where(finite(imgplane) eq 0)] = -1e10

              ;;==Interpolate
              theta_range = [0,360]
              rtp = xyz_rtp(imgplane[*,*,0],dx=info.xdif,dy=info.ydif, $
                            theta_range = theta_range)
              nk = n_elements(rtp.r_vals)
              n_theta = n_elements(rtp.t_vals)
              ktw = fltarr(nk,n_theta,nw)
              for iw=0,nw-1 do begin
                 rtp = xyz_rtp(imgplane[*,*,iw],dx=info.xdif,dy=info.ydif, $
                               theta_range = theta_range)
                 ktw[*,*,iw] = rtp.data
              endfor

              ;;==Build vector of frequencies
              w_max = 2*!pi/(info.params.dt*info.params.nout)
              w_vals = w_max*(dindgen(nw)/nw-0.5)
              rtp['w_vals'] = w_vals

              ;;==Create images of interpolated data
              th_range = [0,180]
              v_ExB = abs(info.params.Ex0_external/info.params.Bz)
              vp_range = [-3*v_ExB,+3*v_ExB]
              aspect_ratio = (th_range[1]-th_range[0])/ $
                             (vp_range[1]-vp_range[0])
              ;; aspect_ratio *= 1.2
              basename = info.filepath+path_sep()+ $
                         data_name+'-ktw'+plane_string
              eppic_ktw_graphics, ktw,rtp,info, $
                                  lambda = [3.0,4.0,10.0], $
                                  yrange = vp_range, $
                                  xrange = th_range, $
                                  aspect_ratio = aspect_ratio, $
                                  min_value = -30, $
                                  max_value = 0, $
                                  basename = basename


              ;;==Create images of Fourier-transformed data
              basename = info.filepath+path_sep()+ $
                         data_name+'_w'+plane_string
              min_value = max(imgplane,/nan)-30
              max_value = max(imgplane,/nan)
              k_range = [0,2*!pi]
              max_abs_nu = max(abs(reform(info.moments.dist1.nu[0,nt/2:*])))
              w_range = 0.5*[-max_abs_nu,+max_abs_nu]
              aspect_ratio = (k_range[1]-k_range[0])/ $
                             (w_range[1]-w_range[0])
              eppic_xyw_graphics, imgplane,xdata,ydata, $
                                  w_vals, $
                                  info, $
                                  xrng = xrng, $
                                  yrng = yrng, $
                                  xrange = k_range, $
                                  yrange = w_range, $
                                  rgb_table = 39, $
                                  aspect_ratio = aspect_ratio, $
                                  min_value = min_value, $
                                  max_value = max_value, $
                                  basename = basename, $
                                  colorbar_title = "Power [dB]", $
                                  center = [nx/2,ny/2]

           endif $
           else begin

              ;;==Get new dimensions
              img_size = size(imgplane)
              ny = img_size[2]
              nx = img_size[1]

              ;;==Set up data
              ;;--Extract the real part
              imgplane = real_part(imgplane)^2
              ;;--Recenter
              imgplane = shift(imgplane,nx/2,ny/2,0)
              ;;--Zero the near-DC components (crude high-pass filter)
              dc_width = 8
              imgplane[nx/2-dc_width:nx/2+dc_width, $
                       ny/2-dc_width:ny/2+dc_width,*] = 0.0
              ;;--Smooth
              s_width = 3
              if s_width gt 1 then $
                 imgplane = smooth(imgplane,[s_width,s_width,1],/edge_wrap)
              ;;--Normalize
              imgplane = imgplane/max(imgplane)
              ;;--Convert to dB
              imgplane = 10*alog10(imgplane)
              ;;--Set non-finite values to a finite 'missing' value
              imgplane[where(finite(imgplane) eq 0)] = -1e10

              ;;==Create images of Fourier-transformed data
              basename = info.filepath+path_sep()+ $
                         data_name+'_t'+plane_string
              min_value = max(imgplane,/nan)-30
              max_value = max(imgplane,/nan)
              eppic_xyt_graphics, imgplane,xdata,ydata, $
                                  info, $
                                  xrng = xrng, $
                                  yrng = yrng, $
                                  xrange = [-2*!pi,2*!pi], $
                                  yrange = [0,2*!pi], $
                                  rgb_table = 39, $
                                  min_value = min_value, $
                                  max_value = max_value, $
                                  basename = basename, $
                                  dimensions = [nx/2,ny], $
                                  /clip_y_axes, $
                                  colorbar_title = "Power [dB]", $
                                  expand = 3, $
                                  rescale = 0.8, $
                                  movie = keyword_set(movies)

              ;;==Interpolate
              theta_range = [0,180]
              rtp = xyz_rtp(imgplane[*,*,0],dx=info.xdif,dy=info.ydif, $
                            theta_range = theta_range)
              nk = n_elements(rtp.r_vals)
              n_theta = n_elements(rtp.t_vals)
              ktt = fltarr(nk,n_theta,nt)
              for it=0,nt-1 do begin
                 rtp = xyz_rtp(imgplane[*,*,it],dx=info.xdif,dy=info.ydif, $
                               theta_range = theta_range)
                 ktt[*,*,it] = rtp.data
              endfor

              ;;==Create images of interpolated data
              basename = info.filepath+path_sep()+ $
                         data_name+'-ktt'+plane_string
              aspect_ratio = (rtp.r_vals[nk-1]-rtp.r_vals[0])/ $
                             (rtp.t_vals[n_theta-1]-rtp.t_vals[0])
              min_value = max(imgplane,/nan)-30
              max_value = max(imgplane,/nan)
              eppic_xyt_graphics, ktt,rtp.r_vals,rtp.t_vals, $
                                  info, $
                                  aspect_ratio = aspect_ratio, $
                                  rgb_table = 39, $
                                  min_value = min_value, $
                                  max_value = max_value, $
                                  basename = basename, $
                                  /clip_y_axes, $
                                  colorbar_title = "Power [dB]", $
                                  ;; dimensions = [1000,1000], $
                                  expand = 1, $
                                  rescale = 0.8, $
                                  movie = keyword_set(movies)

           endelse

        endif $           ;;--n_dims
        else begin
           print, "[EPPIC_SPECTRAL_ANALYSIS] Could not create an image."
           print, "                          data_name = ",data_name
           print, "                          plane = ",info.planes[ip]
        endelse
     endfor            ;;--planes

     ;;==Free memory
     imgplane = !NULL

  endfor ;;--data_names


end
