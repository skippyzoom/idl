;+
; Script for making movies of E from a plane of EPPIC phi data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;; ;;==Read a plane of phi data
;; @phi_read_plane

;;==Calculate the gradient
efield = calc_grad_xyzt(phi,dx=dx,dy=dy,scale=-1)

;;==Extract components
Ex = efield.x
Ey = efield.y
efield = !NULL

;;==Make images of x component
@Ex_movies

;; ;;==Make plots of average x component
;; @Ex_mean_plots --> movies of this?

;;==Make images of y component
@Ey_movies

;; ;;==Make plots of average x component
;; @Ey_mean_plots --> movies of this?

;;==Make images of magnitude
Er = sqrt(Ex*Ex + Ey*Ey)
@Er_movies

;;==Make images of angle
Et = atan(Ey,Ex)
@Et_movies
