@echo off
setlocal

set "text=Spongebob is watching you"
set "wavfile=spongebob.wav"
set "mp3file=spongebob.mp3"
set "ffmpeg_url=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
set "ffmpeg_dir=%~dp0ffmpeg"
set "ffmpeg_exe=%ffmpeg_dir%\bin\ffmpeg.exe"

rem Check if ffmpeg is installed
if not exist "%ffmpeg_exe%" (
    echo ffmpeg not found. Downloading and installing ffmpeg...
    mkdir "%ffmpeg_dir%"
    powershell -Command "Invoke-WebRequest -Uri %ffmpeg_url% -OutFile %~dp0ffmpeg.zip"
    powershell -Command "Expand-Archive -Path %~dp0ffmpeg.zip -DestinationPath %ffmpeg_dir% -Force"
    del "%~dp0ffmpeg.zip"
    move "%ffmpeg_dir%\ffmpeg-*-essentials_build\*" "%ffmpeg_dir%"
    rmdir /s /q "%ffmpeg_dir%\ffmpeg-*-essentials_build"
) else (
    echo ffmpeg is already installed.
)

rem Generate a WAV file using PowerShell's text-to-speech
powershell -Command "Add-Type –TypeDefinition @'
using System.Speech.Synthesis;
public class TTS {
    public static void Speak(string text, string file) {
        SpeechSynthesizer synth = new SpeechSynthesizer();
        synth.SetOutputToWaveFile(file);
        synth.Speak(text);
        synth.Dispose();
    }
}
'@;
[TTS]::Speak('%text%', '%wavfile%')"

rem Convert the WAV file to MP3 using ffmpeg
"%ffmpeg_exe%" -i %wavfile% -codec:a libmp3lame -qscale:a 2 %mp3file%

rem Play the MP3 file using PowerShell
powershell -c (New-Object Media.SoundPlayer '%mp3file%').PlaySync()

rem Clean up the WAV file
del %wavfile%

rem Spam message boxes indefinitely
:loop
powershell -Command "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('Spongebob is watching you', 'Spongebob is watching you')"
goto loop

endlocal
