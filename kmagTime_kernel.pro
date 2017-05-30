;+
; This script contains all the commands for 
; generating and plotting arrays of spectral
; power as a function of wave number (k),
; flow angle (theta), frequency (omega) or 
; time (t), and, optionally, aspect angle
; (alpha). The user should call this script
; within the target directory or from a batch
; script that changes to target directories.
;
; This script uses the graphics approach of
; loading parameters from a .prm file, then
; passing them to a graphics function via the
; _EXTRA keyword. This allows the user to 
; tune graphics parameters for a specific 
; quantity, and to save them in one dedicated
; file. 
;
; Currently, this script assumes the user will
; update it for a specific project by, e.g., 
; changing timestep and lWant.
;-
;; @load_eppic_params
;; ;; timestep = nout*(indgen(ntMax/2)+ntMax/2+1)
;; timestep = nout*(lindgen(ntMax-1)+1)
;; dataName = 'den1'
;; dataType = 'ph5'
;; @calc_kmagTime
;; save, filename='kmagTime-'+dataName+'.sav', $
;;       kmagTime,tVals,kmag_info

lWant = 3.0
ikWant = find_closest(kmag_info.kvals,2*!pi/lWant)
kmag_rmsTheta = rms(reform(kmagTime[ikWant,*,*]),dim=1)
title = "$\lambda$ = "+string(lWant,format='(f4.1)')
title = strcompress(title,/remove_all)
plt = plot(dt*timestep,kmag_rmsTheta,xstyle=1,/buffer,title=title,yrange=[0,0.04])
pltName = 'kmagTime-rms_'+strcompress(fix(lWant),/remove_all)+'m.pdf'
print, "Saving ",pltName,"..."
plt.save, pltName
plt.close
print, "Finished"

lWant = 8.0
ikWant = find_closest(kmag_info.kvals,2*!pi/lWant)
kmag_rmsTheta = rms(reform(kmagTime[ikWant,*,*]),dim=1)
title = "$\lambda$ = "+string(lWant,format='(f4.1)')
title = strcompress(title,/remove_all)
plt = plot(dt*timestep,kmag_rmsTheta,xstyle=1,/buffer,title=title,yrange=[0,0.04])
pltName = 'kmagTime-rms_'+strcompress(fix(lWant),/remove_all)+'m.pdf'
print, "Saving ",pltName,"..."
plt.save, pltName
plt.close
print, "Finished"
