local plane = {}

-- Dependências
local screenWidth, screenHeight = 800, 800 -- Dimensões da tela
local planeImg = love.graphics.newImage("assets/airStrikePowerUp.bmp") -- Imagem do avião
local planeSpeed = 50 -- Velocidade do avião
local planeBonus = 100 -- Bônus ao coletar o avião
local planeSpawnTimer = 30 -- Tempo inicial para spawnar o próximo avião
local planes = {} -- Tabela para armazenar os aviões
isAirstrikeUp = false -- Variável que ativa o ultimate


-- Função para spawnar um avião
function plane.spawn()
  local newPlane = {
    x = math.random(planeImg:getWidth() / 2, screenWidth - planeImg:getWidth() / 2), -- Spawn aleatório na horizontal
    y = math.random(planeImg:getHeight() / 2, screenHeight - planeImg:getHeight() / 2), -- Spawn aleatório na vertical
    width = planeImg:getWidth(),
    height = planeImg:getHeight(),
    collected = false -- Indica se o avião foi coletado
  }
  table.insert(planes, newPlane)
end


-- Função para atualizar os aviões
function plane.update(dt)
  -- Atualizar timer para spawnar aviões
  planeSpawnTimer = planeSpawnTimer - dt
  if planeSpawnTimer <= 0 then
    plane.spawn() -- Spawnar um novo avião
    planeSpawnTimer = math.random(15, 30) -- Reiniciar o timer com intervalo aleatório
  end

  -- Atualizar posição dos aviões
  for i = #planes, 1, -1 do
    local p = planes[i]
    p.y = p.y + planeSpeed * dt -- Avião descendo

    -- Verificar se o avião saiu da tela
    if p.y > screenHeight + 50 then
      table.remove(planes, i) -- Remove avião se sair da tela
    end
  end
end


-- Função para verificar coleta de aviões
function plane.checkCollection(bolhas)
  for i = #planes, 1, -1 do
    local p = planes[i]
    for _, bolha in ipairs(bolhas) do
      local dx = p.x - bolha.x
      local dy = p.y - bolha.y
      local distance = math.sqrt(dx^2 + dy^2)

      -- Verificar colisão com o jogador (bolhas)
      if distance < (p.width / 2 + 20) then -- 20 é o raio da bolha
        -- Coleta ocorreu
        p.collected = true
        isAirstrikeUp = true -- Ativa o ultimate
        print("Avião coletado! Ultimate ativado.")

        -- Remover avião coletado
        table.remove(planes, i)
        break
      end
    end
  end
end

-- Função para desenhar aviões
function plane.draw()
  for _, p in ipairs(planes) do
    love.graphics.draw(planeImg, p.x, p.y, 0, 1, 1, p.width / 2, p.height / 2)
  end
end

-- Retorna o estado do ultimate
function plane.isAirstrikeUp()
  return isAirstrikeUp
end

-- Reseta o ultimate após uso
function plane.resetAirstrike()
  isAirstrikeUp = false
end

return plane
