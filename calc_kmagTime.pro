;+
; Take the FFT of some data and calculate the
; array of power as a function of k value (k),
; look angle (theta), time (t), and, 
; optionally, aspect angle (alpha)
;-
@load_eppic_params
if n_elements(dataName) eq 0 then dataName = 'den1'
if n_elements(dataType) eq 0 then dataType = 'ph5'
if n_elements(nTheta) eq 0 then nTheta = 360
if n_elements(nAlpha) eq 0 then nAlpha = 1
if n_elements(alpha) eq 0 then alpha = 0.0
if n_elements(timestep) eq 0 then timestep = 0

data = read_xxx_data(dataName, $
                     dataType, $
                     nx = grid.nx, $
                     ny = grid.ny, $
                     nz = grid.nz, $
                     timestep = timestep, $
                     path = 'parallel', $
                     /verbose)

data = fft_custom(data,/overwrite, $
                  /center, $
                  /normalize, $
                  /skip_time, $
                  /verbose)

kmag_info = kmag_interpolate(data[*,*,*,0], $
                             dx = dx*nout_avg, $
                             dy = dy*nout_avg, $
                             dz = dz*nout_avg, $
                             aspect = alpha, $
                             shape = 'cone', $
                             nTheta = nTheta, $
                             nAlpha = nAlpha, $
                             /info)
kmagTime = kmag_interpolate_loop(data, $
                                 dx = dx*nout_avg, $
                                 dy = dy*nout_avg, $
                                 dz = dz*nout_avg, $
                                 aspect = alpha, $
                                 shape = 'cone', $
                                 nTheta = nTheta, $
                                 nAlpha = nAlpha)
data = !NULL

kmagSize = size(kmagTime)
tVals = indgen(nTheta)
