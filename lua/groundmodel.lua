-- This Source Code Form is subject to the terms of the bCDDL, v. 1.1.
-- If a copy of the bCDDL was not distributed with this
-- file, You can obtain one at http://beamng.com/bCDDL-1.1.txt

-- this file defines the ground models

local M = {}


-- clear all existing ground models first
BeamEngine:resetGroundModels()

local materials = particles.getMaterialsParticlesTable()

-------------------------------------------------------------------------------
-- Asphalt

local g = groundModel()
g.adhesionVelocity            = 1.0
--[[
Adhesion velocity
Below this velocity, static friction rules, above it dynamic friction takes command. This velocity threshold is also used by the fluid physics, so you should always define it. NEVER have it at 0. 
Parameter range 0.1 -> 10 (Never put it at 0)
]]--

g.staticFrictionCoefficient   = 1.2
--[[
Static friction coef
Static friction keeps you in the same place when you are stopped on a hill. In the real world this friction is always bigger than dynamic friction (sliding friction). Start with 0.5 and work from there. It is better to try to find some experimentally validated values for this and the rest of surface friction variables in the net, and then to fine tune via strength. 

Parameter range 0.1 -> 2
]]--

--http://www.mfes.com/friction.html
--http://en.wikibooks.org/wiki/Physics_Study_Guide/Frictional_coefficients
g.slidingFrictionCoefficient  = 0.60
--[[
Dynamic friction coef
Or sliding friction coef. It should be smaller than static friction coef. This parameter defines how much friction you'll have when sliding. Try to find some values for it from the net. 
Parameter range 0.1 -> 1.5
]]--

g.hydrodynamicFriction        = 0.001
--[[
Hydrodynamic friction coef
This friction defines the added friction that you'll feel from a surface that has a little film of fluid on it. It is kind of redundant with all the fluid physics below, but it is here so as for experimentally validated values from the net to be usable. If you decide that you'll simulate the film of fluid with the more complex fluid physics below, then just set this to 0. 

Parameter range 0 -> 1.5
]]--

--http://www.apps.vtti.vt.edu/PDFs/SURF-2012-presentations/B1.3%20Madhura%20Rajapakshe.pdf
g.stribeckVelocity            = 3.0
--[[
Stribeck velocity
You'll either find stribeck velocity in the net, or the inverse (1/stribeck velocity) of it described as "stribeck coef". It defines the shape of the dynamic friction curve.
]]--

g.strength                    = 1.0
--[[
Strength
This parameter raises or diminishes surface friction in a generic way. It is here so as to be able to do quick calibrations of friction. Start with having this to 1.0 and after tuning the rest of the surface variables, come back and play with this. 

Parameter range 0 -> 2
]]--
 
-- set the default depth of the groundmodel (it applies if no terrain depthmap has been defined)
g.defaultDepth = 0

-- set the collision type to emit
g.collisiontype = particles.getMaterialIDByName(materials, "ASPHALT")
g.skidMarks = true

BeamEngine:setGroundModel(g, "Asphalt")
BeamEngine:setGroundModel(g, "Concrete")
BeamEngine:setGroundModel(g, "Concrete2")
BeamEngine:setGroundModel(g, "groundmodel_asphalt1")



-------------------------------------------------------------------------------
-- gravel
g = groundModel()
g.adhesionVelocity            = 3
g.staticFrictionCoefficient   = 0.90
g.slidingFrictionCoefficient  = 0.66
g.hydrodynamicFriction        = 0.1
g.stribeckVelocity            = 0.2
g.strength                    = 1.0

g.fluidDensity = 100
g.flowConsistencyIndex = 460
g.flowBehaviorIndex = 0.5
g.dragAnisotropy = 0
g.defaultDepth = 0

g.collisiontype               = particles.getMaterialIDByName(materials, "DIRT")
g.skidMarks                   = false
BeamEngine:setGroundModel(g, "Dirt")
BeamEngine:setGroundModel(g, "RockyDirt")

-------------------------------------------------------------------------------
-- rock
g = groundModel()
g.adhesionVelocity            = 3
g.staticFrictionCoefficient   = 0.95
g.slidingFrictionCoefficient  = 0.68
g.hydrodynamicFriction        = 0.001
g.stribeckVelocity            = 6.0
g.strength                    = 1.0
g.defaultDepth                = 0

g.collisiontype               = particles.getMaterialIDByName(materials, "ROCK")
g.skidMarks                   = false
BeamEngine:setGroundModel(g, "Rock")

-------------------------------------------------------------------------------
-- metal
g = groundModel()
g.adhesionVelocity            = 3
g.staticFrictionCoefficient   = 0.74
g.slidingFrictionCoefficient  = 0.57
g.hydrodynamicFriction        = 0.001
g.stribeckVelocity            = 0.2
g.strength                    = 1.0
g.defaultDepth                = 0

g.collisiontype               = particles.getMaterialIDByName(materials, "METAL")
g.skidMarks                   = false
BeamEngine:setGroundModel(g, "Metal")

-------------------------------------------------------------------------------
-- grass
g = groundModel()
g.adhesionVelocity            = 3
g.staticFrictionCoefficient   = 0.85
g.slidingFrictionCoefficient  = 0.4
g.hydrodynamicFriction        = 0.1
g.stribeckVelocity            = 0.2
g.strength                    = 1.0
g.defaultDepth                = 0

g.fluidDensity = 100
g.flowConsistencyIndex = 460
g.flowBehaviorIndex = 0.9
g.dragAnisotropy = 0

g.collisiontype               = particles.getMaterialIDByName(materials, "DIRT")
g.skidMarks                   = false
BeamEngine:setGroundModel(g, "Grass")
BeamEngine:setGroundModel(g, "Grass2")
BeamEngine:setGroundModel(g, "Forest")

-------------------------------------------------------------------------------
-- sand
g = groundModel()
g.adhesionVelocity            = 3
g.staticFrictionCoefficient   = 0.75
g.slidingFrictionCoefficient  = 0.90
g.hydrodynamicFriction        = 0.15
g.stribeckVelocity            = 0.2
g.strength                    = 1.0
g.defaultDepth                = 0

-- http://www.engineeringtoolbox.com/density-materials-d_1652.html
g.fluidDensity = 1522
g.flowConsistencyIndex = 1800
g.flowBehaviorIndex = 0.9
g.dragAnisotropy = 0.1

g.collisiontype               = particles.getMaterialIDByName(materials, "SAND")
g.skidMarks                   = false
BeamEngine:setGroundModel(g, "Sand")
BeamEngine:setGroundModel(g, "BeachSand")

-------------------------------------------------------------------------------
-- dirt_dusty
g = groundModel()
g.adhesionVelocity            = 3
g.staticFrictionCoefficient   = 0.75
g.slidingFrictionCoefficient  = 0.60
g.hydrodynamicFriction        = 0.05
g.stribeckVelocity            = 0.2
g.strength                    = 1.0
g.defaultDepth                = 0

g.fluidDensity = 100
g.flowConsistencyIndex = 460
g.flowBehaviorIndex = 0.5
g.dragAnisotropy = 0

g.collisiontype               = particles.getMaterialIDByName(materials, "DIRT_DUSTY")
g.skidMarks                   = false
BeamEngine:setGroundModel(g, "RockyDirt")

-------------------------------------------------------------------------------
-- dirt
g = groundModel()
g.adhesionVelocity            = 3
g.staticFrictionCoefficient   = 0.76
g.slidingFrictionCoefficient  = 0.78
g.hydrodynamicFriction        = 0.1
g.stribeckVelocity            = 0.2
g.strength                    = 1.0
g.defaultDepth                = 0

g.fluidDensity = 100
g.flowConsistencyIndex = 460
g.flowBehaviorIndex = 0.5
g.dragAnisotropy = 0

g.collisiontype               = particles.getMaterialIDByName(materials, "DIRT")
g.skidMarks                   = false
BeamEngine:setGroundModel(g, "dirt_grass")
BeamEngine:setGroundModel(g, "derby_dirt")

-------------------------------------------------------------------------------
-- ice
g = groundModel()
g.adhesionVelocity            = 15
g.staticFrictionCoefficient   = 0.33
g.slidingFrictionCoefficient  = 0.2
g.hydrodynamicFriction        = 0.0001
g.stribeckVelocity            = 0.2
g.strength                    = 1.0
g.defaultDepth                = 0
g.collisiontype               = particles.getMaterialIDByName(materials, "ICE")
g.skidMarks                   = false
BeamEngine:setGroundModel(g, "Ice")

-------------------------------------------------------------------------------
-- snow
g = groundModel()
g.adhesionVelocity            = 5
g.staticFrictionCoefficient   = 0.65
g.slidingFrictionCoefficient  = 0.4
g.hydrodynamicFriction        = 0.1
g.stribeckVelocity            = 0.2
g.strength                    = 1.0
g.defaultDepth                = 0

-- http://www.simetric.co.uk/si_materials.htm
g.fluidDensity = 481
g.flowConsistencyIndex = 300
g.flowBehaviorIndex = 0.8
g.dragAnisotropy = 0.02

g.collisiontype               = particles.getMaterialIDByName(materials, "SNOW")
g.skidMarks                   = false
BeamEngine:setGroundModel(g, "Snow")

-------------------------------------------------------------------------------
-- mud
g = groundModel()
g.adhesionVelocity            = 3
g.staticFrictionCoefficient   = 0.3
g.slidingFrictionCoefficient  = 0.5
g.hydrodynamicFriction        = 0.1
g.stribeckVelocity            = 0.2
g.strength                    = 1.0
g.defaultDepth                = 0

-- http://www.simetric.co.uk/si_materials.htm
g.fluidDensity = 1730
g.flowConsistencyIndex = 900
g.flowBehaviorIndex = 0.9
g.dragAnisotropy = 0.02

g.collisiontype               = particles.getMaterialIDByName(materials, "MUD")
g.skidMarks                   = false
BeamEngine:setGroundModel(g, "Mud")

-- public interface

-- currently empty

return M