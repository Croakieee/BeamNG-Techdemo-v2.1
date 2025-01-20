
singleton Material(tireTrack)
{
   mapTo = "unmapped_mat";
   diffuseMap[0] = "art/decals/tiremark.png";
   vertColor[ 0 ] = true;
   materialTag2 = "beamng";
   materialTag0 = "decal";
   diffuseColor[0] = "1 1 1 0.199";
   emissive[0] = "1";
   translucent = "1";
   alphaRef = "1";
   castShadows = "0";
   translucentZWrite = "1";
   showFootprints = "0";
   specularPower[0] = "1";
};

singleton Material(eca_bld_woodcladding_01_bare_mat)
{
   mapTo = "eca_bld_woodcladding_01_bare";
   diffuseMap[0] = "levels/east_coast_usa/art/shapes/buildings/eca/eca_bld_woodcladding_01_bare_d.dds";
   materialTag0 = "beamng";
   materialTag1 = "building";
   materialTag2 = "east_coast_usa";
   normalMap[0] = "levels/east_coast_usa/art/shapes/buildings/eca/eca_bld_woodcladding_01_n.dds";
   specularMap[0] = "levels/east_coast_usa/art/shapes/buildings/eca/eca_bld_woodcladding_01_s.dds";
   detailMap[0] = "levels/east_coast_usa/art/shapes/buildings/eca/eca_grungewood_b.dds";
   detailScale[0] = "0.1 0.1";
};

singleton Material(eca_bld_brick_brown_mat)
{
   mapTo = "eca_bld_brick_brown";
   diffuseMap[0] = "levels/east_coast_usa/art/shapes/buildings/eca/eca_bld_brick_01_brown_d.dds";
   detailMap[0] = "levels/east_coast_usa/art/shapes/buildings/eca/eca_grungewood_b.dds";
   detailScale[0] = "0.1 0.1";
   normalMap[0] = "levels/east_coast_usa/art/shapes/buildings/eca/eca_bld_brick_01_n.dds";
   specularMap[0] = "levels/east_coast_usa/art/shapes/buildings/eca/eca_bld_brick_01_s.dds";
   materialTag0 = "beamng";
   materialTag1 = "building";
   materialTag2 = "east_coast_usa";
};
