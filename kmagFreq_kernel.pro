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
;-

@calc_kmagFreq
save, filename=swap_extension(imgName,'.pdf','.sav'), $
      kmagFreq,tVals,wVals,kmag_info

ikWant = find_closest(kmag_info.kVals,2*!pi/lWant)
imgData = reform(kmagFreq[ikWant,*,*])
imgData = imgData^2
;; imgData = 10*alog10(imgData)
for it=0,nTheta-1 do imgData[it,*] /= max(abs(imgData[it,*]))
xData = tVals
yData = wVals/kmag_info.kVals[ikWant]
;; @kmag_img.prm
;; img = image(imgData,xData,yData,_EXTRA=prm)
;; @kmag_clr.prm
;; clr = colorbar(target=img,_EXTRA=prm)
;; print, "Saving ",imgName,"..."
;; img.save, imgName
;; img.close
;; print, "Finished"
@kmagFreq.prm
@img_pdf
