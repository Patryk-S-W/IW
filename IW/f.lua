local p={}

_G.title=mw.title.getCurrentTitle()

local data=mw.loadData('Module:IW/data')
local imp={"Name","Subname","Navigation","File","Icon","Caption file","Map","Caption map","Template","Category"}
function p.is(a) return a~=nil and a~="" end
function p.ns(a) return title.namespace==a end
function p._if(a,b,c) if a then return b else return c end end

function p.check(a,b,c)
	local success, result = pcall(function() return data['forms'][data[a][mw.ustring.lower(b)]][c] end)
	return success and result or data["#default"] or b
end

function p.duplicate(a)
	local r,h={},{}
	for _,z in ipairs(a) do
		if not h[z] then
			r[#r+1]=z
			h[z]=true
		end
	end
	return r
end

function table_gsub(t,selector,f)
	local visit = {}
	for k, v in pairs(t) do
		if type(v) == 'table' then
			table.insert(visit, v)
		end
	end
	if t[selector] then f(t) end
	for _, each in ipairs(visit) do
		table_gsub(each, selector, f)
	end
end

--table_gsub(profiles, "track", convert_format)

local function convert_format(t)
	assert(type(t.track) == 'string')
	for each in t.track:gmatch "%w[^#]+" do
		table.insert(t, {track = each})
	end
	t.track = nil
end

function p.build2(frame)
	local r,e,l,j={},{},{},{}
	a=frame:getParent().args
	for i,x in pairs(a) do
		l=p.split(x:gsub('<br.*?>',', '):gsub('\n',', '),'%s*,%s+')
		if p.is(x) then
			for k,z in ipairs(l) do
				r[#r+1]=i..'='..p.check(i,z,1)..'|'
				if imp[i] then
					e[i][k]=p.split(z,'%s*;%s*')
				else
					j[i][k]=p.split(z,'%s*;%s*')
				end
			end
		end
	end
	return r,e,j
end

function p.build(frame)
	local r,l={},{}
	a=frame:getParent().args
	for i,x in pairs(a) do
		l=p.split(x:gsub('<br.*?>',', '):gsub('\n',', '),'%s*,%s+')
		if p.is(x) then
			for _,z in ipairs(l) do
				r[#r+1]=i..'='..p.check(i,z,1)
			end
		end
	end
	local e=mw.smw.set(r)
end

function p.split(s,a)
	local r={}
	local i=1
	local a_i,a_to=s:find(a,i)
	while a_i do
		r[#r+1]=s:sub(i,a_i-1)
		i=a_to+1
		a_i,a_to=s:find(a,i)
	end
	r[#r+1]=s:sub(i)
	return r
end

function p.implode(l,d)
	local w=#l
	if w==0 then
		return ""
	end
	local s=l[1]
	for i=2,w do
		s=s..d..l[i]
	end
	return s
end

function p.newMdArray(X,Y,Z)
	local MT={__call=function(t,x,y,z,v)
		if x>X or y>Y or z>Z or x<1 or y<1 or z<1 then return end
		local k=x+X*(y-1)+X*Y*(z-1)
		if v~=nil then t[k]=v end
		return t[k]
	end}
	return setmetatable({},MT)
end

function p.fromCSV(a)
	a=a..','
	local t={}
	local fs=1
	repeat
		if a:find('^"',fs) then
			local a,c
			local i=fs
			repeat
				a,i,c=a:find('"("?)',i+1)
			until c~='"'
			if not i then error('not found "') end
			local f=a:sub(fs+1,i-1)
			t[#t+1]=(f:gsub('""','"'))
			fs=a:find(',',i)+1
		else
			local nexti=a:find(',',fs)
			t[#t+1]=a:sub(fs,nexti-1)
			fs=nexti+1
		end
	until fs>a:len()
	return t
end

function p.escapeCSV(s)
	if s:find('[,"]') then
		s='"'..s:gsub(s,'"','""')..'"'
	end
	return s
end

function p.toCSV(a)
	local s=""
	for _,z in ipairs(a) do
		s=s..","..escapeCSV(z)
	end
	return s:sub(2)
end

return p

