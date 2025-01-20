
singleton Material(hatch)
{
   mapTo = "hatch";
   diffuseMap[2] = "vehicles/hatch/hatch_c_alt.dds";
   specularMap[2] = "vehicles/hatch/hatch_s_alt.dds";
   normalMap[2] = "vehicles/hatch/hatch_n.dds";
   diffuseMap[1] = "vehicles/hatch/hatch_d_alt.dds";
   specularMap[1] = "vehicles/hatch/hatch_s_alt.dds";
   normalMap[1] = "vehicles/hatch/hatch_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/hatch/hatch_n.dds";
   //diffuseMap[3] = "vehicles/hatch/hatch_dirt.dds";
   //normalMap[3] = "vehicles/hatch/hatch_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   diffuseColor[2] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   useAnisotropic[2] = "1";
   //diffuseColor[3] = "1.5 1.5 1.5 1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   instanceDiffuse[2] = true;
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(hatch_interior)
{
   mapTo = "hatch_interior";
   diffuseMap[0] = "hatch_interior_d.dds";
   normalMap[0] = "hatch_interior_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   useAnisotropic[0] = "1";
   specularMap[0] = "hatch_interior_s.dds";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "0.8 0.8 0.8 1";
};

singleton Material(hatch_gauges)
{
   mapTo = "hatch_gauges";
   diffuseMap[1] = "hatch_gauges_g.dds";
   specularMap[1] = "hatch_gauges_s.dds";
   normalMap[1] = "hatch_gauges_n.dds";
   diffuseMap[0] = "hatch_gauges_d.dds";
   specularMap[0] = "hatch_gauges_s.dds";
   normalMap[0] = "hatch_gauges_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   glow[1] = "0";
   emissive[1] = "1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "0.75 0.75 0.75 1";
   diffuseColor[1] = "1.5 1.5 1.5 0.2";
};

singleton Material(hatch_gauges_on)
{
   mapTo = "hatch_gauges_on";
   diffuseMap[1] = "hatch_gauges_g.dds";
   specularMap[1] = "hatch_gauges_s.dds";
   normalMap[1] = "hatch_gauges_n.dds";
   diffuseMap[0] = "hatch_gauges_d.dds";
   specularMap[0] = "hatch_gauges_s.dds";
   normalMap[0] = "hatch_gauges_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   glow[1] = "1";
   emissive[1] = "1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "0.75 0.75 0.75 1";
   diffuseColor[1] = "0.8 1.5 1.5 0.2";
};

singleton Material(hatch_glass)
{
   mapTo = "hatch_glass";
   diffuseMap[0] = "vehicles/hatch/hatch_glass_d.dds";
   specularMap[0] = "vehicles/hatch/hatch_glass_s.dds";
   diffuseMap[1] = "vehicles/hatch/hatch_glass_da.dds";
   specularMap[1] = "vehicles/hatch/hatch_glass_s.dds";
   //diffuseMap[2] = "vehicles/hatch/hatch_glass_dirt.dds";
   specularPower[0] = "128";
   pixelSpecular[0] = "1";
   specularPower[1] = "128";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   //diffuseColor[2] = "1.5 1.5 1.5 1";
   castShadows = "0";
   translucent = "1";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(hatch_lights_on)
{
   mapTo = "hatch_lights_on";
   diffuseMap[2] = "vehicles/hatch/hatch_lights_g.dds";
   specularMap[2] = "vehicles/hatch/hatch_lights_s.dds";
   normalMap[2] = "vehicles/hatch/hatch_lights_n.dds";
   diffuseMap[1] = "vehicles/hatch/hatch_lights_d.dds";
   specularMap[1] = "vehicles/hatch/hatch_lights_s.dds";
   normalMap[1] = "vehicles/hatch/hatch_lights_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/hatch/hatch_lights_n.dds";
   //diffuseMap[3] = "vehicles/hatch/hatch_lights_dirt.dds";
   //normalMap[3] = "vehicles/hatch/hatch_lights_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   diffuseColor[2] = "1.5 1.5 1.5 0.12";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   useAnisotropic[2] = "1";
   //diffuseColor[3] = "1.5 1.5 1.5 1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   glow[2] = "1";
   emissive[2] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(hatch_lights_on_intense)
{
   mapTo = "hatch_lights_on_intense";
   diffuseMap[2] = "vehicles/hatch/hatch_lights_g.dds";
   specularMap[2] = "vehicles/hatch/hatch_lights_s.dds";
   normalMap[2] = "vehicles/hatch/hatch_lights_n.dds";
   diffuseMap[1] = "vehicles/hatch/hatch_lights_d.dds";
   specularMap[1] = "vehicles/hatch/hatch_lights_s.dds";
   normalMap[1] = "vehicles/hatch/hatch_lights_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/hatch/hatch_lights_n.dds";
   //diffuseMap[3] = "vehicles/hatch/hatch_lights_dirt.dds";
   //normalMap[3] = "vehicles/hatch/hatch_lights_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   diffuseColor[2] = "1.5 1.5 1.5 0.20";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   useAnisotropic[2] = "1";
   //diffuseColor[3] = "1.5 1.5 1.5 1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   glow[2] = "1";
   emissive[2] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(hatch_glass_dmg)
{
   mapTo = "hatch_glass_dmg";
   diffuseMap[0] = "vehicles/hatch/hatch_glass_dmg_d.dds";
   specularMap[0] = "vehicles/common/glass_dmg_s.dds";
   normalMap[0] = "vehicles/common/glass_dmg_n.dds";
   //diffuseMap[2] = "vehicles/hatch/hatch_glass_dirt.dds";
   specularPower[0] = "32";
   diffuseColor[0] = "1.5 1.5 1.5 1";
   useAnisotropic[0] = "1";
   //diffuseColor[2] = "1.5 1.5 1.5 1";
   castShadows = "0";
   translucent = "1";
   alphaTest = "1";
   alphaRef = "0";
   //cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(hatch_lights)
{
   mapTo = "hatch_lights";
   diffuseMap[1] = "vehicles/hatch/hatch_lights_d.dds";
   specularMap[1] = "vehicles/hatch/hatch_lights_s.dds";
   normalMap[1] = "vehicles/hatch/hatch_lights_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/hatch/hatch_lights_n.dds";
   //diffuseMap[2] = "vehicles/hatch/hatch_lights_dirt.dds";
   //normalMap[2] = "vehicles/hatch/hatch_lights_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   //diffuseColor[2] = "1.5 1.5 1.5 1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(hatch_lights_dmg)
{
   mapTo = "hatch_lights_dmg";
   diffuseMap[1] = "vehicles/hatch/hatch_lights_dmg_d.dds";
   specularMap[1] = "vehicles/hatch/hatch_lights_dmg_s.dds";
   normalMap[1] = "vehicles/hatch/hatch_lights_dmg_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/hatch/hatch_lights_dmg_n.dds";
   //diffuseMap[2] = "vehicles/hatch/hatch_lights_dirt.dds";
   //normalMap[2] = "vehicles/hatch/hatch_lights_dmg_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   //diffuseColor[2] = "1.5 1.5 1.5 1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(hatch_reverselight)
{
   mapTo = "hatch_reverselight";
};

singleton Material(hatch_signal_R)
{
   mapTo = "hatch_signal_R";
};

singleton Material(hatch_signal_L)
{
   mapTo = "hatch_signal_L";
};

singleton Material(hatch_headlight)
{
   mapTo = "hatch_headlight";
};

singleton Material(hatch_parkinglight)
{
   mapTo = "hatch_parkinglight";
};

singleton Material(hatch_chmsl)
{
   mapTo = "hatch_chmsl";
};

singleton Material(hatch_taillight)
{
   mapTo = "hatch_taillight";
};

singleton Material(hatch_highbeam)
{
   mapTo = "highbeam";
};
