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

// This is the default save location for any Particle datablocks created in the
// Particle Editor (this script is executed from onServerCreated())

datablock ParticleData(BNG_Leaf1 : DefaultParticle)
{
   textureName = "art/shapes/particles/particle_oak_leaf_01.dds";
   animTexName = "art/shapes/particles/particle_oak_leaf_01.dds";
   spinRandomMin = "-208";
   spinRandomMax = "417";
   colors[0] = "0.992126 0.992126 0.992126 1";
   colors[1] = "0.992126 0.992126 0.992126 1";
   colors[2] = "0.992126 0.992126 0.992126 1";
   colors[3] = "0.992126 0.992126 0.992126 1";
   sizes[0] = "0.497467";
   sizes[1] = "0.497467";
   sizes[2] = "0";
   sizes[3] = "0";
   gravityCoefficient = "2";
   lifetimeMS = "5438";
   lifetimeVarianceMS = "0";
   inheritedVelFactor = "1";
   constantAcceleration = "10";
   useInvAlpha = "0";
   times[1] = "0";
   dragCoefficient = "4.98534";
   times[0] = "0.0625";
   times[2] = "0";
   times[3] = "0";
};

datablock ParticleData(BNG_Leaf2 : DefaultParticle)
{
   textureName = "art/shapes/particles/particle_oak_leaf_02.dds";
   animTexName = "art/shapes/particles/particle_oak_leaf_02.dds";
   lifetimeMS = "15000";
   colors[0] = "0.996078 0.992157 0.992157 1";
   colors[1] = "0.996078 0.996078 0.992157 1";
   colors[2] = "0.996078 0.992157 0.992157 1";
   colors[3] = "0.996078 0.996078 0.992157 1";
   lifetimeVarianceMS = "0";
   constantAcceleration = "10";
   dragCoefficient = "8";
   inheritedVelFactor = "1";
   times[1] = "0.979167";
   times[2] = "0.75";
   sizes[0] = "0.5";
   sizes[1] = "0.5";
   sizes[2] = "0";
   sizes[3] = "0";
   useInvAlpha = "0";
};

datablock ParticleData(BNG_sparks : DefaultParticle)
{
   textureName = "art/shapes/particles/Sparkparticle.png";
   animTexName = "art/shapes/particles/Sparkparticle.png";
   colors[0] = "0.996078 0.996078 0.992157 1";
   colors[1] = "0.996078 0.996078 0.992157 1";
   colors[2] = "0.996078 0.458824 0.196078 1";
   colors[3] = "0.996078 0.0784314 0.00784314 0.025";
   dragCoefficient = "2.49756";
   gravityCoefficient = "0.998779";
   inheritedVelFactor = "1";
   spinRandomMin = "-360";
   spinRandomMax = "360";
   lifetimeMS = "800";
   lifetimeVarianceMS = "700";
   sizes[0] = "0.08";
   sizes[2] = "0.15";
   sizes[3] = "0.15";
   times[1] = "0.416667";
   times[2] = "0.8125";
   times[3] = "1";
   spinSpeed = "0.5";
   sizes[1] = "0.12";
   times[0] = "0";
   constantAcceleration = "0";
};

datablock ParticleData(BNG_dust_light : DefaultParticle)
{
   textureName = "art/shapes/particles/particle_smoke_soft_01.dds";
   animTexName = "art/shapes/particles/particle_smoke_soft_01.dds";
   colors[0] = "1 0.968504 0.937008 0.349";
   colors[1] = "1 0.968504 0.937008 0.212";
   colors[2] = "1 0.968504 0.937008 0.149606";
   colors[3] = "1 0.968504 0.937008 0";
   dragCoefficient = "5";
   gravityCoefficient = "0.0";
   inheritedVelFactor = "1";
   spinRandomMin = "-360";
   spinRandomMax = "360";
   lifetimeMS = "3000";
   lifetimeVarianceMS = "375";
   sizes[0] = "0.497467";
   sizes[2] = "0.997986";
   sizes[3] = "2.09974";
   times[1] = "0.2";
   times[2] = "0.4";
   times[3] = "0.698039";
   spinSpeed = "0.14";
   sizes[1] = "0.997986";
};

datablock ParticleData(BNG_dust_dark : DefaultParticle)
{
   textureName = "art/shapes/particles/particle_dust_soft_01.dds";
   animTexName = "art/shapes/particles/particle_dust_soft_01.dds";
   colors[0] = "0.25 0.23 0.2 0.7";
   colors[1] = "0.25 0.23 0.2 0.3";
   colors[2] = "0.25 0.23 0.2 0.1";
   colors[3] = "0.25 0.23 0.2 0";
   dragCoefficient = "3.5";
   gravityCoefficient = "0.15";
   inheritedVelFactor = "0.7";
   spinRandomMin = "-360";
   spinRandomMax = "360";
   lifetimeMS = "3000";
   lifetimeVarianceMS = "375";
   sizes[0] = "0.7";
   sizes[2] = "1.1";
   sizes[3] = "2.0";
   times[1] = "0.1";
   times[2] = "0.3";
   times[3] = "0.7";
   spinSpeed = "0.14";
};

datablock ParticleData(BNG_dust_dirt : DefaultParticle)
{
   textureName = "art/shapes/particles/particle_dust_soft_01.dds";
   animTexName = "art/shapes/particles/particle_dust_soft_01.dds";
   colors[0] = "0.944882 0.929134 0.905512 0.88";
   colors[1] = "1 0.944882 0.913386 0.722";
   colors[2] = "1 0.944882 0.913386 0.257";
   colors[3] = "1 0.984252 0.968504 0";
   dragCoefficient = "3.99804";
   gravityCoefficient = "-0.041514";
   inheritedVelFactor = "0.69863";
   spinRandomMin = "-360";
   spinRandomMax = "360";
   lifetimeMS = "3501";
   lifetimeVarianceMS = "2300";
   sizes[0] = "0.5";
   sizes[2] = "1.8";
   sizes[3] = "3.59824";
   times[1] = "0.0833333";
   times[2] = "0.583333";
   times[3] = "1";
   spinSpeed = "0.14";
   sizes[1] = "0.997986";
   times[0] = "0.0208333";
};

datablock ParticleData(BNG_dirt : DefaultParticle)
{
   textureName = "art/shapes/particles/Particle_dust_gravel_01.dds";
   animTexName = "art/shapes/particles/Particle_dust_gravel_01.dds";
   colors[0] = "1 1 1 1";
   colors[1] = "1 1 1 1";
   colors[2] = "1 1 1 1";
   colors[3] = "1 1 1 0";
   dragCoefficient = "0.498534";
   gravityCoefficient = "0.598291";
   inheritedVelFactor = "0.898239";
   spinRandomMin = "-360";
   spinRandomMax = "360";
   lifetimeMS = "1000";
   lifetimeVarianceMS = "375";
   sizes[0] = "0.799609";
   sizes[2] = "0.799609";
   sizes[3] = "0.799609";
   times[1] = "0.0392157";
   times[2] = "0.791667";
   times[3] = "1";
   spinSpeed = "0.14";
   sizes[1] = "0.997986";
};

datablock ParticleData(BNG_smoke_white : DefaultParticle)
{
   textureName = "art/shapes/particles/particle_smoke_soft_01.dds";
   animTexName = "art/shapes/particles/particle_smoke_soft_01.dds";
   colors[0] = "0.992126 0.992126 0.992126 0";
   colors[1] = "0.992126 0.992126 0.992126 0.141";
   colors[2] = "1 1 1 0.062";
   colors[3] = "1 1 1 0";
   dragCoefficient = "3.99316";
   gravityCoefficient = "-0.0610501";
   inheritedVelFactor = "0.684932";
   spinRandomMin = "-708";
   spinRandomMax = "833";
   lifetimeMS = "3000";
   lifetimeVarianceMS = "2999";
   sizes[0] = "0.997986";
   sizes[2] = "1.69078";
   sizes[3] = "2.08753";
   times[1] = "0.054902";
   times[2] = "0.556863";
   times[3] = "1";
   spinSpeed = "0.2";
   sizes[1] = "1.0987";
   times[0] = "0";
};

datablock ParticleData(BNG_smoke_white2 : DefaultParticle)
{
   textureName = "art/shapes/particles/particle_smoke_soft_01.dds";
   animTexName = "art/shapes/particles/particle_smoke_soft_01.dds";
   colors[0] = "0.992126 0.992126 0.992126 0";
   colors[1] = "0.996078 0.996078 0.996078 0.199";
   colors[2] = "0.992126 0.992126 0.992126 0.108";
   colors[3] = "0.992126 0.992126 0.992126 0";
   dragCoefficient = "3.99316";
   gravityCoefficient = "-0.0610501";
   inheritedVelFactor = "0.684932";
   spinRandomMin = "-1000";
   spinRandomMax = "1000";
   lifetimeMS = "700";
   lifetimeVarianceMS = "399";
   sizes[0] = "0.799609";
   sizes[2] = "1.0987";
   sizes[3] = "1.19636";
   times[1] = "0.14902";
   times[2] = "0.517647";
   times[3] = "1";
   spinSpeed = "0.2";
   sizes[1] = "0.997986";
   times[0] = "0";
};

datablock ParticleData(BNG_smoke_black : DefaultParticle)
{
   textureName = "art/shapes/particles/particle_smoke_black_01.dds";
   animTexName = "art/shapes/particles/particle_smoke_black_01.dds";
   colors[0] = "1 1 1 1";
   colors[1] = "1 1 1 0.9";
   colors[2] = "1 1 1 0.5";
   colors[3] = "1 1 1 0";
   dragCoefficient = "4";
   gravityCoefficient = "-0.06";
   inheritedVelFactor = "0.7";
   spinRandomMin = "-360";
   spinRandomMax = "360";
   lifetimeMS = "3500";
   lifetimeVarianceMS = "375";
   sizes[0] = "0.6";
   sizes[2] = "1.1";
   sizes[3] = "2.4";
   times[1] = "0.0416667";
   times[2] = "0.125";
   times[3] = "0.791667";
   spinSpeed = "0.14";
};

datablock ParticleData(BNG_dust_sand : DefaultParticle)
{
   textureName = "art/shapes/particles/particle_dust_soft_01.dds";
   animTexName = "art/shapes/particles/particle_dust_soft_01.dds";
   colors[0] = "0.996078 0.905882 0.815686 1";
   colors[1] = "0.996078 0.909804 0.835294 0.897638";
   colors[2] = "0.996078 0.901961 0.807843 0.838";
   colors[3] = "0.996078 0.937255 0.878431 0";
   dragCoefficient = "2.99609";
   gravityCoefficient = "0.0366306";
   inheritedVelFactor = "0.798434";
   spinRandomMin = "-360";
   spinRandomMax = "360";
   lifetimeMS = "3500";
   lifetimeVarianceMS = "375";
   sizes[0] = "0.497467";
   sizes[2] = "1.0987";
   sizes[3] = "2.39883";
   times[1] = "0.0392157";
   times[2] = "0.121569";
   times[3] = "0.788235";
   spinSpeed = "0.14";
   sizes[1] = "0.997986";
};

datablock ParticleData(BNG_dust_small : DefaultParticle)
{
   textureName = "art/shapes/particles/particle_dust_soft_01.dds";
   animTexName = "art/shapes/particles/particle_dust_soft_01.dds";
   colors[0] = "0.992126 0.929134 0.889764 0";
   colors[1] = "0.992126 0.92126 0.866142 1";
   colors[2] = "0.992126 0.897638 0.834646 0.645669";
   colors[3] = "0.992126 0.897638 0.834646 0.00787402";
   times[1] = "0.0470588";
   times[2] = "0.0980392";
   dragCoefficient = "2.98143";
   gravityCoefficient = "0";
   inheritedVelFactor = "0.455969";
   lifetimeMS = "2200";
   lifetimeVarianceMS = "500";
   spinSpeed = "0.146";
   spinRandomMin = "-416";
   spinRandomMax = "541";
   sizes[2] = "0.93";
   sizes[3] = "2.0";
};

datablock ParticleData(BNG_gravel : DefaultParticle)
{
   dragCoefficient = "0.5";
   gravityCoefficient = "0.6";
   inheritedVelFactor = "0.9";
   lifetimeMS = "1501";
   spinSpeed = "0.042";
   textureName = "art/shapes/particles/particle_dust_gravel_01.dds";
   animTexName = "art/shapes/particles/particle_dust_gravel_01.dds";
   colors[0] = "1 1 1 1";
   colors[1] = "1 1 1 1";
   colors[2] = "1 1 1 1";
   colors[3] = "1 1 1 0";
   sizes[0] = "0.8";
   sizes[1] = "0.8";
   sizes[2] = "0.8";
   sizes[3] = "0.8";
   times[1] = "0.101961";
   times[2] = "0.435294";
   times[3] = "0.956863";
   lifetimeVarianceMS = "0";
   spinRandomMin = "-360";
   spinRandomMax = "360";
   times[0] = "0";
};

datablock ParticleData(BNG_chunk_small : DefaultParticle)
{
   dragCoefficient = "0.498534";
   gravityCoefficient = "0.798535";
   inheritedVelFactor = "0";
   lifetimeMS = "1501";
   spinSpeed = "2";
   textureName = "art/shapes/particles/particle_chunk_01.dds";
   animTexName = "art/shapes/particles/particle_chunk_01.dds";
   colors[0] = "1 1 1 1";
   colors[1] = "0.996078 0.992157 0.992157 1";
   colors[2] = "1 1 1 1";
   colors[3] = "1 1 1 0";
   sizes[0] = "0.3";
   sizes[1] = "0.3";
   sizes[2] = "0.3";
   sizes[3] = "0.3";
   times[1] = "0.101961";
   times[2] = "0.411765";
   times[3] = "1";
   lifetimeVarianceMS = "200";
   spinRandomMin = "-360";
   spinRandomMax = "360";
   times[0] = "0";
};

datablock ParticleData(BNG_chunk_med : DefaultParticle)
{
   dragCoefficient = "0.25";
   gravityCoefficient = "0.798535";
   inheritedVelFactor = "0";
   lifetimeMS = "1501";
   spinSpeed = "0.646";
   textureName = "art/shapes/particles/particle_chunk_01.dds";
   animTexName = "art/shapes/particles/particle_chunk_01.dds";
   colors[0] = "1 1 1 1";
   colors[1] = "1 1 1 1";
   colors[2] = "1 1 1 1";
   colors[3] = "0.996078 0.996078 0.996078 0";
   sizes[0] = "0.5";
   sizes[1] = "0.9";
   sizes[2] = "0.7";
   sizes[3] = "1.2";
   times[1] = "0.104167";
   times[2] = "0.431373";
   times[3] = "0.956863";
   lifetimeVarianceMS = "200";
   spinRandomMin = "-500";
   spinRandomMax = "583.5";
   times[0] = "0";
};


datablock ParticleData(BNG_sand : DefaultParticle)
{
   dragCoefficient = "5";
   gravityCoefficient = "0.3";
   inheritedVelFactor = "1";
   lifetimeMS = "1000";
   spinSpeed = "0";
   textureName = "art/shapes/particles/particle_sandspray_01.dds";
   animTexName = "art/shapes/particles/particle_sandspray_01.dds";
   colors[0] = "1 1 1 0.195";
   colors[1] = "1 1 1 1";
   colors[2] = "1 1 1 0.187";
   colors[3] = "1 1 1 0";
   sizes[0] = "0.4";
   sizes[1] = "0.5";
   sizes[2] = "1.6";
   sizes[3] = "2.2";
   times[1] = "0.1875";
   times[2] = "0.4375";
   times[3] = "1";
   lifetimeVarianceMS = "0";
   spinRandomMin = "-708";
   spinRandomMax = "708";
   times[0] = "0";
};


datablock ParticleData(BNG_mud_1 : DefaultParticle)
{
   sizes[0] = "0.0976622";
   sizes[1] = "0.799609";
   sizes[2] = "1.99902";
   sizes[3] = "1.59922";
   times[1] = "0.0823529";
   times[2] = "0.580392";
   textureName = "art/shapes/particles/Particle_mud_01.dds";
   animTexName = "art/shapes/particles/Particle_mud_01.dds";
   colors[0] = "0.992126 0.992126 0.992126 1";
   colors[1] = "0.992126 0.992126 0.992126 1";
   colors[2] = "0.992126 0.992126 0.992126 1";
   gravityCoefficient = "0.495726";
   spinSpeed = "0.3";
   dragCoefficient = "0.298143";
   lifetimeMS = "1400";
   lifetimeVarianceMS = "375";
   times[0] = "0";
   times[3] = "1";
   inheritedVelFactor = "0.248532";
   colors[3] = "0.992126 0.992126 0.992126 0";
};

datablock ParticleData(BNG_glassbreak : DefaultParticle)
{
   sizes[0] = "0.399805";
   sizes[1] = "0.399805";
   sizes[2] = "0.497467";
   sizes[3] = "0.598181";
   times[1] = "0.227451";
   times[2] = "0.75";
   textureName = "art/shapes/particles/Particle_glass_01.dds";
   animTexName = "art/shapes/particles/Particle_glass_01.dds";
   colors[0] = "0.992126 0.992126 0.992126 1";
   colors[1] = "0.992126 0.992126 0.992126 1";
   colors[2] = "0.992126 0.992126 0.992126 1";
   colors[3] = "0.992126 0.992126 0.992126 0";
   gravityCoefficient = "0.3";
   spinSpeed = "0.646";
   inheritedVelFactor = "0.299413";
   dragCoefficient = "0.562072";
   lifetimeMS = "1900";
   lifetimeVarianceMS = "300";
};
