-----------------------------------------------------------------
--  Copyright (c) 2013 TwoDudesOneCode, Inc.					--																		  
--  All Rights Reserved.  													--																	  
--  http://TwoDudesOneCode.com									--
-----------------------------------------------------------------

function populateAttributes ( attributes, aTable )
	if attributes == nil then return aTable end

	for key, value in pairs ( attributes ) do
		aTable[key] = value
	end
	return aTable
end

function populateChildren(children, aTable)
	if children == nil then return aTable end
	-- print("children")
	for key, value in pairs (children) do
		print("key: " .. key)
		aTable[key] = {}
		for k, v in pairs (value) do
			print("  k: " .. k)
			myVal = ""
			for aK, aV in pairs(v) do
				if (aK == "value") then
					myVal = aV
				end
				print("    aK:" .. aK )
				if type(aV) == "table" then
					for kk, vv in pairs(aV) do
						print( "      kk:" .. kk .. " vv: " .. vv)
						print("          aTable["..key.."]["..vv.."] = "..myVal)
						aTable[key][vv] = myVal
					end
				else
					print("      aV: " .. aV)					
				end
			end
			aTable[key][k] = v
		end
	end
	
	return aTable
end

function xmlparser( fileName )
	xml = MOAIXmlParser.parseFile( fileName )
	xmlTable = {}
	if (xml.attributes) then
		xmlTable = populateAttributes(xml.attributes, xmlTable)
	end
	if (xml.children) then		
		xmlTable = populateChildren(xml.children, xmlTable)
	end
	return xmlTable
end