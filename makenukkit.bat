del .\sspks.nukkit\*.* /Q
copy nukkitxx-noarch-xx_thumb_72.png .\sspks.nukkit\nukkit%1-noarch-%2_thumb_72.png
copy nukkitxx-noarch-xx_thumb_120.png .\sspks.nukkit\nukkit%1-noarch-%2_thumb_120.png
copy .\source\INFO.nukkit .\sspks.nukkit\nukkit%1-noarch-%2.nfo
"C:\Program Files\7-Zip\7z" a -ttar  .\sspks.nukkit\nukkit%1-noarch-%2.spk .\source\*
"C:\Program Files\7-Zip\7z" rn -ttar .\sspks.nukkit\nukkit%1-noarch-%2.spk INFO.nukkit INFO
"C:\Program Files\7-Zip\7z" d -ttar  .\sspks.nukkit\nukkit%1-noarch-%2.spk INFO.craftbukkit
"C:\Program Files\7-Zip\7z" d -ttar  .\sspks.nukkit\nukkit%1-noarch-%2.spk INFO.minecraft
"C:\Program Files\7-Zip\7z" d -ttar  .\sspks.nukkit\nukkit%1-noarch-%2.spk INFO.spigot
