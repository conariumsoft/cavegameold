local illegal = {
	"\"", "%<", "%>", "%+", "%-", "%*",  "%%", "%$", "#", "@", "!", "{", "}", "|", "\\",
	"/", ";", ":", "'", "`", "~", "%(", "%)", "%&", "%^"
}

local function sanitize(str)

	for _, char in pairs(illegal) do
		str = str:gsub(char, "_")
	end

	return str
end

local bad = "fuck you nigga <> _+ :; fatass()\"nigga$^&*$#@!{}''balls"

print(sanitize(bad))