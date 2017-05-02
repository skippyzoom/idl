baseDir = '/projectnb/eregion/may/Stampede_runs/'
baseDir += 'FB_flow_angle/3D/'
lWant = 3.0
imgName = 'test.pdf'

cd, baseDir+'alt0'
$pwd
@general_params
;; timestep = nout*(indgen(ntMax/2)+ntMax/2+1)
timestep = nout*(indgen(2)+ntMax/2+1)

cd, baseDir+'alt0'
$pwd
@kmagFreq_kernel

;; cd, baseDir+'alt1'
;; $pwd
;; @kmagFreq_kernel

;; cd, baseDir+'alt2'
;; $pwd
;; @kmagFreq_kernel
