#!/bin/bash

layout=$(hyprctl devices | grep "active keymap" | tail -n1 | awk -F': ' '{print $2}')

if [[ "$layout" == *"Russian"* ]]; then
  echo "🇷🇺"
elif [[ "$layout" == *"English (US)"* ]]; then
  echo "🇺🇸"
else
  echo "$layout"
fi
