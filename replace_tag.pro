;+
; Replace a struct data field with new data
;
; TO DO
; -- This could probably be vectorized since
;    remove_tag should be trivially vectorizable.
; -- Keep track of index (see TAG_EXIST man page)
;    in order to preserve tag order?
;    
; QUIET: Suppress non-fatal warnings.
;-
function replace_tag, str,tag,new,quiet=quiet

  if n_params() ne 3 then $
     message, "Please provide struct, tag name, and new field." $
  else begin
     if size(str,/type) ne 8 then $
        message, "First argument must be a struct"
     if size(tag,/type) ne 7 then $
        message, "Second argument must be a string"
  endelse

  str = remove_tag(str,tag,quiet=quiet)
  str = create_struct(str,tag,new)

  return, str
end
