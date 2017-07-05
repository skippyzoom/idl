;+
; Create plots of spectral power as a function
; of |k|, angle, and frequency.
;
; TO DO
; -- Allow user to restore kmag struct to 
;    save time.
;-

;;==Load density data from simulation
@load_eppic_params
if n_elements(dataName) eq 0 then dataName = 'den1'
if n_elements(dataType) eq 0 then dataType = 'ph5'
if n_elements(timestep) eq 0 then timestep = nout*(lindgen(ntMax-1)+1)
data = load_eppic_data(dataName,dataType,timestep=timestep)

;; ;;==Calculate |k|,angle,freq.
;; kmag = calc_kmag(data.den1, $
;;                  dt = dt*nout, $
;;                  alpha = 0.5, $
;;                  aspect = 0.0, $
;;                  nTheta = 360, $
;;                  nAlpha = 1, $
;;                  shape = 'disk', $
;;                  /verbose)

;; ;;==Save the interpolation struct
;; save, kmag,filename='kmag_freq.sav'

;; ;; ;;==Restore (TEMP)
;; ;; restore, filename='kmag_freq.sav',/verbose

kmag = load_kmag(data.den1, $
                 dt = dt*nout, $
                 alpha = 0.5, $
                 aspect = 0.0, $
                 nTheta = 360, $
                 nAlpha = 1, $
                 shape = 'disk', $
                 /restore, $
                 /verbose)

;;==Create images
lambda = [3.0,8.3,12.0]
nLambda = n_elements(lambda)
strLambda = strcompress(string(lambda,format='(f4.1)'),/remove_all)
;; name = 'k_freq-'+strLambda+'m-dB.pdf'
;; for il=0,nLambda-1 do $
;;    k_freq_image, kmag,lambda=lambda[il],name=name[il], $
;;                  /power_dB
;; name = 'k_freq-'+strLambda+'m-norm_t.pdf'
;; for il=0,nLambda-1 do $
;;    k_freq_image, kmag,lambda=lambda[il],name=name[il], $
;;                  /normalize_theta
name = 'k_freq-'+strLambda+'m-norm_m.pdf'
for il=0,nLambda-1 do $
   k_freq_image, kmag,lambda=lambda[il],name=name[il], $
                 /normalize_max,/power_dB
