local data = {}

local lastScore = 0
local highScore = 0
local gold = 0

local fileName = "data.txt" -- Nome do arquivo para armazenar os dados
--local gameData = {highscore = 0, gold = 0} -- Dados em memória

-- Função para carregar os dados do arquivo
local function loadData()
    local result = {highscore = 0, gold = 0} -- Valores padrão
    local file = io.open(fileName, "r")  
    if file then
        for line in file:lines() do
            local key, value = line:match("^(%w+):%s*(%d+)")
            if key and value then
                result[key] = tonumber(value)
            end
        end
        file:close()
    end
    --print (result)
    return result
end

-- Função para salvar os dados no arquivo
local function saveData(data)
    local file = io.open(fileName, "w")
    if file then
        file:write(string.format("highscore: %d\n", data.highscore))
        file:write(string.format("gold: %d\n", data.gold))
        file:close()
    end
end

-- Carregar dados iniciais
local gameData = loadData()

-- Função para definir o maior score
function data.setHighScore(score)
    if score > highScore then
        gameData.highscore = score
        saveData(gameData)
    end
end

-- Função para obter o maior score
function data.getHighScore()
    return gameData.highscore
end

-- Função para somar ouro
function data.addGold(amount)
    gameData.gold = gameData.gold + amount
    saveData(gameData)
end

-- Função para obter a quantidade total de ouro
function data.getGold()
    return gameData.gold
end

return data
