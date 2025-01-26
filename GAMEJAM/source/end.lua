local data = require('data') -- Importa o módulo `data.lua`
local inGame = require'inGame'
--local finalScore = scoreOnExecution
--local currentScore = 0
--local highestScore = data.getHighScore() -- Carrega o high score do arquivo

-- Configuração do botão "Retry"
local btnRetryFont = love.graphics.newFont("A Love of Thunder.ttf", 48)
local btnRetryText = "Retry"
local btnRetryX = 300
local btnRetryY = 390
local btnRetryHover = false
-- o certo é ja saber antes o tam do botão, antes de ser codado
-- Calcula largura e altura do texto dinamicamente
local btnRetryWidth = btnRetryFont:getWidth(btnRetryText)
local btnRetryHeight = btnRetryFont:getHeight()

print(highScoreExecution)

local endState = {}

-- Função para atualizar e salvar o high score, se necessário
local function updateHighScore()
    if roundScore > highScore then
        highScore = roundScore
        data.setHighScore(highScore)
    end
    return highScore
end

-- LOVE callbacks
function endState.load()
    -- Exemplo: você pode carregar o score aqui
    -- Substitua isso pelo score atual do jogo
    --highScore=updateHighScore() -- Atualiza o high score
end


function endState.start()
    highScore=updateHighScore()
end

function endState.draw()
    -- Exibir o maior score
    love.graphics.setColor(1, 0.84, 0) -- Dourado
    local highScoreFont = love.graphics.newFont("A Love of Thunder.ttf", 80)
    love.graphics.setFont(highScoreFont)
    love.graphics.print("Highest Score: " .. tostring(highScore), 50, 200)

    -- Exibir a pontuação atual
    love.graphics.setColor(1, 0, 0) -- Vermelho
    local scoreFont = love.graphics.newFont("A Love of Thunder.ttf", 72)
    love.graphics.setFont(scoreFont)
    love.graphics.print("Score: " .. tostring(roundScore), 250, 300)

    -- Exibir o botão "Retry"
    if btnRetryHover == true then
        love.graphics.setFont(btnRetryFont)
        love.graphics.setColor(1, 0, 0) -- Vermelho no hover
        love.graphics.print(btnRetryText, btnRetryX, btnRetryY)
    else
        love.graphics.setFont(btnRetryFont)
        love.graphics.setColor(1, 1, 1) -- Branco normal
        love.graphics.print(btnRetryText, btnRetryX, btnRetryY)
    end
end

function endState.mousemoved(x, y, dx, dy, istouch)
    -- Verificar se o mouse está dentro da área do botão
    --FAIL btnRetryHover = x >= btnRetryX and x <= btnRetryX + btnRetryWidth and
    --              y >= btnRetryY and y <= btnRetryY + btnRetryHeight
    btnRetryHover = x >= btnRetryX and x <= btnRetryX + 150 and
                    y >= btnRetryY and y <= btnRetryY + 50
                    
end



function endState.mousepressed(x, y, button)
    -- Verificar clique no botão "Retry"
    if button == 1 and btnRetryHover then
        -- Finalizar ou reiniciar o jogo
        love.audio.play(buttonSound)
        --setGame() --volta para o Game
        setMenu() -- volta para o Menu
    end
end

return endState
