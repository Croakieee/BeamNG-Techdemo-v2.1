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

// Always declare audio Descriptions (the type of sound) before Profiles (the
// sound itself) when creating new ones.

// ----------------------------------------------------------------------------
// Now for the profiles - these are the usable sounds
// ----------------------------------------------------------------------------

datablock SFXProfile(MenuSound)
{
   filename = "art/sound/environment/amb";
   description = AudioLoop2d;
};

singleton SFXAmbience( AudioAmbienceMenu )
{
   environment = AudioEnvPlain;
   states[0] = AudioLocationOutside;
   soundTrack = "MenuSound";
};


singleton SFXProfile(EngineTestSound)
{
   fileName = "art/sound/cheetah_engine.ogg";
   description = "AudioDefaultLoop3D";
};

singleton SFXProfile(RollingTestSound)
{
   fileName = "art/sound/rolling_asphalt.ogg";
   description = "AudioDefaultLoop3D";
};

singleton SFXProfile(SkidTestSound)
{
   fileName = "art/sound/skid_asphalt.ogg";
   description = "AudioDefaultLoop3D";
};

singleton SFXProfile(WindTestSound)
{
   fileName = "art/sound/wind.ogg";
   description = "AudioDefaultLoop3D";
};

singleton SFXProfile(CrashTestSound)
{
   fileName = "art/sound/crash.ogg";
   description = "AudioDefault3D";
};

singleton SFXProfile(ShiftTestSound)
{
   fileName = "art/sound/shift.ogg";
   description = "AudioDefault3D";
};

