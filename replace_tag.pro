;+
; Replace a struct data field with new data
;
; SILENT: Suppress non-fatal warnings.
;-

pro replace_tag, str,tag,new,silent=silent

  if n_params() ne 3 then $
     message, "Please provide struct and tag name." $
  else begin
     if size(str,/type) ne 8 then $
        message, "First argument must be a struct"
     if size(tag,/type) ne 7 then $
        message, "Second argument must be a string"
  endelse

  remove_tag, str,tag,silent=silent
  str = create_struct(str,tag,new)

end
