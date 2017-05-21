;+
; Reduce the dimension of a data field in a struct if
; the field is an array with more than one dimension,
; or "zero" the field if it is a scalar or 1-D array.
; The "zero" value for a string is a blank, non-null 
; string (i.e. ' ').
;
; SIDE EFFECTS:
; -- Tag indices of the new struct will not match tag
;    indices of the old struct.
;
; NOTES:
; -- This function was originally written to deal with 
;    image() keywords passed to multi_image.pro in for
;    which the value differs among panels.
; -- Recursively calling this function on the same tag
;    N+1 times, where N is the dimension of the field data,
;    will result in zeroing the field.
;
; Example:
;   Suppose I pass a struct of keywords to multi_image.pro
; via image_keywords and that struct has a field called
; 'title' that contains an array of strings, one for each
; panel (as opposed to a single string to be used for all
; panels). multi_image.pro will need to pass each title
; string to image() individually when it loops over all the
; requested images, so I first use extract_tag to extract 
; the data associated with the tag 'title', then use this
; function to reset the field to a single blank string.
; Finally, I assign each string in title to the reset 'title'
; field in the parameter struct.
;
; SILENT: Suppress non-fatal warnings.
;-

function reduce_tag, str,tag,silent=silent

  nTags = n_elements(tag)
  success = make_array(nTags,value=0B)
  for it=0,nTags-1 do begin
     if tag_exist(str,tag[it]) then begin
        ind = where(strcmp(tag_names(str),tag[it],/fold_case),count)
        data = str.(ind)
        tmpSize = size(data)
        tmpType = size(data,/type)
        zero = get_zero(tmpType)
        if n_elements(zero) ne 0 then begin
           case tmpSize[0] of
              0: val = zero
              1: val = zero
              2: val = make_array(tmpSize[1],value=zero)
           endcase
        endif
        remove_tag, str,tag[it]
        str = create_struct(str,tag[it],val)
        success[it] = 1B
     endif else begin
        if not(keyword_set(silent)) then $
           print, "tag '"+tag[it]+"' is not a member of struct"
        success[it] = 0B
     endelse
  endfor

  return, success
end
