del .\sspks.paper\*.* /Q
copy paperxx-noarch-xx_thumb_72.png .\sspks.paper\paper%1-noarch-%2_thumb_72.png
copy paperxx-noarch-xx_thumb_120.png .\sspks.paper\paper%1-noarch-%2_thumb_120.png
copy .\source\INFO.paper .\sspks.paper\paper%1-noarch-%2.nfo
"C:\Program Files\7-Zip\7z" a -ttar .\sspks.paper\paper%1-noarch-%2.spk .\source\*
"C:\Program Files\7-Zip\7z" rn -ttar .\sspks.paper\paper%1-noarch-%2.spk INFO.paper INFO
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.paper\paper%1-noarch-%2.spk INFO.craftbukkit
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.paper\paper%1-noarch-%2.spk INFO.minecraft
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.spigot\spigot%1-noarch-%2.spk INFO.spigot
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.bedrock\bedrock%1-noarch-%2.spk INFO.bedrock
