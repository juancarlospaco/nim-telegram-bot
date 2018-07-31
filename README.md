# nim-telegram-bot

- Easy `*.ini` & `*.md` Customization. Single Binary, ~150 Kilobytes size. Tiny CPU & Net use. No dependencies.

![Rlyeh HackLab](art/nim-telegram-bot-rlye.svg "Art by Rlyeh HackLab http://rlab.be")


## Compile

Get the Code:

```bash
git clone https://github.com/juancarlospaco/nim-telegram-bot.git
cd nim-telegram-bot/
```

Compile:

```bash
nim e build_nim_telegram_bot.nims
```

**Optional**, Compilation and Run for Development only (Hacks, testing, dev, etc)

```bash
nim c -r -d:ssl nim_telegram_bot.nim
```


## Config

- Rename the file `config.ini.TEMPLATE` to `config.ini`.
- Edit the file `config.ini` to set `api_key`, `polling_interval`, etc.
- Edit the file `coc_text.md` to customize **Code Of Conduct** text.
- Edit the file `motd_text.md` to customize **Message Of The Day** text.
- Edit the file `help_text.md` to customize **Help** text.
- Edit the file `donate_text.md` to customize **Donations** text.

You can hack any of the `*.ini` and `*.md` to customize.


## Run

```bash
./nim_telegram_bot
```

The binary executable needs the following files on the same current folder:

- `config.ini`
- `coc_text.md`
- `motd_text.md`
- `help_text.md`
- `donate_text.md`

Example:

```
/home/user/bot/nim_telegram_bot
/home/user/bot/config.ini
/home/user/bot/coc_text.md
/home/user/bot/motd_text.md
/home/user/bot/help_text.md
/home/user/bot/donate_text.md
```

**Optional**, you can use any Linux command like `chrt`, `trickle`, `firejails`, `docker`, `rkt` with the Bot too.


## Requisites

*For Compilation only!, if it compiles it does not need Nim nor Telebot.*

- [Nim](https://nim-lang.org/install_unix.html) `>= 0.18.0`
- [Telebot](https://github.com/ba0f3/telebot.nim) [`nimble install telebot`](https://nimble.directory/pkg/telebot)
- [OpenExchangeRates](https://github.com/juancarlospaco/nim-openexchangerates#nim-openexchangerates)


### Single File

**Optional**, this is for advanced users only.

If you want to compile to 1 file, without any extra `*.md` files.

On the source code find and remove the lines:

```nim
helps_texts = readFile("help_text.md")
coc_text =    readFile("coc_text.md")
motd_text =   readFile("motd_text.md")
donate_text = readFile("donate_text.md")
```

On the source code find and uncomment the lines:

```nim
helps_texts = staticRead("help_text.md")
coc_text =    staticRead("coc_text.md")
motd_text =   staticRead("motd_text.md")
donate_text = staticRead("donate_text.md")
```

Recompile, it will Embed all the `*.md` files on the binary executable.

You will need to Recompile to change any content of the `*.md` files.

You can later delete all the `*.md` files.


### Performance Profiling

**Optional**, this is for advanced developers only.

Find and uncomment the line `import nimprof` on `nim_telegram_bot.nim`.

```bash
nim c --profiler:on --stacktrace:on -d:ssl -d:release --app:console --opt:size nim_telegram_bot.nim
./nim_telegram_bot
```

Then open the file `profile_results.txt`.


## Check code

**Optional**, this is for advanced developers only.

How to Lint the code.

```bash
nimble check
nim check src/nim_telegram_bot.nim
```


### CrossCompile

**Optional**, this is for advanced developers only.

Linux -> Windows, this allows to generate a `*.EXE` for Windows on Linux.

On Linux install all this packages:

```
mingw-w64-binutils mingw-w64-crt mingw-w64-gcc mingw-w64-headers mingw-w64-winpthreads mingw-w64-gcc-base mingw-w64-*
```

Usually only installing `mingw-w64-gcc` gets all the rest as dependency.

Names are from ArchLinux AUR, should be similar on other Distros


### Contributions

- This is cross-collaboration work of [Rlyeh HackLab](https://rlab.be) and [NimAr](https://t.me/NimArgentina) communities.
