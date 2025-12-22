#!/bin/bash

# Directory where this script is located
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Determine which app to use
if [ "$KMPARAM_Persistant" != "0" ]; then
    App="${DIR}/NotifiCLI.app/Contents/Apps/NotifiPersistent.app/Contents/MacOS/NotifiPersistent"
else
    App="${DIR}/NotifiCLI.app/Contents/MacOS/NotifiCLI"
fi

# Check for other parameters and construct flags
ActionsFlag=""
if [ -n "$KMPARAM_Actions" ]; then
    ActionsFlag="-actions"
fi

ReplyFlag=""
ReplyPlaceholder=""
if [ -n "$KMPARAM_Reply_Placeholder" ]; then
    ReplyFlag="-reply"
    ReplyPlaceholder="$KMPARAM_Reply_Placeholder"
fi

URLFlag=""
URLValue=""
if [ -n "$KMPARAM_URL" ]; then
    URLFlag="-url"
    URLValue="$KMPARAM_URL"
fi

SoundFlag=""
SoundName=""
if [ -n "$KMPARAM_Sound" ]; then
    SoundFlag="-sound"
    SoundName="$KMPARAM_Sound"
fi

IconFlag=""
IconPath=""
if [ -n "$KMPARAM_Icon_Path" ]; then
    IconFlag="-icon"
    IconPath="$KMPARAM_Icon_Path"
fi

ImageFlag=""
ImagePath=""
if [ -n "$KMPARAM_Image_Path" ]; then
    ImageFlag="-image"
    ImagePath="$KMPARAM_Image_Path"
fi

"$App" \
  -title "${KMPARAM_Title}" \
  -subtitle "${KMPARAM_Subtitle}" \
  -message "${KMPARAM_Message}" \
  $ActionsFlag "${KMPARAM_Actions}" \
  $ReplyFlag "$ReplyPlaceholder" \
  $URLFlag "$URLValue" \
  $SoundFlag "$SoundName" \
  $IconFlag "$IconPath" \
  $ImageFlag "$ImagePath"
