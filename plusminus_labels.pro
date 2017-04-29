function plusminus_labels, values
;+
; Intended to be a way to prevent '+0.0' when
; using a 'f+...' format specifier, but in its
; current form, the resulting format of '0.0'
; may be inconsistent with the rest of the 
; labels.
;-


  labels = string(values,format='(f+7.1)')
  iEq0 = where(values eq 0.0)
  labels[iEq0] = '0.0'
  labels = strcompress(labels,/remove_all)

  return, labels
end
