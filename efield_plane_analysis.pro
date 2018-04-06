;+
; Script for analyzing E fields from a plane of EPPIC phi data.
;-

;;==Read a plane of phi data
@phi_read_plane

;;==Calculate the gradient
efield = calc_grad_xyzt(phi,dx=dx,dy=dy,scale=-1)

;;==Extract components
Ex = efield.x
Ey = efield.y
efield = !NULL

;; ;;==Make images of x component
;; @Ex_images

;;==Make plots of average x component
Ex_mean = mean(Ex,dim=1)
filename = pd.path+path_sep()+'frames'+ $
           path_sep()+'efield_x-x_mean-'+time.index+'.pdf'
data_graphics, ydata,Ex_mean, $
               /make_frame, $
               filename = filename


;; ;;==Make images of y component
;; @Ey_images

;; ;;==Make images of magnitude
;; Er = sqrt(Ex*Ex + Ey*Ey)
;; @Er_images

;; ;;==Make images of angle
;; Et = atan(Ey,Ex)
;; @Et_images