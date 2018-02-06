;+
; Analysis of EPPIC moments*.out files.
;
; This program reads in the moments*.out files and stores
; useful quantities including Hall and Pederson drifts,
; sound speed, effective collision frequencies (calculated 
; from drifts; in general different from input values), 
; and the Psi parameter.
;
; The original moment_plots.pro was written by Meers Oppenheim
; in May 2006. This version analyzes either pure PIC or hybrid
; runs, based on the value of efield_algorithm.
;
; NOTES
; -- This function assumes that distribution 0 is magnetized
;    and distribution 1 is unmagnetized when it calculates
;    collision frequencies.
; -- This function assumes that B0 is aligned with one 
;    physical coordinate, then rotates the logical coordinates
;    so that B0 is aligned with z. It does this to simplify
;    some calculations that require vector components (e.g.,
;    nu0 and nu1)
; -- This function appears to calculate nu1 from the unmagnetized,
;    cold perpendicular drift equation but that's really just a
;    way to get the Pedersen drift correct even when the simula-
;    tion domain is rotated from the physical domain (e.g., 
;    the user set up the run with simulation axes x & y
;    corresponding to physical axes y & -x)
;-

function analyze_moments, path=path

  ;;==Set default path
  if n_elements(path) eq 0 then path = './'

  ;;==Read sim parameters and moment files
  params = set_eppic_params(path=path)
  if file_test(path+path_sep()+'domain000',/directory) then $
     bp = path+path_sep()+'domain000/' $
  else bp = './'
  if file_test(bp+'moments0.out') then $
     moments0=readarray(bp+'moments0.out',13,lineskip=1)
  if file_test(bp+'moments1.out') then $
     moments1=readarray(bp+'moments1.out',13,lineskip=1)

  if n_elements(params) ne 0 then begin

     ;;==Set default parameters
     coll_rate0 = float(params.coll_rate0)
     coll_rate1 = float(params.coll_rate1)
     md0 = float(params.md0)
     md1 = float(params.md1)
     qd0 = float(params.qd0)
     qd1 = float(params.qd1)
     Bx0 = float(params.Bx)
     By0 = float(params.By)
     Bz0 = float(params.Bz)
     B0 = sqrt(Bx0^2 + By0^2 + Bz0^2)
     Ex0 = float(params.Ex0_external)
     Ey0 = float(params.Ey0_external)
     Ez0 = float(params.Ez0_external)
     efield_algorithm = params.efield_algorithm
     vx0d0 = float(params.vx0d0)
     vy0d0 = float(params.vy0d0)
     vz0d0 = float(params.vz0d0)
     vx0d1 = float(params.vx0d1)
     vy0d1 = float(params.vy0d1)
     vz0d1 = float(params.vz0d1)
     vxthd0 = float(params.vxthd0)
     vythd0 = float(params.vythd0)
     vzthd0 = float(params.vzthd0)
     vxthd1 = float(params.vxthd1)
     vythd1 = float(params.vythd1)
     vzthd1 = float(params.vzthd1)
     if (n_elements(kb) eq 0) then if (md0 lt 1e-8) then kb = 1.38e-23 else kb = 1

     ;;==Create constant electron moments for QN, inertialess electrons
     if efield_algorithm eq 1 or efield_algorithm eq 2 then begin
        moments0 = moments1*0.0
        moments0[1,*] = vx0d0     ;x drift velocity
        moments0[2,*] = vxthd0^2  ;x thermal velocity
        moments0[5,*] = vy0d0     ;y drift velocity
        moments0[6,*] = vythd0^2  ;y thermal velocity
        moments0[9,*] = vz0d0     ;z drift velocity
        moments0[10,*] = vzthd0^2 ;z thermal velocity
     endif

     ;;==Transform coordinates for 3-D
     case 1B of
        (B0 eq Bz0): begin
           vxpd0 = moments0[1,*]
           vypd0 = moments0[5,*]
           vzpd0 = moments0[9,*]
           vxpd1 = moments1[1,*]
           vypd1 = moments1[5,*]
           vzpd1 = moments1[9,*]
           Exp = Ex0
           Eyp = Ey0
           Ezp = Ez0
        end
        (B0 eq By0): begin
           vxpd0 = moments0[1,*]
           vypd0 = -moments0[9,*]
           vzpd0 = moments0[5,*]
           vxpd1 = moments1[1,*]
           vypd1 = -moments1[9,*]
           vzpd1 = moments1[5,*]
           Exp = Ex0
           Eyp = -Ez0
           Ezp = Ey0
        end
        (B0 eq Bx0): begin
           vxpd0 = -moments0[9,*]
           vypd0 = moments0[5,*]
           vzpd0 = moments0[1,*]
           vxpd1 = -moments1[9,*]
           vypd1 = moments1[5,*]
           vzpd1 = moments1[1,*]
           Exp = -Ez0
           Eyp = Ey0
           Ezp = Ex0
        end
     endcase
                                ;--------;
                                ; Hybrid ;
                                ;--------;
     if (efield_algorithm eq 1) || (efield_algorithm eq 2) then begin

        ;;==Theoretical values
        ;;--cyclotron frequencies
        wc0  = qd0*B0/md0
        wc1  = qd1*B0/md1
        ;;--parallel mobilities
        if (coll_rate0 ne 0) then $
           mu0_start = qd0/coll_rate0/md0 $
        else mu0_start = 0
        if (coll_rate1 ne 0) then $
           mu1_start = qd1/coll_rate1/md1 $
        else mu1_start = 0

        ;;--Pedersen mobilities and drift
        ped0_start = mu0_start/(1+wc0^2/(coll_rate0*1.0)^2)
        ped1_start = mu1_start/(1+wc1^2/(coll_rate1*1.0)^2)
        v_ped0_start= Eyp*ped0_start
        v_ped1_start= Eyp*ped1_start
        ;;--Hall mobilities and drift
        hall0_start = qd0*wc0/(md0*(wc0^2+coll_rate0^2))
        hall1_start = qd1*wc1/(md1*(wc1^2+coll_rate1^2))
        v_hall0_start = Eyp*hall0_start
        v_hall1_start = Eyp*hall1_start
        ;;--Temperatures and acoustic speed
        ;; T0_start = 0.5*(md0/kb)*(vxthd0^2+vythd0^2+vzthd0^2)
        ;; T1_start = 0.5*(md1/kb)*(vxthd1^2+vythd1^2+vzthd1^2)
        Tx0_start = (md0/kb)*vxthd0^2
        Ty0_start = (md0/kb)*vythd0^2
        Tz0_start = (md0/kb)*vzthd0^2
        T0_start = (Tx0_start+Ty0_start+Tz0_start)/3.0
        Tx1_start = (md1/kb)*vxthd1^2
        Ty1_start = (md1/kb)*vythd1^2
        Tz1_start = (md1/kb)*vzthd1^2
        T1_start = (Tx1_start+Ty1_start+Tz1_start)/3.0
        Cs_start = sqrt(kb*(T0_start + T1_start)/md1)
        ;;--Psi
        Psi_start = abs(coll_rate0*coll_rate1/(wc0*wc1))
        driver = (Eyp/B0)/(1+Psi_start)

        ;;==Simulated values
        ;;--Collision frequencies and Psi
        nu0 = moments1[5,*]*0.0 + coll_rate0                        ;From Input value
        ;; nu1 = (Eyp/vypd1)*(qd1/md1) ;From Ped drift        
        nu1 = (qd1/md1)*(Exp*vxpd1 + Eyp*vypd1)/(vxpd1^2 + vypd1^2) ;From perp drift
        Psi = abs(nu0*nu1/(wc0*wc1))
        driver = (Eyp/B0)/(1+Psi)
        ;;--parallel mobilities
        !NULL = where(nu0 ne 0.0,count)
        if (count ne 0) then $
           mu0 = qd0/nu0/md0 $
        else mu0 = 0.0
        !NULL = where(nu1 ne 0.0,count)
        if (count ne 0) then $
           mu1 = qd1/nu1/md1 $
        else mu1 = 0.0
        ;;--Pedersen mobilities and drift
        ped0 = mu0/(1+wc0^2/(nu0*1.0)^2)
        ped1 = mu1/(1+wc1^2/(nu1*1.0)^2)
        v_ped0 = Eyp*ped0
        v_ped1 = Eyp*ped1
        ;;--Hall mobilities and drift
        hall0 = qd0*wc0/(md0*(wc0^2+nu0^2))
        hall1 = qd1*wc1/(md1*(wc1^2+nu1^2))
        v_hall0 = Eyp*hall0
        v_hall1 = Eyp*hall1
        ;;--Temperatures and acoustic speed
        ;; T0 = (moments0[2,*] + moments0[6,*] + moments0[10,*])/3. * md0/kb
        ;; T1 = (moments1[2,*] + moments1[6,*] + moments1[10,*])/3. * md1/kb
        Tx0 = (md0/kb)*moments0[2,*]
        Ty0 = (md0/kb)*moments0[6,*]
        Tz0 = (md0/kb)*moments0[10,*]
        T0 = (Tx0+Ty0+Tz0)/3.0
        Tx1 = (md1/kb)*moments1[2,*]
        Ty1 = (md1/kb)*moments1[6,*]
        Tz1 = (md1/kb)*moments1[10,*]
        T1 = (Tx1+Ty1+Tz1)/3.0
        Cs = sqrt(kb*(T0+T1)/md1)
     endif $                    ;hybrid

                                ;----------;
                                ; Pure PIC ;
                                ;----------;
     else begin
        ;;==Theoretical values
        ;;--cyclotron frequencies
        wc0  = qd0*B0/md0
        wc1  = qd1*B0/md1
        ;;--parallel mobilities
        if (coll_rate0 ne 0) then $
           mu0_start = qd0/coll_rate0/md0 $
        else mu0_start = 0
        if (coll_rate1 ne 0) then $
           mu1_start = qd1/coll_rate1/md1 $
        else mu1_start = 0
        ;;--Pedersen mobilities and drift
        ped0_start = mu0_start/(1+wc0^2/(coll_rate0)^2)
        ped1_start = mu1_start/(1+wc1^2/(coll_rate1)^2)
        v_ped0_start= Eyp*ped0_start
        v_ped1_start= Eyp*ped1_start
        ;;--Hall mobilities and drift
        hall0_start = qd0*wc0/(md0*(wc0^2+coll_rate0^2))
        hall1_start = qd1*wc1/(md1*(wc1^2+coll_rate1^2))
        v_hall0_start = Eyp*hall0_start
        v_hall1_start = Eyp*hall1_start
        ;;--Temperatures and acoustic speed
        ;; T0_start = 0.5*(md0/kb)*(vxthd0^2+vythd0^2+vzthd0^2)
        ;; T1_start = 0.5*(md1/kb)*(vxthd1^2+vythd1^2+vzthd1^2)
        Tx0_start = (md0/kb)*vxthd0^2
        Ty0_start = (md0/kb)*vythd0^2
        Tz0_start = (md0/kb)*vzthd0^2
        T0_start = (Tx0_start+Ty0_start+Tz0_start)/3.0
        Tx1_start = (md1/kb)*vxthd1^2
        Ty1_start = (md1/kb)*vythd1^2
        Tz1_start = (md1/kb)*vzthd1^2
        T1_start = (Tx1_start+Ty1_start+Tz1_start)/3.0
        Cs_start = sqrt(kb*(T0_start + T1_start)/md1)
        ;;--Psi
        Psi_start = abs(coll_rate0*coll_rate1/(wc0*wc1))
        driver = (Eyp/B0)/(1+Psi_start)

        ;;==Simulated values
        ;;--Collision frequencies and Psi
        ;; nu0 = wc0*vypd0/vxpd0               ;From Hall drift
        nu0 = (Ezp/vzpd0)*(qd0/md0)                                 ;From parallel drift
        ;; nu1 = (Eyp/vypd1)*(qd1/md1)         ;From Ped drift
        nu1 = (qd1/md1)*(Exp*vxpd1 + Eyp*vypd1)/(vxpd1^2 + vypd1^2) ;From perp drift
        ;; nu0 = 0.5*qd0*Eyp/(md0*vypd0)*(1 + sqrt(1-(2*md0*vypd0*wc0/(qd0*Eyp))^2))
        ;; nu1 = 0.5*qd1*Eyp/(md1*vypd1)*(1 + sqrt(1-(2*md1*vypd1*wc1/(qd1*Eyp))^2))
        ;; nu0 = 0.5*qd0*Eyp/(md0*vypd0)*(1 - sqrt(1-(2*md0*vypd0*wc0/(qd0*Eyp))^2))
        ;; nu1 = 0.5*qd1*Eyp/(md1*vypd1)*(1 - sqrt(1-(2*md1*vypd1*wc1/(qd1*Eyp))^2))
        Psi = abs(nu0*nu1/(wc0*wc1))
        driver = (Eyp/B0)/(1+Psi)
        ;;--parallel mobilities
        !NULL = where(nu0 ne 0.0,count)
        if (count ne 0) then $
           mu0 = qd0/nu0/md0 $
        else mu0 = 0.0
        !NULL = where(nu1 ne 0.0,count)
        if (count ne 0) then $
           mu1 = qd1/nu1/md1 $
        else mu1 = 0.0
        ;;--Pedersen mobilities and drift
        ped0 = mu0/(1+wc0^2/(nu0*1.0)^2)
        ped1 = mu1/(1+wc1^2/(nu1*1.0)^2)
        v_ped0 = Eyp*ped0
        v_ped1 = Eyp*ped1
        ;;--Hall mobilities and drift
        hall0 = qd0*wc0/(md0*(wc0^2+nu0^2))
        hall1 = qd1*wc1/(md1*(wc1^2+nu1^2))
        v_hall0 = Eyp*hall0
        v_hall1 = Eyp*hall1
        ;;--Temperatures and acoustic speed
        ;; T0 = (moments0[2,*] + moments0[6,*] + moments0[10,*])/3. * md0/kb
        ;; T1 = (moments1[2,*] + moments1[6,*] + moments1[10,*])/3. * md1/kb
        Tx0 = (md0/kb)*moments0[2,*]
        Ty0 = (md0/kb)*moments0[6,*]
        Tz0 = (md0/kb)*moments0[10,*]
        T0 = (Tx0+Ty0+Tz0)/3.0
        Tx1 = (md1/kb)*moments1[2,*]
        Ty1 = (md1/kb)*moments1[6,*]
        Tz1 = (md1/kb)*moments1[10,*]
        T1 = (Tx1+Ty1+Tz1)/3.0
        Cs = sqrt(kb*(T0+T1)/md1)
     endelse                    ;pure PIC

     dist0 = {vx_m1:reform(moments0[1,*]), $
              vx_m2:reform(moments0[2,*]), $
              vx_m3:reform(moments0[3,*]), $
              vx_m4:reform(moments0[4,*]), $
              vy_m1:reform(moments0[5,*]), $
              vy_m2:reform(moments0[6,*]), $
              vy_m3:reform(moments0[7,*]), $
              vy_m4:reform(moments0[8,*]), $
              vz_m1:reform(moments0[9,*]), $
              vz_m2:reform(moments0[10,*]), $
              vz_m3:reform(moments0[11,*]), $
              vz_m4:reform(moments0[12,*]), $
              wc:wc0, $
              mu_start:mu0_start, $
              ped_start:ped0_start, $
              v_ped_start:v_ped0_start, $
              hall_start:hall0_start, $
              v_hall_start:v_hall0_start, $
              Tx_start:Tx0_start, $
              Ty_start:Ty0_start, $
              Tz_start:Tz0_start, $
              T_start:T0_start, $
              nu_start:coll_rate0, $
              nu:nu0, $
              ped:ped0, $
              v_ped:v_ped0, $
              hall:hall0, $
              v_hall:v_hall0, $
              Tx:Tx0, $
              Ty:Ty0, $
              Tz:Tz0, $
              T:T0}
     dist1 = {vx_m1:reform(moments1[1,*]), $
              vx_m2:reform(moments1[2,*]), $
              vx_m3:reform(moments1[3,*]), $
              vx_m4:reform(moments1[4,*]), $
              vy_m1:reform(moments1[5,*]), $
              vy_m2:reform(moments1[6,*]), $
              vy_m3:reform(moments1[7,*]), $
              vy_m4:reform(moments1[8,*]), $
              vz_m1:reform(moments1[9,*]), $
              vz_m2:reform(moments1[10,*]), $
              vz_m3:reform(moments1[11,*]), $
              vz_m4:reform(moments1[12,*]), $
              wc:wc1, $
              mu_start:mu1_start, $
              ped_start:ped1_start, $
              v_ped_start:v_ped1_start, $
              hall_start:hall1_start, $
              v_hall_start:v_hall1_start, $
              Tx_start:Tx1_start, $
              Ty_start:Ty1_start, $
              Tz_start:Tz1_start, $
              T_start:T1_start, $
              nu_start:coll_rate1, $
              nu:nu1, $
              ped:ped1, $
              v_ped:v_ped1, $
              hall:hall1, $
              v_hall:v_hall1, $
              Tx:Tx1, $
              Ty:Ty1, $
              Tz:Tz1, $
              T:T1}

     moment_struct = {dist0:dist0, dist1:dist1, $
                      Psi_start:Psi_start, Psi:Psi, $
                      Cs_start:Cs_start, Cs:Cs, driver:driver}
     
     return, moment_struct
  endif $
  else begin
     print, "[ANALYZE_MOMENTS] Could not read parameter file"
     return, !NULL
  endelse
end
