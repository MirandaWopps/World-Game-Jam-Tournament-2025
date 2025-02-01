local plane = require("plane")
local data = require("data") 
--local enemy = require("enemy")
local flash = require("flash")
local enemy = require("enemy")


-- Screen
local screenWidth = 800
local screenHeight = 800

local inGame = {}

-- Fontes
font = love.graphics.newFont( "A Love of Thunder.ttf" , 48)

-- Color
goldColor = {1, 0.84, 0} -- RGB para dourado (255, 215, 0)

-- Scores
highScore = 0
roundScore=0
gold = 0 
-- Airstrike ball
local ballRadius = 20 -- Tamanho da bola de airstrike
local ballX, ballY = 100,100 -- Posição da bola (baixo da tela)

-- Keys
keyUltimate = 'z' 


-- Bolha
local bolhas = {}

--Essa bolha a bIXO E SPAWNADA JA NO COMEÇO, podemos fazer um squad de 3 ja decomeco. Varia --de sua criatividade.
--bolhas[2] = {
--  x = 400, y = 300
-- }

local bolhaImage = love.graphics.newImage("hero.png")
local bolhaSpeed = 50 -- Velocidade da bolha (em pixels por segundo)



-- Tiros
local shots = {}
local shotSpeed = 700
local shotRadius = 5

local backgroundSong1, ar15Sound, airplaneSound, explosionSound


function inGame.load()
    
    -- Songs
    backgroundSong1 = love.audio.newSource("seals3 maintheme.mp3", "stream")
    ar15Sound = love.audio.newSource("ar15 rajada.wav", "static")
    airplaneSound = love.audio.newSource("airstrike plane.wav", "static")
    explosionSound = love.audio.newSource("airstrike explosion.wav","static")
    
    
 end

-- Função para atualizar e salvar o high score, se necessário
local function updateHighScore()
    if roundScore > highScore then
        highScore = roundScore
        data.setHighScore(highScore)
    end
    return highScore
end

function inGame.start()
  love.audio.play(backgroundSong1)
  bolhas = {}
  bolhas[1] = {
    x = 400, y = 300,
    keyLeft = 'a',
    keyRight = 'd',
    keyDown = 's',
    keyUp = 'w'
  }
  enemy.start()
  enemies = enemy.getEnemies()
  shots = {}
  roundScore = 0 
  highScore = data.getHighScore()
  gold = data.getGold()
end


-- Explosions
--Tabela para armazenar explosões
local explosions = {}
local pendingExplosions = {} -- Explosões com delay
-- Função para criar uma explosão após um delay
local function scheduleExplosion(x, y, delay)
  table.insert(pendingExplosions, {
    x = x,
    y = y,
    delay = delay, -- Tempo de espera
    timer = 0      -- Tempo acumulado
  })
end
-- Atualizar explosões pendentes (com delay)
local function updatePendingExplosions(dt)
  for i = #pendingExplosions, 1, -1 do
    local pending = pendingExplosions[i]
    pending.timer = pending.timer + dt -- Incrementa o tempo acumulado

    -- Se o delay terminar, mova para a lista de explosões ativas
    if pending.timer >= pending.delay then
      table.insert(explosions, {
        x = pending.x,
        y = pending.y,
        radius = 0.0,
        maxRadius = 200.0,
        speed = 500
      })
      table.remove(pendingExplosions, i) -- Remove da lista de pendentes
    end
  end
end


function newBolha(targetX, targetY)
  table.insert(bolhas, {x=targetX, y=targetY})
end

-- Função para atirar
function shoot(targetX, targetY)
  for _,bolha in ipairs(bolhas) do
    local dx = targetX - bolha.x
    local dy = targetY - bolha.y
    local distance = math.sqrt(dx^2 + dy^2)
      local shot = {
        x = bolha.x,
        y = bolha.y,
        dx = (dx / distance) * shotSpeed,
        dy = (dy / distance) * shotSpeed
      }
      table.insert(shots, shot)
    -- Reproduz som do tiro
    ar15Sound:stop()
    ar15Sound:play()
  end
end



-- Função que desenha tudo
function inGame.draw()
  --Desenha avioes
  plane.draw()
  
  
  -- Desenhar explosões
  for _, explosion in ipairs(explosions) do
    love.graphics.setColor(1, 0, 0) -- Cor vermelha
    love.graphics.setLineWidth(2) -- Espessura da linha
    love.graphics.circle("line", explosion.x, explosion.y, explosion.radius)
    love.graphics.setColor(1, 1, 1) -- Resetar cor
  end
  
  -- Score
  love.graphics.setColor(goldColor)
  love.graphics.print("Score: " .. roundScore .. " | Gold: "..gold, font, 0, 10)
  love.graphics.setColor(1,1,1)
  love.graphics.print("Airstrike:",font,0,60)
  
  if plane.isAirstrikeUp() == true then
      love.graphics.setColor(0, 1, 0) -- Verde
  else
      love.graphics.setColor(1, 0, 0) -- Vermelha
  end
  love.graphics.circle("fill",280,85, 20 ,70)
  love.graphics.setColor(1,1,1) -- evitar problema
  
  -- Desenhar a bolha
  for _, bolha in ipairs(bolhas) do
      love.graphics.draw(bolhaImage, bolha.x, bolha.y)
  end


  enemy.draw()

  -- Desenhar os tiros
  for _, shot in ipairs(shots) do
    love.graphics.setColor(1, 1, 0,1) -- Cor amarela
    love.graphics.circle("fill", shot.x, shot.y, shotRadius) -- Tiro como um círculo
    love.graphics.setColor(1, 1, 1) -- Reseta a cor
  end

  flash.draw()
end

-- Função update: atualiza a posição da bolha, inimigos e tiros
function inGame.update(dt)
  -- Atualizar aviões
  plane.update(dt)
  -- Verificar coleta de aviões
  plane.checkCollection(bolhas)

  
  -- Explosoes
  -- Atualizar explosões pendentes (com delay)
  updatePendingExplosions(dt)

  -- Atualizar explosões ativas
  for i = #explosions, 1, -1 do
    local explosion = explosions[i]
    explosion.radius = explosion.radius + explosion.speed * dt
    love.audio.play(explosionSound)

    -- Verificar colisão com inimigos
    for j = #enemies, 1, -1 do
      local enemy = enemies[j]
      local dx = explosion.x - enemy.x
      local dy = explosion.y - enemy.y
      local distance = math.sqrt(dx^2 + dy^2)    
      if distance < explosion.radius + enemy.width / 2 then
        table.remove(enemies, j)-- Remove inimigo
        roundScore = roundScore + 1 -- Incrementa score
        gold = gold + 10        -- Incrementa gold
        data.addGold(10)
      end
    end
    -- Remover explosão quando atingir o tamanho máximo
    if explosion.radius >= explosion.maxRadius then
      table.remove(explosions, i)
    end
  end


  flash.update(dt)


  -- Controle de Movimento da Bolha
  for _,bolha in ipairs(bolhas) do
  -- Movimento da bolha com teclas W, A, S, D
    if bolha.keyUp and love.keyboard.isDown(bolha.keyUp) then
      bolha.y = bolha.y - bolhaSpeed * dt
    end
    if bolha.keyDown and love.keyboard.isDown(bolha.keyDown) then
      bolha.y = bolha.y + bolhaSpeed * dt
    end
    if bolha.keyLeft and love.keyboard.isDown(bolha.keyLeft) then
      bolha.x = bolha.x - bolhaSpeed * dt
    end
    if bolha.keyRight and love.keyboard.isDown(bolha.keyRight) then
      bolha.x = bolha.x + bolhaSpeed * dt
    end
    -- Limitar a bolha dentro da tela
    bolha.x = math.max(0, math.min(bolha.x, screenWidth - 20))
    bolha.y = math.max(0, math.min(bolha.y, screenHeight - 21))
  end
 

    -- Atualiza os inimigos
    enemy.update(dt, bolhas)

    -- Verifica se precisa spawnar uma onda de inimigos
    enemy.checkWave(roundScore)


  -- Detecao de inimigo em colisao com as bolhas
  for i=#bolhas,1,-1 do
    local bolha = bolhas[i]
    for _, enemy in ipairs(enemies) do
      local dx = bolha.x - enemy.x
      local dy = bolha.y - enemy.y
      local distance = math.sqrt(dx^2 + dy^2)
      -- Verificar colisão: distância é menor que o raio da bolha + raio do inimigo)
      if distance < (20 + 33 / 2) then
        -- Colisão ocorreu, jogo termina/ morte/ game over
        if i==1 then -- tratando da first bubble
          love.audio.stop(backgroundSong1)
         
          setEnd()
        else
          table.remove(bolhas,i)
        end
        break
      end
    end
  end


  -- Tiros
  --Atualizar a posição dos tiros
  for i = #shots, 1, -1 do -- indo de tras para frente
    local shot = shots[i] -- pegando um tiro específico
    shot.x = shot.x + shot.dx * dt -- isso faz a locomoção no x
    shot.y = shot.y + shot.dy * dt -- isso faz a locomoção no y

    -- Remover tiros fora da tela
    if shot.x < 0 or shot.x > screenWidth or shot.y < 0 or shot.y > screenHeight then -- verifica se o tiro ta fora da tela
      table.remove(shots, i)
    else
      -- Verifica colisão entre tiros e inimigos
      local enemyList = enemy.getEnemies()
      for j = #enemyList, 1, -1 do
        local currentEnemy = enemyList[j]
        local dx = shot.x - currentEnemy.x
        local dy = shot.y - currentEnemy.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist < currentEnemy.radius + shotRadius  then
          -- Remover o inimigo e o tiro
          table.remove(enemy.getEnemies(), j)
          -- table.remove(shots, i) -- remove inimigo e tiro, mas uma ar-15 penetra 7 cadávers ou mais
          -- Incrementar o score
          roundScore = roundScore + 1
          gold = gold + 10
          data.addGold(10)
          -- Reproduzir um som de abate
          -- love.audio.play(killSound)
          break
        end
      end
    end
  end

end

function inGame.keypressed(key)
    if key == 'space' then
        if gold >= 100 then       
           newBolha(bolhas[1].x, bolhas[1].y)
            gold = gold - 100
            data.addGold(-100)
        end
    end
  
    -- Consumir ultimate
    if key == 'z' then
      if plane.isAirstrikeUp() == true then
        local mouseX, mouseY = love.mouse.getPosition() -- Obtém posição do mouse
        love.audio.play(airplaneSound)
        scheduleExplosion(mouseX, mouseY, 5)  -- Cria explosão na posição do mouse
        plane.resetAirstrike()
      end
    end
    
    if key == 'escape' then -- voltamos para o menu, mudando o esstado atraves da f. globl
       setMenu() 
     end
end

-- Detecta cliques do mouse para atirar
function inGame.mousepressed(x, y, button)
  if button == 1 then
    shoot(x, y)
  end
end

return inGame