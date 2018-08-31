function build_multirun_spatial_rms, mr_hash, $
                                     data_name, $
                                     lun=lun, $
                                     run=run, $
                                     ranges=ranges

  ;;==Set default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Get available runs
  all_runs = mr_hash.keys()

  ;;==Sort runs into ascending order
  all_runs = all_runs.sort()

  ;;==Set default runs
  if n_elements(run) eq 0 then run = all_runs

  ;;==Get number of runs
  nr = n_elements(run)

  ;;==Get dimensions
  prototype = (mr_hash[run[0]])[data_name]
  fsize = size(prototype)
  nx = fsize[1]
  ny = fsize[2]
  nz = (fsize[0] eq 4) ? fsize[3] : 1
  nt = fsize[fsize[0]]

  ;;==Set default ranges
  if n_elements(ranges) eq 0 then ranges = [0,nx,0,ny,0,nz]
  if n_elements(ranges) eq 4 then ranges = [ranges,0,nz]

  ;;==Set up array
  mr_rms = make_array(nt,nr, $
                      type = size(prototype,/type), $
                      /nozero)

  ;;==Loop over all runs
  for ir=0,nr-1 do begin
     this = (mr_hash[run[ir]])[data_name]
     if fsize[0] eq 3 then this = reform(this,[nx,ny,1,nt])
     for it=0,nt-1 do begin
        mr_rms[it,ir] = rms(this[ranges[0]:ranges[1]-1, $
                                 ranges[2]:ranges[3]-1, $
                                 ranges[4]:ranges[5]-1, $
                                 it])
     endfor
  endfor

  return, mr_rms
end
