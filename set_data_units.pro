;+
; Set the units to be used for graphics.
;
; TO DO
; -- Consider making this a function that takes
;    data names as input and returns the units
;    dictionary, which the user can assign to the
;    project dictionary. That would allow the user
;    to call this before setting the actual project
;    data (and independent of the name of the field
;    that holds data names).
;-
pro set_data_units, target,units, $
                    absolute=absolute

  if target.haskey('data') then begin
     dKeys = target.data.keys()
     target['units'] = dictionary(dKeys)
     for ik=0,target.data.count()-1 do begin
        data_oom = fix(alog10(1./target.scale[dKeys[ik]]))
        data_prefix = units.prefixes.where(data_oom)
        case 1 of
           strcmp(dKeys[ik],'den',3): begin
              if keyword_set(absolute) then begin
                 if data_oom eq 0 then target.units[dKeys[ik]] = $
                    units.bases['abs_den'] $
                 else target.units[dKeys[ik]] = $
                    strcompress(string(target.scale[dKeys[ik]]), $
                                /remove_all)+ $
                    "$\times$"+units.bases['abs_den']
              endif $
              else begin
                 case data_oom of
                    ;; 0:          ;Do nothing
                    0: target.units[dKeys[ik]] = $
                       data_prefix.remove()+units.bases['rel_den']
                    -2: target.units[dKeys[ik]] = "%"
                    else: target.units[dKeys[ik]] = $
                       "$\times$"+ $
                       strcompress(string(target.scale[dKeys[ik]]), $
                                   /remove_all)
                 endcase
              endelse
           end
           strcmp(dKeys[ik],'phi',3): $
              target.units[dKeys[ik]] = data_prefix.remove()+units.bases['phi']
           strcmp(dKeys[ik],'e',1,/fold_case): $
              target.units[dKeys[ik]] = data_prefix.remove()+units.bases['E']
        endcase
        target.units[dKeys[ik]] = "["+target.units[dKeys[ik]]+"]"        
     endfor
  endif $
  else print, "SET_DATA_UNITS: Needs to know project data names."

end
