--thank you chatgpt
SMODS.Joker {
    key = "you_broke_it",
    config = {
      extra = {

      current_rank_key = 'Ace',
      current_rank_name = localize('Ace', 'ranks'),
      current_enhancement_key = 'm_bonus', 
      current_enhancement_name = localize{type = 'name_text', set = 'Enhanced', key = 'm_bonus'},
      
      enhancement_pool = (function()
          local pool = {}
          for k, v in pairs(G.P_CENTERS) do
              if v.set == 'Enhanced' and k ~= 'c_base' then 
                  pool[#pool+1] = k
              end
          end
          return pool
      end)()
      }
    },
    loc_txt = {
      name = "You Broke It!",
      text ={
          "Turns every scored {C:attention}#1#{} into a",
          "{C:attention}#2#{}. Rank and",
          "Enhancement change when",
          "selecting {C:attention}blind{}"
      },
  },
    rarity = 2,
    pos = { x = 24, y = 8},
    atlas = 'joker_atlas',
    cost = 4,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
  
    loc_vars = function(self, info_queue, card)
      return {vars = {
        card.ability.extra.current_rank_name,
        card.ability.extra.current_enhancement_name,
    }}
    end,
  
    calculate = function(self, card, context)

    if context.setting_blind and not context.blueprint then
      
      local ranks = {'2','3','4','5','6','7','8','9','T','J','Q','K','A'}
      local new_rank_key = card.ability.extra.current_rank_key
      
      local attempts = 0
      while new_rank_key == card.ability.extra.current_rank_key and attempts < 5 do
          new_rank_key = pseudorandom_element(ranks, pseudoseed('broken_rank_'..G.GAME.round_resets.ante))
          attempts = attempts + 1
      end
      card.ability.extra.current_rank_key = new_rank_key
      card.ability.extra.current_rank_name = localize(G.P_CARDS['S_'..new_rank_key].value, 'ranks') -- Get localized name

      
      local new_enhancement_key = card.ability.extra.current_enhancement_key
      attempts = 0
      while new_enhancement_key == card.ability.extra.current_enhancement_key and attempts < 5 do
           new_enhancement_key = pseudorandom_element(card.ability.extra.enhancement_pool, pseudoseed('broken_enhance_'..G.GAME.round_resets.ante))
           attempts = attempts + 1
      end
      card.ability.extra.current_enhancement_key = new_enhancement_key
      card.ability.extra.current_enhancement_name = localize{type = 'name_text', set = 'Enhanced', key = new_enhancement_key}
  end

  
  if context.before and context.scoring_hand and not context.blueprint then
    local transformed_card = false
      local target_rank_name = card.ability.extra.current_rank_name
      local target_enhancement_key = card.ability.extra.current_enhancement_key
      local target_enhancement_center = G.P_CENTERS[target_enhancement_key]

      if target_enhancement_center then
          for i, scored_card in ipairs(context.scoring_hand) do
              
              if scored_card.base.value == target_rank_name and scored_card.config.center == G.P_CENTERS.c_base then
                  
                  scored_card:set_ability(target_enhancement_center, nil, true)
                  
                  G.E_MANAGER:add_event(Event({
                    func = function()
                          card:juice_up()
                          if scored_card and not scored_card.removed then scored_card:juice_up(0.4, 0.3) end
                          return true
                      end
                  }))
                  transformed_card = true
              end
          end
      end
      if transformed_card then
        local enhancement_key = card.ability.extra.current_enhancement_key
        local enhancement_name = localize{type = 'name_text', set = 'Enhanced', key = enhancement_key}

        -- Determine color based on enhancement (optional but nice)
        local message_colour = G.C.SECONDARY_SET.Enhanced -- Default
        if enhancement_key == 'm_bonus' or enhancement_key == 'm_stone' or enhancement_key == 'm_wild' then
            message_colour = G.C.CHIPS
        elseif enhancement_key == 'm_mult' then
            message_colour = G.C.MULT
        elseif enhancement_key == 'm_glass' or enhancement_key == 'm_steel' or enhancement_key == 'm_wild' then
            message_colour = G.C.JOKER_GREY -- Or another distinct color like G.C.JOKER_GREY
        elseif enhancement_key == 'm_gold' or enhancement_key == 'm_lucky' then
            message_colour = G.C.MONEY
        end
        -- Wild Card is excluded, so no need for a specific check

        return {
            -- Use the localized name of the enhancement, maybe add "!"
            message = enhancement_name, -- <<< CHANGE HERE
            colour = message_colour         -- <<< CHANGE HERE (using determined color)
        }
    end
  end
end,
   
  }