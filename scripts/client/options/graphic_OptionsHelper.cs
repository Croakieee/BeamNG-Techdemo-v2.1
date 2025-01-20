//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// display_driver
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_Graphic_display_driver_getValue()
{
    return $pref::Video::displayOutputDevice;
}
function Settings_Graphic_display_driver_setValue( %value )
{
    $pref::Video::displayOutputDevice = %value;
    applyOptions_Graphic();
}
function Settings_Graphic_display_driver_getOptions()
{
    %out = "";
    for( %itr = 0; %itr < GFXInit::getAdapterCount(); %itr++ )
    {
        if( %out !$= "" )
            %out = %out @ ",";
            
        %out = %out @ "'" @ GFXInit::getAdapterName( %itr ) @ "'";
    }
    %out = "[" @ %out @ "]";
    return %out;
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// resolutions
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_Graphic_resolutions_getValue()
{
    return getWord($pref::Video::mode,  $WORD::RES_X) @ " " @ getWord($pref::Video::mode,  $WORD::RES_Y);
}
function Settings_Graphic_resolutions_setValue( %value )
{
    $pref::Video::mode = setWord($pref::Video::mode,  $WORD::RES_Y, "");
    $pref::Video::mode = setWord($pref::Video::mode,  $WORD::RES_X, %value);

    applyOptions_Graphic();
}
function Settings_Graphic_resolutions_getOptions()
{
    %out = "";
    for( %itr = 0; %itr < Canvas.getModeCount(); %itr++ )
    {
        if( %out !$= "" )
            %out = %out @ ",";
            
        %mode = Canvas.getMode( %itr );
        
        %res = getWord( %mode,  $WORD::RES_X) @ " " @ getWord( %mode,  $WORD::RES_Y);
        if( strpos(%out, %res) != -1 )
            continue;
            
        %out = %out @ "'" @ %res @ "'" ;
    }
    %out = "[" @ %out @ "]";
    return %out;
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// fullscreen
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_Graphic_fullscreen_getValue()
{
    return getWord($pref::Video::mode,   $WORD::FULLSCREEN);
}
function Settings_Graphic_fullscreen_setValue( %value )
{
    $pref::Video::mode = setWord($pref::Video::mode,   $WORD::FULLSCREEN, %value);
    applyOptions_Graphic();
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// borderless
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_Graphic_borderless_getValue()
{
    return $pref::Video::borderless;
}
function Settings_Graphic_borderless_setValue( %value )
{
    $pref::Video::borderless = %value;
    applyOptions_Graphic();
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// sync
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_Graphic_Sync_getValue()
{
    return !$pref::Video::disableVerticalSync;
}
function Settings_Graphic_Sync_setValue( %val )
{
    $pref::Video::disableVerticalSync = !%val;
    applyOptions_Graphic();
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// refresh_rate
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_refresh_rate_getValue()
{
    return getWord($pref::Video::mode, $WORD::REFRESH);
}
function Settings_refresh_rate_setValue( %value )
{
    $pref::Video::mode = setWord($pref::Video::mode, $WORD::REFRESH, %value);
    applyOptions_Graphic();
}
function Settings_refresh_rate_getOptions()
{
    %out = "";
    %res = getWord($pref::Video::mode,  $WORD::RES_X) @ " " @ getWord($pref::Video::mode,  $WORD::RES_Y);
    for( %itr = 0; %itr < Canvas.getModeCount(); %itr++ )
    {
        %mode = Canvas.getMode( %itr );
        %rf = getWord( %mode,  $WORD::REFRESH);
        
        if( strpos(%mode, %res) == -1 )
            continue;
        
        if( strpos(%out, %rf) != -1 )
            continue;
            
        if( %out !$= "" )
            %out = %out @ ",";
            
        %out = %out @ "'" @ %rf @ "'" ;
    }
    
    %out = "[" @ %out @ "]";
    return %out;
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// antialias
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_Graphic_antialias_getValue()
{
    %AA = getWord($pref::Video::mode, $WORD::AA);
    if( %AA == 0)
        return "Off";
        
    return %AA @ "x";
}
function Settings_Graphic_antialias_setValue( %value )
{
    if( %value $= "Off")
        %value = 0;
    else
        %value = getSubStr( %value, 0, 1);
    
    if( %value < 0 || %value > 4 )
        return;
    
    echo( %value );
    $pref::Video::mode = setWord($pref::Video::mode, $WORD::AA, %value );
    applyOptions_Graphic();
}
function Settings_Graphic_antialias_getOptions()
{
    return "[ 'Off', '1x', '2x', '4x' ]";
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// gamma
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_Graphic_gamma_getValue()
{
    return $pref::Video::Gamma;
}
function Settings_Graphic_gamma_setValue( %value )
{
    $pref::Video::Gamma = %value;
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// mesh_quality
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$Settings_Graphic_mesh_quality = MeshQualityGroup.getCurrentLevel();
function Settings_Graphic_mesh_quality_getValue()
{
    return $Settings_Graphic_mesh_quality;
}
function Settings_Graphic_mesh_quality_setValue( %value )
{
    $Settings_Graphic_mesh_quality = %value;
    
    MeshQualityGroup.applyLevel( $Settings_Graphic_mesh_quality );
}
function Settings_Graphic_mesh_quality_getOptions()
{
    return "['Lowest','Low','Normal','High']";
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// texture_quality
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$Settings_Graphic_texture_quality = TextureQualityGroup.getCurrentLevel();
function Settings_Graphic_texture_quality_getValue()
{
    return $Settings_Graphic_texture_quality;
}
function Settings_Graphic_texture_quality_setValue( %value )
{
    $Settings_Graphic_texture_quality = %value;
    
    TextureQualityGroup.applyLevel( $Settings_Graphic_texture_quality );
}
function Settings_Graphic_texture_quality_getOptions()
{
    return "['Lowest','Low','Normal','High']";
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// lighting_quality
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$Settings_Graphic_lighting_quality = LightingQualityGroup.getCurrentLevel();
function Settings_Graphic_lighting_quality_getValue()
{
    return $Settings_Graphic_lighting_quality;
}
function Settings_Graphic_lighting_quality_setValue( %value )
{
    $Settings_Graphic_lighting_quality = %value;
    
    LightingQualityGroup.applyLevel( $Settings_Graphic_lighting_quality );
}
function Settings_Graphic_lighting_quality_getOptions()
{
    return "['Lowest','Low','Normal','High']";
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// shader_quality
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$Settings_Graphic_shader_quality = ShaderQualityGroup.getCurrentLevel();
function Settings_Graphic_shader_quality_getValue()
{
    return $Settings_Graphic_shader_quality;
}
function Settings_Graphic_shader_quality_setValue( %value )
{
    $Settings_Graphic_shader_quality = %value;
    
    ShaderQualityGroup.applyLevel( $Settings_Graphic_shader_quality );
}
function Settings_Graphic_shader_quality_getOptions()
{
    return "['Lowest','Low','Normal','High']";
}

function applyOptions_Graphic()
{
    echo("    >>>> applyOptions_Graphic <<<<<");
    %resX = getWord($pref::Video::mode, $WORD::RES_X);
    %resY = getWord($pref::Video::mode, $WORD::RES_Y);
    %fs = getWord($pref::Video::mode,   $WORD::FULLSCREEN);
    %bpp = getWord($pref::Video::mode,  $WORD::BITDEPTH);
    %rate = getWord($pref::Video::mode, $WORD::REFRESH);
    %fsaa = getWord($pref::Video::mode, $WORD::AA);   
    Canvas.setVideoMode(%resX, %resY, %fs, %bpp, %rate, %fsaa);    
    
    beamNGExecuteJS( "updateOptionsData()" , 0);
    beamNGExecuteJS( "updateOptionsData()" , 1);
}