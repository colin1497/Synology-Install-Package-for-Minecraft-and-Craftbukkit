del .\sspks.nukkitx\*.* /Q
copy nukkitxxx-noarch-xx_thumb_72.png .\sspks.nukkitx\nukkitx%1-noarch-%2_thumb_72.png
copy nukkitxxx-noarch-xx_thumb_120.png .\sspks.nukkitx\nukkitx%1-noarch-%2_thumb_120.png
copy .\source\INFO.nukkitx .\sspks.nukkitx\nukkitx%1-noarch-%2.nfo
"C:\Program Files\7-Zip\7z" a -ttar  .\sspks.nukkitx\nukkitx%1-noarch-%2.spk .\source\*
"C:\Program Files\7-Zip\7z" rn -ttar .\sspks.nukkitx\nukkitx%1-noarch-%2.spk INFO.nukkitx INFO
"C:\Program Files\7-Zip\7z" d -ttar  .\sspks.nukkitx\nukkitx%1-noarch-%2.spk INFO.craftbukkit
"C:\Program Files\7-Zip\7z" d -ttar  .\sspks.nukkitx\nukkitx%1-noarch-%2.spk INFO.minecraft
"C:\Program Files\7-Zip\7z" d -ttar  .\sspks.nukkitx\nukkitx%1-noarch-%2.spk INFO.spigot
