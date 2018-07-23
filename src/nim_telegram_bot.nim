import asyncdispatch, httpclient, logging, json, options, ospaths, osproc, parsecfg, strformat, strutils, terminal, times
import telebot            # nimble install telebot            https://nimble.directory/pkg/telebot
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
  kitten_pics = "https://source.unsplash.com/collection/139386/480x480"
  doge_pics   = "https://source.unsplash.com/collection/1301659/480x480"
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
  server_cmd_ip    = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "ip"))
  server_cmd_df    = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "df"))
  server_cmd_free  = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "free"))
  server_cmd_lshw  = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "lshw"))
  server_cmd_lsusb = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "lsusb"))
  server_cmd_lspci = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "lspci"))
  server_cmd_public_ip = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "public_ip"))
  api_url = fmt"https://api.telegram.org/file/bot{api_key}/"
  polling_interval: range[99..999] = parseInt(config_ini.getSectionValue("", "polling_interval")).int32

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
      message = responz.headers["location"]

proc dogHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let
      responz = await newAsyncHttpClient(maxRedirects=0).get(doge_pics)
      message = responz.headers["location"]

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


proc main*() {.async.} =

  addHandler(newConsoleLogger(fmtStr="$time $levelname "))

  setBackgroundColor(bgBlack)
  setForegroundColor(fgCyan)
  defer: resetAttributes()

  let bot = newTeleBot(api_key)

  bot.onUpdate(handleUpdate(bot))

  bot.onCommand("cat", catHandler(bot))
  bot.onCommand("dog", dogHandler(bot))
  bot.onCommand("coc", cocHandler(bot))
  bot.onCommand("motd", motdHandler(bot))
  bot.onCommand("help", helpHandler(bot))
  bot.onCommand("ping", pingHandler(bot))
  bot.onCommand("about", aboutHandler(bot))
  bot.onCommand("uptime", uptimeHandler(bot))
  bot.onCommand("donate", donateHandler(bot))
  bot.onCommand("datetime", datetimeHandler(bot))

  when defined(linux):
    if server_cmd_ip:
      bot.onCommand("ip", ipHandler(bot))
    if server_cmd_df:
      bot.onCommand("df", dfHandler(bot))
    if server_cmd_free:
      bot.onCommand("free", freeHandler(bot))
    if server_cmd_lshw:
      bot.onCommand("lshw", lshwHandler(bot))
    if server_cmd_lsusb:
      bot.onCommand("lsusb", lsusbHandler(bot))
    if server_cmd_lspci:
      bot.onCommand("lspci", lspciHandler(bot))
    if server_cmd_public_ip:
      bot.onCommand("public_ip", public_ipHandler(bot))

  bot.poll(polling_interval)


when isMainModule:
  waitFor(main())
