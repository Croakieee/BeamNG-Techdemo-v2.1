singleton Material(cargobox)
{
   mapTo = "cargobox";
   diffuseMap[1] = "vehicles/common/cargobox_d.dds";
   specularMap[1] = "vehicles/common/cargobox_s.dds";
   normalMap[1] = "vehicles/common/cargobox_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/cargobox_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(grille)
{
   mapTo = "grille";
   normalMap[0] = "vehicles/common/grille_n.dds";
   diffuseMap[0] = "vehicles/common/grille_d.dds";
   diffuseColor[0] = "1 1 1 1";
   specularPower[0] = "16";
   specularPower[1] = "16";
   useAnisotropic[0] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "lerpAlpha";
   alphaTest = "0";
   alphaRef = "5";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(van_lights)
{
   mapTo = "van_lights";
   diffuseMap[1] = "vehicles/van/van_lights_d.dds";
   specularMap[1] = "vehicles/van/van_lights_s.dds";
   normalMap[1] = "vehicles/van/van_lights_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/van/van_lights_n.dds";
   //diffuseMap[2] = "vehicles/van/van_lights_dirt.dds";
   //normalMap[2] = "vehicles/van/van_lights_n.dds";
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

singleton Material(van_lights_on)
{
   mapTo = "van_lights_on";
   diffuseMap[2] = "vehicles/van/van_lights_g.dds";
   specularMap[2] = "vehicles/van/van_lights_s.dds";
   normalMap[2] = "vehicles/van/van_lights_n.dds";
   diffuseMap[1] = "vehicles/van/van_lights_d.dds";
   specularMap[1] = "vehicles/van/van_lights_s.dds";
   normalMap[1] = "vehicles/van/van_lights_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/van/van_lights_n.dds";
   //diffuseMap[3] = "vehicles/van/van_lights_dirt.dds";
   //normalMap[3] = "vehicles/van/van_lights_n.dds";
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

singleton Material(van_lights_on_intense)
{
   mapTo = "van_lights_on_intense";
   diffuseMap[2] = "vehicles/van/van_lights_g.dds";
   specularMap[2] = "vehicles/van/van_lights_s.dds";
   normalMap[2] = "vehicles/van/van_lights_n.dds";
   diffuseMap[1] = "vehicles/van/van_lights_d.dds";
   specularMap[1] = "vehicles/van/van_lights_s.dds";
   normalMap[1] = "vehicles/van/van_lights_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/van/van_lights_n.dds";
   //diffuseMap[3] = "vehicles/van/van_lights_dirt.dds";
   //normalMap[3] = "vehicles/van/van_lights_n.dds";
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

singleton Material(van_lights_dmg)
{
   mapTo = "van_lights_dmg";
   diffuseMap[1] = "vehicles/van/van_lights_dmg_d.dds";
   specularMap[1] = "vehicles/van/van_lights_dmg_s.dds";
   normalMap[1] = "vehicles/van/van_lights_dmg_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/van/van_lights_dmg_n.dds";
   //diffuseMap[2] = "vehicles/van/van_lights_dirt.dds";
   //normalMap[2] = "vehicles/van/van_lights_dmg_n.dds";
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

singleton Material(tsfb_lights)
{
   mapTo = "tsfb_lights";
   diffuseMap[1] = "vehicles/common/tsfb_lights_d.dds";
   specularMap[1] = "vehicles/common/tsfb_lights_s.dds";
   normalMap[1] = "vehicles/common/tsfb_lights_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/tsfb_lights_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(tsfb_lights_on)
{
   mapTo = "tsfb_lights_on";
   diffuseMap[2] = "vehicles/common/tsfb_lights_g.dds";
   specularMap[2] = "vehicles/common/tsfb_lights_s.dds";
   normalMap[2] = "vehicles/common/tsfb_lights_n.dds";
   diffuseMap[1] = "vehicles/common/tsfb_lights_d.dds";
   specularMap[1] = "vehicles/common/tsfb_lights_s.dds";
   normalMap[1] = "vehicles/common/tsfb_lights_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/tsfb_lights_n.dds";
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

singleton Material(tsfb_lights_on_intense)
{
   mapTo = "tsfb_lights_on_intense";
   diffuseMap[2] = "vehicles/common/tsfb_lights_g.dds";
   specularMap[2] = "vehicles/common/tsfb_lights_s.dds";
   normalMap[2] = "vehicles/common/tsfb_lights_n.dds";
   diffuseMap[1] = "vehicles/common/tsfb_lights_d.dds";
   specularMap[1] = "vehicles/common/tsfb_lights_s.dds";
   normalMap[1] = "vehicles/common/tsfb_lights_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/tsfb_lights_n.dds";
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

singleton Material(tsfb_lights_dmg)
{
   mapTo = "tsfb_lights_dmg";
   diffuseMap[1] = "vehicles/common/tsfb_lights_dmg_d.dds";
   specularMap[1] = "vehicles/common/tsfb_lights_dmg_s.dds";
   normalMap[1] = "vehicles/common/tsfb_lights_dmg_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/tsfb_lights_dmg_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(wheel_01a)
{
   mapTo = "wheel_01a";
   diffuseMap[1] = "vehicles/common/wheel_01a_d.dds";
   specularMap[1] = "vehicles/common/wheel_01a_s.dds";
   normalMap[1] = "vehicles/common/wheel_01a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/wheel_01a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(wheel_02a)
{
   mapTo = "wheel_02a";
   diffuseMap[1] = "vehicles/common/wheel_02a_d.dds";
   specularMap[1] = "vehicles/common/wheel_02a_s.dds";
   normalMap[1] = "vehicles/common/wheel_02a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/wheel_02a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(wheel_02b)
{
   mapTo = "wheel_02b";
   diffuseMap[1] = "vehicles/common/wheel_02b_d.dds";
   specularMap[1] = "vehicles/common/wheel_02a_s.dds";
   normalMap[1] = "vehicles/common/wheel_02a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/wheel_02a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1.5 1.5 1.5 1.5";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(wheel_03a)
{
   mapTo = "wheel_03a";
   diffuseMap[1] = "vehicles/common/wheel_03a_d.dds";
   specularMap[1] = "vehicles/common/wheel_03a_s.dds";
   normalMap[1] = "vehicles/common/wheel_03a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/wheel_03a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(wheel_04a)
{
   mapTo = "wheel_04a";
   diffuseMap[1] = "vehicles/common/wheel_04a_d.dds";
   specularMap[1] = "vehicles/common/wheel_04a_s.dds";
   normalMap[1] = "vehicles/common/wheel_04a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/wheel_04a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(wheel_05a)
{
   mapTo = "wheel_05a";
   diffuseMap[1] = "vehicles/common/wheel_05a_d.dds";
   specularMap[1] = "vehicles/common/wheel_05a_s.dds";
   normalMap[1] = "vehicles/common/wheel_05a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/wheel_05a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(offroadwheel_01a)
{
   mapTo = "offroadwheel_01a";
   diffuseMap[1] = "vehicles/common/offroadwheel_01a_d.dds";
   specularMap[1] = "vehicles/common/offroadwheel_01a_s.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   //diffuseMap[2] = "vehicles/common/offroadwheel_01a_dirt.dds";
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
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(steelwheel_01a)
{
   mapTo = "steelwheel_01a";
   diffuseMap[1] = "vehicles/common/steelwheel_01a_d.dds";
   specularMap[1] = "vehicles/common/steelwheel_01a_s.dds";
   normalMap[1] = "vehicles/common/steelwheel_01a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/steelwheel_01a_n.dds";
   //diffuseMap[2] = "vehicles/common/steelwheel_01a_dirt.dds";
   //normalMap[2] = "vehicles/common/steelwheel_01a_n.dds";
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
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(steelwheel_02a)
{
   mapTo = "steelwheel_02a";
   diffuseMap[1] = "vehicles/common/steelwheel_02a_d.dds";
   specularMap[1] = "vehicles/common/steelwheel_02a_s.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   //diffuseMap[2] = "vehicles/common/steelwheel_02a_dirt.dds";
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
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(steelwheel_03a)
{
   mapTo = "steelwheel_03a";
   diffuseMap[1] = "vehicles/common/steelwheel_03a_d.dds";
   specularMap[1] = "vehicles/common/steelwheel_03a_s.dds";
   normalMap[1] = "vehicles/common/steelwheel_03a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/steelwheel_03a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(steelwheel_04a)
{
   mapTo = "steelwheel_04a";
   diffuseMap[1] = "vehicles/common/steelwheel_04a_d.dds";
   specularMap[1] = "vehicles/common/steelwheel_04a_s.dds";
   normalMap[1] = "vehicles/common/steelwheel_04a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/steelwheel_04a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(steelwheel_05a)
{
   mapTo = "steelwheel_05a";
   diffuseMap[1] = "vehicles/common/steelwheel_05a_d.dds";
   specularMap[1] = "vehicles/common/steelwheel_05a_s.dds";
   normalMap[1] = "vehicles/common/steelwheel_05a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/steelwheel_05a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(steelwheel_06a)
{
   mapTo = "steelwheel_06a";
   diffuseMap[1] = "vehicles/common/steelwheel_06a_d.dds";
   specularMap[1] = "vehicles/common/steelwheel_06a_s.dds";
   normalMap[1] = "vehicles/common/steelwheel_06a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/steelwheel_06a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(steelwheel_07a)
{
   mapTo = "steelwheel_07a";
   diffuseMap[1] = "vehicles/common/steelwheel_07a_d.dds";
   specularMap[1] = "vehicles/common/steelwheel_07a_s.dds";
   normalMap[1] = "vehicles/common/steelwheel_07a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/steelwheel_07a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(ibishu_hubcap_01a)
{
   mapTo = "ibishu_hubcap_01a";
   diffuseMap[1] = "vehicles/common/ibishu_hubcap_01a_d.dds";
   specularMap[1] = "vehicles/common/ibishu_hubcap_01a_s.dds";
   normalMap[1] = "vehicles/common/ibishu_hubcap_01a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/ibishu_hubcap_01a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(ibishu_hubcap_02a)
{
   mapTo = "ibishu_hubcap_02a";
   diffuseMap[1] = "vehicles/common/ibishu_hubcap_02a_d.dds";
   specularMap[1] = "vehicles/common/ibishu_hubcap_02a_s.dds";
   normalMap[1] = "vehicles/common/ibishu_hubcap_02a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/ibishu_hubcap_02a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(bruckell_hubcap_01a)
{
   mapTo = "bruckell_hubcap_01a";
   diffuseMap[1] = "vehicles/common/bruckell_hubcap_01a_d.dds";
   specularMap[1] = "vehicles/common/bruckell_hubcap_01a_s.dds";
   normalMap[1] = "vehicles/common/bruckell_hubcap_01a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/bruckell_hubcap_01a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(hirochi_hubcap_01a)
{
   mapTo = "hirochi_hubcap_01a";
   diffuseMap[1] = "vehicles/common/hirochi_hubcap_01a_d.dds";
   specularMap[1] = "vehicles/common/hirochi_hubcap_01a_s.dds";
   normalMap[1] = "vehicles/common/hirochi_hubcap_01a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/hirochi_hubcap_01a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(hirochi_wheel_01a)
{
   mapTo = "hirochi_wheel_01a";
   diffuseMap[1] = "vehicles/common/hirochi_wheel_01a_d.dds";
   specularMap[1] = "vehicles/common/hirochi_wheel_01a_s.dds";
   normalMap[1] = "vehicles/common/hirochi_wheel_01a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/hirochi_wheel_01a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(hirochi_wheel_02a)
{
   mapTo = "hirochi_wheel_02a";
   diffuseMap[1] = "vehicles/common/hirochi_wheel_02a_d.dds";
   specularMap[1] = "vehicles/common/hirochi_wheel_02a_s.dds";
   normalMap[1] = "vehicles/common/hirochi_wheel_02a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/hirochi_wheel_02a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
};


singleton Material(super_wheel)
{
   mapTo = "super_wheel";
   diffuseMap[1] = "vehicles/common/super_wheel_d.dds";
   specularMap[1] = "vehicles/common/super_wheel_s.dds";
   normalMap[1] = "vehicles/common/super_wheel_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/super_wheel_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   diffuseColor[1] = "1.5 1.5 1.5 1";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(pickup_alloy)
{
   mapTo = "pickup_alloy";
   diffuseMap[1] = "vehicles/common/pickup_alloy_d.dds";
   specularMap[1] = "vehicles/common/pickup_alloy_s.dds";
   normalMap[1] = "vehicles/common/pickup_alloy_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/pickup_alloy_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(tire)
{
   mapTo = "tire";
   diffuseMap[1] = "vehicles/common/tire_01a_d.dds";
   specularMap[1] = "vehicles/common/tire_01a_s.dds";
   normalMap[1] = "vehicles/common/tire_01a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/tire_01a_n.dds";
   //diffuseMap[2] = "vehicles/common/tire_01a_dirt.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   //diffuseColor[2] = "1.5 1.5 1.5 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(tire_01a)
{
   mapTo = "tire_01a";
   diffuseMap[1] = "vehicles/common/tire_01a_d.dds";
   specularMap[1] = "vehicles/common/tire_01a_s.dds";
   normalMap[1] = "vehicles/common/tire_01a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/tire_01a_n.dds";
   //diffuseMap[2] = "vehicles/common/tire_01a_dirt.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   //diffuseColor[2] = "1.5 1.5 1.5 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(tire_02a)
{
   mapTo = "tire_02a";
   diffuseMap[1] = "vehicles/common/tire_02a_d.dds";
   specularMap[1] = "vehicles/common/tire_02a_s.dds";
   normalMap[1] = "vehicles/common/tire_02a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/tire_02a_n.dds";
   //diffuseMap[2] = "vehicles/common/tire_02a_dirt.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   //diffuseColor[2] = "1.5 1.5 1.5 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(tire_01b)
{
   mapTo = "tire_01b";
   diffuseMap[1] = "vehicles/common/tire_01b_d.dds";
   specularMap[1] = "vehicles/common/tire_01a_s.dds";
   normalMap[1] = "vehicles/common/tire_01a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/tire_01a_n.dds";
   //diffuseMap[2] = "vehicles/common/tire_01a_dirt.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   //diffuseColor[2] = "1.5 1.5 1.5 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(tire_01c)
{
   mapTo = "tire_01c";
   diffuseMap[1] = "vehicles/common/tire_01c_d.dds";
   specularMap[1] = "vehicles/common/tire_01a_s.dds";
   normalMap[1] = "vehicles/common/tire_01a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/tire_01a_n.dds";
   //diffuseMap[2] = "vehicles/common/tire_01a_dirt.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   //diffuseColor[2] = "1.5 1.5 1.5 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(offroadtire_01a)
{
   mapTo = "offroadtire";
   diffuseMap[1] = "vehicles/common/offroadtire_01a_d.dds";
   specularMap[1] = "vehicles/common/offroadtire_01a_s.dds";
   normalMap[1] = "vehicles/common/offroadtire_01a_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/offroadtire_01a_n.dds";
   //diffuseMap[2] = "vehicles/common/offroadtire_01a_dirt.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   //diffuseColor[2] = "1.5 1.5 1.5 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};

singleton Material(steer_01a)
{
   mapTo = "steer_01a";
   diffuseMap[0] = "vehicles/common/steer_01a_d.dds";
   normalMap[0] = "vehicles/common/steer_01a_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   useAnisotropic[0] = "1";
   specularMap[0] = "vehicles/common/steer_01a_s.dds";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1.5 1.5 1.5 1";
};

singleton Material(licenseplate)
{
   mapTo = "licenseplate";
   diffuseColor[0] = "0.588235 0.588235 0.588235 1";
   specular[0] = "0.9 0.9 0.9 1";
   useAnisotropic[0] = "1";
   specularPower[0] = "10";
   translucentBlendOp = "None";
};

singleton Material(decals_police)
{
   mapTo = "decals_police";
   diffuseMap[1] = "vehicles/common/decals_police.dds";
   specularMap[1] = "vehicles/common/null.dds";
   //diffuseMap[2] = "vehicles/common/decals_police_dirt.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   diffuseColor[0] = "0 0 0 0";
   diffuseColor[1] = "0 0.3 0.9 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   //diffuseColor[2] = "1.5 1.5 1.5 1";
   castShadows = "0";
   translucent = "1";
   //translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
   materialTag0 = "beamng"; materialTag1 = "vehicle"; materialTag2 = "decal";
   translucentZWrite = "1";
};

singleton Material(decals_gauges)
{
   mapTo = "decals_gauges";
   diffuseMap[0] = "vehicles/common/decals_gauges.dds";
   diffuseColor[0] = "1 1 1 1";
   diffuseMap[1] = "vehicles/common/decals_gauges.dds";
   diffuseColor[1] = "1 1 1 0.35";
   castShadows = "0";
   translucent = "1";
   alphaTest = "1";
   alphaRef = "0";
   glow[1] = "1";
   emissive[1] = "1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle"; materialTag2 = "decal";
};

singleton Material(rollcage_01a)
{
   mapTo = "rollcage_01a";
   diffuseColor[0] = "0.5 0.5 0.5 1";
   specularColor[0] = "1 1 1 1";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
};

singleton Material(invis)
{
   mapTo = "invis";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(signal_L)
{
   mapTo = "signal_L";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(signal_R)
{
   mapTo = "signal_R";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(parkingbrake)
{
   mapTo = "parkingbrake";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(battery)
{
   mapTo = "battery";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(checkengine)
{
   mapTo = "checkengine";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(hazard)
{
   mapTo = "hazard";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(lowpressure)
{
   mapTo = "lowpressure";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(abs)
{
   mapTo = "abs";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(tcs)
{
   mapTo = "tcs";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(esc)
{
   mapTo = "esc";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(temp)
{
   mapTo = "temp";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(oil)
{
   mapTo = "oil";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(lowfuel)
{
   mapTo = "lowfuel";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(highbeam)
{
   mapTo = "highbeam";
   diffuseColor[0] = "0 0 0 0";
   castShadows = "0";
   translucent = "1";
};

singleton Material(tsfb_reverselight)
{
   mapTo = "tsfb_reverselight";
   diffuseColor[0] = "0.588 0.588 0.588 1";
   specular[0] = "0.9 0.9 0.9 1";
   specularPower[0] = "10";
   translucentBlendOp = "None";
};

singleton Material(tsfb_taillight)
{
   mapTo = "tsfb_taillight";
   diffuseColor[0] = "0.588 0.588 0.588 1";
   diffuseColor[2] = "White";
   specular[0] = "0.9 0.9 0.9 1";
   specularPower[0] = "10";
   translucentBlendOp = "None";
};

singleton Material(tsfb_signal_R)
{
   mapTo = "tsfb_signal_R";
   diffuseColor[0] = "0.588 0.588 0.588 1";
   specular[0] = "0.9 0.9 0.9 1";
   specularPower[0] = "10";
   translucentBlendOp = "None";
};

singleton Material(tsfb)
{
   mapTo = "tsfb";
   diffuseMap[1] = "vehicles/common/tsfb_d.dds";
   specularMap[1] = "vehicles/common/tsfb_s.dds";
   normalMap[1] = "vehicles/common/tsfb_n.dds";
   diffuseMap[0] = "vehicles/common/null.dds";
   specularMap[0] = "vehicles/common/null.dds";
   normalMap[0] = "vehicles/common/tsfb_n.dds";
   specularPower[0] = "16";
   pixelSpecular[0] = "1";
   specularPower[1] = "16";
   pixelSpecular[1] = "1";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
   diffuseColor[0] = "1 1 1 1";
   diffuseColor[1] = "1 1 1 1";
   useAnisotropic[0] = "1";
   useAnisotropic[1] = "1";
   castShadows = "1";
   translucent = "1";
   translucentBlendOp = "None";
   alphaTest = "1";
   alphaRef = "0";
   cubemap = "BNG_Sky_02_cubemap";
};

singleton Material(tsfb_signal_L)
{
   mapTo = "tsfb_signal_L";
   diffuseColor[0] = "0.588 0.588 0.588 1";
   specular[0] = "0.9 0.9 0.9 1";
   specularPower[0] = "10";
   translucentBlendOp = "None";
};

singleton Material(skidplate)
{
   mapTo = "skidplate";
   normalMap[0] = "vehicles/common/skidplate_n.dds";
   diffuseMap[0] = "vehicles/common/skidplate_d.dds";
   diffuseColor[0] = "1 1 1 1";
   specularPower[0] = "16";
   specularPower[1] = "16";
   useAnisotropic[0] = "1";
   castShadows = "1";
   translucent = "0";
   translucentBlendOp = "None";
   alphaTest = "0";
   alphaRef = "0";
   cubemap = "global_cubemap_metalblurred";
   materialTag0 = "beamng"; materialTag1 = "vehicle";
};
