;+
; Condition an FFT for graphics
;-
function condition_fft, f, $
                        lun=lun, $
                        overwrite=overwrite, $
                        magnitude=magnitude, $
                        shift=shift, $
                        center=center, $
                        mask_index=mask_index, $
                        missing=missing, $
                        normalize=normalize, $
                        finite=finite, $
                        to_dB=to_dB

  ;;==Set default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Get array dimensions
  fsize = size(f)
  ndims = fsize[0]
  nx = fsize[1]

  ;;==Check for overwrite keyword
  if keyword_set(overwrite) then begin
     if keyword_set(magnitude) then f = abs(f)
     shift_err = 0B
     case ndims of
        1: begin
           if keyword_set(center) then shift = nx/2
           if keyword_set(shift) then begin
              if n_elements(shift) eq ndims then $
                 f = shift(f,shift) $
              else shift_err = 1B
           endif
           if n_elements(missing) eq 0 then missing = min(f)
           if keyword_set(mask_index) then $
              f[mask_index[0,0]:mask_index[1,0]-1] = missing
           if keyword_set(normalize) then f /= max(f)
           if keyword_set(to_dB) then f = 10*alog10(f^2)
           if keyword_set(finite) then $
              f[where(~finite(f))] = missing
        end
        2: begin
           ny = fsize[2]
           if keyword_set(center) then shift = [nx/2,ny/2]
           if keyword_set(shift) then begin
              if n_elements(shift) eq ndims then $
                 f = shift(f,shift) $
              else shift_err = 1B
           endif
           if n_elements(missing) eq 0 then missing = min(f)
           if keyword_set(mask_index) then $
              f[mask_index[0,0]:mask_index[1,0]-1, $
                mask_index[0,1]:mask_index[1,1]-1] = missing
           if keyword_set(normalize) then f /= max(f)
           if keyword_set(to_dB) then f = 10*alog10(f^2)
           if keyword_set(finite) then $
              f[where(~finite(f))] = missing
        end
        3: begin
           ny = fsize[2]
           nz = fsize[3]
           if keyword_set(center) then shift = [nx/2,ny/2,nz/2]
           if keyword_set(shift) then begin
              if n_elements(shift) eq ndims then $
                 f = shift(f,shift) $
              else shift_err = 1B
           endif
           if n_elements(missing) eq 0 then missing = min(f)
           if keyword_set(mask_index) then $
              f[mask_index[0,0]:mask_index[1,0]-1, $
                mask_index[0,1]:mask_index[1,1]-1, $
                mask_index[0,2]:mask_index[1,2]-1] = missing
           if keyword_set(normalize) then f /= max(f)
           if keyword_set(to_dB) then f = 10*alog10(f^2)
           if keyword_set(finite) then $
              f[where(~finite(f))] = missing
        end
        4: begin
           ny = fsize[2]
           nz = fsize[3]
           nt = fsize[4]
           if keyword_set(center) then shift = [nx/2,ny/2,nz/2,nt/2]
           if keyword_set(shift) then begin
              if n_elements(shift) eq ndims then $
                 f = shift(f,shift) $
              else shift_err = 1B
           endif
           if n_elements(missing) eq 0 then missing = min(f)
           if keyword_set(mask_index) then $
              f[mask_index[0,0]:mask_index[1,0]-1, $
                mask_index[0,1]:mask_index[1,1]-1, $
                mask_index[0,2]:mask_index[1,2]-1, $
                mask_index[0,3]:mask_index[1,3]-1] = missing
           if keyword_set(normalize) then f /= max(f)
           if keyword_set(to_dB) then f = 10*alog10(f^2)
           if keyword_set(finite) then $
              f[where(~finite(f))] = missing
        end
        else: begin
           printf, lun,"[FFT_CONDITION] Input array must have "
           printf, lun,"                1 to 4 dimensions."
        end
     endcase

     if shift_err then begin
        printf, lun,"[FFT_CONDITION] shift must have one element for each"
        printf, lun,"                dimension of f."
     endif

     return, f
  endif $ ;;--overwrite
  else begin
     f_out = f
     if keyword_set(magnitude) then f_out = abs(f_out)
     shift_err = 0B
     case ndims of
        1: begin
           if keyword_set(center) then shift = nx/2
           if keyword_set(shift) then begin
              if n_elements(shift) eq ndims then $
                 f_out = shift(f_out,shift) $
              else shift_err = 1B
           endif
           if n_elements(missing) eq 0 then missing = min(f_out)
           if keyword_set(mask_index) then $
              f_out[mask_index[0,0]:mask_index[1,0]-1] = missing
           if keyword_set(normalize) then f_out /= max(f_out)
           if keyword_set(finite) then $
              f_out[where(~finite(f_out))] = missing
           if keyword_set(to_dB) then f_out = 10*alog10(f_out^2)
        end
        2: begin
           ny = fsize[2]
           if keyword_set(center) then shift = [nx/2,ny/2]
           if keyword_set(shift) then begin
              if n_elements(shift) eq ndims then $
                 f_out = shift(f_out,shift) $
              else shift_err = 1B
           endif
           if n_elements(missing) eq 0 then missing = min(f_out)
           if keyword_set(mask_index) then $
              f_out[mask_index[0,0]:mask_index[1,0]-1, $
                mask_index[0,1]:mask_index[1,1]-1] = missing
           if keyword_set(normalize) then f_out /= max(f_out)
           if keyword_set(finite) then $
              f_out[where(~finite(f_out))] = missing
           if keyword_set(to_dB) then f_out = 10*alog10(f_out^2)
        end
        3: begin
           ny = fsize[2]
           nz = fsize[3]
           if keyword_set(center) then shift = [nx/2,ny/2,nz/2]
           if keyword_set(shift) then begin
              if n_elements(shift) eq ndims then $
                 f_out = shift(f_out,shift) $
              else shift_err = 1B
           endif
           if n_elements(missing) eq 0 then missing = min(f_out)
           if keyword_set(mask_index) then $
              f_out[mask_index[0,0]:mask_index[1,0]-1, $
                mask_index[0,1]:mask_index[1,1]-1, $
                mask_index[0,2]:mask_index[1,2]-1] = missing
           if keyword_set(normalize) then f_out /= max(f_out)
           if keyword_set(finite) then $
              f_out[where(~finite(f_out))] = missing
           if keyword_set(to_dB) then f_out = 10*alog10(f_out^2)
        end
        4: begin
           ny = fsize[2]
           nz = fsize[3]
           nt = fsize[4]
           if keyword_set(center) then shift = [nx/2,ny/2,nz/2,nt/2]
           if keyword_set(shift) then begin
              if n_elements(shift) eq ndims then $
                 f_out = shift(f_out,shift) $
              else shift_err = 1B
           endif
           if n_elements(missing) eq 0 then missing = min(f_out)
           if keyword_set(mask_index) then $
              f_out[mask_index[0,0]:mask_index[1,0]-1, $
                mask_index[0,1]:mask_index[1,1]-1, $
                mask_index[0,2]:mask_index[1,2]-1, $
                mask_index[0,3]:mask_index[1,3]-1] = missing
           if keyword_set(normalize) then f_out /= max(f_out)
           if keyword_set(finite) then $
              f_out[where(~finite(f_out))] = missing
           if keyword_set(to_dB) then f_out = 10*alog10(f_out^2)
        end
        else: begin
           printf, lun,"[FFT_CONDITION] Input array must have 1 to 4 dimensions"
        end
     endcase

     if shift_err then begin
        printf, lun,"[FFT_CONDITION] shift must have one element for each"
        printf, lun,"                dimension of f"
     endif

     return, f_out
  endelse

end
