$camStartPos  = false;
$camTargetPos = false;
$moveRangeX   = 0.8;
$moveRangeZ   = 0.4;
$hitObject    = false;
$creditsActive = false;

function MainMenuGui::load3dBackground(%this)
{
   /*
   // 3d main menu disabled for now
   if($no3dGUI $= "" && isFile( "levels/menu/menu.mis" ))
   {
      if(isObject( ServerGroup ) && $missionRunning && $Server::MissionFile !$= "levels/menu/menu.mis")
      {
         // if we are connected, disconnect first
         disconnect();
      }

      if ( isObject( ServerGroup ) )
         return;

      // Main menu with mission in background
      loadLoadingGui();
      createAndConnectToLocalServer( "SinglePlayer", "levels/menu/menu.mis" );
      
      // start the menu sound
      //msound.play();
   }
   */
}

function MainMenuGui::onWake(%this)
{
}

function MainMenuGui::onSleep(%this)
{
    mainmenucef.hibernate();
}

function MainMenuGui::onRender(%this)
{   
   if(!isObject(LocalClientConnection))
   {
      %this.load3dBackground();
   } else if($camTargetPos != false)
   {
      %obj = LocalClientConnection.getControlObject();
      if (!isObject(%obj)) return;
      %p = %obj.getPosition();
      // slowly move towards it
      %d = VectorSub($camTargetPos, %p);
      %d = VectorScale(%d, 0.06);
      %d = VectorAdd(%p, %d);
      commandToServer('MoveMenuCam', %d);
   }
}

function MainMenuGui::onBtnPlay(%this)
{
   // actually save the settings now instead of doing so when exiting
   saveGlobalOptions();
   
   Canvas.pushDialog(ChooseLevelDlg);
}

function MainMenuGui::onMouseMoveSpecial(%this, %mousePosX, %mousePosY)
{
   if($creditsActive) return;
   if (!isObject(LocalClientConnection)) return;
   %obj = LocalClientConnection.getControlObject();
   if (!isObject(%obj)) return;

   if($camStartPos == false)
   {
      $camStartPos = %obj.getPosition();
      $camTargetPos = $camStartPos;
   } else
   {
      %camMoveX = %mousePosX * $moveRangeX - ($moveRangeX * 0.5);
      %camMoveZ = (1 - %mousePosY) * $moveRangeZ - ($moveRangeZ * 0.5);
      $camTargetPos = VectorAdd($camstartPos,(%camMoveX@" 0 "@%camMoveZ));
   }
}

function MainMenuGui::creditsToggle(%this)
{
   if($creditsActive)
   {
      MMExitButton.visible = true;
      MMOptionsButton.visible = true;
      MMPlayButton.visible = true;     
      MMCreditsButton.setText("The Team");
      $camTargetPos = $camstartPos;
      $creditsActive = false;
   } else {
      MMExitButton.visible = false;
      MMOptionsButton.visible = false;
      MMPlayButton.visible = false;     
      MMCreditsButton.setText("Back");
      $camTargetPos = "-330.167 104.035 59.1512";
      $creditsActive = true;
   }
}

/*
// this is the sign highlighting code which we do not need atm
function setObjectSelected(%obj, %val)
{
   for(%k = 0; %k < %obj.getTargetCount(); %k++)
   {
      %matName = %obj.getTargetName(%k);
      %mapped = getMaterialMapping( %matName );
      %mapped.emissive[0] = %val;
      %mapped.flush();
      //echo(%mapped@" = "@%val);
   }
}

function selectObject(%newObj)
{
   if($hitObject == %newObj)
   {
      // no change
      return;
   }
   
   // deselect all
   if($hitObject != false)
   {
      setObjectSelected($hitObject, 0);
      $hitObject = false;
   }
   // select new
   if(%newObj != false)
   {
      setObjectSelected(%newObj, 1);
      $hitObject = %newObj;
   }
}

function mouseRayTest(%this, %pos, %start, %ray)
{
   %ray = VectorScale(%ray, 2000);
   %end = VectorAdd(%start, %ray);
   %result = ContainerRayCast( %start, %end, $TypeMasks::StaticObjectType);
   
   // If the terrain object was found in the scan
   if( %result )
   {
      %obj = firstWord(%result);  
      %hitPos = getWords(%result, 1, 3);
      
      //echo(" hit object " @ %obj.getId() @ " / " @ %obj.getName() @ " at " @ %pos);
      if( %obj.isMethod( "getTargetName" ) )
      {
         selectObject(%obj);
         return;
      }
   }
   selectObject(false);
}

function MainMenuGui::onMouseMove(%this, %pos, %start, %ray)
{
   mouseRayTest(%this, %pos, %start, %ray);
}

      
function MainMenuGui::onMouseDown(%this, %pos, %start, %ray)
{
   mouseRayTest(%this, %pos, %start, %ray);
   if($hitObject == false) return;   
   %n = $hitObject.getName();
   
   // TODO: fix crash when you reenter the window
   //if(%n $= "betaSign")
   //{
      //gotoWebPage("http://www.beamng.com/alpha");
      // deselect sign
      //setObjectSelected(betaSign, 0);
      //$hitObject = false;
      //schedule(200, 0, selectObject, false);
   //}
}
*/