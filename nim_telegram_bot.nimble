# Package

version       = "0.1.0"
author        = "Juan Carlos"
description   = "Generic Configurable Telegram Bot for Nim, with builtin basic functionality and Plugins"
license       = "MIT"
srcDir        = "src"
skipDirs      = @["art"]
# bin           = @["nim_telegram_bot"]

# Dependencies

requires "nim >= 0.18.0", telebot, openexchangerates
