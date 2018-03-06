;+
; Spectral graphics of EPPIC data
;-
pro eppic_spectral_graphics, imgplane,info

  ;;==Get image sizes
  imgsize = size(imgplane.f)
  nx = imgsize[1]
  ny = imgsize[2]
  nt = imgsize[3]

  ;;==Transform spatial data at each time step
  if strcmp(info.data_context,'spatial') then begin
     for it=0,nt-1 do begin
        tmp = imgplane.f
        tmp[*,*,it] = fft(tmp[*,*,it],/overwrite)
        imgplane.f = tmp
        tmp = !NULL
     endfor              
     info.image_name += '-fft'
  endif

  if info.full_transform then begin

     ;;==Get new dimensions
     imgsize = size(imgplane.f)
     ny = imgsize[2]
     nx = imgsize[1]

     ;;==Transform the time dimension
     nw = next_power2(nt)
     tmp = make_array(nx,ny,nw,type=6,value=0.0)
     tmp[*,*,0:nt-1] = imgplane.f
     tmp = fft(tmp,dim=3)
     imgplane.f = tmp
     tmp = !NULL

     ;;==Set up data
     ;;--Extract the real part
     imgplane.f = real_part(imgplane.f)^2
     ;;--Recenter
     imgplane.f = shift(imgplane.f,nx/2,ny/2,nw/2)
     imgplane.x -= imgplane.dx*nx/2
     imgplane.y -= imgplane.dy*ny/2
     ;;--Zero the near-DC components (crude high-pass filter)
     dc_width = info.dc_width
     tmp = imgplane.f
     tmp[nx/2-dc_width:nx/2+dc_width, $
         ny/2-dc_width:ny/2+dc_width,*] = 0.0
     imgplane.f = tmp
     tmp = !NULL
     ;;--Smooth
     fft_smooth = info.fft_smooth
     if fft_smooth gt 1 then $
        imgplane.f = smooth(imgplane.f,[fft_smooth,fft_smooth,1],/edge_wrap)
     ;;--Normalize
     imgplane.f = imgplane.f/max(imgplane.f)
     ;;--Convert to dB
     imgplane.f = 10*alog10(imgplane.f)
     ;;--Set non-finite values to a finite 'missing' value
     tmp = imgplane.f
     tmp[where(finite(imgplane.f) eq 0)] = info.missing
     imgplane.f = tmp
     tmp = !NULL

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
                info.image_name+'-ktw'+info.plane_string
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
                info.image_name+'_w'+info.plane_string
     min_value = max(imgplane.f,/nan)-30
     max_value = max(imgplane.f,/nan)
     k_range = [0,2*!pi]
     max_abs_nu = max(abs(reform(info.moments.dist1.nu[0,nt/2:*])))
     w_range = 0.5*[-max_abs_nu,+max_abs_nu]
     aspect_ratio = (k_range[1]-k_range[0])/ $
                    (w_range[1]-w_range[0])
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
     imgplane.x -= imgplane.dx*nx/2
     imgplane.y -= imgplane.dy*ny/2
     ;;--Zero the near-DC components (crude high-pass filter)
     dc_width = info.dc_width
     tmp = imgplane.f
     tmp[nx/2-dc_width:nx/2+dc_width, $
         ny/2-dc_width:ny/2+dc_width,*] = 0.0
     imgplane.f = tmp
     tmp = !NULL
     ;;--Smooth
     fft_smooth = info.fft_smooth
     if fft_smooth gt 1 then $
        imgplane.f = smooth(imgplane.f,[fft_smooth,fft_smooth,1],/edge_wrap)
     ;;--Normalize
     imgplane.f = imgplane.f/max(imgplane.f)
     ;;--Convert to dB
     imgplane.f = 10*alog10(imgplane.f)
     ;;--Set non-finite values to a finite 'missing' value
     tmp = imgplane.f
     tmp[where(finite(imgplane.f) eq 0)] = info.missing
     imgplane.f = tmp
     tmp = !NULL

     ;;==Create images of Fourier-transformed data
     basename = info.filepath+path_sep()+ $
                info.image_name+'_t'+info.plane_string
     min_value = max(imgplane.f,/nan)-30
     max_value = max(imgplane.f,/nan)
     eppic_xyt_graphics, imgplane.f,imgplane.x,imgplane.y, $
                         info, $
                         xrng = imgplane.xr, $
                         yrng = imgplane.yr, $
                         xrange = [-10*!pi,10*!pi], $
                         ;; yrange = [0,2*!pi], $
                         yrange = [-10*!pi,10*!pi], $
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
                info.image_name+'-ktt'+info.plane_string
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

end
