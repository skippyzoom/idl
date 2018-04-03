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
  tmp = fdata
  fdata = make_array(nkx,nky,nt,type=6,value=0)
  fdata[0:nx-1,0:ny-1,*] = tmp
  tmp = !NULL

  ;;==Calculate spatial FFT of density
  for it=0,nt-1 do $
     fdata[*,*,it] = fft(fdata[*,*,it],/overwrite,/center)

  ;;==Manipulate data
  fdata = abs(fdata)
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

  ;;==Make movie(s)
  data_graphics, fdata,xdata,ydata, $
                 name, $
                 time = time, $
                 movie_path = path+path_sep()+'movies', $
                 movie_name = name+'_fft', $
                 movie_type = '.pdf', $
                 context = 'spectral'

end
