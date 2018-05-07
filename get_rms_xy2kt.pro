function get_rms_xy2kt, data, $
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

  ;;==Set up the ouput array
  nl = n_elements(lambda)
  rms_xy2kt = fltarr(nl,nt)

  ;;==Loop over wavelengths
  for il=0,nl-1 do begin

     ;;==Calculate the interpolated power
     xy2kt = interp_xy2kt(data, $
                          lambda = lambda[il], $
                          /array, $
                          nkx = nkx, $
                          nky = nky, $
                          _EXTRA = ex)

     ;;==Calculate the RMS interpolated power
     for it=0,nt-1 do rms_xy2kt[il,it] = rms(xy2kt[*,it])
  endfor

  return, rms_xy2kt
end
