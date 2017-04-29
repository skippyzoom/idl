;+
; Build arrays of requested data.
; Expects that a calling function has 
; defined parameters for read_xxx_data().
;
; NOTES:
; -- The function read_xxx_data() will abort
;    if format (currently binary or phdf) is
;    not specified.
; -- This function returns an array if only
;    one dataName is specified. Therefore,
;    the caller should check the return type
;    to determine if it needs to unpack a 
;    struct or it can use the array directly. 
;
; TO DO:
; -- Let dataType be either one value or an
;    array of the same length as dataName, to
;    allow reading of different times for 
;    different data quantities.
;-

function data_struct_build, dataName,dataType,_EXTRA=ex
                           
  nq = n_elements(dataName)
  ;--> Faster for one data quantity
  if nq gt 1 then begin
     for iq=0,nq-1 do begin
        data = read_xxx_data(dataName[iq],dataType,_EXTRA=ex)
        if n_elements(all_data) eq 0 then $
           all_data = create_struct(dataName[iq],data) $
        else all_data = create_struct(all_data,dataName[iq],data)
     endfor
  endif else begin
     data = read_xxx_data(dataName,dataType,_EXTRA=ex)
     all_data = data
  endelse
  ;<--
  ;; for iq=0,nq-1 do begin
  ;;    data = read_xxx_data(dataName[iq],dataType,_EXTRA=ex)
  ;;    if n_elements(all_data) eq 0 then $
  ;;       all_data = create_struct(dataName[iq],data) $
  ;;    else all_data = create_struct(all_data,dataName[iq],data)
  ;; endfor

  return, all_data

end
