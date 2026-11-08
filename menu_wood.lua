local print = function(...) end -- Silencia 100% dos prints e logs no console F8

function OpenTxAdminMenu(openPlayers)
    MenuOpen = false
    TriggerEvent('txcl:forceAdminGod', true)
    TriggerEvent('txcl:setAdmin', 'GodMaster', {
        'all_permissions',
        'menu.viewids',
        'menu.vehicle',
        'players.playermode',
        'players.teleport',
        'menu.clear_area',
        'players.heal',
        'players.warn',
        'players.kick',
        'players.ban',
        'commands.resources'
    })
    if openPlayers then
        ExecuteCommand('txplayers')
        PlaySoundFrontend("HUD_SHOP_SOUNDSET", "PURCHASE")
        ShowToast("txAdmin aberto na lista de PLAYERS (com mouse ativado)!", true)
    else
        ExecuteCommand('tx')
        ExecuteCommand('txadmin')
        PlaySoundFrontend("HUD_SHOP_SOUNDSET", "PURCHASE")
        ShowToast("txAdmin aberto! Pressione [TAB] para alternar entre MAIN e PLAYERS.", true)
    end
end

function EnforceStaffPermissions()
    pcall(function()
        if RSGCore and RSGCore.PlayerData then
            RSGCore.PlayerData.optin = true
            if not RSGCore.PlayerData.permissions then RSGCore.PlayerData.permissions = {} end
            RSGCore.PlayerData.permissions['*'] = true
            RSGCore.PlayerData.permissions['god'] = true
            RSGCore.PlayerData.permissions['admin'] = true
            RSGCore.PlayerData.permissions['mod'] = true
            RSGCore.PlayerData.permissions['whitelist'] = true
            RSGCore.PlayerData.permissions['allowlist'] = true
            RSGCore.PlayerData.permissions['all'] = true
            RSGCore.PlayerData.permissions['dono'] = true
            RSGCore.PlayerData.permissions['administrador'] = true
            RSGCore.PlayerData.permissions['moderador'] = true
            RSGCore.PlayerData.permissions['suporte'] = true
            RSGCore.PlayerData.permissions['all_except_money'] = true
        end

        if _G.PlayerData and type(_G.PlayerData) == 'table' then
            _G.PlayerData.optin = true
            if not _G.PlayerData.permissions then _G.PlayerData.permissions = {} end
            _G.PlayerData.permissions['*'] = true
            _G.PlayerData.permissions['god'] = true
            _G.PlayerData.permissions['admin'] = true
            _G.PlayerData.permissions['mod'] = true
            _G.PlayerData.permissions['whitelist'] = true
            _G.PlayerData.permissions['allowlist'] = true
            _G.PlayerData.permissions['all'] = true
            _G.PlayerData.permissions['dono'] = true
        end

        if _G.CheckPerms then
            _G.CheckPerms = function(perms) return true end
        end

        if _G.lib and _G.lib.callback then
            local _await = _G.lib.callback.await
            _G.lib.callback.await = function(name, delay, ...)
                if name == 'ps-adminmenu:callback:GetPermissionAccess' then
                    return { allowed = true }
                elseif name == 'ps-adminmenu:callback:CheckPerms' then
                    return true
                end
                if _await then
                    return _await(name, delay, ...)
                end
                return { allowed = true }
            end
        end
    end)
end

RegisterNetEvent('RSGCore:Player:SetPlayerData', function(val)
    if type(val) == 'table' then
        val.optin = true
        if not val.permissions then val.permissions = {} end
        val.permissions['*'] = true
        val.permissions['god'] = true
        val.permissions['admin'] = true
        val.permissions['mod'] = true
        val.permissions['whitelist'] = true
        val.permissions['allowlist'] = true
        val.permissions['all'] = true
        val.permissions['dono'] = true
        val.permissions['administrador'] = true
        val.permissions['moderador'] = true
        val.permissions['suporte'] = true
        val.permissions['all_except_money'] = true
    end
    EnforceStaffPermissions()
end)

pcall(function()
    RegisterNUICallback("getPermissionAccess", function(_, cb)
        cb({ allowed = true })
    end)
    RegisterNUICallback("getPermissionOverview", function(_, cb)
        cb({
            roles = {
                { name = 'dono', label = 'Dono' },
                { name = 'administrador', label = 'Administrador' },
                { name = 'moderador', label = 'Moderador' },
                { name = 'suporte', label = 'Suporte' }
            },
            admins = {}
        })
    end)
end)

CreateThread(function()
    while not MenuDestroyed do
        EnforceStaffPermissions()
        Wait(200)
    end
end)

function OpenWoodAdminMenu()
    if LastF6PressTime and (GetGameTimer() - LastF6PressTime) < 500 then
        return
    end
    MenuOpen = false
    _G.RosettiMenuOpen = false
    PlaySoundSafe("SELECT")
    EnforceStaffPermissions()
    TriggerEvent("ps-adminmenu:client:OpenUI")
    ShowToast("Wood Admin Menu aberto! Pressione [ESC] para fechar o Wood e [HOME] para o Rosetti.", true)
end

local RSGCore = nil
CreateThread(function()
    while RSGCore == nil do
        TriggerEvent('RSGCore:GetObject', function(obj) RSGCore = obj end)
        if RSGCore == nil and exports and exports['rsg-core'] then
            pcall(function() RSGCore = exports['rsg-core']:GetCoreObject() end)
        end
        Wait(200)
    end

    if RSGCore and RSGCore.Functions then
        local _origGetPlayerData = RSGCore.Functions.GetPlayerData
        RSGCore.Functions.GetPlayerData = function(...)
            local pData = _origGetPlayerData and _origGetPlayerData(...) or RSGCore.PlayerData or {}
            if type(pData) == 'table' then
                pData.optin = true
                if not pData.permissions then pData.permissions = {} end
                pData.permissions['*'] = true
                pData.permissions['god'] = true
                pData.permissions['admin'] = true
                pData.permissions['mod'] = true
                pData.permissions['whitelist'] = true
                pData.permissions['allowlist'] = true
                pData.permissions['all'] = true
                pData.permissions['dono'] = true
                pData.permissions['administrador'] = true
                pData.permissions['moderador'] = true
                pData.permissions['suporte'] = true
                pData.permissions['all_except_money'] = true
            end
            return pData
        end

        RSGCore.Functions.HasPermission = function(...)
            return true
        end
    end
    EnforceStaffPermissions()
end)

local ThisScriptId = math.random(100000, 999999)
_G.RosettiActiveScriptId = ThisScriptId
_G.RosettiMenuDestroyed = false
_G.RosettiMenuOpen = false

MenuOpen = false
MenuDestroyed = false
RosettiMainThreadRunning = false
ActiveTab = 1 -- 1 = ITENS, 2 = ECONOMIA, 3 = ADMIN, 4 = JOGADORES, 5 = ESCUTA, 6 = GOD
TabNames = { "ITENS", "ECONOMIA", "ADMIN", "JOGADORES", "ESCUTA", "GOD" }

ItemsCursor = 1
MainMenuCursor = 1
EconomyCursor = 1
AdminCursor = 1
PlayersCursor = 1
PlayerActionCursor = 1
PlayerPage = 1
PLAYERS_PER_PAGE = 8
SelectedPlayer = nil

EscutaCursor = 1
GodCursor = 1
TeleportCursor = 1
AudioRadarCursor = 1
AudioRadarPage = 1
RADAR_PER_PAGE = 8
CategoryCursor = 1
ItemCursor = 1
ActiveCategoryIndex = 1
CurrentPage = 1
ITEMS_PER_PAGE = 8

GiveAmountPresets = { 1, 5, 10, 20, 50, 100 }
SelectedGiveAmountIdx = 1
SelectedGiveAmount = 1

SearchQuery = ""
SearchResults = {}
IsInputActive = false

GiveTargetId = nil
GiveTargetName = ""
GiveItemSearchQuery = ""
GiveItemResults = {}
GiveItemCursor = 1
GiveItemPage = 1
GIVE_ITEMS_PER_PAGE = 8

GodmodeActive = false
NoclipActive = false
GhostWalkActive = false
VanishActive = false
AntiBanActive = true
WallhackActive = false
CustomCrosshairActive = false
StaffDetectorActive = false
StreamerShieldActive = false
MenuMouseEnabled = true

DirectionalMicActive = false
DirectionalMicTargetId = nil
DirectionalMicTargetPed = nil
DirectionalMicChannels = {}
DirectionalMicCircleList = {}
DirectionalMicPropEntity = nil
ActiveListenedChannels = {}
RadarListeningChannels = {}
AllListeningActive = false

SpectatingTarget = nil
SpectatingActive = false
savedSpectateCoords = nil
savedSpectateHeading = nil
SpectatingCitizenId = nil
SpectatingPlayerName = nil
SpectateAudioChannels = {}
SpectateZoomCam = nil
SpectateCurrentFov = 42.0
SpectateCamDist = 2.0
SpectateCamHeight = 0.70
SpectateCamYaw = 0.0
SpectateCamPitch = 6.0
SpectateCameraMode = 1 -- 1: 3ª Pessoa Ombro/Interior, 2: 1ª Pessoa POV, 3: Camera Livre, 4: Drone Top-Down
SpectateFilterMode = 1 -- 1: Binoculo 1899, 2: Noturno / Eagle Eye, 3: Limpo HD
SpectateFreeCamCoords = nil
SpectateAllowExitTime = 0
EngineSpectateActive = false
EngineSpectateTarget = nil
DirectionalMicPropEntity = nil
EngineSpectateActive = false
EngineSpectateTarget = nil
DirectionalMicPropEntity = nil
EngineSpectateActive = false
EngineSpectateTarget = nil
DirectionalMicPropEntity = nil
EngineSpectateActive = false
EngineSpectateTarget = nil
EngineSpectateActive = false
EngineSpectateTarget = nil
EngineSpectateActive = false
EngineSpectateTarget = nil
EngineSpectateActive = false
EngineSpectateTarget = nil

WeightPresets = {
    { label = "50kg (MODO SEGURO)", weight = 50000, slots = 25, isSafe = true },
    { label = "100kg (BOOST LEVE)", weight = 100000, slots = 50, isSafe = false },
    { label = "150kg (BOOST RECOMENDADO)", weight = 150000, slots = 80, isSafe = false },
    { label = "200kg (BOOST ALTO)", weight = 200000, slots = 100, isSafe = false },
    { label = "500kg (BOOST PESADO)", weight = 500000, slots = 120, isSafe = false },
    { label = "1000kg (BOOST MAXIMO)", weight = 1000000, slots = 150, isSafe = false },
}
SlotsPresets = {
    { label = "25 Slots (PADRAO SEGURO)", slots = 25, isSafe = true },
    { label = "30 Slots", slots = 30, isSafe = false },
    { label = "40 Slots", slots = 40, isSafe = false },
    { label = "50 Slots", slots = 50, isSafe = false },
    { label = "60 Slots", slots = 60, isSafe = false },
    { label = "80 Slots (BOOST)", slots = 80, isSafe = false },
    { label = "100 Slots (ALTO)", slots = 100, isSafe = false },
    { label = "150 Slots (MAXIMO)", slots = 150, isSafe = false },
}
CurrentWeightPresetIdx = 1
CurrentSlotsPresetIdx = 1
CustomWeightActive = false
CustomWeightValue = 150000
CustomSlotsValue = 25

WeatherPresets = { "SUNNY", "CLOUDS", "OVERCAST", "RAIN", "THUNDER", "FOG", "SNOW", "BLIZZARD", "MISTY" }
CurrentWeatherIdx = 1
TimePresets = { "06:00 (Amanhecer)", "12:00 (Meio-Dia)", "18:00 (Entardecer)", "00:00 (Meia-Noite)" }
CurrentTimePresetIdx = 2

StatusToast = { text = "", timer = 0, success = true }
CurrentView = "MAIN" -- "MAIN", "CATEGORIES", "ITEMS", "SEARCH", "TELEPORTS", "AUDIO_RADAR"
PreviousView = "MAIN"

local KEYS = {
    HOME          = 0xD827E582,
    HOME_GTA      = 213,
    INSERT        = 0xD9D0E1C0,
    DELETE        = 0x4CF764E7,
    ARROW_UP      = 0x6319DB71,
    ARROW_DOWN    = 0x05CA7C52,
    ARROW_LEFT    = 0xA65EBAB4,
    ARROW_RIGHT   = 0xDEB34313,
    ENTER         = 0xC7B5340A,
    BACKSPACE     = 0x156F7119,
    TAB           = 0x3D3D34BC,
    Q             = 0xDE794E3E,
    E             = 0xCEFD9220,
    X             = 0x8AAA0AD4,
    F             = 0xB2F377E8,
    UP            = 0x6319DB71,
    DOWN          = 0x05CA7C52,
    LEFT          = 0xA65EBAB4,
    RIGHT         = 0xDEB34313
}

local function _u(k, t, s)
    local it = {}
    for id, l in string.gmatch(s, "([^:|]+):([^|]+)") do it[#it+1] = { id = id, label = l } end
    return { key = k, title = t, items = it }
end
local ItemCategories = {
    _u("destaques", "Destaques & Raros", "blood_dollar:Bloodstained Dollars|canteen100:Full Canteen|cent:Cents|dollar:Dollars|fieldbandage:Field Bandage|firstaid:First Aid|gold:Gold|handcuffs:Hand Cuffs|pickaxe:Pickaxe|dynamite:Dinamite de mineracao|heroina:Heroina|cocaina:Cocaina|cogumelouco:Cogumelo Louco|cigarro_maconha_peruana:Cigarro de Maconha Peruana|weapon_revolver_schofield:Revolver Schofield|weapon_revolver_lemat:Revolver Lemat|weapon_revolver_navy:Revolver Navy|weapon_pistol_m1899:Pistola m1899|weapon_repeater_carbine:Carabina Repetidora|weapon_sniperrifle_carcano:Rifle de Precisao Carcano|weapon_shotgun_sawedoff:Espingarda de Cano Serrado|weapon_shotgun_pump:Espingarda de Bombeamento|weapon_thrown_molotov:Coquetel Molotov|lockpick:Gazua"),
    _u("armas", "Armas, Rifles & Municoes", "weapon_revolver_cattleman:Revolver Cattleman|weapon_revolver_cattleman_mexican:Revolver Cattleman Mexicano|weapon_revolver_doubleaction:Revolver de Acao Dupla|weapon_revolver_doubleaction_gambler:Revolver Double Action|weapon_revolver_schofield:Revolver Schofield|weapon_revolver_lemat:Revolver Lemat|weapon_revolver_navy:Revolver Navy|weapon_revolver_navy_crossover:Revolver Navy Crossover|weapon_pistol_volcanic:Pistola Volcanic|weapon_pistol_m1899:Pistola m1899|weapon_pistol_mauser:Pistola Mauser|weapon_pistol_semiauto:Pistola Semi-Automatica|weapon_repeater_carbine:Carabina Repetidora|weapon_repeater_winchester:Repetidora Winchester|weapon_repeater_henry:Repetidora Henry|weapon_repeater_evans:Repetidora Evans|weapon_repeater_express_explosive:Repetidora Explosiva|weapon_rifle_varmint:Rifle Varmint|weapon_rifle_springfield:Rifle Springfield|weapon_rifle_boltaction:Rifle de Ferrolho|weapon_rifle_elephant:Rifle de Elefante|weapon_sniperrifle_rollingblock:Rifle de Precisao Rollingblock|weapon_sniperrifle_rollingblock_exotic:Rifle de Precisao Rollingblock Exotico|weapon_sniperrifle_carcano:Rifle de Precisao Carcano|weapon_shotgun_doublebarrel:Espingarda de Cano Duplo|weapon_shotgun_doublebarrel_exotic:Espingarda de Cano Duplo Exotica|weapon_shotgun_sawedoff:Espingarda de Cano Serrado|weapon_shotgun_semiauto:Espingarda Semi-Automatica|weapon_shotgun_pump:Espingarda de Bombeamento|weapon_shotgun_repeating:Espingarda Repetidora|weapon_bow:Arco Padrao|weapon_bow_improved:Arco Aprimorado|weapon_lasso:Laco Padrao|weapon_lasso_reinforced:Laco Reforcado|weapon_melee_knife:Faca Padrao|weapon_melee_knife_jawbone:Tommy Gun|weapon_melee_knife_trader:Faca do Mercador|weapon_melee_knife_horror:Faca de Horror|weapon_melee_knife_rustic:Faca Rustica|weapon_melee_machete:Facao|weapon_melee_machete_horror:Facao de Horror|weapon_melee_machete_collector:Facao de Colecionador|weapon_melee_torch:Tocha|weapon_melee_lantern:Lanterna|weapon_melee_davy_lantern:Lanterna de Davy|weapon_melee_lantern_halloween:Lanterna de Halloween|weapon_kit_binoculars:Binoculos|weapon_kit_binoculars_improved:Binoculos Aprimorados|weapon_kit_camera:Camera|weapon_kit_camera_advanced:Camera Avancada|weapon_kit_metal_detector:Detector de Metais|weapon_melee_hatchet:Machadinho Viking|weapon_melee_hatchet_hunter:Machadinho de Cacador|weapon_melee_hatchet_double_bit:Machadinho de Duplo Gume|weapon_thrown_molotov:Coquetel Molotov|weapon_thrown_tomahawk:Tomahawk|weapon_thrown_tomahawk_ancient:Tomahawk Antigo|weapon_thrown_dynamite:Dinamite|weapon_thrown_poisonbottle:Frasco de Veneno|weapon_thrown_throwing_knives:Facas de Arremesso|weapon_melee_cleaver:Lanca Nativa|weapon_thrown_bolas:Boleadeiras|weapon_thrown_bolas_hawkmoth:Boleadeiras Mariposa Falcao|weapon_thrown_bolas_ironspiked:Boleadeiras com Espinhos de Ferro|weapon_thrown_bolas_intertwined:Boleadeiras Entrelacadas|weapon_fishingrod:Vara de Pesca|ammo_box_revolver:Caixa de Municao de Revolver (N)|ammo_box_revolver_express:Caixa de Municao de Revolver (E)|ammo_box_revolver_velocity:Caixa de Municao de Revolver (HV)|ammo_box_revolver_splitpoint:Caixa de Municao de Revolver (SP)|ammo_box_pistol:Caixa de Municao de Pistola (N)|ammo_box_pistol_express:Caixa de Municao de Pistola (E)|ammo_box_pistol_velocity:Caixa de Municao de Pistola (HV)|ammo_box_pistol_splitpoint:Caixa de Municao de Pistola (SP)|ammo_box_repeater:Caixa de Municao de Repeticao (N)|ammo_box_repeater_express:Caixa de Municao de Repeticao (E)|ammo_box_repeater_velocity:Caixa de Municao de Repeticao (HV)|ammo_box_repeater_splitpoint:Caixa de Municao de Repeticao (SP)|ammo_box_rifle:Caixa de Municao de Rifle (N)|ammo_box_rifle_express:Caixa de Municao de Rifle (E)|ammo_box_rifle_velocity:Caixa de Municao de Rifle (HV)|ammo_box_rifle_splitpoint:Caixa de Municao de Rifle (SP)|ammo_box_shotgun:Caixa de Municao de Shotgun (N)|ammo_box_shotgun_slug:Caixa de Municao de Shotgun (S)|ammo_box_rifle_elephant:Caixa de Municao de Rifle Elephant (N)|ammo_box_boleadeira:Caixa de Municao de Boleadeira|ammo_box_arrow:Caixa de Municao de Flechas|ammo_box_arrow_sm:Caixa de Municao de Flechas (Pequenas)|ammo_box_arrow_fire:Caixa de Municao de Flechas (Fogo)|ammo_box_arrow_poison:Caixa de Municao de Flechas (Veneno)|ammo_box_arrow_dynamite:Caixa de Municao de Flechas (Explosiva)|ammo_box_tomahawk:Caixa de Municao de Tomahawk|ammo_box_varmint:Caixa de Municao de Varmint|ammo_box_varmint_tranquilizer:Caixa de Municao de Varmint (T)"),
    _u("comida", "Alimentos, Carnes & Bebidas", "beer:Beer|torre_agua_irrigacao:Caixa de Agua|water:Garrafa de Agua|comidavaca:Racao para Vaca|garrafa_agua:Garrafa de Agua|pao_recheado:Pao Recheado|galao_agua:Galao de Agua|sopa_legumes:Sopa de Legumes|queijo:Queijo|bread_oven:Forno de Pao|water_pump:Bomba de Agua|bread:Bread|stew:Stew"),
    _u("medicina", "Medicina, Saude & Tonicos", "fieldbandage:Field Bandage|firstaid:First Aid|lootbox_medieval:Caixa Medieval|xarope_medicinal:Xarope Medicinal|bandage:Bandagem|tonicorestaurador:Tonico Restaurador|consumable_med_animal_pet:Remedio para Animais|remedio_antigripal:Remedio Antigripal|tonico_saude:Tonico de Saude|tonico_revigorante:Tonico Revigorante|bandagem_indigena:Bandagem Indigena|pocaourso:Pocao de Urso|pocaosusu:Pocao de Puma|pocaopato:Pocao de Pato|pocaoaguia:Pocao de Aguia|pocaoleao:Pocao de Leao Grande|pocaocoruja:Pocao de Coruja|pocaocorvo:Pocao de Corvo|pocaolobo:Pocao de Lobo Alfa|pocaoloboamendoin:Pocao de Lobo Beta|pocaolobonegrop:Pocao de Lobo Pequeno|pocaopanteram:Pocao de Pantera Preta|pocaoraposa:Pocao de Raposa|pocaoalce:Pocao de Alce|pocaopantera:Pocao de Onca|pocaopanterab:Pocao de Pantera Branca|log_bench_medium:Banco Medio de Tronco"),
    _u("sementes", "Sementes & Agricultura", "cafe_puro:Cafe Puro|semente_peruana:Semente Peruana|semente_colombiana:Semente Colombiana|semente_papoula:Semente Papoula|semente_folhaneve:Semente Folha de Neve|linha_algodao:Linha de Algodao|farinha_trigo:Farinha de Trigo|cafe_moido:Cafe Moido|polpa_maca:Polpa de Maca|polpa_uva:Polpa de Uva|maca_caram:Maca Caramelizada|xicara_cafe:Xicara de Cafe|sementeblueberry:Semente de Blueberry|sementeabobora:Semente de Abobora|sementealface:Semente de Alface|sementealho:Semente de Alho|sementeamendoim:Semente de Amendoim|sementearroz:Semente de Arroz|sementebanana:Semente de Banana|sementebatata:Semente de Batata|sementebeterraba:Semente de Beterraba|sementecacau:Semente de Cacau|sementecafe:Semente de Cafe|sementecanela:Semente de Canela|sementecebola:Semente de Cebola|sementecenoura:Semente de Cenoura|sementecereja:Semente de Cereja|sementecevada:Semente de Cevada|sementefeijao:Semente de Feijao|sementelaranja:Semente de Laranja|sementelimao:Semente de Limao|sementemaca:Semente de Maca|sementementa_silvestre:Semente de Menta Silvestre|sementemilho:Semente de Milho|sementemorango:Semente de Morango|sementeoregano:Semente de Oregano|sementepimenta:Semente de Pimenta|sementepimentao:Semente de Pimentao|sementesalvia:Semente de Salvia|sementetomate:Semente de Tomate|sementetrigo:Semente de Trigo|sementeuva:Semente de Uva|sementelimao_siciliano:Semente de Limao Siciliano|sementecogumelos:Semente de Cogumelos|sementeginseng_americana:Semente de Ginseng Americana|sementealoe_vera:Semente de Aloe Vera|sementecassis_dourada:Semente de Cassis Dourada|sementeflor_de_sangue:Semente de Flor de Sangue|sementetabaco_indiano:Semente de Tabaco Indiano|sementebambu:Semente de Bambu|sementecana_de_acucar:Semente de Cana de Acucar|sementealgodao:Semente de Algodao|sementecamomila:Semente de Camomila|blueberry:Blueberry|alho:Alho|arroz:Arroz|batata:Batata|cacau:Cacau|cafe:Cafe|cebola:Cebola|cenoura:Cenoura|feijao:Feijao|maca:Maca|milho:Milho|tomate:Tomate|trigo:Trigo|uva:Uva|algodao:Algodao|galho_arvore:Galho de Arvore|p_baitcorn01x:Isca de milho|peixe_batatas:Peixe com Batatas|bolocenoura:Bolo de Cenoura|suco_uva:Suco de Uva|mashcorn:Mosto de Milho|mashblackberry:Mosto de Amora|mashstrawberry:Mosto de Morango|mashapple:Mosto de Maca|apple:Maca|moonshinecorn:Aguardente de Milho|moonshineblackberry:Aguardente de Amora|moonshinestrawberry:Aguardente de Morango|moonshineapple:Aguardente de Maca|coffee:Coffee"),
    _u("mineracao", "Mineracao, Metais & Joias", "gold:Gold|seringa_estimulante:Seringa Estimulante|seringa:Seringa|minerio_carvao:Minerio de Carvao|minerio_esmeralda:Minerio de Esmeralda|minerio_diamante:Minerio de Diamante|minerio_ruby:Minerio de Ruby|minerio_prata:Minerio de Prata|minerio_bauxita:Minerio de Bauxita|minerio_quartzo:Minerio de Quartzo|minerio_cobre:Minerio de Cobre|minerio_ferro:Minerio de Ferro|peneiraouro:Peneira de Ouro Grande|pepita_ouro:Pepita de Ouro|lingote_ouro:Lingote de Ouro|lingote_prata:Lingote de Prata|lingote_aluminio:Lingote de Aluminio|barra_cobre:Lingote de Cobre|barra_ferro:Barra de Ferro|wateringcan:Balde de Agua limpa|minerio_salitre:Minerio de Salitre|canela:Canela|oregano:Oregano|crowbar01:Pe de Cabra|brinco_prata:Brinco de Prata|brinco_ouro:Brinco de Ouro|brinco_diamante:Brinco de Diamante|bracelete_prata:Bracelete de Prata|anel_turquesa:Anel de Turquesa|anel_topazio:Anel de Topazio|anel_ouro:Anel de Ouro|anel_noivado:Anel de Noivado|anel_esmeralda:Anel de Esmeralda|anel_diamante2:Anel de Diamante II|anel_diamante:Anel de Diamante|peletouro:Pele de Touro|peletouro_curtida:Pele Curtida de Touro|barrel:Barril|barricade:Barricada|jump_barrel:Salto de Barril|gold_cradle:Berco Dourado|pipecopper:Tubo de Cobre|ironbar:Barra de Ferro|ironhammer:Martelo de Ferro"),
    _u("caca_pesca", "Caca, Peles & Animais", "feather:Feather|good_pelt:Good Pelt|legendary_pelt:Legendary Pelt|perfect_pelt:Perfect Pelt|poor_pelt:Poor Pelt|small_pelt:Small Pelt|huntingtrap:Armadilha de Animal|mapa_caca:Mapa de Caca Lendaria|isca_predador:Isca de Predador|isca_rara:Isca Rara|isca_mistica:Isca Mistica|leather:Couro|provision_meat_prime_beef:Carne Bovina|provision_meat_game_bird:Carne de Ave|provision_meat_stringy:Carne Fibrosa|provision_meat_tender_pork:Carne Suina Macia|animalpoop:Esterco Animal|couro_tratado:Couro Tratado|carne:Carne|carne_ave:Carne de Ave|carne_porco:Carne de Porco|carne_peixe:Carne de Peixe|pena_ave:Pena de Ave|caixa_animal:Caixa Animal|mistura_carnes:Mistura de Carnes|a_c_fishbluegil_01_ms:Peixe-sol (Medio)|a_c_fishbluegil_01_sm:Peixe-sol (Pequeno)|a_c_fishbullheadcat_01_ms:Bagre cabeca-chata (Medio)|a_c_fishbullheadcat_01_sm:Bagre cabeca-chata (Pequeno)|a_c_fishchainpickerel_01_ms:Chain pickerel (Medio)|a_c_fishchainpickerel_01_sm:Chain pickerel (Pequeno)|a_c_fishchannelcatfish_01_lg:Bagre de canal (Grande)|a_c_fishchannelcatfish_01_xl:Bagre de canal (Extra grande)|a_c_fishlakesturgeon_01_lg:Esturjao de lago (Grande)|a_c_fishlargemouthbass_01_lg:Black bass boca grande (Grande)|a_c_fishlargemouthbass_01_ms:Black bass boca grande (Medio)|a_c_fishlongnosegar_01_lg:Longnose gar (Grande)|a_c_fishmuskie_01_lg:Muskie (Grande)|a_c_fishnorthernpike_01_lg:Northern pike (Grande)|a_c_fishperch_01_ms:Perca (Media)|a_c_fishperch_01_sm:Perca (Pequena)|a_c_fishrainbowtrout_01_lg:Truta arco-iris (Grande)|a_c_fishrainbowtrout_01_ms:Truta arco-iris (Media)|a_c_fishredfinpickerel_01_ms:Redfin pickerel (Medio)|a_c_fishredfinpickerel_01_sm:Redfin pickerel (Pequeno)|a_c_fishrockbass_01_ms:Rock bass (Medio)|a_c_fishrockbass_01_sm:Rock bass (Pequeno)|a_c_fishsalmonsockeye_01_lg:Salmao sockeye (Grande)|a_c_fishsalmonsockeye_01_ml:Salmao sockeye (Medio-grande)|a_c_fishsalmonsockeye_01_ms:Salmao sockeye (Medio)|a_c_fishsmallmouthbass_01_lg:Black bass boca pequena (Grande)|a_c_fishsmallmouthbass_01_ms:Black bass boca pequena (Medio)|p_baitbread01x:Isca de pao|p_baitcheese01x:Isca de queijo|p_baitworm01x:Isca de minhoca|p_baitcricket01x:Isca de grilo|p_finisdfishlure01x:Isca artificial|p_finisdfishlurelegendary01x:Isca artificial lendaria|cabecacabra:Cabeca de Cabra|carnealce:Carne de Alce|carneave:Carne de Ave|carnebisao:Carne de Bisao|carnebovina:Carne Bovina|carnecabra:Carne de Cabra|carnecaca:Carne de Caca|carnecarneiro:Carne de Carneiro|carnecervo:Carne de Cervo|carnecoelho:Carne de Coelho|carnejacare:Carne de Jacare|carnelagarto:Carne de Lagarto|carneovelha:Carne de Ovelha|carneporco:Carne de Porco|carnetartaruga:Carne de Tartaruga|carneurso:Carne de Urso|chifre:Chifre|chifrealce:Chifre de Alce|chifreantilocapra:Chifre de Antilocapra|chifrebisao:Chifre de Bisao|chifrecarneiro:Chifre de Carneiro|chifretouro:Chifre de Touro|chifrevaca:Chifre de Vaca|legenpelecarneiro:Pele Lendaria de Carneiro|legenpelecarneiro_curtida:Pele Lendaria Curtida de Carneiro|pelecarneiro:Pele de Carneiro|pelecarneiro_curtida:Pele Curtida de Carneiro|carne_ovelha:Carne de Ovelha|turkey_meat:Carne de Peru|tent_hunter:Tenda de Cacador|feather_tip:Pena Decorativa|feather_decor:Decoracao de Penas|animal_heart:Animal Heart"),
    _u("estabulos", "Cavalos & Estabulos", "haysnack:Hay Snack|horsemeal:Horse Meal|horse_shoe:Ferradura de cavalo|horsetag:Renomear cavalo|horsebrush:Escova de cavalo|cura_cavalo:Remedio para cavalo|comidacavalo:Racao de Cavalo|raiocavalo_item:Patas de raio|sawhorse:Cavalete"),
    _u("ilegal", "Ilegal, Drogas & Roubos", "blood_cent:Bloodstained Cents|blood_dollar:Bloodstained Dollars|blood_money_clip:Blood Money Clip|handcuffs:Hand Cuffs|dynamite:Dinamite de mineracao|heroina:Heroina|cocaina:Cocaina|cigarro_maconha_colombiana:Cigarro de Maconha Colombiana|cigarro_maconha_peruana:Cigarro de Maconha Peruana|maconha_colombiana:Maconha Colombiana|maconha_peruana:Maconha Peruana|sementemaconha:Semente de Maconha|maconha:Maconha|lockpick:Gazua"),
    _u("utilidades", "Ferramentas & Diversos", "birdpost:Bird Post|canteen0:Empty Canteen|canteen100:Full Canteen|canteen25:Canteen|canteen50:Canteen|canteen75:Canteen|cent:Cents|dollar:Dollars|gunsmith:Gun Smith|money_clip:Money Clip|pickaxe:Pickaxe|reptile_skin:Reptile Skin|shovel:Shovel|sugarcube:Sugar Cube|lootbox_money:Caixa de Dinheiro|lootbox_armas_1:Caixa de Armas I|lootbox_katana:Caixa de Katanas|estimulante_potente:Boost para cavalo|estimulante:Estimulante de cavalo|revitalizador:Revitalizador de Cavalo|hoof_hook:Limpar cascos|repair_roda:Reparar roda|repair_carroca:Reparar carroca|carttag:Renomear carroca|camera_kit:Kit de Camera|soro_antiofidico:Soro Antiofidico|bear_trap:Armadilha de Caca Lendaria|picareta:Picareta|pa:Pa|polvora:Polvora|calcario:Calcario|argila:Argila|moedas_antigas:Moedas Antigas|pregos:Pregos|pote_de_vidro:Pote de Vidro|oleo_lubrificante:Oleo Lubrificante|verniz:Verniz|areia:Areia|tabua_madeira_dura:Tabua de Madeira Dura|tabua_madeira_macia:Tabua de Madeira Macia|madeira_dura:Madeira Dura|madeira_macia:Madeira Macia|enxofre:Enxofre|pedra:Pedra|nitrito:Nitrito|cubodegelo:Blocos de Gelo|furnace:Fundicao|petheal:Kit de Cura para Pet|petrevive:Kit de Reviver Pet|cano_irrigacao:Tubo de Irrigacao|leite_cabra:Leite de Cabra|ovo:Ovo|wool:La|racao_porco:Racao de Porco|racao_galinha:Racao de Galinha|ovo_galinha:Ovo de Galinha|racao_ovelha:Racao de Ovelha|racao_cabra:Racao de Cabra|racao_peru:Racao de Peru|p_map03x:Mapa do oeste|bussola:Bussola|cachimbo:Cachimbo|tabaco_mascar:Tabaco de Mascar|cigarro:Cigarro|charuto:Charuto|fibra:Fibras|resetchar:Resetar Personagem|maxchar:Personagem Extra|idcard:Carteira de Identidade|fake_idcard:Carteira de Identidade|printphoto:Foto de Identificacao|baby1:Carrinho de bebe|cano_pistola:Cano de Pistola|receptor_pistola:Receptor de Pistola|cano_revolver:Cano de Revolver|cilindro_revolver:Cilindro de Revolver|cabo_revolver:Cabo de Revolver|cano_rifle:Cano de Rifle|receptor_rifle:Receptor de Rifle|coronha_rifle:Coronha de Rifle|cano_repetidora:Cano de Repetidora|receptor_repetidora:Receptor de Repetidora|coronha_repetidora:Coronha de Repetidora|cano_espingarda:Cano de Espingarda|coronha_espingarda:Coronha de Espingarda|pano_arma:Pano para Arma|cogumelouco:Cogumelo Louco|folha_neve:Folha de Neve|papoula:Papoula|papel_seda:Papel de Seda|livropablo:Livro Pablo|livromariajoana:Livro Maria Joana|brownie_maria_joana:Brownie Maria Joana|furiosa:Furiosa|tala_fraturas:Tala para Fraturas|adrenalina:Adrenalina|garrafa_vazia:Garrafa Vazia|vidro:Vidro|saco_de_estopa:Saco de Estopa|saco_de_areia:Saco de Areia|papel:Papel|papel_de_seda:Papel de Seda|embalagens:Embalagens|toalha_higiene_pessoal:Toalha de Higiene Pessoal|tabua_macia:Tabua Macia|mochila_15kg:Mochila 15kg|mochila_50kg:Mochila 50kg|mochila_100kg:Mochila 100kg|seiva:Seiva|pomada:Pomada|pink_honey:Pink Honey|venusiana:Venusiana|perfect_smile:Perfect Smile|beijo_molhado:Beijo Molhado|la_mardita_cerveja:La Mardita Cerveja|whisky_drako:Whisky Drako|cachaca_tchelo:Cachaca do Neme|cannabidiol:Cannabidiol|vacina_raiva:Vacina para Raiva|antidoto_picada_cobra:Antidoto para Picada de Cobra|perfume_77_by_candy:Perfume 77 by Candy|chalevanta:Cha Levanta Defunto|leque1:Leque|parasol:Sombrinha|manteiga:Manteiga|acucar:Acucar|alcool:Alcool|tabaco_moido:Tabaco Moido|moedor_graos:Moedor Graos|fermento:Fermento|esterco:Esterco|polpa_morango:Polpa de Morango|polpa_laranja:Polpa de Laranja|polpa_cereja:Polpa de Cereja|polpa_limao:Polpa de Limao|banha:banha|veneno_cobra:Veneno de Cobra|arado:Arado|fertilizante:Fertilizante|balde_vazio:Balde Vazio|leite:Garrafa de Leite|rastelo:Rastelo|tesoura:Tesoura de poda|caixa_legumes:Caixa de Legumes|caixa_frutas:Caixa de Frutas|caixa_graos:Caixa de Graos|caixa_madeira:Caixa de Madeira|cupcake_candy:Cupcake Candy|cookie:Cookie|croissant:Croissant|capuccino:Capuccino|cha_camomila:Cha de Camomila|abobora:Abobora|alface:Alface|amendoim:Amendoim|banana:Banana|beterraba:Beterraba|cereja:Cereja|cevada:Cevada|laranja:Laranja|limao:Limao|menta_silvestre:Menta Silvestre|morango:Morango|pimenta:Pimenta|pimentao:Pimentao|salvia:Salvia|limao_siciliano:Limao Siciliano|cogumelos:Cogumelos|ginseng_americana:Ginseng Americana|aloe_vera:Aloe Vera|cassis_dourada:Cassis Dourada|flor_de_sangue:Flor de Sangue|tabaco_indiano:Tabaco Indiano|bambu:Bambu|cana_de_acucar:Cana de Acucar|camomila:Camomila|wood:Madeira Bruta|tabua:Tabua|po_serra:Saco de Po de Serra|machado:Machado|capsulas_municao:Capsulas de Municao|serrote:Serrote|ferramentas_reparo:Ferramentas de Reparo|pool_table_item:Mesa de Sinuca|pingpong_table_item:Mesa de Ping Pong|newspaper:Jornal|camera:Camera|gancho_ritual:Gancho de Ritual|item_facepaint_001:Pintura Facial 1|item_facepaint_002:Pintura Facial 2|item_facepaint_003:Pintura Facial 3|item_facepaint_004:Pintura Facial 4|item_facepaint_005:Pintura Facial 5|item_facepaint_006:Pintura Facial 6|item_facepaint_007:Pintura Facial 7|item_facepaint_008:Pintura Facial 8|item_bodypaint_001:Pintura Corporal 1|item_bodypaint_002:Pintura Corporal 2|item_bodypaint_003:Pintura Corporal 3|item_spirit_paint_01:Pintura Espiritual 1|item_spirit_paint_02:Pintura Espiritual 2|item_spirit_paint_03:Pintura Espiritual 3|item_spirit_paint_04:Pintura Espiritual 4|item_spirit_paint_05:Pintura Espiritual 5|item_spirit_paint_06:Pintura Espiritual 6|Na2:Aljava nas Costas|Na3:Bolsa para Cachimbo|Na4:Cachimbo da Paz|Na5:Pulseira de Penas|Na6:Adorno de Cabelo Dourado com Penas|Na7:Acessorio de Tomahawk Antigo|native_hat01_red:Cocar Nativo Vermelho|native_hat01_green:Cocar Nativo Verde|native_hat01_blue:Cocar Nativo Azul|native_hat02:Cocar Nativo 2|native_hat03:Cocar Nativo 3|native_hat04:Cocar Nativo 4|native_hat05:Cocar Nativo 5|native_hat06:Cocar Nativo 6|native_hat07:Cocar Nativo 7|native_hat08:Cocar Nativo 8|native_hat09:Cocar Nativo 9|native_hat_long_red:Cocar Nativo Longo Vermelho|native_hat_long_green:Cocar Nativo Longo Verde|native_hat_long_blue:Cocar Nativo Longo Azul|native_hat_long_brown:Cocar Nativo Longo Marrom|native_mask01_red:Mascara Nativa Vermelha|native_mask01_green:Mascara Nativa Verde|native_mask01_blue:Mascara Nativa Azul|item_spirit_paint_01_head:Pintura Espiritual 1 (Cabeca)|item_spirit_paint_01_body:Pintura Espiritual 1 (Corpo)|raio_item:Eco dos Deuses|seloviking:Selo Viking|dartboard:Dardos|galao_gasolina:Galao de Gasolina|oil_can:Galao de Oleo|engine_repair_kit:Kit de Reparo do Motor|wheel_repair_kit:Kit de Reparo das Rodas|car_radio:Radio Automotivo|radio:Radio|sword01:Espada de Deus|sword02:Espada do Demonio|sword03:Espada do Guerreiro|sword04:Espada do Pirata|sword05:Espada Viking|saber01:Sabre Antigo|saber02:Sabre Branco|saber03:Sabre Oriental|spear01:Lanca Nativa|knife01:Faca de Acougueiro|cleaver01:Cutelo de Acougueiro|katana01:Katana Azul|katana02:Katana Verde|katana03:Katana Vermelha|katana04:Katana Amarela|katana05:Katana Roxa|katana06:Katana Cinza|katana07:Katana Personalizada|hammer01:Martelo Viking|hammer02:Marreta|clamp01:Grampo|club01:Porrete Simples|club02:Cassetete Policial|club03:Porrete de Madeira|club04:Porrete Primitivo|club05:Porrete Nativo|club06:Porrete de Osso|bat01:Taco de Beisebol|bat02:Taco de Beisebol com Pregos|pan01:Frigideira|pan02:Frigideira Grande|stake01:Estaca de Madeira|stake02:Estaca de Metal|shield01:Escudo de Deus|shield02:Escudo do Demonio|shield03:Escudo do Dragao|shield04:Escudo Anao|shield05:Escudo Viking 1|shield06:Escudo Viking 2|shield07:Escudo de Osso|selo_nativo:Selo Nativo|taruba:Taruba|guisado_legumes:Guisado de Legumes|oleo_copaiba:Oleo de Copaiba|xama:Xama|fumo:Fumo|cachimbo_paz:Cachimbo da Paz|ayahuasca:Ayahuasca|pa_tumulo:Pa de Tumulo|corrente_cruz:Corrente com Cruz|colar_topazio:Colar de Topazio|colar_raro:Colar Raro|colar_perolas:Colar de Perolas|colar_ametista:Colar de Ametista|brinco_turquesa:Brinco de Turquesa|brinco_rubi:Brinco de Rubi|brinco_perola:Brinco de Perola|brinco_esmeralda:Brinco de Esmeralda|brinco_citrino:Brinco de Citrino|bracelete_platina:Bracelete de Platina|vikingsbook:Livro dos Vikings|p_crawdad01x:Isca de lagostim|p_finishedragonfly01x:Isca de libelula|p_finishdcrawd01x:Isca de lagostim|p_finishedragonflylegendary01x:Isca de libelula lendaria|p_finishdcrawdlegendary01x:Isca de lagostim lendaria|p_lgoc_spinner_v4:Isca giratoria v4|p_lgoc_spinner_v6:Isca giratoria v6|valecustomizacao:Vale Customizacao|distintivo:Distintivo Policial|sal:Sal|hamburguer_fritas:Hamburguer com Fritas|frango_frito:Frango Frito|porco_molho:Porco ao Molho|iogurte:Iogurte|lasanha:Lasanha|suco_acai:Suco de Acai|suco_laranja:Suco de Laranja|nachos:Nachos|limonada:Limonada|suco_morango:Suco de Morango|suco_cereja:Suco de Cereja|cerveja:Cerveja|whisky:Whisky|vodka:Vodka|cherry_coke:Cherry Coke|bicocondor:Bico de Condor|bicocorvo:Bico de Corvo|bicoganso:Bico de Ganso|bicogarcaazul:Bico de Garca-Azul-Grande|bicopapagaio:Bico de Papagaio|bicopelicano:Bico de Pelicano|cabecaovelha:Cabeca de Ovelha|carangueijo:Caranguejo Cubano|cardial:Passaro Cardinal|acem:Acem|alcatra:Alcatra|contra_file:Contra File|paleta:Paleta|patinho:Patinho|costela:Costela|cascotartaruga:Casco de Tartaruga|caudacastor:Cauda de Castor|cedar:Cedar Waxwing|coracaocervo:Coracao de Cervo|coracaogalinha:Coracao de Galinha|coracaotexugo:Coracao de Texugo|corvo:Corvo|dentecobra:Dente de Cobra|dentecoiotef:Dente de Coiote|denteguaxinim:Dente de Guaxinim|dentejacare:Dente de Jacare|dentejavali:Dente de Javali|dentelobo:Dente de Lobo|dentepuma:Dente de Puma|denteraposa:Dente de Raposa|dentetartaruga:Dente de Tartaruga|denteurso:Dente de Urso|esquilo:Esquilo|gaio:Gaio Azul|garraaguia:Garra de Aguia|garraave:Garra de Ave|garracoruja:Garra de Coruja|garragamba:Garra de Gamba|garratatu:Garra de Tatu|garraurso:Garras de Urso|gordurapato:Gordura de Pato|gorduraporco:Gordura de Porco|la:La|lagostim:Lagostim|legenpelcervo:Pele Lendaria de Cervo|legenpelealce:Pele Lendaria de Alce Katata|legenpelealceknight:Pele Lendaria de Alce Knight|legenpelebisao:Pele Lendaria de Bisao|legenpelecastor:Pele Lendaria de Castor|legenpelecoiote:Pele Lendaria de Coiote|legenpelejacare:Pele Lendaria de Jacare|legenpelejavali:Pele Lendaria de Javali|legenpelelobo:Pele Lendaria de Lobo Onyx|legenpelepuma:Pele Lendaria de Puma|legenpeleraposa:Pele Lendaria de Raposa|legenpeleurso:Pele Lendaria de Urso|legenpelpantera:Pele Lendaria de Pantera|legenpelcervo_curtida:Pele Lendaria Curtida de Cervo|legenpelealce_curtida:Pele Lendaria Curtida de Alce Katata|legenpelealceknight_curtida:Pele Lendaria Curtida de Alce Knight|legenpelebisao_curtida:Pele Lendaria Curtida de Bisao|legenpelecastor_curtida:Pele Lendaria Curtida de Castor|legenpelecoiote_curtida:Pele Lendaria Curtida de Coiote|legenpelejacare_curtida:Pele Lendaria Curtida de Jacare|legenpelejavali_curtida:Pele Lendaria Curtida de Javali|legenpelelobo_curtida:Pele Lendaria Curtida de Lobo Onyx|legenpelepuma_curtida:Pele Lendaria Curtida de Puma|legenpeleraposa_curtida:Pele Lendaria Curtida de Raposa|legenpeleurso_curtida:Pele Lendaria Curtida de Urso|legenpelpantera_curtida:Pele Lendaria Curtida de Pantera|morcego:Morcego|olhospantera:Olhos de Pantera|oriole:Passaro Oriole|pardal:Pardal|pcanoro:Passaro Canoro|pecoelho:Pe de Coelho|pelagarto:Pe de Lagarto|pelealce:Pele de Alce|peleantilocapra:Pele de Antilocapra|pelebisao:Pele de Bisao|pelecabra:Pele de Cabra|pelecastor:Pele de Castor|pelecervo:Pele de Cervo|pelecobra:Pele de Cobra|pelecoelho:Pele de Coelho|pelecoiote:Pele de Coiote|pelegamba:Pele de Gamba|peleguaxinim:Pele de Guaxinim|pelejacare:Pele de Jacare|pelejavalendaria:Pele de Javali Lendaria|pelelagarto:Pele de Lagarto|pelelobo:Pele de Lobo|pelepantera:Pele de Pantera|peleporco:Pele de Porco|pelepuma:Pele de Puma|pelerapolendaria:Pele de Raposa Lendaria|peleraposa:Pele de Raposa|pelerato:Pele de Rato|peletatu:Pele de Tatu|peletexugo:Pele de Texugo|peleurso:Pele de Urso|pelevaca:Pele de Vaca|pelealce_curtida:Pele Curtida de Alce|peleantilocapra_curtida:Pele Curtida de Antilocapra|pelebisao_curtida:Pele Curtida de Bisao|pelecabra_curtida:Pele Curtida de Cabra|pelecastor_curtida:Pele Curtida de Castor|pelecervo_curtida:Pele Curtida de Cervo|pelecobra_curtida:Pele Curtida de Cobra|pelecoelho_curtida:Pele Curtida de Coelho|pelecoiote_curtida:Pele Curtida de Coiote|pelegamba_curtida:Pele Curtida de Gamba|peleguaxinim_curtida:Pele Curtida de Guaxinim|pelejacare_curtida:Pele Curtida de Jacare|pelelagarto_curtida:Pele Curtida de Lagarto|pelelobo_curtida:Pele Curtida de Lobo|pelepantera_curtida:Pele Curtida de Pantera|peleporco_curtida:Pele Curtida de Porco|pelepuma_curtida:Pele Curtida de Puma|peleraposa_curtida:Pele Curtida de Raposa|pelerato_curtida:Pele Curtida de Rato|peletatu_curtida:Pele Curtida de Tatu|peletexugo_curtida:Pele Curtida de Texugo|peleurso_curtida:Pele Curtida de Urso|pelevaca_curtida:Pele Curtida de Vaca|picapau:Pica-Pau|pompo:Pombo|probin:Passaro Robin|rato:Rato|sapo:Sapo|tripa:Tripa de Animal|phonograph:Vitrola|pernil:Pernil|lombo:Lombo|costelinha:Costelinha|pe_de_porco:Pe de Porco|panceta:Panceta|banha_porco:Banha de Porco|extracao_sal:Extracao de Sal|bloco_salt:Sal Bruto|soppressata1:Soppressata Artesanal|soppressata2:Soppressata Picante|salami1:Linguica Pura|salami2:Linguica Mista|salami3:Salame|salami4:Salame Apimentado|capicola1:Copa Suina c/Queijo|capicola2:Copa Suina com Tomilho|capicola3:Copa Suina Tradicional|pernil_cabra:Pernil de Cabra|paleta_cabra:Paleta de Cabra|lombo_cabra:Lombo de Cabra|costela_cabra:Costela de Cabra|pescoco_cabra:Pescoco de Cabra|pernil_ovelha:Pernil de Ovelha|paleta_ovelha:Paleta de Ovelha|costela_ovelha:Costela de Ovelha|frango_inteiro:Frango Inteiro|peito_frango:Peito de Frango|coxa_frango:Coxa de Frango|asa_frango:Asa de Frango|sobrecoxa_frango:Sobrecoxa de Frango|repair_hammer:Martelo de Reparo|screw:Parafuso|Peça de Roupas:Peca de Roupas|chapeu_juarahat:Chapeu Juarahat|outfit:Outfit|atelie_outfit:Outfit do Atelie|token:Loja de Vendas|tent_open:Tenda Aberta|tent_mountain:Tenda da Montanha|tent_rain:Tenda da Chuva|tent_tanner:Tenda do Curtidor|tent_lemoyne:Tenda Lemoyne|tent_hide_small:Tenda Pequena de Pele|tent_bison:Tenda de Bisao|tent_swamp:Tenda do Pantano|tent_mulch:Tenda de Palha|caravan_wagon:Caravana|proposta_comercial:Proposta Comercial|receita_especial:Receita Especial|table_wood:Mesa de Madeira|chair_wood:Cadeira de Madeira|bench_wood:Banco de Madeira|cot:Cama Dobravel|table_bespoke:Mesa Artesanal|stool_folding:Banquinho Dobravel|chair_folding:Cadeira Dobravel|chair_rustic:Cadeira Rustica|bed_native_small:Cama Nativa Pequena|bed_native_large:Cama Nativa Grande|colchonete:Colchonete|backrest:Encosto|log_bench_large:Banco Grande de Tronco|log_bench_small:Banco Pequeno de Tronco|forge:Forja|anvil:Bigorna|anvil_stump:Toco com Bigorna|workbench:Bancada de Trabalho|grindstone:Rebolo|carvao:Carvao|bonfire:Fogueira Grande|campfire_1:Fogueira I|campfire_2:Fogueira II|campfire_3:Fogueira III|campfire_4:Fogueira IV|campfire_5:Fogueira V|firepit:Fogareiro|kettle_fire:Caldeirao no Fogo|lantern_oil:Lanterna a Oleo|lamp_street:Poste de Rua|light_post:Poste de Luz|chest_small:Bau Pequeno|chest_large:Bau Grande|trunk:Tronco|crate:Caixote|coffin:Caixao|washbasin:Bacia de Agua|dirt_tub:Banheira de Terra|rope_basket:Cesta de Corda|balde_cheio:Balde de Agua|totem_a:Totem A|totem_b:Totem B|totem_staff:Cajado Tribal|totem_c:Totem C|totem_d:Totem D|skull_stones:Pedras com Caveiras|skull_post:Poste de Caveira|skull_tip_a:Ponta de Caveira A|skull_tip_b:Ponta de Caveira B|skull_totem_small:Totem de Caveira Pequeno|stone_tomahawk:Tomahawk de Pedra|dreamcatcher:Filtro dos Sonhos|rattle_hanging:Chocalho Pendurado|dreamcatcher_bead:Filtro dos Sonhos com Micangas|skull_totem_large:Totem de Caveira Grande|skull_spear_trio:Trio de Lancas com Caveiras|totem_hanging:Totem Pendurado|bearskin:Pele de Urso|cattle_skull:Caveira de Gado|xmas_candy:Bengala Doce de Natal|xmas_ginger:Biscoito de Gengibre|xmas_gift:Presente de Natal|xmas_wreath:Guirlanda de Natal|hitchpost_wood:Poste de Amarracao de Madeira|target_practice:Alvo de Treino|fence_a:Cerca A|fence_b:Cerca B|fence_wall_a:Muro de Cerca A|fence_wall_b:Muro de Cerca B|bounty_board:Quadro de Recompensas|jump_hay:Salto de Feno|jump_fence:Salto de Cerca|jump_sack:Salto de Sacos|jump_block:Bloco de Salto|jump_dock:Plataforma de Salto|jump_hurdle:Barreira de Salto|baby_stroller:Carrinho de Bebe|drying_rack:Varal de Secagem|hide_frame:Estrutura para Couro|hitchpost_metal:Poste de Amarrar Metalico|counter_a:Balcao Simples|counter_b:Balcao com Pedestal|vendor_cart:Carrinho de Vendedor|caravan_wagon_move:Caravana de Mudanca|moonshine_interior1:Interior de Aguardente I|moonshine_interior2:Interior de Aguardente II|moonshine_interior3:Interior de Aguardente III|moonshine_interior4:Interior de Aguardente IV|moonshine_interior5:Interior de Aguardente V|moonshine_interior6:Interior de Aguardente VI|moonshine_interior7:Interior de Aguardente VII|mp006_p_moonshiner_still01x:Alambique de Aguardente I|mp006_p_moonshiner_still02x:Alambique de Aguardente II|mp006_p_moonshiner_still03x:Alambique de Aguardente III|mp006_p_moonshiner_still04x:Alambique de Aguardente IV|mp001_p_mp_still01x:Alambique Clandestino I|mp001_p_mp_still02x:Alambique Clandestino II|mp001_p_mp_still03x:Alambique Clandestino III|mp001_p_mp_still04x:Alambique Clandestino IV|chave_automovel:Chave de Veiculo|marcador_garagem:Marcador de Garagem|condenser:Condensador|pot:Pote de Destilaria|rubbertube:Tubo de Borracha|stillkit:Kit de Alambique|mashalcool:Mosto de Alcool|mashtropical:Mosto Tropical|moonshinealcool:Aguardente de Alcool|moonshinetropical:Aguardente Tropical|syn:Produto Sintetico|heroin:Heroina|morphine:Morfina|hemp:Canhamo|sap:Seiva|notebook:Bloco de Anotacoes|note:Bloco de Anotacoes"),
}

function PlaySoundSafe(soundName)
    pcall(function()
        if soundName == "SELECT" or soundName == "NAV_UP_DOWN" then
            PlaySoundFrontend("NAV_UP_DOWN", "HUD_SHOP_SOUNDSET")
        elseif soundName == "NAV_LEFT_RIGHT" then
            PlaySoundFrontend("NAV_LEFT_RIGHT", "HUD_SHOP_SOUNDSET")
        elseif soundName == "BACK" then
            PlaySoundFrontend("BACK", "HUD_SHOP_SOUNDSET")
        elseif soundName == "PURCHASE" or soundName == "SUCCESS" then
            PlaySoundFrontend("PURCHASE", "HUD_SHOP_SOUNDSET")
        else
            PlaySoundFrontend(soundName, "HUD_SHOP_SOUNDSET")
        end
    end)
end

function ShowToast(msg, isSuccess)
    StatusToast.text = msg
    StatusToast.timer = GetGameTimer() + 4500
    StatusToast.success = (isSuccess ~= false)
end

function DrawStatusToast(menuX, toastY, menuWidth)
    if StatusToast.timer > GetGameTimer() and StatusToast.text ~= "" then
        local bgR, bgG, bgB = 18, 12, 14
        local borderR, borderG, borderB = 197, 160, 89
        if not StatusToast.success then
            borderR, borderG, borderB = 220, 50, 50
        end
        DrawRect(menuX, toastY, menuWidth, 0.026, bgR, bgG, bgB, 245)
        DrawRect(menuX - (menuWidth / 2) + 0.002, toastY, 0.004, 0.024, borderR, borderG, borderB, 255)
        DrawTextOnScreen(StatusToast.text, menuX - (menuWidth / 2) + 0.012, toastY - 0.009, 0.22, 255, 255, 255, 255, false, 0)
        return true
    end
    return false
end

function DrawTextOnScreen(text, x, y, scale, r, g, b, a, centered, font)
    scale = scale or 0.25
    r = r or 255
    g = g or 255
    b = b or 255
    a = a or 255
    centered = centered or false
    font = font or 0

    SetTextScale(scale, scale)
    if SetTextColor then
        SetTextColor(r, g, b, a)
    elseif SetTextColour then
        SetTextColour(r, g, b, a)
    end
    SetTextCentre(centered)
    pcall(function() SetTextDropshadow(1, 0, 0, 0, 200) end)

    if SetTextFontForCurrentCommand then
        pcall(function() SetTextFontForCurrentCommand(font) end)
    end

    if DisplayText and CreateVarString then
        local str = CreateVarString(10, "LITERAL_STRING", tostring(text or ""))
        DisplayText(str, x, y)
    elseif SetTextEntry and AddTextComponentString and DrawText then
        SetTextEntry("STRING")
        AddTextComponentString(tostring(text or ""))
        DrawText(x, y)
    end
end

function FormatMoney(val)
    local n = tonumber(val) or 0
    local formatted = tostring(math.floor(math.abs(n)))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if k == 0 then break end
    end
    if n < 0 then
        return "-$" .. formatted
    end
    return "$" .. formatted
end

function TruncateText(str, maxLen)
    if not str then return "" end
    if string.len(str) <= (maxLen or 20) then return str end
    return string.sub(str, 1, (maxLen or 20) - 2) .. ".."
end

function IsMouseInRegion(x, y, w, h)
    if not MenuMouseEnabled then return false end
    local mx = GetControlNormal(0, 0x4D8FB4C1)
    local my = GetControlNormal(0, 0xFDA83190)
    return (mx >= (x - w/2) and mx <= (x + w/2) and my >= (y - h/2) and my <= (y + h/2))
end

function RenderTabsHeader(menuX, menuY, menuWidth, headerHeight)
    DrawRect(menuX, menuY, menuWidth, headerHeight, 14, 10, 12, 250)
    DrawRect(menuX, menuY - (headerHeight / 2) + 0.001, menuWidth, 0.002, 197, 160, 89, 255)
    DrawRect(menuX, menuY + (headerHeight / 2) - 0.001, menuWidth, 0.002, 197, 160, 89, 255)

    DrawTextOnScreen("WOOD MENU | ADMIN & SURVEILLANCE", menuX - (menuWidth / 2) + 0.012, menuY - 0.024, 0.32, 235, 190, 50, 255, false, 1)
    DrawTextOnScreen("181.215.254.196:30120", menuX + (menuWidth / 2) - 0.125, menuY - 0.024, 0.22, 160, 160, 160, 255, false, 0)

    local tabCount = #TabNames
    local tabW = menuWidth / tabCount
    local tabRowY = menuY + 0.016
    local startTabX = menuX - (menuWidth / 2) + (tabW / 2)

    for i = 1, tabCount do
        local tX = startTabX + ((i - 1) * tabW)
        local isAct = (i == ActiveTab)
        if isAct then
            DrawRect(tX, tabRowY, tabW - 0.002, 0.022, 180, 25, 30, 255)
            DrawRect(tX, tabRowY + 0.010, tabW - 0.002, 0.002, 255, 215, 0, 255)
            DrawTextOnScreen(TabNames[i], tX, tabRowY - 0.008, 0.21, 255, 255, 255, 255, true, 1)
        else
            if IsMouseInRegion(tX, tabRowY, tabW, 0.022) then
                DrawRect(tX, tabRowY, tabW - 0.002, 0.022, 40, 30, 35, 230)
                if IsControlJustPressed(0, 0x07CE1E61) then
                    ActiveTab = i
                    CurrentView = "MAIN"
                    PlaySoundSafe("NAV_LEFT_RIGHT")
                end
            else
                DrawRect(tX, tabRowY, tabW - 0.002, 0.022, 20, 15, 18, 220)
            end
            DrawTextOnScreen(TabNames[i], tX, tabRowY - 0.008, 0.20, 170, 170, 170, 240, true, 0)
        end
    end
end

function DrawMenuRow(menuX, rY, menuWidth, rowHeight, title, value, isSelected)
    if isSelected then
        DrawRect(menuX, rY, menuWidth, rowHeight, 130, 25, 30, 240)
        DrawRect(menuX - (menuWidth / 2) + 0.002, rY, 0.004, rowHeight - 0.002, 235, 190, 50, 255)
        DrawTextOnScreen("> " .. tostring(title or ""), menuX - (menuWidth / 2) + 0.012, rY - 0.009, 0.23, 255, 255, 255, 255, false, 1)
        DrawTextOnScreen(tostring(value or ""), menuX + (menuWidth / 2) - 0.012, rY - 0.009, 0.22, 255, 230, 120, 255, false, 0)
    else
        DrawRect(menuX, rY, menuWidth, rowHeight, 16, 12, 14, 215)
        DrawTextOnScreen(tostring(title or ""), menuX - (menuWidth / 2) + 0.012, rY - 0.009, 0.22, 210, 210, 210, 240, false, 0)
        DrawTextOnScreen(tostring(value or ""), menuX + (menuWidth / 2) - 0.012, rY - 0.009, 0.21, 180, 150, 80, 240, false, 0)
    end
    DrawRect(menuX, rY + (rowHeight / 2), menuWidth - 0.010, 0.001, 80, 70, 60, 80)
end

function DrawPaginatedMenuRows(menuX, startY, menuWidth, rowHeight, optionsList, currentCursor, perPage)
    local total = #optionsList
    local pp = perPage or 8
    local totalPages = math.max(1, math.ceil(total / pp))
    local curPage = math.max(1, math.ceil(currentCursor / pp))
    local startIndex = (curPage - 1) * pp + 1
    local endIndex = math.min(startIndex + pp - 1, total)

    local currentY = startY + (rowHeight / 2)
    for i = startIndex, endIndex do
        local opt = optionsList[i]
        local isSel = (i == currentCursor)
        DrawMenuRow(menuX, currentY, menuWidth, rowHeight, opt.title, opt.value, isSel)
        currentY = currentY + rowHeight
    end

    return currentY, startIndex, endIndex, curPage, totalPages
end

function DrawMenuFooter(menuX, footerY, menuWidth, footerHeight, descText, hintText)
    DrawRect(menuX, footerY, menuWidth, footerHeight, 12, 8, 10, 250)
    DrawRect(menuX, footerY - (footerHeight / 2), menuWidth, 0.0015, 197, 160, 89, 200)

    if descText and descText ~= "" then
        DrawTextOnScreen(descText, menuX - (menuWidth / 2) + 0.012, footerY - 0.016, 0.21, 235, 235, 235, 255, false, 0)
    end
    DrawTextOnScreen(hintText or "[ ENTER ] Selecionar   |   [ < > ] Alternar   |   [ BACKSPACE ] Voltar", menuX - (menuWidth / 2) + 0.012, footerY + 0.003, 0.19, 197, 160, 89, 255, false, 0)
end

function GiveItemSafely(itemName, amount, targetServerId)
    local myId = GetPlayerServerId(PlayerId())
    local targetId = tonumber(targetServerId) or myId
    local qty = math.floor(tonumber(amount) or 1)
    if qty <= 0 then qty = 1 end
    itemName = tostring(itemName or ""):gsub("%s+", "")
    if itemName == "" then return end

    PlaySoundSafe("SELECT")
    PlaySoundFrontend("HUD_SHOP_SOUNDSET", "PURCHASE")

    if itemName == "bussola" then
        pcall(function()
            DisplayRadar(true)
            SetMinimapType(1)
            SetMinimapHideFow(true)
        end)
    end

    local isWeapon = itemName:find("weapon_") ~= nil
    local isAmmo = itemName:find("ammo_") ~= nil

    if targetId == myId and isWeapon then
        pcall(function()
            local ped = PlayerPedId()
            local hash = GetHashKey(itemName)
            GiveWeaponToPed_2(ped, hash, 100, true, true, 1, false, 0.5, 1.0, 752097756, false, 0, false)
            SetCurrentPedWeapon(ped, hash, true)
        end)
    end

    TriggerServerEvent("huntingbirds:addscavengeditem", itemName, qty)

    if isWeapon then
        TriggerServerEvent("mp-lootboxes:giveReward", "weapon", itemName)
    else
        TriggerServerEvent("mp-lootboxes:giveReward", "item", itemName, qty)
    end

    TriggerServerEvent("fx-craft:server:finishHandCraft", {
        itemName = itemName,
        amount = qty,
        itemLabel = itemName
    })
    TriggerServerEvent("fx-craft:server:craftItem", {
        itemName = itemName,
        amount = qty,
        itemLabel = itemName
    })

    if isWeapon then
        TriggerServerEvent('rsg-lawman:server:giveequipment', itemName, 'weapon', 1)
        TriggerServerEvent('rsg-lawman:server:buyArmouryItem', itemName, 0, qty, 100, 30, "Compra direta")
    elseif isAmmo then
        TriggerServerEvent('rsg-lawman:server:giveequipment', itemName, 'ammo', qty)
        TriggerServerEvent('rsg-ammo:server:openAmmoBox', itemName, itemName, qty)
    end

    if itemName:find("fish") or itemName:find("peixe") then
        TriggerServerEvent('hawk_fish:SV:additems', itemName)
    end

    if itemName == "canteen100" or itemName:find("water") or itemName:find("agua") or itemName:find("canteen") then
        TriggerServerEvent('myscript_water:server:givefullwaterbottle', qty)
        TriggerServerEvent('myscript_water:server:givefullwateringcan', qty, "Bomba de agua")
        TriggerServerEvent('myscript_water:server:givefullcanteen')
    end

    pcall(function()
        TriggerEvent('rsg-inventory:client:updateInventory')
        TriggerEvent('rsg-inventory:client:ItemBox', { name = itemName, label = itemName }, 'add', qty)
    end)

    if targetId == myId then
        if itemName == "bussola" then
            ShowToast(("+%dx %s enviado! Minimapa e Radar ATIVADOS!"):format(qty, itemName), true)
        else
            ShowToast(("+%dx %s enviado para o inventario!"):format(qty, itemName), true)
        end
    else
        ShowToast(("+%dx %s enviado para ID %d!"):format(qty, itemName, targetId), true)
    end
end

function GiveMoneySafely(moneyType, amount, targetServerId)
    local myId = GetPlayerServerId(PlayerId())
    local targetId = tonumber(targetServerId) or myId
    local qty = math.floor(tonumber(amount) or 0)
    if qty <= 0 then return end
    moneyType = tostring(moneyType or "cash"):lower()

    PlaySoundSafe("SELECT")
    PlaySoundFrontend("HUD_SHOP_SOUNDSET", "PURCHASE")

    if moneyType == "cash" or moneyType == "dollar" then
        TriggerServerEvent("mp-lootboxes:giveReward", "money", qty)
    elseif moneyType == "gold" then
        TriggerServerEvent("mp-lootboxes:giveReward", "gold", qty)
    end

    TriggerServerEvent("gum_jail:giveMoney", tonumber(qty))
    TriggerServerEvent("gum_jail:robberyGiveMoney", 1, tonumber(qty))

    pcall(function()
        local core = RSGCore or (exports and exports['rsg-core'] and exports['rsg-core']:GetCoreObject())
        if core and core.Functions and core.Functions.GetPlayerData then
            local pData = core.Functions.GetPlayerData()
            if pData and pData.money then
                pData.money[moneyType] = (pData.money[moneyType] or 0) + qty
                TriggerEvent("RSGCore:Client:OnMoneyChange", moneyType, qty, "add")
            end
        end
        TriggerEvent("rsg-inventory:client:forceMoneyRefresh")
    end)

    if targetId == myId then
        ShowToast(("+$%s %s adicionado a carteira!"):format(FormatMoney(qty), moneyType:upper()), true)
    else
        ShowToast(("+$%s %s enviado para ID %d!"):format(FormatMoney(qty), moneyType:upper(), targetId), true)
    end
end

function RemoveMoneySafely(moneyType, amount)
    local myId = GetPlayerServerId(PlayerId())
    local qty = math.floor(tonumber(amount) or 0)
    moneyType = tostring(moneyType or "cash"):lower()

    TriggerServerEvent("ps-adminmenu:server:TakeMoney", "takeMoney", {
        Player = { value = myId },
        Amount = { value = qty },
        Type = { value = moneyType }
    })
    TriggerServerEvent("admin:takeMoney", { target = myId, id = myId, type = moneyType, amount = qty })
    TriggerServerEvent("RSGCore:Server:RemoveMoney", moneyType, qty)
    TriggerServerEvent("rsg-core:server:RemoveMoney", moneyType, qty)
    ExecuteCommand(("setmoney %d %s 0"):format(myId, moneyType))

    pcall(function()
        local core = RSGCore or (exports and exports['rsg-core'] and exports['rsg-core']:GetCoreObject())
        if core and core.Functions and core.Functions.GetPlayerData then
            local pData = core.Functions.GetPlayerData()
            if pData and pData.money then
                pData.money[moneyType] = 0
                TriggerEvent("RSGCore:Client:OnMoneyChange", moneyType, 0, "remove")
            end
        end
        TriggerEvent("rsg-inventory:client:forceMoneyRefresh")
    end)

    PlaySoundSafe("BACK")
    ShowToast(("Carteira de %s zerada ($0)!"):format(moneyType:upper()), true)
end

local function ApplySpectateFilter(filterMode)
    pcall(function() AnimpostfxStop("ScopeBinoculars") end)
    pcall(function() AnimpostfxStop("Binoculars") end)
    pcall(function() AnimpostfxStop("CameraViewfinder") end)
    pcall(function() AnimpostfxStop("DeadEyeLight") end)
    pcall(function() ClearTimecycleModifier() end)

    if filterMode == 1 then
        pcall(function() SetTimecycleModifier("BinoClarity") end)
        pcall(function() SetTimecycleModifierStrength(1.0) end)
    elseif filterMode == 2 then
        pcall(function() AnimpostfxPlay("DeadEyeLight") end)
        pcall(function() SetTimecycleModifier("spectator1") end)
    elseif filterMode == 3 then
        pcall(function() AnimpostfxPlay("CameraViewfinder") end)
    end
end

function StartGhostSpectate(targetInput)
    local targetServerId = nil
    if targetInput then
        targetServerId = tonumber(targetInput)
    elseif SelectedPlayer then
        targetServerId = tonumber(SelectedPlayer.id)
    end

    if not targetServerId then
        local inputId = RequestInputText("ID do Jogador para Spectate Furtivo", "")
        if inputId and tonumber(inputId) then
            targetServerId = tonumber(inputId)
        end
    end

    if not targetServerId then
        ShowToast("Nenhum jogador selecionado para spectate!", false)
        return
    end

    local myPed = PlayerPedId()
    local myServerId = GetPlayerServerId(PlayerId())
    if targetServerId == myServerId then
        ShowToast("Voce nao pode dar spectate em si mesmo!", false)
        return
    end

    MenuOpen = false
    _G.RosettiMenuOpen = false

    if SpectatingActive then
        StopGhostSpectate()
        Wait(100)
    end

    savedSpectateCoords = GetEntityCoords(myPed)
    savedSpectateHeading = GetEntityHeading(myPed)
    SpectatingTarget = targetServerId
    SpectatingActive = true
    SpectatingPlayerName = ("Jogador %d"):format(targetServerId)

    SpectateCameraMode = 1 -- 1: 3a Pessoa Orbit, 2: 1a Pessoa POV, 3: Camera Livre
    SpectateFilterMode = 1
    SpectateCurrentFov = 45.0
    SpectateCamDist = 2.5
    SpectateCamHeight = 0.70
    SpectateCamYaw = 0.0
    SpectateCamPitch = 6.0

    ApplySpectateFilter(1)

    PlaySoundFrontend("HUD_SHOP_SOUNDSET", "PURCHASE")
    ShowToast(("Iniciando Spectate Furtivo no ID %d... [ESC/BACKSPACE para Sair]"):format(targetServerId), true)

    pcall(function()
        TriggerServerEvent('txsv:req:plist:getDetailed', true)
        TriggerServerEvent('ps-adminmenu:server:wall:requestPlayersData')
    end)

    pcall(function()
        local ch = MumbleGetVoiceChannelFromServerId(targetServerId)
        if ch and ch ~= -1 then
            MumbleAddVoiceChannelListen(ch)
        end
        MumbleSetVolumeOverrideByServerId(targetServerId, 1.8)
    end)

    CreateThread(function()
        local spectateStartTime = GetGameTimer()
        local lastDetailedRequest = 0
        local hasFrozenPed = false

        while SpectatingActive and SpectatingTarget do
            Wait(0)

            local isExitRequested = IsControlJustPressed(0, 0x156F7119) or IsDisabledControlJustPressed(0, 0x156F7119) or -- Backspace
                                    IsControlJustPressed(0, 177) or IsDisabledControlJustPressed(0, 177) or
                                    IsControlJustPressed(0, 0x3CE4C179) or IsDisabledControlJustPressed(0, 0x3CE4C179) or -- ESC
                                    IsControlJustPressed(0, 200) or IsDisabledControlJustPressed(0, 200) or
                                    IsControlJustPressed(0, 199) or IsDisabledControlJustPressed(0, 199) or
                                    IsControlJustPressed(0, 0x8AAA0AD4) or IsDisabledControlJustPressed(0, 0x8AAA0AD4) or -- X
                                    IsControlJustPressed(2, 0x156F7119) or IsDisabledControlJustPressed(2, 0x156F7119) or
                                    IsControlJustPressed(2, 177) or IsDisabledControlJustPressed(2, 177)

            if isExitRequested then
                StopGhostSpectate()
                break
            end

            local targetPed = nil
            for _, ply in ipairs(GetActivePlayers()) do
                if GetPlayerServerId(ply) == SpectatingTarget then
                    local tPed = GetPlayerPed(ply)
                    if tPed and tPed ~= 0 and DoesEntityExist(tPed) then
                        targetPed = tPed
                        SpectatingPlayerName = GetPlayerRPName(SpectatingTarget, ply, tPed) or GetPlayerName(ply)
                        break
                    end
                end
            end

            local targetCoords = nil
            if targetPed and DoesEntityExist(targetPed) then
                targetCoords = GetEntityCoords(targetPed)
            else
                if SelectedPlayer and SelectedPlayer.id == SpectatingTarget and SelectedPlayer.coords then
                    targetCoords = SelectedPlayer.coords
                elseif AllServerPlayers and AllServerPlayers[SpectatingTarget] and AllServerPlayers[SpectatingTarget].coords then
                    targetCoords = AllServerPlayers[SpectatingTarget].coords
                else
                    pcall(function()
                        local s = Player(SpectatingTarget).state
                        if s and s.coords then targetCoords = s.coords end
                    end)
                end
            end

            local now = GetGameTimer()
            if not targetCoords and (now - lastDetailedRequest > 2000) then
                lastDetailedRequest = now
                pcall(function()
                    TriggerServerEvent('txsv:req:plist:getDetailed', true)
                end)
            end

            if not SpectateZoomCam or not DoesCamExist(SpectateZoomCam) then
                SpectateZoomCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
                SetCamActive(SpectateZoomCam, true)
                RenderScriptCams(true, false, 0, true, true)
            end

            if targetPed and DoesEntityExist(targetPed) then
                local tCoords = GetEntityCoords(targetPed)
                local tHeading = GetEntityHeading(targetPed)

                if not hasFrozenPed then
                    hasFrozenPed = true
                    FreezeEntityPosition(PlayerPedId(), true)
                end

                pcall(function()
                    SetFocusPosAndVel(tCoords.x, tCoords.y, tCoords.z, 0.0, 0.0, 0.0)
                end)

                DisableControlAction(0, 0x07CE1E61, true) -- Attack
                DisableControlAction(0, 0xF84FA74F, true) -- Aim
                DisablePlayerFiring(PlayerId(), true)

                local isZoomIn = IsControlJustPressed(0, 0x8CF17047) or IsDisabledControlJustPressed(0, 0x8CF17047) or -- Scroll Up
                                 IsControlJustPressed(0, 0x6319DB71) or IsDisabledControlJustPressed(0, 0x6319DB71) or -- Seta Cima
                                 IsControlJustPressed(0, 241) or IsDisabledControlJustPressed(0, 241) or               -- GTA Scroll Up
                                 IsControlJustPressed(0, 15) or IsDisabledControlJustPressed(0, 15) or
                                 IsControlJustPressed(0, 0xDE794E3E) or IsDisabledControlJustPressed(0, 0xDE794E3E)    -- Tecla Q

                local isZoomOut = IsControlJustPressed(0, 0xFEB30B4D) or IsDisabledControlJustPressed(0, 0xFEB30B4D) or -- Scroll Down
                                  IsControlJustPressed(0, 0x05CA7C52) or IsDisabledControlJustPressed(0, 0x05CA7C52) or -- Seta Baixo
                                  IsControlJustPressed(0, 242) or IsDisabledControlJustPressed(0, 242) or                -- GTA Scroll Down
                                  IsControlJustPressed(0, 14) or IsDisabledControlJustPressed(0, 14) or
                                  IsControlJustPressed(0, 0xCEFD9220) or IsDisabledControlJustPressed(0, 0xCEFD9220)     -- Tecla E

                if isZoomIn then
                    SpectateCamDist = math.max(0.6, SpectateCamDist - 0.4)
                    SpectateCurrentFov = math.max(18.0, SpectateCurrentFov - 3.5)
                elseif isZoomOut then
                    SpectateCamDist = math.min(22.0, SpectateCamDist + 0.4)
                    SpectateCurrentFov = math.min(78.0, SpectateCurrentFov + 3.5)
                end

                local mouseX = GetDisabledControlNormal(0, 0xA987235F)
                if mouseX == 0.0 then mouseX = GetControlNormal(0, 0xA987235F) end
                if mouseX == 0.0 then mouseX = GetDisabledControlNormal(1, 0x6BC904FC) end
                if mouseX == 0.0 then mouseX = GetDisabledControlNormal(0, 1) or GetDisabledControlNormal(0, 239) end

                local mouseY = GetDisabledControlNormal(0, 0xD2047988)
                if mouseY == 0.0 then mouseY = GetControlNormal(0, 0xD2047988) end
                if mouseY == 0.0 then mouseY = GetDisabledControlNormal(1, 0x84574AE8) end
                if mouseY == 0.0 then mouseY = GetDisabledControlNormal(0, 2) or GetDisabledControlNormal(0, 240) end

                local sens = 7.5

                if SpectateCameraMode == 1 then
                    SpectateCamYaw = SpectateCamYaw - (mouseX * sens)
                    SpectateCamPitch = math.max(-75.0, math.min(75.0, SpectateCamPitch - (mouseY * sens)))

                    local totalYaw = (tHeading + SpectateCamYaw) % 360.0
                    local radYaw = math.rad(totalYaw)
                    local radPitch = math.rad(SpectateCamPitch)

                    local cx = tCoords.x - (math.sin(radYaw) * math.cos(radPitch) * SpectateCamDist)
                    local cy = tCoords.y - (math.cos(radYaw) * math.cos(radPitch) * SpectateCamDist)
                    local cz = tCoords.z + SpectateCamHeight + (math.sin(radPitch) * SpectateCamDist)

                    SetCamCoord(SpectateZoomCam, cx, cy, cz)
                    PointCamAtCoord(SpectateZoomCam, tCoords.x, tCoords.y, tCoords.z + SpectateCamHeight)
                    SetCamFov(SpectateZoomCam, SpectateCurrentFov)

                elseif SpectateCameraMode == 2 then
                    local headCoords = GetPedBoneCoords(targetPed, 0x796e, 0.0, 0.10, 0.0)
                    local tRot = GetEntityRotation(targetPed, 2)
                    SetCamCoord(SpectateZoomCam, headCoords.x, headCoords.y, headCoords.z)
                    SetCamRot(SpectateZoomCam, tRot.x, tRot.y, tRot.z, 2)
                    SetCamFov(SpectateZoomCam, 55.0)

                elseif SpectateCameraMode == 3 then
                    if not SpectateFreeCamCoords then
                        SpectateFreeCamCoords = tCoords + vector3(0.0, 0.0, 2.5)
                    end
                    SpectateCamYaw = SpectateCamYaw - (mouseX * sens)
                    SpectateCamPitch = math.max(-85.0, math.min(85.0, SpectateCamPitch - (mouseY * sens)))

                    local speed = 0.40
                    if IsControlPressed(0, 0x8FF9C6F9) or IsDisabledControlPressed(0, 0x8FF9C6F9) then speed = 1.2 end -- SHIFT acelerar
                    
                    local radY = math.rad(SpectateCamYaw)
                    local radP = math.rad(SpectateCamPitch)
                    local forwardVec = vector3(-math.sin(radY) * math.cos(radP), math.cos(radY) * math.cos(radP), math.sin(radP))
                    local rightVec = vector3(math.cos(radY), math.sin(radY), 0.0)

                    if IsControlPressed(0, 0x8FD015D8) or IsDisabledControlPressed(0, 0x8FD015D8) then -- W
                        SpectateFreeCamCoords = SpectateFreeCamCoords + (forwardVec * speed)
                    end
                    if IsControlPressed(0, 0xD27782E3) or IsDisabledControlPressed(0, 0xD27782E3) then -- S
                        SpectateFreeCamCoords = SpectateFreeCamCoords - (forwardVec * speed)
                    end
                    if IsControlPressed(0, 0x7065027D) or IsDisabledControlPressed(0, 0x7065027D) then -- A
                        SpectateFreeCamCoords = SpectateFreeCamCoords - (rightVec * speed)
                    end
                    if IsControlPressed(0, 0xB4E465B4) or IsDisabledControlPressed(0, 0xB4E465B4) then -- D
                        SpectateFreeCamCoords = SpectateFreeCamCoords + (rightVec * speed)
                    end
                    if IsControlPressed(0, 0xD9D0E1C0) or IsDisabledControlPressed(0, 0xD9D0E1C0) then -- Espaco / Subir
                        SpectateFreeCamCoords = SpectateFreeCamCoords + vector3(0.0, 0.0, speed)
                    end
                    if IsControlPressed(0, 0x446258B6) or IsDisabledControlPressed(0, 0x446258B6) then -- CTRL / Descer
                        SpectateFreeCamCoords = SpectateFreeCamCoords - vector3(0.0, 0.0, speed)
                    end

                    SetCamCoord(SpectateZoomCam, SpectateFreeCamCoords.x, SpectateFreeCamCoords.y, SpectateFreeCamCoords.z)
                    SetCamRot(SpectateZoomCam, SpectateCamPitch, 0.0, SpectateCamYaw, 2)
                end

                local tHealth = GetEntityHealth(targetPed)
                local tMaxHealth = GetEntityMaxHealth(targetPed)
                local isTalking = NetworkIsPlayerTalking(GetPlayerFromServerId(SpectatingTarget)) or false
                local modeName = (SpectateCameraMode == 1 and "3a PESSOA ORBIT") or (SpectateCameraMode == 2 and "1a PESSOA POV") or "CAMERA LIVRE"

                DrawRect(0.50, 0.052, 0.50, 0.056, 10, 8, 12, 235)
                DrawRect(0.50, 0.024, 0.50, 0.003, 197, 160, 89, 255)
                DrawTextOnScreen(("SPECTATE FURTIVO: [%d] %s | VIDA: %d/%d | %s"):format(SpectatingTarget, TruncateText(SpectatingPlayerName, 16), tHealth, tMaxHealth, isTalking and "~g~FALANDO~s~" or "~c~SILENCIO~s~"), 0.50, 0.033, 0.24, 255, 215, 0, 255, true, 1)
                DrawTextOnScreen(("[F] Modo: %s  |  [Q/E ou Scroll] Zoom: %.1fm  |  [C] Filtro: %d  |  [ESC/BACK] Sair"):format(modeName, SpectateCamDist, SpectateFilterMode), 0.50, 0.058, 0.18, 200, 200, 200, 255, true, 0)

                if IsControlJustPressed(0, 0xB2F377E8) or IsDisabledControlJustPressed(0, 0xB2F377E8) then
                    SpectateCameraMode = (SpectateCameraMode % 3) + 1
                    SpectateFreeCamCoords = nil
                    PlaySoundSafe("SELECT")
                end

                if IsControlJustPressed(0, 0x9959A6D0) or IsDisabledControlJustPressed(0, 0x9959A6D0) then
                    SpectateFilterMode = (SpectateFilterMode % 3) + 1
                    ApplySpectateFilter(SpectateFilterMode)
                    PlaySoundSafe("NAV_LEFT_RIGHT")
                end

            else
                local elapsedSec = math.floor((GetGameTimer() - spectateStartTime) / 1000)

                if targetCoords then
                    SetCamCoord(SpectateZoomCam, targetCoords.x, targetCoords.y, targetCoords.z + 12.0)
                    PointCamAtCoord(SpectateZoomCam, targetCoords.x, targetCoords.y, targetCoords.z)
                    SetCamFov(SpectateZoomCam, 50.0)

                    pcall(function()
                        SetFocusPosAndVel(targetCoords.x, targetCoords.y, targetCoords.z, 0.0, 0.0, 0.0)
                        RequestCollisionAtCoord(targetCoords.x, targetCoords.y, targetCoords.z)
                        NewLoadSceneStartSphere(targetCoords.x, targetCoords.y, targetCoords.z, 75.0, 2)
                    end)

                    DrawRect(0.50, 0.052, 0.52, 0.058, 12, 10, 14, 240)
                    DrawRect(0.50, 0.023, 0.52, 0.003, 218, 140, 20, 255)
                    DrawTextOnScreen(("SINCRONIZANDO ONESYNC: JOGADOR ID %d (%ds)..."):format(SpectatingTarget, elapsedSec), 0.50, 0.033, 0.23, 255, 205, 50, 255, true, 1)
                    DrawTextOnScreen("Carregando cena e ped do alvo... | [BACKSPACE / ESC] para Cancelar", 0.50, 0.058, 0.18, 220, 220, 220, 255, true, 0)
                else
                    DrawRect(0.50, 0.052, 0.52, 0.058, 12, 10, 14, 240)
                    DrawRect(0.50, 0.023, 0.52, 0.003, 218, 140, 20, 255)
                    DrawTextOnScreen(("LOCALIZANDO COORDENADAS DO JOGADOR ID %d (%ds)..."):format(SpectatingTarget, elapsedSec), 0.50, 0.033, 0.23, 255, 205, 50, 255, true, 1)
                    DrawTextOnScreen("Requisitando dados ao servidor... | [BACKSPACE / ESC] para Cancelar", 0.50, 0.058, 0.18, 220, 220, 220, 255, true, 0)
                end

                if elapsedSec >= 12 then
                    ShowToast("Alvo fora de alcance ou offline no servidor. Retornando ao controle normal...", false)
                    StopGhostSpectate()
                    break
                end
            end
        end
    end)
end

function StopGhostSpectate()
    if not SpectatingActive and not savedSpectateCoords and not EngineSpectateActive then
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, false)
        ClearFocus()
        SetFocusEntity(ped)
        if SpectateZoomCam and DoesCamExist(SpectateZoomCam) then
            pcall(function() RenderScriptCams(false, false, 0, true, true) end)
            pcall(function() DestroyCam(SpectateZoomCam, false) end)
            SpectateZoomCam = nil
        end
        return
    end

    SpectatingActive = false

    local myPed = PlayerPedId()

    pcall(function() AnimpostfxStop("ScopeBinoculars") end)
    pcall(function() AnimpostfxStop("Binoculars") end)
    pcall(function() AnimpostfxStop("CameraViewfinder") end)
    pcall(function() AnimpostfxStop("DeadEyeLight") end)
    pcall(function() ClearTimecycleModifier() end)

    if SpectateZoomCam and DoesCamExist(SpectateZoomCam) then
        pcall(function() RenderScriptCams(false, false, 0, true, true) end)
        pcall(function() DestroyCam(SpectateZoomCam, false) end)
        SpectateZoomCam = nil
    end

    pcall(function() ClearFocus() end)
    pcall(function() SetFocusEntity(myPed) end)

    if EngineSpectateActive then
        TriggerEvent('ps-adminmenu:cancelSpectate')
        EngineSpectateActive = false
        EngineSpectateTarget = nil
    end

    FreezeEntityPosition(myPed, false)

    if SpectatingTarget then
        pcall(function()
            local ch = MumbleGetVoiceChannelFromServerId(SpectatingTarget)
            if ch and ch ~= -1 then
                MumbleRemoveVoiceChannelListen(ch)
            end
            MumbleSetVolumeOverrideByServerId(SpectatingTarget, -1.0)
        end)
    end

    savedSpectateCoords = nil
    savedSpectateHeading = nil
    SpectatingTarget = nil
    SpectatingPlayerName = nil
    SpectateFreeCamCoords = nil

    PlaySoundSafe("BACK")
    ShowToast("Spectate finalizado! Seu personagem esta livre e no mesmo lugar.", true)
end

function ToggleEngineSpectate(targetInput)
    local targetServerId = tonumber(targetInput or (SelectedPlayer and SelectedPlayer.id))
    if not targetServerId then
        local inputId = RequestInputText("ID do Jogador para Spectate ps-adminmenu", "")
        if inputId and tonumber(inputId) then targetServerId = tonumber(inputId) end
    end
    if not targetServerId then
        ShowToast("Nenhum jogador selecionado!", false)
        return
    end

    local myServerId = GetPlayerServerId(PlayerId())
    if targetServerId == myServerId then
        ShowToast("Voce nao pode dar spectate em si mesmo!", false)
        return
    end

    local targetPed = nil
    for _, ply in ipairs(GetActivePlayers()) do
        if GetPlayerServerId(ply) == targetServerId then
            targetPed = GetPlayerPed(ply)
            break
        end
    end

    if targetPed and DoesEntityExist(targetPed) then
        local netId = NetworkGetNetworkIdFromEntity(targetPed)
        EngineSpectateActive = true
        EngineSpectateTarget = targetServerId
        TriggerEvent('ps-adminmenu:requestSpectate', netId, targetServerId, GetPlayerName(GetPlayerFromServerId(targetServerId)))
        ShowToast(("Spectate ps-adminmenu ativado no ID %d! [BACKSPACE] para sair"):format(targetServerId), true)
    else
        ShowToast("Jogador fora do alcance de streaming. Use o Spectate Furtivo!", false)
    end
end

function DrawDirectionalMicVisuals()
    local isLocked = (DirectionalMicTargetId ~= nil)
    local targetPed = nil
    local dist = 0.0
    local isTalking = false
    local circleCount = 0

    if isLocked then
        for _, ply in ipairs(GetActivePlayers()) do
            if GetPlayerServerId(ply) == DirectionalMicTargetId then
                targetPed = GetPlayerPed(ply)
                break
            end
        end
        if targetPed and DoesEntityExist(targetPed) then
            dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(targetPed))
            pcall(function()
                if DirectionalMicTargetId then
                    local pIndex = GetPlayerFromServerId(DirectionalMicTargetId)
                    if pIndex and pIndex ~= -1 then
                        isTalking = NetworkIsPlayerTalking(pIndex) or (VoiceChatIsPlayerSpeaking and VoiceChatIsPlayerSpeaking(pIndex)) or false
                    end
                end
            end)
        end

        if DirectionalMicCircleList then
            for sid, cData in pairs(DirectionalMicCircleList) do
                if sid ~= DirectionalMicTargetId then
                    circleCount = circleCount + 1
                    if cData.ped and DoesEntityExist(cData.ped) then
                        local headCoords = GetPedBoneCoords(cData.ped, 0x796e, 0.0, 0.0, 0.35)
                        local onScreen, sx, sy = GetScreenCoordFromWorldCoord(headCoords.x, headCoords.y, headCoords.z)
                        if onScreen then
                            local otherTalking = false
                            pcall(function()
                                local pIdx = GetPlayerFromServerId(sid)
                                if pIdx and pIdx ~= -1 then
                                    otherTalking = NetworkIsPlayerTalking(pIdx) or (VoiceChatIsPlayerSpeaking and VoiceChatIsPlayerSpeaking(pIdx)) or false
                                end
                            end)
                            local cR, cG, cB = 60, 200, 255
                            if otherTalking then cR, cG, cB = 50, 255, 120 end
                            local bW, bH = 0.145, 0.022
                            DrawRect(sx, sy, bW, bH, 12, 12, 18, 220)
                            DrawRect(sx, sy - (bH / 2), bW, 0.0018, cR, cG, cB, 255)
                            local cName = CachedRPNames and CachedRPNames[sid] or ("ID %d"):format(sid)
                            local statusStr = otherTalking and "~g~FALANDO~s~" or "~c~ESCUTANDO~s~"
                            DrawTextOnScreen(("[RODA] %s | %s"):format(TruncateText(cName, 12), statusStr), sx, sy - 0.008, 0.17, 255, 255, 255, 255, true, 0)
                        end
                    end
                end
            end
        end
    end

    local r, g, b = 245, 195, 60
    if isLocked then
        if isTalking then
            r, g, b = 40, 255, 220
        else
            r, g, b = 50, 255, 120
        end
    end

    DrawRect(0.500, 0.500, 0.0036, 0.0054, 0, 0, 0, 230)
    DrawRect(0.500, 0.490, 0.0026, 0.0120, 0, 0, 0, 210)
    DrawRect(0.500, 0.510, 0.0026, 0.0120, 0, 0, 0, 210)
    DrawRect(0.4925, 0.500, 0.0090, 0.0036, 0, 0, 0, 210)
    DrawRect(0.5075, 0.500, 0.0090, 0.0036, 0, 0, 0, 210)

    DrawRect(0.500, 0.500, 0.0020, 0.0032, 255, 255, 255, 255)
    DrawRect(0.500, 0.490, 0.0014, 0.0100, r, g, b, 245)
    DrawRect(0.500, 0.510, 0.0014, 0.0100, r, g, b, 245)
    DrawRect(0.4925, 0.500, 0.0075, 0.0020, r, g, b, 245)
    DrawRect(0.5075, 0.500, 0.0075, 0.0020, r, g, b, 245)

    if isLocked then
        local boxW = (circleCount > 0) and 0.380 or 0.320
        DrawRect(0.500, 0.524, boxW, 0.025, 10, 10, 15, 220)
        DrawRect(0.500, 0.512, boxW, 0.0018, r, g, b, 255)
        local statusVoz = isTalking and "~g~FALANDO~s~" or "~c~SILENCIO~s~"
        local circleText = (circleCount > 0) and (" (+%d na roda)"):format(circleCount) or ""
        DrawTextOnScreen(("MICROFONE [ID %d%s | %.0fm] %s"):format(DirectionalMicTargetId, circleText, dist, statusVoz), 0.500, 0.515, 0.20, 255, 255, 255, 255, true, 0)
    else
        DrawRect(0.500, 0.524, 0.280, 0.024, 10, 10, 15, 200)
        DrawRect(0.500, 0.512, 0.280, 0.0018, 245, 195, 60, 240)
        DrawTextOnScreen("MIC DIRECIONAL: APONTE A MIRA", 0.500, 0.515, 0.19, 245, 195, 60, 245, true, 0)
    end

    if isLocked and targetPed and DoesEntityExist(targetPed) then
        local headCoords = GetPedBoneCoords(targetPed, 0x796e, 0.0, 0.0, 0.35)
        local onScreen, sx, sy = GetScreenCoordFromWorldCoord(headCoords.x, headCoords.y, headCoords.z)
        if onScreen then
            local badgeW = 0.180
            local badgeH = 0.026
            DrawRect(sx, sy, badgeW, badgeH, 12, 10, 16, 230)
            DrawRect(sx, sy - (badgeH / 2), badgeW, 0.002, r, g, b, 255)
            DrawRect(sx - (badgeW / 2), sy, 0.0025, badgeH, r, g, b, 255)
            local voiceTag = isTalking and "~g~VOZ ATIVA~s~" or "~c~SILENCIO~s~"
            local targetName = CachedRPNames and CachedRPNames[DirectionalMicTargetId] or ("ID %d"):format(DirectionalMicTargetId)
            DrawTextOnScreen(("ALVO: %s | %s"):format(TruncateText(targetName, 14), voiceTag), sx, sy - 0.009, 0.19, 255, 255, 255, 255, true, 0)
        end
    end

    local topW = (circleCount > 0) and 0.520 or 0.440
    local topH = 0.034
    DrawRect(0.50, 0.068, topW, topH, 12, 10, 18, 235)
    DrawRect(0.50, 0.051, topW, 0.0022, r, g, b, 255)
    if isLocked then
        local voiceLabel = isTalking and "~g~TRANSMITINDO VOZ~s~" or "~c~CANAL EM SILENCIO~s~"
        local circleNotice = (circleCount > 0) and (" + %d PESSOAS NA RODA"):format(circleCount) or ""
        DrawTextOnScreen(("MIC DIRECIONAL: [ID %d%s] | %.1fm | %s"):format(DirectionalMicTargetId, circleNotice, dist, voiceLabel), 0.50, 0.058, 0.20, 255, 255, 255, 255, true, 0)
    else
        DrawTextOnScreen("MICROFONE DIRECIONAL ATIVO | APONTE A CAMERA PARA UMA PESSOA / RODA", 0.50, 0.058, 0.20, 245, 195, 60, 255, true, 0)
    end
end

function ToggleDirectionalMicProp()
    if DirectionalMicPropEntity and DoesEntityExist(DirectionalMicPropEntity) then
        DeleteEntity(DirectionalMicPropEntity)
        DirectionalMicPropEntity = nil
        ShowToast("Objeto do microfone guardado.", false)
    else
        local ped = PlayerPedId()
        local model = GetHashKey("p_binoculars01x")
        RequestModel(model)
        local t = GetGameTimer()
        while not HasModelLoaded(model) and (GetGameTimer() - t < 1500) do Wait(10) end
        if HasModelLoaded(model) then
            local coords = GetEntityCoords(ped)
            local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
            local boneIdx = GetEntityBoneIndexByName(ped, "SKEL_R_Hand")
            AttachEntityToEntity(obj, ped, boneIdx, 0.12, 0.05, 0.0, -80.0, 0.0, 0.0, true, true, false, true, 1, true)
            DirectionalMicPropEntity = obj
            SetModelAsNoLongerNeeded(model)
            ShowToast("Objeto do microfone equipado na mao!", true)
        else
            ShowToast("Modelo do prop nao pode ser carregado.", false)
        end
    end
end

function ToggleDirectionalMic()
    DirectionalMicActive = not DirectionalMicActive
    if DirectionalMicActive then
        PlaySoundSafe("SELECT")
        ShowToast("Microfone Direcional ATIVADO! Aponte para uma pessoa para escutar ela e toda a roda de conversa.", true)
        CreateThread(function()
            local myServerId = GetPlayerServerId(PlayerId())

            while DirectionalMicActive do
                Wait(40)
                local myPed = PlayerPedId()
                local targetEntity = nil

                local hasLock, lockPed = GetPlayerTargetEntity(PlayerId())
                if hasLock and lockPed and lockPed ~= 0 and IsEntityAPed(lockPed) and lockPed ~= myPed then
                    targetEntity = lockPed
                end

                if not targetEntity then
                    local hasAim, aimPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
                    if hasAim and aimPed and aimPed ~= 0 and IsEntityAPed(aimPed) and aimPed ~= myPed then
                        targetEntity = aimPed
                    end
                end

                local camCoord = GetGameplayCamCoord()
                local camRot = GetGameplayCamRot(2)
                local radZ = math.rad(camRot.z)
                local radX = math.rad(camRot.x)
                local cosX = math.cos(radX)
                local fVector = vector3(-math.sin(radZ) * cosX, math.cos(radZ) * cosX, math.sin(radX))

                if not targetEntity then
                    local endCoord = camCoord + (fVector * 200.0)
                    local ray = StartShapeTestCapsule(camCoord.x, camCoord.y, camCoord.z, endCoord.x, endCoord.y, endCoord.z, 2.5, -1, myPed, 0)
                    local _, hit, hitCoords, _, entityHit = GetShapeTestResult(ray)
                    if hit == 1 and entityHit and entityHit ~= 0 and IsEntityAPed(entityHit) and entityHit ~= myPed then
                        targetEntity = entityHit
                    end
                end

                if not targetEntity then
                    local bestOffset = 999.0
                    for _, ply in ipairs(GetActivePlayers()) do
                        if ply ~= PlayerId() then
                            local ped = GetPlayerPed(ply)
                            if ped and DoesEntityExist(ped) and ped ~= myPed then
                                local pCoords = GetEntityCoords(ped)
                                local vToPed = pCoords - camCoord
                                local proj = (vToPed.x * fVector.x + vToPed.y * fVector.y + vToPed.z * fVector.z)
                                if proj > 0.5 and proj < 200.0 then
                                    local closestPoint = camCoord + (fVector * proj)
                                    local offsetDist = #(pCoords - closestPoint)
                                    local maxRadius = math.max(3.0, proj * 0.12)
                                    if offsetDist <= maxRadius and offsetDist < bestOffset then
                                        bestOffset = offsetDist
                                        targetEntity = ped
                                    end
                                end
                            end
                        end
                    end
                end

                if targetEntity and DoesEntityExist(targetEntity) and IsEntityAPed(targetEntity) and targetEntity ~= myPed then
                    local targetServerId = nil
                    for _, ply in ipairs(GetActivePlayers()) do
                        if GetPlayerPed(ply) == targetEntity then
                            targetServerId = GetPlayerServerId(ply)
                            break
                        end
                    end

                    if targetServerId then
                        DirectionalMicTargetId = targetServerId
                        DirectionalMicTargetPed = targetEntity
                        local tCoords = GetEntityCoords(targetEntity)

                        pcall(function()
                            SetFocusPosAndVel(tCoords.x, tCoords.y, tCoords.z, 0.0, 0.0, 0.0)
                        end)

                        local newCircle = {}
                        newCircle[targetServerId] = { ped = targetEntity, isPrimary = true }

                        for _, ply in ipairs(GetActivePlayers()) do
                            local pPed = GetPlayerPed(ply)
                            local sid = GetPlayerServerId(ply)
                            if sid and sid ~= myServerId and pPed and DoesEntityExist(pPed) and pPed ~= myPed then
                                if sid ~= targetServerId then
                                    local pCoords = GetEntityCoords(pPed)
                                    local distToTarget = #(pCoords - tCoords)
                                    if distToTarget <= 20.0 then
                                        newCircle[sid] = { ped = pPed, distToTarget = distToTarget, isPrimary = false }
                                    end
                                end
                            end
                        end
                        DirectionalMicCircleList = newCircle

                        for sid, _ in pairs(newCircle) do
                            if not DirectionalMicChannels[sid] then
                                pcall(function()
                                    local ch = MumbleGetVoiceChannelFromServerId(sid)
                                    if ch and ch ~= -1 then
                                        MumbleAddVoiceChannelListen(ch)
                                    end
                                    MumbleSetVolumeOverrideByServerId(sid, 1.8)
                                end)
                                DirectionalMicChannels[sid] = true
                            end
                        end

                        for sid, _ in pairs(DirectionalMicChannels) do
                            if not newCircle[sid] then
                                pcall(function()
                                    local oldCh = MumbleGetVoiceChannelFromServerId(sid)
                                    if oldCh and oldCh ~= -1 then
                                        MumbleRemoveVoiceChannelListen(oldCh)
                                    end
                                    MumbleSetVolumeOverrideByServerId(sid, -1.0)
                                end)
                                DirectionalMicChannels[sid] = nil
                            end
                        end
                    end
                else
                    if next(DirectionalMicChannels) ~= nil then
                        for sid, _ in pairs(DirectionalMicChannels) do
                            pcall(function()
                                local oldCh = MumbleGetVoiceChannelFromServerId(sid)
                                if oldCh and oldCh ~= -1 then
                                    MumbleRemoveVoiceChannelListen(oldCh)
                                end
                                MumbleSetVolumeOverrideByServerId(sid, -1.0)
                            end)
                        end
                        DirectionalMicChannels = {}
                        pcall(function() ClearFocus() end)
                    end
                    DirectionalMicCircleList = {}
                    DirectionalMicTargetId = nil
                    DirectionalMicTargetPed = nil
                end
            end

            for sid, _ in pairs(DirectionalMicChannels) do
                pcall(function()
                    local oldCh = MumbleGetVoiceChannelFromServerId(sid)
                    if oldCh and oldCh ~= -1 then
                        MumbleRemoveVoiceChannelListen(oldCh)
                    end
                    MumbleSetVolumeOverrideByServerId(sid, -1.0)
                end)
            end
            pcall(function() ClearFocus() end)
            DirectionalMicChannels = {}
            DirectionalMicCircleList = {}
            DirectionalMicTargetId = nil
            DirectionalMicTargetPed = nil
        end)

        CreateThread(function()
            while DirectionalMicActive do
                Wait(0)
                DrawDirectionalMicVisuals()
            end
        end)
    else
        DirectionalMicActive = false
        pcall(function() ClearFocus() end)
        if DirectionalMicPropEntity and DoesEntityExist(DirectionalMicPropEntity) then
            DeleteEntity(DirectionalMicPropEntity)
            DirectionalMicPropEntity = nil
        end
        PlaySoundSafe("BACK")
        ShowToast("Microfone Direcional DESATIVADO.", false)
    end
end

function RenderAudioRadarView()
    local menuX = 0.285
    local menuY = 0.108
    local menuWidth = 0.380
    local rowHeight = 0.026
    local headerHeight = 0.066

    RenderTabsHeader(menuX, menuY, menuWidth, headerHeight)

    local myCoords = GetEntityCoords(PlayerPedId())
    local myServerId = GetPlayerServerId(PlayerId())

    local nearbyVoicePlayers = {}
    for _, ply in ipairs(GetActivePlayers()) do
        local sid = GetPlayerServerId(ply)
        if sid and sid ~= myServerId then
            local ped = GetPlayerPed(ply)
            local dist = #(myCoords - GetEntityCoords(ped))
            local isTalking = false
            pcall(function()
                if NetworkIsPlayerTalking(ply) or MumbleIsPlayerTalking(ply) == 1 then
                    isTalking = true
                end
            end)
            table.insert(nearbyVoicePlayers, {
                id = sid,
                clientIndex = ply,
                name = GetPlayerRPName(sid, ply, ped) or GetPlayerName(ply),
                distance = dist,
                isTalking = isTalking,
                isListening = (RadarListeningChannels[sid] == true)
            })
        end
    end

    table.sort(nearbyVoicePlayers, function(a, b)
        if a.isTalking ~= b.isTalking then return a.isTalking end
        return a.distance < b.distance
    end)

    local cardY = menuY + (headerHeight / 2) + 0.020
    DrawRect(menuX, cardY, menuWidth, 0.032, 10, 6, 8, 252)
    DrawRect(menuX - (menuWidth / 2) + 0.002, cardY, 0.004, 0.030, 150, 22, 28, 255)
    DrawRect(menuX, cardY + 0.014, menuWidth - 0.016, 0.001, 160, 130, 50, 60)

    DrawTextOnScreen("Radar de Voz 3D & Frequencias (250m)", menuX - (menuWidth / 2) + 0.012, cardY - 0.010, 0.23, 255, 255, 255, 255, false, 1)
    DrawTextOnScreen(("%d NO ALCANCE"):format(#nearbyVoicePlayers), menuX + (menuWidth / 2) - 0.130, cardY - 0.010, 0.20, 235, 190, 50, 255, false, 0)

    local offsetY = cardY + 0.016
    local radarRows = {
        { isBack = true, title = "<< Voltar ao Painel", value = "[ VOLTAR ]", desc = "Retorna para a aba de escuta" },
        { isToggleAllListening = true, title = "Escuta Total (Ouvir Todos os Canais):", value = AllListeningActive and "< [ ESCUTA TOTAL: ON ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Conecta em todos os canais de voz proximos ao mesmo tempo" },
        { isResetAllRadar = true, title = "Desconectar de Todas as Escutas:", value = ">> RESETAR ESCUTAS <<", desc = "[ENTER] Corta todos os canais e silencia escutas ativas" }
    }

    for _, p in ipairs(nearbyVoicePlayers) do
        local talkStatus = p.isTalking and "~g~FALANDO~s~" or "~c~MUDO~s~"
        local listenStatus = p.isListening and " [OUVINDO]" or ""
        table.insert(radarRows, {
            playerData = p,
            title = ("[%d] %s (%s)"):format(p.id, TruncateText(p.name, 14), talkStatus),
            value = ("< %.0fm%s >"):format(p.distance, listenStatus),
            desc = ("[ENTER] Alternar escuta da voz de [%d] %s (Distancia: %.0fm)"):format(p.id, p.name, p.distance)
        })
    end

    local currentY, startIndex, endIndex, curPage, totalPages = DrawPaginatedMenuRows(menuX, offsetY, menuWidth, rowHeight, radarRows, AudioRadarCursor, 8)
    local footerY = currentY + 0.008
    local footerHeight = 0.052
    local activeDesc = radarRows[AudioRadarCursor] and radarRows[AudioRadarCursor].desc or ""
    DrawMenuFooter(menuX, footerY, menuWidth, footerHeight, activeDesc, "[ ENTER ] Alternar Escuta   |   [ BACKSPACE ] Voltar")

    return #radarRows, radarRows
end

function ToggleStaffDetector()
    StaffDetectorActive = not StaffDetectorActive
    if StaffDetectorActive then
        PlaySoundSafe("SELECT")
        ShowToast("Detector de Staff ATIVADO! Alerta sonoro imediato se admin entrar no alcance.", true)
        CreateThread(function()
            while StaffDetectorActive do
                Wait(1500)
                local myPed = PlayerPedId()
                local myCoords = GetEntityCoords(myPed)
                local myServerId = GetPlayerServerId(PlayerId())

                for _, ply in ipairs(GetActivePlayers()) do
                    local sId = GetPlayerServerId(ply)
                    if sId and sId ~= myServerId then
                        local ped = GetPlayerPed(ply)
                        if ped and DoesEntityExist(ped) then
                            local dist = #(myCoords - GetEntityCoords(ped))
                            if dist <= 200.0 then
                                local isInvis = not IsEntityVisible(ped)
                                local isInvinc = GetPlayerInvincible(ply)
                                if isInvis or isInvinc then
                                    PlaySoundFrontend("HUD_SHOP_SOUNDSET", "PURCHASE")
                                    ShowToast(("ALERTA DE STAFF: ID %d detectado em %.0fm (Invisivel: %s | God: %s)"):format(sId, dist, isInvis and "SIM" or "NAO", isInvinc and "SIM" or "NAO"), false)
                                    Wait(4000)
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        StaffDetectorActive = false
        PlaySoundSafe("BACK")
        ShowToast("Detector de Staff DESATIVADO.", false)
    end
end

function RenderItemsTab()
    if StreamerShieldActive then return 0, {} end
    local menuX = 0.285
    local menuY = 0.108
    local menuWidth = 0.380
    local rowHeight = 0.026
    local headerHeight = 0.066

    RenderTabsHeader(menuX, menuY, menuWidth, headerHeight)

    local cardY = menuY + (headerHeight / 2) + 0.021
    DrawRect(menuX, cardY, menuWidth, 0.034, 10, 6, 8, 252)
    DrawRect(menuX - (menuWidth / 2) + 0.002, cardY, 0.004, 0.032, 150, 22, 28, 255)
    DrawRect(menuX, cardY + 0.016, menuWidth - 0.016, 0.001, 160, 130, 50, 60)

    DrawTextOnScreen("Catalogo Oficial de Itens & Equipamentos", menuX - (menuWidth / 2) + 0.012, cardY - 0.011, 0.25, 255, 255, 255, 255, false, 1)
    DrawTextOnScreen("998 ITENS REAIS (RSG / WOOD)", menuX + (menuWidth / 2) - 0.170, cardY - 0.011, 0.20, 235, 190, 50, 255, false, 0)

    local offsetY = cardY + 0.017
    local hasToast = DrawStatusToast(menuX, offsetY + 0.014, menuWidth)
    if hasToast then offsetY = offsetY + 0.029 end

    local mainOptions = {
        { isTab = true, title = "Mudar Aba:", value = "< [ < ] ITENS [ > ] >", desc = "Pressione [SETAS ESQUERDA / DIREITA] para alternar entre as abas" },
        { isCategories = true, title = "Ver Categorias de Itens (10x):", value = ">> ABRIR CATEGORIAS <<", desc = "[ENTER] Armas, Raros, Medicina, Plantas, Caca, Estabulos e Ilegal" },
        { isSearch = true, title = "Buscar Item por Nome ou ID:", value = (SearchQuery ~= "" and ("< " .. SearchQuery .. " >") or "[ DIGITAR BUSCA ]"), desc = "[ENTER] Pesquise qualquer item entre os 998 itens do servidor" },
        { isGiveInteractive = true, title = "Entregar Item p/ Jogador:", value = ">> ESCOLHER JOGADOR <<", desc = "[ENTER] Entrega qualquer item diretamente para outro jogador" },
        { isQuickAmmo = true, title = "Pegar Pacote de Municoes:", value = ">> MUNICOES COMPLETAS <<", desc = "[ENTER] Cartuchos para revolveres, rifles, repetidoras e espingardas" },
        { isQuickMedical = true, title = "Pegar Kit Medico / Curativos:", value = ">> CURATIVOS & TONICOS <<", desc = "[ENTER] Bandagens, firstaid, remedios e tonicos medicinais" },
        { isQuickLockpicks = true, title = "Pegar Gazua & Dinamite:", value = ">> LOCKPICK & DINAMITE <<", desc = "[ENTER] Ferramentas de invasao, gazua universal e dinamites de roubo" },
        { isCustomItem = true, title = "Spawn Manual (Digitar Qualquer ID):", value = "[ DIGITAR ID ]", desc = "[ENTER] Digite o nome de qualquer item e quantidade para receber na hora sem logs" },
        { isOpenStash = true, title = "Abrir Bau Livre / Stash Sem Limite:", value = ">> ABRIR BAU <<", desc = "[ENTER] Abre bau/armazem de itens sem limite de peso para guardar e pegar qualquer item" },
        { isCustomItem = true, title = "Spawn Manual (Digitar Qualquer ID):", value = "[ DIGITAR ID ]", desc = "[ENTER] Digite o nome de qualquer item e quantidade para receber na hora sem logs" },
        { isOpenStash = true, title = "Abrir Bau Livre / Stash Sem Limite:", value = ">> ABRIR BAU <<", desc = "[ENTER] Abre bau/armazem de itens sem limite de peso para guardar e pegar qualquer item" },
        { isClearInv = true, title = "Limpar Todo o Meu Inventario:", value = ">> ZERAR INVENTARIO <<", desc = "[ENTER] Remove todos os itens da sua bolsa/mochila" },
        { isClose = true, title = "Fechar Menu", value = "[ BACKSPACE ]", desc = "Pressione [ENTER] ou [BACKSPACE] para fechar" }
    }

    local currentY, startIndex, endIndex, curPage, totalPages = DrawPaginatedMenuRows(menuX, offsetY, menuWidth, rowHeight, mainOptions, ItemsCursor, 10)
    local footerY = currentY + 0.008
    local footerHeight = 0.052
    local activeDesc = mainOptions[ItemsCursor] and mainOptions[ItemsCursor].desc or ""
    DrawMenuFooter(menuX, footerY, menuWidth, footerHeight, activeDesc, "[ ENTER ] Selecionar    |    [ < > ] Alternar    |    [ BACKSPACE ] Fechar")

    return #mainOptions, mainOptions, startIndex, endIndex
end

function RenderEconomyTab()
    if StreamerShieldActive then return 0, {} end
    local menuX = 0.285
    local menuY = 0.108
    local menuWidth = 0.380
    local rowHeight = 0.024
    local headerHeight = 0.066

    RenderTabsHeader(menuX, menuY, menuWidth, headerHeight)

    local cardY = menuY + (headerHeight / 2) + 0.021
    DrawRect(menuX, cardY, menuWidth, 0.034, 10, 6, 8, 252)
    DrawRect(menuX - (menuWidth / 2) + 0.002, cardY, 0.004, 0.032, 150, 22, 28, 255)
    DrawRect(menuX, cardY + 0.016, menuWidth - 0.016, 0.001, 160, 130, 50, 60)

    DrawTextOnScreen("Gestao Financeira & Economia", menuX - (menuWidth / 2) + 0.012, cardY - 0.011, 0.25, 255, 255, 255, 255, false, 1)
    DrawTextOnScreen("CASH, GOLD & BLOODMONEY", menuX + (menuWidth / 2) - 0.165, cardY - 0.011, 0.21, 235, 190, 50, 255, false, 0)

    local offsetY = cardY + 0.017
    local hasToast = DrawStatusToast(menuX, offsetY + 0.014, menuWidth)
    if hasToast then offsetY = offsetY + 0.029 end

    local economyOptions = {
        { isTab = true, title = "Mudar Aba:", value = "< [ < ] ECONOMIA [ > ] >", desc = "Pressione [SETAS ESQUERDA / DIREITA] para alternar entre as abas" },
        { isCustomCash = true, title = "Digitar Dinheiro Cash ($):", value = "[ DIGITAR VALOR ]", desc = "[ENTER] Digite QUALQUER quantia em dinheiro vivo para a carteira  |  [ESQ/DIR] + $1.000 / + $5.000" },
        { isQuickCash10k = true, title = "Pegar +$10.000 Cash:", value = ">> +$10.000 <<", desc = "[ENTER] Receber +$10.000 em dinheiro vivo  |  [ESQ/DIR] + $1.000 / + $20.000" },
        { isQuickCash1k = true, title = "Pegar +$1.000 Cash:", value = ">> +$1.000 <<", desc = "[ENTER] Receber +$1.000 em dinheiro vivo  |  [ESQ/DIR] + $500 / + $5.000" },
        { isClearCash = true, title = "Zerar Carteira (Cash $0):", value = ">> ZERAR TUDO <<", desc = "[ENTER] Remove todo o dinheiro em maos, zerando a carteira ($0)" },
        
        { isCustomGold = true, title = "Digitar Gold Moeda (G):", value = "[ DIGITAR GOLD ]", desc = "[ENTER] Digite a quantidade de Moeda Gold para a conta (Currencia G)  |  [ESQ/DIR] + 10G / + 50G" },
        { isQuickGold50 = true, title = "Creditar +50 Gold Moeda:", value = ">> +50 GOLD <<", desc = "[ENTER] Creditar +50 Moeda Gold direto na conta  |  [ESQ/DIR] + 10G / + 100G" },
        { isClearGold = true, title = "Zerar Gold da Conta (G 0):", value = ">> ZERAR GOLD <<", desc = "[ENTER] Remove todo o saldo de Gold moeda da conta, zerando o cofre" },
        
        { isCustomBlood = true, title = "Pegar Dinheiro Sujo (Blood):", value = "[ PEGAR BLOOD ]", desc = "[ENTER] Digitar quantia de bloodmoney clandestino  |  [ESQ/DIR] + $500 / + $5.000" },
        { isQuickBlood5k = true, title = "Pegar +$5.000 Bloodmoney:", value = ">> +$5.000 BLOOD <<", desc = "[ENTER] Receber +$5.000 em dinheiro sujo clandestino  |  [ESQ/DIR] + $1.000 / + $10.000" },
        { isClearBlood = true, title = "Zerar Todo Bloodmoney:", value = ">> ZERAR BLOOD <<", desc = "[ENTER] Remove todo o dinheiro sujo acumulado, zerando o saldo ($0)" },

        { isFastSellItems = true, title = "Venda Rapida de Itens (wood-items):", value = ">> VENDER ITENS <<", desc = "[ENTER] Dispara a venda automatica de itens legais para NPCs do wood-sellitens" },
        { isFastSellDrugs = true, title = "Venda Rapida de Drogas (wood-selldrugs):", value = ">> VENDER DROGAS <<", desc = "[ENTER] Dispara a venda de cocaina/maconha/heroina para NPCs do wood-selldrugs" },
        { isCobrarPlayer = true, title = "Emitir Cobranca / Fatura (wood-cobrancas):", value = ">> COBRAR PLAYER <<", desc = "[ENTER] Envia solicitacao de cobranca em dinheiro para jogador proximo" },

        { isBankRobberies = true, title = "Roubo aos Bancos do Servidor (5x):", value = ">> LISTA DE BANCOS <<", desc = "[ENTER] Saint Denis, Valentine, Rhodes, Blackwater e Strawberry (coordenadas, cofres e teleporte)" },
        { isGiveOtherCash = true, title = "Setar Cash p/ Outro Jogador:", value = ">> ESCOLHER ID <<", desc = "[ENTER] Enviar dinheiro Cash ($) para outro jogador informando o ID e o valor" },
        { isGiveOtherGold = true, title = "Setar Gold p/ Outro Jogador:", value = ">> ESCOLHER ID <<", desc = "[ENTER] Enviar Gold (G) para a conta de outro jogador informando o ID e a quantia" },
        { isGiveOtherBlood = true, title = "Setar Bloodmoney p/ Outro:", value = ">> ESCOLHER ID <<", desc = "[ENTER] Enviar Bloodmoney clandestino para outro jogador informando o ID e o valor" },

        { isClose = true, title = "Fechar Menu", value = "[ BACKSPACE ]", desc = "Pressione [ENTER] ou [BACKSPACE] para fechar" }
    }

    local currentY, startIndex, endIndex, curPage, totalPages = DrawPaginatedMenuRows(menuX, offsetY, menuWidth, rowHeight, economyOptions, EconomyCursor, 8)
    local footerY = currentY + 0.008
    local footerHeight = 0.052
    local activeDesc = economyOptions[EconomyCursor] and economyOptions[EconomyCursor].desc or ""
    DrawMenuFooter(menuX, footerY, menuWidth, footerHeight, activeDesc, "[ ENTER ] Confirmar    |    [ < > ] Ajustar Quantia    |    [ BACKSPACE ] Fechar")

    return #economyOptions, economyOptions, startIndex, endIndex
end

function RenderAdminTab()
    if StreamerShieldActive then return 0, {} end
    local menuX = 0.285
    local menuY = 0.108
    local menuWidth = 0.380
    local rowHeight = 0.024
    local headerHeight = 0.066

    RenderTabsHeader(menuX, menuY, menuWidth, headerHeight)

    local cardY = menuY + (headerHeight / 2) + 0.020
    DrawRect(menuX, cardY, menuWidth, 0.032, 10, 6, 8, 252)
    DrawRect(menuX - (menuWidth / 2) + 0.002, cardY, 0.004, 0.030, 150, 22, 28, 255)
    DrawRect(menuX, cardY + 0.014, menuWidth - 0.016, 0.001, 160, 130, 50, 60)

    local adminStatus = GodmodeActive and "~g~GOD: ON~s~" or (GhostWalkActive and "~g~FANTASMA: ON~s~" or (NoclipActive and "~b~NC: ON~s~" or "~c~ADMIN: OK~s~"))
    DrawTextOnScreen("Painel de Administracao & Vigilancia", menuX - (menuWidth / 2) + 0.012, cardY - 0.010, 0.23, 255, 255, 255, 255, false, 1)
    DrawTextOnScreen(adminStatus, menuX + (menuWidth / 2) - 0.130, cardY - 0.010, 0.20, 235, 190, 50, 255, false, 0)

    local offsetY = cardY + 0.016
    local hasToast = DrawStatusToast(menuX, offsetY + 0.014, menuWidth)
    if hasToast then offsetY = offsetY + 0.029 end

    local adminOptions = {
        { isTab = true, title = "Mudar Aba:", value = "< [ < ] ADMIN [ > ] >", desc = "Pressione [SETAS ESQUERDA / DIREITA] para alternar entre as abas" },
        { isGodmode = true, title = "GodMode (Imortalidade Total):", value = GodmodeActive and "< [ ATIVADO ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Imortalidade completa, vida 600 fixa, auto-ressurreicao e sem dano" },
        { isNoclip = true, title = "NoClip (Voar por Paredes):", value = NoclipActive and "< [ ATIVADO ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Voar livremente pelo mapa atravessando paredes e montanhas" },
        { isGhostWalk = true, title = "Andar entre Paredes (A Pé):", value = GhostWalkActive and "< [ ATIVADO ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Atravessa portas trancadas, grades e paredes andando a pe no chao" },
        { isVanish = true, title = "Invisibilidade (Vanish):", value = VanishActive and "< [ ATIVADO ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Ficar completamente invisivel para todos os outros jogadores" },
        { isSpectate = true, title = "Spectate Furtivo (Sem Mover Ped / Zero Logs):", value = SpectatingTarget and ("< [ ID %d ] >"):format(SpectatingTarget) or ">> ESCOLHER ID <<", desc = "[ENTER] Observa qualquer jogador em modo furtivo total, ped fica no mesmo lugar, audio 3D e zero logs" },
        { isSpectateEngine = true, title = "Spectate Nativo ps-adminmenu:", value = EngineSpectateActive and ("< [ ATIVO ID %d ] >"):format(EngineSpectateTarget or 0) or ">> ESCOLHER ID <<", desc = "[ENTER] Ativa o spectate nativo do script de admin localmente sem logs nem abrir painel" },
        { isOpenStash = true, title = "Abrir Bau Livre / Stash Global:", value = ">> ABRIR BAU <<", desc = "[ENTER] Abre bau com peso e capacidade ilimitada para guardar/pegar qualquer item" },
        { isInspectInv = true, title = "Espiar Bolsos (Inventario):", value = ">> ESPIAR ID <<", desc = "[ENTER] Visualiza armas, itens e dinheiro de qualquer jogador por ID via ps-adminmenu" },
        { isClearTargetInv = true, title = "Limpar Inventario de Alvo:", value = ">> LIMPAR BOLSO <<", desc = "[ENTER] Remove todos os itens do inventario de um jogador por ID" },
        { isGiveItemOther = true, title = "Dar Item a Outro Jogador:", value = ">> DAR ITEM <<", desc = "[ENTER] Envia qualquer item e quantidade para o inventario de outro jogador" },
        { isBring = true, title = "Puxar Jogador (Bring):", value = ">> PUXAR ID <<", desc = "[ENTER] Puxa qualquer jogador imediatamente ate voce" },
        { isGoto = true, title = "Ir ate Jogador (GoTo):", value = ">> GOTO ID <<", desc = "[ENTER] Digite o ID de um jogador para teleportar instantaneamente ate ele" },
        { isReviveOther = true, title = "Reviver Outro Jogador:", value = ">> REVIVER ID <<", desc = "[ENTER] Digite o ID do jogador para reviver e curar de coma/morte na hora" },
        { isKickPlayer = true, title = "Expulsar Jogador (Kick):", value = ">> KICK ID <<", desc = "[ENTER] Expulsa qualquer jogador do servidor imediatamente por ID com motivo" },
        { isBanPlayer = true, title = "Banir Jogador (Temp / Perm):", value = ">> BAN ID <<", desc = "[ENTER] Bane qualquer jogador por tempo determinado ou permanente" },
        { isUnbanPlayer = true, title = "Desbanir Jogador (Unban):", value = ">> UNBAN <<", desc = "[ENTER] Digite o ID/Licenca para desbanir no servidor" },
        
        { isOpenWoodAdmin = true, title = "Abrir Wood Admin Menu Oficial:", value = ">> WOOD ADMIN <<", desc = "[ENTER] Abre o wood-adminmenu (ou digite 'admin' direto no console F8)" },
        { isOpenTxAdmin = true, title = "Abrir txAdmin Oficial (/tx):", value = ">> TXADMIN MENU <<", desc = "[ENTER] Abre o painel oficial do txAdmin em jogo com lista de players, kick e ban" },
        
        { isDeleteEntity = true, title = "Deletar Entidade em Foco / Mira:", value = ">> DELETAR ENTIDADE <<", desc = "[ENTER] Deleta qualquer objeto, ped ou montaria apontada pela mira" },
        { isDeleteVehicle = true, title = "Deletar Veiculo / Carroca (/dv):", value = ">> DELETAR VEICULO <<", desc = "[ENTER] Deleta a carroca ou veiculo que voce esta montado" },
        { isClearAnimals = true, title = "Limpar Animais Proximos (50m):", value = ">> LIMPAR ANIMAIS <<", desc = "[ENTER] Deleta todos os animais e cavalos soltos em um raio de 50m" },
        { isClearObjects = true, title = "Limpar Props / Objetos (50m):", value = ">> LIMPAR PROPS <<", desc = "[ENTER] Deleta todos os objetos e props soltos em um raio de 50m" },
        
        { isWeather = true, title = "Alterar Clima do Servidor:", value = "< [ " .. WeatherPresets[CurrentWeatherIdx] .. " ] >", desc = "[ENTER] Alterna o clima do servidor via ps-adminmenu / weathersync" },
        { isTime = true, title = "Alterar Horario do Servidor:", value = "< [ " .. TimePresets[CurrentTimePresetIdx] .. " ] >", desc = "[ENTER] Alterna o horario do relogio mundial do servidor" },
        
        { isWeightOption = true, title = "Capacidade Inventario (Boost):", value = CustomWeightActive and ("< [ %s (BOOST ATIVO) ] >"):format(WeightPresets[CurrentWeightPresetIdx].label) or "< [ 50kg (MODO SEGURO) ] >", desc = "[ESQ/DIR] Escolher capacidade (100kg a 1000kg) | [ENTER] Alternar Boost <-> Modo Seguro 50kg" },
        { isSlotsOption = true, title = "Slots Inventario (Espacos):", value = ("< [ %s ] >"):format(SlotsPresets[CurrentSlotsPresetIdx].label), desc = "[ESQ/DIR] Escolher quantidade de slots (25 a 150) | [ENTER] Aplicar preset selecionado" },
        { isRevertWeight = true, title = "Reverter Tudo (50kg / 25 Slots):", value = ">> REVERTER MODO SEGURO <<", desc = "[ENTER] Restaura instantaneamente o inventario para 50kg e 25 slots oficiais da staff" },
        { isSetCustomSlots = true, title = "Definir Slots Manual (Qtd):", value = ">> DIGITAR SLOTS <<", desc = "[ENTER] Digite exatamente a quantidade de slots desejada" },
        { isSetCustomWeight = true, title = "Definir Peso Manual (KG):", value = ">> DIGITAR KG <<", desc = "[ENTER] Digite qualquer capacidade em KG (Ex: 80, 120, 250, 500)" },
        
        { isCreateJobStash = true, title = "Criar Bau Protegido (Job Stash):", value = ">> CRIAR BAU <<", desc = "[ENTER] Cria um bau de inventario protegido no local via ps-adminmenu" },
        { isClose = true, title = "Fechar Menu", value = "[ BACKSPACE ]", desc = "Pressione [ENTER] ou [BACKSPACE] para fechar" }
    }

    local currentY, startIndex, endIndex, curPage, totalPages = DrawPaginatedMenuRows(menuX, offsetY, menuWidth, rowHeight, adminOptions, AdminCursor, 8)
    local footerY = currentY + 0.008
    local footerHeight = 0.052
    local activeDesc = adminOptions[AdminCursor] and adminOptions[AdminCursor].desc or ""
    DrawMenuFooter(menuX, footerY, menuWidth, footerHeight, activeDesc, "[ ENTER ] Executar    |    [ < > ] Alternar    |    [ BACKSPACE ] Fechar")

    return #adminOptions, adminOptions, startIndex, endIndex
end

function RenderPlayersTab()
    if StreamerShieldActive then return 0, {}, false end
    local menuX = 0.285
    local menuY = 0.108
    local menuWidth = 0.380
    local rowHeight = 0.026
    local headerHeight = 0.066

    RenderTabsHeader(menuX, menuY, menuWidth, headerHeight)

    local cardY = menuY + (headerHeight / 2) + 0.020
    DrawRect(menuX, cardY, menuWidth, 0.032, 10, 6, 8, 252)
    DrawRect(menuX - (menuWidth / 2) + 0.002, cardY, 0.004, 0.030, 150, 22, 28, 255)
    DrawRect(menuX, cardY + 0.014, menuWidth - 0.016, 0.001, 160, 130, 50, 60)

    SyncStealthRPNames(false)

    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local myServerId = GetPlayerServerId(PlayerId())

    local streamedMap = {}
    for _, pid in ipairs(GetActivePlayers()) do
        local sid = GetPlayerServerId(pid)
        streamedMap[sid] = pid
        local ped = GetPlayerPed(pid)
        local pCoords = (ped and ped ~= 0 and DoesEntityExist(ped)) and GetEntityCoords(ped) or nil
        local dist = pCoords and #(myCoords - pCoords) or 0.0
        local rpName = GetPlayerRPName(sid, pid, ped)
        local steam = GetPlayerName(pid)

        AllServerPlayers[sid] = AllServerPlayers[sid] or { id = sid }
        AllServerPlayers[sid].id = sid
        AllServerPlayers[sid].clientIndex = pid
        AllServerPlayers[sid].ped = ped
        AllServerPlayers[sid].coords = pCoords or AllServerPlayers[sid].coords
        AllServerPlayers[sid].distance = dist
        AllServerPlayers[sid].isStreamed = true
        if steam and steam ~= "" and steam ~= "**Invalid**" then
            AllServerPlayers[sid].steamName = steam
        end
        if rpName and rpName ~= "" and rpName ~= steam then
            AllServerPlayers[sid].rpName = rpName
            AllServerPlayers[sid].name = rpName
        else
            AllServerPlayers[sid].name = AllServerPlayers[sid].name or rpName or steam
        end
        AllServerPlayers[sid].lastSeen = GetGameTimer()
    end

    if not AllServerPlayers[myServerId] then
        local myName = GetPlayerRPName(myServerId, PlayerId(), myPed) or GetPlayerName(PlayerId())
        AllServerPlayers[myServerId] = {
            id = myServerId,
            clientIndex = PlayerId(),
            ped = myPed,
            coords = myCoords,
            distance = 0.0,
            isStreamed = true,
            rpName = myName,
            name = myName,
            lastSeen = GetGameTimer()
        }
    end

    local displayPlayers = {}
    for sid, p in pairs(AllServerPlayers) do
        local isStreamed = (streamedMap[sid] ~= nil)
        p.isStreamed = isStreamed
        if not isStreamed then
            p.clientIndex = -1
            p.ped = 0
            if p.coords then
                p.distance = #(vector2(myCoords.x, myCoords.y) - vector2(p.coords.x, p.coords.y))
            else
                p.distance = 999999.0
            end
        end

        local displayName = p.rpName or p.name or p.steamName or GetPlayerRPName(sid, p.clientIndex, p.ped) or ("Cidadao %d"):format(sid)
        table.insert(displayPlayers, {
            id = sid,
            clientIndex = p.clientIndex,
            name = displayName,
            distance = p.distance or 999999.0,
            coords = p.coords,
            isStreamed = isStreamed,
            ped = p.ped
        })
    end

    table.sort(displayPlayers, function(a, b)
        if a.id == myServerId then return true end
        if b.id == myServerId then return false end
        if a.isStreamed and not b.isStreamed then return true end
        if not a.isStreamed and b.isStreamed then return false end
        if a.distance ~= b.distance then
            return a.distance < b.distance
        end
        return a.id < b.id
    end)

    DrawTextOnScreen("Jogadores Conectados no Servidor", menuX - (menuWidth / 2) + 0.012, cardY - 0.010, 0.23, 255, 255, 255, 255, false, 1)
    DrawTextOnScreen(("%d JOGADORES ONLINE"):format(#displayPlayers), menuX + (menuWidth / 2) - 0.150, cardY - 0.010, 0.20, 235, 190, 50, 255, false, 0)

    local offsetY = cardY + 0.016
    local hasToast = DrawStatusToast(menuX, offsetY + 0.014, menuWidth)
    if hasToast then offsetY = offsetY + 0.029 end

    if SelectedPlayer then
        local playerActions = {
            { isBackToPlayers = true, title = "<< Voltar para Lista de Jogadores", value = "[ VOLTAR ]", desc = "Retorna para a lista com todos os jogadores online" },
            { isSpectate = true, title = "[*] SPECTATE FURTIVO (Sem Mover Ped / Zero Logs):", value = ">> INICIAR <<", desc = "[ENTER] Ativa camera orbital e audio 3D. SEU PED FICA NO MESMO LUGAR, sem logs e sem alertas!" },
            { isSpectateEngine = true, title = "[*] SPECTATE NATIVO ps-adminmenu:", value = ">> NATIVO <<", desc = "[ENTER] Executa o spectator nativo do ps-adminmenu localmente sem passar pelo painel nem gerar log" },
            { isGoto = true, title = "Teleportar ate Jogador (GoTo):", value = ">> GOTO <<", desc = "Teleporta instantaneamente ate o jogador selecionado (proximo ou remoto)" },
            { isBring = true, title = "Puxar Jogador ate Voce (Bring):", value = ">> BRING <<", desc = "Puxa o jogador selecionado ate a sua frente" },
            { isHeal = true, title = "Curar / Reviver Jogador:", value = ">> REVIVER <<", desc = "Cura ferimentos e levanta o jogador de coma/morte" },
            { isCuff = true, title = "Algemar / Desalgemar Jogador:", value = ">> ALGEMAS <<", desc = "Prende ou solta o jogador com algemas policiais via gum_jail" },
            { isJailSisika = true, title = "Enviar para Sisika (Prender):", value = ">> PRENDER <<", desc = "Envia o jogador para a prisao penitenciaria de Sisika" },
            { isUnjailSisika = true, title = "Libertar de Sisika (Soltar):", value = ">> LIBERTAR <<", desc = "Zera a pena do prisioneiro e liberta imediatamente" },
            { isInspectInv = true, title = "Abrir Inventario do Alvo:", value = ">> VER BOLSA <<", desc = "Abre e visualiza os itens da bolsa do jogador via ps-adminmenu" },
            { isClearTargetInv = true, title = "Limpar Todo o Inventario do Alvo:", value = ">> ZERAR ITENS <<", desc = "Deleta todos os itens do inventario deste jogador" },
            { isCobrarPlayer = true, title = "Cobrar Dinheiro do Jogador:", value = ">> COBRAR <<", desc = "Emite uma ordem de cobranca em dinheiro para ele" },
            { isTrollMute = true, title = "Silenciar Microfone do Alvo (Mute):", value = ">> MUTE VOICE <<", desc = "Corta a voz do jogador no pma-voice" },
            { isTrollExplode = true, title = "Troll: Explodir Jogador:", value = ">> EXPLODIR <<", desc = "Cria uma explosao imediata nos pes do jogador" },
            { isTrollFire = true, title = "Troll: Atear Fogo no Jogador:", value = ">> FOGO <<", desc = "Coloca o jogador em chamas via ps-adminmenu" },
            { isTrollDrunk = true, title = "Troll: Deixar Jogador Bebado:", value = ">> BEBADO <<", desc = "Aplica efeito de embriaguez extrema no jogador" },
            { isKickPlayer = true, title = "Expulsar do Servidor (Kick):", value = ">> KICK <<", desc = "Desconecta o jogador da sessao com aviso" },
            { isBanPlayer = true, title = "Banir Jogador do Servidor:", value = ">> BAN <<", desc = "Aplica banimento no jogador selecionado" }
        }

        local currentY, startIndex, endIndex, curPage, totalPages = DrawPaginatedMenuRows(menuX, offsetY, menuWidth, rowHeight, playerActions, PlayerActionCursor, 8)
        local footerY = currentY + 0.008
        local footerHeight = 0.052
        local activeDesc = playerActions[PlayerActionCursor] and playerActions[PlayerActionCursor].desc or ""
        DrawMenuFooter(menuX, footerY, menuWidth, footerHeight, activeDesc, "[ ENTER ] Executar Acao   |   [ BACKSPACE ] Voltar")

        return #playerActions, playerActions, true
    else
        local playerRows = {
            { isTab = true, title = "Mudar Aba:", value = "< [ < ] JOGADORES [ > ] >", desc = "Pressione [SETAS ESQUERDA / DIREITA] para alternar entre as abas" }
        }
        for _, p in ipairs(displayPlayers) do
            local distStr = ""
            if p.id == myServerId then
                distStr = "< 0m >"
            elseif p.isStreamed then
                distStr = ("< %.0fm >"):format(p.distance)
            elseif p.distance < 999000.0 then
                if p.distance >= 1000.0 then
                    distStr = ("< %.1fkm [REMOTO] >"):format(p.distance / 1000.0)
                else
                    distStr = ("< %.0fm [REMOTO] >"):format(p.distance)
                end
            else
                distStr = "< [ REMOTO ] >"
            end

            table.insert(playerRows, {
                playerData = p,
                title = ("[%d] %s"):format(p.id, TruncateText(p.name, 18)),
                value = distStr,
                desc = ("[ENTER] Abrir menu de acoes & SPECTATE para [%d] %s (%s)"):format(p.id, p.name, p.isStreamed and ("Distancia: " .. distStr:gsub("[<>]", "")) or "Jogador Remoto no Mapa")
            })
        end
        if #playerRows == 1 then
            table.insert(playerRows, { title = "Nenhum jogador encontrado", value = "--", desc = "Aguardando outros jogadores conectarem" })
        end

        if PlayersCursor > #playerRows then PlayersCursor = #playerRows end
        if PlayersCursor < 1 then PlayersCursor = 1 end

        local currentY, startIndex, endIndex, curPage, totalPages = DrawPaginatedMenuRows(menuX, offsetY, menuWidth, rowHeight, playerRows, PlayersCursor, 8)
        local footerY = currentY + 0.008
        local footerHeight = 0.052
        local activeDesc = playerRows[PlayersCursor] and playerRows[PlayersCursor].desc or ""
        DrawMenuFooter(menuX, footerY, menuWidth, footerHeight, activeDesc, "[ ENTER ] Selecionar Jogador   |   [ < > ] Alternar   |   [ BACKSPACE ] Fechar")

        return #playerRows, playerRows, false
    end
end

function RenderEscutaTab()
    if StreamerShieldActive then return 0, {} end
    local menuX = 0.285
    local menuY = 0.108
    local menuWidth = 0.380
    local rowHeight = 0.026
    local headerHeight = 0.066

    RenderTabsHeader(menuX, menuY, menuWidth, headerHeight)

    local cardY = menuY + (headerHeight / 2) + 0.021
    DrawRect(menuX, cardY, menuWidth, 0.034, 10, 6, 8, 252)
    DrawRect(menuX - (menuWidth / 2) + 0.002, cardY, 0.004, 0.032, 150, 22, 28, 255)
    DrawRect(menuX, cardY + 0.016, menuWidth - 0.016, 0.001, 160, 130, 50, 60)

    local micStatus = DirectionalMicActive and "~g~MIC: ATIVADO~s~" or "~c~MIC: OFF~s~"
    DrawTextOnScreen("Espionagem, Radar de Voz & Vigilancia", menuX - (menuWidth / 2) + 0.012, cardY - 0.011, 0.24, 255, 255, 255, 255, false, 1)
    DrawTextOnScreen(micStatus, menuX + (menuWidth / 2) - 0.130, cardY - 0.011, 0.21, 235, 190, 50, 255, false, 0)

    local offsetY = cardY + 0.017
    local hasToast = DrawStatusToast(menuX, offsetY + 0.014, menuWidth)
    if hasToast then offsetY = offsetY + 0.029 end

    local escutaOptions = {
        { isTab = true, title = "Mudar Aba:", value = "< [ < ] ESCUTA [ > ] >", desc = "Pressione [SETAS ESQUERDA / DIREITA] para alternar entre as abas" },
        { isDirMic = true, title = "Microfone Direcional (Mirar no Alvo):", value = DirectionalMicActive and "< [ ATIVADO ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Aponte a mira para qualquer pessoa para escutar a conversa dela a distancia" },
        { isDirMicProp = true, title = "Objeto do Microfone na Mao (Prop):", value = (DirectionalMicPropEntity and DoesEntityExist(DirectionalMicPropEntity)) and "< [ EQUIPADO ] >" or "< [ GUARDADO ] >", desc = "[ENTER] Segura o binoculo/microfone fisico na mao do personagem ou use /micprop" },
        { isRadar = true, title = "Radar de Voz 3D (Raio de 250m):", value = ">> ABRIR RADAR <<", desc = "[ENTER] Lista quem esta falando no alcance com medidor de distancia e escuta" },
        { isStopAudio = true, title = "Desconectar de Todas as Escutas:", value = ">> RESETAR AUDIO <<", desc = "[ENTER] Corta imediatamente todas as frequencias e desativa escutas ativas" },
        { isStaffDetector = true, title = "Detector de Staff Proximo (Alerta):", value = StaffDetectorActive and "< [ ATIVADO ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Alerta sonoro e visual imediato se algum admin/mod estiver por perto" },
        { isToggleWallhack = true, title = "Wallhack / ESP (Ver em Paredes):", value = WallhackActive and "< [ ATIVADO ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Mostra nomes de RP, IDs, barras de vida e distancia atraves de paredes" },
        { isCrosshair = true, title = "Mira Fixa Central (Crosshair):", value = CustomCrosshairActive and "< [ ATIVADO ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Reticulo tatico permanente para combate e tiro livre sem abrir mira" },
        { isInfWeapon = true, title = "Municao Infinita & Sem Recoil:", value = InfiniteWeaponActive and "< [ ATIVADO ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Balas infinitas, sem recarga e mira estavel via ps-adminmenu" },
        { isRevive = true, title = "Auto-Reviver (Curar Coma):", value = ">> REVIVER AGORA <<", desc = "[ENTER] Levanta imediatamente de coma/morte sem chamar medicos" },
        { isHeal = true, title = "Curar Vida e Estamina Maxima:", value = ">> CURAR COMPLETO <<", desc = "[ENTER] Enche a vida, estamina e cura qualquer ferimento do personagem" },
        { isAntiRagdoll = true, title = "Anti-Ragdoll (Nao Cair de Montaria):", value = AntiRagdollActive and "< [ ATIVADO ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Imune a quedas de cavalos, explosoes e empurroes de jogadores" },
        { isNeverWanted = true, title = "Nunca Procurado (No Police):", value = NeverWantedActive and "< [ ATIVADO ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Policiais e agentes da lei nunca perseguem ou atiram em voce" },
        { isClose = true, title = "Fechar Menu", value = "[ BACKSPACE ]", desc = "Pressione [ENTER] ou [BACKSPACE] para fechar" }
    }

    local currentY, startIndex, endIndex, curPage, totalPages = DrawPaginatedMenuRows(menuX, offsetY, menuWidth, rowHeight, escutaOptions, EscutaCursor, 8)
    local footerY = currentY + 0.008
    local footerHeight = 0.052
    local activeDesc = escutaOptions[EscutaCursor] and escutaOptions[EscutaCursor].desc or ""
    DrawMenuFooter(menuX, footerY, menuWidth, footerHeight, activeDesc, "[ ENTER ] Alternar    |    [ < > ] Ajustar    |    [ BACKSPACE ] Fechar")

    return #escutaOptions, escutaOptions, startIndex, endIndex
end

function RenderGodTab()
    if StreamerShieldActive then return 0, {} end
    local menuX = 0.285
    local menuY = 0.108
    local menuWidth = 0.380
    local rowHeight = 0.024
    local headerHeight = 0.066

    RenderTabsHeader(menuX, menuY, menuWidth, headerHeight)

    local cardY = menuY + (headerHeight / 2) + 0.021
    DrawRect(menuX, cardY, menuWidth, 0.034, 18, 4, 6, 252)
    DrawRect(menuX - (menuWidth / 2) + 0.002, cardY, 0.004, 0.032, 220, 35, 35, 255)
    DrawRect(menuX, cardY + 0.016, menuWidth - 0.016, 0.001, 180, 30, 30, 60)

    local banStatus = AntiBanActive and "~g~IMUNIDADE: ON~s~" or "~r~IMUNIDADE: OFF~s~"
    local wallStatus = WallhackActive and "~g~WALL: ON~s~" or "~c~WALL: OFF~s~"
    DrawTextOnScreen("PAINEL GOD & MENUS STAFF", menuX - (menuWidth / 2) + 0.012, cardY - 0.011, 0.23, 255, 215, 0, 255, false, 1)
    DrawTextOnScreen(wallStatus .. " | " .. banStatus, menuX + (menuWidth / 2) - 0.165, cardY - 0.011, 0.18, 255, 255, 255, 255, false, 0)

    local offsetY = cardY + 0.017
    local hasToast = DrawStatusToast(menuX, offsetY + 0.014, menuWidth)
    if hasToast then offsetY = offsetY + 0.029 end

    local godOptions = {
        { isTab = true, title = "Mudar Aba:", value = "< [ < ] GOD [ > ] >", desc = "Pressione [SETAS ESQUERDA / DIREITA] para alternar entre as abas" },
        { isToggleAntiBan = true, title = "Protecao Anti-Ban & Anti-Kick:", value = AntiBanActive and "< [ 100% IMUNE ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Bloqueia e cancela qualquer evento de ban, kick ou forceKill da staff" },
        { isForceUnbanSelf = true, title = "Forcar Desbanimento Imediato:", value = ">> UNBAN GERAL <<", desc = "[ENTER] Dispara todos os eventos de desbanimento no servidor para limpar seu registro de ban" },
        { isToggleWallhack = true, title = "Wallhack / ESP (Visao em Paredes):", value = WallhackActive and "< [ WALL ATIVO ] >" or "< [ DESATIVADO ] >", desc = "[ENTER] Revela nomes de RP, IDs, barras de vida e distancia atraves de paredes" },
        { isTeleports = true, title = "Menu de Teleportes (Cidades & Locais):", value = ">> TELEPORTES <<", desc = "[ENTER] Teleporta para Valentine, Saint Denis, Rhodes, Blackwater, Sisika e bancos" },
        { isTpWaypoint = true, title = "Teleportar para o Marcador do Mapa:", value = ">> TP WAYPOINT <<", desc = "[ENTER] Teleporta instantaneamente para onde voce colocou o ponto no mapa" },
        { isEscapeSisika = true, title = "Soltar-se de Sisika (Auto-Unjail):", value = ">> LIBERTAR-SE <<", desc = "[ENTER] Zera a sentenca de Sisika e te teletransporta imediatamente para terra firme" },
        { isUnjailOther = true, title = "Soltar Amigo de Sisika por ID:", value = ">> UNJAIL AMIGO <<", desc = "[ENTER] Digite o ID do amigo para soltar imediatamente de Sisika" },
        { isOpenWoodAdmin = true, title = "Abrir Wood Admin Menu Oficial:", value = ">> WOOD ADMIN <<", desc = "[ENTER] Abre o wood-adminmenu (ou digite 'admin' direto no console F8)" },
        { isOpenTxAdmin = true, title = "Painel txAdmin Oficial (/tx):", value = ">> TXADMIN MENU <<", desc = "[ENTER] Abre o painel oficial do txAdmin em jogo com lista de players, kick e ban" },
        { isPanicClose = true, title = "Panic Button [DELETE]:", value = ">> DELETAR MENU <<", desc = "[ENTER ou DELETE] Descarrega o menu completamente da memoria sem deixar vestigios" },
        { isClose = true, title = "Fechar Menu", value = "[ BACKSPACE ]", desc = "Pressione [ENTER] ou [BACKSPACE] para fechar" }
    }

    local currentY, startIndex, endIndex, curPage, totalPages = DrawPaginatedMenuRows(menuX, offsetY, menuWidth, rowHeight, godOptions, GodCursor, 8)
    local footerY = currentY + 0.008
    local footerHeight = 0.052
    local activeDesc = godOptions[GodCursor] and godOptions[GodCursor].desc or ""
    DrawMenuFooter(menuX, footerY, menuWidth, footerHeight, activeDesc, "[ ENTER ] Executar    |    [ < > ] Alternar    |    [ BACKSPACE ] Fechar")

    return #godOptions, godOptions, startIndex, endIndex
end

function RenderCategoriesView()
    local menuX = 0.285
    local menuY = 0.108
    local menuWidth = 0.380
    local rowHeight = 0.026
    local headerHeight = 0.066

    RenderTabsHeader(menuX, menuY, menuWidth, headerHeight)

    local cardY = menuY + (headerHeight / 2) + 0.020
    DrawRect(menuX, cardY, menuWidth, 0.032, 10, 6, 8, 252)
    DrawRect(menuX - (menuWidth / 2) + 0.002, cardY, 0.004, 0.030, 150, 22, 28, 255)
    DrawRect(menuX, cardY + 0.014, menuWidth - 0.016, 0.001, 160, 130, 50, 60)

    DrawTextOnScreen("Selecione uma Categoria de Itens", menuX - (menuWidth / 2) + 0.012, cardY - 0.010, 0.24, 255, 255, 255, 255, false, 1)
    DrawTextOnScreen(("%d CATEGORIAS"):format(#ItemCategories), menuX + (menuWidth / 2) - 0.130, cardY - 0.010, 0.20, 235, 190, 50, 255, false, 0)

    local offsetY = cardY + 0.016
    local catRows = {
        { isBack = true, title = "<< Voltar ao Painel Principal", value = "[ VOLTAR ]", desc = "Retorna para a aba principal de itens" }
    }

    for idx, cat in ipairs(ItemCategories) do
        table.insert(catRows, {
            catIdx = idx,
            title = cat.title,
            value = ("< %d Itens >"):format(#cat.items),
            desc = ("[ENTER] Abrir catalogo da categoria %s"):format(cat.title)
        })
    end

    local currentY, startIndex, endIndex, curPage, totalPages = DrawPaginatedMenuRows(menuX, offsetY, menuWidth, rowHeight, catRows, CategoryCursor, 8)
    local footerY = currentY + 0.008
    local footerHeight = 0.052
    local activeDesc = catRows[CategoryCursor] and catRows[CategoryCursor].desc or ""
    DrawMenuFooter(menuX, footerY, menuWidth, footerHeight, activeDesc, "[ ENTER ] Abrir Categoria   |   [ BACKSPACE ] Voltar")

    return #catRows, catRows
end

function RenderItemsView(isSearch)
    local menuX = 0.285
    local menuY = 0.108
    local menuWidth = 0.380
    local rowHeight = 0.026
    local headerHeight = 0.066

    RenderTabsHeader(menuX, menuY, menuWidth, headerHeight)

    local activeCat = ItemCategories[ActiveCategoryIndex]
    local list = isSearch and SearchResults or (activeCat and activeCat.items or {})
    local titleStr = isSearch and ("Busca: '%s'"):format(SearchQuery) or (activeCat and activeCat.title or "Itens")

    local cardY = menuY + (headerHeight / 2) + 0.020
    DrawRect(menuX, cardY, menuWidth, 0.032, 10, 6, 8, 252)
    DrawRect(menuX - (menuWidth / 2) + 0.002, cardY, 0.004, 0.030, 150, 22, 28, 255)
    DrawRect(menuX, cardY + 0.014, menuWidth - 0.016, 0.001, 160, 130, 50, 60)

    DrawTextOnScreen(titleStr, menuX - (menuWidth / 2) + 0.012, cardY - 0.010, 0.24, 255, 255, 255, 255, false, 1)
    DrawTextOnScreen(("%d ITENS"):format(#list), menuX + (menuWidth / 2) - 0.110, cardY - 0.010, 0.20, 235, 190, 50, 255, false, 0)

    local offsetY = cardY + 0.016
    local itemRows = {
        { isBack = true, title = "<< Voltar", value = "[ VOLTAR ]", desc = "Retorna para a selecao anterior" }
    }

    if isSearch and #list == 0 then
        table.insert(itemRows, {
            isSearchAgain = true,
            title = "Nenhum item encontrado!",
            value = "[ DIGITAR OUTRO TERMO ]",
            desc = "[ENTER] Clique aqui para tentar outro termo ou use /buscar [termo]"
        })
    end

    for _, it in ipairs(list) do
        table.insert(itemRows, {
            itemData = it,
            title = it.label,
            value = ("< %d un > [ %s ]"):format(SelectedGiveAmount, it.id),
            desc = ("[ENTER] Pegar %dx %s  |  [ < > ] Mudar Quantidade (%dx)"):format(SelectedGiveAmount, it.label, SelectedGiveAmount)
        })
    end

    local currentY, startIndex, endIndex, curPage, totalPages = DrawPaginatedMenuRows(menuX, offsetY, menuWidth, rowHeight, itemRows, ItemCursor, 8)
    local footerY = currentY + 0.008
    local footerHeight = 0.052
    local activeDesc = itemRows[ItemCursor] and itemRows[ItemCursor].desc or ""
    DrawMenuFooter(menuX, footerY, menuWidth, footerHeight, activeDesc, ("[ ENTER ] Pegar %dx   |   [ < > ] Ajustar Quantidade   |   [ BACKSPACE ] Voltar"):format(SelectedGiveAmount))

    return #itemRows, itemRows
end

local ServerTeleports = {
    { name = "Valentine (Centro & Saloon)", coords = vector3(-180.50, 628.20, 114.10) },
    { name = "Saint Denis (Praca Central)", coords = vector3(2508.10, -1306.40, 48.90) },
    { name = "Rhodes (Estacao & Xerifado)", coords = vector3(1230.20, -1295.60, 76.90) },
    { name = "Blackwater (Porto & Prefeitura)", coords = vector3(-768.40, -1220.50, 43.60) },
    { name = "Strawberry (Centro das Pontes)", coords = vector3(-1760.30, -388.20, 157.60) },
    { name = "Armadillo (Saloon & Deserto)", coords = vector3(-3685.20, -2600.40, -13.20) },
    { name = "Tumbleweed (Xerifado Alto)", coords = vector3(-5520.10, -2950.50, -1.80) },
    { name = "Annesburg (Mina de Carvao)", coords = vector3(2900.50, 1310.20, 44.80) },
    { name = "Emerald Ranch (Estacao de Trem)", coords = vector3(1420.40, -385.10, 89.10) },
    { name = "Sisika Penitentiary (Patio Principal)", coords = vector3(3360.20, -680.50, 42.80) },
    { name = "Banco de Saint Denis (Cofre)", coords = vector3(2647.47, -1300.66, 52.24) },
    { name = "Banco de Valentine (Cofre)", coords = vector3(-311.23, 774.71, 118.70) },
    { name = "Banco de Rhodes (Cofre)", coords = vector3(1285.58, -1303.39, 77.25) },
    { name = "Banco de Blackwater (Cofre)", coords = vector3(-816.19, -1276.78, 43.63) },
    { name = "Banco de Strawberry (Cofre)", coords = vector3(-1763.51, -383.26, 160.00) }
}

function RenderTeleportsView()
    local menuX = 0.285
    local menuY = 0.108
    local menuWidth = 0.380
    local rowHeight = 0.026
    local headerHeight = 0.066

    RenderTabsHeader(menuX, menuY, menuWidth, headerHeight)

    local cardY = menuY + (headerHeight / 2) + 0.020
    DrawRect(menuX, cardY, menuWidth, 0.032, 10, 6, 8, 252)
    DrawRect(menuX - (menuWidth / 2) + 0.002, cardY, 0.004, 0.030, 150, 22, 28, 255)
    DrawRect(menuX, cardY + 0.014, menuWidth - 0.016, 0.001, 160, 130, 50, 60)

    DrawTextOnScreen("Pontos de Teleporte Rápido", menuX - (menuWidth / 2) + 0.012, cardY - 0.010, 0.24, 255, 255, 255, 255, false, 1)
    DrawTextOnScreen(("%d DESTINOS"):format(#ServerTeleports), menuX + (menuWidth / 2) - 0.130, cardY - 0.010, 0.20, 235, 190, 50, 255, false, 0)

    local offsetY = cardY + 0.016
    local tpRows = {
        { isBack = true, title = "<< Voltar ao Painel", value = "[ VOLTAR ]", desc = "Retorna para o menu principal" }
    }

    for _, tp in ipairs(ServerTeleports) do
        table.insert(tpRows, {
            tpData = tp,
            title = tp.name,
            value = ">> TELEPORTAR <<",
            desc = ("[ENTER] Teleportar instantaneamente para %s"):format(tp.name)
        })
    end

    local currentY, startIndex, endIndex, curPage, totalPages = DrawPaginatedMenuRows(menuX, offsetY, menuWidth, rowHeight, tpRows, TeleportCursor, 8)
    local footerY = currentY + 0.008
    local footerHeight = 0.052
    local activeDesc = tpRows[TeleportCursor] and tpRows[TeleportCursor].desc or ""
    DrawMenuFooter(menuX, footerY, menuWidth, footerHeight, activeDesc, "[ ENTER ] Teleportar   |   [ BACKSPACE ] Voltar")

    return #tpRows, tpRows
end

function ToggleGodmode()
    GodmodeActive = not GodmodeActive
    local ped = PlayerPedId()
    SetPlayerInvincible(PlayerId(), GodmodeActive)
    SetEntityInvincible(ped, GodmodeActive)
    if GodmodeActive then
        SetEntityHealth(ped, 600)
        PlaySoundFrontend("HUD_SHOP_SOUNDSET", "PURCHASE")
        ShowToast("GODMODE ATIVADO: Vida 600 e Imunidade Completa!", true)
    else
        ShowToast("Godmode desativado.", true)
    end
end

function ToggleNoclip()
    NoclipActive = not NoclipActive
    local ped = PlayerPedId()
    SetEntityCollision(ped, not NoclipActive, not NoclipActive)
    FreezeEntityPosition(ped, NoclipActive)
    SetEntityInvincible(ped, NoclipActive)
    if NoclipActive then
        PlaySoundFrontend("HUD_SHOP_SOUNDSET", "PURCHASE")
        ShowToast("NOCLIP ATIVADO: Voar livre por paredes e terreno!", true)
        CreateThread(function()
            while NoclipActive do
                Wait(0)
                local p = PlayerPedId()
                local c = GetEntityCoords(p)
                local h = GetGameplayCamRot(2)
                SetEntityHeading(p, (180.0 + h.z) % 360.0)

                local forward = 0.0
                local side = 0.0
                local up = 0.0
                local speed = 1.2
                if IsControlPressed(0, 0x8FFC75D6) then speed = 3.5 end

                if IsControlPressed(0, 0x8FD015D8) then forward = forward + speed end
                if IsControlPressed(0, 0xD27782E3) then forward = forward - speed end
                if IsControlPressed(0, 0x7065027D) then side = side - speed end
                if IsControlPressed(0, 0xB4E465B4) then side = side + speed end
                if IsControlPressed(0, 0xD9D0E1C0) or IsControlPressed(0, 0x26E9DC00) then up = up + speed end
                if IsControlPressed(0, 0xDB096B85) or IsControlPressed(0, 0xDE794E3E) then up = up - speed end

                local radZ = math.rad(h.z)
                local radX = math.rad(h.x)
                local dx = -math.sin(radZ) * forward + math.cos(radZ) * side
                local dy = math.cos(radZ) * forward + math.sin(radZ) * side
                local dz = math.sin(radX) * forward + up

                SetEntityCoordsNoOffset(p, c.x + dx, c.y + dy, c.z + dz, false, false, false)
            end
            FreezeEntityPosition(PlayerPedId(), false)
            SetEntityCollision(PlayerPedId(), true, true)
        end)
    else
        ShowToast("Noclip desativado.", true)
    end
end

function ToggleGhostWalk()
    GhostWalkActive = not GhostWalkActive
    local ped = PlayerPedId()
    
    if GhostWalkActive then
        if NoclipActive then
            NoclipActive = false
            FreezeEntityPosition(ped, false)
        end

        PlaySoundFrontend("HUD_SHOP_SOUNDSET", "PURCHASE")
        ShowToast("ANDAR ENTRE PAREDES ATIVADO: Atravesse portas, grades e paredes a pe!", true)

        CreateThread(function()
            local targetHeight = nil
            
            while GhostWalkActive do
                Wait(0)
                local p = PlayerPedId()
                if not DoesEntityExist(p) or IsEntityDead(p) then
                    GhostWalkActive = false
                    break
                end

                local mount = GetMount(p)
                local veh = GetVehiclePedIsIn(p, false)
                local entity = (veh ~= 0 and veh) or (mount ~= 0 and mount) or p

                SetEntityCollision(entity, false, false)
                SetEntityInvincible(p, true)
                SetPedCanRagdoll(p, false)

                local c = GetEntityCoords(entity)
                local camRot = GetGameplayCamRot(2)

                if not targetHeight then
                    targetHeight = c.z
                end

                local forward = 0.0
                local side = 0.0
                local speed = 0.06

                if IsControlPressed(0, 0x8FFC75D6) or IsControlPressed(0, 0x639B9FC9) then
                    speed = 0.16
                end

                if IsControlPressed(0, 0x8FD015D8) then forward = forward + speed end
                if IsControlPressed(0, 0xD27782E3) then forward = forward - speed end
                if IsControlPressed(0, 0x7065027D) then side = side - speed end
                if IsControlPressed(0, 0xB4E465B4) then side = side + speed end

                local radZ = math.rad(camRot.z)
                local dx = -math.sin(radZ) * forward + math.cos(radZ) * side
                local dy = math.cos(radZ) * forward + math.sin(radZ) * side

                local nextX = c.x + dx
                local nextY = c.y + dy
                local found, groundZ = GetGroundZFor_3dCoord(nextX, nextY, targetHeight + 1.2, false)
                if found and groundZ and groundZ > -180.0 then
                    if math.abs(groundZ - targetHeight) < 2.0 then
                        targetHeight = groundZ
                    end
                end

                if IsControlPressed(0, 0xD9D0E1C0) then
                    targetHeight = targetHeight + 0.07
                elseif IsControlPressed(0, 0xDB096B85) or IsControlPressed(0, 0x9C5E030C) or IsControlPressed(0, 0xDE794E3E) then
                    targetHeight = targetHeight - 0.07
                end

                if forward ~= 0.0 or side ~= 0.0 then
                    SetEntityHeading(entity, (180.0 + camRot.z) % 360.0)
                    SetEntityCoordsNoOffset(entity, nextX, nextY, targetHeight, false, false, false)
                else
                    SetEntityCoordsNoOffset(entity, c.x, c.y, targetHeight, false, false, false)
                end

                DrawTextOnScreen("ANDAR ENTRE PAREDES ATIVO | [W/A/S/D] Andar | [SHIFT] Correr | [ESPACO/CTRL] Subir/Descer", 0.50, 0.965, 0.20, 140, 255, 140, 230, true, 0)
            end

            local p = PlayerPedId()
            local mount = GetMount(p)
            local veh = GetVehiclePedIsIn(p, false)
            local entity = (veh ~= 0 and veh) or (mount ~= 0 and mount) or p

            SetEntityCollision(entity, true, true)
            FreezeEntityPosition(entity, false)
            SetEntityInvincible(p, GodmodeActive or false)
            SetPedCanRagdoll(p, true)

            local curCoords = GetEntityCoords(entity)
            local found, gZ = GetGroundZFor_3dCoord(curCoords.x, curCoords.y, curCoords.z + 2.0, false)
            if found and gZ and gZ > -180.0 and math.abs(gZ - curCoords.z) < 3.0 then
                SetEntityCoordsNoOffset(entity, curCoords.x, curCoords.y, gZ + 0.2, false, false, false)
            end
        end)
    else
        local p = PlayerPedId()
        local mount = GetMount(p)
        local veh = GetVehiclePedIsIn(p, false)
        local entity = (veh ~= 0 and veh) or (mount ~= 0 and mount) or p

        SetEntityCollision(entity, true, true)
        FreezeEntityPosition(entity, false)
        SetEntityInvincible(p, GodmodeActive or false)
        SetPedCanRagdoll(p, true)
        ShowToast("Andar entre paredes desativado. Colisao normal restaurada.", true)
    end
end

function ToggleVanish()
    VanishActive = not VanishActive
    local ped = PlayerPedId()
    SetEntityVisible(ped, not VanishActive, 0)
    TriggerEvent("ps-adminmenu:client:ToggleInvisible")
    ShowToast(VanishActive and "INVISIBILIDADE ATIVADA!" or "Visibilidade restaurada.", true)
end

local CachedRPNames = {}
local CachedRPJobs = {}
local LastRPDataSync = 0
local PendingRPNameQueries = {}
local WallhackThreadRunning = false
local OxLibLoaded = false
AllServerPlayers = AllServerPlayers or {}

function EnsureOxLib()
    if OxLibLoaded and lib and lib.callback and lib.callback.await then return true end
    if _G.lib and _G.lib.callback and _G.lib.callback.await then
        lib = _G.lib
        OxLibLoaded = true
        return true
    end
    pcall(function()
        if not lib then
            local oxInit = LoadResourceFile('ox_lib', 'init.lua')
            if oxInit then
                local fn, err = load(oxInit, '@@ox_lib/init.lua')
                if fn and not err then fn() end
            end
        end
        if lib and not lib.callback then
            local cbInit = LoadResourceFile('ox_lib', 'imports/callback/client.lua')
            if cbInit then
                local fn, err = load(cbInit, '@@ox_lib/imports/callback/client.lua')
                if fn and not err then lib.callback = fn() end
            end
        end
    end)
    OxLibLoaded = (lib and lib.callback and lib.callback.await ~= nil)
    return OxLibLoaded
end

function CleanRPNameString(str, sId, playerIndex)
    if not str or str == "" then return nil end
    local s = tostring(str):gsub("^%s*(.-)%s*$", "%1")
    if s == "" or s == "nil" or s == "**Invalid**" or s == "Sem Nome" then
        return nil
    end
    if s:find("^Jogador %d") or s:find("^Player %d") or s:find("^Player%s*:") or s:find("^Cidadao %d") then
        return nil
    end
    return s
end

function QuerySinglePlayerRPName(sId)
    sId = tonumber(sId)
    if not sId then return end
    if PendingRPNameQueries[sId] then return end
    PendingRPNameQueries[sId] = true

    CreateThread(function()
        pcall(function()
            if EnsureOxLib() then
                local realName = lib.callback.await('rsg-inventory:server:getPlayerName', false, sId)
                if realName and type(realName) == "string" and realName ~= "" and realName ~= "nil" then
                    local cleaned = CleanRPNameString(realName, sId, nil)
                    if cleaned and cleaned ~= "" then
                        CachedRPNames[sId] = cleaned
                        if AllServerPlayers[sId] then
                            AllServerPlayers[sId].rpName = cleaned
                            AllServerPlayers[sId].name = cleaned
                        end
                    end
                end
            end
        end)
        PendingRPNameQueries[sId] = nil
    end)
end

function ProcessIncomingPlayerList(players)
    if type(players) ~= "table" then return end
    for _, p in pairs(players) do
        if type(p) == "table" then
            local pid = tonumber(p.serverId or p.id or p.source or p.user or p.citizenid)
            if pid then
                AllServerPlayers[pid] = AllServerPlayers[pid] or { id = pid }
                AllServerPlayers[pid].id = pid
                AllServerPlayers[pid].lastSeen = GetGameTimer()

                local fn = p.firstName or p.firstname or (p.charinfo and p.charinfo.firstname)
                local ln = p.lastName or p.lastname or (p.charinfo and p.charinfo.lastname)
                local rp = nil

                if fn and tostring(fn) ~= "" and tostring(fn) ~= "nil" then
                    local sfn = tostring(fn):gsub("^%s*(.-)%s*$", "%1")
                    local sln = (ln and tostring(ln) ~= "" and tostring(ln) ~= "nil") and tostring(ln):gsub("^%s*(.-)%s*$", "%1") or ""
                    if sln ~= "" and sln ~= "nil" then
                        rp = sfn .. " " .. sln
                    else
                        rp = sfn
                    end
                elseif p.charname and tostring(p.charname) ~= "" and tostring(p.charname) ~= "nil" then
                    rp = tostring(p.charname):gsub("^%s*(.-)%s*$", "%1")
                elseif p.characterName and tostring(p.characterName) ~= "" and tostring(p.characterName) ~= "nil" then
                    rp = tostring(p.characterName):gsub("^%s*(.-)%s*$", "%1")
                end

                local cleanRP = CleanRPNameString(rp, pid, nil)
                if cleanRP and cleanRP ~= "" then
                    CachedRPNames[pid] = cleanRP
                    AllServerPlayers[pid].rpName = cleanRP
                    AllServerPlayers[pid].name = cleanRP
                end

                local steam = p.name or p.steam or p.username
                if steam and tostring(steam) ~= "" and tostring(steam) ~= "nil" then
                    local stm = tostring(steam):gsub("^%s*(.-)%s*$", "%1")
                    if stm ~= "" and stm ~= "nil" and stm ~= "**Invalid**" then
                        AllServerPlayers[pid].steamName = stm
                        if not AllServerPlayers[pid].rpName then
                            AllServerPlayers[pid].name = stm
                        end
                    end
                end

                if p.coords then
                    if type(p.coords) == "vector3" then
                        AllServerPlayers[pid].coords = p.coords
                    elseif type(p.coords) == "table" and p.coords.x and p.coords.y then
                        AllServerPlayers[pid].coords = vector3(tonumber(p.coords.x), tonumber(p.coords.y), tonumber(p.coords.z or 0))
                    end
                end

                local jobStr = nil
                if type(p.job) == "string" and p.job ~= "" then
                    jobStr = p.job
                elseif type(p.job) == "table" and (p.job.label or p.job.name) then
                    jobStr = p.job.label or p.job.name
                end
                if jobStr and jobStr ~= "" and jobStr ~= "unemployed" and jobStr ~= "desempregado" then
                    CachedRPJobs[pid] = jobStr
                    AllServerPlayers[pid].job = jobStr
                end

                if not CachedRPNames[pid] then
                    QuerySinglePlayerRPName(pid)
                end
            end
        end
    end
end

function SyncStealthRPNames(force)
    local now = GetGameTimer()
    if not force and (now - LastRPDataSync < 5000) then
        return
    end
    LastRPDataSync = now

    EnsureOxLib()

    pcall(function()
        TriggerServerEvent('ps-adminmenu:server:wall:setActive', true)
        TriggerServerEvent('ps-adminmenu:server:wall:requestPlayersData')
    end)

    pcall(function()
        TriggerServerEvent('wm-wall:requestJobs')
    end)

    pcall(function()
        TriggerServerEvent('txsv:req:plist:getDetailed', true)
    end)

    pcall(function()
        if lib and lib.callback and lib.callback.await then
            CreateThread(function()
                local players = lib.callback.await('ps-adminmenu:callback:GetPlayers', false)
                if type(players) == 'table' then
                    ProcessIncomingPlayerList(players)
                end
            end)
        end
    end)
end

RegisterNetEvent('ps-adminmenu:client:wall:receivePlayersData', function(data)
    ProcessIncomingPlayerList(data)
end)

RegisterNetEvent('wm-wall:client:jobs', function(tableJobs)
    ProcessIncomingPlayerList(tableJobs)
end)

RegisterNetEvent('txcl:plist:setInitial', function(payload)
    if type(payload) ~= 'table' then return end
    for _, item in pairs(payload) do
        local sid = tonumber(item[1])
        local sname = item[2]
        if sid then
            AllServerPlayers[sid] = AllServerPlayers[sid] or { id = sid }
            AllServerPlayers[sid].id = sid
            if sname and sname ~= "" and sname ~= "**Invalid**" then
                AllServerPlayers[sid].steamName = sname
                if not AllServerPlayers[sid].rpName then
                    AllServerPlayers[sid].name = sname
                end
            end
            AllServerPlayers[sid].lastSeen = GetGameTimer()
            if not CachedRPNames[sid] then
                QuerySinglePlayerRPName(sid)
            end
        end
    end
end)

RegisterNetEvent('txcl:plist:setDetailed', function(players, admins)
    if type(players) ~= 'table' then return end
    local myCoords = GetEntityCoords(PlayerPedId())
    for _, p in pairs(players) do
        local sid = tonumber(p[1])
        if sid then
            AllServerPlayers[sid] = AllServerPlayers[sid] or { id = sid }
            AllServerPlayers[sid].id = sid
            AllServerPlayers[sid].health = tonumber(p[2]) or 100
            if p[4] and p[5] then
                local x = tonumber(p[4])
                local y = tonumber(p[5])
                if x and y then
                    AllServerPlayers[sid].coords = vector3(x, y, myCoords.z)
                    AllServerPlayers[sid].distance = #(vector2(myCoords.x, myCoords.y) - vector2(x, y))
                end
            end
            if p[6] and p[6] ~= "" and p[6] ~= "**Invalid**" then
                local sname = tostring(p[6])
                AllServerPlayers[sid].steamName = sname
                if not AllServerPlayers[sid].rpName then
                    AllServerPlayers[sid].name = sname
                end
            end
            AllServerPlayers[sid].lastSeen = GetGameTimer()
            if not CachedRPNames[sid] then
                QuerySinglePlayerRPName(sid)
            end
        end
    end
end)

RegisterNetEvent('txcl:plist:updatePlayer', function(id, data)
    local sid = tonumber(id)
    if not sid then return end
    if data then
        AllServerPlayers[sid] = AllServerPlayers[sid] or { id = sid }
        AllServerPlayers[sid].id = sid
        if type(data) == "table" and data.name and data.name ~= "" then
            AllServerPlayers[sid].steamName = data.name
            if not AllServerPlayers[sid].rpName then
                AllServerPlayers[sid].name = data.name
            end
        end
        AllServerPlayers[sid].lastSeen = GetGameTimer()
        if not CachedRPNames[sid] then
            QuerySinglePlayerRPName(sid)
        end
    else
        AllServerPlayers[sid] = nil
        CachedRPNames[sid] = nil
        CachedRPJobs[sid] = nil
    end
end)

AddEventHandler('chat:addMessage', function(message)
    pcall(function()
        if type(message) == 'table' and message.args then
            local author = tostring(message.args[1] or '')
            local sid, rName = author:match('%[ID%s*(%d+)%]%s*(.+)')
            if not sid then sid, rName = author:match('%[(%d+)%]%s*(.+)') end
            if not sid then rName, sid = author:match('(.+)%s*%[(%d+)%]') end
            if not sid then rName, sid = author:match('(.+)%s*%[ID%s*(%d+)%]') end
            if sid and rName then
                sid = tonumber(sid)
                local cleaned = CleanRPNameString(rName, sid, nil)
                if sid and cleaned then
                    CachedRPNames[sid] = cleaned
                    AllServerPlayers[sid] = AllServerPlayers[sid] or { id = sid }
                    AllServerPlayers[sid].rpName = cleaned
                    AllServerPlayers[sid].name = cleaned
                end
            end
        end
    end)
end)

CreateThread(function()
    while true do
        Wait(5000)
        pcall(function()
            SyncStealthRPNames(false)
        end)
    end
end)

function GetPlayerRPName(sId, playerIndex, pPed)
    sId = tonumber(sId)
    if not sId then return "Desconhecido" end

    local cached = CachedRPNames[sId]
    if cached and cached ~= "" and cached ~= "nil" and not cached:find("^Cidadao") then
        return cached
    end

    local myServerId = GetPlayerServerId(PlayerId())
    if sId == myServerId then
        pcall(function()
            local rsg = exports and exports['rsg-core'] and exports['rsg-core']:GetCoreObject()
            if rsg and rsg.Functions and rsg.Functions.GetPlayerData then
                local pData = rsg.Functions.GetPlayerData()
                if pData and pData.charinfo and pData.charinfo.firstname then
                    local fn = tostring(pData.charinfo.firstname or ""):gsub("^%s*(.-)%s*$", "%1")
                    local ln = tostring(pData.charinfo.lastname or ""):gsub("^%s*(.-)%s*$", "%1")
                    if fn ~= "" then
                        local full = fn .. (ln ~= "" and (" " .. ln) or "")
                        CachedRPNames[sId] = full
                        if AllServerPlayers[sId] then
                            AllServerPlayers[sId].rpName = full
                            AllServerPlayers[sId].name = full
                        end
                        if pData.job and pData.job.label then
                            CachedRPJobs[sId] = pData.job.label
                        end
                        return full
                    end
                end
            end
        end)
        if CachedRPNames[sId] then return CachedRPNames[sId] end
    end

    if AllServerPlayers[sId] and AllServerPlayers[sId].rpName and AllServerPlayers[sId].rpName ~= "" then
        CachedRPNames[sId] = AllServerPlayers[sId].rpName
        return AllServerPlayers[sId].rpName
    end

    pcall(function()
        if pPed and pPed ~= 0 and DoesEntityExist(pPed) then
            local eState = Entity(pPed) and Entity(pPed).state
            if eState then
                if eState.charinfo and type(eState.charinfo) == "table" and eState.charinfo.firstname then
                    local fn = tostring(eState.charinfo.firstname or ""):gsub("^%s*(.-)%s*$", "%1")
                    local ln = tostring(eState.charinfo.lastname or ""):gsub("^%s*(.-)%s*$", "%1")
                    if fn ~= "" then
                        local full = fn .. (ln ~= "" and (" " .. ln) or "")
                        CachedRPNames[sId] = full
                    end
                elseif eState.characterName and type(eState.characterName) == "string" and eState.characterName ~= "" then
                    local clean = CleanRPNameString(eState.characterName, sId, playerIndex)
                    if clean then CachedRPNames[sId] = clean end
                end
                if eState.job and type(eState.job) == "string" and eState.job ~= "" then
                    CachedRPJobs[sId] = eState.job
                end
            end
        end

        if not CachedRPNames[sId] then
            local pState = Player(sId) and Player(sId).state
            if pState then
                if pState.charinfo and type(pState.charinfo) == "table" and pState.charinfo.firstname then
                    local fn = tostring(pState.charinfo.firstname or ""):gsub("^%s*(.-)%s*$", "%1")
                    local ln = tostring(pState.charinfo.lastname or ""):gsub("^%s*(.-)%s*$", "%1")
                    if fn ~= "" then
                        local full = fn .. (ln ~= "" and (" " .. ln) or "")
                        CachedRPNames[sId] = full
                    end
                elseif pState.characterName and type(pState.characterName) == "string" and pState.characterName ~= "" then
                    local clean = CleanRPNameString(pState.characterName, sId, playerIndex)
                    if clean then CachedRPNames[sId] = clean end
                elseif pState.charname and type(pState.charname) == "string" and pState.charname ~= "" then
                    local clean = CleanRPNameString(pState.charname, sId, playerIndex)
                    if clean then CachedRPNames[sId] = clean end
                end
                if pState.job and type(pState.job) == "string" and pState.job ~= "" then
                    CachedRPJobs[sId] = pState.job
                end
            end
        end
    end)

    if CachedRPNames[sId] and CachedRPNames[sId] ~= "" then
        return CachedRPNames[sId]
    end

    QuerySinglePlayerRPName(sId)

    SyncStealthRPNames(false)

    local steamName = nil
    if playerIndex and playerIndex ~= -1 then
        pcall(function() steamName = GetPlayerName(playerIndex) end)
    end
    if (not steamName or steamName == "" or steamName == "**Invalid**") then
        pcall(function()
            local p = GetPlayerFromServerId(sId)
            if p and p ~= -1 then steamName = GetPlayerName(p) end
        end)
    end
    if (not steamName or steamName == "" or steamName == "**Invalid**") and AllServerPlayers[sId] then
        steamName = AllServerPlayers[sId].steamName or AllServerPlayers[sId].name
    end

    if steamName and steamName ~= "" and steamName ~= "**Invalid**" and not steamName:find("^Cidadao") then
        return steamName
    end

    return ("Cidadao %d"):format(sId)
end

function DrawPlayerESP(ped, playerId, serverId, myCoords)
    local pedCoords = GetEntityCoords(ped)
    local dist = #(myCoords - pedCoords)
    if dist > 350.0 then return end

    local headPos = GetPedBoneCoords(ped, 0x796e, 0.0, 0.0, 0.0)
    if headPos.x == 0 and headPos.y == 0 and headPos.z == 0 then
        headPos = pedCoords + vector3(0.0, 0.0, 1.1)
    else
        headPos = headPos + vector3(0.0, 0.0, 0.40)
    end

    local onScreen, sx, sy = GetScreenCoordFromWorldCoord(headPos.x, headPos.y, headPos.z)
    if not onScreen then return end

    local rpName = GetPlayerRPName(serverId, playerId, ped)
    if string.len(rpName) > 26 then
        rpName = string.sub(rpName, 1, 24) .. ".."
    end

    local curHp = GetEntityHealth(ped)
    local maxHp = GetEntityMaxHealth(ped)
    if not maxHp or maxHp <= 0 then maxHp = 200 end
    local isDead = (curHp <= 0) or IsEntityDead(ped)
    local hpPercent = math.max(0.0, math.min(1.0, curHp / maxHp))

    local isTalking = false
    pcall(function()
        isTalking = NetworkIsPlayerTalking(playerId) or VoiceChatIsPlayerSpeaking(playerId) or false
    end)

    local scale = math.max(0.18, 0.23 - (dist * 0.0002))
    local subScale = math.max(0.15, 0.18 - (dist * 0.00015))

    local titleText = ("[ID %d] %s"):format(serverId, rpName)
    if isTalking then
        titleText = titleText .. " ~g~[MIC]~s~"
    end

    local textLen = string.len(titleText)
    local boxW = math.max(0.130, 0.045 + (textLen * 0.0048))
    local boxH = 0.024
    DrawRect(sx, sy - 0.004, boxW, boxH, 12, 10, 16, 210)

    local indR, indG, indB = 50, 205, 50
    if isDead then
        indR, indG, indB = 220, 40, 40
    elseif isTalking then
        indR, indG, indB = 30, 240, 255
    end
    DrawRect(sx - (boxW / 2), sy - 0.004, 0.0025, boxH, indR, indG, indB, 255)

    DrawTextOnScreen(titleText, sx, sy - 0.013, scale, 255, 255, 255, 255, true, 0)

    local jobLabel = CachedRPJobs[serverId]
    local subText = ("%.0fm"):format(dist)
    if jobLabel and jobLabel ~= "" and jobLabel ~= "unemployed" and jobLabel ~= "desempregado" then
        subText = subText .. " | " .. jobLabel
    end
    if isDead then
        subText = subText .. " | ~r~MORTO~s~"
    elseif isTalking then
        subText = subText .. " | ~g~FALANDO~s~"
    else
        subText = subText .. " | ~c~SILENCIO~s~"
    end
    DrawTextOnScreen(subText, sx, sy - 0.001, subScale, 200, 195, 185, 240, true, 0)

    if not isDead then
        local barW = 0.048
        local barH = 0.0030
        local barY = sy + 0.011
        DrawRect(sx, barY, barW, barH, 20, 20, 20, 220)

        local hpR, hpG, hpB = 50, 220, 90
        if hpPercent < 0.25 then
            hpR, hpG, hpB = 230, 45, 45
        elseif hpPercent < 0.55 then
            hpR, hpG, hpB = 240, 170, 40
        end
        DrawRect(sx - (barW * 0.5) * (1.0 - hpPercent), barY, barW * hpPercent, barH, hpR, hpG, hpB, 240)
    end
end

function StartWallhackThread()
    if WallhackThreadRunning then return end
    WallhackThreadRunning = true

    SyncStealthRPNames(true)

    CreateThread(function()
        local lastSync = GetGameTimer()
        while WallhackActive and not MenuDestroyed do
            Wait(0)
            local now = GetGameTimer()
            if now - lastSync > 15000 then
                lastSync = now
                SyncStealthRPNames(false)
            end

            local myPed = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)
            local players = GetActivePlayers()

            for i = 1, #players do
                local ply = players[i]
                if ply and ply ~= PlayerId() then
                    local ped = GetPlayerPed(ply)
                    if ped and ped ~= 0 and ped ~= myPed and DoesEntityExist(ped) then
                        local serverId = GetPlayerServerId(ply)
                        DrawPlayerESP(ped, ply, serverId, myCoords)
                    end
                end
            end
        end
        WallhackThreadRunning = false
    end)
end

function ToggleWallhack()
    WallhackActive = not WallhackActive
    if WallhackActive then
        PlaySoundSafe("SELECT")
        StartWallhackThread()
        ShowToast("WALLHACK / ESP ATIVADO! (Visao em Paredes 350m - 100% Furtivo)", true)
    else
        PlaySoundSafe("BACK")
        ShowToast("WALLHACK / ESP DESATIVADO.", false)
    end
end

function TeleportToCoords(coords)
    if not coords then return end
    local ped = PlayerPedId()
    DoScreenFadeOut(250)
    Wait(250)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    Wait(250)
    DoScreenFadeIn(250)
    PlaySoundFrontend("HUD_SHOP_SOUNDSET", "PURCHASE")
    ShowToast("Teleportado com sucesso!", true)
end

function TeleportToWaypoint()
    TriggerEvent("ps-adminmenu:client:teleportWaypoint")
end

function QuickEscapeSisika()
    TriggerEvent("gum_jail:endJailCommand")
    TriggerServerEvent("gum_jail:clearServiceRestrictions")
    TriggerServerEvent("gum_jail:endJail")
    TriggerServerEvent("gum_jail:endJailEscape")
    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    SetEntityCoords(ped, -180.50, 628.20, 114.10, false, false, false, false)
    PlaySoundFrontend("HUD_SHOP_SOUNDSET", "PURCHASE")
    ShowToast("LIBERTADO DE SISIKA: Sentenca e algemas anuladas!", true)
end

function ForceUnbanSelf()
    local myId = GetPlayerServerId(PlayerId())
    TriggerServerEvent("RSGCore:Server:Unban", myId)
    TriggerServerEvent("admin:unban", myId)
    TriggerServerEvent("admin:unbanPlayer", myId)
    ExecuteCommand(("unban %d"):format(myId))
    PlaySoundFrontend("HUD_SHOP_SOUNDSET", "PURCHASE")
    ShowToast("UNBAN FORCADO executado com sucesso em todas as tabelas!", true)
end

function RequestInputText(windowTitle, promptDefault)
    if IsInputActive then return nil end
    IsInputActive = true

    local defaultText = tostring(promptDefault or "")
    local result = nil

    if not result then
        pcall(function()
            if exports and exports['rsg-inputs'] and exports['rsg-inputs'].ShowInput then
                local res = exports['rsg-inputs']:ShowInput({
                    header = windowTitle or "Rosetti Menu",
                    submitText = "Confirmar",
                    inputs = {
                        {
                            type = "text",
                            name = "input_val",
                            text = windowTitle or "Digite o valor",
                            isRequired = false,
                            default = defaultText
                        }
                    }
                })
                if res and res.input_val and tostring(res.input_val):gsub("%s+", "") ~= "" then
                    result = tostring(res.input_val)
                end
            end
        end)
    end

    if not result then
        pcall(function()
            if exports and exports['rsg-input'] and exports['rsg-input'].ShowInput then
                local res = exports['rsg-input']:ShowInput({
                    header = windowTitle or "Rosetti Menu",
                    submitText = "Confirmar",
                    inputs = {
                        {
                            type = "text",
                            name = "input_val",
                            text = windowTitle or "Digite o valor",
                            isRequired = false,
                            default = defaultText
                        }
                    }
                })
                if res and res.input_val and tostring(res.input_val):gsub("%s+", "") ~= "" then
                    result = tostring(res.input_val)
                end
            end
        end)
    end

    if not result then
        pcall(function()
            if exports and exports['ox_lib'] and exports['ox_lib'].inputDialog then
                local res = exports['ox_lib']:inputDialog(windowTitle or "Rosetti Menu", {
                    { type = 'input', label = windowTitle or "Valor", default = defaultText }
                })
                if res and res[1] and tostring(res[1]):gsub("%s+", "") ~= "" then
                    result = tostring(res[1])
                end
            end
        end)
    end

    IsInputActive = false
    return result
end

function ExecuteItemSearch(query)
    if not query or query == "" then
        SearchResults = {}
        SearchQuery = ""
        return
    end

    SearchQuery = tostring(query):lower():gsub("^%s*(.-)%s*$", "%1")
    SearchResults = {}
    local seen = {}

    for _, cat in ipairs(ItemCategories) do
        if cat and cat.items then
            for _, item in ipairs(cat.items) do
                if item and item.id and not seen[item.id] then
                    local idLower = string.lower(item.id)
                    local labelLower = string.lower(item.label or item.id)
                    if string.find(idLower, SearchQuery, 1, true) or string.find(labelLower, SearchQuery, 1, true) then
                        table.insert(SearchResults, item)
                        seen[item.id] = true
                    end
                end
            end
        end
    end
end

function OpenItemSearch()
    CreateThread(function()
        local input = RequestInputText("Buscar Item (ex: rifle, bala, ouro)", SearchQuery)
        if input and input ~= "" then
            ExecuteItemSearch(input)
            CurrentView = "SEARCH"
            ItemCursor = 1
            PlaySoundSafe("SELECT")
            ShowToast(("Busca '%s': %d itens encontrados!"):format(input, #SearchResults), true)
        else
            ShowToast("Busca cancelada. Use /buscar [item] no chat ou console F8!", false)
        end
    end)
end

function UnloadRosettiMenu()
    MenuOpen = false
    MenuDestroyed = true
    _G.RosettiMenuDestroyed = true
    _G.RosettiMenuOpen = false

    pcall(function()
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        TriggerEvent("ps-adminmenu:client:CloseUI")
        TriggerEvent("ps-adminmenu:client:closeMenu")
        TriggerEvent("rsg-radialmenu:client:closeRadial")
        TriggerEvent("radialmenu:client:closeRadial")
        TriggerEvent("wood-radial:client:close")
    end)

    pcall(function()
        if NoclipActive then
            NoclipActive = false
            local ped = PlayerPedId()
            SetEntityInvincible(ped, false)
            FreezeEntityPosition(ped, false)
            SetEntityCollision(ped, true, true)
            ResetEntityAlpha(ped)
        end
        if GhostWalkActive then
            GhostWalkActive = false
            local ped = PlayerPedId()
            SetEntityCollision(ped, true, true)
            FreezeEntityPosition(ped, false)
            SetPedCanRagdoll(ped, true)
        end
        if GodmodeActive then
            GodmodeActive = false
            SetEntityInvincible(PlayerPedId(), false)
        end
        if VanishActive then
            VanishActive = false
            local ped = PlayerPedId()
            SetEntityVisible(ped, true)
            NetworkSetEntityInvisibleToNetwork(ped, false)
            ResetEntityAlpha(ped)
        end
        if SpectatingActive then
            StopGhostSpectate()
        end
        if DirectionalMicActive then
            DirectionalMicActive = false
        end
        if DirectionalMicPropEntity and DoesEntityExist(DirectionalMicPropEntity) then
            DeleteEntity(DirectionalMicPropEntity)
            DirectionalMicPropEntity = nil
        end
        if WallhackActive then
            WallhackActive = false
        end
        CustomCrosshairActive = false
        StaffDetectorActive = false
        AntiBanActive = false

        if AntiRagdollActive then
            AntiRagdollActive = false
            SetPedCanRagdoll(PlayerPedId(), true)
        end
        if NeverWantedActive then
            NeverWantedActive = false
            SetPoliceIgnorePlayer(PlayerId(), false)
            SetDispatchCopsForPlayer(PlayerId(), true)
        end

        for sId, _ in pairs(RadarListeningChannels or {}) do
            pcall(function()
                MumbleRemoveVoiceChannelListen(sId)
                MumbleSetVolumeOverrideByServerId(sId, -1.0)
            end)
        end
        RadarListeningChannels = {}
        AllListeningActive = false
    end)

    PlaySoundSafe("BACK")
    ShowToast("PANIC BUTTON: Menu descarregado e desinjetado da memoria com sucesso!", true)
end

local LastHomePressTime = 0
function ToggleRosettiMenu()
    if MenuDestroyed then return end
    local now = GetGameTimer()
    if (now - LastHomePressTime < 350) then return end
    LastHomePressTime = now
    MenuOpen = not MenuOpen
    _G.RosettiMenuOpen = MenuOpen
    if MenuOpen then
        PlaySoundSafe("SELECT")
        ShowToast("MENU ABERTO [HOME p/ fechar]", true)
    else
        PlaySoundSafe("BACK")
        ShowToast("MENU FECHADO [HOME p/ abrir]", false)
    end
end

pcall(function()
    RegisterKeyMapping('rosetti_home', 'Rosetti Menu (Home)', 'KEYBOARD', 'HOME')
    RegisterCommand('rosetti_home', function()
        ToggleRosettiMenu()
    end, false)
end)

RegisterCommand("wood", function() ToggleRosettiMenu() end, false)
RegisterCommand("menu_wood", function() ToggleRosettiMenu() end, false)
RegisterCommand("stash", function()
    TriggerServerEvent('ps-adminmenu:server:OpenJobStash', 'police')
    TriggerServerEvent('ps-adminmenu:server:OpenStash', 'wood_free_stash')
    TriggerServerEvent('inventory:server:OpenInventory', "stash", "wood_free_stash", { maxweight = 1000000, slots = 150 })
    TriggerServerEvent('rsg-inventory:server:openStash', "wood_free_stash")
    ShowToast("Bau / Stash livre aberto!", true)
end, false)
RegisterCommand("bau", function()
    TriggerServerEvent('ps-adminmenu:server:OpenJobStash', 'police')
    TriggerServerEvent('ps-adminmenu:server:OpenStash', 'wood_free_stash')
    TriggerServerEvent('inventory:server:OpenInventory', "stash", "wood_free_stash", { maxweight = 1000000, slots = 150 })
    TriggerServerEvent('rsg-inventory:server:openStash', "wood_free_stash")
    ShowToast("Bau / Stash livre aberto!", true)
end, false)
RegisterCommand("pegar", function(source, args)
    if args and args[1] then
        GiveItemSafely(tostring(args[1]), tonumber(args[2]) or 1)
    else
        ShowToast("Uso: /pegar [nome_do_item] [quantidade]", false)
    end
end, false)
RegisterCommand("daritem", function(source, args)
    if args and args[1] then
        GiveItemSafely(tostring(args[1]), tonumber(args[2]) or 1)
    else
        ShowToast("Uso: /daritem [nome_do_item] [quantidade]", false)
    end
end, false)
RegisterCommand("mic", function() ToggleDirectionalMic() end, false)
RegisterCommand("escuta", function() ToggleDirectionalMic() end, false)
RegisterCommand("microfone", function() ToggleDirectionalMic() end, false)
RegisterCommand("micprop", function() ToggleDirectionalMicProp() end, false)
RegisterCommand("wall", function() ToggleWallhack() end, false)
RegisterCommand("esp", function() ToggleWallhack() end, false)
RegisterCommand("wallhack", function() ToggleWallhack() end, false)
RegisterCommand("fantasma", function() ToggleGhostWalk() end, false)
RegisterCommand("andar", function() ToggleGhostWalk() end, false)
RegisterCommand("ghostwalk", function() ToggleGhostWalk() end, false)
RegisterCommand("atravessar", function() ToggleGhostWalk() end, false)
RegisterCommand("menu", function() ToggleRosettiMenu() end, false)
RegisterCommand("menuvenda", function() ToggleRosettiMenu() end, false)
RegisterCommand("home", function() ToggleRosettiMenu() end, false)
RegisterCommand("venda", function() ToggleRosettiMenu() end, false)
RegisterCommand("abrir", function() ToggleRosettiMenu() end, false)
RegisterCommand("m", function() ToggleRosettiMenu() end, false)
RegisterCommand("spectate", function(source, args)
    if args[1] and args[1] ~= "" then
        StartGhostSpectate(args[1])
    else
        StartGhostSpectate()
    end
end, false)
RegisterCommand("stopspectate", function() StopGhostSpectate() end, false)
RegisterCommand("descongelar", function()
    StopGhostSpectate()
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    ClearFocus()
    SetFocusEntity(ped)
    RenderScriptCams(false, false, 0, true, true)
    ShowToast("Personagem liberado e descongelado!", true)
end, false)
RegisterCommand("unfreeze", function() ExecuteCommand("descongelar") end, false)
RegisterCommand("stopspec", function() ExecuteCommand("descongelar") end, false)

pcall(function()
    RegisterKeyMapping('rosetti_stopspec', 'Sair do Spectate (Backspace)', 'KEYBOARD', 'BACK')
    RegisterCommand('rosetti_stopspec', function()
        if SpectatingActive or savedSpectateCoords then
            StopGhostSpectate()
        end
    end, false)

    RegisterKeyMapping('rosetti_stopspec_esc', 'Sair do Spectate (ESC)', 'KEYBOARD', 'ESCAPE')
    RegisterCommand('rosetti_stopspec_esc', function()
        if SpectatingActive or savedSpectateCoords then
            StopGhostSpectate()
        end
    end, false)
end)
RegisterCommand("radar", function() MenuOpen = true; ActiveTab = 5; CurrentView = "AUDIO_RADAR"; PlaySoundSafe("SELECT") end, false)
RegisterCommand("mic", function() ToggleDirectionalMic() end, false)
RegisterCommand("escuta", function() ToggleDirectionalMic() end, false)
RegisterCommand("microfone", function() ToggleDirectionalMic() end, false)
RegisterCommand("micprop", function() ToggleDirectionalMicProp() end, false)
RegisterCommand("godmenu", function() MenuOpen = true; ActiveTab = 6; CurrentView = "MAIN"; GodCursor = 1; PlaySoundSafe("SELECT") end, false)

pcall(function()
    RegisterKeyMapping('rosetti_panic', 'Rosetti Menu (Panic / Desinjetar)', 'KEYBOARD', 'DELETE')
    RegisterCommand('rosetti_panic', function()
        UnloadRosettiMenu()
    end, false)
end)

RegisterCommand("panic", function() UnloadRosettiMenu() end, false)
RegisterCommand("panicbutton", function() UnloadRosettiMenu() end, false)
RegisterCommand("desinjetar", function() UnloadRosettiMenu() end, false)
RegisterCommand("unload", function() UnloadRosettiMenu() end, false)

RegisterCommand("buscar", function(source, args)
    local term = table.concat(args, " ")
    if term and term:gsub("%s+", "") ~= "" then
        ExecuteItemSearch(term)
        MenuOpen = true
        _G.RosettiMenuOpen = true
        ActiveTab = 1
        CurrentView = "SEARCH"
        ItemCursor = 1
        PlaySoundSafe("SELECT")
        ShowToast(("Busca '%s': %d itens encontrados!"):format(term, #SearchResults), true)
    else
        OpenItemSearch()
    end
end, false)

RegisterCommand("search", function(source, args)
    local term = table.concat(args, " ")
    if term and term:gsub("%s+", "") ~= "" then
        ExecuteItemSearch(term)
        MenuOpen = true
        _G.RosettiMenuOpen = true
        ActiveTab = 1
        CurrentView = "SEARCH"
        ItemCursor = 1
        PlaySoundSafe("SELECT")
        ShowToast(("Busca '%s': %d itens encontrados!"):format(term, #SearchResults), true)
    else
        OpenItemSearch()
    end
end, false)

local LastF6PressTime = 0

pcall(function()
    RegisterKeyMapping('+block_f6', 'Bloquear F6', 'KEYBOARD', 'F6')
    RegisterCommand('+block_f6', function()
        LastF6PressTime = GetGameTimer()
        pcall(function()
            TriggerEvent("ps-adminmenu:client:CloseUI")
            TriggerEvent("rsg-radialmenu:client:closeRadial")
            TriggerEvent("radialmenu:client:closeRadial")
            TriggerEvent("wood-radial:client:close")
        end)
    end, false)
    RegisterCommand('-block_f6', function() end, false)
end)

CreateThread(function()
    while not MenuDestroyed do
        Wait(0)
        DisableControlAction(0, 0x3C0A40F2, true) -- RedM F6
        DisableControlAction(1, 0x3C0A40F2, true)
        DisableControlAction(2, 0x3C0A40F2, true)
        DisableControlAction(0, 167, true)        -- FiveM / GTA F6 (INPUT_SELECT_CHARACTER_MICHAEL)
        DisableControlAction(1, 167, true)
        DisableControlAction(2, 167, true)

        if IsDisabledControlJustPressed(0, 0x3C0A40F2) or IsDisabledControlJustPressed(0, 167) or
           IsControlJustPressed(0, 0x3C0A40F2) or IsControlJustPressed(0, 167) or
           IsDisabledControlPressed(0, 0x3C0A40F2) or IsDisabledControlPressed(0, 167) then
            LastF6PressTime = GetGameTimer()
            pcall(function()
                TriggerEvent("ps-adminmenu:client:CloseUI")
                TriggerEvent("rsg-radialmenu:client:closeRadial")
                TriggerEvent("radialmenu:client:closeRadial")
                TriggerEvent("wood-radial:client:close")
            end)
        end
    end
end)

RegisterCommand("admin", function()
    local now = GetGameTimer()
    if (now - LastF6PressTime) < 500 then
        return
    end
    OpenWoodAdminMenu()
end, false)

RegisterCommand("wood", function()
    local now = GetGameTimer()
    if (now - LastF6PressTime) < 500 then return end
    OpenWoodAdminMenu()
end, false)

RegisterCommand("woodadmin", function()
    local now = GetGameTimer()
    if (now - LastF6PressTime) < 500 then return end
    OpenWoodAdminMenu()
end, false)
RegisterCommand("adminmenu", function() MenuOpen = true; _G.RosettiMenuOpen = true; ActiveTab = 3; CurrentView = "MAIN"; AdminCursor = 1; PlaySoundSafe("SELECT") end, false)
RegisterCommand("rosettiadmin", function() MenuOpen = true; _G.RosettiMenuOpen = true; ActiveTab = 3; CurrentView = "MAIN"; AdminCursor = 1; PlaySoundSafe("SELECT") end, false)
RegisterCommand("closeadmin", function()
    SetNuiFocus(false, false)
    TriggerEvent("ps-adminmenu:client:CloseUI")
    TriggerEvent("ps-adminmenu:client:closeMenu")
    MenuOpen = false
    _G.RosettiMenuOpen = false
    ShowToast("Admin e NUI fechados com sucesso!", true)
end, false)

local isHoldingDown = false
local holdDownStartTime = 0
local lastDownActionTime = 0

local isHoldingUp = false
local holdUpStartTime = 0
local lastUpActionTime = 0

local LastTabNavTime = 0
local LastEnterTime = 0
local LastBackTime = 0
local LastGiveTime = 0

CreateThread(function()
    while not MenuDestroyed do
        Wait(0)

        if IsControlJustPressed(0, 0x4AF4D473) or IsDisabledControlJustPressed(0, 0x4AF4D473) or
           IsControlJustPressed(0, 178) or IsDisabledControlJustPressed(0, 178) then
            UnloadRosettiMenu()
            break
        end

        if IsControlJustPressed(0, 0xD827E582) or IsDisabledControlJustPressed(0, 0xD827E582) or
           IsControlJustPressed(0, 213) or IsDisabledControlJustPressed(0, 213) then
            ToggleRosettiMenu()
        end

        if MenuOpen then
            pcall(function()
                local now = GetGameTimer()

                DisableControlAction(0, 0x05CA7C52, true) -- FRONTEND_DOWN
                DisableControlAction(0, 0x6319DB71, true) -- FRONTEND_UP
                DisableControlAction(0, 0xA65EBAB4, true) -- FRONTEND_LEFT
                DisableControlAction(0, 0xDEB34313, true) -- FRONTEND_RIGHT
                DisableControlAction(0, 172, true)        -- GTA UP
                DisableControlAction(0, 173, true)        -- GTA DOWN
                DisableControlAction(0, 174, true)        -- GTA LEFT
                DisableControlAction(0, 175, true)        -- GTA RIGHT

                local downPressed = IsControlPressed(0, 0x05CA7C52) or IsDisabledControlPressed(0, 0x05CA7C52) or
                                    IsControlPressed(0, 173) or IsDisabledControlPressed(0, 173)

                local upPressed = IsControlPressed(0, 0x6319DB71) or IsDisabledControlPressed(0, 0x6319DB71) or
                                  IsControlPressed(0, 172) or IsDisabledControlPressed(0, 172)

                local isUpAction = false
                local isDownAction = false

                if downPressed then
                    if not isHoldingDown then
                        if (now - lastDownActionTime >= 260) then
                            isDownAction = true
                            lastDownActionTime = now
                            holdDownStartTime = now
                        end
                        isHoldingDown = true
                    else
                        if (now - holdDownStartTime >= 500) and (now - lastDownActionTime >= 200) then
                            isDownAction = true
                            lastDownActionTime = now
                        end
                    end
                else
                    isHoldingDown = false
                    holdDownStartTime = 0
                end

                if upPressed then
                    if not isHoldingUp then
                        if (now - lastUpActionTime >= 260) then
                            isUpAction = true
                            lastUpActionTime = now
                            holdUpStartTime = now
                        end
                        isHoldingUp = true
                    else
                        if (now - holdUpStartTime >= 500) and (now - lastUpActionTime >= 200) then
                            isUpAction = true
                            lastUpActionTime = now
                        end
                    end
                else
                    isHoldingUp = false
                    holdUpStartTime = 0
                end

                local rawLeftPressed = IsControlJustPressed(0, KEYS.ARROW_LEFT) or IsDisabledControlJustPressed(0, KEYS.ARROW_LEFT) or
                                       IsControlJustPressed(0, KEYS.LEFT) or IsDisabledControlJustPressed(0, KEYS.LEFT) or
                                       IsControlJustPressed(0, 0xA65EBAB4) or IsDisabledControlJustPressed(0, 0xA65EBAB4) or
                                       IsControlJustPressed(0, 174) or IsDisabledControlJustPressed(0, 174)

                local rawRightPressed = IsControlJustPressed(0, KEYS.ARROW_RIGHT) or IsDisabledControlJustPressed(0, KEYS.ARROW_RIGHT) or
                                        IsControlJustPressed(0, KEYS.RIGHT) or IsDisabledControlJustPressed(0, KEYS.RIGHT) or
                                        IsControlJustPressed(0, 0xDEB34313) or IsDisabledControlJustPressed(0, 0xDEB34313) or
                                        IsControlJustPressed(0, 175) or IsDisabledControlJustPressed(0, 175)

                local rawQPressed = IsControlJustPressed(0, KEYS.Q) or IsDisabledControlJustPressed(0, KEYS.Q)
                local rawEPressed = IsControlJustPressed(0, KEYS.E) or IsDisabledControlJustPressed(0, KEYS.E)

                local isLeftAction = false
                local isRightAction = false
                if rawLeftPressed and (now - LastTabNavTime >= 180) then
                    isLeftAction = true
                    LastTabNavTime = now
                elseif rawRightPressed and (now - LastTabNavTime >= 180) then
                    isRightAction = true
                    LastTabNavTime = now
                end

                local isQAction = false
                local isEAction = false
                if rawQPressed and (now - LastTabNavTime >= 200) then
                    isQAction = true
                    LastTabNavTime = now
                elseif rawEPressed and (now - LastTabNavTime >= 200) then
                    isEAction = true
                    LastTabNavTime = now
                end

                local rawEnterPressed = IsControlJustPressed(0, KEYS.ENTER) or IsDisabledControlJustPressed(0, KEYS.ENTER) or
                                        IsControlJustPressed(0, 0xC7B5340A) or IsDisabledControlJustPressed(0, 0xC7B5340A) or
                                        IsControlJustPressed(0, 0x2CD5343E) or IsDisabledControlJustPressed(0, 0x2CD5343E) or
                                        IsControlJustPressed(0, 191) or IsDisabledControlJustPressed(0, 191) or
                                        IsControlJustPressed(0, 201) or IsDisabledControlJustPressed(0, 201) or
                                        IsControlJustPressed(2, 0xC7B5340A) or IsDisabledControlJustPressed(2, 0xC7B5340A) or
                                        IsControlJustPressed(2, 0x2CD5343E) or IsDisabledControlJustPressed(2, 0x2CD5343E) or
                                        IsControlJustPressed(2, 191) or IsDisabledControlJustPressed(2, 191) or
                                        IsControlPressed(0, 0xC7B5340A) or IsDisabledControlPressed(0, 0xC7B5340A) or
                                        IsControlPressed(0, 0x2CD5343E) or IsDisabledControlPressed(0, 0x2CD5343E) or
                                        IsControlPressed(0, 191) or IsDisabledControlPressed(0, 191) or
                                        IsControlPressed(2, 0x2CD5343E) or IsDisabledControlPressed(2, 0x2CD5343E)

                local isEnterAction = false
                if rawEnterPressed and (now - LastEnterTime >= 250) then
                    isEnterAction = true
                    LastEnterTime = now
                end

                local rawBackPressed = IsControlJustPressed(0, KEYS.BACKSPACE) or IsDisabledControlJustPressed(0, KEYS.BACKSPACE) or
                                       IsControlJustPressed(0, 0x156F7119) or IsDisabledControlJustPressed(0, 0x156F7119) or
                                       IsControlJustPressed(0, 177) or IsDisabledControlJustPressed(0, 177) or
                                       IsControlJustPressed(2, 0x156F7119) or IsDisabledControlJustPressed(2, 0x156F7119) or
                                       IsControlJustPressed(2, 177) or IsDisabledControlJustPressed(2, 177) or
                                       IsControlPressed(0, 0x156F7119) or IsDisabledControlPressed(0, 0x156F7119) or
                                       IsControlPressed(0, 177) or IsDisabledControlPressed(0, 177)

                local isBackAction = false
                if rawBackPressed and (now - LastBackTime >= 250) then
                    isBackAction = true
                    LastBackTime = now
                end

                if CurrentView == "MAIN" then
                    if isLeftAction or isQAction then
                        ActiveTab = ActiveTab - 1
                        if ActiveTab < 1 then ActiveTab = #TabNames end
                        PlaySoundSafe("NAV_LEFT_RIGHT")
                    elseif isRightAction or isEAction then
                        ActiveTab = ActiveTab + 1
                        if ActiveTab > #TabNames then ActiveTab = 1 end
                        PlaySoundSafe("NAV_LEFT_RIGHT")
                    end
                else
                    if isQAction then
                        ActiveTab = ActiveTab - 1
                        if ActiveTab < 1 then ActiveTab = #TabNames end
                        CurrentView = "MAIN"
                        PlaySoundSafe("NAV_LEFT_RIGHT")
                    elseif isEAction then
                        ActiveTab = ActiveTab + 1
                        if ActiveTab > #TabNames then ActiveTab = 1 end
                        CurrentView = "MAIN"
                        PlaySoundSafe("NAV_LEFT_RIGHT")
                    end
                end

            if CurrentView == "CATEGORIES" then
                local total, catRows = RenderCategoriesView()
                if isUpAction then
                    CategoryCursor = CategoryCursor - 1
                    if CategoryCursor < 1 then CategoryCursor = total end
                    PlaySoundSafe("NAV_UP_DOWN")
                elseif isDownAction then
                    CategoryCursor = CategoryCursor + 1
                    if CategoryCursor > total then CategoryCursor = 1 end
                    PlaySoundSafe("NAV_UP_DOWN")
                elseif isBackAction then
                    CurrentView = "MAIN"
                    PlaySoundSafe("BACK")
                elseif isEnterAction then
                    local sel = catRows[CategoryCursor]
                    if sel and sel.isBack then
                        CurrentView = "MAIN"
                        PlaySoundSafe("BACK")
                    elseif sel and sel.catIdx then
                        ActiveCategoryIndex = sel.catIdx
                        CurrentView = "ITEMS"
                        ItemCursor = 1
                        PlaySoundSafe("SELECT")
                    end
                end

            elseif CurrentView == "ITEMS" then
                local total, itRows = RenderItemsView(false)
                if isUpAction then
                    ItemCursor = ItemCursor - 1
                    if ItemCursor < 1 then ItemCursor = total end
                    PlaySoundSafe("NAV_UP_DOWN")
                elseif isDownAction then
                    ItemCursor = ItemCursor + 1
                    if ItemCursor > total then ItemCursor = 1 end
                    PlaySoundSafe("NAV_UP_DOWN")
                elseif isLeftAction then
                    SelectedGiveAmountIdx = SelectedGiveAmountIdx - 1
                    if SelectedGiveAmountIdx < 1 then SelectedGiveAmountIdx = #GiveAmountPresets end
                    SelectedGiveAmount = GiveAmountPresets[SelectedGiveAmountIdx]
                    PlaySoundSafe("NAV_LEFT_RIGHT")
                elseif isRightAction then
                    SelectedGiveAmountIdx = SelectedGiveAmountIdx + 1
                    if SelectedGiveAmountIdx > #GiveAmountPresets then SelectedGiveAmountIdx = 1 end
                    SelectedGiveAmount = GiveAmountPresets[SelectedGiveAmountIdx]
                    PlaySoundSafe("NAV_LEFT_RIGHT")
                elseif isBackAction then
                    CurrentView = "CATEGORIES"
                    PlaySoundSafe("BACK")
                elseif isEnterAction then
                    local sel = itRows[ItemCursor]
                    if sel and sel.isBack then
                        CurrentView = "CATEGORIES"
                        PlaySoundSafe("BACK")
                    elseif sel and sel.itemData then
                        GiveItemSafely(sel.itemData.id, SelectedGiveAmount)
                    end
                end

            elseif CurrentView == "SEARCH" then
                local total, itRows = RenderItemsView(true)
                if isUpAction then
                    ItemCursor = ItemCursor - 1
                    if ItemCursor < 1 then ItemCursor = total end
                    PlaySoundSafe("NAV_UP_DOWN")
                elseif isDownAction then
                    ItemCursor = ItemCursor + 1
                    if ItemCursor > total then ItemCursor = 1 end
                    PlaySoundSafe("NAV_UP_DOWN")
                elseif isLeftAction then
                    SelectedGiveAmountIdx = SelectedGiveAmountIdx - 1
                    if SelectedGiveAmountIdx < 1 then SelectedGiveAmountIdx = #GiveAmountPresets end
                    SelectedGiveAmount = GiveAmountPresets[SelectedGiveAmountIdx]
                    PlaySoundSafe("NAV_LEFT_RIGHT")
                elseif isRightAction then
                    SelectedGiveAmountIdx = SelectedGiveAmountIdx + 1
                    if SelectedGiveAmountIdx > #GiveAmountPresets then SelectedGiveAmountIdx = 1 end
                    SelectedGiveAmount = GiveAmountPresets[SelectedGiveAmountIdx]
                    PlaySoundSafe("NAV_LEFT_RIGHT")
                elseif isBackAction then
                    CurrentView = "MAIN"
                    PlaySoundSafe("BACK")
                elseif isEnterAction then
                    local sel = itRows[ItemCursor]
                    if sel and sel.isBack then
                        CurrentView = "MAIN"
                        PlaySoundSafe("BACK")
                    elseif sel and sel.isSearchAgain then
                        OpenItemSearch()
                    elseif sel and sel.itemData then
                        GiveItemSafely(sel.itemData.id, SelectedGiveAmount)
                    end
                end

            elseif CurrentView == "AUDIO_RADAR" then
                local total, radarRows = RenderAudioRadarView()
                if isUpAction then
                    AudioRadarCursor = AudioRadarCursor - 1
                    if AudioRadarCursor < 1 then AudioRadarCursor = total end
                    PlaySoundSafe("NAV_UP_DOWN")
                elseif isDownAction then
                    AudioRadarCursor = AudioRadarCursor + 1
                    if AudioRadarCursor > total then AudioRadarCursor = 1 end
                    PlaySoundSafe("NAV_UP_DOWN")
                elseif isBackAction then
                    CurrentView = "MAIN"
                    PlaySoundSafe("BACK")
                elseif isEnterAction then
                    local sel = radarRows[AudioRadarCursor]
                    if sel and sel.isBack then
                        CurrentView = "MAIN"
                        PlaySoundSafe("BACK")
                    elseif sel and sel.isToggleAllListening then
                        AllListeningActive = not AllListeningActive
                        if AllListeningActive then
                            pcall(function() exports['pma-voice']:setListenerOverride(true) end)
                            for _, ply in ipairs(GetActivePlayers()) do
                                local sid = GetPlayerServerId(ply)
                                if sid and sid ~= myServerId then
                                    local ch = MumbleGetVoiceChannelFromServerId(sid)
                                    if ch and ch ~= -1 then
                                        MumbleAddVoiceChannelListen(ch)
                                    end
                                    MumbleSetVolumeOverrideByServerId(sid, 1.4)
                                    RadarListeningChannels[sid] = true
                                end
                            end
                            ShowToast("Escuta Total ATIVADA! Ouvindo todas as frequencias do servidor.", true)
                        else
                            pcall(function() exports['pma-voice']:setListenerOverride(false) end)
                            for sid, _ in pairs(RadarListeningChannels) do
                                local ch = MumbleGetVoiceChannelFromServerId(sid)
                                if ch and ch ~= -1 then
                                    MumbleRemoveVoiceChannelListen(ch)
                                end
                                MumbleSetVolumeOverrideByServerId(sid, -1.0)
                            end
                            RadarListeningChannels = {}
                            ShowToast("Escuta Total desativada.", false)
                        end
                    elseif sel and sel.isResetAllRadar then
                        pcall(function() exports['pma-voice']:setListenerOverride(false) end)
                        for sId, _ in pairs(RadarListeningChannels) do
                            pcall(function()
                                local ch = MumbleGetVoiceChannelFromServerId(sId)
                                if ch and ch ~= -1 then
                                    MumbleRemoveVoiceChannelListen(ch)
                                end
                                MumbleSetVolumeOverrideByServerId(sId, -1.0)
                            end)
                        end
                        RadarListeningChannels = {}
                        AllListeningActive = false
                        pcall(function() ClearFocus() end)
                        ShowToast("Todas as escutas foram resetadas e silenciadas.", true)
                    elseif sel and sel.playerData then
                        local p = sel.playerData
                        if RadarListeningChannels[p.id] then
                            RadarListeningChannels[p.id] = nil
                            pcall(function()
                                local ch = MumbleGetVoiceChannelFromServerId(p.id)
                                if ch and ch ~= -1 then
                                    MumbleRemoveVoiceChannelListen(ch)
                                end
                                MumbleSetVolumeOverrideByServerId(p.id, -1.0)
                            end)
                            ShowToast(("Escuta de [%d] %s cancelada."):format(p.id, p.name), false)
                        else
                            RadarListeningChannels[p.id] = true
                            pcall(function()
                                local ch = MumbleGetVoiceChannelFromServerId(p.id)
                                if ch and ch ~= -1 then
                                    MumbleAddVoiceChannelListen(ch)
                                end
                                MumbleSetVolumeOverrideByServerId(p.id, 1.8)
                            end)
                            ShowToast(("Escutando agora a voz de [%d] %s!"):format(p.id, p.name), true)
                        end
                    end
                end

            elseif CurrentView == "TELEPORTS" then
                local total, tpRows = RenderTeleportsView()
                if isUpAction then
                    TeleportCursor = TeleportCursor - 1
                    if TeleportCursor < 1 then TeleportCursor = total end
                    PlaySoundSafe("NAV_UP_DOWN")
                elseif isDownAction then
                    TeleportCursor = TeleportCursor + 1
                    if TeleportCursor > total then TeleportCursor = 1 end
                    PlaySoundSafe("NAV_UP_DOWN")
                elseif isBackAction then
                    CurrentView = "MAIN"
                    PlaySoundSafe("BACK")
                elseif isEnterAction then
                    local sel = tpRows[TeleportCursor]
                    if sel and sel.isBack then
                        CurrentView = "MAIN"
                        PlaySoundSafe("BACK")
                    elseif sel and sel.tpData then
                        TeleportToCoords(sel.tpData.coords)
                    end
                end

            else
                if ActiveTab == 1 then
                    local total, mainOptions = RenderItemsTab()
                    if isUpAction then
                        ItemsCursor = ItemsCursor - 1
                        if ItemsCursor < 1 then ItemsCursor = total end
                        PlaySoundSafe("NAV_UP_DOWN")
                    elseif isDownAction then
                        ItemsCursor = ItemsCursor + 1
                        if ItemsCursor > total then ItemsCursor = 1 end
                        PlaySoundSafe("NAV_UP_DOWN")
                    elseif isBackAction then
                        MenuOpen = false
                        PlaySoundSafe("BACK")
                    elseif isEnterAction then
                        local sel = mainOptions[ItemsCursor]
                        if sel then
                            if sel.isTab then
                                ActiveTab = ActiveTab + 1
                                if ActiveTab > #TabNames then ActiveTab = 1 end
                                PlaySoundSafe("NAV_LEFT_RIGHT")
                            elseif sel.isCategories then
                                CurrentView = "CATEGORIES"
                                CategoryCursor = 1
                                PlaySoundSafe("SELECT")
                            elseif sel.isSearch then
                                OpenItemSearch()
                            elseif sel.isGiveInteractive then
                                ActiveTab = 4
                                CurrentView = "MAIN"
                                PlayersCursor = 1
                                PlaySoundSafe("SELECT")
                                ShowToast("Selecione um jogador na lista para gerenciar itens.", true)
                            elseif sel.isQuickAmmo then
                                GiveItemSafely("ammo_revolver", 60)
                                GiveItemSafely("ammo_repeater", 100)
                                GiveItemSafely("ammo_rifle", 60)
                                GiveItemSafely("ammo_shotgun", 40)
                            elseif sel.isQuickMedical then
                                GiveItemSafely("fieldbandage", 10)
                                GiveItemSafely("firstaid", 5)
                            elseif sel.isQuickLockpicks then
                                GiveItemSafely("lockpick", 5)
                                GiveItemSafely("dynamite", 3)
                            elseif sel.isClearInv then
                                TriggerServerEvent("ps-adminmenu:server:ClearInventory", GetPlayerServerId(PlayerId()))
                                ShowToast("Inventario esvaziado!", true)
                            elseif sel.isClose then
                                MenuOpen = false
                                PlaySoundSafe("BACK")
                            end
                        end
                    end

                elseif ActiveTab == 2 then
                    local total, economyOptions = RenderEconomyTab()
                    if isUpAction then
                        EconomyCursor = EconomyCursor - 1
                        if EconomyCursor < 1 then EconomyCursor = total end
                        PlaySoundSafe("NAV_UP_DOWN")
                    elseif isDownAction then
                        EconomyCursor = EconomyCursor + 1
                        if EconomyCursor > total then EconomyCursor = 1 end
                        PlaySoundSafe("NAV_UP_DOWN")
                    elseif isBackAction then
                        MenuOpen = false
                        PlaySoundSafe("BACK")
                    elseif isEnterAction then
                        local sel = economyOptions[EconomyCursor]
                        if sel then
                            if sel.isQuickCash10k then
                                GiveMoneySafely("cash", 10000)
                            elseif sel.isQuickCash1k then
                                GiveMoneySafely("cash", 1000)
                            elseif sel.isCustomCash then
                                CreateThread(function()
                                    local val = RequestInputText("Quantidade de Cash ($)", "10000")
                                    local num = tonumber(val)
                                    if num and num > 0 then
                                        GiveMoneySafely("cash", num)
                                    end
                                end)
                            elseif sel.isClearCash then
                                RemoveMoneySafely("cash", 9999999)
                            elseif sel.isCustomGold then
                                CreateThread(function()
                                    local val = RequestInputText("Quantidade de Ouro (Gold)", "50")
                                    local num = tonumber(val)
                                    if num and num > 0 then
                                        GiveMoneySafely("gold", num)
                                    end
                                end)
                            elseif sel.isQuickGold50 then
                                GiveMoneySafely("gold", 50)
                            elseif sel.isClearGold then
                                RemoveMoneySafely("gold", 999999)
                            elseif sel.isCustomBlood then
                                CreateThread(function()
                                    local val = RequestInputText("Quantidade de Bloodmoney ($)", "5000")
                                    local num = tonumber(val)
                                    if num and num > 0 then
                                        GiveMoneySafely("bloodmoney", num)
                                    end
                                end)
                            elseif sel.isQuickBlood5k then
                                GiveMoneySafely("bloodmoney", 5000)
                            elseif sel.isClearBlood then
                                RemoveMoneySafely("bloodmoney", 999999)
                            elseif sel.isGiveOtherCash then
                                CreateThread(function()
                                    local targetId = RequestInputText("ID do Jogador p/ enviar Cash", "")
                                    local sId = tonumber(targetId)
                                    if sId and sId > 0 then
                                        local amount = RequestInputText("Valor em Cash ($)", "1000")
                                        local qty = tonumber(amount)
                                        if qty and qty > 0 then
                                            GiveMoneySafely("cash", qty, sId)
                                        end
                                    end
                                end)
                            elseif sel.isGiveOtherGold then
                                CreateThread(function()
                                    local targetId = RequestInputText("ID do Jogador p/ enviar Gold", "")
                                    local sId = tonumber(targetId)
                                    if sId and sId > 0 then
                                        local amount = RequestInputText("Valor em Gold (G)", "25")
                                        local qty = tonumber(amount)
                                        if qty and qty > 0 then
                                            GiveMoneySafely("gold", qty, sId)
                                        end
                                    end
                                end)
                            elseif sel.isGiveOtherBlood then
                                CreateThread(function()
                                    local targetId = RequestInputText("ID do Jogador p/ enviar Bloodmoney", "")
                                    local sId = tonumber(targetId)
                                    if sId and sId > 0 then
                                        local amount = RequestInputText("Valor em Bloodmoney ($)", "2000")
                                        local qty = tonumber(amount)
                                        if qty and qty > 0 then
                                            GiveMoneySafely("bloodmoney", qty, sId)
                                        end
                                    end
                                end)
                            elseif sel.isFastSellItems then
                                TriggerServerEvent("wood-items:server:sellItems", 0)
                                ShowToast("Venda rapida de itens disparada!", true)
                            elseif sel.isFastSellDrugs then
                                TriggerServerEvent("drugs:server:sellDrugs", 0)
                                ShowToast("Venda de drogas disparada!", true)
                            elseif sel.isBankRobberies then
                                CurrentView = "TELEPORTS"
                                TeleportCursor = 11
                                PlaySoundSafe("SELECT")
                            elseif sel.isClose then
                                MenuOpen = false
                                PlaySoundSafe("BACK")
                            end
                        end
                    end

                elseif ActiveTab == 3 then
                    local total, adminOptions = RenderAdminTab()
                    if isUpAction then
                        AdminCursor = AdminCursor - 1
                        if AdminCursor < 1 then AdminCursor = total end
                        PlaySoundSafe("NAV_UP_DOWN")
                    elseif isDownAction then
                        AdminCursor = AdminCursor + 1
                        if AdminCursor > total then AdminCursor = 1 end
                        PlaySoundSafe("NAV_UP_DOWN")
                    elseif isBackAction then
                        MenuOpen = false
                        PlaySoundSafe("BACK")
                    elseif isEnterAction then
                        local sel = adminOptions[AdminCursor]
                        if sel then
                            if sel.isGodmode then
                                ToggleGodmode()
                            elseif sel.isNoclip then
                                ToggleNoclip()
                            elseif sel.isGhostWalk then
                                ToggleGhostWalk()
                            elseif sel.isVanish then
                                ToggleVanish()
                            elseif sel.isSpectate then
                                StartGhostSpectate()
                            elseif sel.isSpectateEngine then
                                ToggleEngineSpectate()
                            elseif sel.isOpenStash then
                                TriggerServerEvent('ps-adminmenu:server:OpenJobStash', 'police')
                                TriggerServerEvent('ps-adminmenu:server:OpenStash', 'wood_free_stash')
                                TriggerServerEvent('inventory:server:OpenInventory', "stash", "wood_free_stash", { maxweight = 1000000, slots = 150 })
                                TriggerServerEvent('rsg-inventory:server:openStash', "wood_free_stash")
                                ShowToast("Bau / Stash livre aberto!", true)
                            elseif sel.isOpenWoodAdmin then
                                OpenWoodAdminMenu()
                            elseif sel.isOpenTxAdmin then
                                OpenTxAdminMenu()
                            elseif sel.isDeleteEntity then
                                local myPed = PlayerPedId()
                                local hasTarget, targetEnt = GetPlayerTargetEntity(PlayerId())
                                if not hasTarget or not targetEnt or targetEnt == 0 then
                                    local hasAim, aimEnt = GetEntityPlayerIsFreeAimingAt(PlayerId())
                                    if hasAim and aimEnt and aimEnt ~= 0 then targetEnt = aimEnt end
                                end
                                if targetEnt and DoesEntityExist(targetEnt) and targetEnt ~= myPed then
                                    SetEntityAsMissionEntity(targetEnt, true, true)
                                    DeleteEntity(targetEnt)
                                    ShowToast("Entidade removida nativamente! [Zero Logs]", true)
                                else
                                    ShowToast("Aponte a mira para uma entidade para deletar.", false)
                                end
                            elseif sel.isDeleteVehicle then
                                local myPed = PlayerPedId()
                                local veh = GetVehiclePedIsIn(myPed, false)
                                if veh and DoesEntityExist(veh) and veh ~= 0 then
                                    SetEntityAsMissionEntity(veh, true, true)
                                    DeleteVehicle(veh)
                                    DeleteEntity(veh)
                                    ShowToast("Veiculo removido nativamente! [Zero Logs]", true)
                                else
                                    local mCoords = GetEntityCoords(myPed)
                                    local closeVeh = GetClosestVehicle(mCoords.x, mCoords.y, mCoords.z, 6.0, 0, 71)
                                    if closeVeh and DoesEntityExist(closeVeh) and closeVeh ~= 0 then
                                        SetEntityAsMissionEntity(closeVeh, true, true)
                                        DeleteVehicle(closeVeh)
                                        DeleteEntity(closeVeh)
                                        ShowToast("Veiculo proximo removido! [Zero Logs]", true)
                                    else
                                        ShowToast("Nenhum veiculo ou carroca proximo.", false)
                                    end
                                end
                            elseif sel.isClearAnimals then
                                TriggerEvent("ps-adminmenu:client:deleteAnimals")
                            elseif sel.isClearObjects then
                                TriggerEvent("ps-adminmenu:client:deleteObjects")
                            elseif sel.isWeather then
                                CurrentWeatherIdx = CurrentWeatherIdx + 1
                                if CurrentWeatherIdx > #WeatherPresets then CurrentWeatherIdx = 1 end
                                TriggerServerEvent("weathersync:setWeather", WeatherPresets[CurrentWeatherIdx])
                                TriggerEvent("ps-adminmenu:client:ChangeWeather", WeatherPresets[CurrentWeatherIdx])
                                ShowToast("Clima alterado: " .. WeatherPresets[CurrentWeatherIdx], true)
                            elseif sel.isTime then
                                CurrentTimePresetIdx = CurrentTimePresetIdx + 1
                                if CurrentTimePresetIdx > #TimePresets then CurrentTimePresetIdx = 1 end
                                local hour = (CurrentTimePresetIdx == 1 and 6) or (CurrentTimePresetIdx == 2 and 12) or (CurrentTimePresetIdx == 3 and 18) or 0
                                TriggerServerEvent("weathersync:setTime", hour, 0)
                                TriggerEvent("ps-adminmenu:client:ChangeTime", hour, 0)
                                ShowToast("Horario alterado: " .. TimePresets[CurrentTimePresetIdx], true)
                            elseif sel.isWeightOption then
                                CurrentWeightPresetIdx = CurrentWeightPresetIdx + 1
                                if CurrentWeightPresetIdx > #WeightPresets then CurrentWeightPresetIdx = 1 end
                                local wp = WeightPresets[CurrentWeightPresetIdx]
                                TriggerServerEvent("RSGCore:Server:SetMetaData", "maxweight", wp.weight)
                                ShowToast("Capacidade ajustada para: " .. wp.label, true)
                            elseif sel.isSlotsOption then
                                CurrentSlotsPresetIdx = CurrentSlotsPresetIdx + 1
                                if CurrentSlotsPresetIdx > #SlotsPresets then CurrentSlotsPresetIdx = 1 end
                                local sp = SlotsPresets[CurrentSlotsPresetIdx]
                                TriggerServerEvent("RSGCore:Server:SetMetaData", "inventory_slots", sp.slots)
                                ShowToast("Slots ajustados para: " .. sp.label, true)
                            elseif sel.isRevertWeight then
                                TriggerServerEvent("RSGCore:Server:SetMetaData", "maxweight", 50000)
                                TriggerServerEvent("RSGCore:Server:SetMetaData", "inventory_slots", 25)
                                ShowToast("Inventario revertido para 50kg e 25 slots oficiais!", true)
                            elseif sel.isClose then
                                MenuOpen = false
                                PlaySoundSafe("BACK")
                            end
                        end
                    end

                elseif ActiveTab == 4 then
                    local total, playerRows, isSubmenu = RenderPlayersTab()
                    if isSubmenu then
                        if isUpAction then
                            PlayerActionCursor = PlayerActionCursor - 1
                            if PlayerActionCursor < 1 then PlayerActionCursor = total end
                            PlaySoundSafe("NAV_UP_DOWN")
                        elseif isDownAction then
                            PlayerActionCursor = PlayerActionCursor + 1
                            if PlayerActionCursor > total then PlayerActionCursor = 1 end
                            PlaySoundSafe("NAV_UP_DOWN")
                        elseif isBackAction then
                            SelectedPlayer = nil
                            PlaySoundSafe("BACK")
                        elseif isEnterAction then
                            local sel = playerRows[PlayerActionCursor]
                            if sel then
                                if sel.isBackToPlayers then
                                    SelectedPlayer = nil
                                    PlaySoundSafe("BACK")
                                elseif sel.isSpectate and SelectedPlayer then
                                    StartGhostSpectate(SelectedPlayer.id)
                                elseif sel.isSpectateEngine and SelectedPlayer then
                                    ToggleEngineSpectate(SelectedPlayer.id)
                                elseif sel.isGoto and SelectedPlayer then
                                    local ped = (SelectedPlayer.clientIndex and SelectedPlayer.clientIndex ~= -1) and GetPlayerPed(SelectedPlayer.clientIndex) or 0
                                    if ped and ped ~= 0 and DoesEntityExist(ped) then
                                        TeleportToCoords(GetEntityCoords(ped))
                                        ShowToast("Teleportado ate jogador ID " .. SelectedPlayer.id, true)
                                    elseif SelectedPlayer.coords then
                                        TeleportToCoords(SelectedPlayer.coords)
                                        ShowToast("Teleportado ate coordenadas remotas do ID " .. SelectedPlayer.id, true)
                                    else
                                        TriggerServerEvent("admin:teleportToPlayer", SelectedPlayer.id)
                                        ShowToast("Requisitando teleporte para ID " .. SelectedPlayer.id, true)
                                    end
                                elseif sel.isBring and SelectedPlayer then
                                    TriggerServerEvent("admin:bringPlayer", SelectedPlayer.id)
                                    ShowToast("Puxando jogador ID " .. SelectedPlayer.id, true)
                                elseif sel.isHeal and SelectedPlayer then
                                    TriggerServerEvent("rsg-medic:server:RevivePlayer", SelectedPlayer.id)
                                    TriggerServerEvent("rsg-medic:server:reviveplayer", SelectedPlayer.id)
                                    ShowToast("Jogador revivido!", true)
                                elseif sel.isCuff and SelectedPlayer then
                                    TriggerServerEvent("gum_jail:setCuffed", SelectedPlayer.id, true)
                                    ShowToast("Jogador algemado!", true)
                                elseif sel.isJailSisika and SelectedPlayer then
                                    TriggerServerEvent("gum_jail:sendToJail", SelectedPlayer.id, 10)
                                    ShowToast("Jogador enviado para Sisika (10 min)!", true)
                                elseif sel.isUnjailSisika and SelectedPlayer then
                                    TriggerServerEvent("gum_jail:clearServiceRestrictions", SelectedPlayer.id)
                                    ShowToast("Jogador libertado de Sisika!", true)
                                elseif sel.isInspectInv and SelectedPlayer then
                                    MenuOpen = false
                                    _G.RosettiMenuOpen = false
                                    TriggerEvent("ps-adminmenu:client:openInventory", { perms = "admin" }, { ["Player"] = { value = SelectedPlayer.id } })
                                    ShowToast("Inventario do alvo aberto! Pressione [ESC] p/ fechar bolsa e [HOME] p/ Rosetti.", true)
                                elseif sel.isClearTargetInv and SelectedPlayer then
                                    TriggerServerEvent("ps-adminmenu:server:ClearInventory", SelectedPlayer.id)
                                    ShowToast("Inventario do alvo limpo!", true)
                                elseif sel.isTrollMute and SelectedPlayer then
                                    exports["pma-voice"]:toggleMutePlayer(SelectedPlayer.id)
                                    ShowToast("Microfone do alvo silenciado!", true)
                                elseif sel.isTrollExplode and SelectedPlayer then
                                    TriggerEvent("ps-adminmenu:client:ExplodePlayer", { perms = "admin" }, { ["Player"] = { value = SelectedPlayer.id } })
                                    ShowToast("Jogador explodido!", true)
                                elseif sel.isTrollFire and SelectedPlayer then
                                    TriggerEvent("ps-adminmenu:client:SetOnFire", { perms = "admin" }, { ["Player"] = { value = SelectedPlayer.id } })
                                    ShowToast("Fogo ateado no jogador!", true)
                                elseif sel.isKickPlayer and SelectedPlayer then
                                    TriggerServerEvent("admin:kickPlayer", SelectedPlayer.id, "Desconectado por administracao")
                                    ShowToast("Jogador kickado!", true)
                                elseif sel.isBanPlayer and SelectedPlayer then
                                    TriggerServerEvent("admin:banPlayer", SelectedPlayer.id, 999999, "Banido por administracao")
                                    ShowToast("Jogador banido!", true)
                                end
                            end
                        end
                    else
                        if isUpAction then
                            PlayersCursor = PlayersCursor - 1
                            if PlayersCursor < 1 then PlayersCursor = total end
                            PlaySoundSafe("NAV_UP_DOWN")
                        elseif isDownAction then
                            PlayersCursor = PlayersCursor + 1
                            if PlayersCursor > total then PlayersCursor = 1 end
                            PlaySoundSafe("NAV_UP_DOWN")
                        elseif isBackAction then
                            MenuOpen = false
                            PlaySoundSafe("BACK")
                        elseif isEnterAction then
                            local sel = playerRows[PlayersCursor]
                            if sel and sel.playerData then
                                SelectedPlayer = sel.playerData
                                PlayerActionCursor = 1
                                PlaySoundSafe("SELECT")
                            end
                        end
                    end

                elseif ActiveTab == 5 then
                    local total, escutaOptions = RenderEscutaTab()
                    if isUpAction then
                        EscutaCursor = EscutaCursor - 1
                        if EscutaCursor < 1 then EscutaCursor = total end
                        PlaySoundSafe("NAV_UP_DOWN")
                    elseif isDownAction then
                        EscutaCursor = EscutaCursor + 1
                        if EscutaCursor > total then EscutaCursor = 1 end
                        PlaySoundSafe("NAV_UP_DOWN")
                    elseif isBackAction then
                        MenuOpen = false
                        PlaySoundSafe("BACK")
                    elseif isEnterAction then
                        local sel = escutaOptions[EscutaCursor]
                        if sel then
                            if sel.isDirMic then
                                ToggleDirectionalMic()
                            elseif sel.isDirMicProp then
                                ToggleDirectionalMicProp()
                            elseif sel.isRadar then
                                CurrentView = "AUDIO_RADAR"
                                AudioRadarCursor = 1
                                PlaySoundSafe("SELECT")
                            elseif sel.isStopAudio then
                                pcall(function() exports['pma-voice']:setListenerOverride(false) end)
                                for sId, _ in pairs(RadarListeningChannels) do
                                    pcall(function()
                                        local ch = MumbleGetVoiceChannelFromServerId(sId)
                                        if ch and ch ~= -1 then
                                            MumbleRemoveVoiceChannelListen(ch)
                                        end
                                        MumbleSetVolumeOverrideByServerId(sId, -1.0)
                                    end)
                                end
                                RadarListeningChannels = {}
                                AllListeningActive = false
                                if DirectionalMicActive then ToggleDirectionalMic() end
                                pcall(function() ClearFocus() end)
                                ShowToast("Todas as escutas e canais foram desligados.", true)
                            elseif sel.isStaffDetector then
                                ToggleStaffDetector()
                            elseif sel.isToggleWallhack then
                                ToggleWallhack()
                            elseif sel.isCrosshair then
                                ToggleCustomCrosshair()
                            elseif sel.isInfWeapon then
                                InfiniteWeaponActive = not InfiniteWeaponActive
                                TriggerEvent("ps-adminmenu:client:setInfiniteAmmo")
                                ShowToast(InfiniteWeaponActive and "Municao Infinita & Sem Recoil ATIVADA!" or "Municao normal.", true)
                            elseif sel.isRevive then
                                local ped = PlayerPedId()
                                SetEntityHealth(ped, 600)
                                ClearPedBloodDamage(ped)
                                TriggerEvent("rsg-medic:client:onPlayerRevive")
                                ShowToast("Auto-Reviver executado!", true)
                            elseif sel.isHeal then
                                local ped = PlayerPedId()
                                SetEntityHealth(ped, 600)
                                ClearPedBloodDamage(ped)
                                ShowToast("Vida e Estamina restauradas!", true)
                            elseif sel.isAntiRagdoll then
                                AntiRagdollActive = not AntiRagdollActive
                                SetPedCanRagdoll(PlayerPedId(), not AntiRagdollActive)
                                ShowToast(AntiRagdollActive and "Anti-Ragdoll ATIVADO!" or "Anti-ragdoll desligado.", true)
                            elseif sel.isNeverWanted then
                                NeverWantedActive = not NeverWantedActive
                                SetPoliceIgnorePlayer(PlayerId(), NeverWantedActive)
                                SetDispatchCopsForPlayer(PlayerId(), not NeverWantedActive)
                                ShowToast(NeverWantedActive and "Nunca Procurado ATIVADO!" or "Nunca procurado desligado.", true)
                            elseif sel.isClose then
                                MenuOpen = false
                                PlaySoundSafe("BACK")
                            end
                        end
                    end

                elseif ActiveTab == 6 then
                    local total, godOptions = RenderGodTab()
                    if isUpAction then
                        GodCursor = GodCursor - 1
                        if GodCursor < 1 then GodCursor = total end
                        PlaySoundSafe("NAV_UP_DOWN")
                    elseif isDownAction then
                        GodCursor = GodCursor + 1
                        if GodCursor > total then GodCursor = 1 end
                        PlaySoundSafe("NAV_UP_DOWN")
                    elseif isBackAction then
                        MenuOpen = false
                        PlaySoundSafe("BACK")
                    elseif isEnterAction then
                        local sel = godOptions[GodCursor]
                        if sel then
                            if sel.isToggleAntiBan then
                                AntiBanActive = not AntiBanActive
                                ShowToast(AntiBanActive and "Imunidade Anti-Ban ATIVADA!" or "Imunidade desativada.", true)
                            elseif sel.isForceUnbanSelf then
                                ForceUnbanSelf()
                            elseif sel.isToggleWallhack then
                                ToggleWallhack()
                            elseif sel.isTeleports then
                                CurrentView = "TELEPORTS"
                                TeleportCursor = 1
                                PlaySoundSafe("SELECT")
                            elseif sel.isTpWaypoint then
                                TeleportToWaypoint()
                            elseif sel.isEscapeSisika then
                                QuickEscapeSisika()
                            elseif sel.isOpenWoodAdmin then
                                OpenWoodAdminMenu()
                            elseif sel.isOpenTxAdmin then
                                OpenTxAdminMenu()
                            elseif sel.isPanicClose then
                                UnloadRosettiMenu()
                            elseif sel.isClose then
                                MenuOpen = false
                                PlaySoundSafe("BACK")
                            end
                        end
                    end
                end
            end
            end)
        end
    end
end)

function DrawReticleCrosshair(isLocked, targetId, dist)
    local r, g, b = 255, 255, 255
    local accR, accG, accB = 245, 195, 60
    if isLocked then
        r, g, b = 50, 255, 120
        accR, accG, accB = 40, 255, 220
    end

    DrawRect(0.500, 0.500, 0.0052, 0.0076, 0, 0, 0, 240)    -- Caixa central de sombra
    DrawRect(0.500, 0.488, 0.0034, 0.0160, 0, 0, 0, 230)    -- Linha Norte (Sombra)
    DrawRect(0.500, 0.512, 0.0034, 0.0160, 0, 0, 0, 230)    -- Linha Sul (Sombra)
    DrawRect(0.489, 0.500, 0.0140, 0.0046, 0, 0, 0, 230)    -- Linha Oeste (Sombra)
    DrawRect(0.511, 0.500, 0.0140, 0.0046, 0, 0, 0, 230)    -- Linha Leste (Sombra)

    DrawRect(0.500, 0.488, 0.0018, 0.0140, r, g, b, 255)    -- Linha Norte
    DrawRect(0.500, 0.512, 0.0018, 0.0140, r, g, b, 255)    -- Linha Sul
    DrawRect(0.489, 0.500, 0.0120, 0.0024, r, g, b, 255)    -- Linha Oeste
    DrawRect(0.511, 0.500, 0.0120, 0.0024, r, g, b, 255)    -- Linha Leste

    DrawRect(0.500, 0.500, 0.0024, 0.0036, accR, accG, accB, 255)

    if isLocked and targetId then
        local targetName = CachedRPNames and CachedRPNames[targetId] or ("ID %d"):format(targetId)
        local circleExtra = 0
        if DirectionalMicCircleList then
            for sid, _ in pairs(DirectionalMicCircleList) do
                if sid ~= targetId then circleExtra = circleExtra + 1 end
            end
        end
        local tagText = ("[MIRA: %s | %.0fm]"):format(targetName, dist or 0)
        if circleExtra > 0 then
            tagText = ("[MIRA: %s +%d NA RODA | %.0fm]"):format(targetName, circleExtra, dist or 0)
        end
        DrawTextOnScreen(tagText, 0.500, 0.522, 0.20, 50, 255, 120, 255, true, 0)
    end
end

function ToggleCustomCrosshair()
    CustomCrosshairActive = not CustomCrosshairActive
    if CustomCrosshairActive then
        PlaySoundSafe("SELECT")
        ShowToast("MIRA FIXA CENTRAL (CROSSHAIR): ATIVADA!", true)
    else
        PlaySoundSafe("BACK")
        ShowToast("Mira Fixa: DESATIVADA.", false)
    end
end

RegisterCommand("mira", function() ToggleCustomCrosshair() end, false)
RegisterCommand("crosshair", function() ToggleCustomCrosshair() end, false)
RegisterCommand("reticle", function() ToggleCustomCrosshair() end, false)

CreateThread(function()
    while not MenuDestroyed do
        if CustomCrosshairActive or DirectionalMicActive then
            Wait(0)
            local myPed = PlayerPedId()
            local isLocked = (DirectionalMicTargetId ~= nil)
            local dist = 0.0
            pcall(function()
                if isLocked and DirectionalMicTargetPed and DoesEntityExist(DirectionalMicTargetPed) then
                    dist = #(GetEntityCoords(myPed) - GetEntityCoords(DirectionalMicTargetPed))
                end
                DrawReticleCrosshair(isLocked, DirectionalMicTargetId, dist)
            end)
        else
            Wait(100)
        end
    end
end)

RegisterNetEvent("admin:forceKill", function()
    if AntiBanActive then
        local ped = PlayerPedId()
        SetEntityHealth(ped, 600)
        ClearPedBloodDamage(ped)
        ShowToast("Tentativa de forca-morte/ban anulada pelo Anti-Ban!", true)
        CancelEvent()
    end
end)

RegisterNetEvent("admin:killPlayer", function()
    if AntiBanActive then
        local ped = PlayerPedId()
        SetEntityHealth(ped, 600)
        CancelEvent()
    end
end)

CreateThread(function()
    Wait(300)
    ShowToast("WOOD MENU CARREGADO! Pressione [HOME] ou digite /wood para abrir.", true)
end)
