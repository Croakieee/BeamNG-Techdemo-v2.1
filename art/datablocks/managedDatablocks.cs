
datablock DecalData(tireTrackDecal)
{
   Material = "tireTrack";
   textureCoordCount = "0";
   size = "0.4";
   lifeSpan = "60000";
   fadeTime = "60000";
   fadeStartPixelSize = "5";
   fadeEndPixelSize = "8";
};

singleton SFXProfile(amb_windtrees_01 : EngineTestSound)
{
   fileName = "art/sound/environment/amb_windtrees_01.ogg";
};

singleton SFXProfile(amb_birds_01 : amb_windtrees_01)
{
   fileName = "art/sound/environment/amb_birds_01.ogg";
};


singleton SFXProfile(amb_rain_medium : amb_windtrees_01)
{
   fileName = "art/sound/environment/amb_rain_medium.ogg";
   description = "AudioLoop2D";
};

singleton SFXProfile(amb_beach_close_01 : amb_windtrees_01)
{
   fileName = "art/sound/environment/amb_beach_close_01.ogg";
};

singleton SFXProfile(amb_beach_close_02 : amb_beach_close_01)
{
   fileName = "art/sound/environment/amb_beach_close_02.ogg";
};

singleton SFXProfile(amb_river_crossing_01 : amb_beach_close_01)
{
   fileName = "art/sound/environment/amb_river_crossing_01.ogg";
};

datablock PrecipitationData(Snow_menu)
{
   dropTexture = "art/shapes/particles/Particle_snow.dds";
};

datablock LightFlareData(BNG_SunFlare_1 : LightFlareExample2)
{
   flareTexture = "art/special/BNG_lensFlareSheet0.png";
   elementTint[1] = "0.945098 0.92549 0.894118 1";
   elementUseLightColor[1] = "0";
   elementRect[8] = "1024 0 128 128";
   elementRect[9] = "1024 0 128 128";
   elementRect[10] = "1024 0 128 128";
   elementDist[8] = "5";
   elementDist[9] = "13";
   elementDist[10] = "-10";
   elementScale[1] = "1";
   elementScale[8] = "0.8";
   elementScale[9] = "3.5";
   elementScale[10] = "0.5";
   elementTint[8] = "1 1 1 1";
   elementTint[9] = "1 1 1 1";
   elementTint[10] = "0.694118 0.694118 0.694118 1";
   elementRotate[8] = "1";
   elementRotate[9] = "1";
   elementRect[11] = "1024 0 128 128";
   elementDist[11] = "-2.5";
   elementScale[11] = "0.3";
   elementTint[11] = "0.694118 0.694118 0.694118 1";
   elementRotate[11] = "1";
   overallScale = "1";
};


datablock ParticleEmitterData(lightTest1 : DefaultEmitter)
{
   particles = "lightTestParticle";
   ejectionPeriodMS = "20";
   ejectionVelocity = "2";
   velocityVariance = "1";
};

datablock ParticleData(lightTestParticle : DefaultParticle)
{
   sizes[0] = "0.997986";
   sizes[1] = "0.997986";
   sizes[2] = "0.997986";
   sizes[3] = "0.997986";
   times[1] = "0.329412";
   times[2] = "0.658824";
   lifetimeMS = "6751";
   lifetimeVarianceMS = "3563";
   colors[0] = "0.996078 0.992157 0.992157 1";
   colors[1] = "0.996078 0.996078 0.992157 0.637795";
   colors[2] = "0.996078 0.992157 0.992157 0.330709";
};

datablock ParticleEmitterNodeData(lightExampleEmitterNodeData1)
{
};
