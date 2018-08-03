import
  asyncdispatch, httpclient, logging, json, options, ospaths, osproc, parsecfg,
  strformat, strutils, terminal, times, random, posix
import telebot            # nimble install telebot            https://nimble.directory/pkg/telebot
import openexchangerates  # nimble install openexchangerates  https://github.com/juancarlospaco/nim-openexchangerates
# import nimprof


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
  strip_cmd   = "strip --verbose --strip-all"
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

let
  start_time = cpuTime()
  config_ini = loadConfig("config.ini")
  api_key    = config_ini.getSectionValue("", "api_key")
  cli_colors = parseBool(config_ini.getSectionValue("", "terminal_colors"))

  file_size_limit = parseInt(config_ini.getSectionValue("nim_files_crosscompilation", "size_limit"))
  file_lineno_limit = parseInt(config_ini.getSectionValue("nim_files_crosscompilation", "lines_limit"))
  linux_args = config_ini.getSectionValue("nim_files_crosscompilation", "linux_args")
  windows_args = config_ini.getSectionValue("nim_files_crosscompilation", "windows_args")

  cmd_cat      = parseBool(config_ini.getSectionValue("commands", "cat"))
  cmd_dog      = parseBool(config_ini.getSectionValue("commands", "dog"))
  cmd_bigcat   = parseBool(config_ini.getSectionValue("commands", "bigcat"))
  cmd_sea      = parseBool(config_ini.getSectionValue("commands", "sea"))
  cmd_coc      = parseBool(config_ini.getSectionValue("commands", "coc"))
  cmd_motd     = parseBool(config_ini.getSectionValue("commands", "motd"))
  cmd_help     = parseBool(config_ini.getSectionValue("commands", "help"))
  cmd_ping     = parseBool(config_ini.getSectionValue("commands", "ping"))
  cmd_about    = parseBool(config_ini.getSectionValue("commands", "about"))
  cmd_uptime   = parseBool(config_ini.getSectionValue("commands", "uptime"))
  cmd_donate   = parseBool(config_ini.getSectionValue("commands", "donate"))
  cmd_datetime = parseBool(config_ini.getSectionValue("commands", "datetime"))
  cmd_dollar   = parseBool(config_ini.getSectionValue("commands", "dollar"))

  server_cmd_ip    = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "ip"))
  server_cmd_df    = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "df"))
  server_cmd_free  = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "free"))
  server_cmd_lshw  = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "lshw"))
  server_cmd_lsusb = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "lsusb"))
  server_cmd_lspci = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "lspci"))
  server_cmd_public_ip = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "public_ip"))

  cmd_bash0 = (name: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin0_name"), command: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin0_command"))
  cmd_bash1 = (name: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin1_name"), command: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin1_command"))
  cmd_bash2 = (name: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin2_name"), command: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin2_command"))
  cmd_bash3 = (name: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin3_name"), command: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin3_command"))
  cmd_bash4 = (name: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin4_name"), command: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin4_command"))
  cmd_bash5 = (name: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin5_name"), command: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin5_command"))
  cmd_bash6 = (name: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin6_name"), command: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin6_command"))
  cmd_bash7 = (name: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin7_name"), command: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin7_command"))
  cmd_bash8 = (name: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin8_name"), command: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin8_command"))
  cmd_bash9 = (name: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin9_name"), command: config_ini.getSectionValue("bash_plugin_commands", "bash_plugin9_command"))

  cmd_geo0 = (name: config_ini.getSectionValue("geo_location_sharing", "geo_plugin0_name"), lat: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin0_lat")), lon: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin0_lon")))
  cmd_geo1 = (name: config_ini.getSectionValue("geo_location_sharing", "geo_plugin1_name"), lat: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin1_lat")), lon: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin1_lon")))
  cmd_geo2 = (name: config_ini.getSectionValue("geo_location_sharing", "geo_plugin2_name"), lat: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin2_lat")), lon: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin2_lon")))
  cmd_geo3 = (name: config_ini.getSectionValue("geo_location_sharing", "geo_plugin3_name"), lat: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin3_lat")), lon: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin3_lon")))
  cmd_geo4 = (name: config_ini.getSectionValue("geo_location_sharing", "geo_plugin4_name"), lat: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin4_lat")), lon: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin4_lon")))
  cmd_geo5 = (name: config_ini.getSectionValue("geo_location_sharing", "geo_plugin5_name"), lat: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin5_lat")), lon: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin5_lon")))
  cmd_geo6 = (name: config_ini.getSectionValue("geo_location_sharing", "geo_plugin6_name"), lat: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin6_lat")), lon: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin6_lon")))
  cmd_geo7 = (name: config_ini.getSectionValue("geo_location_sharing", "geo_plugin7_name"), lat: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin7_lat")), lon: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin7_lon")))
  cmd_geo8 = (name: config_ini.getSectionValue("geo_location_sharing", "geo_plugin8_name"), lat: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin8_lat")), lon: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin8_lon")))
  cmd_geo9 = (name: config_ini.getSectionValue("geo_location_sharing", "geo_plugin9_name"), lat: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin9_lat")), lon: parseFloat(config_ini.getSectionValue("geo_location_sharing", "geo_plugin9_lon")))

  oer_api_key = config_ini.getSectionValue("openexchangerates", "api_key")
  oer_currenc = config_ini.getSectionValue("openexchangerates", "currencies").split(",")
  oer_round = parseBool(config_ini.getSectionValue("openexchangerates", "round_prices"))

  cam_enabled = parseBool(config_ini.getSectionValue("linux_server_camera", "cam"))
  cam_blur    = parseBool(config_ini.getSectionValue("linux_server_camera", "blur"))
  cam_caption = config_ini.getSectionValue("linux_server_camera", "photo_caption")
  api_url = fmt"https://api.telegram.org/file/bot{api_key}/"
  api_file = fmt"https://api.telegram.org/bot{api_key}/getFile?file_id="
  polling_interval = int32(parseInt(config_ini.getSectionValue("", "polling_interval")).int8 * 1000)
  oer_client = AsyncOER(timeout: 3, api_key: oer_api_key, base: "USD", local_base: "",  # "ARS",
                        round_float: oer_round, prettyprint: false, show_alternative: true)

var counter: int


proc handleUpdate(bot: TeleBot): UpdateCallback =
  let
    url = api_url
    url_getfile = api_file
    linux_args = linux_args
    windows_args = windows_args
    strip_cmd = strip_cmd
    upx_cmd = upx_cmd
    sha_cmd = sha_cmd

  proc cb(e: Update) {.async.} =
    var response = e.message.get
#     if response.text.isSome:  # Echo text message.
#       let
#         text = response.text.get
#       var message = newMessage(response.chat.id, text)
#       message.disableNotification = true
#       message.replyToMessageId = response.messageId
#       message.parseMode = "markdown"
#       discard bot.send(message)
    if response.document.isSome:   # files
      let
        document = response.document.get
        file_name = document.file_name.get
        mime_type = document.mime_type.get
        file_id = document.file_id
        file_size = document.file_size.get
        responz = await newAsyncHttpClient().get(url_getfile & file_id)
        responz_body = await responz.body
        file_path = parseJson(responz_body)["result"]["file_path"].getStr()
        responx = await newAsyncHttpClient().get(url & file_path)
        file_content = await responx.body
        file_linecount = file_content.splitLines.len
        size_remaining = file_size_limit - file_size
        lineno_remaining = file_lineno_limit - file_linecount
        file_tuple = (file_name: file_name, mime_type: mime_type, file_id: file_id,
        file_path: file_path, file_size: file_size, file_linecount: file_linecount,
        owner: fmt"{response.chat.first_name.get} {response.chat.last_name.get}",
        file_content: file_content)
        metadata_text = fmt"""⏳ *Processing file; Please wait!.* ⏳
        *file_name:* `{file_name}`
        *mime_type:* `{mime_type}`
        *file_id:*   `{file_id}`
        *file_path:* `{file_path}`
        *file_size:* `{file_size}` Bytes _({size_remaining} below limit)_
        *file_linecount:* `{file_linecount}` _({lineno_remaining} below limit)_
        *owner:* {response.chat.first_name.get} {response.chat.last_name.get}"""

      var message = newMessage(response.chat.id, metadata_text)
      message.disableNotification = true
      message.parseMode = "markdown"
      discard bot.send(message)

      if size_remaining > 1 and lineno_remaining > 1:
        if file_name.endsWith(".nim"):
          let
            temp_file_nim = temp_folder / file_tuple.file_name
            temp_file_bin = temp_file_nim.replace(".nim", "")
            temp_file_exe = temp_file_nim.replace(".nim", ".exe")
          writeFile(temp_file_nim,  file_tuple.file_content)
          var
            output: string
            exitCode: int
          # Linux Compilation.
          (output, exitCode) = execCmdEx(fmt"nim c -d:release --opt:size {linux_args} --out:{temp_file_bin} {temp_file_nim}")
          if exitCode == 0:
            (output, exitCode) = execCmdEx(fmt"{strip_cmd} {temp_file_bin}")
            if exitCode == 0:
              (output, exitCode) = execCmdEx(fmt"{upx_cmd} {temp_file_bin}")
              if exitCode == 0:
                (output, exitCode) = execCmdEx(fmt"{sha_cmd} {temp_file_bin}")
                if exitCode == 0:
                  var binary_lin = newDocument(response.chat.id, "file://" & temp_file_bin)
                  binary_lin.caption = output.strip
                  discard await bot.send(binary_lin)
          # Windows Compilation.
          (output, exitCode) = execCmdEx(fmt"nim c --cpu:amd64 --os:windows -d:release --opt:size {windows_args} --out:{temp_file_exe} {temp_file_nim}")
          if exitCode == 0:
            (output, exitCode) = execCmdEx(fmt"{strip_cmd} {temp_file_exe}")
            if exitCode == 0:
              (output, exitCode) = execCmdEx(fmt"{sha_cmd} {temp_file_exe}")
              if exitCode == 0:
                var binary_win = newDocument(response.chat.id, "file://" & temp_file_exe)
                binary_win.caption = output.strip
                discard await bot.send(binary_win)
        else:
          echo "TODO: Plugins should take it from here, WIP."
      else:
        var mssg = newMessage(response.chat.id, "💩 *File is too big for Plugins to Process!* 💩")
        mssg.disableNotification = true
        mssg.parseMode = "markdown"
        discard bot.send(mssg)

  result = cb


template handlerizer(body: untyped): untyped =
  proc cb(e: Command) {.async.} =
    inc counter
    body
    var msg = newMessage(e.message.chat.id, $message.strip())
    msg.disableNotification = true
    # message.replyToMessageId = e.message.messageId
    msg.parseMode = "markdown"
    discard bot.send(msg)
  result = cb

template handlerizerPhoto(body: untyped): untyped =
  proc cb(e: Command) {.async.} =
    inc counter
    body
    var msg = newPhoto(e.message.chat.id, photo_path)
    msg.caption = photo_caption
    msg.disableNotification = true
    # message.replyToMessageId = e.message.messageId
    discard await bot.send(msg)
  result = cb

template handlerizerLocation(body: untyped): untyped =
  proc cb(e: Command) {.async.} =
    inc counter
    body
    let
      geo_uri = "*GEO URI:* geo:$1,$2    ".format(latitud, longitud)
      osm_url = "*OSM URL:* https://www.openstreetmap.org/?mlat=$1&mlon=$2".format(latitud, longitud)
    var
      msg = newMessage(e.message.chat.id,  geo_uri & osm_url)
      geo_msg = newLocation(e.message.chat.id, longitud, latitud)
    msg.disableNotification = true
    geo_msg.disableNotification = true
    msg.parseMode = "markdown"
    discard bot.send(geo_msg)
    discard bot.send(msg)
  result = cb

proc catHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let
      responz = await newAsyncHttpClient(maxRedirects=0).get(kitten_pics)
      message = responz.headers["location"].split("?")[0] & "?w=480&h=480&fit=crop"

proc dogHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let
      responz = await newAsyncHttpClient(maxRedirects=0).get(doge_pics)
      message = responz.headers["location"].split("?")[0] & "?w=480&h=480&fit=crop"

proc bigcatHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let
      responz = await newAsyncHttpClient(maxRedirects=0).get(bigcat_pics)
      message = responz.headers["location"].split("?")[0] & "?w=480&h=480&fit=crop"

proc seaHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let
      responz = await newAsyncHttpClient(maxRedirects=0).get(sea_pics)
      message = responz.headers["location"].split("?")[0] & "?w=480&h=480&fit=crop"

proc public_ipHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let
      responz = await newAsyncHttpClient().get(pub_ip_api)  # await response
      publ_ip = await responz.body                          # await body
      message = fmt"*Server Public IP Address:* `{publ_ip}`"

proc uptimeHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let message = fmt"*Uptime:* `{cpuTime() - start_time}` ⏰"

proc pingHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let message = "*pong*"

proc datetimeHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let message = $now()

proc aboutHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let message = about_texts & $counter

proc helpHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let message = helps_texts

proc cocHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let message = coc_text

proc donateHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let message = donate_text

proc motdHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let message = motd_text

proc dollarHandler(bot: Telebot): CommandCallback =
  let
    money_json = waitFor oer_client.latest()      # Updated Prices.
    names_json = waitFor oer_client.currencies()  # Friendly Names.
  var dineros = ""
  for crrncy in money_json.pairs:
    if crrncy[0] in oer_currenc:
      dineros.add fmt"*{crrncy[0]}* _{names_json[crrncy[0]]}_: `{crrncy[1]}`,  "
  handlerizer():
    let message = dineros

proc geoHandler(bot: Telebot, latitud, longitud: float): CommandCallback =
  handlerizerLocation():
    let
      latitud = latitud
      longitud = longitud


when defined(linux):
  proc dfHandler(bot: Telebot): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx("df --human-readable --local --total --print-type")[0]}`"""

  proc freeHandler(bot: Telebot): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx("free --human --total --giga")[0]}`"""

  proc ipHandler(bot: Telebot): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx("ip -brief address")[0]}`"""

  proc lshwHandler(bot: Telebot): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx("lshw -short")[0]}`"""

  proc lsusbHandler(bot: Telebot): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx("lsusb")[0]}`"""

  proc lspciHandler(bot: Telebot): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx("lspci")[0]}`"""

  proc camHandler(bot: Telebot): CommandCallback =
    discard execCmdEx(if cam_blur: cam_ffmepg_blur else: cam_ffmepg)
    let
      path = "file://" & ffmpeg_outp
      caption = if cam_caption != "": cam_caption.strip() else: $now()
    handlerizerPhoto():
      let
        photo_path = path
        photo_caption = caption

  proc cmd_bashHandler(bot: Telebot, command: string): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx(command)[0]}`"""


proc main*() {.async.} =
  ## Main loop of the bot.
  if cli_colors:
    randomize()
    setBackgroundColor(bgBlack)
    setForegroundColor([fgRed, fgGreen, fgYellow, fgBlue, fgMagenta, fgCyan, fgWhite].rand)

  addHandler(newConsoleLogger(fmtStr="$time $levelname "))

  let bot = newTeleBot(api_key)

  bot.onUpdate(handleUpdate(bot))

  if cmd_cat:      bot.onCommand("cat", catHandler(bot))
  if cmd_dog:      bot.onCommand("dog", dogHandler(bot))
  if cmd_bigcat:   bot.onCommand("bigcat", bigcatHandler(bot))
  if cmd_sea:      bot.onCommand("sea", seaHandler(bot))
  if cmd_coc:      bot.onCommand("coc", cocHandler(bot))
  if cmd_motd:     bot.onCommand("motd", motdHandler(bot))
  if cmd_help:     bot.onCommand("help", helpHandler(bot))
  if cmd_ping:     bot.onCommand("ping", pingHandler(bot))
  if cmd_about:    bot.onCommand("about", aboutHandler(bot))
  if cmd_uptime:   bot.onCommand("uptime", uptimeHandler(bot))
  if cmd_donate:   bot.onCommand("donate", donateHandler(bot))
  if cmd_datetime: bot.onCommand("datetime", datetimeHandler(bot))
  if cmd_dollar:   bot.onCommand("dollar", dollarHandler(bot))

  if cmd_geo0.name != "": bot.onCommand(cmd_geo0.name, geoHandler(bot, cmd_geo0.lat, cmd_geo0.lon))
  if cmd_geo1.name != "": bot.onCommand(cmd_geo1.name, geoHandler(bot, cmd_geo1.lat, cmd_geo1.lon))
  if cmd_geo2.name != "": bot.onCommand(cmd_geo2.name, geoHandler(bot, cmd_geo2.lat, cmd_geo2.lon))
  if cmd_geo3.name != "": bot.onCommand(cmd_geo3.name, geoHandler(bot, cmd_geo3.lat, cmd_geo3.lon))
  if cmd_geo4.name != "": bot.onCommand(cmd_geo4.name, geoHandler(bot, cmd_geo4.lat, cmd_geo4.lon))
  if cmd_geo5.name != "": bot.onCommand(cmd_geo5.name, geoHandler(bot, cmd_geo5.lat, cmd_geo5.lon))
  if cmd_geo6.name != "": bot.onCommand(cmd_geo6.name, geoHandler(bot, cmd_geo6.lat, cmd_geo6.lon))
  if cmd_geo7.name != "": bot.onCommand(cmd_geo7.name, geoHandler(bot, cmd_geo7.lat, cmd_geo7.lon))
  if cmd_geo8.name != "": bot.onCommand(cmd_geo8.name, geoHandler(bot, cmd_geo8.lat, cmd_geo8.lon))
  if cmd_geo9.name != "": bot.onCommand(cmd_geo9.name, geoHandler(bot, cmd_geo9.lat, cmd_geo9.lon))

  when defined(linux):
    if server_cmd_ip:        bot.onCommand("ip", ipHandler(bot))
    if server_cmd_df:        bot.onCommand("df", dfHandler(bot))
    if server_cmd_free:      bot.onCommand("free", freeHandler(bot))
    if server_cmd_lshw:      bot.onCommand("lshw", lshwHandler(bot))
    if server_cmd_lsusb:     bot.onCommand("lsusb", lsusbHandler(bot))
    if server_cmd_lspci:     bot.onCommand("lspci", lspciHandler(bot))
    if server_cmd_public_ip: bot.onCommand("public_ip", public_ipHandler(bot))

    if cam_enabled: bot.onCommand("cam", camHandler(bot))

    if cmd_bash0.name != "" and cmd_bash0.command != "":
      bot.onCommand($cmd_bash0.name, cmd_bashHandler(bot, cmd_bash0.command))
    if cmd_bash1.name != "" and cmd_bash1.command != "":
      bot.onCommand($cmd_bash1.name, cmd_bashHandler(bot, cmd_bash1.command))
    if cmd_bash2.name != "" and cmd_bash2.command != "":
      bot.onCommand($cmd_bash2.name, cmd_bashHandler(bot, cmd_bash2.command))
    if cmd_bash3.name != "" and cmd_bash3.command != "":
      bot.onCommand($cmd_bash3.name, cmd_bashHandler(bot, cmd_bash3.command))
    if cmd_bash4.name != "" and cmd_bash4.command != "":
      bot.onCommand($cmd_bash4.name, cmd_bashHandler(bot, cmd_bash4.command))
    if cmd_bash5.name != "" and cmd_bash5.command != "":
      bot.onCommand($cmd_bash5.name, cmd_bashHandler(bot, cmd_bash5.command))
    if cmd_bash6.name != "" and cmd_bash6.command != "":
      bot.onCommand($cmd_bash6.name, cmd_bashHandler(bot, cmd_bash6.command))
    if cmd_bash7.name != "" and cmd_bash7.command != "":
      bot.onCommand($cmd_bash7.name, cmd_bashHandler(bot, cmd_bash7.command))
    if cmd_bash8.name != "" and cmd_bash8.command != "":
      bot.onCommand($cmd_bash8.name, cmd_bashHandler(bot, cmd_bash8.command))
    if cmd_bash9.name != "" and cmd_bash9.command != "":
      bot.onCommand($cmd_bash9.name, cmd_bashHandler(bot, cmd_bash9.command))

    discard nice(19.cint)  # smooth cpu priority

  bot.poll(polling_interval)


when isMainModule:
  waitFor(main())
