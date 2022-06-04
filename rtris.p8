pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--main functions

function _init()
 cls(7)
 --draw black pixels
 palt(0, false)
 
 srand(69)
 init_board()
end

function _update60()

 up_game()
end

function _draw()
 cls(7)
	draw_hud()
	draw_board()
	draw_tet(player_tet,70,60)
 draw_parts()
-- draw_debug()
end
-->8
--gameplay logic

--sideways: 23, then 9 

--should i implement the
--2 frame delay that the og
--game has???

function init_board()
 parts={} --particle list
 counters={} --animations
 stop_t=0 --stop updating
 d_count=0 --soft drop points
 hold_input=false
 s_level=0 --starting level
 score1=0
 score2=0
 level=s_level
 lines=0
 level_lines=lines
 board=matrix()
 next_tet = rnd(all_tets())()
 spawn_tet()
end

--update in-game
function up_game()
 debug_s=stop_t
	if #counters==0 then
		handle_input(player_tet)
	 gravity(player_tet)
	 if(not d_press)d_count=0
 end
 for x in all(counters) do
  x:f()
  x.t-=1
  if x.t==0 then
   del(counters,x)
  end
 end
end

function place_tet(tet)
 hold_input=true
 d_press=false
 if(d_count==0)d_count=1
 add_score(d_count-1)
 d_count=0
 for p in all(tet.shape) do
  local s = p[1]
  local x = tet.x+p[2]
  local y = tet.y+p[3]
 	board[x][y]=true
 	mset(x+20,y,s)
 end
 sfx(1)
 check_rows(tet)
end

function spawn_tet()
 player_tet = next_tet
 player_tet.x = 4
 player_tet.y = 1
 local tet = rnd(all_tets())()
 next_tet = tet
end

function check_rows(tet)
 local rows = rot_cw(board)
 local full_rows = {} 
 for i=1,#rows do
  if every(rows[i]) then
   add(full_rows, i)
  end
 end
 if #full_rows > 0 then
  if #full_rows==4 then
   sfx(3)
  else
  	sfx(2)
  end
  flash(full_rows)
 else
  spawn_tet()
 end
end

function clear_lines(b,lines)
 remove_rows(b,lines)
 line_score(#lines)
 add_to_lines(#lines)
end

function add_to_lines(x)
 lines += x
 level_lines += x
 if(lines>9999)lines=9999
 if level==s_level then
  local n = (s_level*10)+10
  if level_lines >= n then
   level+=1
   level_lines-=n
  end
 else
		if level_lines >= 10 then
   level+=1
   level_lines-=10
  end
 end
end

function line_score(n)
 local x=0
 if(n==1)x=40
 if(n==2)x=100
 if(n==3)x=300
 if(n==4)x=1200
 add_score(x*(level+1))
end

function add_score(x)
 score1+=x
 score2+=flr(score1/1000)
 if score2>999 then
  score2=999
  if score1>999 then
  	score1=999
  end
 end
 score1=score1%1000
end

function remove_rows(b,ys)
 for y in all(ys) do
 	for x=1,#b do
   	b[x][y]=false
		 	mset(x+20,y,0)
		end
		fall_rows(b,y-1)
 end
end

function fall_rows(b,bot)
 for y=bot,1,-1 do
 	for x=1,#b do
   b[x][y+1]=b[x][y]
   b[x][y]=false
   local s=mget(x+20,y)
   mset(x+20,y,0)
		 mset(x+20,y+1,s)
		end
	end
end

-- check for out of bounds
function oob(tet)
 for p in all(tet.shape) do
  local x = tet.x+p[2]
  local y = tet.y+p[3]
  if(x <  1)return true
  if(x > 10)return true
--  if(y <  1)return true
  if(y > 17)return true
 end
end

function collide(tet)
 if(oob(tet))return true
 for p in all(tet.shape) do
  local x = tet.x+p[2]
  local y = tet.y+p[3]
  if(board[x][y])then
   return true
  end 
 end
 return false
end

function matrix()
 local mt = {}
 for i=1,10 do
  mt[i] = {}
  for j=1,17 do
    mt[i][j] = false
  end
 end
 return mt
end

function handle_input(tet)
-- debug_s=hold_input
 if btn()==0 then
  hold_input=false
  d_press=false
 end
 if hold_input==false then
  if(btnp(⬇️))d_press=true
 end
 if(btnp(➡️))move_right(tet)
 if(btnp(⬅️))move_left(tet)
 if(btnp(❎))rot_right(tet)
 if(btnp(🅾️))rot_left(tet)
 if btn(➡️) then
  d_press=false
 end
 if btn(⬅️) then
  d_press=false
 end
end

function rot_right(tet)
	local n = #tet.shape_list
	local old_i = tet.shape_i
 if tet.shape_i < n then
  tet.shape_i += 1
 else
  tet.shape_i = 1
 end
	tet.shape = tet.shape_list[
	 tet.shape_i
	]
	if collide(tet) then
	 tet.shape_i = old_i
		tet.shape = tet.shape_list[
			tet.shape_i
		]
	else
	 sfx(0)
	end
end

function rot_left(tet)
	local n = #tet.shape_list
	local old_i = tet.shape_i
 if tet.shape_i != 1 then
  tet.shape_i -= 1
 else
  tet.shape_i = n	
 end
	tet.shape = tet.shape_list[
	 tet.shape_i
	]
	if collide(tet) then
	 tet.shape_i = old_i
		tet.shape = tet.shape_list[
			tet.shape_i
		]
	else
	 sfx(0)
	end
end

function move_right(tet)
	tet.x += 1
	if(collide(tet))tet.x -= 1
end

function move_left(tet)
 tet.x -= 1
 if(collide(tet))tet.x += 1
end

function move_up(tet)
 tet.y -= 1
 if(collide(tet))tet.y += 1
end

function move_down(tet)
 tet.y+=1
 if(d_press)d_count+=1
 if(collide(tet)) then
	 tet.y-=1
 	place_tet(tet)	
 end
end

function gravity(tet)
 local lookup={
  49,45,41,37,33,28,22,17,11,10,
	 9,8,7,6,6,5,5,4,4,3
 }
 lookup[0]=53
 local n=0
 if d_press then
	  n=2
	else
	 n=lookup[level]-1
	end
 if tet.counter > n then
  move_down(tet)
  tet.counter = 1
 else
  tet.counter += 1
 end
end

-->8
--blocks

function all_tets()
 return {
 	t_tet,
	 i_tet,
	 j_tet,
	 l_tet,
	 o_tet,
	 s_tet,
	 z_tet
	}
end

function new_tet(shapes)
 local tet = {}
 tet.counter = 1
 tet.x = 4
 tet.y = 1
 tet.shape_list = shapes
 tet.shape_i = 1
	tet.shape = tet.shape_list[
 	tet.shape_i
	]
	return tet
end

function t_tet()
 return new_tet(
  {
		 {
	  	{4,0,0},
	  	{4,1,0},
	  	{4,2,0},
	  	{4,1,1}
	  },
	  {
	  	{4,1,-1},
	  	{4,0, 0},
	  	{4,1, 0},
	  	{4,1, 1}
	  },
	  {
	  	{4,1,-1},
	  	{4,0, 0},
	  	{4,1, 0},
	  	{4,2, 0}
	  },
	  {
	  	{4,1,-1},
	  	{4,1, 0},
	  	{4,2, 0},
	  	{4,1, 1}
	  }
		}
 )
end

function i_tet()
 return	new_tet(
	 {
	 	{
			 {6,0,0},
			 {7,1,0},
			 {7,2,0},
			 {8,3,0}
			},
	 	{
			 {22,1,-2},
			 {23,1,-1},
			 {23,1, 0},
			 {24,1, 1}
			}
		}
 )
end

function j_tet()
 return new_tet(
  {
	  {
		  {3,0,0},
		  {3,1,0},
		  {3,2,0},
		  {3,2,1}
		 },
	  {
		  {3,1,-1},
		  {3,1, 0},
		  {3,0, 1},
		  {3,1, 1}
		 },
	  {
		  {3,0,-1},
		  {3,0, 0},
		  {3,1, 0},
		  {3,2, 0}
		 },
	  {
		  {3,1,-1},
		  {3,2,-1},
		  {3,1, 0},
		  {3,1, 1}
		 }
	 }
	)
end

function l_tet()
 return new_tet(
  {
	  {
		  {5,0,0},
		  {5,1,0},
		  {5,2,0},
		  {5,0,1}
		 },
	  {
		  {5,0,-1},
		  {5,1,-1},
		  {5,1, 0},
		  {5,1, 1}
		 },
	  {
		  {5,2,-1},
		  {5,0, 0},
		  {5,1, 0},
		  {5,2, 0}
		 },
	  {
		  {5,1,-1},
		  {5,1, 0},
		  {5,1, 1},
		  {5,2, 1}
		 }
		}
	)
end

function o_tet()
	return new_tet{
 	{
	 	{1,1,0},
	 	{1,2,0},
	 	{1,1,1},
	 	{1,2,1}
	 }
	}
end

function s_tet()
 return new_tet{
  {
 	 {9,1,0},{9,2,0},
 	 {9,0,1},{9,1,1}
 	},
 	{
 	 {9,0,-1},{9,0,0},
 	 {9,1, 0},{9,1,1}
 	}
 }
end

function z_tet()
 return new_tet{
  {
	  {2,0,0},{2,1,0},
	  {2,1,1},{2,2,1}
	 },
  {
	  {2,1,-1},{2,0,0},
	  {2,1,0},{2,0,1}
	 }
	}
end
-->8
--graphics

function draw_debug()
 print(
  debug_s,
  20, 8, 0
  )
end

function draw_board()
 for x=21,31 do
  for y=1,17 do
   map(
    x,y,
    ((x-20)*7),
    ((y*7)+1),
    1,1)
  end
 end
--	map(21,17,8,120,1,1)
end

--draw particles
function draw_parts()
 for p in all(parts) do
  local f=p[1]
  local args=p[2]
  f(unpack(args))
  p[3]-=1
  if p[3]==0 then
   del(parts,p)
  end
 end
end

function flash(rows)
 local c={}
 c.rows=rows
 c.t=100
 c.f=function(self)
  local pc=6 --particle color
  local pt=10 --particle time
  if self.t==20 then
   pc=7
   pt=20
  end
  if self.t%20==0 then
   for r in all(self.rows) do
	   add(parts,{
	    rectfill,{
		    7,(r*7)+1,77,(r*7)+8,pc
		   },
		   pt
		  })
   end
  end
  if self.t==1 then
   clear_lines(board,self.rows)
   spawn_tet()
  end
 end
 add(counters,c)
 stop_t=60
end

function draw_hud()
 map(0,0,0,0,16,16)
 rectfill(86,0,127,127,0)
 
 -- draw "score" text box
 local start=5
 line(
  86,start+8,127,start+8,7
 )
 rectfill(
  86,start+9,127,start+28,5
 )
 line(
  86,start+16,127,start+16,7
 )
 rectfill(
  86,start+18,127,start+27,7
 )
 line(
  86,start+29,127,start+29,7
 )
 
 box(87,start,126,start+13)
 spr(82, 89,start+3)
 spr(66, 96,start+3)
 spr(78,103,start+3)
 spr(81,110,start+3)
 spr(68,117,start+3)
 draw_num(score1,120,start+19)
 if score2 > 0 then
  draw_num(score2, 99,start+19)
 	if score1<100 then
   spr(96,106,start+19)
  end
  if score1<10 then
   spr(96,113,start+19)
  end
 end
 
 --this is a hack
 spr(25,77,start+19)

 
 
 -- draw "level" text box
 local start=start+32
 box(87,start,126,start+21)
 spr(75, 89,start+3)
 spr(68, 96,start+3)
 spr(85, 103,start+3)
 spr(68, 110,start+3)
 spr(75, 117,start+3)
 draw_num(level,110,start+11)
 
  -- draw "lines" text box
 local start=start+24
 box(87,start,126,start+21)
 spr(75,  89,start+3)
 spr(72,  96,start+3)
 spr(77, 103,start+3)
 spr(68, 110,start+3)
 spr(82, 117,start+3)
 draw_num(lines,110,start+11)
 
 -- draw "up next" box
 fancybox(89,89,127,127)
-- local next_tet = o_tet()
 next_tet.x=13.5
 next_tet.y=14.2
 draw_tet(next_tet)
 
end

function draw_num(n,x,y)
 local s_start=96
 local cs=split(n,"")
 local ss = {}
 for c in all(cs) do
  add(ss,s_start+c)
 end
 local x=x
 for i=#ss,1,-1 do
  spr(ss[i],x,y)
  x-=7
 end
end

function box(x1,y1,x2,y2)
 rsquare1(x1,  y1,  x2,  y2,  7)
 rsquare1(x1+1,y1+1,x2-1,y2-1,5)
 rsquare1(x1+2,y1+2,x2-2,y2-2,7)
end

function fancybox(x1,y1,x2,y2)
	rsquare2(x1,  y1,  x2,  y2,  6)
	rsquare1(x1+1,y1+1,x2-1,y2-1,7)
	rsquare1(x1+2,y1+2,x2-2,y2-2,6)
	rsquare2(x1+2,y1+2,x2-2,y2-2,5)
	rsquare1(x1+3,y1+3,x2-3,y2-3,0)	
	rectfill(x1+4,y1+4,x2-4,y2-4,7)
end

-- rounded square
function rsquare1(x1,y1,x2,y2,c)
 rectfill(x1+1,y1,  x2-1,y2,  c)
 rectfill(x1,  y1+1,x2,  y2-1,c)
end

-- even roundeder square
function rsquare2(x1,y1,x2,y2,c)
 rectfill(x1+2,y1,  x2-2,y2,  c)
 rectfill(x1,  y1+2,x2,  y2-2,c)
 rectfill(x1+1,y1+1,x2-1,y2-1,c)
end

function draw_tet(tet)
 local x = tet.x
 local y = tet.y
 for p in all(tet.shape)do
  spr(
   p[1],
   ((x+p[2])*7),
   ((y+p[3])*7)+1
  )
 end
end
-->8
--helper functions

--i really should add some
--standard functions here,
--like fmap and fold

function chars(s)
	local o={}
	for i=1,#s do
	 
	end
end

function lowest(t)
 local o = t[1]
 deli(t,1)
 for n in all(t) do
  o = min(o,n) 
 end
 return o
end

function highest(t)
 local o = t[1]

 deli(t,1)
 for n in all(t) do
  o = max(o,n) 
 end
 
 return o
end




function not_elem(t,x)
 for i in all(t) do
  if(i==x)return false
 end
 return true
end

--rotate a matrix 90 degrees
--clockwise
function rot_cw(m)
 local x_max = #m
 local y_max = #m[1]
 local o = {}
	for y=1,y_max do
	 local row = {}
	 for x=1,x_max do
	  add(row, m[x][y])
	 end
	 add(o, row)
	end
	return o
end

function every(t)
 for i in all(t) do
  if(i == false)return false
 end
 return true
end

function none(t)
 for i in all(t) do
  if(i == true)return false
 end
 return true
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700666666006666660066666600555555006566566565656665666566005555550000000000000000000000000000000000000000000000000
00700700070000700666666006000060067777600555555006666666666666566656666005000050000000000000000000000000000000000000000000000000
00077000070000700660066006077060067660600555555005665656665666666666656005077050000000000000000000000000000000000000000000000000
00077000070000700660066006077060067660600555555006666666566665666565666005077050000000000000000000000000000000000000000000000000
00700700070000700666666006000060060000600555555006566656666566656666665005000050000000000000000000000000000000000000000000000000
00000000077777700666666006666660066666600555555006665666656665666656566005555550000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60766077777777607660777707777777777777777777777000000000066566500666665076076607000000000000000000000000000000000000000000000000
60666067777777606660677775555555555555555555557706665660056666600665666076066606000000000000000000000000000000000000000000000000
00000007777777000000077755777777777777777777755706566650066656500566656070000000000000000000000000000000000000000000000000000000
76607667777777766076677757777777777777777777775706666660065666600665666077660766000000000000000000000000000000000000000000000000
66606667777777666066677757777777777777777777775705665660066666500566665076660666000000000000000000000000000000000000000000000000
00000007777777000000077757777777777777777777775706666650056566600666566070000000000000000000000000000000000000000000000000000000
60766077777777607660777757777777777777777777775706565660066665600656666076076607000000000000000000000000000000000000000000000000
60666067777777606660677757777777777777777777775706666660065666600000000076066606000000000000000000000000000000000000000000000000
00000007777777000000077757777777777777777777775700000000000000000000000000000000000000000000000000000000000000000000000000000000
76607667777777766076677757777777777777777777775700000000000000000000000000000000000000000000000000000000000000000000000000000000
66606667777777666066677757777777777777777777775700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007777777000000077757777777777777777777775700000000000000000000000000000000000000000000000000000000000000000000000000000000
60766077777777607660777757777777777777777777775700000000000000000000000000000000000000000000000000000000000000000000000000000000
60666067777777606660677755777777777777777777755700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007777777000000077775555555555555555555557700000000000000000000000000000000000000000000000000000000000000000000000000000000
76607667777777766076677757777777777777777777777500000000000000000000000000000000000000000000000000000000000000000000000000000000
66606667777777666066677700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007777777000000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60766077777777607660777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666067777777606660677700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007777777000000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76607667777777766076677700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606667777777666066677700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007777777000000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77000077700000777700007770000077700000077000000777000077707770077700007777700007700770077007777770777007707770077700007770000077
70770007700770077007700770770007700777777007777770077007707770077770077777770077700700777007777770070007700770077007700770077007
70770007700000777007777770770007700000777007777770077777700000077770077777770077700007777007777770000007700070077007700770077007
70000007700770077007777770770007700777777000007770070007707770077770077770070077700007777007777770707007707000077007700770000077
70770007700770077007700770770007700777777007777770077007707770077770077770070077700700777007777770777007707700077007700770077777
70770007700000777700007770000077700000077007777777000007707770077700007777000777700770077000000770777007707770077700007770077777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777700000000
77000077700000777700007770000007707770077077700770777007707770077007700770000007777777777777777777777777777777777700700700000000
70077707700770077007777777700777707770077077700770777007770700777007700777770007777777777777777777077707777777777076066000000000
70077707700770077700007777700777707770077077700770707007777007777700007777700077777777777700007777707077777777777076666000000000
70070707700000777777000777700777707770077077700770000007770007777770077777000777777777777700007777770777777777777066666000000000
70077077700707777077000777700777707700077707007770070007700770777770077770007777700777777777777777707077777777777706660700000000
77000707700770077700007777700777770000777770077770777007707777077770077770000007700777777777777777077707777777777770607700000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777077700000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777000000000000000000000000000000000000000000000000
77000077777007777700007770000077770000777000007777000077700000077700007777000077000000000000000000000000000000000000000000000000
70077007770007777077000777770007700700777007777770077777777770077077000770770007000000000000000000000000000000000000000000000000
70077007777007777777000777000077707700777000007770000077777700777700007770770007000000000000000000000000000000000000000000000000
70077007777007777700007777770007707700077777000770077007777007777077000777000007000000000000000000000000000000000000000000000000
70077007777007777000777777770007700000077077000770077007770007777077000777770007000000000000000000000000000000000000000000000000
77000077770000777000000770000077777700777700007777000077770007777700007777000077000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777000000000000000000000000000000000000000000000000
__map__
1000000000000000001112000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000000000000000002122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3000000000000000003132000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000001112000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000000000000000002122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3000000000000000003132000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000001112000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000000000000000002122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3000000000000000003132000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000001112000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000000000000000002122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3000000000000000003132000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000001112000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000000000000000002122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3000000000000000003132000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000001112000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0103000026055220552105521055240552505527055250052200525005270052600528005190051b0051d0051e0051a0051500514005180051a0051c0051c0051a00517005000050000500005000050000500005
0102000006650086500c6500f65010650106500c65009650046500165000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0000095560a5560b5560c5560e5560e556105561255615547175361952014500145002330000300003000b6500a65000600006000a6000030000300003000960008600086000760007600096000b60000300
000c00003c050370503c0503705037030370101a3001b3001f250222502425027250202502330000300003000b6500a6500000000000000000000000000000000000000000000000000000000000000000000000
