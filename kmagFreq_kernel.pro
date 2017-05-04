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

@general_params
;; timestep = nout*(indgen(ntMax/2)+ntMax/2+1)
timestep = nout*(lindgen(ntMax-1)+1)
dataName = 'den1'
dataType = 'phdf'
@calc_kmagFreq
save, filename='kmagFreq-'+dataName+'.sav', $
      kmagFreq,tVals,wVals,kmag_info

lWant = 3.0
@prep_kmagFreq
@kmagFreq.prm
@img_pdf

lWant = 8.0
@prep_kmagFreq
@kmagFreq.prm
@img_pdf

lWant = 12.0
@prep_kmagFreq
@kmagFreq.prm
@img_pdf

lWant = 24.0
@prep_kmagFreq
@kmagFreq.prm
@img_pdf
