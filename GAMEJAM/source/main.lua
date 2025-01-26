#Made by Lucas Ebrenz to Global Game Jam January, 22 2024  Ingresso:2LGMD8DKZQG
-- O correto seria no main existirem chamadas aos arquivos, mas por começo ruim estamos como estamos.
screenWidth = 800
screenHeight = 800
windowTitle = "BUBBLE: U.S. NAVY SEALS"

local endScreen = require'end'
local menuScreen = require'menu'
local inGame = require'inGame'
score = 0
game_state = menuScreen

--Carregando tudo
function love.load ()
  menuScreen.load()
  endScreen.load()
  inGame.load()
end


-- Funcao desenhara no love
function love.draw ()
  game_state.draw()
end

function love.start()
  if game_state.start then game_state.start() end
end

-- Funcao update do LOVE2D: possui atualização de infos 
function love.update(dt)
  if game_state.update then game_state.update(dt) end
  --print("Current game_state:", type(game_state))
end

function love.mousepressed(x, y, button, istouch)
  if game_state.mousepressed then game_state.mousepressed(x, y, button, istouch) end
end

function love.mousemoved(x,y,dx,dy,istouch)
  if game_state.mousemoved then game_state.mousemoved(x,y,dx,dy,istouch) end
end

function love.keypressed(key)
  if game_state.keypressed then game_state.keypressed(key) end
end

-- Evita que processo continue, precisando abater via gerenciador de tarefas.
function love.quit()
  os.exit()
end

function setState(state)
  game_state = state
  if game_state.start then game_state.start() end
end

function setGame()
  setState(inGame)
end

function setMenu()
  setState(menuScreen)
end

function setEnd()
  setState(endScreen)
end