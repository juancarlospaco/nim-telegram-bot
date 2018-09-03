let
  start_time = cpuTime()
  plugins_folder* = getCurrentDir() / "plugins"      ## Plugins main folder path, that contains all other subfolder by plugin type.
  bash_plugins_folder* = plugins_folder / "bash"     ## Bash Plugins folder path, that contains all ``*.sh`` Bash plugins.
  python_plugins_folder* = plugins_folder / "python" ## Python Plugins folder path, that contains all ``*.py`` Python plugins.
  static_plugins_folder* = plugins_folder / "static" ## Static files "Plugins" folder path, that contains all ``*.*`` plugins. Its similar to Djangos/Flask Static folder.
  geo_plugins_folder* = plugins_folder / "geo"       ## INI Plugins folder path, that contains all ``*.ini`` Geo Location plugins.
  config_ini* = loadConfig("config.ini")             ## Load the ``config.ini`` file to get all the configs for the bot.
  api_key*    = config_ini.getSectionValue("", "api_key")                    ## Telegram API Key, its like the ID of the Bot, its given by ``@BotFather``, not technically a password.
  cli_colors* = parseBool(config_ini.getSectionValue("", "terminal_colors")) ## Use Terminal Colors or not. It allows Color Blind people to use the bot comfortably.
  ips2ping* = config_ini.getSectionValue("", "ips2ping").split(',')          ## List of IP to ping when the ``/ping`` command is used on the chat.
  # folders2backup = parseJson(config_ini.getSectionValue("", "folders2backup"))

  file_size_limit* = parseInt(config_ini.getSectionValue("nim_files_crosscompilation", "size_limit"))    ## File Size Limit for CrossCompilation on demand.
  file_lineno_limit* = parseInt(config_ini.getSectionValue("nim_files_crosscompilation", "lines_limit")) ## File Line count Limit for CrossCompilation on demand.
  linux_args* = config_ini.getSectionValue("nim_files_crosscompilation", "linux_args")                   ## Linux Bash command line extra parameters for CrossCompilation on demand, for target Linux.
  windows_args* = config_ini.getSectionValue("nim_files_crosscompilation", "windows_args")               ## Windows Bash command line extra parameters for CrossCompilation on demand, for target Windows.

  cmd_cat*      = parseBool(config_ini.getSectionValue("commands", "cat"))      ## Boolean to Enable/Disable the ``/cat`` chat command.
  cmd_dog*      = parseBool(config_ini.getSectionValue("commands", "dog"))      ## Boolean to Enable/Disable the ``/dog`` chat command.
  cmd_bigcat*   = parseBool(config_ini.getSectionValue("commands", "bigcat"))   ## Boolean to Enable/Disable the ``/bigcat`` chat command.
  cmd_sea*      = parseBool(config_ini.getSectionValue("commands", "sea"))      ## Boolean to Enable/Disable the ``/sea`` chat command.
  cmd_coc*      = parseBool(config_ini.getSectionValue("commands", "coc"))      ## Boolean to Enable/Disable the ``/coc`` chat command.
  cmd_motd*     = parseBool(config_ini.getSectionValue("commands", "motd"))     ## Boolean to Enable/Disable the ``/motd`` chat command.
  cmd_help*     = parseBool(config_ini.getSectionValue("commands", "help"))     ## Boolean to Enable/Disable the ``/help`` chat command.
  cmd_about*    = parseBool(config_ini.getSectionValue("commands", "about"))    ## Boolean to Enable/Disable the ``/about`` chat command.
  cmd_uptime*   = parseBool(config_ini.getSectionValue("commands", "uptime"))   ## Boolean to Enable/Disable the ``/uptime`` chat command.
  cmd_donate*   = parseBool(config_ini.getSectionValue("commands", "donate"))   ## Boolean to Enable/Disable the ``/donate`` chat command.
  cmd_datetime* = parseBool(config_ini.getSectionValue("commands", "datetime")) ## Boolean to Enable/Disable the ``/datetime`` chat command.
  cmd_dollar*   = parseBool(config_ini.getSectionValue("commands", "dollar"))   ## Boolean to Enable/Disable the ``/dollar`` chat command.

  server_cmd_ip    = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "ip"))
  server_cmd_df    = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "df"))
  server_cmd_free  = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "free"))
  server_cmd_lshw  = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "lshw"))
  server_cmd_lsusb = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "lsusb"))
  server_cmd_lspci = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "lspci"))
  server_cmd_public_ip = parseBool(config_ini.getSectionValue("linux_server_admin_commands", "public_ip"))

  oer_api_key = config_ini.getSectionValue("openexchangerates", "api_key")
  oer_currenc = config_ini.getSectionValue("openexchangerates", "currencies").split(",")
  oer_round = parseBool(config_ini.getSectionValue("openexchangerates", "round_prices"))

  cam_enabled = parseBool(config_ini.getSectionValue("linux_server_camera", "cam"))
  cam_blur    = parseBool(config_ini.getSectionValue("linux_server_camera", "blur"))
  cam_caption = config_ini.getSectionValue("linux_server_camera", "photo_caption")
  python_plugins = parseBool(config_ini.getSectionValue("", "python_plugins"))
  api_url = fmt"https://api.telegram.org/file/bot{api_key}/"
  api_file = fmt"https://api.telegram.org/bot{api_key}/getFile?file_id="
  polling_interval = int32(parseInt(config_ini.getSectionValue("", "polling_interval")).int8 * 1000)
  oer_client = AsyncOER(timeout: 3, api_key: oer_api_key, base: "USD", local_base: "",  # "ARS",
                        round_float: oer_round, prettyprint: false, show_alternative: true)
