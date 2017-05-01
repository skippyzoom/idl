;+
; Created 26Apr2017 (may)
;
; Plot zeroth-order drift-velocity flow and
; aspect angles.
;
; NB: This assumes that the simulation used
;     B0 in the x direction (common for EPPIC
;     runs since that is the subdomain direction),
;     but that the physical setup has B0 in the z
;     direction (e.g. high-latitude FBI). The
;     rotation into that frame takes x -> z, y -> y,
;     and (-z) -> x, hence the negative signs on
;     Vex and Vix.
;-

@general_params
@moments3d

time = dt*moments0[0,*]
Vex = -moments0[9,*]
Vix = -moments1[9,*]
Vdx = Vex-Vix
Vey = moments0[5,*]
Viy = moments1[5,*] 
Vdy = Vey-Viy
Vez = moments0[1,*]
Viz = moments1[1,*]
Vdz = Vez-Viz

theta_Vd = atan(Vdy,Vdx)/!dtor
alpha_Vd = atan(Vdz,sqrt(Vdx^2+Vdy^2))/!dtor

pltName = "theta_Vd.pdf"
plt = plot(time,theta_Vd, $
           xstyle = 1, $
           xtitle = "t [s]", $
           ytitle = "$\theta_{Vd}$ [deg]", $
           font_name = "Times", $
           /buffer)
print, "Saving ",pltName,"..."
plt.save, pltName
plt.close
print, "Finished"

pltName = "alpha_Vd.pdf"
plt = plot(time,alpha_Vd, $
           xstyle = 1, $
           xtitle = "t [s]", $
           ytitle = "$\alpha_{Vd}$ [deg]", $
           font_name = "Times", $
           /buffer)
print, "Saving ",pltName,"..."
plt.save, pltName
plt.close
print, "Finished"
