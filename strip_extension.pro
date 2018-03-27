;+
; Remove the extension from a file name
; without knowing the extension a priori.
; This function assumes that all characters
; following the final '.' comprise the
; extension.
;
; NOTES
; -- This function will return name unmodified
;    if it does not find an extension.
;-
function strip_extension, name
  name_in = name
  pos = strpos(name_in,'.',/reverse_search)
  if pos ge 0 then name_in = strmid(name_in,0,pos)
  return, name_in
end
