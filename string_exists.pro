function string_exists, array,search,fold_case=fold_case
;+
; Test whether a given string exists in an
; array of strings.
;-

  return, where(strmatch(array,search,fold_case=fold_case) eq 1) ge 0

end
