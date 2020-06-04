del .\sspks.bedrock\*.* /Q
copy bedrockxx-cedarview-xx_thumb_72.png .\sspks.bedrock\bedrock%1-cedarview-%2_thumb_72.png
copy bedrockxx-cedarview-xx_thumb_120.png .\sspks.bedrock\bedrock%1-cedarview-%2_thumb_120.png
copy .\source\INFO.bedrock .\sspks.bedrock\bedrock%1-cedarview-%2.nfo
"C:\Program Files\7-Zip\7z" a -ttar .\sspks.bedrock\bedrock%1-cedarview-%2.spk .\source\*
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.bedrock\bedrock%1-cedarview-%2.spk scripts
"C:\Program Files\7-Zip\7z" rn -ttar .\sspks.bedrock\bedrock%1-cedarview-%2.spk scripts.bedrock scripts
"C:\Program Files\7-Zip\7z" rn -ttar .\sspks.bedrock\bedrock%1-cedarview-%2.spk INFO.bedrock INFO
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.bedrock\bedrock%1-cedarview-%2.spk INFO.minecraft
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.bedrock\bedrock%1-cedarview-%2.spk INFO.spigot
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.bedrock\bedrock%1-cedarview-%2.spk INFO.craftbukkit
"C:\Program Files\7-Zip\7z" d -ttar .\sspks.bedrock\bedrock%1-cedarview-%2.spk INFO.paper