;+
; Crude high-pass FFT filter for 2-D or 3-D data. 
;
; This function computes the FFT of real data, centers the spectrum,
; zeroes a rectangle centered on DC and bounded by 2*!pi/lambda_max,
; computes the inverse FFT, and returns the filtered array.
;
; Created by Matt Young
;------------------------------------------------------------------------------
; **Output fdata is not positive definite when input fdata is. That
; seems like a serious error. In any case, it makes this function
; useless for EPPIC nvsqr arrays.**
;-
function high_pass_filter, fdata, $
                           lambda_max, $
                           lun=lun, $
                           dx=dx, $
                           dy=dy, $
                           dz=dz

  if n_elements(lun) eq 0 then lun = -1

  if n_elements(dx) eq 0 then dx = 1.0
  if n_elements(dy) eq 0 then dy = 1.0
  if n_elements(dz) eq 0 then dz = 1.0

  fsize = size(fdata)
  ndims = fsize[0]
  nx = fsize[1]
  ny = fsize[2]
  nz = (ndims gt 3) ? fsize[3] : 1

  kxdata = 2*!pi*fftfreq(nx,dx)
  kxdata = shift(kxdata,nx/2)
  kydata = 2*!pi*fftfreq(ny,dy)
  kydata = shift(kydata,ny/2)
  if nz gt 1 then begin
     kzdata = 2*!pi*fftfreq(nz,dz)
     kzdata = shift(kzdata,nz/2)
  endif

  dkx = find_closest(kxdata,2*!pi/lambda_max) - nx/2
  dky = find_closest(kydata,2*!pi/lambda_max) - ny/2
  dkz = (ndims gt 3) ? $
        find_closest(kzdata,2*!pi/lambda_max) - nz/2 : 0

  fftdata = fft(fdata,/center)
  fftdata[nx/2-dkx:nx/2+dkx, $
          ny/2-dky:ny/2+dky, $
          nz/2-dkz:nz/2+dkz] = 0.0
  fdata = fft(fftdata,/inverse,/center)
  fdata = real_part(fdata)

  return, fdata
end
