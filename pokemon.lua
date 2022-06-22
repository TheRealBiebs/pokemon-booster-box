num_cards_in_booster_pack = 0 -- calculated automatically

card_pack_obj_URL = "http://cloud-3.steamusercontent.com/ugc/1030707316751677470/50A2B45A59B53E7C4AEC8CFE47E84DF3604F8BBE/"
card_packs = {
          "http://cloud-3.steamusercontent.com/ugc/1030707316751680694/3237364EE48149F31EE8898AE6B8B45769FD642F/", --charizard
          "http://cloud-3.steamusercontent.com/ugc/1030707353544412513/30A985AFED56000709109405810B725D7D8B7276/", --venusaur
          "http://cloud-3.steamusercontent.com/ugc/1030707353544445111/CF469A6D4FA72FB77F594DE324402DCBBB498E7F/" --blastoise
        }
num_commons_per_pack = 6
num_uncommons_per_pack = 3
num_rares_per_pack = 1
num_energy_per_pack = 1
booster_pack_rows = 4
booster_pack_columns = 9
deal_wait_time = 1 -- lower = faster. 1 is recommended to make all cards into a single stack inside the pack. higher lets them separate
-- init_x, y, and z indicate the position of lower-left-most pack
-- xdelta indicates horizontal spacing
-- zdelta indicates vertical spacing
booster_pack_pos_init_x = self.getPosition().x + 12
booster_pack_pos_init_y = 2 --height
booster_pack_pos_init_z = self.getPosition().z - 10
booster_pack_pos_xdelta = 3
booster_pack_pos_zdelta = 4
booster_pack_pos = nil
--paused = false
creating = false
in_queue = 0
pack_obj_name = "Base Set Booster"

function onload()



    local btn = {}
    btn.click_function = "createBoosterPack"
    btn.function_owner = self
    btn.label = "Fill Box"
    btn.width = 2200
    btn.height = 1300
    btn.font_size = 700
    btn.rotation = {90, 180, 0}
    btn.position = {0,2.5,3}


    self.createButton(btn)
end


function createBoosterPack(GO)
	if creating == false then
		creating = true
	    startLuaCoroutine(self, "createBoosterPackCoroutine")
	else
        printToAll("Please wait!", {0, 1, 0})
	end
end

function createBoosterPackCoroutine()
  common_deck_bag = getObjectFromName("Common Bag")
  uncommon_deck_bag = getObjectFromName("Uncommon Bag")
  rare_deck_bag = getObjectFromName("Rare Bag")
  holo_deck_bag = getObjectFromName("Holo Bag")
  energy_deck_bag = getObjectFromName("Energy")


    common_deck_pos = common_deck_bag.getPosition()
    uncommon_deck_pos = uncommon_deck_bag.getPosition()
    rare_deck_pos = rare_deck_bag.getPosition()
    holo_deck_pos = holo_deck_bag.getPosition()
    energy_deck_pos = energy_deck_bag.getPosition()

    num_commons_per_pack = getObjectFromName("Commons").getValue()
    num_uncommons_per_pack = getObjectFromName("Uncommons").getValue()
    num_rares_per_pack = getObjectFromName("Rares").getValue()
    holo_odds = getObjectFromName("Holo Odds").getValue()
    num_energy_per_pack = getObjectFromName("Energies").getValue()
    num_cards_in_booster_pack = 0 -- reset this


    booster_index = 0
    array_of_boosters = {}
    for i=1,booster_pack_columns do
        for j=1,booster_pack_rows do
            booster_pack_pos = {booster_pack_pos_init_x - booster_pack_pos_xdelta * (i-1), booster_pack_pos_init_y, booster_pack_pos_init_z - booster_pack_pos_zdelta * (j-1)}
            booster = spawnRandomCardPack(booster_pack_pos)
            local common_deck = takeDeck(common_deck_bag, common_deck_pos)
            local uncommon_deck = takeDeck(uncommon_deck_bag, uncommon_deck_pos)
            local rare_deck
            if math.random(1,holo_odds)==1 then
                rare_deck = takeDeck(holo_deck_bag, holo_deck_pos)
            else
                rare_deck = takeDeck(rare_deck_bag, rare_deck_pos)
            end
            local energy_deck = takeDeck(energy_deck_bag, energy_deck_pos)



            dealFromThenDestroy(common_deck, num_commons_per_pack,booster )
            dealFromThenDestroy(uncommon_deck, num_uncommons_per_pack, booster)
            dealFromThenDestroy(rare_deck, num_rares_per_pack, booster)
            dealFromThenDestroy(energy_deck, num_energy_per_pack, booster)


        end
    end

    creating = false

    waitFrames(100) --wait for everything to settle before scooping

    scoopUpPacks()


    return 1
end

function scoopUpPacks()
  booster_box = self
  local allObjects = getAllObjects()
  --And look through them for the name
  for _, booster_pack_obj in ipairs(allObjects) do
      if booster_pack_obj.getName() == pack_obj_name then
          booster_box.putObject(booster_pack_obj)
          waitFrames(2)
      end
  end
end

function takeDeck(bag, pos)
    local p = {}

    p.rotation = {0, 180, 180}

    p.position = pos

    local deck = bag.takeObject(p)


    return deck
end

function dealFromThenDestroy(deck, amt, booster)
    num_cards_in_booster_pack = num_cards_in_booster_pack + amt
    deck.shuffle()
    local p = {}
    p.position = booster_pack_pos
    p.rotation = {180, 0, 0}
    for i=1,amt do
        local obj = deck.takeObject(p)
        waitFrames(deal_wait_time)


    end

    waitFrames(deal_wait_time)
    deck.destruct()
end


function waitFrames(frames)
    while frames > 0 do
        coroutine.yield(0)
        frames = frames - 1
    end
end

function spawnRandomCardPack(pos)
    local toolPos = self.getPosition()
    local obj = spawnObject({
        type="Custom_Model",
        position=pos,
        scale={1,1,1}, --(shrinking it down a bit)
        rotation = {0,180,0}
    })

    obj.setCustomObject({
        type=6,
        mesh = card_pack_obj_URL,
        diffuse = card_packs[math.random(1,3)],
        specular_intensity=0,
        material = 3
    })
    obj.setName(pack_obj_name)
end

function getObjectFromName(name)
  local allObjects = getAllObjects()
  for _, object in ipairs(allObjects) do
      if object.getName() == name then
          return object
      end
  end
end