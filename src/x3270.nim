# https://github.com/py3270/py3270/blob/master/py3270/__init__.py
# http://x3270.bgp.nu/Unix/x3270-script.html
#[
s3270 -httpd 8080 -scriptport 16000 127.0.0.1:3270
https://x3270.miraheze.org/wiki/HTTP_server

http://127.0.0.1:8080/3270/screen.html
]#
import std/[net, strutils,strformat]

type
  Server3270 = Socket
    #     screenSizeMax:tuple[row,col:int]
  #StatusLine = object
  #  commStatus:string

  Command = object
    cmd:string
    data:seq[string]
    statusLine:string
    result:string



proc `$`(res:Command):string =
  result = "Command: " & res.cmd & "\n"
  result &= "  data:\n"  
  for i in res.data:
    result &= "  >> " & i & "\n"
  result &= "  statusLine: " & res.statusLine & "\n"
  result &= "  ok: " & res.result 


proc connectToServer(host:string; scriptPort:int):Server3270 =
  let socket = newSocket()
  socket.connect("127.0.0.1", Port(16000))
  return socket



proc cmd(client:Server3270; cmd:string):Command =
  result.cmd = cmd
  client.send(cmd & "\n")
  var data:string
  while true:
    client.readLine( data )
    if not data.startsWith("data:"):
      data = data.strip()
      if data == "ok" or (result.cmd == "Quit" and data == ""):
        result.result = "ok"
        break
      elif data == "error":
        raise newException(ValueError, &"the command '{cmd}' failed")

      result.statusLine = data
      
    else:
      result.data &= data

#----


proc moveCursor(client:Server3270; row,col:int) =
  var tmp = client.cmd(&"MoveCursor({row},{col})")


proc write(client:Server3270; str:string; row:int = -1; col:int = -1) =
  # https://x3270.miraheze.org/wiki/String()_action
  if row > -1 and col > -1:
    client.moveCursor(row, col)
  #echo &"String({str})"
  #var tmp = client.cmd(&"String(\"{str}\")")
  var tmp = client.cmd("String(Jose)")  
  echo tmp

proc getScreenSize(client:Server3270; txt:string):tuple[row,col:int] =
  var res = client.cmd(&"Show({txt})")
  var tmp = res.data[0].split()
  if tmp[1] == "rows" and tmp[3] == "columns":
    return (tmp[2].parseInt, tmp[4].parseInt)

proc queryScreenCurSize(client:Server3270):tuple[row,col:int] =
  return client.getScreenSize("ScreenCurSize")

proc queryScreenMaxSize(client:Server3270):tuple[row,col:int] =
  return client.getScreenSize("ScreenMaxSize")

proc queryScreenSizeCurrent(client:Server3270):tuple[row,col:int] =
  return client.getScreenSize("ScreenSizeCurrent")

proc queryScreenSizeMax(client:Server3270):tuple[row,col:int] =
  return client.getScreenSize("ScreenSizeMax")



proc query(client:Server3270) =
  echo client.queryScreenSizeMax
  #echo tmp



#---------
proc main =
  let client = connectToServer("127.0.0.1", 16000)
  #var tmp = client.cmd( "String(Jose)\n" )
  #echo tmp

  client.moveCursor(4, 19) 
  #client.moveCursor(0, 0)     
  client.moveCursor(42, 79)   
  #client.query
  #client.write("Jose")

  #tmp = client.cmd( "Quit")
  #echo tmp


main()