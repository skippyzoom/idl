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

;;==Save working directory
spawn, 'pwd',curDir

;;==Read sim parameters and moment files
@params_in.pro
@ppic3d.i
@moments3d

;;==Defaults
if n_elements(baseLabel) eq 0 then baseLabel=''
if n_elements(vzthd0) eq 0 then vzthd0=0.
if n_elements(vz0d0) eq 0 then vz0d0=0.
if n_elements(vzthd1) eq 0 then vzthd1=0.
if n_elements(vz0d1) eq 0 then vz0d1=0.
if n_elements(Bz) eq 0 and n_elements(Bx) ne 0 then Bz=Bx
if (n_elements(kb) eq 0) then if (md0 lt 1e-8) then kb=1.38e-23 else kb=1
if (n_elements(coll_rate0) eq 0) then coll_rate0=0.
if (n_elements(coll_rate1) eq 0) then coll_rate1=0.
if (n_elements(Ex0_external) eq 0) then Ex0_external=0.
if (n_elements(Ey0_external) eq 0) then Ey0_external=0.
if (n_elements(Ez0_external) eq 0) then Ez0_external=0.
if n_elements(efield_algorithm) eq 0 then efield_algorithm = 0
if n_elements(make_plots) eq 0 then make_plots = 0B
if n_elements(vx0d0) eq 0 then vx0d0 = 0.0
if n_elements(vy0d0) eq 0 then vy0d0 = 0.0
if n_elements(vz0d0) eq 0 then vz0d0 = 0.0

;;==Set up plotting (same for hybrid and pure PIC)
if make_plots then begin
   if !d.name eq strupcase('ps') then begin
      stop_ps 
      print, "Warning: moment_analysis controls PostScript internally"
   endif
   ps, "moment_plots.ps",/landscape
endif

;--------;
; Hybrid ;
;--------;
if efield_algorithm eq 1 then begin

   ;;==Constant electron moments from input values
   moments0 = moments1*0.0
   moments0[1,*] = vx0d0                ;x drift velocity
   moments0[2,*] = vxthd0^2             ;x thermal velocity
   moments0[5,*] = vy0d0                ;y drift velocity
   moments0[6,*] = vythd0^2             ;y thermal velocity
   moments0[9,*] = vz0d0                ;z drift velocity
   moments0[10,*] = vzthd0^2            ;z thermal velocity

   ;;==Theoretical values
   ;;--cyclotron frequencies
   wce  = qd0*Bz/md0
   wci  = qd1*Bz/md1
   ;;--parallel mobilities
   if (coll_rate0 ne 0) then mu0=qd0/coll_rate0/md0 else mu0 = 0
   if (coll_rate1 ne 0) then mu1=qd1/coll_rate1/md1 else mu1 = 0
   ;;--Pedersen mobilities and drift
   ped0 = mu0/(1+wce^2/(coll_rate0*1.0)^2)
   ped1 = mu1/(1+wci^2/(coll_rate1*1.0)^2)
   v_ped0= Ey0_external*ped0
   v_ped1= Ey0_external*ped1
   ;;--Hall mobilities and drift
   hall0 = qd0*wce/(md0*(wce^2+coll_rate0^2))
   hall1 = qd1*wci/(md1*(wci^2+coll_rate1^2))
   v_hall0 = Ey0_external*hall0
   v_hall1 = Ey0_external*hall1

   ;;==Temperatures and acoustic speed
   ;; Te_start = 0.5*(md0/kb)*((vxthd0*1.0)^2+(vythd0^2*1.0)+(vzthd0*1.0)^2)
   ;; Ti_start = 0.5*(md1/kb)*((vxthd1*1.0)^2+(vythd1^2*1.0)+(vzthd1*1.0)^2)
   Te_start = 0.5*(md0/kb)*(vxthd0^2+vythd0^2+vzthd0^2)
   Ti_start = 0.5*(md1/kb)*(vxthd1^2+vythd1^2+vzthd1^2)
   Te = (moments0[2,*] + moments0[6,*] + moments0[10,*])/3. * md0/kb
   Ti = (moments1[2,*] + moments1[6,*] + moments1[10,*])/3. * md1/kb
   Cs = sqrt(kb*(thermal_gamma*Te + Ti)/md1)
   Cs_start = sqrt(kb*(Te_start + Ti_start)/md1)

   ;;==Collision frequencies and Psi
   ;;--nue from input value
   ;;--nui from Ped drift.
   nue = moments1[5,*]*0.0 + coll_rate0
   nui = Ey0_external/(moments1[5,*])*(qd1/md1)
   Psi = abs(nue*nui/(wce*wci))
   driver = (Ey0_external/Bz)/(1+Psi)

   ;;==Sizes
   momSize = size(moments1)
   imomin = 1
   imomax = momSize[2]-1
   timeVec = moments1[0,*]*dt
   t0tfin = [timeVec[0],timeVec[imomax]]*dt

   if make_plots then begin
      ;;==Plot temperatures
      mintemp = 0.9*min([moments1[2,*],moments1[6,*],moments1[10,*]],/nan)*md1/kb
      maxtemp = 1.1*max([moments1[2,*],moments1[6,*],moments1[10,*]],/nan)*md1/kb
      plot, timeVec,moments1[2,*]*md1/kb, $
            ystyle=1,yrange=[mintemp,maxtemp],$
            title='Temperature: ',ytitle='T!Ii!N [K]',xtitle='time [s]'
      xyouts, timeVec[imomax]*dt,moments1[2,(imomax)]*md1/kb,' x'
      oplot, timeVec, moments1[6,*]*md1/kb
      xyouts, timeVec[imomax]*dt,moments1[6,(imomax)]*md1/kb,' y'
      oplot, timeVec, moments1[10,*]*md1/kb
      xyouts, timeVec[imomax]*dt,moments1[10,(imomax)]*md1/kb,' z'

      ;;==Plot velocities (sim and theory)
      maxvel = 0.9*max([moments1[1,*],moments1[5,*],moments1[9,*]],/nan)
      minvel = 1.1*min([moments1[1,*],moments1[5,*],moments1[9,*]],/nan)
      plot, timeVec, moments1[1,*],ystyle=1,yrange=[minvel,maxvel], $
            title='Velocities: ',ytitle='V [m/s]',xtitle='time [s]'
      xyouts, timeVec[imomax]*dt,moments1[1,(imomax)],' Vx'
      oplot, timeVec,moments1[5,*]
      xyouts, timeVec[imomax]*dt,moments1[5,(imomax)],' Vy'
      oplot, timeVec,moments1[9,*]
      xyouts, timeVec[imomax]*dt,moments1[9,(imomax)],' Vz'
      oplot,t0tfin,[v_hall1,v_hall1]
      xyouts, timeVec[imomax]*dt,v_hall1,' V!IH!N'
      oplot,t0tfin,[v_ped1,v_ped1]
      xyouts, timeVec[imomax]*dt,v_ped1,' V!IP!N'

      ;;==Plot acoustic speed and driver
      yMin = 0.9*min([Cs_start,Cs[imomin:imomax],driver[imomin:imomax]])
      yMax = 1.1*max([Cs_start,Cs[imomin:imomax],driver[imomin:imomax]])
      plot, timeVec[imomin:imomax]*dt,Cs[imomin:imomax], $
            ystyle=1,yrange=[yMin,yMax], $
            title='Acoustic/Driver speed:',ytitle='Cs [m/s]',xtitle='time [s]'
      xyouts, timeVec[imomax]*dt,Cs[(imomax)],' Cs'
      oplot, t0tfin,[Cs_start,Cs_start]
      xyouts, timeVec[imomax]*dt,Cs_start,' Cs_start'
      oplot, timeVec[imomin:imomax]*dt,Driver[imomin:imomax]
      xyouts, timeVec[imomax]*dt,Driver[(imomax)],' Driver'

      ;;==Plot collision frequencies
      yMin = 0.1*min([nue[imomin:imomax],nui[imomin:imomax]])>0.0
      yMax = 10*max([nue[imomin:imomax],nui[imomin:imomax]])
      plot, timeVec[imomin:imomax]*dt,nue[imomin:imomax],/ylog, $
            ystyle=1,yrange=[yMin,yMax], $
            title='Collision Rates:',ytitle='freq [s!E-1!N]',xtitle='time [s]'
      xyouts, timeVec[imomax]*dt,nue[(imomax)],' nue'
      oplot, timeVec[imomin:imomax]*dt,nui[imomin:imomax]
      xyouts, timeVec[imomax]*dt,nui[(imomax)],' nui:sim'
      oplot, t0tfin,[coll_rate1,coll_rate1]
      xyouts, timeVec[imomax]*dt,coll_rate1,' nui:in'

      ;;==Plot Psi
      yMin = 0.0
      yMax = 1.1*max(Psi[imomin:imomax])
      plot, timeVec[imomin:imomax]*dt,Psi[imomin:imomax], $
            ystyle=1,yrange=[yMin,yMax], $
            title='Psi:',ytitle='Psi',xtitle='time [s]'
   endif                        ;make plots
   nue_scale = 1.0
   nui_scale = 0.564517
endif $                         ;hybrid

;----------;
; Pure PIC ;
;----------;
else begin
   ;;==Theoretical values
   ;;--cyclotron frequencies
   wce  = qd0*Bz/md0
   wci  = qd1*Bz/md1
   ;;--parallel mobilities
   if (coll_rate0 ne 0) then mu0=qd0/coll_rate0/md0 else mu0 = 0
   if (coll_rate1 ne 0) then mu1=qd1/coll_rate1/md1 else mu1 = 0
   ;;--Pedersen mobilities and drift
   ped0 = mu0/(1+wce^2/(coll_rate0*1.0)^2)
   ped1 = mu1/(1+wci^2/(coll_rate1*1.0)^2)
   v_ped0= Ey0_external*ped0
   v_ped1= Ey0_external*ped1
   ;;--Hall mobilities and drift
   hall0 = qd0*wce/(md0*(wce^2+coll_rate0^2))
   hall1 = qd1*wci/(md1*(wci^2+coll_rate1^2))
   v_hall0 = Ey0_external*hall0
   v_hall1 = Ey0_external*hall1

   ;;==Temperatures and acoustic speed
   ;; Te_start = 0.5*md0/kb*((vxthd0*1.0)^2+(vythd0^2*1.0)+(vxthd0*1.0)^2)
   ;; Ti_start = 0.5*md1/kb*((vxthd1*1.0)^2+(vythd1^2*1.0)+(vxthd1*1.0)^2)
   Te_start = 0.5*(md0/kb)*(vxthd0^2+vythd0^2+vzthd0^2)
   Ti_start = 0.5*(md1/kb)*(vxthd1^2+vythd1^2+vzthd1^2)
   Te = (moments0[2,*] + moments0[6,*] + moments0[10,*])/3. * md0/kb
   Ti = (moments1[2,*] + moments1[6,*] + moments1[10,*])/3. * md1/kb
   Cs = sqrt(kb*(Te+Ti)/md1)
   Cs_start = sqrt(kb*(Te_start + Ti_start)/md1)

   ;;==Collision frequencies and Psi
   ;;--nue from either E x B drift or Ped drift
   ;;  It may be even better to use a ratio of the two
   ;;--nui from Ped drift.
   if Bz eq 0.0 then begin
      case 1 of
         Ex0_external ne 0.0: $
            nue = qd0*Ex0_external/moments0[1,*]/md0
         Ey0_external ne 0.0: $
            nue = qd0*Ey0_external/moments0[1,*]/md0
         Ez0_external ne 0.0: $
            nue = qd0*Ez0_external/moments0[1,*]/md0
      endcase
   endif $
   else $
      nue = moments0[5,*]/moments0[1,*]*wce
      ;; nue = abs(wce)*sqrt(Ey0_external/Bz/moments0[1,*]-1)
      ;; nue = (qd0/md0)*Ey0_external/(moments0[5,*]+moments0[9,*])
   nui = Ey0_external/(moments1[5,*])*(qd1/md1)
   Psi = abs(nue*nui/(wce*wci))
   driver = (Ey0_external/Bz)/(1+Psi)

   ;;==Sizes
   momSize = size(moments1)
   imomin = 64
   imomax = momSize[2]-1
   timeVec = moments1[0,*]*dt
   t0tfin = [timeVec[0],timeVec[imomax]]*dt

   if make_plots then begin
      ;;==Plot electron temperatures
      mintemp0 = 0.9*min([moments0[2,*],moments0[6,*],moments0[10,*]],/nan)*md0/kb
      maxtemp0 = 1.1*max([moments0[2,*],moments0[6,*],moments0[10,*]],/nan)*md0/kb
      plot, timeVec, moments0[2,*]*md0/kb, $
            ystyle=1, yrange=[mintemp0,maxtemp0],$
            title='Elec. Temperatures: ',ytitle='T!Ie!N [K]',xtitle='time [s]'
      xyouts, timeVec[imomax],moments0[2,(imomax)]*md0/kb,' x'
      oplot, timeVec, moments0[6,*]*md0/kb
      xyouts, timeVec[imomax],moments0[6,(imomax)]*md0/kb,' y'
      oplot, timeVec, moments0[10,*]*md0/kb
      xyouts, timeVec[imomax],moments0[10,(imomax)]*md0/kb,' z'

      ;;==Plot ion temperatures
      mintemp1 = 0.9*min([moments1[2,*],moments1[6,*],moments1[10,*]],/nan)*md1/kb
      maxtemp1 = 1.1*max([moments1[2,*],moments1[6,*],moments1[10,*]],/nan)*md1/kb
      plot, timeVec, moments1[2,*]*md1/kb, $
            ystyle=1,yrange=[mintemp1,maxtemp1],$
            title='Ion Temperatures: ',ytitle='T!Ii!N [K]',xtitle='time [s]'
      xyouts, timeVec[imomax],moments1[2,(imomax)]*md1/kb,' x'
      oplot, timeVec,moments1[6,*]*md1/kb
      xyouts, timeVec[imomax],moments1[6,(imomax)]*md1/kb,' y'
      oplot, timeVec,moments1[10,*]*md1/kb
      xyouts, timeVec[imomax],moments1[10,(imomax)]*md1/kb,' z'

      ;;==Plot electron velocities (sim and theory)
      minvel0 = 0.9*min([moments0[1,*],moments0[5,*],moments0[9,*]],/nan)
      maxvel0 = 1.1*max([moments0[1,*],moments0[5,*],moments0[9,*]],/nan)
      plot, timeVec,moments0[1,*],ystyle=1, yrange=[minvel0,maxvel0], $
            title='Elec. Velocities: ',ytitle='V!Ie!N [m/s]',xtitle='time [s]'
      xyouts, timeVec[imomax],moments0[1,(imomax)],' V!Ix!N'
      oplot, timeVec,moments0[5,*]
      xyouts, timeVec[imomax],moments0[5,(imomax)],' V!Iy!N'
      oplot, timeVec,moments0[9,*]
      xyouts, timeVec[imomax],moments0[9,(imomax)],' V!Iz!N'
      oplot, t0tfin,[v_hall1,v_hall1]
      xyouts, timeVec[imomax],v_hall1,' V!IH,e!N'
      oplot, t0tfin,[v_ped1,v_ped1]
      xyouts, timeVec[imomax],v_ped1,' V!IP,e!N'

      ;;==Plot ion velocities (sim and theory)
      minvel1 = 0.9*min([moments1[1,*],moments1[5,*],moments1[9,*]],/nan)
      maxvel1 = 1.1*max([moments1[1,*],moments1[5,*],moments1[9,*]],/nan)
      plot, timeVec,moments1[1,*],ystyle=1, yrange=[minvel1,maxvel1], $
            title='Ion Velocities: ',ytitle='V!Ii!N [m/s]',xtitle='time [s]'
      xyouts, timeVec[imomax],moments1[1,(imomax)],' V!Ix!N'
      oplot, timeVec,moments1[5,*]
      xyouts, timeVec[imomax],moments1[5,(imomax)],' V!Iy!N'
      oplot, timeVec,moments1[9,*]
      xyouts, timeVec[imomax],moments1[9,(imomax)],' V!Iz!N'
      oplot, t0tfin,[v_hall1,v_hall1]
      xyouts, timeVec[imomax],v_hall1,' V!IH,i!N'
      oplot, t0tfin,[v_ped1,v_ped1]
      xyouts, timeVec[imomax],v_ped1,' V!IP,i!N'

      ;;==Plot acoustic speed and driver
      yMin = 0.9*min([Cs_start,Cs[imomin:imomax],driver[imomin:imomax]])
      yMax = 1.1*max([Cs_start,Cs[imomin:imomax],driver[imomin:imomax]])
      plot, timeVec[imomin:imomax],Cs[imomin:imomax], $
            ystyle=1,yrange=[yMin,yMax], $
            title='Acoustic/Driver Speed:',ytitle='Cs [m/s]',xtitle='time [s]'
      xyouts, timeVec[imomax],Cs[(imomax)],' Cs'
      oplot, t0tfin,[Cs_start,Cs_start]
      xyouts, timeVec[imomax],Cs_start,' Cs_start'
      oplot, timeVec[imomin:imomax]*dt, Driver[imomin:imomax]
      xyouts, timeVec[imomax],Driver[(imomax)],' Driver'

      ;;==Plot collision frequencies
      yMin = 0.9*min([nue[imomin:imomax],nui[imomin:imomax]])>0.0
      yMax = 1.1*max([nue[imomin:imomax],nui[imomin:imomax]])
      plot, timeVec[imomin:imomax],nue[imomin:imomax], $
            ystyle=1,yrange=[yMin,yMax], $
            title='Collisions:',ytitle='freq [s!E-1!N]',xtitle='time [s]'
      xyouts, timeVec[imomax],nue[(imomax)],' nue:sim'
      oplot, t0tfin,[coll_rate0,coll_rate0]
      xyouts, timeVec[imomax],coll_rate0,' nue:in'
      oplot, timeVec[imomin:imomax],nui[imomin:imomax]
      xyouts, timeVec[imomax],nui[(imomax)],' nui:sim'
      oplot, t0tfin,[coll_rate1,coll_rate1]
      xyouts, timeVec[imomax],coll_rate1,' nui:in'

      ;;==Plot Psi
      yMin = 0.0
      yMax = 1.1*max(Psi[imomin:imomax])
      plot, timeVec[imomin:imomax],Psi[imomin:imomax], $
            ystyle=1,yrange=[yMin,yMax], $
            title='Psi:',ytitle='Psi',xtitle='time [s]'
   endif                        ;make plots
   nue_scale = 1.0
   nui_scale = 1.0
endelse                         ;pure PIC

;;==Calculate average collision frequencies and Psi factor
if Ey0_external ne 0.0 or Ex0_external ne 0.0 then begin
   nue_avg = mean((reform(nue))[ntMax/2:*])
   nui_avg = mean((reform(nui))[ntMax/2:*])
   Psi_avg = mean((reform(Psi))[ntMax/2:*])   
endif else begin
   nue_avg = nue_scale*coll_rate0
   nui_avg = nui_scale*coll_rate1
   Psi_avg = nui_avg*nue_avg/(abs(wce)*abs(wci))
endelse

;;==Check for unrealistic collision frequencies
if nue_avg gt coll_rate0 or nui_avg gt coll_rate1 then begin
   if nue_avg gt coll_rate0 then nue_avg = nue_scale*coll_rate0
   if nui_avg gt coll_rate1 then nui_avg = nui_scale*coll_rate1
   Psi_avg = nui_avg*nue_avg/(abs(wce)*abs(wci))
endif

;;==Make plots, if requested
if make_plots then begin
   date_plot, baseLabel
   stop_ps
endif

end
