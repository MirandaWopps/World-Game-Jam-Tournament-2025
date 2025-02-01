local enemy = {}

-- Imagens dos inimigos
local enemyImg = love.graphics.newImage("assets/enemy.png")
local enemyBanzai = love.graphics.newImage("assets/enemyBanzai.png")

-- Som dos inimigos
local banzaiSound = love.audio.newSource("banzai.mp3", "static")

-- Parâmetros dos inimigos
local enemyWidth = enemyImg:getWidth()
local enemyHeight = enemyImg:getHeight()
local enemyRadius = enemyWidth / 2
local enemySpeed = 200
local enemySpawnTimer = 0
local lastWaveScore = 0

-- Tabela para armazenar inimigos
local enemies = {}

-- Retorna lista de inimigos
function enemy.getEnemies()
    return enemies
end

-- O inicio do inGame tem esse vetor zerado, o que impede o bug dos inimigos estarem sobre a bolha já no começo.
function enemy.start()
    enemies = {}
end


-- Função para gerar coordenadas aleatórias para spawn de inimigos fora da tela
local function coordRandomizer()
    if math.random() < 0.5 then
        return math.random(-200, -50)
    else
        return math.random(800 + 50, 800 + 200)
    end
end

-- Função para spawnar um inimigo
function enemy.spawn()
    local newEnemy = {}
    if math.random() < 0.5 then
        newEnemy.x = coordRandomizer()
        newEnemy.y = math.random(0, 800)
    else
        newEnemy.x = math.random(0, 800)
        newEnemy.y = coordRandomizer()
    end
    newEnemy.width = enemyWidth
    newEnemy.height = enemyHeight
    newEnemy.radius = enemyWidth / 2
    newEnemy.type = 1
    table.insert(enemies, newEnemy)
end

-- Função para spawnar uma onda de inimigos
function enemy.spawnWave()
    local sides = {"left", "right", "top", "bottom"}
    local waveSide = sides[math.random(#sides)]
    enemyImg = enemyBanzai -- Temporariamente troca a imagem

    for i = 1, 10 do
        local newEnemy = {}
        if waveSide == "left" then
            newEnemy.x = -50
            newEnemy.y = math.random(0, 800) + (i * 7)
        elseif waveSide == "right" then
            newEnemy.x = 800 + 50
            newEnemy.y = math.random(0, 800) + (i * 7)
        elseif waveSide == "top" then
            newEnemy.x = math.random(0, 800) + (i * 7)
            newEnemy.y = -50
        elseif waveSide == "bottom" then
            newEnemy.x = math.random(0, 800) + (i * 7)
            newEnemy.y = 800 + 50
        end
        newEnemy.width = enemyWidth
        newEnemy.height = enemyHeight
        newEnemy.radius = enemyWidth / 2
        newEnemy.type = 2
        table.insert(enemies, newEnemy)
    end

    enemyImg = love.graphics.newImage("assets/enemy.png") -- Volta à imagem original
end

-- Atualizar posição dos inimigos
function enemy.update(dt, bolhas)
    for _, e in ipairs(enemies) do
        local dx = bolhas[1].x - e.x
        local dy = bolhas[1].y - e.y
        local distance = math.sqrt(dx^2 + dy^2)
        e.x = e.x + (dx / distance) * enemySpeed * dt
        e.y = e.y + (dy / distance) * enemySpeed * dt
    end

    -- Gerar inimigos periodicamente
    enemySpawnTimer = enemySpawnTimer - dt
    if enemySpawnTimer <= 0 then
        enemy.spawn()
        enemySpawnTimer = 1
    end
end

-- Verifica se é hora de spawnar uma wave
function enemy.checkWave(roundScore)
    if roundScore > 0 and roundScore % 20 == 0 and roundScore ~= lastWaveScore then
        enemy.spawnWave()
        lastWaveScore = roundScore
        love.audio.play(banzaiSound)
    end
end

-- Função para desenhar os inimigos
function enemy.draw()
    for _, e in ipairs(enemies) do
        if e.type == 1 then
            love.graphics.draw(enemyImg, e.x, e.y, 0, 1, 1, e.width / 2, e.height / 2)
        else
            love.graphics.draw(enemyBanzai, e.x, e.y, 0, 1, 1, e.width / 2, e.height / 2)
        end
    end
end

-- Remove um inimigo da lista
function enemy.remove(index)
    table.remove(enemies, index)
end

return enemy
