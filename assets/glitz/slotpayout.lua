---------------------------------------------------------------
-- SPARKLE: Spew generally vertically, falling down and spinning, with color fade
-- Controllable:
--		gSparkleTexture: default "sparkle"
--		gSparkleTime: Counts down for sparkle generation
--		gSparkleColorStart/gSparkleColorEnd: Color fade
-- Particle properties

pVelocity = Allocate(2)
pAge = Allocate(1)
pSpin = Allocate(1)
pSpinSpeed = Allocate(1)

if gSparkleTexture then SetTexture(gSparkleTexture)
else SetTexture("sparkle.xml")
end

SetBlendMode(kBlendNormal)
SetNumParticles(80)

---------------------------------------------------------------
-- Particle initialization

pPosition:Init( fRange( Vec2(-5,0), Vec2(5,0) ) )
--pScale:Init( fRange(.3,1) )

--pVelocity:Init( fRange( Vec2(-53,100), Vec2(53,100) ) )
pVelocity:Init( fRange( Vec2(-45,100), Vec2(45,100) ) )
pAge:Init(0)

pSpin:Init( fRange( 0, 2*3.1415927 ) )
pSpinSpeed:Init( fRange( -1, 1 ) )

if not gSparkleColorStart then gSparkleColorStart = Color(1,1,1,1) end
if not gSparkleColorEnd then gSparkleColorEnd = Color(1,1,1,0.5) end
pColor:Init(gSparkleColorEnd)
pColor:Init(gSparkleColorStart)

---------------------------------------------------------------
-- Particle Animation

-- Add velocity scaled by time to position
pPosition:Anim( pPosition + fTimeScale(pVelocity) )
pVelocity:Anim( pVelocity + fTimeScale(Vec2(0,300)) )		-- Gravity

-- Fade
pColor:Anim(  fFade( pAge, gSparkleColorStart, 2000, gSparkleColorEnd ) )

-- Spin
pSpin:Anim( pSpin + fTimeScale( pSpinSpeed ) )
pUp:Anim( f2dRotation( pSpin ) )

-- Age the particle using age function, expire after 1000 ms
pAge:Anim( pAge+fAge() )
Anim( fExpire( fGreater(pAge,2000) ) )

---------------------------------------------------------------
-- Update function

gSparkleTime = 0
gSparkleDensity = 30

function Update(seconds)
	if gSparkleTime >= 1 then
		CreateParticles( seconds * gSparkleDensity )
	end
	if gSparkleTime > 0 then
		gSparkleTime = gSparkleTime - seconds
	end
end
