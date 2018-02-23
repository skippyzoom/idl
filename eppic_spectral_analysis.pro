;+
; This routine makes images from EPPIC spectral data. 
;-
pro eppic_spectral_analysis, info, $
                             movies=movies, $
                             full_transform=full_transform, $
                             force_spatial_data=force_spatial_data

  ;;==Loop over requested data quantities
  for id=0,n_elements(info.data_names)-1 do begin

     ;;==Extract currect quantity name
     data_name = info.data_names[id]

     ;;==Loop over 2-D image planes
     for ip=0,n_elements(info.planes)-1 do begin

        ;;==Read 2-D image data
        if keyword_set(movies) || keyword_set(full_transform) then $
           timestep = lindgen(info.nt_max) $
        else $
           timestep = info.timestep

        ;; if ~keyword_set(force_spatial_data) then $
        ;;    data = read_ph5_plane(data_name, $
        ;;                          ext = '.h5', $
        ;;                          timestep = timestep, $
        ;;                          plane = info.planes[ip], $
        ;;                          type = 6, $
        ;;                          /eppic_ft_data, $
        ;;                          path = expand_path(info.path+path_sep()+'parallel'), $
        ;;                          /verbose)

        ;; ;;==Check successful read
        ;; using_spatial_data = 0B
        ;; if size(data,/n_dim) eq 0 then begin

        ;;    ;;==Extract the name of the non-FT quantity
        ;;    pos = strpos(data_name,'ft')
        ;;    data_name = strmid(data_name,0,pos)+strmid(data_name,pos+2)

        ;;    data = read_ph5_plane(data_name, $
        ;;                          ext = '.h5', $
        ;;                          timestep = timestep, $
        ;;                          plane = info.planes[ip], $
        ;;                          type = 4, $
        ;;                          path = expand_path(info.path+path_sep()+'parallel'), $
        ;;                          /verbose)

        ;;    ;;==Check successful read
        ;;    using_spatial_data = (size(data,/n_dim) ne 0) ? 1B : 0B

        ;; endif

        if keyword_set(force_spatial_data) then begin

           ;;==Read spatial data
           data = read_ph5_plane(data_name, $
                                 ext = '.h5', $
                                 timestep = timestep, $
                                 plane = info.planes[ip], $
                                 type = 4, $
                                 path = expand_path(info.path+path_sep()+'parallel'), $
                                 /verbose)

           ;;==Check successful read
           using_spatial_data = (size(data,/n_dim) ne 0) ? 1B : 0B

        endif $
        else begin

           ;;==Try to read EPPIC FT data
           data_name_in = data_name
           last_char = strmid(data_name,0,1,/reverse_offset)
           !NULL = where(strcmp(last_char,strcompress(sindgen(10),/remove_all)),count)
           if count eq 1 then $
              data_name = strmid(data_name,0,strlen(data_name)-1)+'ft'+last_char $
           else $
              data_name = data_name+'ft'
           data = read_ph5_plane(data_name, $
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

              ;;==Restore the name of the non-FT quantity
              data_name = data_name_in
              data = read_ph5_plane(data_name, $
                                    ext = '.h5', $
                                    timestep = timestep, $
                                    plane = info.planes[ip], $
                                    type = 4, $
                                    path = expand_path(info.path+path_sep()+'parallel'), $
                                    /verbose)

              ;;==Check successful read
              using_spatial_data = (size(data,/n_dim) ne 0) ? 1B : 0B

           endif
        endelse

STOP                            ; PROBLEM WITH FT DATA??
        ;;==Check dimensions
        imgsize = size(data)
        n_dims = imgsize[0]
        if n_dims eq 3 then begin
           nx = imgsize[1]
           ny = imgsize[2]
           nt = imgsize[3]

           ;;==Set up 2-D auxiliary data
           imgplane = build_imgplane(data,info, $
                                     plane = info.planes[ip], $
                                     context = 'spectral', $
                                     using_spatial_data = using_spatial_data)

           ;;==Save string for filenames
           if info.params.ndim_space eq 2 then plane_string = '' $
           else plane_string = '_'+info.planes[ip]
if keyword_set(full_transform) then STOP
           ;;==Transform spatial data at each time step
           if using_spatial_data then begin
              for it=0,nt-1 do begin
                 imgplane.f[*,*,it] = fft(imgplane.f[*,*,it],/overwrite)
              endfor              
              data_name += 'fft'
           endif

           if keyword_set(full_transform) then begin

              ;;==Get new dimensions
              img_size = size(imgplane.f)
              ny = img_size[2]
              nx = img_size[1]
STOP
              ;;==Transform the time dimension
              nw = next_power2(nt)
              tmp = make_array(nx,ny,nw,type=6,value=0.0)
              tmp[*,*,0:nt-1] = imgplane.f
              tmp = fft(tmp,dim=3)
              imgplane.f = tmp
              tmp = !NULL
STOP
              ;;==Set up data
              ;;--Extract the real part
              imgplane.f = real_part(imgplane.f)^2
STOP
              ;;--Recenter
              imgplane.f = shift(imgplane.f,nx/2,ny/2,nw/2)
STOP
              ;;--Zero the near-DC components (crude high-pass filter)
              dc_width = 8
              tmp = imgplane.f
              tmp[nx/2-dc_width:nx/2+dc_width, $
                  ny/2-dc_width:ny/2+dc_width,*] = 0.0
              imgplane.f = tmp
              tmp = !NULL
STOP
              ;;--Smooth
              imgplane.f = smooth(imgplane.f,[5,5,1],/edge_wrap)
STOP
              ;;--Normalize
              imgplane.f = imgplane.f/max(imgplane.f)
STOP
              ;;--Convert to dB
              imgplane.f = 10*alog10(imgplane.f)
STOP
              ;;--Set non-finite values to a finite 'missing' value
              tmp = imgplane.f
              tmp[where(finite(imgplane.f) eq 0)] = -1e10
              imgplane.f = tmp
              tmp = !NULL
STOP
              ;;==Interpolate
              theta_range = [0,360]
              rtp = xyz_rtp(imgplane.f[*,*,0],dx=imgplane.dx,dy=imgplane.dy, $
                            theta_range = theta_range)
              nk = n_elements(rtp.r_vals)
              n_theta = n_elements(rtp.t_vals)
              ktw = fltarr(nk,n_theta,nw)
              for iw=0,nw-1 do begin
                 rtp = xyz_rtp(imgplane.f[*,*,iw],dx=imgplane.dx,dy=imgplane.dy, $
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
STOP, "KTW"
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
              min_value = max(imgplane.f,/nan)-30
              max_value = max(imgplane.f,/nan)
              k_range = [0,2*!pi]
              max_abs_nu = max(abs(reform(info.moments.dist1.nu[0,nt/2:*])))
              w_range = 0.5*[-max_abs_nu,+max_abs_nu]
              aspect_ratio = (k_range[1]-k_range[0])/ $
                             (w_range[1]-w_range[0])
STOP, "XYW"
              eppic_xyw_graphics, imgplane.f,imgplane.x,imgplane.y, $
                                  w_vals, $
                                  info, $
                                  xrng = imgplane.xr, $
                                  yrng = imgplane.yr, $
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
              img_size = size(imgplane.f)
              ny = img_size[2]
              nx = img_size[1]

              ;;==Set up data
              ;;--Extract the real part
              imgplane.f = real_part(imgplane.f)^2
              ;;--Recenter
              imgplane.f = shift(imgplane.f,nx/2,ny/2,0)
              ;;--Zero the near-DC components (crude high-pass filter)
              dc_width = 8
              tmp = imgplane.f
              tmp[nx/2-dc_width:nx/2+dc_width, $
                  ny/2-dc_width:ny/2+dc_width,*] = 0.0
              imgplane.f = tmp
              tmp = !NULL
              ;;--Smooth
              s_width = 3
              if s_width gt 1 then $
                 imgplane.f = smooth(imgplane.f,[s_width,s_width,1],/edge_wrap)
              ;;--Normalize
              imgplane.f = imgplane.f/max(imgplane.f)
              ;;--Convert to dB
              imgplane.f = 10*alog10(imgplane.f)
              ;;--Set non-finite values to a finite 'missing' value
              tmp = imgplane.f
              tmp[where(finite(imgplane.f) eq 0)] = -1e10
              imgplane.f = tmp
              tmp = !NULL

              ;;==Create images of Fourier-transformed data
              basename = info.filepath+path_sep()+ $
                         data_name+'_t'+plane_string
              min_value = max(imgplane.f,/nan)-30
              max_value = max(imgplane.f,/nan)
              eppic_xyt_graphics, imgplane.f,imgplane.x,imgplane.y, $
                                  info, $
                                  xrng = imgplane.xr, $
                                  yrng = imgplane.yr, $
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
              rtp = xyz_rtp(imgplane.f[*,*,0],dx=imgplane.dx,dy=imgplane.dy, $
                            theta_range = theta_range)
              nk = n_elements(rtp.r_vals)
              n_theta = n_elements(rtp.t_vals)
              ktt = fltarr(nk,n_theta,nt)
              for it=0,nt-1 do begin
                 rtp = xyz_rtp(imgplane.f[*,*,it],dx=imgplane.dx,dy=imgplane.dy, $
                               theta_range = theta_range)
                 ktt[*,*,it] = rtp.data
              endfor

              ;;==Create images of interpolated data
              basename = info.filepath+path_sep()+ $
                         data_name+'-ktt'+plane_string
              aspect_ratio = (rtp.r_vals[nk-1]-rtp.r_vals[0])/ $
                             (rtp.t_vals[n_theta-1]-rtp.t_vals[0])
              min_value = max(imgplane.f,/nan)-30
              max_value = max(imgplane.f,/nan)
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
     imgplane.f = !NULL

  endfor ;;--data_names


end
