local plane = require("plane")
local data = require("data") 
--local enemy = require("enemy")
local flash = require("flash")

-- Screen
local screenWidth = 800
local screenHeight = 800

local inGame = {}

-- Fontes
font = love.graphics.newFont( "A Love of Thunder.ttf" , 48)

-- Color
goldColor = {1, 0.84, 0} -- RGB para dourado (255, 215, 0)


-- Valores dinamicos a serem mudados
local totalTime = 0 -- Tempo total acumulado do jogo

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


-- Enemies
local enemyImg = love.graphics.newImage("enemy.png")
local enemyBanzai = love.graphics.newImage("enemyBanzai.png")
local enemyWidth = enemyImg:getWidth()
local enemyHeight = enemyImg:getHeight()
local enemyRadius = enemyWidth/2
local enemies = {} -- Tabela para armazenar os inimigos
local enemySpawnTimer = 0 -- Tempo para gerar novos inimigos
local enemySpeed = 200 -- Velocidade dos inimigos
local lastWaveScore = 0 -- gigawave


-- Tiros
local shots = {}
local shotSpeed = 700
local shotRadius = 5

local backgroundSong1, ar15Sound, banzaiSound, airplaneSound, explosionSound


function inGame.load()
    
    -- Songs
    backgroundSong1 = love.audio.newSource("seals3 maintheme.mp3", "stream")
    ar15Sound = love.audio.newSource("ar15 rajada.wav", "static")
    banzaiSound = love.audio.newSource("banzai.mp3", "static")
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
  enemies = {}
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

--[[
-- Flash 
local flashDuration = 1.5 -- Duração total do flash (subida e descida)
local flashAlpha = 0 -- Opacidade atual do flash
local flashActive = false -- Indica se o flash está ativo
local flashStep = 0 -- Controle para o aumento/diminuição da opacidade

-- Função para ativar o flash
function triggerFlash()
  if not flashActive then
    flashActive = true
    flashStep = 1 / (flashDuration / 2) -- Calcula a velocidade da transição
  end
end ]]


-- Função para gerar coordenadas aleatórias para spawn de inimigos fora da tela
function coordRandomizer()
  local numero
  if math.random() < 0.5 then
    numero = math.random(-200, -50)
  else
    numero = math.random(screenWidth + 50, screenWidth + 200)
  end
  return numero
end


-- Função para gerar inimigos
local function spawnEnemy()
  local enemy = {}
  if math.random() < 0.5 then
    enemy.x = coordRandomizer()
    enemy.y = math.random(0, screenHeight)
  else
    enemy.x = math.random(0, screenWidth)
    enemy.y = coordRandomizer()
  end
  enemy.width = enemyWidth
  enemy.height = enemyHeight
  enemy.radius = enemyWidth/2
  enemy.type = 1
  table.insert(enemies, enemy)
end


-- Função para gerar 10 inimigos de um lado específico
local function spawnWave()
  -- Escolher aleatoriamente o lado da tela
  local sides = {"left", "right", "top", "bottom"}
  local waveSide = sides[math.random(#sides)]
  -- Gerar 10 inimigos
  enemyImg = love.graphics.newImage("enemyBanzai.png") -- banzai gear
  for i = 1, 10 do
    local enemy = {}
    if waveSide == "left" then -- esquerda da tela
      enemy.x = -50 
      enemy.y = math.random(0, screenHeight) +(i*7)
    elseif waveSide == "right" then -- direita da tela
      enemy.x = screenWidth + 50 
      enemy.y = math.random(0, screenHeight) +(i*7)
    elseif waveSide == "top" then -- topo da tela
      enemy.x = math.random(0, screenWidth) +(i*7)
      enemy.y = -50
    elseif waveSide == "bottom" then -- baixo da tela
      enemy.x = math.random(0, screenWidth) +(i*7)
      enemy.y = screenHeight + 50
    end
    enemy.width = enemyWidth
    enemy.height = enemyHeight
    enemy.radius = enemyWidth/2 
    enemy.type = 2
    table.insert(enemies, enemy) -- insercao na table
  end
  -- volta ao que era
  enemyImg = love.graphics.newImage("enemy.png")
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


  -- Desenhar os inimigos
  for _, enemy in ipairs(enemies) do
    if enemy.type == 1 then
        love.graphics.draw(enemyImg, enemy.x, enemy.y, 0, 1, 1, enemy.width/2, enemy.height/2)
    else
        love.graphics.draw(enemyBanzai, enemy.x, enemy.y, 0, 1, 1, enemy.width/2, enemy.height/2)
    end
  end
  --draw.enemy()

  -- Desenhar os tiros
  for _, shot in ipairs(shots) do
    love.graphics.setColor(1, 1, 0,1) -- Cor amarela
    love.graphics.circle("fill", shot.x, shot.y, shotRadius) -- Tiro como um círculo
    love.graphics.setColor(1, 1, 1) -- Reseta a cor
  end
--[[
  -- Desenhar o flash branco, se ativo
  if flashAlpha > 0 then
    love.graphics.setColor(1, 1, 1, flashAlpha) -- Define a cor branca com opacidade
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight) -- Preenche a tela
    love.graphics.setColor(1, 1, 1) -- Reseta a cor
  end]]
  flash.draw()
end

-- Função update: atualiza a posição da bolha, inimigos e tiros
function inGame.update(dt)
  --[[ Atualizar o tempo total
  totalTime = totalTime + dt]]

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


  -- Flash
  --[[Controlar a transição do flash
  if flashActive then
    flashAlpha = flashAlpha + flashStep * dt
    if flashAlpha >= 1 then
      flashAlpha = 1 -- Máxima opacidade
      flashStep = -flashStep -- Inverter a direção da transição
    elseif flashAlpha <= 0 then
      flashAlpha = 0 -- Fim do flash
      flashActive = false -- Desativa o flash
    end
  end
  -- Ativar flash aos 14 segundos, oq  comba com a musica
  if totalTime <= 15 and totalTime >= 14 and not flashActive then
    triggerFlash()
  end
  ]]flash.update(dt)

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
 
 
  -- Inimigos
  -- Atualizar a posição dos inimigos
  for _, enemy in ipairs(enemies) do
    local dx = bolhas[1].x - enemy.x
    local dy = bolhas[1].y - enemy.y
    local distance = math.sqrt(dx^2 + dy^2)
    enemy.x = enemy.x + (dx / distance) * enemySpeed * dt
    enemy.y = enemy.y + (dy / distance) * enemySpeed * dt
  end

  -- Detecao de colisao com as bolhas
  for i=#bolhas,1,-1 do
    bolha = bolhas[i]
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
  -- Gerar inimigos periodicamente
  enemySpawnTimer = enemySpawnTimer - dt
  if enemySpawnTimer <= 0 then
    spawnEnemy()
    enemySpawnTimer = 1
  end
  
   --Wave: verificar se o score é múltiplo de 10 e diferente do último registrado
  if roundScore > 0 and roundScore % 20 == 0 and roundScore ~= lastWaveScore then
    spawnWave() -- Gerar 10 inimigos de um lado aleatório
    lastWaveScore = roundScore -- Atualizar o último score que gerou a onda
    love.audio.play(banzaiSound)
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
      for j = #enemies, 1, -1 do
        local enemy = enemies[j]
        local dx = shot.x - enemy.x
        local dy = shot.y - enemy.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist < enemy.radius + shotRadius  then
          -- Remover o inimigo e o tiro
          table.remove(enemies, j)
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