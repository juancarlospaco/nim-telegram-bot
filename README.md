# nim-telegram-bot

Nim Telegram Bot.


### Compile

```bash
nim c -d:release --opt:size -d:ssl nim_telegram_bot.nim
strip --strip-all nim_telegram_bot
```

Optional:

```bash
upx --best --ultra-brute nim_telegram_bot
```

### Requisites

*For Compilation only!, if compiles it does not need Nim.*

- [Nim](https://nim-lang.org/install_unix.html)
- [Telebot](https://github.com/ba0f3/telebot.nim) `nimble install telebot`
