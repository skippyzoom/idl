;+
; Take the FFT of an array containing spatial and
; temporal data. The temporal FFT is optional.
;-
function fft_xyzt, data, $
                   alpha=alpha, $
                   width=width, $
                   swap_time=swap_time, $
                   zero_dc=zero_dc, $
                   normalize=normalize, $
                   complex=complex, $
                   skip_time=skip_time, $
                   verbose=verbose, $
                   _EXTRA=ex

  dsize = size(data)
  n_dims = dsize[0]
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
  if n_elements(width) eq 0 then width = nt/2

  ;;==Add window, if applicable
  if ~keyword_set(skip_time) then begin
     if alpha gt 0.0 and alpha lt 1.0 then begin
        if keyword_set(verbose) then $
           print, "FFT: Adding window (alpha = ", $
                  strcompress(string(alpha,format='(f4.2)'),/remove_all), $
                  ")..."
        win = hanning(width,alpha=alpha)
        for it=0,nt-1 do data[*,*,*,it] *= win[it]
     endif
  endif

  ;;==Calculate
  if keyword_set(verbose) then $
     print, "FFT: Calculating..."
  if ~keyword_set(skip_time) then data = fft(data,_EXTRA=ex) $
  else for it=0,nt-1 do $
     data[*,*,*,it] = fft(data[*,*,*,it],_EXTRA=ex)

  ;;==Swap time dimension, if applicable
  if ~keyword_set(skip_time) && keyword_set(swap_time) then begin
     if keyword_set(vebose) then $
        print, "FFT: Swapping time dimension..."
     data = reverse(data,dim=n_dims)
  endif

  ;;==Zero DC component
  if keyword_set(zero_dc) then begin
     if keyword_set(verbose) then $
        print, "FFT: zeroing DC component..."
     data[nx/2,ny/2,nz/2,nt/2] = 0.0
  endif

  ;;==Return real part if user didn't request complex
  if ~keyword_set(complex) then data = abs(data)

  ;;==Normalize
  if keyword_set(normalize) then begin
     if keyword_set(verbose) then $
        print, "FFT: Normalizing..."
     data /= max(data)
  endif

  return, data
end
