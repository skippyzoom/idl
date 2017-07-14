;; pro moment_analysis

;+
; Analysis of moments*.out files. This program is based on
; moment_plots.pro (M. Oppenheim). 
;
; This program reads in the necessary
; data files and produces plots of Hall and Pederson drifts,
; sound speed, effective collision frequencies (calculated 
; from drifts -- in general different from input values), 
; and the Psi parameter.
;
; The original moment_plots.pro was written by Meers Oppenheim
; in May 2006. This version analyzes either pure PIC or hybrid
; runs, based on the value of efield_algorithm.
;
; Notes on nue_scale and nui_scale:
;    Normally, moment_analysis.pro calculates the
;    collision frequencies as a function of time
;    via the Pedersen and Hall drifts for a subthreshold 
;    run. Therefore, it may not find physically meaningful
;    expressions when |E_0|=0. The appropriate scale factors
;    may be used to scale the input collision frequency to
;    the actual frequencies calculated during simulation runs.
;
;    Values for hybrid simulation came from the coupled FB/GD 
;    project, using PPIC3D. Values for pure PIC have not been
;    determined. 
;
;    Average collision frequencies may be unphysically high if
;    the simulation runs for too few time steps for the calculated 
;    frequency to have time to settle down. In that case, this 
;    routine will reset the average collision frequency to the 
;    scaled value.
;
; Set make_plots = 0 to suppress plotting when you only want 
; this routine to calculate quantities for other routines.
;-

function analyze_moments, ntMax
  ;;==Read sim parameters and moment files
  @eppic_defaults.pro
  ;; @moments3d
  if file_test('domain000',/directory) then bp = 'domain000/' $
  else bp = './'
  if file_test(bp+'moments0.out') then $
     moments0=readarray(bp+'moments0.out',13,lineskip=1)
  if file_test(bp+'moments1.out') then $
     moments1=readarray(bp+'moments1.out',13,lineskip=1)

  ;;==Defaults
  if n_elements(baseLabel) eq 0 then baseLabel = ''
  if n_elements(vzthd0) eq 0 then vzthd0 = 0.
  if n_elements(vz0d0) eq 0 then vz0d0 = 0.
  if n_elements(vzthd1) eq 0 then vzthd1 = 0.
  if n_elements(vz0d1) eq 0 then vz0d1 = 0.
  ;; if n_elements(Bz) eq 0 and n_elements(Bx) ne 0 then Bz = Bx
  ;; if hdf_output_arrays then Bz = Bx & Bx = 0.0
  if (n_elements(kb) eq 0) then if (md0 lt 1e-8) then kb = 1.38e-23 else kb = 1
  if (n_elements(coll_rate0) eq 0) then coll_rate0 = 0.
  if (n_elements(coll_rate1) eq 0) then coll_rate1 = 0.
  if (n_elements(Bx) eq 0) then Bx = 0.
  if (n_elements(By) eq 0) then By = 0.
  if (n_elements(Bz) eq 0) then Bz = 0.
  B0 = sqrt(Bx^2 + By^2 + Bz^2)
  if (n_elements(Ex0_external) eq 0) then Ex0_external = 0.
  if (n_elements(Ey0_external) eq 0) then Ey0_external = 0.
  if (n_elements(Ez0_external) eq 0) then Ez0_external = 0.
  if n_elements(efield_algorithm) eq 0 then efield_algorithm = 0
  if n_elements(make_plots) eq 0 then make_plots = 0B
  if n_elements(vx0d0) eq 0 then vx0d0 = 0.0
  if n_elements(vy0d0) eq 0 then vy0d0 = 0.0
  if n_elements(vz0d0) eq 0 then vz0d0 = 0.0

  ;--------;
  ; Hybrid ;
  ;--------;
  if efield_algorithm eq 1 or efield_algorithm eq 2 then begin

     ;;==Constant electron moments from input values
     moments0 = moments1*0.0
     moments0[1,*] = vx0d0      ;x drift velocity
     moments0[2,*] = vxthd0^2   ;x thermal velocity
     moments0[5,*] = vy0d0      ;y drift velocity
     moments0[6,*] = vythd0^2   ;y thermal velocity
     moments0[9,*] = vz0d0      ;z drift velocity
     moments0[10,*] = vzthd0^2  ;z thermal velocity

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
     v_ped0_start= Ey0_external*ped0_start
     v_ped1_start= Ey0_external*ped1_start
     ;;--Hall mobilities and drift
     hall0_start = qd0*wc0/(md0*(wc0^2+coll_rate0^2))
     hall1_start = qd1*wc1/(md1*(wc1^2+coll_rate1^2))
     v_hall0_start = Ey0_external*hall0_start
     v_hall1_start = Ey0_external*hall1_start
     ;;--Temperatures and acoustic speed
     T0_start = 0.5*(md0/kb)*(vxthd0^2+vythd0^2+vzthd0^2)
     T1_start = 0.5*(md1/kb)*(vxthd1^2+vythd1^2+vzthd1^2)
     Cs_start = sqrt(kb*(T0_start + T1_start)/md1)
     ;;--Psi
     Psi_start = abs(coll_rate0*coll_rate1/(wc0*wc1))
     driver = (Ey0_external/B0)/(1+Psi_start)

     ;;==Simulated values
     ;;--Collision frequencies and Psi
     nu0 = moments1[5,*]*0.0 + coll_rate0       ;Input value
     nu1 = Ey0_external/(moments1[5,*])*(qd1/md1) ;Ped drift
     Psi = abs(nu0*nu1/(wc0*wc1))
     driver = (Ey0_external/B0)/(1+Psi)
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
     v_ped0 = Ey0_external*ped0
     v_ped1 = Ey0_external*ped1
     ;;--Hall mobilities and drift
     hall0 = qd0*wc0/(md0*(wc0^2+nu0^2))
     hall1 = qd1*wc1/(md1*(wc1^2+nu1^2))
     v_hall0 = Ey0_external*hall0
     v_hall1 = Ey0_external*hall1
     ;;--Temperatures and acoustic speed
     T0 = (moments0[2,*] + moments0[6,*] + moments0[10,*])/3. * md0/kb
     T1 = (moments1[2,*] + moments1[6,*] + moments1[10,*])/3. * md1/kb
     Cs = sqrt(kb*(T0+T1)/md1)
  endif $                       ;hybrid

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
     ped0_start = mu0_start/(1+wc0^2/(coll_rate0*1.0)^2)
     ped1_start = mu1_start/(1+wc1^2/(coll_rate1*1.0)^2)
     v_ped0_start= Ey0_external*ped0_start
     v_ped1_start= Ey0_external*ped1_start
     ;;--Hall mobilities and drift
     hall0_start = qd0*wc0/(md0*(wc0^2+coll_rate0^2))
     hall1_start = qd1*wc1/(md1*(wc1^2+coll_rate1^2))
     v_hall0_start = Ey0_external*hall0_start
     v_hall1_start = Ey0_external*hall1_start
     ;;--Temperatures and acoustic speed
     T0_start = 0.5*(md0/kb)*(vxthd0^2+vythd0^2+vzthd0^2)
     T1_start = 0.5*(md1/kb)*(vxthd1^2+vythd1^2+vzthd1^2)
     Cs_start = sqrt(kb*(T0_start + T1_start)/md1)
     ;;--Psi
     Psi_start = abs(coll_rate0*coll_rate1/(wc0*wc1))
     driver = (Ey0_external/B0)/(1+Psi_start)

     ;;==Simulated values
     ;;--Collision frequencies and Psi
     nu0 = moments0[5,*]/moments0[1,*]*wc0      ;Hall drift
     nu1 = Ey0_external/(moments1[5,*])*(qd1/md1) ;Ped drift
     Psi = abs(nu0*nu1/(wc0*wc1))
     driver = (Ey0_external/B0)/(1+Psi)
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
     v_ped0 = Ey0_external*ped0
     v_ped1 = Ey0_external*ped1
     ;;--Hall mobilities and drift
     hall0 = qd0*wc0/(md0*(wc0^2+nu0^2))
     hall1 = qd1*wc1/(md1*(wc1^2+nu1^2))
     v_hall0 = Ey0_external*hall0
     v_hall1 = Ey0_external*hall1
     ;;--Temperatures and acoustic speed
     T0 = (moments0[2,*] + moments0[6,*] + moments0[10,*])/3. * md0/kb
     T1 = (moments1[2,*] + moments1[6,*] + moments1[10,*])/3. * md1/kb
     Cs = sqrt(kb*(T0+T1)/md1)
  endelse                       ;pure PIC

  dist0 = {moments:moments0, $
           wc:wc0, $
           mu_start:mu0_start, $
           ped_start:ped0_start, $
           v_ped_start:v_ped0_start, $
           hall_start:hall0_start, $
           v_hall_start:v_hall0_start, $
           T_start:T0_start, $
           nu_start:coll_rate0, $
           nu:nu0, $
           ped:ped0, $
           v_ped:v_ped0, $
           hall:hall0, $
           v_hall:v_hall0, $
           T:T0}
  dist1 = {moments:moments1, $
           wc:wc1, $
           mu_start:mu1_start, $
           ped_start:ped1_start, $
           v_ped_start:v_ped1_start, $
           hall_start:hall1_start, $
           v_hall_start:v_hall1_start, $
           T_start:T1_start, $
           nu_start:coll_rate1, $
           nu:nu1, $
           ped:ped1, $
           v_ped:v_ped1, $
           hall:hall1, $
           v_hall:v_hall1, $
           T:T1}

  moment_vars = {dist0:dist0, dist1:dist1, $
                 Psi_start:Psi_start, Psi:Psi, $
                 Cs_start:Cs_start, Cs:Cs, driver:driver}
  
  return, moment_vars

end
