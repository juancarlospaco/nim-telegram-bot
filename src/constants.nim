const
  about_texts = fmt"""*Nim Telegram Bot* 🤖
  ☑️ *Version:*     `0.0.1` 👾
  ☑️ *Licence:*     MIT 👽
  ☑️ *Author:*      _Juan Carlos_ @juancarlospaco 😼
  ☑️ *Compiled:*    `{CompileDate} {CompileTime}` ⏰
  ☑️ *Nim Version:* `{NimVersion}` 👑
  ☑️ *OS & CPU:*    `{hostOS.toUpperAscii} {hostCPU.toUpperAscii}` 💻
  ☑️ *Git Repo:*    `http://github.com/juancarlospaco/nim-telegram-bot`
  ☑️ *Bot uses:*    """
  temp_folder = getTempDir()
  strip_cmd   = "strip --strip-all"
  upx_cmd     = "upx --best --ultra-brute"
  sha_cmd     = "sha1sum --tag"
  pub_ip_api  = "https://api.ipify.org"
  kitten_pics = "https://source.unsplash.com/collection/139386/99x99"  # 480x480
  doge_pics   = "https://source.unsplash.com/collection/1301659/99x99" # 480x480
  bigcat_pics = "https://source.unsplash.com/collection/600741/99x99"  # 480x480
  sea_pics    = "https://source.unsplash.com/collection/2160165/99x99" # 480x480
  ffmpeg_base = r"ffmpeg -loglevel warning -y -an -sn -f video4linux2 -s 640x480 -i /dev/video0 -ss 0:0:1 -frames 1 "
  ffmpeg_blur = r"-vf 'boxblur=luma_radius=min(h\,w)/10:luma_power=1:chroma_radius=min(cw\,ch)/10:chroma_power=1' "
  ffmpeg_outp = temp_folder / "nim_telegram_bot_webcam.webp"
  cam_ffmepg_blur = ffmpeg_base & ffmpeg_blur & ffmpeg_outp
  cam_ffmepg = ffmpeg_base & ffmpeg_outp
  helps_texts = readFile("help_text.md")      # External *.md files.
  coc_text =    readFile("coc_text.md")
  motd_text =   readFile("motd_text.md")
  donate_text = readFile("donate_text.md")
  # helps_texts = staticRead("help_text.md")  # Embed the *.md files.
  # coc_text =    staticRead("coc_text.md")
  # motd_text =   staticRead("motd_text.md")
  # donate_text = staticRead("donate_text.md")
