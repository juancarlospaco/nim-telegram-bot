import
  asyncdispatch, httpclient, logging, json, options, ospaths, osproc, parsecfg,
  strformat, strutils, terminal, times, random, posix, os
import telebot            # nimble install telebot            https://nimble.directory/pkg/telebot
import openexchangerates  # nimble install openexchangerates  https://github.com/juancarlospaco/nim-openexchangerates
import nimpy              # nimble install nimpy              https://github.com/yglukhov/nimpy
# import zip/zipfiles       # nimble install zip
# import nimprof

include ./constants  ## File with all compile time constants.
include ./variables  ## File with some of the initial variables.
var counter: int

proc handleUpdate(bot: TeleBot, update: Update) {.async.} =
  let
    url = api_url
    url_getfile = api_file
    linux_args = linux_args
    windows_args = windows_args
    strip_cmd = strip_cmd
    upx_cmd = upx_cmd
    sha_cmd = sha_cmd

  inc counter
  var response = update.message.get
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
                discard bot.send(binary_lin)
        # Windows Compilation.
        (output, exitCode) = execCmdEx(fmt"nim c --cpu:amd64 --os:windows -d:release --opt:size {windows_args} --out:{temp_file_exe} {temp_file_nim}")
        if exitCode == 0:
          (output, exitCode) = execCmdEx(fmt"{strip_cmd} {temp_file_exe}")
          if exitCode == 0:
            (output, exitCode) = execCmdEx(fmt"{sha_cmd} {temp_file_exe}")
            if exitCode == 0:
              var binary_win = newDocument(response.chat.id, "file://" & temp_file_exe)
              binary_win.caption = output.strip
              discard bot.send(binary_win)
      else:
        echo "TODO: Plugins should take it from here, WIP."
    else:
      var mssg = newMessage(response.chat.id, "💩 *File is too big for Plugins to Process!* 💩")
      mssg.disableNotification = true
      mssg.parseMode = "markdown"
      discard bot.send(mssg)


template handlerizer*(body: untyped): untyped =
  ## This Template sends a markdown text message from the ``message`` variable.
  inc counter
  body
  var msg = newMessage(update.message.chat.id, $message.strip())
  msg.disableNotification = true
  msg.parseMode = "markdown"
  discard bot.send(msg)

template handlerizerPhoto*(body: untyped): untyped =
  ## This Template sends a photo image message from the ``photo_path`` variable with the caption comment from ``photo_caption``.
  inc counter
  body
  var msg = newPhoto(update.message.chat.id, photo_path)
  msg.caption = photo_caption
  msg.disableNotification = true
  discard bot.send(msg)

template handlerizerLocation*(body: untyped): untyped =
  ## This Template sends a Geo Location message from the ``latitud`` and ``longitud`` variables.
  inc counter
  body
  let
    geo_uri = "*GEO URI:* geo:$1,$2    ".format(latitud, longitud)
    osm_url = "*OSM URL:* https://www.openstreetmap.org/?mlat=$1&mlon=$2".format(latitud, longitud)
  var
    msg = newMessage(update.message.chat.id,  geo_uri & osm_url)
    geo_msg = newLocation(update.message.chat.id, longitud, latitud)
  msg.disableNotification = true
  geo_msg.disableNotification = true
  msg.parseMode = "markdown"
  discard bot.send(geo_msg)
  discard bot.send(msg)

template handlerizerDocument*(body: untyped): untyped =
  ## This Template sends an attached File Document message from the ``document_file_path`` variable with the caption comment from ``document_caption``.
  inc counter
  body
  var document = newDocument(update.message.chat.id, "file://" & document_file_path)
  document.caption = document_caption.strip
  document.disableNotification = true
  discard bot.send(document)


proc catHandler(bot: Telebot, update: Command) {.async.} =
  handlerizer():
    let
      responz = await newAsyncHttpClient(maxRedirects=0).get(kitten_pics)
      message = responz.headers["location"].split("?")[0] & "?w=480&h=480&fit=crop"

proc dogHandler(bot: Telebot, update: Command) {.async.} =
  handlerizer():
    let
      responz = await newAsyncHttpClient(maxRedirects=0).get(doge_pics)
      message = responz.headers["location"].split("?")[0] & "?w=480&h=480&fit=crop"

proc bigcatHandler(bot: Telebot, update: Command) {.async.} =
  handlerizer():
    let
      responz = await newAsyncHttpClient(maxRedirects=0).get(bigcat_pics)
      message = responz.headers["location"].split("?")[0] & "?w=480&h=480&fit=crop"

proc seaHandler(bot: Telebot, update: Command) {.async.} =
  handlerizer():
    let
      responz = await newAsyncHttpClient(maxRedirects=0).get(sea_pics)
      message = responz.headers["location"].split("?")[0] & "?w=480&h=480&fit=crop"

proc public_ipHandler(bot: Telebot, update: Command) {.async.} =
  handlerizer():
    let
      responz = await newAsyncHttpClient().get(pub_ip_api)  # await response
      publ_ip = await responz.body                          # await body
      message = fmt"*Server Public IP Address:* `{publ_ip}`"

proc uptimeHandler(bot: Telebot, update: Command) {.async.} =
  handlerizer():
    let message = fmt"""⏰ *Uptime:* ⏰
    Ark Server:   `{execCmdEx("uptime --pretty")[0]}`
    Telegram Bot: `{cpuTime() - start_time}`"""

proc datetimeHandler(bot: Telebot, update: Command) {.async.} =
  handlerizer():
    let message = $now()

proc aboutHandler(bot: Telebot, update: Command) {.async.} =
  handlerizer():
    let message = about_texts & $counter

proc helpHandler(bot: Telebot, update: Command) {.async.} =
  handlerizer():
    let message = helps_texts

proc cocHandler(bot: Telebot, update: Command) {.async.} =
  handlerizer():
    let message = coc_text

proc donateHandler(bot: Telebot, update: Command) {.async.} =
  handlerizer():
    let message = donate_text

proc motdHandler(bot: Telebot, update: Command) {.async.} =
  handlerizer():
    let message = motd_text

proc dollarHandler(bot: Telebot, update: Command) {.async.} =
  let
    money_json = waitFor oer_client.latest()      # Updated Prices.
    names_json = waitFor oer_client.currencies()  # Friendly Names.
  var dineros = ""
  for crrncy in money_json.pairs:
    if crrncy[0] in oer_currenc:
      dineros.add fmt"*{crrncy[0]}* _{names_json[crrncy[0]]}_: `{crrncy[1]}`,  "
  handlerizer():
    let message = dineros

proc geoHandler(latitud, longitud: float,): CommandCallback =
  proc cb(bot: Telebot, update: Command) {.async.} =
    handlerizerLocation():
      let
        latitud = latitud
        longitud = longitud
  return cb

proc staticHandler(static_file: string): CommandCallback =
  proc cb(bot: Telebot, update: Command) {.async.} =
    handlerizerDocument():
      let
        document_file_path = static_file
        document_caption   = static_file
  return cb

proc pythonHandler(name: string): CommandCallback =
  proc cb(bot: Telebot, update: Command) {.async.} =
    let python_output = pyImport(name).main().to(string)
    handlerizer():
      let message = python_output
  return cb

# proc backupHandler(folders: JsonNode): CommandCallback =
#   proc cb(bot: Telebot, update: Command) {.async.} =
#     for folder in folders.pairs:
#       var z: ZipArchive
#       discard z.open(fmt"{folder.key}-{$now()}.zip", fmWrite)
#       for a_folder in folder.val:
#         echo "before FILE"
#         var foldr = $a_folder
#         for item in walkDirRec(foldr):
#           echo "IN FILE"
#           echo "FILE " & $item
#           #z.addFile($item)
#         echo "AFTER FILE"
#       z.close
# #       handlerizer:
# #         var message = fmt"*Backup:* from `{folder.val}` to `{folder.key}`."
#   return cb


when defined(linux):
  proc dfHandler(bot: Telebot, update: Command) {.async.} =
    handlerizer():
      let message = fmt"""`{execCmdEx("df --human-readable --local --total --print-type")[0]}`"""

  proc freeHandler(bot: Telebot, update: Command) {.async.} =
    handlerizer():
      let message = fmt"""`{execCmdEx("free --human --total --giga")[0]}`"""

  proc ipHandler(bot: Telebot, update: Command) {.async.} =
    handlerizer():
      let message = fmt"""`{execCmdEx("ip -brief address")[0]}`"""

  proc lshwHandler(bot: Telebot, update: Command) {.async.} =
    handlerizer():
      let message = fmt"""`{execCmdEx("lshw -short")[0]}`"""

  proc lsusbHandler(bot: Telebot, update: Command) {.async.} =
    handlerizer():
      let message = fmt"""`{execCmdEx("lsusb")[0]}`"""

  proc lspciHandler(bot: Telebot, update: Command) {.async.} =
    handlerizer():
      let message = fmt"""`{execCmdEx("lspci")[0]}`"""

  proc pingHandler(ips2ping: seq[string]): CommandCallback =
    proc cb(bot: Telebot, update: Command) {.async.} =
      var pings_msg = "📡 *Ping results:* 📡 \n"
      for an_ip in ips2ping:
        pings_msg &= fmt"""`{execCmdEx("ping -c 1 -t 1 -W 1 " & an_ip)[0]}`"""
      handlerizer():
        let message = pings_msg
    return cb

  proc camHandler(bot: Telebot, update: Command) {.async.} =
    discard execCmdEx(if cam_blur: cam_ffmepg_blur else: cam_ffmepg)
    let
      path = "file://" & ffmpeg_outp
      caption = if cam_caption != "": cam_caption.strip() else: $now()
    handlerizerPhoto():
      let
        photo_path = path
        photo_caption = caption

  proc cmd_bashHandler(command: string,): CommandCallback =
    proc cb(bot: Telebot, update: Command) {.async.} =
      handlerizer():
        let message = fmt"""`{execCmdEx(command)[0]}`"""
    return cb


proc main*() {.async.} =
  ## Main loop of the bot. It instances, init, config, run loop of the Bot.
  if cli_colors:
    randomize()
    setBackgroundColor(bgBlack)
    setForegroundColor([fgRed, fgGreen, fgYellow, fgBlue, fgMagenta, fgCyan, fgWhite].rand)

  addHandler(newConsoleLogger(fmtStr="$time $levelname "))

  createDir(bash_plugins_folder)
  createDir(python_plugins_folder)
  createDir(static_plugins_folder)
  createDir(geo_plugins_folder)

  let bot = newTeleBot(api_key)

  bot.onUpdate(handleUpdate)

  if cmd_cat:      bot.onCommand("cat", catHandler)
  if cmd_dog:      bot.onCommand("dog", dogHandler)
  if cmd_bigcat:   bot.onCommand("bigcat", bigcatHandler)
  if cmd_sea:      bot.onCommand("sea", seaHandler)
  if cmd_coc:      bot.onCommand("coc", cocHandler)
  if cmd_motd:     bot.onCommand("motd", motdHandler)
  if cmd_help:     bot.onCommand("help", helpHandler)
  if cmd_about:    bot.onCommand("about", aboutHandler)
  if cmd_uptime:   bot.onCommand("uptime", uptimeHandler)
  if cmd_donate:   bot.onCommand("donate", donateHandler)
  if cmd_datetime: bot.onCommand("datetime", datetimeHandler)
  if cmd_dollar:   bot.onCommand("dollar", dollarHandler)
  # if folders2backup.len != 0: bot.onCommand("backup", backupHandler(folders2backup))

  if ips2ping != @[""]: bot.onCommand("ping", pingHandler(ips2ping))

  for static_file in walkFiles(static_plugins_folder / "/*.*"):
    echo "Loading Static File as a Plugin: " & static_file
    let (dir, name, ext) = splitFile(static_file)
    bot.onCommand(name.toLowerAscii, staticHandler(static_file))

  for geo_file in walkFiles(geo_plugins_folder / "/*.ini"):
    echo "Loading INI File as a GeoLocation Plugin: " & geo_file
    let
      geo_ini = loadConfig(geo_file)
      latitud = parseFloat(geo_ini.getSectionValue("", "latitude"))
      longitu = parseFloat(geo_ini.getSectionValue("", "longitude"))
      (dir, name, ext) = splitFile(geo_file)
    bot.onCommand(name.toLowerAscii, geoHandler(latitud, longitu))

  when defined(linux):
    if server_cmd_ip:        bot.onCommand("ip", ipHandler)
    if server_cmd_df:        bot.onCommand("df", dfHandler)
    if server_cmd_free:      bot.onCommand("free", freeHandler)
    if server_cmd_lshw:      bot.onCommand("lshw", lshwHandler)
    if server_cmd_lsusb:     bot.onCommand("lsusb", lsusbHandler)
    if server_cmd_lspci:     bot.onCommand("lspci", lspciHandler)
    if server_cmd_public_ip: bot.onCommand("public_ip", public_ipHandler)

    if cam_enabled: bot.onCommand("cam", camHandler)

    for bash_file in walkFiles(bash_plugins_folder / "/*.sh"):
      echo "Loading Bash Plugin: " & bash_file
      let (dir, name, ext) = splitFile(bash_file)
      bot.onCommand(name.toLowerAscii, cmd_bashHandler(bash_file))

    if python_plugins:
      discard pyImport("sys").path.append(python_plugins_folder)
      for python_file in walkFiles(python_plugins_folder / "/*.py"):
        echo "Loading Python Plugin: " & python_file
        let (dir, name, ext) = splitFile(python_file)
        bot.onCommand(name.toLowerAscii, pythonHandler(name))

    discard nice(19.cint)  # smooth cpu priority

  bot.poll(polling_interval)


when isMainModule:
  wait_for main()
