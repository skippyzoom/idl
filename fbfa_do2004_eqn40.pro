function fbfa_do2004_eqn40, path, $
                            lun=lun, $
                            nkx=nkx, $
                            nky=nky, $
                            double=double, $
                            angle=angle


  if n_elements(lun) eq 0 then lun = -1
  if n_elements(nkx) eq 0 then nkx = 64
  if n_elements(nky) eq 0 then nky = 64
  if n_elements(angle) eq 0 then angle = 'theta'

  params = set_eppic_params(path=path)
  moments = read_moments(path=path)
  kb = 1.3807e-23
  E0 = params.Ey0_external

  alt = strmid(file_basename(path),0,2)
  nui = hash('h0',1021.70, $
             'h1',610.055, $
             'h2',369.367)
  nue = hash('h0',964.595, $
             'h1',671.417, $
             'h2',490.508)
  wci = abs(moments.dist1.wc)
  mi = params.md1
  qi = abs(params.qd1)
  ki = wci/nui[alt]
  ti = mean(moments.dist1.T)
  vti = sqrt(kb*ti/mi)
  wce = abs(moments.dist0.wc)
  me = params.md0
  qe = abs(params.qd0)
  ke = wce/nue[alt]

  uey = -qe*E0/(nue[alt]*me*(1+ke^2))
  uex = -ke*uey
  uiy = +qi*E0/(nui[alt]*mi*(1+ki^2))
  uix = +ki*uiy

  u0 = sqrt((uex-uix)^2 + (uey-uiy)^2)

  kxvec = 2*!pi*fftfreq(nkx,dx)
  kxvec = shift(kxvec,nkx/2-1)
  kyvec = 2*!pi*fftfreq(nky,dy)
  kyvec = shift(kyvec,nky/2-1)

  beta = fbfa_vd_angle(path)

  out_type = keyword_set(double) ? 5 : 4
  re = make_array(nkx,nky,type=out_type)
  im = make_array(nkx,nky,type=out_type)

  case 1B of
     strcmp(angle,'theta'): begin
        for ikx=0L,nkx-1 do begin
           for iky=0L,nky-1 do begin
              kx = kxvec[ikx]
              ky = kyvec[iky]
              kr = sqrt(kx^2 + ky^2)
              na = ki*nui[alt]*(u0/kr/vti)^2* $
                   (ky*kx*(cos(beta)^2-sin(beta)^2) + $
                    cos(beta)*sin(beta)*(ky^2-kx^2))
              nb = u0*(kx*cos(beta)+ky*sin(beta))
              db = nb
              da = nui[alt]
              re[ikx,iky] = (na*da + nb*db)/(da^2 + db^2)
              im[ikx,iky] = (na*db - nb*da)/(da^2 + db^2)
           endfor
        endfor
     end
     strcmp(angle,'chi'): begin
        for ikx=0L,nkx-1 do begin
           for iky=0L,nky-1 do begin
              kx = kxvec[ikx]
              ky = kyvec[iky]
              kr = sqrt(kx^2 + ky^2)
              na = ki*nui[alt]*(u0/kr/vti)^2*kx*ky
              nb = u0*kx
              db = nb
              da = nui[alt]
              re[ikx,iky] = (na*da + nb*db)/(da^2 + db^2)
              im[ikx,iky] = (na*db - nb*da)/(da^2 + db^2)
           endfor
        endfor
     end
     else: begin
        printf, lun, "[FBFA_DO2004_EQN40] Angle may be 'theta' or 'chi'"
     end
  endcase
  re *= (2.0/3.0)
  im *= (2.0/3.0)

  return, {re:re, im:im}
end
