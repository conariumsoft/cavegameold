local guiutil = require("src.guiutil")
local floating_text = require("src.entities.floatingtext")

local item_pickup = floating_text:subclass("ItemPickupText")

function item_pickup:init(item_name, amount, color)
    local name = item_name

    self.name = item_name
    self.amount = amount
    if amount > 1 then
        name = name .. " x"..amount
    end
    floating_text.init(self, name, color, guiutil.fonts.font_6)
end

function item_pickup:update(dt)
    floating_text.update(self, dt)
    for _, entity in pairs(self.world.entities) do
        if entity:isA("ItemPickupText") and entity ~= self then
            if self.position:distance(entity.position) < 30 then
                if self.name == entity.name and self.age < entity.age then
                    self.amount = self.amount + entity.amount
                    self.text = self.name.." x"..self.amount
                    entity.dead = true
                end
            end
        end
    end
end

return item_pickup