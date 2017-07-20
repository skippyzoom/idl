;+
; Set the default keywords for making graphics of <name>.
; The user should call this function, then make project-specific
; changes to the kw struct in a <name>.prm file that lives in
; a subdirectory of ~/projects/
;
; TO DO
; -- Loop over case block to allow name to be a vector.
;-
function set_default_kw, name, $
                         ;; prj=prj, $
                         ;; image=image, $
                         ;; colorbar=colorbar, $
                         ;; text=text
                         _EXTRA=ex

  case 1 of
     strcmp(name,'den',3): begin
        if strlen(name) gt 3 then dist = fix(strmid(name,3,strlen(name))) $
        else dist = 1
        kw = default_kw_den(dist,_EXTRA=ex)
     end
     ;; strcmp(name,'phi'): kw = default_kw_phi(_EXTRA=ex)
     ;; strcmp(name,'emag'): kw = default_kw_emag(_EXTRA=ex)
     ;; strcmp(name,'kmag_freq'): kw = default_kw_kmag(_EXTRA=ex,/frequency)
     ;; strcmp(name,'kmag_time'): kw = default_kw_kmag(_EXTRA=ex)
     ;; strcmp(name,'fft'): kw = default_kw_fft()
     else: begin 
        print, "SET_DEFAULT_KW: Could not find a match for '"+name+"'."
        kw = !NULL
     end
  endcase

  return, kw
end
