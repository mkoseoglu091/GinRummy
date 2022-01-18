pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- core functions

-- init
function _init()
 poke(0x5f10+11, 128+11)
 poke(0x5f10+12, 128+12)
 init_deck()
 shuffle(deck)
 shuffle(deck)
 shuffle(deck)
 shuffle(deck)
 shuffle(deck)
 deal(deck)
end


-- update
function _update()
 action_select()
end


-- draw
function _draw()
 cls()
 map()

 -- draw hand
 draw_player_hand()
 
 -- draw center cards
 draw_mid_cards()
 
 -- oponent hand draw
 for i=1, 10 do
  spr(78, 8 + (i-1)*5, 48, 2, 2)
 end
 
 -- draw oponent
 spr(204, 19, 10, 4, 4)
 

 --knock button
 spr(8, 6, 75, 5, 1) 
 print("knock 10", 10, 77, 0)
 --gin button
 spr(14, 50, 75, 2, 1) 
 print("gin", 52, 77, 0)
 -- scores
 print("player1:100", 75, 10, 0)
 print("player2:000", 75, 18, 0)
 
 --_, _, _, d = gin_knock_checker({"4s", "5s", "6s", "4h", "4d" ,"8d", "ac", "ad", "ac", "kd"}) 
 
end

-->8
-- core game

function init_deck()
 deck = {"ac", "2c", "3c", "4c", "5c", "6c", "7c", "8c", "9c", "10c", "jc", "qc", "kc",
              "ad", "2d", "3d", "4d", "5d", "6d", "7d", "8d", "9d", "10d", "jd", "qd", "kd",
              "ah", "2h", "3h", "4h", "5h", "6h", "7h", "8h", "9h", "10h", "jh", "qh", "kh",
              "as", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s", "10s", "js", "qs", "ks"}
 finish_score = 100
 discard = {} -- discard pile
 
 -- player variables
 player1 = {}
 player2 = {}
 player1.hand = {}
 player2.hand = {}
 player1.score = 0
 player2.score = 0
 player1.action = 1
 player1.selected = false
 
 -- settings
 four_color = true

end

-- finds the sprite that needs to be drawn from the card string
function find_sprite(card)
 local suit = sub(card, -1)
 local value = sub(card, 1, -2)
 local suit_sp = 0
 local value_sp = 0
 local ace_start = 128
 
 if suit == "s" then
  suit_sp = 16
  ace_start = 128
 elseif suit == "h" then
  suit_sp = 17
  ace_start = 144
 elseif suit == "d" then
  if four_color then
   suit_sp = 20
   ace_start = 176
  else
   suit_sp = 18
   ace_start = 144
  end
 elseif suit == "c" then
  if four_color then
   suit_sp = 21
   ace_start = 160
  else
   suit_sp = 19
   ace_start = 128
  end
 end
 if value == "a" then
  value_sp = ace_start
 elseif value == "j" then
  value_sp = ace_start+10
 elseif value == "q" then
  value_sp = ace_start+11
 elseif value == "k" then
  value_sp = ace_start+12
 else
  value_sp = ace_start + tonum(value) - 1
 end
 return value_sp, suit_sp
end


-- shuffle deck
function shuffle(deck)
 for i=#deck,1,-1 do
 rnd_card=ceil(rnd(i))
 deck[i],deck[rnd_card]=deck[rnd_card],deck[i]
 end
end


-- draw card
function draw_card()
 return del(deck, deck[1])
end

-- deal cards
function deal()
 for i=1, 20 do
  if i%2==0 then add(player1.hand, draw_card()) end
  if i%2==1 then add(player2.hand, draw_card()) end
 end
 add(discard, draw_card())
end


-- draw player hand
-- draw the card with yellow border while hovering over it
-- draw the card raised up when it is selected
-- move the selected card (change order)
-- disselect card back to hover mode
function draw_player_hand()
 for i=1, #player1.hand do
  card_val, card_suit = find_sprite(player1.hand[i])
 	if i!= player1.action then -- selected card index
   spr(64, 3 + (i-1)*10, 92, 3, 4)
   spr(card_suit, 5 + (i-1)*10, 102)
   spr(card_val, 5 + (i-1)*10, 93)
  elseif i == player1.action and not player1.selected then
  spr(72, 3 + (i-1)*10, 92, 3, 4)
   spr(card_suit, 5 + (i-1)*10, 102)
   spr(card_val, 5 + (i-1)*10, 93)
  else
   spr(72, 3 + (i-1)*10, 87, 3, 4)
   spr(card_suit, 5 + (i-1)*10, 97)
   spr(card_val, 5 + (i-1)*10, 88)
  end
  if i == #player1.hand and player1.action != #player1.hand or not player1.selected then
   spr(card_suit,5 + (i-1)*10 + 9, 97 + 9, 1, 1, true, true)
   spr(card_val, 5 + (i-1)*10 + 9, 88 + 27, 1, 1, true ,true)
  end
  if i == #player1.hand and player1.selected and player1.action == #player1.hand then
   spr(card_suit,5 + (i-1)*10 + 9, 97 + 5, 1, 1, true, true)
   spr(card_val, 5 + (i-1)*10 + 9, 88 + 22, 1, 1, true ,true)
  end
 end
end


-- draw middle cards
function draw_mid_cards()
 discard_val, discard_suit = find_sprite(discard[#discard])
 spr(64, 74, 44, 3, 4)
 spr(discard_suit,76, 54)
 spr(discard_val, 76, 45)
 spr(discard_suit,85, 58, 1, 1, true, true)
 spr(discard_val, 85, 67, 1, 1, true ,true)
 if #deck > 0 then
  spr(69, 97, 44, 3, 4)
 end
end


function action_select()
 if btnp(0) and not player1.selected then --⬅️
  player1.action -= 1
  if player1.action <= 0 then player1.action = #player1.hand end
 
 elseif btnp(1) and not player1.selected then --➡️
  player1.action += 1
  if player1.action >= #player1.hand+1 then player1.action = 1 end
 
 elseif btnp(5) then --❎
   player1.selected = not player1.selected
 
 elseif btnp(0) and player1.selected and player1.action > 1 then
  --move selected card change order
  player1.action -= 1
  player1.hand[player1.action+1], player1.hand[player1.action] = player1.hand[player1.action], player1.hand[player1.action+1] 

 elseif btnp(1) and player1.selected and player1.action < #player1.hand then
  --move selected card change order
  player1.action += 1
  player1.hand[player1.action], player1.hand[player1.action-1] = player1.hand[player1.action-1], player1.hand[player1.action]
 end
end
-->8
-- helper functions + deadwood calc

-- copy table
function copy_table(tab)
 local t = {}
 for elem in all(tab) do
  add(t, elem)
 end
 return t
end

-- print table
function print_table(tab)
 for elem in all(tab) do
  print(elem)
 end
end

-- get subset of table
function get_subset(table, start, finish)
 local to_return = {}
 for i, v in ipairs(table) do
  if (i >= start) and (i <= finish) then
   add(to_return, v)
  end
 end
 return to_return
end

-- get card value
function card_value(card)
 val = sub(card, 1, -2)
 if val == "a" then
  return 1
 elseif val == "j" or val == "q" or val == "k" then
  return 10
 else
  return tonum(val)
 end
end

-- count deadwood value
function count_deadwood(cards)
 total = 0
 for c in all(cards) do
  total += card_value(c)
 end

 return total
end

-- get card number value for ordering
function card_number_value(card)
 val = sub(card, 1, -2)
 if val == "a" then
  return 1
 elseif val == "j" then
  return 11
 elseif val == "q" then
  return 12
 elseif val == "k" then
  return 13
 else
  return tonum(val)
 end
end

-- check if number meld
function is_number_meld(cards)
 if #cards < 3 or #cards > 4 then
  return false
 end

 num = card_number_value(cards[1])
 for card in all(cards) do
  if card_number_value(card) != num then
   return false
  end 
 end
 
 return true

end

-- check if suit meld (has to be ordered)
function is_suit_meld(cards)
 if #cards < 3 then
  return false
 end
 
 suit = sub(cards[1], -1)
 current_val = card_number_value(cards[1])
 for card in all(cards) do
  if sub(card, -1) != suit then
   return false
  end
 end
 for card in all(cards) do
  if card_number_value(card) != current_val then
   return false
  end
  current_val += 1
 end

 return true 
 
end

-- sort cards by value
function sort_by_value(hand)
 local cards = hand
 qsort(cards, function(a, b) if card_number_value(a) == card_number_value(b) then return sub(a, -1) < sub(b, -1) else return card_number_value(a) < card_number_value(b) end end)
 return cards
end

-- sort cards by suit
function sort_by_suit(hand)
 local cards = hand
 qsort(cards, function(a, b) if sub(a, -1) == sub(b, -1) then return card_number_value(a) < card_number_value(b) else return sub(a, -1) < sub(b, -1) end end)
 return cards
end


-- meld node
function new_meld_node(cards, parent)
 local meld = {}
 meld.cards = cards
 meld.parent = parent
 meld.deadwood = count_deadwood(cards)
 if (parent != nil) then
  meld.deadwood = parent.deadwood + meld.deadwood
 end 
 return meld
end

-- clean melds: return a new array of melds, containing all melds except ones that contain cards from given meld
function clean_meld_group(_melds, _meld)
 local to_return = {}
 local to_remove = {}
 for m in all(_melds) do
  add(to_return, m)
 end
 for c in all(_meld) do
  for m in all(_melds) do
   for c_m in all(m) do
    if c == c_m then
     add(to_remove, m)
     break
    end
   end
  end
 end
 for m in all(to_remove) do
  del(to_return, m)
 end
 return to_return
end

-- build meld tree
function build_meld_tree(melds, root_meld)
 best = root_meld
 for m in all(melds) do
  n = new_meld_node(m, root_meld)
  new_tree = build_meld_tree(clean_meld_group(melds, m), n)
  if (best == nil) or (new_tree.deadwood > best.deadwood) then
   best = new_tree
  end
 end
 return best
end

-- get meld set
function get_meld_set(leaf_node)
 array = {}
 n = leaf_node
 while (n != nil) do
  add(array, n.cards)
  n = n.parent
 end
 return array
end

-- get best combination
function get_best_combination(melds)
 local best_score = 0
 local best_melds = {}
 local best_leaf = build_meld_tree(melds, nil)
 
 best_score = best_leaf.deadwood
 best_melds = get_meld_set(best_leaf)
 return best_score, best_melds
end

-- main function to calculate deadwood
-- input: hand
-- output: best_score, deadwood_score, best_melds, deadwood_cards
function gin_knock_checker(hand)
 local all_melds = {}
 
 -- sort cards by value
 hand = sort_by_value(hand)

 -- check 4 card melds of same number cards
 for i=1, #hand-3 do
  poss_meld = get_subset(hand, i, i+3)
  
  if is_number_meld(poss_meld) then
   add(all_melds, poss_meld)
   -- also add 3 card combinations made from this 4 card meld
   add(all_melds, {poss_meld[1], poss_meld[2], poss_meld[4]})
   add(all_melds, {poss_meld[1], poss_meld[3], poss_meld[4]})
  end
 end
 
 -- check 3 card melds of same number cards
 for i=1, #hand-2 do
  poss_meld = get_subset(hand, i, i+2)
  if is_number_meld(poss_meld) then
   add(all_melds, poss_meld)
  end
 end

 -- sort cards by suit
 hand = sort_by_suit(hand)
 
 -- check 3 card melds in same suit
 for i=1, #hand-2 do
  poss_meld = get_subset(hand, i, i+2)
  if is_suit_meld(poss_meld) then
   add(all_melds, poss_meld)
  end
 end
 
 -- check 4 card melds in same suit
 for i=1, #hand-3 do
  poss_meld = get_subset(hand, i, i+3)
  if is_suit_meld(poss_meld) then
   add(all_melds, poss_meld)
  end
 end
 
 -- check 5 card melds in same suit
 for i=1, #hand-4 do
  poss_meld = get_subset(hand, i, i+4)
  if is_suit_meld(poss_meld) then
   add(all_melds, poss_meld)
  end
 end
 

 qsort(all_melds, function (a,b) return (count_deadwood(a) < count_deadwood(b)) end)

 best_score, best_melds = get_best_combination(all_melds) 
 deadwood_score = count_deadwood(hand) - best_score
 
 local deadwood_cards = copy_table(hand)
 for m in all(best_melds) do
  for c in all(m) do
   del(deadwood_cards, c)
  end
 end
 
 return best_score, deadwood_score, best_melds, deadwood_cards
 
end









-->8
-- qsort

-- qsort(a,c,l,r)
--
-- a
--    array to be sorted,
--    in-place
-- c
--    comparator function(a,b)
--    (default=return a<b)
-- l
--    first index to be sorted
--    (default=1)
-- r
--    last index to be sorted
--    (default=#a)
--
-- typical usage:
--   qsort(array)
--   -- custom descending sort
--   qsort(array,function(a,b) return a>b end)
--
function qsort(a,c,l,r)
	c,l,r=c or function(a,b) return a<b end,l or 1,r or #a
	if l<r then
		if c(a[r],a[l]) then
			a[l],a[r]=a[r],a[l]
		end
		local lp,k,rp,p,q=l+1,l+1,r-1,a[l],a[r]
		while k<=rp do
			local swaplp=c(a[k],p)
			-- "if a or b then else"
			-- saves a token versus
			-- "if not (a or b) then"
			if swaplp or c(a[k],q) then
			else
				while c(q,a[rp]) and k<rp do
					rp-=1
				end
				a[k],a[rp],swaplp=a[rp],a[k],c(a[rp],p)
				rp-=1
			end
			if swaplp then
				a[k],a[lp]=a[lp],a[k]
				lp+=1
			end
			k+=1
		end
		lp-=1
		rp+=1
		-- sometimes lp==rp, so 
		-- these two lines *must*
		-- occur in sequence;
		-- don't combine them to
		-- save a token!
		a[l],a[lp]=a[lp],a[l]
		a[r],a[rp]=a[rp],a[r]
		qsort(a,c,l,lp-1       )
		qsort(a,c,  lp+1,rp-1  )
		qsort(a,c,       rp+1,r)
	end
end



__gfx__
00000000333333332222222299999999222222227777777700000000000000000077777777777777777777777777777777777700000000000077777777777700
00000000333333332222222299999999222222227777777700000000000000000766666666666666666666666666666666666650000000000766666666666650
00700700333333332222222299999999222222227777777700000000000000007666666666666666666666666666666666666665000000007666666666666665
00077000333333332222222299999999222222227777777700000000000000007666666666666666666666666666666666666665000000007666666666666665
00077000333333332222222299999999222222227777777700000000000000007666666666666666666666666666666666666665000000007666666666666665
00700700333333332222222299999999222222227777777700000000000000007666666666666666666666666666666666666665000000007666666666666665
00000000333333332222222299999999222222227777777700000000000000000566666666666666666666666666666666666650000000000566666666666650
00000000333333332222222299999999222222227777777700000000000000000055555555555555555555555555555555555500000000000055555555555500
00010000088088000008000000111000000c000000bbb00000000000000000000066666666666666666666666666666666666600000000000066666666666600
0011100088888880008880000011100000ccc00000bbb000000000000000000006999999999999999999999999999999999999500000000006bbbbbbbbbbbb50
011111000888880008888800111111100ccccc00bbbbbbb000000000000000006999999999999999999999999999999999999995000000006bbbbbbbbbbbbbb5
11111110008880008888888011111110ccccccc0bbbbbbb000000000000000006999999999999999999999999999999999999995000000006bbbbbbbbbbbbbb5
011111000008000008888800111111100ccccc00bbbbbbb000000000000000006999999999999999999999999999999999999995000000006bbbbbbbbbbbbbb5
0001000000000000008880000001000000ccc000000b000000000000000000006999999999999999999999999999999999999995000000006bbbbbbbbbbbbbb5
00111000000000000008000000111000000c000000bbb000000000000000000005999999999999999999999999999999999999500000000005bbbbbbbbbbbb50
00000000000000000000000000000000000000000000000000000000000000000055555555555555555555555555555555555500000000000055555555555500
663333336666666633333355333333333333335666333333333333333333333300aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000000000aaaaaaaaaaaa00
66333333666666663333335533333333333333666633333333333333333333330a999999999999999999999999999999999999a0000000000abbbbbbbbbbbba0
6633333333333333333333553333333333333333333333333333333333333333a99999999999999999999999999999999999999a00000000abbbbbbbbbbbbbba
6633333333333333333333553333333333333333333333333333333333333333a99999999999999999999999999999999999999a00000000abbbbbbbbbbbbbba
6633333333333333333333553333333333333333333333333333333333333333a99999999999999999999999999999999999999a00000000abbbbbbbbbbbbbba
6633333333333333333333553333333333333333333333333333333333333333a99999999999999999999999999999999999999a00000000abbbbbbbbbbbbbba
66333333333333333333335555555555333333333333333355333333333333550a999999999999999999999999999999999999a0000000000abbbbbbbbbbbba0
663333333333333333333355555555553333333333333333563333333333335500aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000000000aaaaaaaaaaaa00
55555555577777775555555555555555555555557777777757777777777777750000000000000000000000000000000000000000000000000000000000000000
57777777577777777777777557777775777777777777777757777777777777750000000000000000000000000000000000000000000000000000000000000000
57777777577777777777777557777753777777777777777757777777777777750000000000000000000000000000000000000000000000000000000000000000
57777777577777777777777557777533777777777777777757777777777777750000000000000000000000000000000000000000000000000000000000000000
57777777577777777777777557775333777777777777777757777777777777750000000000000000000000000000000000000000000000000000000000000000
57777777577777777777777557753333777777777777777757777777777777750000000000000000000000000000000000000000000000000000000000000000
57777777577777777777777557533333777777777777777757777777777777750000000000000000000000000000000000000000000000000000000000000000
57777777555555557777777555333333777777775555555557777777777777750000000000000000000000000000000000000000000000000000000000000000
11111111111111111111100000010000088088001111111111111111111110009999999999999999999990009999999999999999999990001111111111166000
17777777777777777777100000111000888888801cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90001cc777ccc7766000
17777777777777777777100001111100088888001cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90001cc777ccc7766000
17777777777777777777100011111110008880001cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90001cc777ccc7766000
1777777777777777777710000111110000080000177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc779000177ccc777cc66000
1777777777777777777710000001000000000000177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc779000177ccc777cc66000
1777777777777777777710000011100000000000177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc779000177ccc777cc66000
17777777777777777777100000000000000000001cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90001cc777ccc7766000
17777777777777777777100000111000000800001cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90001cc777ccc7766000
17777777777777777777100000111000008880001cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90001cc777ccc7766000
1777777777777777777710001111111008888800177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc779000177ccc777cc66000
1777777777777777777710001111111088888880177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc779000177ccc777cc66000
1777777777777777777710001111111008888800177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc779000177ccc777cc66000
17777777777777777777100000010000008880001cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90001cc777ccc7766000
17777777777777777777100000111000000800001cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90001cc777ccc7766000
17777777777777777777100000000000000000001cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90001cc777ccc7766000
17777777777777777777100000bbb000000c0000177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc7790000000000000000000
17777777777777777777100000bbb00000ccc000177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc7790000000000000000000
177777777777777777771000bbbbbbb00ccccc00177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc7790000000000000000000
177777777777777777771000bbbbbbb0ccccccc01cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90000000000000000000
177777777777777777771000bbbbbbb00ccccc001cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90000000000000000000
177777777777777777771000000b000000ccc0001cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90000000000000000000
17777777777777777777100000bbb000000c0000177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc7790000000000000000000
1777777777777777777710000000000000000000177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc7790000000000000000000
1777777777777777777710000000000000000000177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc7790000000000000000000
17777777777777777777100000000000000000001cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90000000000000000000
17777777777777777777100000000000000000001cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90000000000000000000
17777777777777777777100000000000000000001cc777ccc777ccc777cc10009777777777777777777790009cc777ccc777ccc777cc90000000000000000000
1777777777777777777710000000000000000000177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc7790000000000000000000
1777777777777777777710000000000000000000177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc7790000000000000000000
1777777777777777777710000000000000000000177ccc777ccc777ccc771000977777777777777777779000977ccc777ccc777ccc7790000000000000000000
11111111111111111111100000000000000000001111111111111111111110009999999999999999999990009999999999999999999990000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222222557777777755222222
00110000001100000111100001001000011110000011000001111000001100000011000001001100011110000011000001001000222255777777777777552222
01001000010010000000100001001000010000000100000000001000010010000100100001010010010010000100100001001000222577777777777777775222
01001000000010000000100001001000010000000100000000001000010010000100100001010010000010000100100001010000225777777777777777777522
01111000000100000111100001111000011110000111100000001000001100000011100001010010000010000100100001100000257777777777777777777752
01001000001000000000100000001000000010000100100000001000010010000000100001010010000010000110100001010000257777777777777777777752
01001000010000000000100000001000000010000100100000001000010010000000100001010010010010000101000001001000577777777777777777777775
01001000011110000111100000001000011100000011000000001000001100000011000001001100001100000010100001001000577777775555555577777775
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222222222222222222222222
00880000008800000888800008008000088880000088000008888000008800000088000008008800088880000088000008008000222222222222222222222222
08008000080080000000800008008000080000000800000000008000080080000800800008080080080080000800800008008000222222ffffffffffff222222
08008000000080000000800008008000080000000800000000008000080080000800800008080080000080000800800008080000222222ffffffffffff222222
08888000000800000888800008888000088880000888800000008000008800000088800008080080000080000800800008800000222222ffffffffffff222222
08008000008000000000800000008000000080000800800000008000080080000000800008080080000080000880800008080000222255ffffffffffff552222
0800800008000000000080000000800000008000080080000000800008008000000080000808008008008000080800000800800022555755ffffff4455755522
08008000088880000888800000008000088800000088000000008000008800000088000008008800008800000080800008008000557757775544445577757755
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777775777755557777577777
00bb000000bb00000bbbb0000b00b0000bbbb00000bb00000bbbb00000bb000000bb00000b00bb000bbbb00000bb00000b00b000777777577775577775777777
0b00b0000b00b0000000b0000b00b0000b0000000b0000000000b0000b00b0000b00b0000b0b00b00b00b0000b00b0000b00b000777777757751157757777777
0b00b0000000b0000000b0000b00b0000b0000000b0000000000b0000b00b0000b00b0000b0b00b00000b0000b00b0000b0b0000777777775511115577777777
0bbbb000000b00000bbbb0000bbbb0000bbbb0000bbbb0000000b00000bb000000bbb0000b0b00b00000b0000b00b0000bb00000777777777771177777777777
0b00b00000b000000000b0000000b0000000b0000b00b0000000b0000b00b0000000b0000b0b00b00000b0000bb0b0000b0b0000777777777711117777777777
0b00b0000b0000000000b0000000b0000000b0000b00b0000000b0000b00b0000000b0000b0b00b00b00b0000b0b00000b00b000777777777711117777777777
0b00b0000bbbb0000bbbb0000000b0000bbb000000bb00000000b00000bb000000bb00000b00bb0000bb000000b0b0000b00b000775777777111111777777577
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000775777777111111777777577
00cc000000cc00000cccc0000c00c0000cccc00000cc00000cccc00000cc000000cc00000c00cc000cccc00000cc00000c00c000775777777111111777777577
0c00c0000c00c0000000c0000c00c0000c0000000c0000000000c0000c00c0000c00c0000c0c00c00c00c0000c00c0000c00c000775777777111111777777577
0c00c0000000c0000000c0000c00c0000c0000000c0000000000c0000c00c0000c00c0000c0c00c00000c0000c00c0000c0c0000775777777111111777777577
0cccc000000c00000cccc0000cccc0000cccc0000cccc0000000c00000cc000000ccc0000c0c00c00000c0000c00c0000cc00000775777777111111777777577
0c00c00000c000000000c0000000c0000000c0000c00c0000000c0000c00c0000000c0000c0c00c00000c0000cc0c0000c0c0000775777777111111777777577
0c00c0000c0000000000c0000000c0000000c0000c00c0000000c0000c00c0000000c0000c0c00c00c00c0000c0c00000c00c000775777777111111777777577
0c00c0000cccc0000cccc0000000c0000ccc000000cc00000000c00000cc000000cc00000c00cc0000cc000000c0c0000c00c000555555555555555555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000004fff77700000000000000000000000004fff77700000000000000000000000004fff77700000000000000000000000004fff777000000000000
00000000000444fffff777000000000000000000000444fffff777000000000000000000000444fffff777000000000000000000000444fffff7770000000000
000000000044fffffffff77000000000000000000044fffffffff77000000000000000000044fffffffff77000000000000000000044fffffffff77000000000
00000000044fffffffffff770000000000000000044fffffffffff770000000000000000044fffffffffff770000000000000000044fffffffffff7700000000
0000000044fffffffffffff7700000000000000044fffffffffffff7700000000000000044fffffffffffff7700000000000000044fffffffffffff770000000
000000044fffffffffffffff77000000000000044fffffffffffffff77000000000000044ff444ffffff444f77000000000000044fffffffffffffff77000000
000000444ffffffffffffffff7700000000000444ff44ffffffff44ff7700000000000444444ffffffffff44f7700000000000444ffffffffffffffff7700000
0000004fffffffffffffffffff4000000000004fffff44fffff444ffff4000000000004ff4fffffffffffff4ff4000000000004fffffffffffffffffff400000
0000004fff44444ffff44444ff4000000000004ffffff444ff44ffffff4000000000004fffffffffffffffffff4000000000004fffffffffffffffffff400000
0000044fffffffffffffffffff4400000000044fffffffffffffffffff4400000000044fffffffffffffffffff4400000000044fffffffffffff444fff440000
0000044ffff777ffffff777ffff700000000044ffff777ffffff777ffff700000000044ffff777ffffff777ffff7000000000441ff44444fff44fff4ff170000
0000044ffff717ffffff717ffff700000000044ffff717ffffff717ffff700000000044ffff717ffffff717ffff700000000044f1ff717fffff717fff1f70000
0000044ffffffffffffffffffff700000000044ffffffffffffffffffff700000000044ffff777ffffff777ffff700000000044ff1111111ff1111111ff70000
0000044ffffffffffffffffffff700000000044ffffffffffffffffffff700000000044ffffffffffffffffffff700000000044fff11111111111111fff70000
0000044ffffffffffffffffffff700000000044ffffffffffffffffffff700000000044ffffffffffffffffffff700000000044fff111111ff111111fff70000
0000044fffffffff44fffffffff700000000044fffffffff44fffffffff700000000044fffffffff44fffffffff700000000044fffffffff44fffffffff70000
0000004fffffffffffffffffff4000000000004fffffffffffffffffff4000000000004fffffffffffffffffff4000000000004fffffffffffffffffff400000
00000044ffffffffffffffffff40000000000044ffffffffffffffffff40000000000044ffffffffffffffffff40000000000044ffffffffffffffffff400000
00000044fffff4ffffff4fffff40000000000044ffffffffffffffffff40000000000044ffffffff44ffffffff40000000000044fffff44444444fffff400000
000000044fffff444444fffff4000000000000044fffff444444fffff4000000000000044ffffff4444ffffff4000000000000044fffff477774fffff4000000
0000000044ffffffffffffff400000000000000044fff4ffffff4fff400000000000000044fffff4444fffff400000000000000044fffff4444fffff40000000
00000000044ffffffffffff40000000000000000044ffffffffffff40000000000000000044fffff44fffff40000000000000000044fffff44fffff400000000
000000000044ffffffffff4000000000000000000044ffffffffff4000000000000000000044ffffffffff4000000000000000000044ffffffffff4000000000
0000000000044fffffff4400000000000000000000044fffffff4400000000000000000000044fffffff4400000000000000000000044fffffff440000000000
00000000000004444444000000000000000000000000044444440000000000000000000000000444444400000000000000000000000004444444000000000000
__map__
2723232323232323260101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2202020202020202203034343434320100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2202020202020202203605050505370100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2202020202020202203135353535330100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2202029d9e9f0202200101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22028dadaeaf8f02200101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22028ebdbebf8e02200101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2202020202020202200101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2421212121212121250101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
