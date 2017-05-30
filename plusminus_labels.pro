;+
; Intended to be a way to prevent '+0.0' when
; using a 'f+...' format specifier, but in its
; current form, the resulting format of '0.0'
; may be inconsistent with the rest of the 
; labels.
;
; FORMAT: Optional user-specified FORTRAN-style
;   format code. See 
;   https://harrisgeospatial.com/docs/format_codes_fortran.html
;   for details. If the user passes a string with 
;   leading or training parentheses, this function
;   will strip them to access the code and width.
;-
function plusminus_labels, values,format=format

  ;;==Defaults and guards
  if n_elements(format) eq 0 then format = 'f8.3'

  ;;==Strip parentheses
  length = strlen(format)
  if strcmp(strmid(format,0,1),'(') then $
     format = strmid(format,1,length-1)
  length = strlen(format)
  if strcmp(strmid(format,0,1,/reverse),')') then $
     format = strmid(format,0,length-1)

  ;;==Extract format code and width
  length = strlen(format)
  code = strmid(format,0,1)
  width = strmid(format,1,length-1)

  ;;==Create labels
  labels = string(values,format='('+code+'+'+width+')')
  iEq0 = where(values eq 0.0)
  labels[iEq0] = string(0,format='('+format+')')
  labels = strcompress(labels,/remove_all)

  return, labels
end
