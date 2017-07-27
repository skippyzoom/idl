;+
; Get the file extension of a given file name.
; The return value is the string extension 
; starting AFTER the last dot.
;-
function get_extension, name
  pos = strpos(name,'.',/reverse_search)
  ext = strmid(name,pos+1,strlen(name))
  return, ext
end
