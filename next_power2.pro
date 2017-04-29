;+
; I adapted this code from the web address 
; >  http://www.exelisvis.com/Company/PressRoom/Blogs/
; >  IDLDataPointDetail/TabId/902/ArtMID/2926/ArticleID/
; >  13040/Finding-the-next-power-of-two.aspx
; Credit for original code goes to Ron Kneusel
;
; I believe the ishft arguments go to 64 to cover 64-bit systems.
;-
function next_power2, x
  compile_opt idl2, logical_predicate

  n = x-1
  n = ishft(n,-1) or n
  n = ishft(n,-2) or n
  n = ishft(n,-4) or n
  n = ishft(n,-8) or n
  n = ishft(n,-16) or n
  n = ishft(n,-32) or n
  n = ishft(n,-64) or n

  return, ++n
end
