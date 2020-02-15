local bullet = require("src.entities.projectiles.bullet")

local silverbullet = bullet:subclass("SilverBullet")

function silverbullet:init(...)
    bullet.init(self, ...)

    self.color = {1, 1, 1}
    self.basedamage = 6
end

return silverbullet