function plusminus_labels, values,type=type
;+
; Intended to be a way to prevent '+0.0' when
; using a 'f+...' format specifier, but in its
; current form, the resulting format of '0.0'
; may be inconsistent with the rest of the 
; labels.
;
; TYPE:
;   If type = 'i' then output will be in integer format
;   If type = 'f' then output will be in float format
;   float is the default
;
; TO DO:
; -- Just let the user specify the format so they can 
;    also specify the width and number of decimals?
;-

  if keyword_set(type) eq 0 then type = 'f'
  labels = string(values,format='('+type+'+18.1)')
  iEq0 = where(values eq 0.0)
  if strcmp(type,'f') then labels[iEq0] = '0.0' $
  else labels[iEq0] = '0'
  labels = strcompress(labels,/remove_all)

  return, labels
end
