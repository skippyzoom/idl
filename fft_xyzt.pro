;+
; Take the FFT of an array containing spatial and
; temporal data. The temporal FFT is optional.
;
; NOTES
; -- This function expects data to have a time 
;    dimension. Therefore, it will calculate the
;    number of spatial dimensions (n_dims) as one
;    less than the number of dimensions returned
;    by size().
; -- The user is responsible for padding the input
;    array.
;-
function fft_xyzt, data, $
                   alpha=alpha, $
                   hw_width=hw_width, $
                   swap_time=swap_time, $
                   mask_dc=mask_dc, $
                   dc_width=dc_width, $
                   dc_value=dc_value, $
                   normalize=normalize, $
                   complex=complex, $
                   skip_time=skip_time, $
                   verbose=verbose, $
                   lun=lun, $
                   _EXTRA=ex

  dsize = size(data)
  n_dims = dsize[0]-1
  nt = dsize[n_dims]
  nx = dsize[1]
  ny = dsize[2]
  if n_dims eq 3 then nz = dsize[3] $
  else begin
     nz = 1
     data = reform(data,[nx,ny,nz,nt])
  endelse

  ;;==Defaults and guards
  if n_elements(alpha) eq 0 then alpha = 1.0
  if n_elements(hw_width) eq 0 then hw_width = nt/2
  if n_elements(dc_width) eq 0 then dc_width = 0

  ;;==Add window, if applicable
  if ~keyword_set(skip_time) then begin
     if alpha gt 0.0 and alpha lt 1.0 then begin
        if keyword_set(verbose) then $
           printf, lun,"[FFT_XYZT] Adding window (alpha = ", $
                  strcompress(string(alpha,format='(f4.2)'),/remove_all), $
                  ")..."
        win = hanning(hw_width,alpha=alpha)
        for it=0,nt-1 do data[*,*,*,it] *= win[it]
     endif
  endif

  ;;==Calculate
  if keyword_set(verbose) then $
     printf, lun,"[FFT_XYZT] Calculating..."
  if keyword_set(skip_time) then begin
     for it=0,nt-1 do $
        data[*,*,*,it] = fft(data[*,*,*,it],_EXTRA=ex)
  endif
  else begin
     data = fft(data,_EXTRA=ex)
     if keyword_set(swap_time) then begin
        if keyword_set(vebose) then $
           printf, lun,"[FFT_XYZT] Swapping time dimension..."
        data = reverse(data,dim=n_dims)
     endif
  endelse

  ;; ;;==Swap time dimension, if applicable
  ;; if ~keyword_set(skip_time) && keyword_set(swap_time) then begin
  ;;    if keyword_set(vebose) then $
  ;;       printf, lun,"[FFT_XYZT] Swapping time dimension..."
  ;;    data = reverse(data,dim=n_dims)
  ;; endif

  ;;==Zero DC component
  if keyword_set(mask_dc) then begin
     if isa(dc_value,/string) then begin
        if strcmp(dc_value,'min') then dc_value = min(data)
        if strcmp(dc_value,'max') then dc_value = max(data)
     endif
     if keyword_set(verbose) then $
        printf, lun,"[FFT_XYZT] zeroing DC component..."
     if keyword_set(skip_time) then $
        data[nx/2-dc_width:nx/2+dc_width, $
             nx/2-dc_width:nx/2+dc_width, $
             nx/2-dc_width:nx/2+dc_width, $
             *] = dc_value $
     else $
        data[nx/2-dc_width:nx/2+dc_width, $
             nx/2-dc_width:nx/2+dc_width, $
             nx/2-dc_width:nx/2+dc_width, $
             nt/2] = dc_value
  endif

  ;;==Return real part if user didn't request complex
  if ~keyword_set(complex) then data = abs(data)

  ;;==Normalize
  if keyword_set(normalize) then begin
     if keyword_set(verbose) then $
        printf, lun,"[FFT_XYZT] Normalizing..."
     data /= max(data)
  endif

  return, data
end
