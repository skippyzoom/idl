;+
; Swap the extension on a file. This routine 
; calls the IDL function file_basename to 
; extract the file name up to old_ext, then 
; adds new_ext.
;-
function swap_extension, filename,old_ext,new_ext
  return, file_basename(filename,old_ext)+new_ext
end
