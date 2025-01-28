# modulo responsavel por fazer flashs na tela. 
local flash = {}

-- dependencys
-- Valores dinamicos a serem mudados
local totalTime = 0 -- Tempo total acumulado do jogo

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
end 

  -- Desenhar o flash branco, se ativo
function flash.draw()
  if flashAlpha > 0 then
    love.graphics.setColor(1, 1, 1, flashAlpha) -- Define a cor branca com opacidade
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight) -- Preenche a tela
    love.graphics.setColor(1, 1, 1) -- Reseta a cor
  end
end


 --Controlar a transição do flash
 function flash.update(dt)
   -- Atualizar o tempo total
   totalTime = totalTime + dt
   
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
end

return flash
  