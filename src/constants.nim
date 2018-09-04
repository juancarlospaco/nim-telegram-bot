const
  about_texts = fmt"""*Nim Telegram Bot* 🤖
  ☑️ *Version:*     `0.3.0` 👾
  ☑️ *Licence:*     MIT 👽
  ☑️ *Author:*      _Juan Carlos_ @juancarlospaco 😼
  ☑️ *Compiled:*    `{CompileDate} {CompileTime}` ⏰
  ☑️ *Nim Version:* `{NimVersion}` 👑
  ☑️ *OS & CPU:*    `{hostOS.toUpperAscii} {hostCPU.toUpperAscii}` 💻
  ☑️ *Git Repo:*    `http://github.com/juancarlospaco/nim-telegram-bot`
  ☑️ *Bot uses:*    """  ## Info about the Bot itself, version, licence, git, OS, uses, etc.

  temp_folder* = getTempDir()  ## Temporary folder used for temporary files at runtime, etc.

  strip_cmd*  = "strip --strip-all"        ## Linux Bash command to strip the compiled binary executables.

  upx_cmd*    = "upx --best --ultra-brute" ## Linux Bash command to compress the compiled binary executables.

  sha_cmd*    = "sha1sum --tag"            ## Linux Bash command to checksum the compiled binary executables.

  pub_ip_api* = "https://api.ipify.org"    ## Public IP HTTPS URL API.

  kitten_pics* = "https://source.unsplash.com/collection/139386/99x99" ## Random Kittens Photos HTTPS URL.

  doge_pics*  = "https://source.unsplash.com/collection/1301659/99x99" ## Random Puppies Photos HTTPS URL.

  bigcat_pics* = "https://source.unsplash.com/collection/600741/99x99" ## Random Big Cat Photos HTTPS URL.

  sea_pics*   = "https://source.unsplash.com/collection/2160165/99x99" ## Random Sea Life Photos HTTPS URL.

  ffmpeg_base* = r"ffmpeg -loglevel warning -y -an -sn -f video4linux2 -s 640x480 -i /dev/video0 -ss 0:0:1 -frames 1 " ## Base incomplete FFMEPG Bash command to take 1 Photo from the Camera at ``/dev/video0``.

  ffmpeg_blur* = r"-vf 'boxblur=luma_radius=min(h\,w)/10:luma_power=1:chroma_radius=min(cw\,ch)/10:chroma_power=1' "   ## FFMEPG Blurr Filter to Blurr the Photos from the Camera at ``/dev/video0``.

  ffmpeg_outp* = temp_folder / "nim_telegram_bot_webcam.webp"  ## Temporary FFMEPG Photo path.

  cam_ffmepg_blur = ffmpeg_base & ffmpeg_blur & ffmpeg_outp   ## Full FFMEPG Bash command to take 1 Photo with Blurr Filter from the Camera at ``/dev/video0``.

  cam_ffmepg = ffmpeg_base & ffmpeg_outp   ## Full FFMEPG Bash command to take 1 Photo from the Camera at ``/dev/video0``.

  helps_texts = readFile("help_text.md")   ## External Mardown file with the message for Help command.

  coc_text    = readFile("coc_text.md")    ## External Mardown file with the message for Code Of Conduct command (AKA Rules).

  motd_text   = readFile("motd_text.md")   ## External Mardown file with the message for Message Of The Day command.

  donate_text = readFile("donate_text.md") ## External Mardown file with the message for Donations command.

  cutycapt_cmd* = "CutyCapt --insecure --smooth --private-browsing=on --plugins=on --header=DNT:1 --delay=9 --min-height=800 --min-width=1280 "  ## Linux Bash command to take full Screenshots of Web pages from a link, we use Cutycapt http://cutycapt.sourceforge.net
  # cutycapt_cmd* = "xvfb-run --server-args='-screen 0, 1280x1024x24' CutyCapt --insecure --smooth --private-browsing=on --plugins=on --header=DNT:1 --delay=9 --min-height=800 --min-width=1280 "  ## Linux Bash command to take full Screenshots of Web pages from a link, we use Cutycapt http://cutycapt.sourceforge.net and XVFB for HeadLess Servers without X.

  nuitka_cmd* = "nuitka3 --standalone --remove-output --output-dir="  ## Linux Bash command to Compile Python source code into Binary.

  # helps_texts = staticRead("help_text.md")  # Embed the *.md files.
  # coc_text =    staticRead("coc_text.md")
  # motd_text =   staticRead("motd_text.md")
  # donate_text = staticRead("donate_text.md")
