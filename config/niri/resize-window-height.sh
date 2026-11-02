#!/bin/bash
# Mod+Shift+K/J: move the window's edge in the pressed direction.
# The bottom window of a stack moves its top edge, any other window its bottom edge.

is_bottom=$(niri msg -j windows | jq -r '
  (.[] | select(.is_focused)) as $f
  | $f.layout.pos_in_scrolling_layout as $p
  | if $p == null then false else
      ([.[] | select(.workspace_id == $f.workspace_id and .layout.pos_in_scrolling_layout[0] == $p[0])] | length) as $n
      | ($n > 1 and $p[1] == $n)
    end')

case "$1:$is_bottom" in
  up:true | down:false) change="+5%" ;;
  up:false | down:true) change="-5%" ;;
  *) exit 1 ;;
esac

niri msg action set-window-height -- "$change"
