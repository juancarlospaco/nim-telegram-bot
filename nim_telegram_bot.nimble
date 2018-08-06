# Package

version       = "0.1.0"
author        = "Juan Carlos"
description   = "Generic Configurable Async Telegram Bot for Nim, with builtin basic functionality and Plugins."
license       = "MIT"
srcDir        = "src"
bin           = @["nim_telegram_bot.nim"]

# Dependencies

requires "nim >= 0.18.0"
requires "telebot"
requires "openexchangerates"
