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
  pos = strpos(name,'.',/reverse_search)
  if pos ge 0 then name = strmid(name,0,pos)
  return, name
end
