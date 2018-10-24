;+
; Helper function for calculating the angular deflection of the drift
; velocity from the Hall direction in fb_flow_angle runs
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
function fbfa_vd_angle, path

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
  me = params.md0
  mi = params.md1
  ki = wci/nui[alt]
  ke = wce/nue[alt]
  bigth = sqrt((me*nue[alt])/(mi*nui[alt]))

  num = (1+ki^2)+bigth^2*(1+ke^2)
  den = bigth^2*ki*(1+ke^2)-ke*(1+ki^2)

  return, atan(num/den)
end
