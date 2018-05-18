function interp_xy2kt_rms, data, $
                           lun=lun, $
                           lambda=lambda, $
                           _EXTRA=ex

  ;;==Default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Get data dimensions
  dsize = size(data)
  ndims = dsize[0]
  nkx = dsize[1]
  nky = dsize[2]
  nt = dsize[3]

  ;;==Get number of wavelengths
  nl = n_elements(lambda)

  ;;==Set up the output hash
  rms_xy2kt = hash()

  ;;==Loop over wavelengths
  for il=0,nl-1 do begin

     ;;==Create hash key
     l_val = lambda[il]
     str_lam = string(l_val,format='(f06.2)')
     str_lam = strcompress(str_lam,/remove_all)

     ;;==Calculate the interpolated power
     xy2kt = interp_xy2kt(data, $
                          lambda = lambda[il], $
                          /array, $
                          nkx = nkx, $
                          nky = nky, $
                          _EXTRA = ex)

     ;;==Store in hash
     rms_xy2kt[str_lam] = rms(xy2kt,dim=1)

  endfor

  ;;==Return hash
  return, rms_xy2kt

end
