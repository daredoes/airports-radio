#!/bin/sh
# Loops every audio file in /music independently, mixes them live, and serves
# the mix as an Icecast stream on port 8000.
set -eu

MOUNT="${MOUNT:-/airports}"
STREAM_NAME="${STREAM_NAME:-Music for Airports (endless)}"
VOLUME="${VOLUME:-0.5}"
BITRATE="${BITRATE:-256k}"
PASS="$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n')"

set --
for f in /music/*; do
  case "$(echo "$f" | tr 'A-Z' 'a-z')" in
    *.flac|*.wav|*.aiff|*.mp3|*.m4a|*.aac|*.ogg|*.opus) set -- "$@" -re -stream_loop -1 -i "$f" ;;
  esac
done
n=$(($# / 5))
if [ "$n" -eq 0 ]; then
  echo "No audio files found in /music" >&2
  exit 1
fi
echo "Mixing $n tracks into http://<host>:8000$MOUNT"

sed "s/@PASS@/$PASS/g" /etc/airports-radio/icecast.xml > /tmp/icecast.xml
icecast -b -c /tmp/icecast.xml
# ponytail: fixed wait for icecast to bind; the container restarts if ffmpeg loses the race
sleep 2

exec ffmpeg -hide_banner -loglevel warning "$@" \
  -filter_complex "amix=inputs=$n:normalize=0,volume=$VOLUME,alimiter=limit=0.9" \
  -c:a libmp3lame -b:a "$BITRATE" -content_type audio/mpeg -f mp3 \
  -ice_name "$STREAM_NAME" \
  "icecast://source:$PASS@127.0.0.1:8000$MOUNT"
