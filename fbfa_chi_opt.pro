;+
; Helper function for calculating the optimal angle between wavevector
; and drift velocity fb_flow_angle runs from Dimant & Oppenheim (2004)
; Equation 34.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
function fbfa_chi_opt, path

  params = set_eppic_params(path=path)
  moments = read_moments(path=path)
  alt = strmid(file_basename(path),0,2)
  nui = hash('h0',1021.70, $
             'h1',610.055, $
             'h2',369.367)
  nue = hash('h0',964.595, $
             'h1',671.417, $
             'h2',490.508)
  wci = moments.dist1.wc 
  wce = abs(moments.dist0.wc)
  ki = wci/nui[alt]
  ke = wce/nue[alt]
  psi = 1.0/(ki*ke)

  num = 2*ki*(1+psi)
  den = ki^2-3

  return, 0.5*atan(num/den)
end
