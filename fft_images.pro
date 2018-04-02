pro fft_images, fdata,data_name,time,path,nkx,nky,dx,dy

  ;;==Get dimensions of input array
  fsize = size(fdata)
  nx = fsize[1]
  ny = fsize[2]
  nt = fsize[3]

  ;;==Set up spectral array
  ;;  (nkx & nky may differ from nx & ny for padding)
  ;; nkx = nx
  ;; nky = ny
  tmp = fdata
  fdata = make_array(nkx,nky,nt,type=6,value=0)
  fdata[0:nx-1,0:ny-1,*] = tmp
  tmp = !NULL

  ;;==Calculate spatial FFT of density
  for it=0,nt-1 do $
     fdata[*,*,it] = fft(fdata[*,*,it],/overwrite,/center)

  ;;==Get size of spectral array
  ;;  (covers padded and unpadded cases)
  fsize = size(fdata)
  ;; nkx = fsize[1]
  ;; nky = fsize[2]

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

  ;;==Make frame(s)
  data_graphics, fdata,xdata,ydata, $
                 data_name, $
                 time = time, $
                 frame_path = path+path_sep()+'frames', $
                 frame_name = data_name+'_fft', $
                 frame_type = '.pdf', $
                 context = 'spectral'

end
