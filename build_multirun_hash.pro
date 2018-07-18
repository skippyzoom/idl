;+
; Build a hash of hashes from multiple save files
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
function build_multirun_hash, proj_path, $
                              run, $
                              save_name, $
                              data_name, $
                              lun=lun

  ;;==Defaults
  if n_elements(lun) eq 0 then lun = -1

  ;;==Get number of runs
  nr = n_elements(run)

  ;;==Set up multi-run hash
  mr_hash = hash()
  
  ;;==Loop over runs
  for ir=0,nr-1 do begin
     path = expand_path(proj_path)+path_sep()+run[ir]
     filename = expand_path(path)+path_sep()+save_name
     s_obj = obj_new('IDL_Savefile',filename)
     s_name = s_obj->names()
     nn = n_elements(s_name)
     restore, filename
     dict = dictionary()
     for in=0,nn-1 do begin
        cmnd = 'tmp='+s_name[in]
        !NULL = execute(cmnd)
        dict[s_name[in]] = tmp
     endfor
     mr_hash[run[ir]] = dict
  endfor

  return, mr_hash
end
