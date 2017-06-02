;+
; This function takes the FFT of some data and calculates the
; array of power as a function of k value (k), look angle (theta), 
; frequency (omega), and, optionally, aspect angle (alpha).
;
; TO DO
; -- Keywords: Pass in separate structs for fft_custom() and 
;    kmag_interpolate()? Just handle a few and hardcode the
;    rest?
; -- An alternate approach to the /single_time keyword would
;    be for the user to supply the number of time steps (e.g.
;    n_times). That would require a default value, which could
;    be the length of the last dimension in data. At the moment,
;    this function doesn't need to know the number of time steps
;    anywhere else, so the /single_time keyword may be enough.
;    
;-
function calc_kmag, data, $
                    single_time=single_time, $
                    overwrite=overwrite, $
                    skip_time_fft=skip_time_fft, $
                    alpha=alpha, $
                    nTheta=nTheta, $
                    nAlpha=nAlpha, $
                    shape=shape, $
                    verbose=verbose

@load_eppic_params

  ;;==Defaults and guards
  if n_elements(nTheta) eq 0 then nTheta = 360
  if n_elements(nAlpha) eq 0 then nAlpha = 1
  if n_elements(alpha) eq 0 then alpha = 0.0

  if keyword_set(single_time) then begin
     ;;==Calculate FFT
     data = abs(fft(data, $     ;Temp until fft_custom can handle a single time step
                    overwrite = overwrite, $
                    /center))
     if keyword_set(verbose) then $
        print, "FFT: Normalizing..."
     data /= max(data)

     ;;==Interpolate FFT from Cartesian to spherical
     kmag = kmag_interpolate(data, $
                             dx = dx*nout_avg, $
                             dy = dy*nout_avg, $
                             dz = dz*nout_avg, $
                             aspect = alpha, $
                             shape = shape, $
                             nTheta = nTheta, $
                             nAlpha = nAlpha)
  endif else begin
     ;;==Calculate FFT
     if keyword_set(skip_time_fft) then begin
        data = fft_custom(data, $
                          overwrite = overwrite, $
                          /center, $
                          /normalize, $
                          /skip_time, $
                          verbose = verbose)
     endif else begin
        data = fft_custom(data, $
                          overwrite = overwrite, $
                          /center, $
                          alpha = alpha, $
                          /normalize, $
                          /swap_time, $
                          /zero_dc, $
                          verbose = verbose)
     endelse

     ;;==Interpolate FFT from Cartesian to spherical
     kmag = kmag_interpolate_loop(data, $
                                  dx = dx*nout_avg, $
                                  dy = dy*nout_avg, $
                                  dz = dz*nout_avg, $
                                  aspect = alpha, $
                                  shape = shape, $
                                  nTheta = nTheta, $
                                  nAlpha = nAlpha)
  endelse

  ;;==Free memory
  data = !NULL

  ;;==Return kmag struct
  return, kmag
end
