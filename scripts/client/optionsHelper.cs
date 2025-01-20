exec( "./options/graphic_OptionsHelper.cs");
exec( "./options/audio_OptionsHelper.cs");
exec( "./options/postFX_SSAO_OptionsHelper.cs");
exec( "./options/postFX_HDR_OptionsHelper.cs");
exec( "./options/postFX_LightRays_OptionsHelper.cs");
exec( "./options/postFX_DOF_OptionsHelper.cs");

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

function getSettingsValue( %obj, %setting )
{
    %value = eval( %setting @ "_getValue();" );
    %options = "";
    if( isFunction( %setting @ "_getOptions" ) )
        %options = eval( %setting @ "_getOptions();" );

    %cmd = "onUpdateOptionValue( \"" @ %obj @ "\",\"" @ %value  @ "\", \"" @ %options @ "\" );" ;
    // just send it to both context types, for the options page and the ingame options
    beamNGExecuteJS( %cmd , 0);
    beamNGExecuteJS( %cmd , 1);
}

function setSettingsValue( %obj, %setting, %value )
{
    if( %value $= "false" )
        %value = false;
    else if( %value $= "true")
        %value = true;

    %cmd = %setting @ "_setValue( \"" @ %value @ "\");";
    //echo( ">>>>" @ %cmd);
    eval( %cmd );
}

function applyOptions()
{
    applyOptions_Graphic();
    applyAudioOptions();
}

function cleanRGB( %rgb )
{
    if( stricmp( %rgb , "rgb(" ) > 0 )
    {
        //clean value string
        %rgb = strreplace( %rgb , "rgb(", "" );
        %rgb = strreplace( %rgb , ",", "" );
        %rgb = strreplace( %rgb , ")", "" );
    }
    
    return %rgb;
}