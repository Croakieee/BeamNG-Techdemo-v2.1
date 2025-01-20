//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Audio provider
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_Audio_provider_getValue()
{
    return $pref::SFX::provider;
}
function Settings_Audio_provider_setValue( %value )
{    
    $pref::SFX::provider = %value;
    applyAudioOptions();
}
function Settings_Audio_provider_getOptions()
{
   %out = "";
   %buffer = sfxGetAvailableDevices();
   %count = getRecordCount( %buffer );   
   for(%i = 0; %i < %count; %i++)
   {
      %record = getRecord(%buffer, %i);
      %provider = getField(%record, 0);
      
      if( strpos(%out, %provider) != -1 )
            continue;
      
      if( %out !$= "" )
            %out = %out @ ",";
       %out = %out @ "'" @ %provider @ "'";
   }
   
   //echo( "Settings_Audio_provider_getOptions " @ %out );
   return "[ " @ %out @ " ]"; 
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Audio device
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_Audio_device_getValue()
{
    return $pref::SFX::device;
}
function Settings_Audio_device_setValue( %value )
{    
    $pref::SFX::device = %value;
    applyAudioOptions();
}
function Settings_Audio_device_getOptions()
{
   %out = "";
   %buffer = sfxGetAvailableDevices();
   %count = getRecordCount( %buffer );   
   for(%i = 0; %i < %count; %i++)
   {
      %record = getRecord(%buffer, %i);
      %device = getField(%record, 1);
      
      if( strpos(%out, %device) != -1 )
            continue;
      
      if( %out !$= "" )
            %out = %out @ ",";
       %out = %out @ "'" @ %device @ "'";
   }
   
   //echo( "Settings_Audio_device_getOptions " @ %out );
   return "[ " @ %out @ " ]"; 
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Audio master_vol
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_Audio_master_vol_getValue()
{
    return $pref::SFX::masterVolume;
}
function Settings_Audio_master_vol_setValue( %value )
{    
    OptAudioUpdateMasterVolume( %value );
    beamNGExecuteJS( "updateOptionsData()" , 0);
    beamNGExecuteJS( "updateOptionsData()" , 1);
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Audio interface_vol
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_Audio_interface_vol_getValue()
{
    %channel = sfxGroupToOldChannel( AudioGui.sourceGroup );
   
    return $pref::SFX::channelVolume[ %channel ];
}
function Settings_Audio_interface_vol_setValue( %value )
{    
    OptAudioUpdateChannelVolume(AudioGui, $value);
    beamNGExecuteJS( "updateOptionsData()" , 0);
    beamNGExecuteJS( "updateOptionsData()" , 1);
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Audio effects_vol
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_Audio_effects_vol_getValue()
{
    %channel = sfxGroupToOldChannel( AudioEffect.sourceGroup );
   
    return $pref::SFX::channelVolume[ %channel ];
}
function Settings_Audio_effects_vol_setValue( %value )
{    
    OptAudioUpdateChannelVolume(AudioEffect, $value);
    beamNGExecuteJS( "updateOptionsData()" , 0);
    beamNGExecuteJS( "updateOptionsData()" , 1);
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Audio music_vol
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Settings_Audio_music_vol_getValue()
{
    %channel = sfxGroupToOldChannel( AudioMusic.sourceGroup );
   
    return $pref::SFX::channelVolume[ %channel ];
}
function Settings_Audio_music_vol_setValue( %value )
{    
    OptAudioUpdateChannelVolume(AudioMusic, $value);
    beamNGExecuteJS( "updateOptionsData()" , 0);
    beamNGExecuteJS( "updateOptionsData()" , 1);
}

function OptAudioUpdateMasterVolume( %volume )
{
    echo("OptAudioUpdateMasterVolume " @ %volume);
   if( %volume == $pref::SFX::masterVolume )
      return;
      echo("    changed");
      
   sfxSetMasterVolume( %volume );
   $pref::SFX::masterVolume = %volume;
   
   if( !isObject( $AudioTestHandle ) )
      $AudioTestHandle = sfxPlayOnce( AudioChannel, "core/art/sound/volumeTest.wav" );
}

function OptAudioUpdateChannelVolume( %description, %volume )
{
   %channel = sfxGroupToOldChannel( %description.sourceGroup );
   
   if( %volume == $pref::SFX::channelVolume[ %channel ] )
      return;

   sfxSetChannelVolume( %channel, %volume );
   $pref::SFX::channelVolume[ %channel ] = %volume;
   
   if( !isObject( $AudioTestHandle ) )
   {
      $AudioTestDescription.volume = %volume;
      $AudioTestHandle = sfxPlayOnce( $AudioTestDescription, "core/art/sound/volumeTest.wav" );
   }
}

function applyAudioOptions()
{
    if ( !sfxCreateDevice(  $pref::SFX::provider, $pref::SFX::device, $pref::SFX::useHardware, -1 ) )                              
      error( "Unable to create SFX device: " @ $pref::SFX::provider SPC $pref::SFX::device SPC $pref::SFX::useHardware );
    
    beamNGExecuteJS( "updateOptionsData()" , 0);
    beamNGExecuteJS( "updateOptionsData()" , 1);
}