function build_kttrms, ktt, $
                       lun=lun, $
                       lambda=lambda

  ;;==Set default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Get available wavelengths
  all_lambdas = ktt.keys()

  ;;==Sort wavelengths into ascending order
  all_lambdas = all_lambdas.sort()

  ;;==Set lambda default
  if n_elements(lambda) eq 0 then lambda = all_lambdas

  ;;==Get number of wavelengths
  nl = n_elements(lambda)

  ;;==Get number of time steps
  nt = n_elements(ktt[all_lambdas[0]].f_interp)

  ;;==Loop over runs to build RMS hash
  kttrms = make_array(nt,value=0,/float)
  for il=0,nl-1 do $
     kttrms += rms(ktt[lambda[il]].f_interp,dim=1)

  return, kttrms
end
