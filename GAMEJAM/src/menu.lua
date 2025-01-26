
local menu = {}

-- Menu
local menuStartHover = false
local menuExitHover = false
local backgroundVideo

function menu.load()
  love.window.setTitle( windowTitle )
  love.window.setMode( screenWidth, screenHeight) -- Tela tem 800 de largura e 860 de largura
  love.graphics.setBackgroundColor(0,0,0) -- background

  --Fontes
  menuStartFont = love.graphics.newFont("A love of Thunder.ttf", 72 ) -- Fonte para o botao de start do menu
  menuOptionsFont = love.graphics.newFont("A love of Thunder.ttf", 48 ) -- Fonte para as outras opcoes do menu
  
  --Bolha
  bolha = love.graphics.newImage("hero.png")
  
   -- Vídeo de fundo
  backgroundVideo = love.graphics.newVideo("love (1).ogv", {loop = true}) -- Carrega o vídeo e ativa o looping
  backgroundVideo:play() -- Começa a reprodução do vídeo
  
  --Song
  backgroundSong0 = love.audio.newSource("backgroundSong0.mp3", "stream")
  buttonSound =  love.audio.newSource("buttonSelect.wav", "static")
end

function menu.update(dt)

end

function menu.draw()
  --Menu
  -- Background
  love.audio.play(backgroundSong0)
  if backgroundVideo then
    love.graphics.draw(backgroundVideo, 0, 0, 0, screenWidth / backgroundVideo:getWidth(), screenHeight / backgroundVideo:getHeight() )
  end
  
  
  --  Start
  if menuStartHover == false then
    love.graphics.setFont(menuStartFont)
    love.graphics.setColor(1,1,1) -- white
    love.graphics.print( "Kill", 100, 100  )
  else
    love.graphics.setFont(menuStartFont)
    love.graphics.setColor(1,0,0) -- red
    love.graphics.print( "Kill", 100, 100  )
  end
  
  
  --  Exit
  if menuExitHover == false then
    love.graphics.setFont(menuOptionsFont)
    love.graphics.setColor(1,1,1) -- white
    love.graphics.print( "Exit", 100, 200  )
  else
    love.graphics.setFont(menuOptionsFont)
    love.graphics.setColor(1,0,0) -- red
    love.graphics.print( "Exit", 100, 200  )
    love.graphics.setColor(1,1,1) -- red
    
  end
end

-- Função que lida com cliques do mouse
function menu.mousepressed(x, y, button, istouch)
    -- Menu
    --   Red Start
    if ( (x> 100 and x<250) and  (y>110 and y< 180) ) then
      backgroundSong0:stop()
      love.audio.play(buttonSound)
      --dofile('inGame.lua')
      setGame()
    end
    --  Red exit
     if ( (x> 100 and x<204) and  (y>207 and y< 250) ) then
       love.audio.play(buttonSound)
       love.quit()
    end
     
    
end

function menu.mousemoved(x,y,dx,dy,istouch)
    if ( (x> 100 and x<250) and  (y>110 and y< 180) ) then
        menuStartHover = true
    else
        menuStartHover = false
    end
    if ( (x> 100 and x<204) and  (y>207 and y< 250) ) then
        menuExitHover = true
    else
        menuExitHover = false
    end
  
end

return menu