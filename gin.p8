pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- core functions

-- init
function _init()
 col_change()
 init_title()
end


-- update
function _update()
 if mode == 0 then
  update_title()
 elseif mode == 1 then
  update_game()
 elseif mode == 2 then
  update_round_end() -- not implemented
 else
  update_game_end() -- not implemented
 end
end


-- draw
function _draw()
 if mode == 0 then
  draw_title()
 elseif mode == 1 then
  draw_game()
 elseif mode == 2 then
  draw_round_end()
 else
  draw_game_end()
 end
end








-- states

-- title
function init_title()
 initglobal()
 mode = 0
end

function draw_title()
 draw_title_screen()
 print("hold ❎ to start", 30, 110, 7)
end

function update_title()
 if btn(5) then
  init_game()
 end
end



-- game

-- init new game
function init_game()
 mode = 1
 finish_score = 100
 player1 = {}
 player2 = {}
 player1.score = 0
 player2.score = 0
 init_round()
end

-- initialise new round
function init_round()
 init_deck()
 for i=1,10 do
  shuffle(deck)
 end
 deal(deck)
end

-- init deck
function init_deck()

 -- round init
 deck = {"ac", "2c", "3c", "4c", "5c", "6c", "7c", "8c", "9c", "10c", "jc", "qc", "kc",
              "ad", "2d", "3d", "4d", "5d", "6d", "7d", "8d", "9d", "10d", "jd", "qd", "kd",
              "ah", "2h", "3h", "4h", "5h", "6h", "7h", "8h", "9h", "10h", "jh", "qh", "kh",
              "as", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s", "10s", "js", "qs", "ks"}
 
 
 discard = {} -- discard pile
 round_outcome = ""
 
 -- player variables
 player1.hand = {}
 player1.turn = true -- player1 to play next
 player1.action = 1
 player1.selected = false
 player1.discard_selection = ""
 player1.upper_level_allowed = true
 player1.on_level = 1
 player1.knock_available = false
 player1.gin_available = false
 player1.knocker = nil
 player1.current_deadwood = 100
 
 -- player2 variables
 player2.hand = {}
 player2.wait_time = 0
 player2.sp = 204
 player2.phrase = "hmm.."
end

-- update game
function update_game()
 action_select()
 --simple_play()
 medium_play()
end

--draw game table
function draw_game()
 cls()
 map()
 
 -- draw center cards
 draw_mid_cards()
 
 -- draw hand
 draw_player_hand()
 
 -- draw oponent
 draw_opponent()
 
 -- draw buttons
	draw_knock_gin_button()
 draw_end_turn_button()
 
 -- draw deadwood sum
 draw_deadwood()
 
 draw_bubble()
 
 -- scores
 draw_scores()
end




-- round end


-- game end


-- tutorial
-->8
-- deck helpers + player action

-- init color
function col_change()
 poke(0x5f10+11, 128+11)
 poke(0x5f10+12, 128+12)
 four_color = true
 menuitem(1, "4 color cards", function() four_color = not four_color end)
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




-- select an action
function action_select()
 
 -- player can only rearrange cards
 if not player1.turn then 
  player1.on_level = 1
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

	-- player1's turn and has not drawn a card on level1
 elseif player1.turn and #player1.hand == 10 then
  
  if player1.on_level == 1 then
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
   elseif btn(2) and not player1.selected then
    -- select top row cards
    player1.action = 1
    player1.selected = false
    player1.on_level = 2
   end
  
  -- if player1's turn, player1 has 10 cards and on level2
  elseif player1.on_level == 2 then
   -- only two options to choose from
   if btnp(0) and not player1.selected then
    player1.action = 1
   elseif btnp(1) and not player1.selected then
    player1.action = 2
   -- go back to lower level
   elseif btnp(3) and not player1.selected then
    player1.action = 1
    player1.selected = false
    player1.on_level = 1
   elseif btnp(5) then
    if player1.action == 1 then --player has picked up the top discard card
     add(player1.hand, discard[#discard])
     del(discard, discard[#discard])
     player1.selected = false
     player1.action = 1
     player1.on_level = 1 -- pick which card to discard
    elseif player1.action == 2 then
     add(player1.hand, draw_card()) 
     player1.selected = false
     player1.action = 1
     player1.on_level = 1 -- pick which card to discard
    end
   end 
   player1.discard_selection = ""
  end
 
 -- its still player1's turn, but player has drawn a card, has 11 cards, has to pick a card for discard
 elseif player1.turn and #player1.hand == 11 then
  
  -- discard card not yet selected
  if player1.discard_selection == "" then
   player1.on_level = 1
   
   -- rearrangement options
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
   
   -- select the card for discarding
   elseif btnp(2) and player1.selected then
    -- card picked for discard
    player1.discard_selection = player1.hand[player1.action]
    player1.action = 1
    player1.selected = false
    player1.on_level = 3
    player1.current_deadwood = 100
   end
  
  -- there is a card selected for discarding
  else
   if player1.current_deadwood == 0 then player1.gin_available = true end
   if player1.current_deadwood <= 10 then player1.knock_available = true end
   player1.on_level = 3
   -- player has 3 options, click knock/gin, click done, take back card
   if btnp(3) or btnp(4) then
    player1.discard_selection = ""
    player1.action = 1
    player1.selected = false
    player1.on_level = 1
    player1.current_deadwood = 100
   elseif btnp(0) and not player1.selected then
    player1.action = 1
   elseif btnp(1) and not player1.selected then
    player1.action = 2
   elseif btnp(5) then
    if player1.action == 1 and (player1.gin_available or player1.knock_available) then
     -- player attempts knock or gin
     del(player1.hand, player1.discard_selection)
     player1.knocker = true
     end_round()
     -- game end scoring
    elseif player1.action == 2 then
     -- player is done for the round
     del(player1.hand, player1.discard_selection)
     add(discard, player1.discard_selection)
     player1.discard_selection = ""
     player1.action = 1
     player1.selected = false
     player1.on_level = 1
     player1.turn = false
     player1.current_deadwood = 100
    end
   end
  end
 end
end
-->8
--deadwood calculator

-- find largest valued card
function max_card(tab)
 local cur = 0
 local max_c = ""
 for card in all(tab) do
  if card_value(card) > cur then
   cur = card_value(card)
   max_c = card
  end
 end
 return max_c
end

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
 
 if #all_melds == 0 then
  return -1, count_deadwood(hand), {}, hand
 end
 
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



-->8
-- draw stuff

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

-- draw opponent response
function draw_bubble()
 if player2.wait_time > 0 and player2.wait_time < 50 then
  spr(12, 44, 6, 4, 2)
  print(player2.phrase, 48, 9, 0)
 elseif player2.wait_time > 70 then
  spr(12, 44, 6, 4, 2)
  print(player2.phrase, 48, 9, 0)
 end
end

-- draw player hand
function draw_player_hand()
 for i=1, #player1.hand do
  card_val, card_suit = find_sprite(player1.hand[i])
 	if i!= player1.action or player1.on_level != 1 then -- selected card index
   if player1.hand[i] == player1.discard_selection then
    --normal draw
    spr(64, 72, 50, 3, 4)
    spr(card_suit, 74, 60)
    spr(card_val, 74, 51)
    --upside draw
    spr(card_suit,83, 64, 1, 1, true, true)
    spr(card_val, 83, 73, 1, 1, true ,true)
   else
   --normal draw
    spr(64, 3 + (i-1)*10, 92, 3, 4)
    spr(card_suit, 5 + (i-1)*10, 102)
    spr(card_val, 5 + (i-1)*10, 93)
    --upside draw
    spr(card_suit,5 + (i-1)*10 + 9, 97 + 9, 1, 1, true, true)
    spr(card_val, 5 + (i-1)*10 + 9, 88 + 27, 1, 1, true ,true)
   end
  elseif i == player1.action and not player1.selected and player1.on_level == 1 then
   --highlight draw
   spr(72, 3 + (i-1)*10, 92, 3, 4)
   spr(card_suit, 5 + (i-1)*10, 102)
   spr(card_val, 5 + (i-1)*10, 93)
   spr(card_suit,5 + (i-1)*10 + 9, 97 + 9, 1, 1, true, true)
   spr(card_val, 5 + (i-1)*10 + 9, 88 + 27, 1, 1, true ,true)
  
  elseif i == player1.action and player1.on_level == 1 and player1.selected then
   --raised draw
   spr(72, 3 + (i-1)*10, 87, 3, 4)
   spr(card_suit, 5 + (i-1)*10, 97)
   spr(card_val, 5 + (i-1)*10, 88)
   --upside down
   spr(card_suit,5 + (i-1)*10 + 9, 97 + 5, 1, 1, true, true)
   spr(card_val, 5 + (i-1)*10 + 9, 88 + 22, 1, 1, true ,true)
  end
  
 end
end


-- draw opponent hand
function draw_opponent_hand()
 for i=1, 10 do
  spr(78, 8 + (i-1)*5, 48, 2, 2)
 end
end


-- draw middle cards
function draw_mid_cards()
 if #discard > 0 then
  discard_val, discard_suit = find_sprite(discard[#discard])
  if player1.on_level == 2 and player1.action == 1 then
   spr(72, 72, 40, 3, 4)
  else
   spr(64, 72, 40, 3, 4)
  end
  spr(discard_suit,74, 50)
  spr(discard_val, 74, 41)
  spr(discard_suit,83, 54, 1, 1, true, true)
  spr(discard_val, 83, 63, 1, 1, true ,true)
 end
 if #deck > 0 then
  if player1.on_level == 2 and player1.action == 2 then
   spr(75, 96, 40, 3, 4)
  else 
   spr(69, 96, 40, 3, 4)
  end
 end
end


-- draw knock and gin buttons
function draw_knock_gin_button()
 -- knock/gin  button
 if (player1.gin_available and player1.action != 1 and player1.on_level == 3) or (player1.gin_available and player1.on_level != 3)  then
  spr(44, 6, 72, 4, 1)
  
 elseif player1.gin_available and player1.on_level == 3 and player1.action == 1 then
  spr(60, 6, 72, 4, 1)
 
 elseif (player1.knock_available and player1.action != 1 and player1.on_level == 3) or (player1.knock_available and player1.on_level != 3)  then
  spr(40, 6, 72, 4, 1) 
 
 elseif player1.knock_available and player1.on_level == 3 and player1.action == 1 then
  spr(56, 6, 72, 4, 1) 
 
 elseif not player1.knock_available and player1.on_level != 3 then
  spr(8, 6, 72, 4, 1) 
 
 elseif (not player1.knock_available and player1.on_level == 3 and player1.action == 1) or (not player1.gin_available and player1.on_level == 3 and player1.action == 1) then
  spr(24, 6, 72, 4, 1) 
 
 else
  spr(8, 6, 72, 4, 1)
 end
 
 -- print label
 if player1.gin_available then
  print("gin", 16, 74, 0)
 else
  print("knock", 12, 74, 0)
 end
end


-- draw end turn button
function draw_end_turn_button()
 if player1.discard_selection == "" and player1.on_level != 3 then
  spr(8, 42, 72, 2, 1)
  spr(11, 58, 72)
 elseif player1.discard_selection == "" and player1.on_level == 3 and player1.action != 2 then
  spr(8, 42, 72, 2, 1)
  spr(11, 58, 72)
 elseif player1.discard_selection == "" and player1.on_level == 3 and player1.action == 2 then
  spr(24, 42, 72, 2, 1)
  spr(17, 58, 72)
 elseif (player1.discard_selection != "" and player1.on_level != 3) or (player1.discard_selection != "" and player1.on_level == 3 and player1.action != 2) then
  spr(44, 42, 72, 2, 1)
  spr(47, 58, 72)
 elseif player1.discard_selection != "" and player1.on_level == 3 and player1.action == 2 then
  spr(60, 42, 72, 2, 1)
  spr(63, 58, 72)
 end
 print("end", 48, 74)

end


-- function draw opponent
function draw_opponent()
 spr(player2.sp, 19, 10, 4, 4)
 draw_opponent_hand()
end

-- draw deadwood
function draw_deadwood()
 if player1.on_level == 3 then
  local t = copy_table(player1.hand)
  local card = player1.discard_selection
  del(t, card)
  _, deadwood, _, _ = gin_knock_checker(t)
 
  print("deadwood = "..deadwood, 6, 83, 7)
  player1.current_deadwood = deadwood 
 end
end


-- draw scores
function draw_scores()
 print("player1:"..player1.score, 75, 10, 0)
 print("player2:"..player2.score, 75, 18, 0)

 if player1.turn == true then
  print("player1", 75, 10, 8)
 else
  print("player2", 75, 18, 8)
 end
end
-->8
-- opponent

-- random moves
function simple_play()
 if not player1.turn then
  
  player2.wait_time += 1
  if player2.wait_time == 1 then player2.sp = 192 end
  if player2.wait_time == 50 then
   
   add(player2.hand, draw_card())
   player2.phrase = "done!"
  end
  if player2.wait_time == 70 then
   player2.sp = 204
  end
  if player2.wait_time == 100 then
   local card = del(player2.hand, player2.hand[1])
   add(discard, card)
   player2.sp = 204
   player1.turn = true
   player2.wait_time = 0
   player2.phrase = "hmm.."
  end
 end
end


-- medium play
function medium_play()
 if not player1.turn then
  
  player2.wait_time += 1
  if player2.wait_time == 1 then player2.sp = 192 end
  -- draw card
  if player2.wait_time == 50 then
   -- if discard card is useful take it
   _, _, _, d1 = gin_knock_checker(player2.hand)
   add(player2.hand,discard[#discard])
   _, _, _, d2 = gin_knock_checker(player2.hand)
   if #d2 < #d1+1 then -- the added card was not a deadwood
    del(discard, discard[#discard])
   else
    del(player2.hand, discard[#discard])
    add(player2.hand, draw_card())
   end
   player2.phrase = "done!"
  end
  -- discard card
  if player2.wait_time == 70 then
   player2.sp = 204
  end
  if player2.wait_time == 100 then
   _, d_val, _, d = gin_knock_checker(player2.hand)
   -- find largest card in set
   if d_val > 0 then -- have deadwoods in hand
    local max_c = max_card(d)
    
    del(player2.hand, max_c)
    add(discard, max_c)
   end
   _,d_val,_,_ = gin_knock_checker(player2.hand)
   if d_val<10 then
    player1.knocker = false
    end_round()
   end
   player2.sp = 204
   player1.turn = true
   player2.wait_time = 0
   player2.phrase = "hmm.."
  end
 end
end


-- advanced play
-->8
-- knock gin score

-- end round add to scores
function end_round()
 
 score1, deadwood1, melds1, deadcards1 = gin_knock_checker(player1.hand)
 score2, deadwood2, melds2, deadcards2 = gin_knock_checker(player2.hand)

 -- gin?
 if player1.knocker and deadwood1 == 0 then
  player1.score += 25
  player1.score += deadwood2
  round_outcome = "gin! player 1 wins!"
  return 1
 elseif not player1.knocker and deadwood2 == 0 then
  player2.score += 25
  player2.score += deadwood1
  round_outcome = "gin! player 2 wins!"
  return 1
 end
 
 -- check lay offs
 lay_offs, lay_score = lay_off()
 
 -- check undercut / knock
 if player1.knocker then
  if (deadwood2 - lay_score) < deadwood1 then
   -- undercut!
   player2.score += 25 --undercut bonus
   player2.score += (deadwood1 - (deadwood2 - lay_score))
   round_outcome = "undercut! player 2 wins!"
  else -- regular knock
   player1.score += ((deadwood2 - lay_score) - deadwood1)
   round_outcome = "knock! player 1 wins!"
  end
  
 else
  if (deadwood1 - lay_score) < deadwood2 then
   -- undercut!
   player1.score += 25 --undercut bonus
   player1.score += (deadwood2 - (deadwood1 - lay_score))
   round_outcome = "undercut! player 1 wins!"
  else -- regular knock
   player2.score += ((deadwood1 - lay_score) - deadwood2)
   round_outcome = "knock! player 2 wins!"
  end
 end
 
 -- round over start new round
 if player1.score >= finish_score or player2.score >= finish_score then
  --game over
  
 else
  --start new round
  
 end
end



-- lay off calculator
function lay_off()
	local lay_offs = {}

 score1, deadwood1, melds1, deadcards1 = gin_knock_checker(player1.hand)
 score2, deadwood2, melds2, deadcards2 = gin_knock_checker(player2.hand)

 if player1.knocker then
  local t = copy_table(melds1)
  for card in all(deadcards2) do
   for meld in all(t) do
    add(meld, card)
    _, d, _, _ = gin_knock_checker(meld)
    if d == 0 then -- card can be added to meld
     add(lay_offs, card)
     -- it is possible for a second card to be added due to first card added
     for card2 in all(deadcards2) do
      if card2 != card then
       add(meld, card2)
       _, d2, _, _ = gin_knock_checker(meld)
       if d2 == 0 then
        add(lay_offs, card2)
       end
       del(meld, card2)
      end
     end
    end
    del(meld, card)
   end
  end
 else -- player2 is knocker
  local t = copy_table(melds2)
  for card in all(deadcards1) do
   for meld in all(t) do
    add(meld, card)
    _, d, _, _ = gin_knock_checker(meld)
    if d == 0 then
     add(lay_offs, card)
     -- it is possible for a second card to be added due to first card added
     for card2 in all(deadcards1) do
      if card2 != card then
       add(meld, card2)
       _, d2, _, _ = gin_knock_checker(meld)
       if d2 == 0 then
        add(lay_offs, card2)
       end
       del(meld, card2)
      end
     end
    end
    del(meld, card)
   end
  end
 end
 
 -- possibility of duplicates
 local no_dup_lay_offs = remove_duplicates(lay_offs)
 
 return no_dup_lay_offs, count_deadwood(no_dup_lay_offs)
end


-- remove duplicates from table
function remove_duplicates(tab)
 local t = {}
 add(t, tab[1])
 for x in all(tab) do
  is_dup = false
  for y in all(t) do
   if x == y then
    is_dup = true
   end
  end
  -- after loop ends
  if not is_dup then
   add(t, x)
  end
 end
 return t
end

-->8
-- to do

-- a.i. medium and advanced play
-- game states (title, init game, init round, end round, end game)
-- how to play
-- tutorial?


-- title mode=0
-- game  mode=1
-- round/game end mode=2




-- image compressor for title screen

-- main program ---------------
function draw_title_screen()
 cls()
 --info()
 t="/b'f=l=tum/bg.=luuuu/b5.=luu[3wm/be.=lsuu3{3{u/b4.=lu3{3{3wm=l=l=l=tuu{3{3{3{u/b2.=l=tu3{3{3{3wm=l=luu[/be.3{u/b1.=lsu[/bd.3{3[l=tu/bf.3{3wm/bz.=lsu/bf.{3uu[/bg.3{3[/by.l=luu/be.{3wuu/bi.3{3[/bx.l=lu/be.3{uuu/bj.{3{u=l=l=luuum/br.=l=tu/be.3{u[/bl.3{/af.u3{3wu/bq.=lsu[/be.3{3[/bj.3{3uuuuu/be.3{u/bp.=lsu/bf.{3w/bh.3{3uuuuu/bg.3{3wm/bo.=lsu/bf.{3{u{3g=/be.{3uuu/bj.3{3wm/bn.=lsu/bg.{3w3{3l=,3{3{3{3u/bl.3{3[/bn.l=t/bh.{3[3g=l=,3{3{3w/bm.3{u/bn.=l[/bh.3{u{3l=l=,3{3{3[3{3:/bj.3{3wm/bm.=l=t{3{u[/be.3{3w3g=l=l={3{3{u{3{):/bj.3{3[/bm.l=ls3{3wuuu[/bd.3{3[3l=l=,3{3{3[3{(:):/bj.3{3[/bm.l=ls3{uuuuu[/bd.3{u{3l=l={3{3{u{3{):):/bj.3{u/bn.=l[3wuuuuu/bd.{3{u{3g=,3{3{3w3{3{):):4/bi.{3wm/bm.=l=t{/af.u3{3{3{u{3w3{3{-{3{3{3[3{):):):4{/ay.u[/bi.l=ls3wuuuuu[3{3{3wu[3[/be.3{u{(:):):):3[/bl.3{3[/bi.l=l[3uuuu/bd.{3uuuu[/bd.3{3w3{):):(:4w/bm.3{3[/bi.l=l[3uuwu{3{3{3wuuuuu/be.{323{):({3{3[3{7h4{7h4/bh.{3{u/bi.=l=t{3{3wu{3{3{3/af.u{/bd.3{-[3{3{):3{v{3h8h4h8h4/bh.{3wm/bi.=l=t{3{u[3{3{3w/af.u3/bd.{3lw{3{(:3{)13g/bd.8h4/bh.{3[/bi.l=ls/be.3{/ag.u[/bd.3{-23{3{3{(:)[3g8h8h8h8/bh.{3{u/bj.=ls/bd.3{3w/ag.u[3{3{3{3l=[3{3{3{):v{3g8h8h8}/bh.3{3wm/bj.=l[/bd.3{/ai.u{3{3{3{-lw{3{3{3:)13{3g8h8h4/bi.{3[/bj.l=l[3{3{3{3/ai.u3{3{3{3g=23{3{3{):)[3{3g8h8/bi.{3{u/bj.=l=t{3{3{3{/aj.u3{3{3{-l=23{3{3:):v{3{3g8}/bi.3{3wm/bj.=l=t{3{3{3/af.ueqdqdq{3{3g=l=[3{3{(:)13{3{3g4/bj.{3[/bj.l=ls3{3{3wuuuuudq0^^^jqdq+-l=lw{3{3{(:)[/bm.3{u/bk.=l[3{3{3uuuqdq/ai.^rd=l=23{3{3{):v/bm.{3wm/bk.=l[3{3wuuqd%/ak.^rd-l=[3{3{3{(1/bm.3{3[/bk.l=t{3{3uqd%/af.^y@y@^^^^d-lw{3{(:):([/bm.3{u/bk.=l=t{3{ud%^^^^^@y@y@y@^^^^d-lw{3:):):u/bm.{3wm/bk.=ls3{3gq/af.^yrdqdqt^^^^^d=23{):):)13{3{3{7h8h4{3{3{3h8h8{3{3{3[/bk.l=ls3{q0^^^^^z@duuuuq0^^^^rl=[3:):):)[3{3{3h8h8h4{3{3g8h8h8{3{3{u/bl.=l[3d%^^^^^@iquuuu[q^^^^j-lw{(:):):v{3{3g8h8h8h4{3{7h8h8h8{3{3wm/bl.=leq/af.^jqtuuuuue%^^^^+-23:):):)[3{3{7h8h8h8h4{3/bd.h8{3{3[/bl.l=t0/af.^rtuuuwuuu0^^^zr{-[(:):):v{3{3/bd.h8h4g/bd.8h8{3{u/bl.=lcq/af.^juuu[3uud%^^^^i3{u{):):)13{3{7/bi.h8h4{3wm/bl.=l0/af.^rtuu3{ueq^^^^z@+3{u:):):)[3{3g/bi.8h8}3{3[/bk.l=lcq/af.^duu3{3wut@^^^@iq{3w3:):):v{3{3/bj.h8{3{u/bl.=l0/af.^r{3{3{3uqy@^^y@+3{3[(:):)13{3{7/bi.h8h4{3wm/bk.=lcq/af.^d3{3{3wueqy@y@dq{3{udq:):)[3{3g/bi.8h8}3{3[/bk.l=lt/af.^r/bd.{3gqdqdq{3{3dqjq+):v{3{3/bj.h8{3{u/bk.=l=p%^^^^^j/be.3{3[3{3{3gq^^^r+)13{3{7/bi.h8h4{3wm/bk.=ld!/af.^+/be.3{3[3{3{q0^^^^r:)[3{3{7/bi.h8{3{3[/bk.l=p%^^^^^jq/bd.{3dqdqdqd3g!^^^^i3{u{3{3g/bi.8h4{3wm/bk.=lc!/af.^+/bd.3{q^^^^^@+3t@^^^@+3w3{3{3g/bh.8h8{3{3[/bk.l=lt/af.^r/bd.{3g%^^^^zr{qy@^^yr{3[3{3{3g/bg.8h8}3{3{u/bk.=l=p%^^^^^j/bd.3{q0^^^^@d3g!y@y@d3{u{3{3{3g/bg.8h4{3{3wm/bk.=ld!/af.^+3{3{3{3g%^^^^zr{3dqy@iq{3w3{3{3{q+7/be.h8h4{3{3{3[/bk.l=py/af.^r{3{3{3{q0^^^^^i3{qdqdqd3{qe/bd.qd3/bd.h8h4{3{3{3{u/bk.=lc!%^^^^^j3{3{3{3g%^^^^^@+3d%^^^@+3d%^^jq^^^^d3g8h8h8h4/bd.{3wm/bk.=lt@/af.^d3{3{3{q0^^^^^iq{q^^^^zr{q^^^^0^^^^^d3g8h8h8/be.{3[/bk.l=pt/ag.^+3{3{3g%^^^^^@+3g%^^^@d3g%/aj.^+3g8h8}/be.3{u/bk.=l=p%/af.^r{3{3{30^^^^^zr{30^^^zr{30^^^^@^^^^^r+3g8h4/be.{3wm/bk.=lc!%^^^^^jq{3{3gq/af.^i3gq^^^^i3gq^^^^y@^^^^zr{3g8/bf.{3[/bk.l=ld!/af.^j3{3{q0/af.^r+30^^^z@+30^^^zrt^^^^^i/bh.3{u/bl.=lt@/af.^d3{qd%/af.^iuwq^^^^iq{q^^^^iq%^^^^@+/bg.3{3wm/bk.=l=py/ag.^dqd%/ag.^@tud%^^^@+3d%^^zrd!^^^^yr/bh.{3[/bk.l=lcqy/aq.^jq=p^^^^zr{q^^^^d3t^^^^@d/bh.3{u/bl.=lc!%/ak.^%^^^^^+lc%^^^^d3g%^^^rgq%^^^zr/bh.{3wm/bl.=ld!%/ai.^yr^^^^zr=l0^^^^r{30^^^j3t@^^^@i/bh.3{3[/bl.l=ld!y/ag.^z@d%^^^^imcq^^^^i3gq^^^r+q%^^^zr+/bh.3{u/bm.=ldqy@^^^^z@yr^^^^^r+lt^^^^@tu0^^^j3d!^^^^i/bf.3{7{3{3wm/bm.=lcqt@y@y@yrd%^^^^im=p%^^^zr=p^^^^+qy^^^^@+/be.3{3h8{3{3[/bn.l=pd!y@yrdm0^^^^@+lc!^^^^imd%^^^rg!%^^^zr/be.{3g8h8{3{u/bn.=lcqdqdqdmcq^^^^jq=lt^^^^@dq^^^^j3t@^^^^jq+/bd.3{7h8h8{3wm/bm.=l=p0^^^dq=l0^^^^^+l=p%/aj.^@+qy/af.^r+3{3{3{3h8h8h8{3[/bm.l=ld%^^^^jq+p^^^^^r=lcq%/ai.^jqg!y^^^^^yr{3{3{3g8h8h8h8{u/bm.=lcq/ag.^rc%^^^^jm=lc!%^^^zr^^^@+3t@%^^^z@i3{3{3{7/bd.h8wm/bl.=l=p0/ag.^jq0^^^^r+l=ld!%^y@d%^^yr{qt@%^z@yr+3{3{3{7h8}7h8}3[/bl.l=lc%^^^^y@%^i%^^^^jm=l=ld!y@dqt@y@iuuqt@y@y@d/bd.3{7h4{7h4wm/bl.=l=p0^^^z@y@y@0^^^^^+l=l=ldqdqcqdqdq+l=pd!y@/ah.u[3{3{3{3wu/bm.=lc!^^^@y@d!yr^^^^jqdqdq+/bg.l=ldqdq/bd.=l/ah.u=/bm.l=lt^^^yrdqdqd%^^^@+pdqdq+/b5.l=p%^^^im=lcq^^^^iq=p+lcq/b5.=lc!^^^@+l=ld%^^^@+lcq=ldm/b5.=lt@^^zr=lcq^^^^yr=ldm=p+pdmcq+pdqdqdq=pdqdqdq=pdqcqdm/bp.=l=py^^^jm=p0^^^z@dm=pdqdqcq+ldqcqdqdqdqcqdqdqdqcqdmdq+/bp.l=lc!y^^^dqd%^^^@iq=lcqdq+lcq=ldmcq=p+ldmcq=p+ldmcq=ldm/bq.=ld!y/ai.^y@+l=ldqdm=ldm=p+ldmcq=p+ldmcq=p+ldqcq+/bq.l=ld!y@/af.^y@iq=l=p+pdm=p+lcq=p+ldmcq=p+ldmcq=ldqdm/br.=ldqy@y^z@y@dq+l=lcq=pdmcq=ldmcq=p+ldmcq=p+ldm=ldq+/br.l=lcqt@y@y@dq+l=l=pdmcqdmdqdq+pdmdqcq+pdmdqcq+l=ldm/bs.=l=pdqdqdqcm=l=lcq+ldq+ldqdmcq+pdmdqcq+pdmdq=l=p+/b$.l=ldmdq/b$.=l=pdq+/b%.l=pdm/b5q=lc"
 bit6to8(t, 24576)
end--main()

-- init global variables ------

function initglobal()
 chr6x,asc6x={},{}
 local b6=".abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()`~-_=+[]{};':,<>?"
 local i,c
  for i=0,63 do
   c=sub(b6,i+1,i+1)
   chr6x[i]=c asc6x[c]=i
  end  
 compressdepth=2
end--initglobal()

-- functions ------------------

-- convert integer a to char-6
function chr6(a)
 local r=chr6x[a]
 if (r=="" or r==nil) r="."
 return r
end--chr6(.)

-- test bit #b in a
function btst(a,b)
local r=false
 if (band(a,2^b)>0) r=true
 return r
end--btst(..)

-- return asc-6 of string a
-- from character position b
function fnca(a,b)
local r=asc6x[sub(a,b,b)]
 if (r=="" or r==nil) r=0
 return r
end--fnca(..)

-- return string a repeats of b
function strng(a,b)
local i,r=0,""
 for i=1,a do
  r=r..b
 end
 return r
end--strng(..)

-- convert compressed 6-bit
-- string to 8-bit binary
-- memory
function bit6to8(t,m)
local i,d,e,f,n,p=0,0,0,0,0,1
 repeat
  if sub(t,p,p)=="/" then
   d=fnca(t,p+1)
   e=fnca(t,p+2)+64*fnca(t,p+3)
   t=sub(t,1,p-1)..strng(e,sub(t,p+4,p+4+d-1))..sub(t,p+d+4)
   p+=d*e-1
  end
  p+=1
  until p>=#t
   p=1 d=0 e=0
   for i=1,#t do
    c=fnca(t,i)
    for n=0,5 do
     if (btst(c,n)) e+=2^d
     d+=1
     if (d==8) poke(m+f,e) d=0 e=0 f+=1
  end
 end
end--bit6to8(..)

-- convert 8-bit binary memory
-- area to compressed 6-bit
-- clipboard ready sourcecode
function bit8to6clip(i,m)
 bit8to6(i,m,0)
end--bit8to6clip(...)

-- convert 8-bit binary memory
-- area to compressed 6-bit
-- string or save to clipboard
function bit8to6(i,m,f)
local j,k,l,p,n,c,t=0,0,0,0,0,0,""
 m+=i-1
 for j=i,m do
  p=peek(j)
  for k=0,7 do
   if (btst(p,k)) c+=2^l
    l+=1 if (l==6 or (j==m and k==7)) t=t..chr6(c) c=0 l=0
   end
  end
 for i=1,compressdepth do
  j=1
  repeat
   c=sub(t,j,j+i-1) d=sub(t,j,j)
   n=0 p=j
    if d=="/" then
     j+=i+3
    else
     repeat
      ok=1
      if (c==sub(t,p,p+i-1)) n+=1 p+=i ok=0
       until ok==1 or n==4095
      end
      if n>0 and n!=nil then
       a="/"..chr6(i)..chr6(n%64)..chr6(flr(n/64))..c
      if #a<i*n then
       t=sub(t,1,j-1)..a..sub(t,j+i*n)
       j+=#a-1
      end
     end
     j+=1
    until j>#t-i
 end
 if f==0 then
  printh("t=\""..t.."\"\n","@clip")
 else
  return t
 end
end


__gfx__
00000000333333332222222299999999222222227777777722222333000000000077777777777777777777777777770000005555555555555555555000000000
00000000333333332222222299999999222222227777777722222333000000000766666666666666666666666666665000557777777777777777777550000000
00700700333333332222222299999999222222227777777722222333000000007666666666666666666666666666666505777777777777777777777775000000
00077000333333332222222299999999222222227777777722222333000000007666666666666666666666666666666557777777777777777777777777500000
00077000333333332222222299999999222222227777777722222333000000007666666666666666666666666666666557777777777777777777777777500000
00700700333333332222222299999999222222227777777722222333000000007666666666666666666666666666666557777777777777777777777777500000
00000000333333332222222299999999222222227777777722222333000000000566666666666666666666666666665057777777777777777777777777500000
00000000333333332222222299999999222222227777777722222333000000000055555555555555555555555555550057777777777777777777777775000000
00010000088088000008000000111000000c000000bbb000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaa0005777777777777777777777550000000
0011100088888880008880000011100000ccc00000bbb00000000000000000000a6666666666666666666666666666a000555777755555555555555000000000
011111000888880008888800111111100ccccc00bbbbbbb00000000000000000a666666666666666666666666666666a00005777500000000000000000000000
11111110008880008888888011111110ccccccc0bbbbbbb00000000000000000a666666666666666666666666666666a00005775000000000000000000000000
011111000008000008888800111111100ccccc00bbbbbbb00000000000000000a666666666666666666666666666666a00005750000000000000000000000000
0001000000000000008880000001000000ccc000000b00000000000000000000a666666666666666666666666666666a00005500000000000000000000000000
00111000000000000008000000111000000c000000bbb00000000000000000000a6666666666666666666666666666a000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaa0000000000000000000000000000000000
66333333666666663333335533333333333333566633333333333333333333330066666666666666666666666666660000666666666666666666666666666600
66333333666666663333335533333333333333666633333333333333333333330699999999999999999999999999995006bbbbbbbbbbbbbbbbbbbbbbbbbbbb50
6633333333333333333333553333333333333333333333333333333333333333699999999999999999999999999999956bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5
6633333333333333333333553333333333333333333333333333333333333333699999999999999999999999999999956bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5
6633333333333333333333553333333333333333333333333333333333333333699999999999999999999999999999956bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5
6633333333333333333333553333333333333333333333333333333333333333699999999999999999999999999999956bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5
66333333333333333333335555555555333333333333333355333333333333550599999999999999999999999999995005bbbbbbbbbbbbbbbbbbbbbbbbbbbb50
66333333333333333333335555555555333333333333333356333333333333550055555555555555555555555555550000555555555555555555555555555500
555555555777777755555555555555555555555577777777577777777777777500aaaaaaaaaaaaaaaaaaaaaaaaaaaa0000aaaaaaaaaaaaaaaaaaaaaaaaaaaa00
57777777577777777777777557777775777777777777777757777777777777750a9999999999999999999999999999a00abbbbbbbbbbbbbbbbbbbbbbbbbbbba0
5777777757777777777777755777775377777777777777775777777777777775a999999999999999999999999999999aabbbbbbbbbbbbbbbbbbbbbbbbbbbbbba
5777777757777777777777755777753377777777777777775777777777777775a999999999999999999999999999999aabbbbbbbbbbbbbbbbbbbbbbbbbbbbbba
5777777757777777777777755777533377777777777777775777777777777775a999999999999999999999999999999aabbbbbbbbbbbbbbbbbbbbbbbbbbbbbba
5777777757777777777777755775333377777777777777775777777777777775a999999999999999999999999999999aabbbbbbbbbbbbbbbbbbbbbbbbbbbbbba
57777777577777777777777557533333777777777777777757777777777777750a9999999999999999999999999999a00abbbbbbbbbbbbbbbbbbbbbbbbbbbba0
577777775555555577777775553333337777777755555555577777777777777500aaaaaaaaaaaaaaaaaaaaaaaaaaaa0000aaaaaaaaaaaaaaaaaaaaaaaaaaaa00
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
0000000001111111ff11111100000000000000000044fffffffff77000000000000000000044fffffffff77000000000000000000044fffffffff77000000000
0000000001111111111111110000000000000000044fffffffffff770000000000000000044fffffffffff770000000000000000044fffffffffff7700000000
0000000011111111ff111111100000000000000044fffffffffffff7700000000000000044fffffffffffff7700000000000000044fffffffffffff770000000
000000014fffffffffffffff71000000000000044fffffffffffffff77000000000000044ff444ffffff444f77000000000000044fffffffffffffff77000000
000000444ffffffffffffffff7700000000000444ff44ffffffff44ff7700000000000444444ffffffffff44f7700000000000444ffffffffffffffff7700000
0000004fffffffffffffffffff4000000000004fffff44fffff444ffff4000000000004ff4fffffffffffff4ff4000000000004fffffffffffffffffff400000
0000004fff44444ffff44444ff4000000000004ffffff444ff44ffffff4000000000004fffffffffffffffffff4000000000004fffffffffffffffffff400000
0000044fffffffffffffffffff4400000000044fffffffffffffffffff4400000000044fffffffffffffffffff4400000000044fffffffffffff444fff440000
0000044ffff177ffffff177ffff700000000044ffff777ffffff777ffff700000000044ffff777ffffff777ffff7000000000441ff44444fff44fff4ff170000
0000044ffff777ffffff777ffff700000000044ffff717ffffff717ffff700000000044ffff717ffffff717ffff700000000044f1ff717fffff717fff1f70000
0000044ffffffffffffffffffff700000000044ffffffffffffffffffff700000000044ffff777ffffff777ffff700000000044ff1111111ff1111111ff70000
0000044ffffffffffffffffffff700000000044ffffffffffffffffffff700000000044ffffffffffffffffffff700000000044fff11111111111111fff70000
0000044ffffffffffffffffffff700000000044ffffffffffffffffffff700000000044ffffffffffffffffffff700000000044fff111111ff111111fff70000
0000044fffffffff44fffffffff700000000044fffffffff44fffffffff700000000044fffffffff44fffffffff700000000044fffffffff44fffffffff70000
0000004fffffffffffffffffff4000000000004fffffffffffffffffff4000000000004fffffffffffffffffff4000000000004fffffffffffffffffff400000
00000044ffffffffffffffffff40000000000044ffffffffffffffffff40000000000044ffffffffffffffffff40000000000044ffffffffffffffffff400000
00000044ffffff4444ffffffff40000000000044ffffffffffffffffff40000000000044ffffffff44ffffffff40000000000044fffff44444444fffff400000
000000044fffffffff4ffffff4000000000000044fffff444444fffff4000000000000044ffffff4444ffffff4000000000000044fffff477774fffff4000000
0000000044ffffffffffffff400000000000000044fff4ffffff4fff400000000000000044fffff4444fffff400000000000000044fffff4444fffff40000000
00000000044ffffffffffff40000000000000000044ffffffffffff40000000000000000044fffff44fffff40000000000000000044fffff44fffff400000000
000000000044ffffffffff4000000000000000000044ffffffffff4000000000000000000044ffffffffff4000000000000000000044ffffffffff4000000000
0000000000044fffffff4400000000000000000000044fffffff4400000000000000000000044fffffff4400000000000000000000044fffffff440000000000
00000000000004444444000000000000000000000000044444440000000000000000000000000444444400000000000000000000000004444444000000000000
__map__
2723232323232323260101010101010100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2202020202020202203034343434320100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2202020202020202203605050505370100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2202020202020202203135353535330100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2202029d9e9f0202200101010101010100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22028dadaeaf8f02200101010101010100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22028ebdbebf8e02200101010101010100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2202020202020202200101010101010100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2421212121212121250101010101010100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01020304

