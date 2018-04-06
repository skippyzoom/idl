;+
; Script for preparing spatial spectral data for graphics. This script
; leaves the raw (complex) FFT array unmodified so that future scripts
; can use it. 
;-

;;==Get dimensions of data array
fsize = size(fdata)
nx = fsize[1]
ny = fsize[2]
nt = fsize[3]

;;==Set up spectral array
if n_elements(nkx) eq 0 then nkx = nx
if n_elements(nky) eq 0 then nky = ny
fftarr = make_array(nkx,nky,nt,type=6,value=0)
fftarr[0:nx-1,0:ny-1,*] = fdata

;;==Calculate spatial FFT of density
for it=0,nt-1 do $
   fftarr[*,*,it] = fft(fftarr[*,*,it],/overwrite,/center)

;;==Condition data for (kx,ky,t) images
fdata = abs(fftarr)
dc_mask = 3
fdata[nkx/2-dc_mask:nkx/2+dc_mask, $
      nky/2-dc_mask:nky/2+dc_mask,*] = min(fdata)
fdata /= max(fdata)
fdata = 10*alog10(fdata^2)

;;==Set up kx and ky vectors for images
xdata = 2*!pi*fftfreq(nkx,dx)
xdata = shift(xdata,nkx/2)
ydata = 2*!pi*fftfreq(nky,dy)
ydata = shift(ydata,nky/2)
