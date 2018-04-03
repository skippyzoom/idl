pro fft_images, fdata,name, $
                time=time, $
                path=path, $
                nkx=nkx, $
                nky=nky, $
                dx=dx, $
                dy=dy

  ;;==Get dimensions of input array
  fsize = size(fdata)
  nx = fsize[1]
  ny = fsize[2]
  nt = fsize[3]

  ;;==Defaults and guards
  if n_elements(time) eq 0 then time = dictionary()
  if ~isa(time,'dictionary') then time = dictionary(time)
  if ~time.haskey('index') then time['index'] = 0
  if n_elements(path) eq 0 then path = './'
  if n_elements(nkx) eq 0 then nkx = nx
  if n_elements(nky) eq 0 then nky = ny
  if n_elements(dx) eq 0 then dx = 1.0
  if n_elements(dy) eq 0 then dy = 1.0

  ;;==Set up spectral array
  ;; tmp = fdata
  ;; fdata = make_array(nkx,nky,nt,type=6,value=0)
  ;; fdata[0:nx-1,0:ny-1,*] = tmp
  ;; tmp = !NULL
  fftarr = make_array(nkx,nky,nt,type=6,value=0)
  fftarr[0:nx-1,0:ny-1,*] = fdata

  ;;==Calculate spatial FFT of density
  ;; for it=0,nt-1 do $
  ;;    fdata[*,*,it] = fft(fdata[*,*,it],/overwrite,/center)
  for it=0,nt-1 do $
     fftarr[*,*,it] = fft(fftarr[*,*,it],/overwrite,/center)

  ;;==Condition data for (kx,ky,t) images
  fdata = abs(fftarr)
  dc_mask = 3
  fdata[nkx/2-dc_mask:nkx/2+dc_mask, $
        nky/2-dc_mask:nky/2+dc_mask,*] = min(fdata)
  fdata /= max(fdata)
  fdata = 10*alog10(fdata^2)

  ;;==Set up spectral x- and y-axis vectors
  xdata = 2*!pi*fftfreq(nkx,dx)
  xdata = shift(xdata,nkx/2)
  ydata = 2*!pi*fftfreq(nky,dy)
  ydata = shift(ydata,nky/2)

  ;;==Make frame(s)
  data_graphics, fdata,xdata,ydata, $
                 name, $
                 time = time, $
                 frame_path = path+path_sep()+'frames', $
                 frame_name = name+'_fft', $
                 frame_type = '.pdf', $
                 context = name+'_fft'

  ;; ;;==Interpolate to polar coordinates
  ;; l_val = 4.0
  ;; k_val = 2*!pi/l_val
  ;; kx_min = xdata[nkx/2+1]
  ;; ky_min = ydata[nky/2+1]
  ;; t_size = 8*fix(k_val/min([kx_min,ky_min]))
  ;; t_interp = !pi*dindgen(t_size)/t_size
  ;; x_interp = cos(t_interp)*k_val/kx_min + nkx/2
  ;; y_interp = sin(t_interp)*k_val/ky_min + nky/2
  ;; f_interp = fltarr(t_size,nt)
  ;; for it=0,nt-1 do $
  ;;    f_interp[*,it] = interpolate(fdata[*,*,it],x_interp,y_interp)

end
