//-----------------------------------------------------------------------------
// Copyright (c) 2012 GarageGames, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//-----------------------------------------------------------------------------

// This is the default save location for any Particle Emitter datablocks created in the
// Particle Editor (this script is executed from onServerCreated())


datablock ParticleEmitterData(BNG_Leaves : DefaultEmitter)
{
   ejectionPeriodMS = "687";
   periodVarianceMS = "603";
   ejectionVelocity = "2";
   orientParticles = "0";
   particles = "BNG_Leaf1";
   blendStyle = "NORMAL";
   thetaMin = "142.5";
   thetaMax = "146.3";
   alignParticles = "0";
   alignDirection = "0 0.707107 0.707107";
   phiVariance = "142.5";
   softnessDistance = "1";
   ejectionOffset = "0.2";
   originalName = "BNGTESTEM";
   velocityVariance = "1.5";
};

//datablock ParticleEmitterData(BNG_Black_Smoke : DefaultEmitter)
//{
   //particles = "BNG_Leaf2";
   //ejectionVelocity = "4.167";
   //velocityVariance = "0";
   //softnessDistance = "1";
   //blendStyle = "NORMAL";
   //colors0 = "1 0.0705882 0 1";
   //sizes1 = "18.75";
   //colors1 = "0.00392157 0.00392157 0.00392157 0.407";
   //sizes2 = "1";
   //times3 = "0";
   //colors2 = "0.996078 0.992157 0.992157 1";
   //sizes3 = "1";
   //colors3 = "0.996078 0.992157 0.992157 1";
   //sizes0 = "20.8333";
   //useInvAlpha = "1";
   //lifetimeMS = "376";
   //lifetimeVarianceMS = "0";
   //times1 = "0.25";
   //times2 = "0";
   //inheritedVelFactor = "2.5";
   //dragCoefficient = "0.083";
   //spinRandomMin = "166.1";
   //constantAcceleration = "0.833";
   //spinRandomMax = "167.1";
   //times0 = "0.1875";
   //gravityCoefficient = "0.042";
   //textureName = "art/textures/Particles/particle_oak_leaf_02.dds";
   //spinSpeed = "0";
   //ejectionPeriodMS = "146";
//};

//datablock ParticleEmitterData(BNG_Black_Smoke : DefaultEmitter)
//{
   //particles = "newParticle";
   //blendStyle = "NORMAL";
//};

//datablock ParticleEmitterData(BNG_dust_large : DefaultEmitter)
//{
   //softnessDistance = "1";
   //particles = "BNG_dirt_small";
   //blendStyle = "NORMAL";
   //ejectionOffset = "0.417";
   //thetaMin = "0";
   //thetaMax = "180";
   //originalName = "BNG_dust_small";
   //ejectionPeriodMS = "10";
   //velocityVariance = "0.8";
//};

//datablock ParticleEmitterData(BNG_dust_small : DefaultEmitter)
//{
   //particles = "newParticle2";
   //softnessDistance = "1";
   //blendStyle = "NORMAL";
   //ejectionOffset = "0";
   //thetaMin = "90";
   //thetaMax = "108.8";
//};

//datablock ParticleEmitterData(BNG_Dust_small01 : DefaultEmitter)
//{
   //particles = "BNG_dust_small";
   //softnessDistance = "1";
   //blendStyle = "NORMAL";
   //ejectionVelocity = "1";
   //ejectionOffset = "0.2";
   //thetaMax = "180";
   //periodVarianceMS = "25";
   //ejectionPeriodMS = "26";
//};

datablock ParticleEmitterData(BNG_TestExplosion : DefaultEmitter)
{
   ejectionPeriodMS = "1";
   softnessDistance = "1";
   particles = "newParticle3";
   lifetimeMS = "20";
   blendStyle = "NORMAL";
};

datablock ParticleEmitterData(BNG_dust_gravel : DefaultEmitter)
{
   particles = "BNG_dust_gravel";
   ejectionPeriodMS = "167";
   thetaMax = "45";
   softnessDistance = "1";
   blendStyle = "NORMAL";
};

//datablock ParticleEmitterData(BNG_Dust_Gravel1 : DefaultEmitter)
//{
   //particles = "BNG_Dust_gravel";
   //blendStyle = "NORMAL";
   //ejectionOffset = "0";
   //softnessDistance = "1";
   //ejectionPeriodMS = "101";
   //reverseOrder = "1";
//};

datablock ParticleEmitterData(BNGP_1 : DefaultEmitter)
{
   particles = "BNG_sparks";
   blendStyle = "ADDITIVE";
   ejectionPeriodMS = "63";
   periodVarianceMS = "62";
   velocityVariance = "0";
   thetaMin = "0";
   thetaMax = "80";
   ejectionOffset = "0.1";
   reverseOrder = "1";
   softnessDistance = "0.01";
   ambientFactor = "0";
   alignDirection = "0 0 0";
   lifetimeMS = "0";
   lifetimeVarianceMS = "0";
   ejectionVelocity = "1";
   phiVariance = "0";
   orientParticles = "1";
   useLighting = "0";
};

datablock ParticleEmitterData(BNGP_2 : DefaultEmitter)
{
   particles = "BNG_dust_light";
   blendStyle = "NORMAL";
   ejectionPeriodMS = "1";
   periodVarianceMS = "0";
   velocityVariance = "0";
   thetaMin = "0";
   thetaMax = "360";
   ejectionOffset = "0";
   reverseOrder = "1";
   softnessDistance = "2";
   ambientFactor = "0";
   alignDirection = "0 0 0";
   lifetimeMS = "0";
   lifetimeVarianceMS = "0";
   ejectionVelocity = "0";
   phiVariance = "0";
};

datablock ParticleEmitterData(BNGP_3 : DefaultEmitter)
{
   particles = "BNG_dust_dark";
   blendStyle = "NORMAL";
   ejectionPeriodMS = "1";
   periodVarianceMS = "0";
   velocityVariance = "0";
   thetaMin = "0";
   thetaMax = "360";
   ejectionOffset = "0";
   reverseOrder = "1";
   softnessDistance = "1.5";
   ambientFactor = "0";
   alignDirection = "0 0 0";
   lifetimeMS = "0";
   lifetimeVarianceMS = "0";
   ejectionVelocity = "0";
   phiVariance = "0";
};

datablock ParticleEmitterData(BNGP_4 : DefaultEmitter)
{
   particles = "BNG_dust_dirt";
   blendStyle = "NORMAL";
   ejectionPeriodMS = "1";
   periodVarianceMS = "0";
   velocityVariance = "0";
   thetaMin = "0";
   thetaMax = "360";
   ejectionOffset = "0";
   reverseOrder = "1";
   softnessDistance = "2";
   ambientFactor = "0";
   alignDirection = "0 0 0";
   lifetimeMS = "0";
   lifetimeVarianceMS = "0";
   ejectionVelocity = "0";
   phiVariance = "0";
};

datablock ParticleEmitterData(BNGP_5 : DefaultEmitter)
{
   particles = "BNG_dirt";
   blendStyle = "NORMAL";
   ejectionPeriodMS = "1";
   periodVarianceMS = "0";
   velocityVariance = "0";
   thetaMin = "0";
   thetaMax = "360";
   ejectionOffset = "0";
   reverseOrder = "1";
   softnessDistance = "1";
   ambientFactor = "0";
   alignDirection = "0 0 0";
   lifetimeMS = "0";
   lifetimeVarianceMS = "0";
   ejectionVelocity = "0";
   phiVariance = "0";
};

datablock ParticleEmitterData(BNGP_6 : DefaultEmitter)
{
   particles = "BNG_smoke_white";
   blendStyle = "NORMAL";
   ejectionPeriodMS = "100";
   periodVarianceMS = "0";
   velocityVariance = "2";
   thetaMin = "0";
   thetaMax = "0";
   ejectionOffset = "0";
   reverseOrder = "1";
   softnessDistance = "0.2";
   ambientFactor = "0";
   alignDirection = "0 0 0";
   lifetimeMS = "0";
   lifetimeVarianceMS = "0";
   ejectionVelocity = "2";
   phiVariance = "0";
   originalName = "BNGP_6";
};

datablock ParticleEmitterData(BNGP_7 : DefaultEmitter)
{
   particles = "BNG_smoke_black";
   blendStyle = "NORMAL";
   ejectionPeriodMS = "1";
   periodVarianceMS = "0";
   velocityVariance = "0";
   thetaMin = "0";
   thetaMax = "360";
   ejectionOffset = "0";
   reverseOrder = "1";
   softnessDistance = "2";
   ambientFactor = "0";
   alignDirection = "0 0 0";
   lifetimeMS = "0";
   lifetimeVarianceMS = "0";
   ejectionVelocity = "0";
   phiVariance = "0";
};

datablock ParticleEmitterData(BNGP_8 : DefaultEmitter)
{
   particles = "BNG_dust_sand";
   blendStyle = "NORMAL";
   ejectionPeriodMS = "1";
   periodVarianceMS = "0";
   velocityVariance = "0";
   thetaMin = "0";
   thetaMax = "360";
   ejectionOffset = "0";
   reverseOrder = "1";
   softnessDistance = "2";
   ambientFactor = "0";
   alignDirection = "0 0 0";
   lifetimeMS = "0";
   lifetimeVarianceMS = "0";
   ejectionVelocity = "0";
   phiVariance = "0";
};

datablock ParticleEmitterData(BNGP_13 : DefaultEmitter)
{
   particles = "BNG_chunk_small BNG_chunk_med";
   blendStyle = "NORMAL";
   ejectionPeriodMS = "10";
   periodVarianceMS = "0";
   velocityVariance = "1";
   thetaMin = "0";
   thetaMax = "180";
   ejectionOffset = "0";
   reverseOrder = "1";
   softnessDistance = "0.2";
   ambientFactor = "0";
   alignDirection = "0 0 0";
   lifetimeMS = "0";
   lifetimeVarianceMS = "0";
   ejectionVelocity = "1";
   phiVariance = "0";
   orientParticles = "0";
};

datablock ParticleEmitterData(BNGP_16 : DefaultEmitter)
{
   particles = "BNG_gravel";
   blendStyle = "NORMAL";
   ejectionPeriodMS = "1";
   periodVarianceMS = "0";
   velocityVariance = "0";
   thetaMin = "0";
   thetaMax = "360";
   ejectionOffset = "0";
   reverseOrder = "1";
   softnessDistance = "1";
   ambientFactor = "0";
   alignDirection = "0 0 0";
   lifetimeMS = "0";
   lifetimeVarianceMS = "0";
   ejectionVelocity = "0";
   phiVariance = "0";
};

datablock ParticleEmitterData(BNGP_17 : DefaultEmitter)
{
   particles = "BNG_sand";
   blendStyle = "NORMAL";
   ejectionPeriodMS = "42";
   periodVarianceMS = "0";
   velocityVariance = "0";
   thetaMin = "0";
   thetaMax = "180";
   ejectionOffset = "0";
   reverseOrder = "1";
   softnessDistance = "1.5";
   ambientFactor = "0";
   alignDirection = "0 0 0";
   lifetimeMS = "0";
   lifetimeVarianceMS = "0";
   ejectionVelocity = "0";
   phiVariance = "0";
   orientParticles = "1";
   softParticles = "1";
};

datablock ParticleEmitterData(BNGP_18 : DefaultEmitter)
{
   particles = "BNG_mud_1";
   ejectionOffset = "0";
   phiVariance = "0";
   blendStyle = "NORMAL";
   reverseOrder = "0";
   softnessDistance = "0.1";
   ejectionPeriodMS = "10";
};

datablock ParticleEmitterData(BNGP_19 : DefaultEmitter)
{
   particles = "BNG_glassbreak";
   ejectionOffset = "0.1";
   phiVariance = "360";
   blendStyle = "NORMAL";
   reverseOrder = "1";
   softnessDistance = "0.1";
   ejectionPeriodMS = "1";
   lifetimeMS = "25";
   periodVarianceMS = "0";
   thetaMax = "180";
   orientParticles = "0";
   alignParticles = "0";
   thetaMin = "0";
   ejectionVelocity = "0.8";
   softParticles = "1";
};

datablock ParticleEmitterData(BNGP_20 : DefaultEmitter)
{
   particles = "BNG_smoke_white2";
   blendStyle = "NORMAL";
   ejectionPeriodMS = "100";
   periodVarianceMS = "0";
   velocityVariance = "2";
   thetaMin = "0";
   thetaMax = "0";
   ejectionOffset = "0.2";
   reverseOrder = "1";
   softnessDistance = "0.05";
   ambientFactor = "0";
   alignDirection = "0 0 0";
   lifetimeMS = "0";
   lifetimeVarianceMS = "0";
   ejectionVelocity = "2";
   phiVariance = "0";
   originalName = "BNGP_20";
};
