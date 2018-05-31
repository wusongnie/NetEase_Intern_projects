print("Starting\n")

tableBundleName = {}
tableAssetName = {}

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
	index = -1
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
		
		tableBundleName[assetName][tableAssetName[assetName]] = bundleName
		--Count the occurence of each thing using a table
	end
end

--output the data with occurence more than one
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

count = 0

sorted_keys = getKeysSortedByValue(tableAssetName,function(a , b)
        return tostring(a) > tostring(b)
    end )

output_file = io.open("result.txt", "w")

for i,j in pairs(sorted_keys )do  
		key_in = j
		value_in = tableAssetName[j]
		if(value_in > 1 and string.find(key_in, ".cs") == nil and  string.find(key_in, ".lua") == nil  and  string.find(key_in,  "AssetBundle Object") == nil )
		then
			count = count + 1
			--print(" \n Asset Name: "..key_in.." \n occured time: "..value_in.."\n".."in Bundles: ")
			output_file:write(" \nAsset Name: "..key_in.." \n occured time: "..value_in.."\n".."in Bundles: ")
			for k, v in pairs(tableBundleName[key_in]) do  
				--print(v)
				output_file:write(v)
			end
			output_file:write("\n")
		end
end 

io.close(file)
print("\nTotal asset repeated: "..count.."\n")
print("End of operation,result stored in result.txt\n")