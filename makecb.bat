del .\sspks.craftbukkit\*.* /Q
copy craftbukkitxx-noarch-xx_thumb_72.png .\sspks.craftbukkit\craftbukkit%1-noarch-%2_thumb_72.png
copy craftbukkitxx-noarch-xx_thumb_120.png .\sspks.craftbukkit\craftbukkit%1-noarch-%2_thumb_120.png
copy .\source\INFO.craftbukkit .\sspks.craftbukkit\craftbukkit%1-noarch-%2.nfo
"C:\Program Files\7-Zip\7z" a -ttar .\sspks.craftbukkit\craftbukkit%1-noarch-%2.spk .\source\*
"C:\Program Files\7-Zip\7z" rn -ttar .\sspks.craftbukkit\craftbukkit%1-noarch-%2.spk INFO.craftbukkit INFO
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.craftbukkit\craftbukkit%1-noarch-%2.spk INFO.minecraft
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.craftbukkit\craftbukkit%1-noarch-%2.spk INFO.nukkit
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.craftbukkit\craftbukkit%1-noarch-%2.spk INFO.spigot