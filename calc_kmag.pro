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
;    Consider using a keyword DT that will multiply nOmega in the
;    denominator of wMin and can also replace /single_time as 
;    follows: 
;       dt > 0 ==> do the time loop
;       dt = 0 ==> set dt = 1 (and do the time loop)
;       dt < 0 ==> same as setting /single_time
;    If dt isn't set, treat it as the dt = 0 case.    
;    **Problem: This function calls load_eppic_params.pro, thus
;    overwriting the input value of DT. That's fine, since it
;    then has access to dt and nout from the simulation, but this
;    may make the DT-keyword approach impractical or, at least,
;    awkward.
; -- Clear up the ambiguity between use of alpha for FFT Hanning
;    factor and for aspect angle.
;    
;-
function calc_kmag, data, $
                    ;; single_time=single_time, $
                    dt=dt, $
                    overwrite=overwrite, $
                    skip_time_fft=skip_time_fft, $
                    alpha=alpha, $
                    aspect=aspect, $
                    nTheta=nTheta, $
                    nAlpha=nAlpha, $
                    shape=shape, $
                    verbose=verbose

@load_eppic_params

  ;;==Defaults and guards
  if n_elements(nTheta) eq 0 then nTheta = 360
  if n_elements(nAlpha) eq 0 then nAlpha = 1
  if n_elements(alpha) eq 0 then alpha = 0.0
  if n_elements(aspect) eq 0 then aspect = 0.0

  if keyword_set(single_time) then begin
     data = fft_custom(data, $
                       overwrite = overwrite, $
                       /center, $
                       /normalize, $
                       /single_time, $
                       /verbose)

     ;;==Interpolate FFT from Cartesian to spherical
     kmag = kmag_interpolate(data, $
                             dx = dx*nout_avg, $
                             dy = dy*nout_avg, $
                             dz = dz*nout_avg, $
                             aspect = aspect, $
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
                          alpha = aspect, $
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
                                  aspect = aspect, $
                                  shape = shape, $
                                  nTheta = nTheta, $
                                  nAlpha = nAlpha)
  endelse

  ;;==Free memory
  data = !NULL

  ;;==If transforming time, include frequency increment (wMin)
  if ~keyword_set(skip_time_fft) then begin
     kmagSize = size(kmag.array)
     nOmega = kmagSize[kmagSize[0]]
     wMin = 2*!pi/(dt*nout*nOmega)
  endif
  kmag = create_struct(kmag,'wMin',wMin)

  ;;==Return kmag struct
  return, kmag
end
