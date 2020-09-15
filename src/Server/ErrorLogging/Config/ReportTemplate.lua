--[[
  Supported fields are as follows:
  <COLOR>
  <GAMENAME>
  <GAMELINK>
  <ERRORMESSAGE>
  <LABELS>
  <FOOTER>
  <TIMESTAMP>
]]

return [[{
  "color": "<COLOR>",
  "title": "An error has occurred in <GAMENAME>",
  "title_link": "<GAMELINK>",
  "text": "```\n<ERRORMESSAGE>\n```\n<LABELS>",
  "footer": "<FOOTER>",
  "ts": <TIMESTAMP>
}
]];
