;+
; Set the labels for data graphics
;-
function set_data_labels, name, $
                          absolute=absolute

  if ~isa(name,'string') then name = name.toarray()
  n_names = n_elements(name)
  labels = dictionary(name)
  for in=0,n_names-1 do begin
     case 1 of
        strcmp(name[in],'den',3): labels[name[in]] = "$\delta n/n_0$"
        strcmp(name[in],'phi',3): labels[name[in]] = "$\phi$"
        strcmp(name[in],'e',1,/fold_case): labels[name[in]] = "$|E|$"
     endcase
  endfor
  
  return, labels
end
