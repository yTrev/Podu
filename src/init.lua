if game:GetService('RunService'):IsServer() then
	return require(script.PoduServer)
else
	script.PoduServer:Destroy()
	return require(script.PoduClient)
end
