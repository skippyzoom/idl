;+
; Set the default keywords for making graphics of <name>.
; The user should call this function, then make project-specific
; changes to the kw struct in a <name>.prm file that lives in
; a subdirectory of ~/projects/
;
; TO DO
;-
function set_default_kw, name, $
                         _EXTRA=ex

  nData = n_elements(name)
  kw = dictionary()
  for id=0,nData-1 do begin
     case 1 of
        strcmp(name[id],'den',3): begin
           if strlen(name[id]) gt 3 then dist = fix(strmid(name[id],3,strlen(name[id]))) $
           else dist = 1
           kw['den'+strcompress(dist,/remove_all)] = default_kw_den(dist,_EXTRA=ex)
        end
        strcmp(name[id],'phi'): kw['phi'] = default_kw_phi(_EXTRA=ex)
        ;; strcmp(name[id],'emag'): kw = default_kw_emag(_EXTRA=ex)
        ;; strcmp(name[id],'kmag_freq'): kw = default_kw_kmag(_EXTRA=ex,/frequency)
        ;; strcmp(name[id],'kmag_time'): kw = default_kw_kmag(_EXTRA=ex)
        ;; strcmp(name[id],'fft'): kw = default_kw_fft()
        else: begin 
           print, "SET_DEFAULT_KW: Could not find a match for '"+name[id]+"'."
           kw = !NULL
        end
     endcase
  endfor

  return, kw
end
