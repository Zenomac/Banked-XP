package.path='./?.lua;banked-xp/?.lua;'..package.path
local frame=require('native_frame')
for _,size in ipairs({{320,94},{458,260},{180,140}}) do
 local w,h=table.unpack(size);local b=frame.plan(w,h)
 assert(b[0][1]==2 and b[0][3]==w-4,'native fill inset')
 for i=1,4 do assert(b[i][3]==10 and b[i][4]==10,'native corners never stretched') end
 assert(b[4][1]+10==w and b[4][2]+10==h,'bottom-right corner anchored')
 assert(b[5][3]==w-20 and b[6][2]==h-10,'horizontal edge anchoring')
 assert(b[7][4]==h-20 and b[8][1]==w-10,'vertical edge anchoring')
end
print('PASS: native 10px corners, edge geometry and fill insets at base/expanded sizes')
local parts,dividers,created={},{},{}
for i=0,8 do parts[i]={type=i==0 and 1 or 3} end
local root={xyGlobal={x=0,y=0}}
local function node()
 local c={}
 function c:SetPos(x,y) self.x,self.y=x,y end
 function c:SetSize(w,h) self.width,self.height=w,h end
 function c:MoveToFront() end
 function c:Destroy() self.destroyed=true end
 return c
end
ui={ComponentType={SPRITE=3},Interfaces={GetComponent=function(_,id,static,_,dynamic)
 if id==96797568 then return root end
 if static==900 then return parts[dynamic] end
 if static==901 then return dividers[dynamic] end
end},Layer={new=function() local c=node();created[#created+1]=c;return c end},Sprite={new=node}}
local bg={width=300,height=150,xyGlobal={x=10,y=20}}
local header={height=18,xyGlobal={y=26}}
local footer={xyGlobal={y=150}}
local function box(c,x,y,w,h) c.x,c.y,c.width,c.height=x,y,w,h end
local function edit(c,k,v) c[k]=v end
for count=0,2 do
 frame.destroy();created={};dividers={}
 for i=0,count-1 do dividers[i]={type=3} end
 assert(frame.apply(bg,header,footer,nil,box,edit),'native frame works with '..count..' native dividers')
 assert(#created==2-count,'only missing dividers get native sprite replacements')
 for i=1,8 do assert(parts[i].hidden==false,'native frame pieces retained') end
 frame.hide();for _,c in ipairs(created) do assert(c.hidden,'replacement hidden on restore') end
 frame.apply(bg,header,footer,nil,box,edit)
 assert(#created==2-count,'replacement layers reused')
end
frame.destroy()
print('PASS: native frame retained with zero, one or two divider components; replacement lifecycle and reuse')
