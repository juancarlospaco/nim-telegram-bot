version     = "0.2.3"
author      = "Juan Carlos"
description = "Generic Configurable Async Telegram Bot for Nim with builtin basic functionality and Plugins."
license     = "MIT"
srcDir      = "src"
skipDirs    = @["art"]
bin         = @["nim_telegram_bot"]


# Dependencies

requires "nim >= 0.18.0"
requires "openexchangerates"
requires "telebot"
