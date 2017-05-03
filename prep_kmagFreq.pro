;+
; Prepare kmagFreq data for graphics
;-
imgName = 'kmagFreq'
imgName += '-'+strcompress(fix(lWant),/remove_all)+'m'
imgName += '.pdf'

ikWant = find_closest(kmag_info.kVals,2*!pi/lWant)
imgData = reform(kmagFreq[ikWant,*,*])
imgData = imgData^2
imgData = 10*alog10(imgData)
;; for it=0,nTheta-1 do imgData[it,*] /= max(abs(imgData[it,*]))
xData = tVals
yData = wVals/kmag_info.kVals[ikWant]
