del .\sspks.spigot\*.* /Q
copy spigotxx-noarch-xx_thumb_72.png .\sspks.spigot\spigot%1-noarch-%2_thumb_72.png
copy spigotxx-noarch-xx_thumb_120.png .\sspks.spigot\spigot%1-noarch-%2_thumb_120.png
copy .\source\INFO.spigot .\sspks.spigot\spigot%1-noarch-%2.nfo
"C:\Program Files\7-Zip\7z" a -ttar .\sspks.spigot\spigot%1-noarch-%2.spk .\source\*
"C:\Program Files\7-Zip\7z" rn -ttar .\sspks.spigot\spigot%1-noarch-%2.spk INFO.spigot INFO
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.spigot\spigot%1-noarch-%2.spk INFO.craftbukkit
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.spigot\spigot%1-noarch-%2.spk INFO.minecraft
