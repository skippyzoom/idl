;+
; Read requested data in requested format.
; Designed to accommodate additional formats.
; Other I/O tasks could go here.
;
; It may be useful to check if the requested parameter
; exists, to avoid wasting time on needless I/O. That
; assumes the parameter hasn't been modified (e.g. 
; smoothing) or that the user is aware of modifications.
; Perhaps keep a global array of the data names that
; have been read.
;
;-

function read_xxx_data, data_name, $
                        data_type, $
                        _EXTRA=ex

  if size(data_type,/type) ne 7 then $
     message, "Please supply data type as a string"
  case 1 of
     strcmp(data_type,'bin',/fold_case): data = read_bin_data(data_name,_EXTRA=ex)
     strcmp(data_type,'ph5',/fold_case): data = read_ph5_data(data_name,_EXTRA=ex)
     else: begin 
        print, "[READ_XXX_DATA] Currently supported data types are [bin,ph5]"
        data = 0.0
     end
  endcase

  return, data
end
