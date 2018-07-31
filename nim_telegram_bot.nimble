# Package

version       = "0.1.0"
author        = "Juan Carlos"
description   = "Telegram Bot for Nim"
license       = "MIT"
srcDir        = "src"
bin           = @["nim_telegram_bot"]

# Dependencies

requires "nim >= 0.18.0", telebot, openexchangerates
