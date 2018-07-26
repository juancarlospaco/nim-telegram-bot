import
  asyncdispatch, httpclient, logging, json, options, ospaths, osproc, parsecfg,
  strformat, strutils, terminal, times, random
import telebot  # nimble install telebot https://nimble.directory/pkg/telebot
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
  pub_ip_api  = "https://api.ipify.org"
  kitten_pics = "https://source.unsplash.com/collection/139386/99x99"  # 480x480
  doge_pics   = "https://source.unsplash.com/collection/1301659/99x99" # 480x480
  bigcat_pics = "https://source.unsplash.com/collection/600741/99x99"  # 480x480
  sea_pics    = "https://source.unsplash.com/collection/2160165/99x99" # 480x480
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
  # api_url = fmt"https://api.telegram.org/file/bot{api_key}/"
  polling_interval: int8 = parseInt(config_ini.getSectionValue("", "polling_interval")).int8

var counter: int


proc handleUpdate(bot: TeleBot): UpdateCallback =
  proc cb(e: Update) {.async.} =
    var response = e.message.get

    if response.text.isSome:  # Echo text message.
      let
        text = response.text.get
      var message = newMessage(response.chat.id, text)
      message.disableNotification = true
      message.replyToMessageId = response.messageId
      message.parseMode = "markdown"
      discard bot.send(message)

#     if response.document.isSome:   # files
#       let
#         code = response.document.get
#
#       echo code.file_name
#       echo code.mime_type
#       echo code.file_id
#       echo code.file_size
#
#       var message = newMessage(response.chat.id, $code)
#       message.disableNotification = true
#       message.replyToMessageId = response.messageId
#       message.parseMode = "markdown"
#       discard bot.send(message)

  result = cb

template handlerizer(body: untyped): untyped =
  proc cb(e: Command) {.async.} =
    inc counter
    body
    var msg = newMessage(e.message.chat.id, $message.strip())
    msg.disableNotification = true
    msg.parseMode = "markdown"
    try:
      discard bot.send(msg)  # Sometimes Telegram API just ignores requests (?).
    except Exception:
      discard
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


  proc cmd_bash0Handler(bot: Telebot, command: string): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx(command)[0]}`"""

  proc cmd_bash1Handler(bot: Telebot, command: string): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx(command)[0]}`"""

  proc cmd_bash2Handler(bot: Telebot, command: string): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx(command)[0]}`"""

  proc cmd_bash3Handler(bot: Telebot, command: string): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx(command)[0]}`"""

  proc cmd_bash4Handler(bot: Telebot, command: string): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx(command)[0]}`"""

  proc cmd_bash5Handler(bot: Telebot, command: string): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx(command)[0]}`"""

  proc cmd_bash6Handler(bot: Telebot, command: string): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx(command)[0]}`"""

  proc cmd_bash7Handler(bot: Telebot, command: string): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx(command)[0]}`"""

  proc cmd_bash8Handler(bot: Telebot, command: string): CommandCallback =
    handlerizer():
      let message = fmt"""`{execCmdEx(command)[0]}`"""

  proc cmd_bash9Handler(bot: Telebot, command: string): CommandCallback =
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

  when defined(linux):
    if server_cmd_ip:        bot.onCommand("ip", ipHandler(bot))
    if server_cmd_df:        bot.onCommand("df", dfHandler(bot))
    if server_cmd_free:      bot.onCommand("free", freeHandler(bot))
    if server_cmd_lshw:      bot.onCommand("lshw", lshwHandler(bot))
    if server_cmd_lsusb:     bot.onCommand("lsusb", lsusbHandler(bot))
    if server_cmd_lspci:     bot.onCommand("lspci", lspciHandler(bot))
    if server_cmd_public_ip: bot.onCommand("public_ip", public_ipHandler(bot))

    if cmd_bash0.name != "" and cmd_bash0.command != "":
      bot.onCommand($cmd_bash0.name, cmd_bash0Handler(bot, cmd_bash0.command))
    if cmd_bash1.name != "" and cmd_bash1.command != "":
      bot.onCommand($cmd_bash1.name, cmd_bash0Handler(bot, cmd_bash1.command))
    if cmd_bash2.name != "" and cmd_bash2.command != "":
      bot.onCommand($cmd_bash2.name, cmd_bash0Handler(bot, cmd_bash2.command))
    if cmd_bash3.name != "" and cmd_bash3.command != "":
      bot.onCommand($cmd_bash3.name, cmd_bash0Handler(bot, cmd_bash3.command))
    if cmd_bash4.name != "" and cmd_bash4.command != "":
      bot.onCommand($cmd_bash4.name, cmd_bash0Handler(bot, cmd_bash4.command))
    if cmd_bash5.name != "" and cmd_bash5.command != "":
      bot.onCommand($cmd_bash5.name, cmd_bash0Handler(bot, cmd_bash5.command))
    if cmd_bash6.name != "" and cmd_bash6.command != "":
      bot.onCommand($cmd_bash6.name, cmd_bash0Handler(bot, cmd_bash6.command))
    if cmd_bash7.name != "" and cmd_bash7.command != "":
      bot.onCommand($cmd_bash7.name, cmd_bash0Handler(bot, cmd_bash7.command))
    if cmd_bash8.name != "" and cmd_bash8.command != "":
      bot.onCommand($cmd_bash8.name, cmd_bash0Handler(bot, cmd_bash8.command))
    if cmd_bash9.name != "" and cmd_bash9.command != "":
      bot.onCommand($cmd_bash9.name, cmd_bash0Handler(bot, cmd_bash9.command))

  bot.poll(int32(polling_interval * 1000))


when isMainModule:
  waitFor(main())
