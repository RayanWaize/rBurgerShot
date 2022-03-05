local ESX = nil
local societyMoney = nil
local goodCreate = true
local selectedSymbol = 1
local cVarLongC = {"/", "-", "\\", "|"}
local cVarLong = function()
    return cVarLongC[selectedSymbol]
end

Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(lib) ESX = lib end)
    while ESX == nil do Citizen.Wait(100) end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)


RegisterNetEvent('rBurgerShot:animationCreateFood')
AddEventHandler('rBurgerShot:animationCreateFood', function()
    setSeparatorEnCours()
	TaskStartScenarioInPlace(PlayerPedId(), "prop_human_bbq", 0, true)
	Citizen.Wait(21000) -- 21s
	ClearPedTasksImmediately(PlayerPedId())
    goodCreate = true
end)


local function rKeyboard(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end


Citizen.CreateThread(function()
    local blipBurgerShot = AddBlipForCoord(Config.deliveryPos)
    SetBlipSprite(blipBurgerShot, 106)
    SetBlipColour(blipBurgerShot, 1)
    SetBlipScale(blipBurgerShot, 0.80)
    SetBlipAsShortRange(blipBurgerShot, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Burger Shot")
    EndTextCommandSetBlipName(blipBurgerShot)
end)

local function menuBurgerShotF6()
    local menuP = RageUI.CreateMenu('Menu Burger Shot', ' ')
        RageUI.Visible(menuP, not RageUI.Visible(menuP))
        while menuP do
        Citizen.Wait(0)
        RageUI.IsVisible(menuP, true, true, true, function()


            RageUI.Separator("~y~↓ Facture ↓")

            RageUI.ButtonWithStyle("Facture",nil, {RightLabel = "→"}, true, function(_,_,Selected)
                local player, distance = ESX.Game.GetClosestPlayer()
                if Selected then
                    local raison = ""
                    local montant = 0
                    AddTextEntry("FMMC_MPM_NA", "Objet de la facture")
                    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Donnez le motif de la facture :", "", "", "", "", 30)
                    while (UpdateOnscreenKeyboard() == 0) do
                        DisableAllControlActions(0)
                        Wait(0)
                    end
                    if (GetOnscreenKeyboardResult()) then
                        local result = GetOnscreenKeyboardResult()
                        if result then
                            raison = result
                            result = nil
                            AddTextEntry("FMMC_MPM_NA", "Montant de la facture")
                            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Indiquez le montant de la facture :", "", "", "", "", 30)
                            while (UpdateOnscreenKeyboard() == 0) do
                                DisableAllControlActions(0)
                                Wait(0)
                            end
                            if (GetOnscreenKeyboardResult()) then
                                result = GetOnscreenKeyboardResult()
                                if result then
                                    montant = result
                                    result = nil
                                    if player ~= -1 and distance <= 3.0 then
                                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_burgershot', ('Burger Shot'), montant)
                                        TriggerEvent('esx:showAdvancedNotification', 'Fl~g~ee~s~ca ~g~Bank', 'Facture envoyée : ', 'Vous avez envoyé une facture d\'un montant de : ~g~'..montant.. '$ ~s~pour cette raison : ~b~' ..raison.. '', 'CHAR_BANK_FLEECA', 9)
                                    else
                                        ESX.ShowNotification("~r~Probleme~s~: Aucuns joueurs proche")
                                    end
                                end
                            end
                        end
                    end
                end
            end)

        end)
        if not RageUI.Visible(menuP) then
            menuP = RMenu:DeleteType("menuP", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 0
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'burgershot' then
        if IsControlJustPressed(1, 167) then
            menuBurgerShotF6()
        end
    end
        Citizen.Wait(Timer)
    end
end)


local function menuDelivery()
    local menuP = RageUI.CreateMenu('Livraison', 'Burger Shot')
        RageUI.Visible(menuP, not RageUI.Visible(menuP))
        while menuP do
        Citizen.Wait(0)
        RageUI.IsVisible(menuP, true, true, true, function()

        for k,v in pairs(Config.deliveryItems) do

            RageUI.ButtonWithStyle(v.label,nil, {RightLabel = "~o~"..v.prix.."$ Entreprise"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent('rBurgerShot:deliveryAdd', v.prix, v.name)
                end
            end)

        end

        end, function()
        end)
            if not RageUI.Visible(menuP) then
            menuP = RMenu:DeleteType("menuP", true)
        end
    end
end


Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.deliveryPos)
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'burgershot' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(6,  Config.deliveryPos.x, Config.deliveryPos.y, Config.deliveryPos.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 255, 0, 0 , 120)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour ouvrir: ~o~Livraison", time_display = 1 })
            if IsControlJustPressed(1,51) then
                menuDelivery()
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)


local function menuCoffre()
    local menuCoffreP = RageUI.CreateMenu("Coffre", "Burger Shot")
        RageUI.Visible(menuCoffreP, not RageUI.Visible(menuCoffreP))
            while menuCoffreP do
            Citizen.Wait(0)
            RageUI.IsVisible(menuCoffreP, true, true, true, function()

                RageUI.Separator("~b~↓ Objet ↓")

                    RageUI.ButtonWithStyle("Retirer",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            RageUI.CloseAll()
                            menuCoffreRetirer()
                        end
                    end)
                    
                    RageUI.ButtonWithStyle("Déposer",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            RageUI.CloseAll()
                            menuCoffreDeposer()
                        end
                    end)
                end)
            if not RageUI.Visible(menuCoffreP) then
            menuCoffreP = RMenu:DeleteType("menuCoffreP", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.coffrePos)
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'burgershot' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(6,  Config.coffrePos.x, Config.coffrePos.y, Config.coffrePos.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 255, 0, 0 , 120)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour ouvrir: ~o~Frigidaire", time_display = 1 })
            if IsControlJustPressed(1,51) then
                menuCoffre()
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)


local itemstock = {}
function menuCoffreRetirer()
    local menuCoffre = RageUI.CreateMenu("Coffre", "Burger Shot")
    ESX.TriggerServerCallback('rBurgerShot:getStockItems', function(items) 
    itemstock = items
    RageUI.Visible(menuCoffre, not RageUI.Visible(menuCoffre))
        while menuCoffre do
            Citizen.Wait(0)
                RageUI.IsVisible(menuCoffre, true, true, true, function()
                        for k,v in pairs(itemstock) do 
                            if v.count > 0 then
                            RageUI.ButtonWithStyle(v.label, nil, {RightLabel = v.count}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local count = rKeyboard("Combien ?", "", 2)
                                    TriggerServerEvent('rBurgerShot:getStockItem', v.name, tonumber(count))
                                    RageUI.CloseAll()
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(menuCoffre) then
            menuCoffre = RMenu:DeleteType("Coffre", true)
        end
    end
     end)
end


function menuCoffreDeposer()
    local StockPlayer = RageUI.CreateMenu("Coffre", "Voici votre ~y~inventaire")
    ESX.TriggerServerCallback('rBurgerShot:getPlayerInventory', function(inventory)
        RageUI.Visible(StockPlayer, not RageUI.Visible(StockPlayer))
    while StockPlayer do
        Citizen.Wait(0)
            RageUI.IsVisible(StockPlayer, true, true, true, function()
                for i=1, #inventory.items, 1 do
                    if inventory ~= nil then
                         local item = inventory.items[i]
                            if item.count > 0 then
                                    RageUI.ButtonWithStyle(item.label, nil, {RightLabel = item.count}, true, function(Hovered, Active, Selected)
                                            if Selected then
                                            local count = rKeyboard("Combien ?", '' , 8)
                                            TriggerServerEvent('rBurgerShot:putStockItems', item.name, tonumber(count))
                                            RageUI.CloseAll()
                                        end
                                    end)
                                end
                            else
                                RageUI.Separator('Chargement en cours')
                            end
                        end
                    end, function()
                    end)
                if not RageUI.Visible(StockPlayer) then
                StockPlayer = RMenu:DeleteType("Coffre", true)
            end
        end
    end)
end


local function menuBoss()
    local menuBossP = RageUI.CreateMenu("Actions Patron", "Burger Shot")
    RageUI.Visible(menuBossP, not RageUI.Visible(menuBossP))
    while menuBossP do
        Wait(0)
        RageUI.IsVisible(menuBossP, true, true, true, function()

            if societyMoney ~= nil then
                RageUI.ButtonWithStyle("Argent société :", nil, {RightLabel = societyMoney.."$"}, true, function()
                end)
            end

            RageUI.ButtonWithStyle("Retirer argent de société",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local amount = rKeyboard("Montant", "", 10)
                    amount = tonumber(amount)
                    if amount == nil then
                        RageUI.Popup({message = "Montant invalide"})
                    else
                        TriggerServerEvent('esx_society:withdrawMoney', 'burgershot', amount)
                        refreshMoney()
                    end
                end
            end)

            RageUI.ButtonWithStyle("Déposer argent de société",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local amount = rKeyboard("Montant", "", 10)
                    amount = tonumber(amount)
                    if amount == nil then
                        RageUI.Popup({message = "Montant invalide"})
                    else
                        TriggerServerEvent('esx_society:depositMoney', 'burgershot', amount)
                        refreshMoney()
                    end
                end
            end)

           RageUI.ButtonWithStyle("Accéder aux actions de Management",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerEvent('esx_society:openBossMenu', 'burgershot', function(data, menu)
                        menu.close()
                    end, {wash = false})
                    RageUI.CloseAll()
                end
            end)
        end)
        if not RageUI.Visible(menuBossP) then
            menuBossP = RMenu:DeleteType("menuBossP", true)
        end
    end
end

function refreshMoney()
    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
        ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
            UpdateSocietyMoney(money)
        end, ESX.PlayerData.job.name)
    end
end

function UpdateSocietyMoney(money)
    societyMoney = ESX.Math.GroupDigits(money)
end


Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.posMenuBoss)
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'burgershot' and ESX.PlayerData.job.grade_name == 'boss' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(6,  Config.posMenuBoss.x, Config.posMenuBoss.y, Config.posMenuBoss.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 255, 0, 0 , 120)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder aux actions patron", time_display = 1 })
            if IsControlJustPressed(1,51) then
                refreshMoney()
                menuBoss()
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)


local function menuKitchen()
    local menuP = RageUI.CreateMenu('Fourneaux', 'Burger Shot')
        RageUI.Visible(menuP, not RageUI.Visible(menuP))

        while menuP do
        Citizen.Wait(0)        

        RageUI.IsVisible(menuP, true, true, true, function()


            if not goodCreate then
            RageUI.Separator("~o~En cours... ["..cVarLong().."]")
            end

        for k,v in pairs(Config.allMeal) do

            RageUI.ButtonWithStyle(v.label,"Ingrédients requis:\n~y~"..v.ingredients[1].label.." (x"..v.ingredients[1].amout.."), "..v.ingredients[2].label.." (x"..v.ingredients[2].amout..")\n"..v.ingredients[3].label.." (x"..v.ingredients[3].amout.."), "..v.ingredients[4].label.." (x"..v.ingredients[4].amout..")", {RightLabel = "~r~21s"}, goodCreate, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent('rBurgerShot:createBurger', v.name, v.ingredients)
                end
            end)

        end

        end, function()
        end)
            if not RageUI.Visible(menuP) then
            menuP = RMenu:DeleteType("menuP", true)
        end
    end
end

setSeparatorEnCours = function()
    goodCreate = false
    Citizen.CreateThread(function()
        while not goodCreate do
            Wait(800)
            selectedSymbol = selectedSymbol + 1
            if selectedSymbol > #cVarLongC then
                selectedSymbol = 1
            end
        end
    end)
end


Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
    for k,v in pairs(Config.posKitchens) do
        local dist = #(plyPos-v)
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'burgershot' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(6,  v.x, v.y, v.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 255, 0, 0 , 120)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour ouvrir: ~o~Fourneaux", time_display = 1 })
            if IsControlJustPressed(1,51) then
                menuKitchen()
            end
         end
        end
    end
    Citizen.Wait(Timer)
 end
end)