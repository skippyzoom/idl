;+
; Set the units to be used for graphics.
;-
pro set_data_units, prj,units, $
                    absolute=absolute

  dKeys = prj.data.keys()
  prj['units'] = dictionary(dKeys)
  for ik=0,prj.data.count()-1 do begin
     data_oom = fix(alog10(1./prj.scale[dKeys[ik]]))
     data_prefix = units.prefixes.where(data_oom)
     case 1 of
        strcmp(dKeys[ik],'den',3): begin
           if keyword_set(absolute) then begin
              if data_oom eq 0 then prj.units[dKeys[ik]] = units.bases.abs_den $
              else prj.units[dKeys[ik]] = strcompress(string(prj.scale[dKeys[ik]]),/remove_all)+ $
                                          "$\times$"+units.bases.abs_den
           endif $
           else begin
              case data_oom of
                 0:             ;Do nothing
                 -2: prj.units[dKeys[ik]] = "%"
                 else: prj.units[dKeys[ik]] = "$\times$"+ $
                                              strcompress(string(prj.scale[dKeys[ik]]),/remove_all)
              endcase
           endelse
        end
        strcmp(dKeys[ik],'phi',3): prj.units[dKeys[ik]] = data_prefix.remove()+units.bases['phi']
        strcmp(dKeys[ik],'e',1,/fold_case): prj.units[dKeys[ik]] = data_prefix.remove()+units.bases['E']
     endcase
     prj.units[dKeys[ik]] = "["+prj.units[dKeys[ik]]+"]"
  endfor

end
