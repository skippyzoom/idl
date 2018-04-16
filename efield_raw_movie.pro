efield = calc_grad_xyzt(phi,dx=dx,dy=dy,scale=-1.0)
Ex = efield.x
Ey = efield.y
delvar, efield
@Ex_raw_movie
@Ey_raw_movie
Er = sqrt(Ex*Ex + Ey*Ey)
@Er_raw_movie
Et = atan(Ey,Ex)
@Et_raw_movie
