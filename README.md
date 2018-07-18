# nim-telegram-bot

Nim Telegram Bot.


### Compile

```bash
nim c -d:release --opt:size -d:ssl nim_telegram_bot.nim
strip --strip-all nim_telegram_bot
upx --best --ultra-brute nim_telegram_bot
```
