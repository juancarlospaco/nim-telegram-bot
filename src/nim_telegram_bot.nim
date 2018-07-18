
import times, asyncdispatch, osproc, ospaths, logging, options, httpclient
import terminal, parsecfg, strutils, strformat
import telebot  # nimble install telebot

const
  temp_folder = getTempDir()
  helps_texts = staticRead("help_text.md")
  about_texts = fmt"""
  Nim Telegram Bot 🤖
  Version:     0.0.1 👾
  Licence:     MIT 👽
  Author:      Juan Carlos @juancarlospaco 😼
  Compiled:    {CompileDate} {CompileTime} ⏰
  Nim Version: {NimVersion} 👑
  OS & CPU:    {hostOS} {hostCPU} 💻
  Temp Dir:    {temp_folder}
  Git Repo:    http://github.com/juancarlospaco/nim-telegram-bot
  Bot uses:    """

let
  configuration = loadConfig("config.ini")
  api_key = configuration.getSectionValue("", "api_key")
  polling_interval = parseInt(configuration.getSectionValue("", "polling_interval")).int32
  api_url = fmt"https://api.telegram.org/file/bot{api_key}/"
  start_time = cpuTime()
assert polling_interval > 250

var counter = 0
var L = newConsoleLogger(fmtStr="$levelname, [$time] ")
addHandler(L)


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

proc uptimeHandler(bot: Telebot): CommandCallback =
  proc cb(e: Command) {.async.} =
    inc counter
    discard bot.send(newMessage(e.message.chat.id, fmt"Uptime: {cpuTime() - start_time} ⏰"))
  result = cb

proc pingHandler(bot: Telebot): CommandCallback =
  proc cb(e: Command) {.async.} =
    inc counter
    discard bot.send(newMessage(e.message.chat.id, "pong"))
  result = cb

proc datetimeHandler(bot: Telebot): CommandCallback =
  proc cb(e: Command) {.async.} =
    inc counter
    discard bot.send(newMessage(e.message.chat.id, $now()))
  result = cb

proc aboutHandler(bot: Telebot): CommandCallback =
  proc cb(e: Command) {.async.} =
    inc counter
    discard bot.send(newMessage(e.message.chat.id, about_texts & $counter))
  result = cb

proc helpHandler(bot: Telebot): CommandCallback =
  proc cb(e: Command) {.async.} =
    inc counter
    var message = newMessage(e.message.chat.id, helps_texts)
    message.parseMode = "markdown"
    discard bot.send(message)
  result = cb

proc main*(): auto =
  let bot = newTeleBot(api_key)

  bot.onUpdate(handleUpdate(bot))

  bot.onCommand("ping", pingHandler(bot))
  bot.onCommand("about", aboutHandler(bot))
  bot.onCommand("uptime", uptimeHandler(bot))
  bot.onCommand("datetime", datetimeHandler(bot))
  bot.onCommand("help", helpHandler(bot))

  bot.poll(polling_interval)


when isMainModule:
  main()
