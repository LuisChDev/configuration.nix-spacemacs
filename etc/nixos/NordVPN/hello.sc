println("patching files")

// patchFileAuthLoc("./servers/al/tcp/19", """\/etc\/nixos\/NordVPN\/login.conf""")

os.list(os.pwd / "servers").foreach(country =>
  os.list(country).foreach(protocol =>
    os.list(protocol).foreach(server =>
      patchFileAuthLoc(server.toString, """\/etc\/nixos\/NordVPN\/login.conf""")
    )
  )
)

