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

function read_xxx_data, dataName, $
                        dataType, $
                        _EXTRA=ex

  if size(dataType,/type) ne 7 then $
     message, "Please supply data type as a string"
  case 1 of
     strcmp(dataType,'bin',/fold_case): data = read_bin_data(dataName,_EXTRA=ex)
     strcmp(dataType,'ph5',/fold_case): data = read_ph5_data(dataName,_EXTRA=ex)
     else: begin 
        print, "[READ_XXX_DATA] Currently supported data types are [bin,ph5]"
        data = 0.0
     end
  endcase

  return, data
end
