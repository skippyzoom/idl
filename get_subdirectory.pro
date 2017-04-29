;+
; Extracts the local subdirectory from a path.
; If no path is specified, this routine uses
; the current working directory. If the user
; specifies the path with a terminal '/',
; this routine trims the terminal '/'. For
; example, get_subdirectory('/my/full/path')
; and get_subdirectory('/my/full/path/') both
; return 'path'.
;-
function get_subdirectory, path
  
  if n_elements(path) eq 0 then spawn, 'pwd',path
  lastSlash = strpos(path,'/',/reverse_search)
  pathLen = strlen(path)
  if lastSlash eq pathLen-1 then begin
     path = strmid(path,0,pathLen-1)
     lastSlash = strpos(path,'/',/reverse_search)
  endif
  subDir = strmid(path,lastSlash+1,pathLen)

  return, subDir
end
