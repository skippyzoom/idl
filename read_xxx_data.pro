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
; The binary and phdf keywords exist for backward com-
; patibility. The prefered method is to supply a string
; for dataType.
;-

function read_xxx_data, dataName, $
                        dataType, $
                        binary=binary,phdf=phdf, $                        
                        _EXTRA=ex

  if keyword_set(binary) then dataType = 'binary'
  if keyword_set(phdf) then dataType = 'phdf'
  if size(dataType,/type) ne 7 then $
     message, "Please supply data type as a string"
  ;; case 1 of
  ;;    keyword_set(binary): data = read_bin_data(dataName,_EXTRA=ex)
  ;;    keyword_set(phdf): data = read_ph5_data(dataName,_EXTRA=ex)
  ;; endcase
  case 1 of
     strcmp(dataType,'binary',/fold_case): data = read_bin_data(dataName,_EXTRA=ex)
     strcmp(dataType,'phdf',/fold_case): data = read_ph5_data(dataName,_EXTRA=ex)
     default: message, "Currently supported data types: [binary,phdf]"
  endcase

  return, data
end
