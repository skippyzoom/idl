;+
; Create plots of spectral power as a function
; of |k|, angle, and frequency.
;-

@load_project

;; kmag = load_kmag(data = (transpose(data.den1,[1,0,2,3]))[768-128:768+127,*,*,*], $
;;                  filename = dataName[0]+'_kmag_freq.sav', $
;;                  ;; /restore, $
;;                  dt = dt*nout, $
;;                  alpha = 0.5, $
;;                  aspect = 0.0, $
;;                  nTheta = 360, $
;;                  nAlpha = 1, $
;;                  shape = 'disk', $
;;                  /verbose)

;; ;;==Create images
;; lambda = [3.0,8.3,12.0]
;; nLambda = n_elements(lambda)
;; strLambda = strcompress(string(lambda,format='(f4.1)'),/remove_all)
;; ;; name = 'k_freq-'+strLambda+'m-dB.pdf'
;; ;; for il=0,nLambda-1 do $
;; ;;    k_freq_image, kmag,lambda=lambda[il],name=name[il], $
;; ;;                  /power_dB
;; ;; name = 'k_freq-'+strLambda+'m-norm_t.pdf'
;; ;; for il=0,nLambda-1 do $
;; ;;    k_freq_image, kmag,lambda=lambda[il],name=name[il], $
;; ;;                  /normalize_theta
;; name = 'k_freq-'+strLambda+'m-norm_m.pdf'
;; for il=0,nLambda-1 do $
;;    k_freq_image, kmag,lambda=lambda[il],name=name[il], $
;;                  /normalize_max,/power_dB
