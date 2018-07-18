import asyncdispatch, osproc, ospaths, logging, options, httpclient
import terminal, parsecfg, strutils, strformat, times
import telebot  # nimble install telebot

const
  temp_folder = getTempDir()
  kitten_pics = "https://source.unsplash.com/collection/139386/480x480"
  doge_pics = "https://source.unsplash.com/collection/1301659/480x480"
  helps_texts = staticRead("help_text.md")
  coc_text = staticRead("coc_text.md")
  motd_text = staticRead("motd_text.md")
  donate_text = staticRead("donate_text.md")
  about_texts = fmt"""
  *Nim Telegram Bot* 🤖

  ☑️ *Version:*     `0.0.1` 👾
  ☑️ *Licence:*     MIT 👽
  ☑️ *Author:*      _Juan Carlos_ @juancarlospaco 😼
  ☑️ *Compiled:*    `{CompileDate} {CompileTime}` ⏰
  ☑️ *Nim Version:* `{NimVersion}` 👑
  ☑️ *OS & CPU:*    `{hostOS.toUpperAscii} {hostCPU.toUpperAscii}` 💻
  ☑️ *Temp Dir:*    `{temp_folder}` 📂
  ☑️ *Git Repo:*    `http://github.com/juancarlospaco/nim-telegram-bot`
  ☑️ *Bot uses:*    """

let
  configuration = loadConfig("config.ini")
  api_key = configuration.getSectionValue("", "api_key")
  polling_interval = parseInt(configuration.getSectionValue("", "polling_interval")).int32
  api_url = fmt"https://api.telegram.org/file/bot{api_key}/"
  start_time = cpuTime()
assert polling_interval > 250, "ERROR: polling_interval must be > 250."

var counter = 0
addHandler(newConsoleLogger(fmtStr="$time $levelname "))


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

    if response.document.isSome:   # files
      let
        code = response.document.get

      echo code.file_name
      echo code.mime_type
      echo code.file_id
      echo code.file_size

      var message = newMessage(response.chat.id, $code)
      message.disableNotification = true
      message.replyToMessageId = response.messageId
      message.parseMode = "markdown"
      discard bot.send(message)
  result = cb


template handlerizer(body: untyped): untyped =
  proc cb(e: Command) {.async.} =
    inc counter
    body
    var msg = newMessage(e.message.chat.id, $message.strip())
    msg.disableNotification = true
    msg.parseMode = "markdown"
    discard bot.send(msg)
  result = cb

proc catHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let responz = await newAsyncHttpClient(maxRedirects=0).get(kitten_pics)
    let message = responz.headers["location"]

proc dogHandler(bot: Telebot): CommandCallback =
  handlerizer():
    let responz = await newAsyncHttpClient(maxRedirects=0).get(doge_pics)
    let message = responz.headers["location"]

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


proc main*(): auto =

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

  bot.poll(polling_interval)


when isMainModule:
  main()
