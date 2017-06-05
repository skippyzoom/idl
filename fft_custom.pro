;+
; Takes the spatial (and, optionally, the temporal) FFT of data, 
; allowing for additional manipulation based on parameters. 
;
; FFTDIMS: Allows for zero-padding.
; ALPHA: Hanning window parameter.
; SINGLE_TIME: Signals that data does not have a time dimension.
;              This resolves the ambiguity between arrays with
;              2 spatial + 1 temporal dimensions and arrays with
;              3 spatial + 0 temporal dimsneions.
; SKIP_TIME_FFT: Do not compute the FFT in time.
;                The default is to compute the FFT in time.
;                This keyword is only used to turn off the
;                boolean do_time_fft, which is used in the
;                remainder of the code.
; SWAP_TIME: Reverse the order of the time (frequency) dimension.
; ZERO_DC: Zero the DC component of the FFT.
; NORMALIZE: Normalize the FFT to its max value.
; COMPLEX: Return the complex transform (amplitude and phase).
;          Default is to return the real amplitude.
; VERBOSE: Print informational messages.
;
; TO DO:
;-
function fft_custom, data, $
                     fftdims=fftdims, $
                     alpha=alpha, $
                     single_time=single_time, $
                     skip_time_fft=skip_time_fft, $
                     swap_time=swap_time, $
                     zero_dc=zero_dc, $
                     normalize=normalize, $
                     complex=complex, $
                     verbose=verbose, $
                     _EXTRA=ex

  ;;==Defaults and guards
  n_dims = size(data,/n_dim)
  datadims = size(data,/dim)
  if n_elements(fftdims) eq 0 then $
     fftdims = datadims $
  else begin
     if tag_exist(ex,'overwrite',/quiet) then begin
        print, "FFT_CUSTOM: Cannot resize data when using /overwrite."
        print, "            Using original dimensions instead."
     endif
  endelse
  if n_elements(alpha) eq 0 then alpha = 1.0
  do_time_fft = 1B
  if keyword_set(skip_time_fft) then do_time_fft = 0B

  if keyword_set(single_time) then begin

     ;;==Check dimensions
     ndx = 1 & nkx = 1
     ndy = 1 & nky = 1
     ndz = 1 & nkz = 1
     switch n_dims of
        3: begin
           ndz = datadims[2]
           nkz = fftdims[2]
           if nkz lt ndz then $
              message, "Must have nkz >= nz"
        end
        2: begin
           ndy = datadims[1]
           nky = fftdims[1]
           if nky lt ndy then $
              message, "Must have nky >= ny"
        end
        1: begin
           ndx = datadims[0]
           nkx = fftdims[0]
           if nkx lt ndx then $
              message, "Must have nkx >= nx"
        end
     endswitch

     ;;==Set up data
     if tag_exist(ex, 'overwrite',/quiet) then begin
        if keyword_set(verbose) then $
           print, "FFT: Overwriting input array..."
     endif else begin
        if keyword_set(verbose) then $
           print, "FFT: Setting up FFT array..."
        data_in = data
        data = !NULL
        data = fltarr(nkx,nky,nkz)*0.0
        data[0:ndx-1,0:ndy-1,0:ndz-1] = data_in
        data_in = !NULL
     endelse

     ;;==Calculate
     if keyword_set(verbose) then $
        print, "FFT: Calculating..."
     data = fft(data,_EXTRA=ex)

     ;;==Zero DC component
     if keyword_set(zero_dc) then begin
        if keyword_set(verbose) then $
           print, "FFT: zeroing DC component..."
        data[nkx/2,nky/2,nkz/2] = 0.0
     endif

  endif else begin

     ;;==Check dimensions
     ndx = 1 & nkx = 1
     ndy = 1 & nky = 1
     ndz = 1 & nkz = 1
     ndt = 1 & nw = 1
     switch n_dims of
        4: begin
           ndt = datadims[3]
           nw = fftdims[3]
           if nw lt ndt then $
              message, "Must have nw >= nt"
        end
        3: begin
           ndz = datadims[2]
           nkz = fftdims[2]
           if nkz lt ndz then $
              message, "Must have nkz >= nz"
        end
        2: begin
           ndy = datadims[1]
           nky = fftdims[1]
           if nky lt ndy then $
              message, "Must have nky >= ny"
        end
        1: begin
           ndx = datadims[0]
           nkx = fftdims[0]
           if nkx lt ndx then $
              message, "Must have nkx >= nx"
        end
     endswitch

     ;;==Set up data
     if tag_exist(ex, 'overwrite',/quiet) then begin
        if keyword_set(verbose) then $
           print, "FFT: Overwriting input array..."
     endif else begin
        if keyword_set(verbose) then $
           print, "FFT: Setting up FFT array..."
        data_in = data
        data = !NULL
        data = fltarr(nkx,nky,nkz,nw)*0.0
        data[0:ndx-1,0:ndy-1,0:ndz-1,0:ndt-1] = data_in
        data_in = !NULL
     endelse

     ;;==Add window
     if keyword_set(do_time_fft) then begin
        if alpha gt 0.0 and alpha lt 1.0 then begin
           if keyword_set(verbose) then $
              print, "FFT: Adding window (alpha = ", $
                     strcompress(string(alpha,format='(f4.2)'),/remove_all), $
                     ")..."
           Hsize = nw/2
           ;; Hsize = nw
           Hwin = Hanning(Hsize,alpha=alpha)
           for iw=0,Hsize-1 do data[*,*,*,iw] *= Hwin[iw]
        endif
     endif

     ;;==Calculate
     if keyword_set(verbose) then $
        print, "FFT: Calculating..."
     if keyword_set(do_time_fft) then $
        data = fft(data,_EXTRA=ex) $
     else $
        for it=0,ndt-1 do $
           data[*,*,*,it] = fft(data[*,*,*,it],_EXTRA=ex)

     ;;==Swap time dimension
     if keyword_set(do_time_fft) then begin
        if keyword_set(swap_time) then begin
           if keyword_set(verbose) then $
              print, "FFT: Swapping time dimension..."
           for iw=0,nw/2-1 do begin
              temp = data[*,*,*,iw]
              data[*,*,*,iw] = data[*,*,*,nw-iw-1]
              data[*,*,*,nw-iw-1] = temp
           endfor
        endif
     endif

     ;;==Zero DC component
     if keyword_set(zero_dc) then begin
        if keyword_set(verbose) then $
           print, "FFT: zeroing DC component..."
        data[nkx/2,nky/2,nkz/2,nw/2] = 0.0
     endif
  endelse

  ;;==Normalize
  if keyword_set(normalize) then begin
     if keyword_set(verbose) then $
        print, "FFT: Normalizing..."
     data /= max(data)
  endif

  ;;==Return real part if user didn't request complex
  if ~keyword_set(complex) then data = abs(data)

  return, data

end
