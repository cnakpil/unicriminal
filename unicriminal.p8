pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
------------- init -------------

anims={
 default={fr=5,128,130},
 left={fr=5,132,134},
 right={fr=5,136,138}
}

timer=0
uniframe=0
emove_anim=0

function _init()
	-- clear screen
	cls(0)
	
	mode="start"
	blink_count=0
end

function _update()
	blink_count+=1

	if mode=="game" then
 	update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="over" then
 	update_over()
 end
end

function _draw()
 if mode=="game" then
 	draw_game()
 elseif mode=="start" then
 	draw_start()
 elseif mode=="over" then
  draw_over()
 end
end

function start_game()
	-- basic variables
	mode="game"
	muzzle=0
	score=10000	
	total_lives=4
	cur_lives=4
	
	-- unicorn object
	uni={}
	uni.spr=128
	uni.x=60
	uni.y=100
	uni.spdx=0
	uni.animindex=2
	uni.ghost=false
	uni.colw=16
	uni.colh=16
	
	-- star object array
	stars={}
	for i=1,100 do
		local new_star={}
		new_star.x=flr(rnd(128))
		new_star.y=flr(rnd(128))
		new_star.spd=rnd(1.5)+0.5
		new_star.color=6
		add(stars,new_star)		
	end
	
	-- bullet object array
	bullets={}
	
	-- enemy object array
	enemies={}
	for i=0,7 do
		local new_enemy={}
		new_enemy.x=14+(i*14)
		new_enemy.y=-8
		new_enemy.spr=18
		new_enemy.fspr=21
		new_enemy.ghost=false
		new_enemy.colw=8
		new_enemy.colh=8
		new_enemy.hp=1
		add(enemies,new_enemy)	
	end
	
	-- unicorn fart array
	farts={}
	
end
-->8
------------ update ------------

function update_game()
	
	-- reset unicorn state
	uni_reset()
	
	-- controls
	controls()
	
	-- move unicorn
	uni_move()
	
	-- move+animate unicorn farts
	unifart_anim()
	
	-- animate muzzle flash
	muzzle_flash()
	
	-- move+animate bullet
	bullet_anim()
	
	-- enemy animations
	espawn_anim()
	enemy_anim()
	
	-- animate enemy flames
	flame_anim(enemies,21,24)
	
	-- set screen bounds
	set_bounds()
	
	-- collisions
	shoot_enemy()
	uni_crash()
	
	-- animate stars
	animate_stars()
	
end

function update_start()
	if btnp(5) or btnp(4) then
		start_game()
	end
end

function update_over()
	if btnp(5) or btnp(4) then
		mode="start"
	end
end
-->8
------- update functions -------

function uni_reset()
 uni.spdx=0
	uni.spdy=0
	reset_anim()
end

function uni_move()
 uni.x+=uni.spdx
	uni.y+=uni.spdy
end

function unifart_anim()

end

function bullet_anim()
 for i=#bullets,1,-1 do
		--move
	 local cur_bullet=bullets[i]
	 cur_bullet.y-=cur_bullet.spd
	 
	 if cur_bullet.y<-8 then
	 	del(bullets,cur_bullet)
	 end
	 
	 --animate
	 cur_bullet.spr+=1
		if cur_bullet.spr>68 then
			cur_bullet.spr=66
		end	 
	end
end

function muzzle_flash()
 if muzzle>0 then
		muzzle-=1
	end
end

function flame_anim(array,start,limit)
 for i=#array,1,-1 do
		cur_obj=array[i]
		cur_obj.fspr+=1
			if cur_obj.fspr>limit then
				cur_obj.fspr=start
			end	
	end
end

function enemy_anim()
 for cur_enemy in all(enemies) do
	 -- move enemy ship left and right
	 -- change sprite based on motion
	end
end

function espawn_anim()
 for enemy in all(enemies) do
  if enemy.y<20 then
   enemy.y+=2
  end
  if enemy.y>=20 then
   enemy.y+=1
  end
 end
end
-->8
----------- controls -----------

function controls()
	if btnp(0) then
	 sidestep("left",-4)
	end
	if btnp(1) then
		sidestep("right",4)
	end
	if btnp(5) then
	 load_bullet()
		sfx(0)
		muzzle=4
	end
	if btnp(4) then
		mode="over"
	end
end

function sidestep(dir,spd)
		uni.spdx=spd
 	if uni.animindex>2 then
	 	uni.animindex=1
	 end
	 uni.spr=anims[dir][uni.animindex]
	 uni.animindex+=1
	 timer=6
end

function reset_anim()
	if timer>0 then
		uniframe=0
		timer-=1
	end
	if timer==0 then
		uniframe+=1
		if uni.animindex>2 then
	 	uni.animindex=1
		end
		if uniframe%3==0 then
			uni.spr=anims["default"][uni.animindex]
			uni.animindex+=1 
		end
	end
end

function load_bullet()
 local new_bullet={}
	new_bullet.x=uni.x
	new_bullet.y=uni.y-3.5
	new_bullet.spd=5
	new_bullet.spr=065
	new_bullet.colw=8
	new_bullet.colh=8
	new_bullet.dmg=1
	new_bullet.sy=-4
	add(bullets,new_bullet)
end

function set_bounds()
	if uni.x>112 then
		uni.x=112
	end
	if uni.x<0 then
		uni.x=0
	end
end
-->8
---------- collisions -----------

--collision enemy+unibullets
function shoot_enemy()
	for enemy in all(enemies) do
	 for bullet in all(bullets) do
	  if col(enemy,bullet) then
	   del(bullets,bullet)
	   sfx(1)
	   enemy.hp-=1
	  end
	  if enemy.hp<=0 then
	   kill(enemy)
	  end
	 end
	end
end

--collision enemy+unicorn
function uni_crash()
 for enemy in all(enemies) do
  if col(enemy,uni) then
   sfx(1)
   enemy.hp-=1
   cur_lives-=1
  end
  if enemy.hp<=0 then
   kill(enemy)
  end
  if cur_lives<=0 then
   mode="over"
  end
 end
end

--collision ebullets+unicorn

--kill enemy
function kill(enemy)
 del(enemies,enemy)
 --explode sound
 --explode animation
end

--detect collisions
--returns bool
function col(a,b)
 if a.ghost or b.ghost then 
  return false
 end

 local a_left=a.x
 local a_top=a.y
 local a_right=a.x+a.colw-1
 local a_bottom=a.y+a.colh-1
 
 local b_left=b.x
 local b_top=b.y
 local b_right=b.x+b.colw-1
 local b_bottom=b.y+b.colh-1

 if a_top>b_bottom then 
 	return false end
 if b_top>a_bottom then 
 	return false end
 if a_left>b_right then 
 	return false end
 if b_left>a_right then 
 	return false end
 
 return true
end
-->8
------------- draw -------------

function draw_game()
	cls(0)
	starfield()
	
	-- draw unicorn
	spr(uni.spr,uni.x,uni.y,2,2)
	
	-- draw bullets
	for bullet in all(bullets) do
	 draw_spr(bullet)
	end
	
	-- draw enemies
	for enemy in all(enemies) do
	 draw_spr(enemy)
	 spr(enemy.fspr,
	 				enemy.x,
	 				enemy.y-8)
	end
	
	-- muzzle flash
	if muzzle>0 then
		circfill(uni.x+3,
											uni.y-2,
											muzzle,
											7)
	end
	
	-- 32767 is the biggest number
	print("score: "..score,45,3,12)
	
	-- draw hearts
	for i=1,total_lives do
		if cur_lives>=i then
			spr(13,i*9-8,2)
		else
			spr(14,i*9-8,2)
		end
	end
	
end

function draw_start()
	cls(7)
	print("unicriminal",43,40,0)
	print("press x or z key to start",15,80,blink())
end

function draw_over()
 cls(8)
	print("game over",45,40,2)
	print("press x or z key to continue",9,80,7)
end

function print_test()
 
end
-->8
-------- misc functions --------

function starfield()
	for i=1,#stars do
	 local cur_star=stars[i]
	 
	 if cur_star.spd<1 then
	 	cur_star.color=1
	 	elseif cur_star.spd<1.5 then
			cur_star.color=13
		end
		pset(cur_star.x,
							cur_star.y,
							cur_star.color)
	end
end

function animate_stars()
	for i=1,#stars do
		local cur_star=stars[i]
		cur_star.y+=cur_star.spd
		if cur_star.y>128 then
		 cur_star.y-=128
		end
	end
end

function blink()
	local b_anim={8,8,8,8,8,8,8,8,
															8,8,8,8,8,8,8,8,
															9,9,9,9,9,9,9,9,
															9,9,9,9,9,9,9,9,
															11,11,11,11,11,11,
															11,11,11,11,11,
															11,11,11,11,11,
															12,12,12,12,12,12,
															12,12,12,12,12,
															12,12,12,12,12,
															13,13,13,13,13,13,
															13,13,13,13,13,
															13,13,13,13,13}
	if blink_count>=#b_anim then
		blink_count=1
	end
	return blink_count
end

function draw_spr(new_spr)
	spr(new_spr.spr,
					new_spr.x,
					new_spr.y)
end

function spawn_enemies()
 
end
__gfx__
0000000000022000000220000002200000000000000000000000000000000000000000000000000000000000000000000000000008800bb008800bb000000000
000000000028820000288200002882000000000000077000000770000007700000c77c000000000000000000000000000000000088aabbcc800ab00c00000000
007007000028820000288200002882000000000000c77c000007700000c77c000cccccc0000000000000000000000000000000008aabbcce8000000e00000000
0007700002288e2002e88e2002e882200000000000cccc00000cc00000cccc0000cccc0000000000000000000000000000000000aabbcceea000000e00000000
00077000027c88202e87c8e20288c72000000000000cc000000cc000000cc00000000000000000000000000000000000000000000bbccee00b0000e000000000
007007000211882028811882028811200000000000000000000cc00000000000000000000000000000000000000000000000000000ccee0000c00e0000000000
00000000025582200285582002285520000000000000000000000000000000000000000000000000000000000000000000000000000ee000000ee00000000000
00000000002992000029920000299200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005995000019910000199100000000000000000000000000000000000000000000000000000000000000000000000000000700000007000000000000
000000000555c55001c55c10011c5510000000000000000000000000000000000000000000000000000000000000000000000000000070000000700000000000
000000000511cc501cc11cc101cc00100000000000000000000cc000000000000000000000000000000000000000000000000000000750000007500000000000
0000000005a7cc5016ca7c6101cca71000000000000cc000000cc000000cc0000000000000000000000000000000000000000000005dd5000050050000000000
00000000055cc650016cc610016cc1100000000000cccc00000cc00000cccc0000cccc000000000000000000000000000000000005d7dd500500005000000000
00000000005cc500001cc100001cc1000000000000c77c000007700000c77c000cccccc00000000000000000000000000000000005dddd500500005000000000
00000000005cc500001cc100001cc1000000000000077000000770000007700000c77c0000000000000000000000000000000000005dd5000050050000000000
00000000000550000001100000011000000000000000000000000000000000000000000000000000000000000000000000000000000550000005500000000000
00000000000000005995599500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000c55cc55c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000061a11a160000000000000000000000000cc00cc0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000c6ca7c6c00000000000000000cc00cc00cc00cc00cc00cc00000000000000000000000000000000000000000000000000000000000000000
00000000000000000aca7ca00000000000000000cccccccc0cc00cc0cccccccccccccccc00000000000000000000000000000000000000000000000000000000
000000000000000005cccc500000000000000000c77cc77c07700770c77cc77ccccccccc00000000000000000000000000000000000000000000000000000000
0000000000000000060cc0600000000000000000077007700770077007700770c77cc77c00000000000000000000000000000000000000000000000000000000
00000000000000000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000cc00cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccaccacc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000c1aaaa1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ca7177ac0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a7117a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000001c77c100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a0cc0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a0000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900000000000000000000088000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eaaaab000000000008aa800008aa800008aa8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8aa77aac008aa80008a77a8008aaaa8000aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8a7777ac08a77a800a7777a00aa77aa000a77a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8a7777ac0a7777a00a7777a00a7777a0007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8aa77aac0cb77bc00cb77bc00cb77bc000b77b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eaaaab00007700000c77c0000c77c0000c77c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009999000000000000000000000cc000000cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008aa800008aa800008aa80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08a77a8000aaaa0000aaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a7777a000a77a0000a77a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a7777a0007777000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cb77bc000b77b0000b77b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cbbc0000c77c0000c77c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007000000000000000700000000700000000000000070000000000000000000000000000007000000000000000700000000000000000000000000000000
00000706070000000000070807000000070000000000000007000000000000000000000000000070000000000000007000000000000000000000000000000000
00000078700000000000007a70000000006887000000000000688700000000000000000000788600000000000078860000000000000000000000000000000000
0000007a700000000000007b700000000777aa00000000000777aa00000000000000000000aa77700000000000aa777000000000000000000000000000000000
0000007b700000000000067c7600000077777bb00000000077777bb000000000000000000bb77777000000000bb7777700000000000000000000000000000000
0000067c760000000000676767600000777776cc00000000777776cc0000000000000000cc67777700000000cc67777700000000000000000000000000000000
00006766676000000006777777760000007777666666600000777666777788000006666666777700008877776667770000000000000000000000000000000000
0006777777760000006777777777600000777777777788000077777777777aa000887777777777000aa777777777770000000000000000000000000000000000
006777777777600006777777777776000077777777777aa00077777777777bb00aa77777777777000bb777777777770000000000000000000000000000000000
0677777777777600067777787777760000777777777777bb00777777777770c0bb777777777777000c0777777777770000000000000000000000000000000000
0677777777777600067777ba8777760000777777777777cc0077777777777e00cc7777777777770000e777777777770000000000000000000000000000000000
0677777877777600067777cba7777600007777777777770e0067777777777000e077777777777700000777777777760000000000000000000000000000000000
0677778ab77776000067777c77776000006777777777760000077777777760000067777777777600000677777777700000000000000000000000000000000000
006777abc77760000067776e67776000000677766777600000067776777600000006777667776000000067776777600000000000000000000000000000000000
0067777c7777600000067760e7760000000677600677600000067760677600000006776006776000000067760677600000000000000000000000000000000000
000677e0677600000000676067600000000776000067700000006770776000000007760000677000000006770776000000000000000000000000000000000000
00000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000706607000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000078870000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000007aa70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000007bb70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000067cc76000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006766667600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00067777777760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00677777777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06777777777777600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06777777777777600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06777778877777600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0677778aab7777600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006777abbc7776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0067777cc77776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000677ee067760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003d5503c5503a5503655030550275501f55018550115500c55006550045500155000550010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000033650366503865037650306502c650236501c650186501465011650096500565003650006500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
