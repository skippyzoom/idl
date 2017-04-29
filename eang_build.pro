;+
; Build the electric-field angle from the
; the electrostatic potential. This routine
; will create the full electric field and 
; split it into components if it is not already 
; in memory. The user may wish to delete the
; field or components to recover memory.
;-

;;==Defaults and guards
if n_elements(gridReform) eq 0 then $
   gridReform = [grid.nx,grid.ny,grid.nz,ntMax]
if n_elements(add_E0) eq 0 then add_E0 = 0B
if n_elements(Ex0_external) eq 0 then Ex0_external = 0.0
if n_elements(Ey0_external) eq 0 then Ey0_external = 0.0
if n_elements(Ez0_external) eq 0 then Ez0_external = 0.0
identity = make_array(size(gridReform,/dim),value=1)
if n_elements(phiSW) eq 0 then phiSW = identity
if array_equal(phiSW,identity) then rescale = !NULL
if n_elements(rescale) eq 0 then rescale = 0B

;;==Calculate the electric field if it isn't in memory
if n_elements(Efield) eq 0 then begin
   print, "eang_build: Calculate"
   Efield = calc_efield(phi,phiSW, $
                        dx=dx*nout_avg,dy=dy*nout_avg,dz=dz*nout_avg, $
                        rescale=rescale,/verbose)
   phi =reform(phi,gridReform)

   ;;==Split into components and add external field if requested
   Ex = 0.0
   if tag_exist(Efield,'x',/top_level) then begin
      Ex = reform(Efield.x,gridReform)
      if add_E0 then Ex += Ex0_external
   endif
   Ey = 0.0
   if tag_exist(Efield,'y',/top_level) then begin
      Ey = reform(Efield.y,gridReform)
      if add_E0 then Ey += Ey0_external
   endif
   Ez = 0.0
   if tag_exist(Efield,'z',/top_level) then begin
      Ez = reform(Efield.z,gridReform)
      if add_E0 then Ez += Ez0_external
   endif
endif

;;==Calculate angle
Eang = atan(Ey,Ex)
Eang = reform(Eang,gridReform)

end
