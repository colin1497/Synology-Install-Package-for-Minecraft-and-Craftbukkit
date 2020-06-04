del .\sspks.minecraft\*.* /Q
copy minecraftxx-noarch-xx_thumb_72.png .\sspks.minecraft\minecraft%1-noarch-%2_thumb_72.png
copy minecraftxx-noarch-xx_thumb_120.png .\sspks.minecraft\minecraft%1-noarch-%2_thumb_120.png
copy .\source\INFO.minecraft .\sspks.minecraft\minecraft%1-noarch-%2.nfo
"C:\Program Files\7-Zip\7z" a -ttar .\sspks.minecraft\minecraft%1-noarch-%2.spk .\source\*
"C:\Program Files\7-Zip\7z" rn -ttar .\sspks.minecraft\minecraft%1-noarch-%2.spk INFO.minecraft INFO
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.minecraft\minecraft%1-noarch-%2.spk INFO.craftbukkit
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.minecraft\minecraft%1-noarch-%2.spk INFO.spigot
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.bedrock\bedrock%1-noarch-%2.spk INFO.bedrock
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.bedrock\bedrock%1-noarch-%2.spk INFO.paper

