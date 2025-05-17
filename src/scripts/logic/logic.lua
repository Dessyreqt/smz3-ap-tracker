function GtCrystalCount()
    local reqCount = Tracker:ProviderCountForCode("open_tower")
    local count = Tracker:ProviderCountForCode("allcrystals")

    if count >= reqCount then
        return 1
    else
        return 0
    end
end
