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
;-

function analyze_moments, nt_max,path=path

  ;;==Set default path
  if n_elements(path) eq 0 then path = './'

  ;;==Read sim parameters and moment files
  params = set_eppic_params(path)
  if file_test('domain000',/directory) then bp = 'domain000/' $
  else bp = './'
  if file_test(bp+'moments0.out') then $
     moments0=readarray(bp+'moments0.out',13,lineskip=1)
  if file_test(bp+'moments1.out') then $
     moments1=readarray(bp+'moments1.out',13,lineskip=1)

  if n_elements(params) ne 0 then begin

     ;;==Set default parameters
     coll_rate0 = params.coll_rate0
     coll_rate1 = params.coll_rate1
     md0 = params.md0
     md1 = params.md1
     qd0 = params.qd0
     qd1 = params.qd1
     Bx0 = params.Bx
     By0 = params.By
     Bz0 = params.Bz
     B0 = sqrt(Bx0^2 + By0^2 + Bz0^2)
     Ex0_external = params.Ex0_external
     Ey0_external = params.Ey0_external
     Ez0_external = params.Ez0_external
     efield_algorithm = params.efield_algorithm
     vx0d0 = params.vx0d0
     vy0d0 = params.vy0d0
     vz0d0 = params.vz0d0
     vx0d1 = params.vx0d1
     vy0d1 = params.vy0d1
     vz0d1 = params.vz0d1
     vxthd0 = params.vxthd0
     vythd0 = params.vythd0
     vzthd0 = params.vzthd0
     vxthd1 = params.vxthd1
     vythd1 = params.vythd1
     vzthd1 = params.vzthd1
     if (n_elements(kb) eq 0) then if (md0 lt 1e-8) then kb = 1.38e-23 else kb = 1

     ;;==Transform coordinates for 3-D 
     if Bz0 eq 0.0 and Bx0 ne 0.0 then Bz = Bx0
        
                                ;--------;
                                ; Hybrid ;
                                ;--------;
     if efield_algorithm eq 1 or efield_algorithm eq 2 then begin

        ;;==Constant electron moments from input values
        moments0 = moments1*0.0
        moments0[1,*] = vx0d0   ;x drift velocity
        moments0[2,*] = vxthd0^2 ;x thermal velocity
        moments0[5,*] = vy0d0    ;y drift velocity
        moments0[6,*] = vythd0^2 ;y thermal velocity
        moments0[9,*] = vz0d0    ;z drift velocity
        moments0[10,*] = vzthd0^2 ;z thermal velocity

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
        nu0 = moments1[5,*]*0.0 + coll_rate0      ;Input value
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
        if Bz0 ne 0.0 then $
           nu0 = wc0*moments0[5,*]/moments0[1,*] $ ;Hall drift
        else $
           nu0 = wc0*moments0[5,*]/(-moments0[9,*])
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
     endelse                    ;pure PIC

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
  endif $
  else begin
     print, "[ANALYZE_MOMENTS] Could not read parameter file"
     return, !NULL
  endelse
end
