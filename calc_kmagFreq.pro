;+
; Take the FFT of some data and calculate the
; array of power as a function of k value (k),
; look angle (theta), frequency (omega), and, 
; optionally, aspect angle (alpha)
;-

@general_params
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
                  alpha = 0.5, $
                  /normalize, $
                  /swap_time, $
                  /zero_dc, $
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
kmagFreq = kmag_interpolate_loop(data, $
                                 dx = dx*nout_avg, $
                                 dy = dy*nout_avg, $
                                 dz = dz*nout_avg, $
                                 aspect = alpha, $
                                 shape = 'cone', $
                                 nTheta = nTheta, $
                                 nAlpha = nAlpha)
data = !NULL

kmagSize = size(kmagFreq)
nOmega = kmagSize[kmagSize[0]]
wMin = 2*!pi/(dt*nOmega*nout)
;; if strcmp(dataName,'den0') then wMin /= subcycle0
;; if strcmp(dataName,'den1') then wMin /= subcycle1
;; if strcmp(dataName,'den2') then wMin /= subcycle2
;; if strcmp(dataName,'den3') then wMin /= subcycle3
wVals = wMin*(dindgen(nOmega)-nOmega/2)
tVals = indgen(nTheta)
