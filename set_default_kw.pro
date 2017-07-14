;+
; Set the default keywords for making graphics of <name>.
;
; TO DO:
; -- Repurpose the old set_kw_<name> functions for use here.
; -- Consider implementing image, colorbar, and text keywords 
;    to allow user to request only those defaults.
;-
function set_default_kw, name, $
                         image=image, $
                         colorbar=colorbar, $
                         text=text

  case 1 of
     strcmp(name,'den'): kw = set_kw_den()
     strcmp(name,'phi'): kw = set_kw_phi()
     strcmp(name,'emag'): kw = set_kw_emag()
     strcmp(name,'kmag_freq'): kw = set_kw_kmag(/frequency)
     strcmp(name,'kmag_time'): kw = set_kw_kmag()
     ;; strcmp(name,'fft'): kw = set_kw_fft()
     else: begin 
        print, "SET_DEFAULT_KW: Could not find a match for '"+name+"'."
        kw = !NULL
     end
  endcase

  return, kw
end
