;+
; Handle graphics keywords that may have different
; values at different time steps.
; This function will ignore rgb_table, since that
; can be a scalar or array but shouldn't differ
; between panels.
;-
function get_timestep_kw, kw,type, $
                          verbose=verbose
@load_idl_keywords

  flag = list()
  keys = kw.keys()
  nKeys = kw.count()
  if idl_keywords.haskey(type) then begin
     expect = (idl_keywords[type])[*]
     for ik=0,nKeys-1 do begin
        if ~strcmp(keys[ik],'rgb_table') then begin
           keyDims = size(kw[keys[ik]],/n_dim)
           expDims = expect[keys[ik]]
           case 1B of 
              (keyDims eq expDims): ; Do nothing
              (keyDims eq expDims+1): flag.add, keys[ik]
              else: message, "Keyword '"+keys[ik]+"' may be "+ $
                             strcompress(expDims,/remove_all)+ $
                             "-D (same for all time steps) or "+ $
                             strcompress(expDims+1,/remove_all)+ $
                             "-D (one value for each time step)."
           endcase
        endif
     endfor
  endif

  return, flag
end
