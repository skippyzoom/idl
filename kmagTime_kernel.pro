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
@load_eppic_params
;; ;; timestep = nout*(indgen(ntMax/2)+ntMax/2+1)
timestep = nout*(lindgen(ntMax-1)+1)
dataName = 'den1'
;; dataType = 'ph5'
;; @calc_kmagTime
;; save, filename='kmagTime-'+dataName+'.sav', $
;;       kmagTime,tVals,kmag_info
restore, filename='kmagTime-'+dataName+'.sav',/verbose

;; lWant = 3.0
;; ikWant = find_closest(kmag_info.kvals,2*!pi/lWant)
;; kmag_rmsTheta = rms(reform(kmagTime[ikWant,*,*]),dim=1)
;; title = "$\lambda$ = "+string(lWant,format='(f4.1)')
;; title = strcompress(title,/remove_all)
;; xVals = dt*timestep
;; yVals = kmag_rmsTheta
;; ;; yVals = alog(kmag_rmsTheta)
;; plt = plot(xVals,yVals,xstyle=1,/buffer,title=title)
;; pltName = 'kmagTime-rms_'+strcompress(fix(lWant),/remove_all)+'m.pdf'
;; print, "Saving ",pltName,"..."
;; plt.save, pltName
;; plt.close
;; print, "Finished"

;; lWant = 8.0
;; ikWant = find_closest(kmag_info.kvals,2*!pi/lWant)
;; kmag_rmsTheta = rms(reform(kmagTime[ikWant,*,*]),dim=1)
;; title = "$\lambda$ = "+string(lWant,format='(f4.1)')
;; title = strcompress(title,/remove_all)
;; xVals = dt*timestep
;; yVals = kmag_rmsTheta
;; ;; yVals = alog(kmag_rmsTheta)
;; plt = plot(xVals,yVals,xstyle=1,/buffer,title=title)
;; pltName = 'kmagTime-rms_'+strcompress(fix(lWant),/remove_all)+'m.pdf'
;; print, "Saving ",pltName,"..."
;; plt.save, pltName
;; plt.close
;; print, "Finished"

;-->FIX ASPECT ANGLE
kmag_rmsTheta = transpose(rms(kmagTime,dim=2))
ikLo = find_closest(kmag_info.kvals,2*!pi/(dx*grid.nx*nout_avg/10.0))
ikHi = find_closest(kmag_info.kvals,2*!pi/(5*dx))
xVals = dt*timestep
yVals = kmag_info.kvals[ikLo:ikHi]
imgData = alog(kmag_rmsTheta[*,ikLo:ikHi])
img = image(imgData,xVals,yVals, $
            rgb_table=39,xtitle="Time [s]",ytitle="|k|",title="Wave Power Growth", $
            font_name="Times", $
            /buffer)
imgName = "kmagTime_rms.pdf"
print, "Saving ",imgName,"..."
img.save, imgName
img.close
print, "Finished"
;-->Overplot lines of a few fiducial wavelengths (e.g. 3 m, 8 m).
