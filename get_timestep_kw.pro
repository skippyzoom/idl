;+
; Handle graphics keywords that may have different
; values at different time steps.
;-
function get_timestep_kw, kw,key,expect,verbose=verbose

  nKeys = n_elements(key)
  if n_elements(expect) ne nKeys then $
     message, "Must have equal number of keys and expected values."
  flag = make_array(nKeys,value=0B)

  for ik=0,nKeys-1 do begin
     if kw.haskey(key[ik]) then begin
        nDims = (size(kw[key[ik]]))[0]
        case 1B of
           (nDims eq expect[ik]): ;Do nothing
           (nDims eq expect[ik]+1): flag[ik] = 1B
           else: message, "Keyword '"+key[ik]+"' may be "+ $
                          strcompress(expect[ik],/remove_all)+ $
                          "-D (same for all time steps) or "+ $
                          strcompress(expect[ik]+1,/remove_all)+ $
                          "-D (one value for each time step)."
        endcase
     endif $
     else if keyword_set(verbose) then $
        print, "GET_TIMESTEP_KW: Did not find keyword '"+key[ik]+"'."
           
  endfor

  return, flag
end
