;+
; Get the file extension of a given file name.
; The return value is the string extension 
; starting AFTER the last dot.
;-
function get_extension, name
  name_in = name
  pos = strpos(name_in,'.',/reverse_search)
  ext = strmid(name_in,pos+1,strlen(name_in))
  return, ext
end
