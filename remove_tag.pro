;+
; Remove a tag from a struct. Naturally, this
; means removing the data associated with the tag.
; 
; This function makes use of the remove keyword to
; the create_struct function. For some reason, the 
; documentation doesn't mention this useful keyword!
; https://harrisgeospatial.com/docs/CREATE_STRUCT.html
;
; SIDE EFFECTS:
; -- Tag indices of the new struct will not match tag
;    indices of the old struct.
;
; SILENT: Suppress non-fatal warnings.
;-

pro remove_tag, str,tag,silent=silent

  if n_params() ne 2 then $
     message, "Please provide struct and tag name." $
  else begin
     if size(str,/type) ne 8 then $
        message, "First argument must be a struct"
     if size(tag,/type) ne 7 then $
        message, "Second argument must be a string"
  endelse

  ind = where(strcmp(tag_names(str),tag,/fold_case),count)
  if count eq 0 then begin
     if not(keyword_set(silent)) then $
        print, "tag '"+tag+"' is not a member of struct"
  endif else str = create_struct(str,remove=ind)
  
end
