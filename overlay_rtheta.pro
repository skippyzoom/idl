;+
; Overlay specified radial and axial lines onto an image
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
function overlay_rtheta, img,r,theta, $                         
                         lun=lun, $
                         degrees=degrees, $
                         r_color=r_color, $
                         r_thick=r_thick, $
                         r_linestyle=r_linestyle, $
                         theta_color=theta_color, $
                         theta_linestyle=theta_linestyle, $
                         theta_thick=theta_thick

  if n_elements(lun) eq 0 then lun = -1

  nr = n_elements(r)
  for ir=0,nr-1 do $
     ell = ellipse(0.0,0.0, $
                   major = r[ir], $
                   target = img, $
                   /data, $
                   color = r_color, $
                   thick = r_thick, $
                   linestyle = r_linestyle, $
                   fill_background = 0)
  nth = n_elements(theta)
  max_r = max(r)
  if keyword_set(degrees) then theta *= !dtor
  for ith=0,nth-1 do $
     lin = polyline([0.0,max_r*cos(theta[ith])], $
                    [0.0,max_r*sin(theta[ith])], $
                    target = img, $
                    /data, $
                    color=theta_color, $
                    linestyle=theta_linestyle, $
                    thick=theta_thick)

  return, img
end
