;+
; Returns the a struct of image parameters and
; keywords, called "kw", which the caller
; can pass to IDL's image().
;
; Deprecate? 09Sep2017 (may)
;
; TO DO
; -- Handle cases in which user doesn't pass info
;    necessary for a keyword (e.g. imgData for
;    min/max_value). Maybe the user should just
;    pass those things through _EXTRA.
; -- Consider making the 'freq' part of 'kmag_freq'
;    a keyword instead of forcing the user to remem-
;    ber a different calling sequence for this func-
;    tion and set_kw_kmag.pro.
; -- Use /image, /colorbar, and /text keywords to 
;    let the user request only those structs from
;    a given set_kw_<name> function.
;-
function set_kw, name, $
                 image=image, $
                 colorbar=colorbar, $
                 text=text, $
                 imgData=imgData, $
                 timestep=timestep
  case 1 of
     strcmp(name,'den'): kw = set_kw_den(imgData=imgData,timestep=timestep)
     strcmp(name,'phi'): kw = set_kw_phi(imgData=imgData,timestep=timestep)
     strcmp(name,'emag'): kw = set_kw_emag(imgData=imgData,timestep=timestep)
     strcmp(name,'kmag_freq'): kw = set_kw_kmag(imgData=imgData,/frequency)
     strcmp(name,'kmag_time'): kw = set_kw_kmag(imgData=imgData)
     ;; strcmp(name,'fft'): kw = set_kw_fft(imgData=imgData)
     else: begin 
        print, "SET_KW: Could not find a match for '"+name+"'."
        kw = !NULL
     end
  endcase

  return, kw
end
