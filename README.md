# airports-radio

An endless internet radio station built from Brian Eno's *Ambient 1: Music for Airports*.

The container loops each of the album's four tracks on its own and mixes them live into one
Icecast stream. The tracks have different lengths, so they drift against each other and the
combined sound does not repeat for a very long time. Reverb Machine's
[breakdown of the album](https://reverbmachine.com/blog/deconstructing-brian-eno-music-for-airports/)
explains the tape-loop idea it borrows from.

It works with any set of tracks. Every audio file in `/music` joins the mix.

## Run it

No audio ships in the image. Bring your own copy of the album.

```yaml
services:
  airports-radio:
    image: ghcr.io/daredoes/airports-radio:latest
    restart: unless-stopped
    ports:
      - "8000:8000"
    volumes:
      - ./music:/music:ro
```

Then listen at `http://<host>:8000/airports` in any player that takes a stream URL. In
[Music Assistant](https://music-assistant.io), go to Radio, add an item from URL, and paste
that address.

Use FLAC or WAV if you can. MP3 and AAC files carry a little padding, so you hear a click
each time a track loops.

## Settings

| Variable | Default | What it does |
|---|---|---|
| `MOUNT` | `/airports` | Stream path |
| `STREAM_NAME` | `Music for Airports (endless)` | Station name shown by players |
| `VOLUME` | `0.5` | Gain applied to the mix before the limiter |
| `BITRATE` | `256k` | MP3 bitrate |

The Icecast password is random on every start. Only the mixer inside the container uses it.

Images are built for `linux/amd64` and `linux/arm64`.
