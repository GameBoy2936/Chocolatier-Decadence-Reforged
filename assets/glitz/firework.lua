---------------------------------------------------------------
-- FIREWORK: Explode quickly in all directions, falling down and spinning, with slow color fade
-- Controllable:
--		gSparkleTexture: default "firework"
--		gSparkleTime: Counts down for sparkle generation
--		gSparkleColorStart/gSparkleColorEnd: Color fade
-- Particle properties

pVelocity = Allocate(2)
pGravity = Allocate(2)
pAge = Allocate(1)
pSpin = Allocate(1)
pSpinSpeed = Allocate(1)

if gSparkleTexture then SetTexture(gSparkleTexture)
else SetTexture("firework_red")
end

SetBlendMode(kBlendNormal)
SetNumParticles(80)
--SetNumParticles(120)

---------------------------------------------------------------
-- Particle initialization

pPosition:Init( fRange( Vec2(-2,-2), Vec2(2,2) ) )
--pScale:Init( fRange(.3,1) )
pScale:Init( fRange(.2,.75) )

pGravity:Init( fRange( Vec2(0,90), Vec2(0,110) ) )
pVelocity:Init( fRange( Vec2(-90,-50), Vec2(90,100) ) )
pAge:Init(0)

pSpin:Init( fRange( 0, 2*3.1415927 ) )
pSpinSpeed:Init( fRange( 60,80 ) )

--if not gSparkleColorStart then gSparkleColorStart = Color(1,1,1,1) end
--if not gSparkleColorEnd then gSparkleColorEnd = Color(1,1,1,0) end
gSparkleColorStart = Color(1,1,1,.8)
gSparkleColorEnd = Color(1,1,1,0)
--pColor:Init(gSparkleColorStart)
--pColor:Init(gSparkleColorEnd)
pColor:Init(Color(1,1,1,1))
pColor:Init(Color(1,1,1,0))

---------------------------------------------------------------
-- Particle Animation

-- Add velocity scaled by time to position
pPosition:Anim( pPosition + fTimeScale(pVelocity) )
pVelocity:Anim( pVelocity + fTimeScale(pGravity) )

-- Fade
--pColor:Anim(  fFade( pAge, gSparkleColorStart, 1000, gSparkleColorEnd ) )
pColor:Anim(  fFade( pAge, gSparkleColorStart, 2000, gSparkleColorEnd ) )

-- Shrink
pScale:Anim( pScale - fTimeScale(.1) )

-- Spin
pSpin:Anim( pSpin + fTimeScale( pSpinSpeed ) )
pUp:Anim( f2dRotation( pSpin ) )

-- Age the particle using age function, expire after given time
pAge:Anim( pAge+fAge() )
--Anim( fExpire( fGreater(pAge,1000) ) )
Anim( fExpire( fGreater(pAge,2000) ) )

---------------------------------------------------------------
-- Update function

-- Create all particles in the given time
gSparkleTime = .1

function Update(seconds)
	if gSparkleTime > 0 then
		gSparkleTime = gSparkleTime - seconds
		CreateParticles( seconds * 800 )
--		CreateParticles( seconds * 1200 )
	end
end
