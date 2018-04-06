;+
; Script for analyzing E fields from a plane of EPPIC phi data.
;-

;;==Read a plane of phi data
@phi_read_plane.scr

;;==Calculate the gradient
efield = calc_grad_xyzt(phi,dx=dx,dy=dy,scale=-1)

;;==Extract components
Ex = efield.x
Ey = efield.y
efield = !NULL

;;==Make images of x component
@Ex_kw.scr
filename = pd.path+path_sep()+'frames'+ $
           path_sep()+'efield_x-'+time.index+'.pdf'
data_graphics, Ex,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw

;;==Make images of y component
@Ey_kw.scr
filename = pd.path+path_sep()+'frames'+ $
           path_sep()+'efield_y-'+time.index+'.pdf'
data_graphics, Ey,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw

;;==Calculate magnitude and angle
Er = sqrt(Ex*Ex + Ey*Ey)
Et = atan(Ey,Ex)

;;==Make images of magnitude
@Er_kw.scr
filename = pd.path+path_sep()+'frames'+ $
           path_sep()+'efield_r-'+time.index+'.pdf'
data_graphics, Er,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw

;;==Make images of angle
@Et_kw.scr
filename = pd.path+path_sep()+'frames'+ $
           path_sep()+'efield_t-'+time.index+'.pdf'
data_graphics, Et,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
