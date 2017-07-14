;+
; Calculate interpolated spectral data or
; restore an existing data struct.
;
;
; DATA:
;   Data to be passed to calc_kmag, if applicable.
; FILENAME:
;   Name of existing file, which the function
;   will attempt to restore, or name of file to
;   which to write new array.
; RESTORE:
;   Restore existing data if available. If the
;   file does not exist, this function will
;   behave as if the user did not set /restore.
; SILENT:
;   Suppress verbose warnings.
;-

function load_kmag, data=data,filename=filename,restore=restore,silent=silent,_EXTRA=ex
@load_eppic_params

  if file_test(filename) and keyword_set(restore) then $
     ;;==Restore an existing data struct.
     restore, filename=filename,/verbose $
  else begin
     ;;==If the user set /restore, let them know it failed.
     if keyword_set(restore) then $
        if ~keyword_set(silent) then $
           print, "LOAD_KMAG: Unable to find ",filename,". Calculating new data..."

     ;;==User must provide data.
     if n_elements(data) eq 0 then $
        message, "Please provide data array for processing."

     ;;==Calculate |k|,angle,freq.
     kmag = calc_kmag(data,_EXTRA=ex)

     ;;==Save the interpolation struct.
     if n_elements(filename) eq 0 then filename = 'kmag.sav'
     if ~keyword_set(silent) then print, "Saving data to ",filename
     save, kmag,filename=filename
  endelse

  return, kmag
end
