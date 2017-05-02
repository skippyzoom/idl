baseDir = '/projectnb/eregion/may/Stampede_runs/FB_flow_angle/'
baseDir += '3D/'

cd, baseDir+'alt0'
$pwd
@calc_drifts
print, ' '

cd, baseDir+'alt1'
$pwd
@calc_drifts
print, ' '

cd, baseDir+'alt2'
$pwd
@calc_drifts
print, ' '
