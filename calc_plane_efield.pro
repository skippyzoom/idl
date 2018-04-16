efield = calc_grad_xyzt(phi,dx=dx,dy=dy,scale=-1.0)
Ex = efield.x
Ey = efield.y
delvar, efield
Er = sqrt(Ex*Ex + Ey*Ey)
Et = atan(Ey,Ex)
