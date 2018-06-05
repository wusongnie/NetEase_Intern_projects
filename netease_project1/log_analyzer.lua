--print("Starting\n")

tableBundleName = {}
tableAssetName = {}
tableSuffixName = {}
tableFileMemory= {}
tableAssetMemory = {}


--initializating all the variables and open the log to be read
function initializer()
	filePath = arg[1] -- arg[1] is the path of the  log file
	file = io.open (filePath ,"r")
	if (file == nil) then
		print("Usage: lua test.lua [log_file_name]\n")
		os.exit(0)
	end
	io.input(file)
	line = ""
	nextLine = ""
	bundleName = ""
	tableAssetMemory["picture"] = {}
	tableAssetMemory["font"] = {}
	tableAssetMemory["shader"] = {}
	tableAssetMemory["mat"] = {}
	tableAssetMemory["mesh"] = {}
	tableSuffixName["Picture"] = 0
	tableSuffixName["Mat"] = 0
    tableSuffixName["Shader"] = 0
	tableSuffixName["Font"] = 0
	tableSuffixName["Mesh"] = 0
end

	
--check if it is the start of a correct bundle
function bundleChecker(line)
	return string.find(line, "Bundle Name", 1) ~= "nil"
end


--check if the line is a splitter
function isSplit(line)
	return line == "-------------------------------------------------------------------------------"
end

--process the block of log
function process(line, bundleName)
	local index = -1
	if (string.find(line, "%% Asset") ~= nil)
	then
		index = string.find(line, "% Asset")
		assetName = string.sub(line,index)
		
		--print(bundleName.." "..assetName.." ")
		if(tableAssetName[assetName] == nil)
		then
			tableAssetName[assetName] = 1
		else
			tableAssetName[assetName]  = tableAssetName[assetName]  + 1
		end
		
		if(tableBundleName[assetName] == nil)
		then
			tableBundleName[assetName] = {}
		end
		
		suffix = ""
		mem = 0.0
		for word in string.gmatch(line, "%.%l+") do suffix = string.lower(word) end
		for num in string.gmatch(line,"%d+%.%d%s") do mem = tonumber(num) end
		for check in string.gmatch(line,"%d%.%d%smb") do mem = mem * 1024 end
		tableFileMemory[assetName] = mem
		if(suffix == ".tga" or suffix == ".psd" or suffix == ".png") then 
			tableAssetMemory["picture"][assetName] = mem 
			tableSuffixName["Picture"]  = tableSuffixName["Picture"] + mem 
		end
		if(suffix == ".fbx" or suffix == ".asset") then 
			tableAssetMemory["mesh"][assetName] = mem
			tableSuffixName["Mesh"]  = tableSuffixName["Mesh"] + mem  
		end
		if(suffix == ".shader") then
			tableAssetMemory["shader"][assetName] = mem
			tableSuffixName["Shader"]  = tableSuffixName["Shader"] + mem  
		end
		if(suffix == ".mat") then 
			tableAssetMemory["mat"][assetName] = mem
			tableSuffixName["Mat"]  = tableSuffixName["Mat"] + mem  
		end
		if(suffix == ".tif") then
			tableAssetMemory["font"][assetName] = mem
			tableSuffixName["Font"]  = tableSuffixName["Font"] + mem  
		end
		
		tableBundleName[assetName][tableAssetName[assetName]] = bundleName
		--Count the occurence of each thing using a table
	end
end


function getKeysSortedByValue(tbl, sortFunction)
  local keys = {}
  for key in pairs(tbl) do
    table.insert(keys, key)
  end

table.sort(keys, function(a, b)
    return sortFunction(tbl[a], tbl[b])
  end)
  return keys
end

initializer(line)

while(line ~=  nil) do
	line = io.read()
	if(isSplit(line))
	then
		nextLine = io.read()
		if (string.find(nextLine, "Build Report") ~= nil)
		then
			break
		end
		if (bundleChecker(nextLine))--Navigating to the proper blocks of data
		then
			bundleName = nextLine
			nextLine = io.read()
			while( not(isSplit(nextLine))) do
				process(nextLine,bundleName)
				nextLine = io.read()
			end
		end
	end
end


count = 0

sorted_keys = getKeysSortedByValue(tableAssetName,function(a , b)
        return tostring(a) > tostring(b)
    end )

output_file = io.open("repeated_resources.txt", "w")
for i,j in pairs(sorted_keys)do  
		key_in = j
		value_in = tableAssetName[j]
		if(value_in > 1 and string.find(key_in, ".cs") == nil and  string.find(key_in, ".lua") == nil  and  string.find(key_in,  "AssetBundle Object") == nil )
		then
			count = count + 1
			--print(" \n Asset Name: "..key_in.." \n occured time: "..value_in.."\n".."in Bundles: ")
			output_file:write(" \nAsset Name: "..key_in.." \n occured time: "..value_in.."\n".."in Bundles: ")
			for k, v in pairs(tableBundleName[key_in]) do  
				--print(v)
				output_file:write(v)--output the data with occurence more than one
			end
			output_file:write("\n")
			output_file:write(tableFileMemory[key_in].." kb\n")
		end
end 

output_file = io.open("statistics_total.txt", "w")

print("Statistics Report:\n")

for i,j in pairs(tableSuffixName)do
	print("  "..i..": "..j.."kb\n")
end



for i,j in pairs(tableAssetMemory)do
	local intro = ""
	if(i == "picture")  then intro = "picture (.tga .png .psd)" end
	if(i == "shader")  then intro = "shader (.shader)" end
	if(i == "mesh")  then intro = "mesh (.fbx .asset)" end
	if(i == "font")  then intro = "font (.tif)" end
	if(i == "mat")  then intro = "mat (.mat)" end
	print(" \n------------Asset and suffix Name: (sorted by size)"..intro.."------------------File and path:\n")
	sorted_keys = getKeysSortedByValue(j,function(a , b)
        return a > b
    end )
	for k,v in pairs(sorted_keys) do
		print(v.."\n"..j[v].."kb\n")
	end
end

--print("End of operation, result stored!\n")