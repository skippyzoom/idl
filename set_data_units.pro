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
pro set_data_units, context,units, $
                    absolute=absolute

  if context.haskey('data') then begin
     d_keys = context.data.keys()
     context['units'] = dictionary(d_keys)
     for ik=0,context.data.count()-1 do begin
        data_oom = fix(alog10(1./context.scale[d_keys[ik]]))
        data_prefix = units.prefixes.where(data_oom)
        case 1 of
           strcmp(d_keys[ik],'den',3): begin
              if keyword_set(absolute) then begin
                 if data_oom eq 0 then context.units[d_keys[ik]] = $
                    units.bases['abs_den'] $
                 else context.units[d_keys[ik]] = $
                    strcompress(string(context.scale[d_keys[ik]]), $
                                /remove_all)+ $
                    "$\times$"+units.bases['abs_den']
              endif $
              else begin
                 case data_oom of
                    ;; 0:          ;Do nothing
                    0: context.units[d_keys[ik]] = $
                       data_prefix.remove()+units.bases['rel_den']
                    -2: context.units[d_keys[ik]] = "%"
                    else: context.units[d_keys[ik]] = $
                       "$\times$"+ $
                       strcompress(string(context.scale[d_keys[ik]]), $
                                   /remove_all)
                 endcase
              endelse
           end
           strcmp(d_keys[ik],'phi',3): $
              context.units[d_keys[ik]] = data_prefix.remove()+units.bases['phi']
           strcmp(d_keys[ik],'e',1,/fold_case): $
              context.units[d_keys[ik]] = data_prefix.remove()+units.bases['E']
        endcase
        context.units[d_keys[ik]] = "["+context.units[d_keys[ik]]+"]"        
     endfor
  endif $
  else print, "SET_DATA_UNITS: Needs to know project data names."

end
