--<source lang="lua">
local p={}
local title=mw.title.getCurrentTitle()
local f=require("Module:IW/f")
local c=mw.loadData("Module:IW/class")
local imp={
	Name=true,
	Subname=true,
	Navigation=true,
	File=true,
	Icon=true,
	Caption_file=true,
	Map=true,
	Caption_map=true,
	Template=true,
	Category=true
}
 
function table.vts(v)
	if "string" == type(v) then
		v = string.gsub(v,"\n","\\n")
		if string.match(string.gsub(v,"[^'\"]",""),'^"+$') then
			return "'"..v.."'"
		end
		return '"'..string.gsub(v,'"','\\"')..'"'
	else
		return "table" == type(v) and table.tostring(v) or
			tostring(v)
	end
end
function table.kts(k)
	if "string" == type(k) and string.match(k,"^[_%a][_%a%d]*$") then
		return k
	else
		return "["..table.vts(k).."]"
	end
end
function table.tostring(tbl)
	local result, done = {},{}
	for k,v in ipairs(tbl) do
		table.insert(result, table.vts(v))
		done[k] = true
	end
	for k,v in pairs(tbl) do
		if not done[k] then
		table.insert( result,
			table.kts(k).."="..table.vts(v))
		end
	end
	return "{"..table.concat(result,",").."}"
end
 
function p.ask(a)
	local content=mw.title.new(a..'/wzorzec'):getContent()
	local q={'[[..title..]]',mainlabel='-'}
	content=content:gsub('^.-{{.-(|[^}}]-)}}.-$','%1'):gsub('|(.-)\t*=','|?%1'):gsub('%-%-.-\n','')
	local idx=f.split(content,'|')
	for _,v in pairs(idx) do
		q[#q+1]=v
	end
	local res=mw.smw.ask(q)
	return res[1]
--	return table.tostring(res[1])
--	return content
end
 
function p.main(tbl)
	local y,z,r,ul={},{},{},{}
	local sa=''
--	for x,v in pairs(tbl) do
	for x,v in pairs(p.ask()) do
		if imp[x] then
			y[#y+1]=v
			if x == 'Name' then
				r[#r+1]='<title><default>'..v..'</default></title>'
			elseif x == 'Navigation' then
				r[#r+1]='<navigation>'..v..'</navigation>'
			elseif x == 'File' then
				r[#r+1]='<image><default>'..v..'</default></image>'
			elseif x == 'Caption file' then
				r[#r+1]='<alt><default>'..v..'</default></alt>'
			elseif x == 'Map' then
				r[#r+1]='<image><default>'..v..'</default></image>'
			elseif x == 'Caption map' then
				r[#r+1]='<alt><default>'..v..'</default></alt>'
			elseif x == 'Icon' then
				r[#r+1]=''
			elseif x == 'Template' then
				r[#r+1]=''
			elseif x == 'Category' then
				r[#r+1]=''
			end
		else
			if not ul[c[x][1]] then ul[c[x][1]]={} end
			table.insert(ul[c[x][1]], x)
 
			if (type(v)=="table") then
				u='<div>'..table.concat(v,'</div><div>')..'</div>'
			else
				u='<div>'..tostring(v)..'</div>'
			end
			z[#z+1]='<data><label>'..x..'</label><default>'..u..'</default></data>'
		end
	end
	return mw.getCurrentFrame():preprocess('<infobox>'..table.concat(r)..table.concat(z)..'</infobox>')
--	return '<infobox>'..table.concat(r)..'</infobox>'
--	return table.concat(z)
--	return table.tostring(p.ask())
--	return table.tostring(ul)
end
 
function IWFile(v1,v2,w)
	local v=''
	v2=v2 or ''
	w=w or ''
	local ext={'svg','png','gif','jpg'}
	for _,l in pairs(ext) do
		if mw.title.new('File:'..IWFilexxx(v2,l,w)).exists then
			if f.ns(0) and f.ns(112) then v=v..'{{#set:File=File:'..IWFilexxx(v2,l,w)..'}}' end
			v=v..'[[File:'..IWFilexxx(v2,l,w)..']]'
			return v
		end
	end
end
 
function IWFilexxx(v1,v2,w)
	return tostring(title):gsub('Infobox:',''):gsub(tostring(f.check('Appearance',w,5)),'')..v1..(f.check('Appearance',w,4) or '')..'.'..v2
end
 
return p
--</source>