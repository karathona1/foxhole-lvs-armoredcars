$modelname "foxhole/vehicles/separated/freeman_wheel.mdl"

$body "body" "Freeman_Wheel.dmx"

$opaque

$ambientboost

$cdmaterials "foxhole/vehicles/freeman\"

$surfaceprop "metal"

$contents "solid"

$sequence "freemanwheel_idle" "Freeman_Wheel_Phys.dmx" {
	fps 30
}

$collisionmodel "Freeman_Wheel_Phys.dmx"
{
	$automass
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave
}