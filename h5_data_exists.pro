;+
; Check for existence of a data set within an HDF5 file
;-
function h5_data_exists, fname,dname

  h5_struct = h5_parse(fname)
  !NULL = where(strcmp(tag_names(h5_struct),dname,/fold_case),count)

  return, (count gt 0)
end
