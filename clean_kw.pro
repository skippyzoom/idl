;+
; Remove any graphics keywords that aren't allowed by a
; selected IDL function/routine (e.g. image).
; NB: The user is responsible for backing up the kw
; dictionary before calling this routine.
;-
pro clean_kw, kw,image=image,plot=plot,colorbar=colorbar,text=text, $
              removed=removed
@load_idl_keywords

  user_keys = kw.keys()
  if keyword_set(image) && $
     idl_keywords.haskey('image') then $
        idl_keys = idl_keywords.image.keys()
  if keyword_set(plot) && $
     idl_keywords.haskey('plot') then $
        idl_keys = idl_keywords.plot.keys()
  if keyword_set(colorbar) && $
     idl_keywords.haskey('colorbar') then $
        idl_keys = idl_keywords.colorbar.keys()
  if keyword_set(text) && $
     idl_keywords.haskey('text') then $
        idl_keys = idl_keywords.text.keys()

  removed = list()
  if n_elements(idl_keys) ne 0 then begin
     for ik=0,kw.count()-1 do begin
        allowed = string_exists(idl_keys,user_keys[ik],/fold_case)
        if ~allowed then begin
           kw.remove, user_keys[ik]
           removed.add, user_keys[ik]
        endif
     endfor
  endif

end
