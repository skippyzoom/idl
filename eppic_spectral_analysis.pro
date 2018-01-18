;+
; This routine makes images from EPPIC spectral data. 
;-
pro eppic_spectral_analysis, info,movies=movies,full_transform=full_transform

  ;;==Loop over requested data quantities
  for id=0,n_elements(info.data_names)-1 do begin

     ;;==Extract currect quantity name
     data_name = info.data_names[id]
     
     ;;==Read data
     if keyword_set(movies) || keyword_set(full_transform) then $
        data = (load_eppic_data(data_name,path=info.path))[data_name] $
     else $
        data = (load_eppic_data(data_name,path=info.path, $
                                timestep=info.timestep))[data_name]

     ;;==Check successful read
     data_is_spatial = 0B
     if size(data,/n_dim) eq 0 then begin

        ;;==Extract the name of the non-FT quantity
        pos = strpos(data_name,'ft')
        data_name = strmid(data_name,0,pos)+strmid(data_name,pos+2)

        ;;==Read data
        if keyword_set(movies) || keyword_set(full_transform) then $
           data = (load_eppic_data(data_name,path=info.path))[data_name] $
        else $
           data = (load_eppic_data(data_name,path=info.path, $
                                   timestep=info.timestep))[data_name]

        ;;==Check successful read
        data_is_spatial = (size(data,/n_dim) ne 0) ? 1B : 0B

     endif
     
     ;;==Get data size and dimensions
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
           perp_to_B = 'xy'
        endif

        ;;==Transpose data
        xyzt = info.xyz
        tmp = indgen(n_dims)
        n_xyzt = n_elements(xyzt)
        if n_xyzt lt 4 then xyzt = [xyzt,tmp[n_xyzt,*]]
        data = transpose(data,xyzt)

        ;;==Get new dimensions
        data_size = size(data)
        nz = data_size[3]
        ny = data_size[2]
        nx = data_size[1]

        ;;==Loop over 2-D image planes
        for ip=0,n_elements(info.planes)-1 do begin

           ;;==Set up 2-D image
           case 1B of 
              strcmp(info.planes[ip],'xy') || strcmp(info.planes[ip],'yx'): begin
                 imgplane = reform(data[*,*,info.zctr,*])
                 xdata = (2*!pi/(info.xdif*nx))*(findgen(nx)-0.5*nx)
                 ydata = (2*!pi/(info.ydif*ny))*(findgen(ny)-0.5*ny)
                 xrng = info.xrng
                 yrng = info.yrng
              end
              strcmp(info.planes[ip],'xz') || strcmp(info.planes[ip],'zx'): begin
                 imgplane = reform(data[*,info.yctr,*,*])
                 xdata = (2*!pi/(info.xdif*nx))*(findgen(nx)-0.5*nx)
                 ydata = (2*!pi/(info.zdif*nz))*(findgen(nz)-0.5*nz)
                 xrng = info.xrng
                 yrng = info.zrng
              end
              strcmp(info.planes[ip],'yz') || strcmp(info.planes[ip],'zy'): begin
                 imgplane = reform(data[info.xctr,*,*,*])
                 xdata = (2*!pi/(info.ydif*ny))*(findgen(ny)-0.5*ny)
                 ydata = (2*!pi/(info.zdif*nz))*(findgen(nz)-0.5*nz)
                 xrng = info.yrng
                 yrng = info.zrng
              end
           endcase

           ;;==Save string for filenames
           if data_is_2D then plane_string = '' $
           else plane_string = '_'+info.planes[ip]

           ;;==Transform spatial data at each time step
           if data_is_spatial then begin
              for it=0,nt-1 do begin
                 imgplane[*,*,it] = fft(imgplane[*,*,it],/overwrite)
              endfor              
              data_name += 'fft'
           endif
           
           if keyword_set(full_transform) then begin

              ;;==Get new dimensions
              img_size = size(imgplane)
              nz = img_size[3]
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
              imgplane[nx/2-5:nx/2+5,ny/2-2:ny/2+2,nw/2] = 0.0
              ;;--Smooth
              imgplane = smooth(imgplane,[5,5,1],/edge_wrap)
              ;;--Normalize
              imgplane = imgplane/max(imgplane)
              ;;--Convert to dB
              imgplane = 10*alog10(imgplane)

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

              ;;==Create images of interpolated data
              basename = info.filepath+path_sep()+ $
                         data_name+'-ktw'+plane_string
              eppic_ktw_graphics, ktw,rtp,info, $
                                  lambda = [3.0,4.0,10.0], $
                                  basename = basename

           endif $
           else begin

              ;;==Set up data
              ;;--Extract the real part
              imgplane = real_part(imgplane)^2
              ;;--Recenter
              imgplane = shift(imgplane,nx/2,ny/2,0)
              ;;--Zero the near-DC components (crude high-pass filter)
              imgplane[nx/2-5:nx/2+5,ny/2-2:ny/2+2,*] = 0.0
              ;;--Smooth
              imgplane = smooth(imgplane,[5,5,1],/edge_wrap)
              ;;--Normalize
              imgplane = imgplane/max(imgplane)
              ;;--Convert to dB
              imgplane = 10*alog10(imgplane)

              ;;==Create images of Fourier-transformed data
              basename = info.filepath+path_sep()+ $
                         data_name+plane_string
              eppic_xyt_graphics, imgplane,xdata,ydata, $
                                  info, $
                                  xrng = xrng, $
                                  yrng = yrng, $
                                  xrange = [-2*!pi,2*!pi], $
                                  yrange = [0,2*!pi], $
                                  rgb_table = 39, $
                                  min_value = max(imgplane,/nan)-30, $
                                  max_value = max(imgplane,/nan), $
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
              ;; aspect_ratio = float(n_elements(rtp.r_vals))/n_elements(rtp.t_vals)
              aspect_ratio = (rtp.r_vals[nk-1]-rtp.r_vals[0])/(rtp.t_vals[n_theta-1]-rtp.t_vals[0])
              eppic_xyt_graphics, ktt,rtp.r_vals,rtp.t_vals, $
                                  info, $
                                  aspect_ratio = aspect_ratio, $
                                  rgb_table = 39, $
                                  min_value = max(imgplane,/nan)-30, $
                                  max_value = max(imgplane,/nan), $
                                  basename = basename, $
                                  /clip_y_axes, $
                                  colorbar_title = "Power [dB]", $
                                  dimensions = [1000,1000], $
                                  expand = 1, $
                                  rescale = 1.0, $
                                  movie = keyword_set(movies)

           endelse

        endfor   ;;--planes
     endif $     ;;--n_dims
     else print, "[EPPIC_SPECTRAL_ANALYSIS] Could not create an image."

  endfor ;;--data_names


end
