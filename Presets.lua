-------------
-- GLOBALS --
-------------
assert(DynamicCam);


------------
-- LOCALS --
------------
local presets = {
    ["Vanillalike"] = {
        author = "mpstark",
        description = "Almost no ActionCam, mostly just nicities for zoom.",
        importString = "dCt2maGEvzxiuABiumteqnBPCte1TvANkAVu7wu)ui0Wu43KUmyOcvnoeqA4ivhuiDyuhtQY5ecYcrKLkeulwfwUepeHQNsSmK45QQjkuzQsAYQOPdDreqCvPIupdj56iOnIu2kczZcrSDKuFwLoTGPje13LkIrkvu)vQQrlvA8cLtke4wcr6AiqNxQWRrawRurYJfz3Zvl0lAKeAGRwkaNWa1qNs11vlqMpAWPjz0YjejmHnKiO8dA2ZEw(bKqgdA(7QLbvu5QfiZhn40hws8cfoAcdA(7QLNQlTaw17TbtEb6ngbtYYt1LmhZtkdJgTmOqLRwGmF0GtFyjXlu4OjmO5VRwEQU0cyvV3gm5fO3yemjlpvxYCmpPmmA0YyqmUAbY8rdo9HLeVqHJMWGM)UA5P6kaIH81YhqJgTq1GIRws8cfM4eXLVRwq4J9t8cfoUoY8gsXhWuxs8hOPuhpF65Gyh9SGWh7N4fkCCDK5nKIpGPUE2ZccFSFIxOWrKAOiDvcBNqXZiThXsqli8X(jEHchxhzEdP4dyQlj(d0uQJNpJt7KSK4g45GyPIGgTK4fkC0eg083vlpvxbqmKVw(aA5P6slGv9EBWKxGEJrWKS8uDjZX8KYWshCNehCla89ms7nSuuKrqaed5RLt4wa4B5P6se3ie8KGwkkYiqIteGjz0OLbXmC1cK5JgC6dljEHchnHbn)D1Yt1LwaR692GjVa9gJGjz5P6sMJ5jLHrJwgdkUAjXlu4OjmO5VRwEQU0cyvV3gm5fO3yemjlpvxbqmKVwczlpvxI4gHGNeOwEQUK5yEszy0OLEJHRws8cfM4eXLVRwq4J9t8cfoUoY8gsXhWuxphwq4J9t8cfUZaFswPgwiJcwG8f765WccFSFIxOWrKAOiDvcBNqXZHrljEHchnHbn)D1Yt1LwaR692GjVa9gJGjz5P6kaIH81IsiA5P6se3ie8KkcA5P6sMJ5jLHrJwOmgUAjXluyItex(UAbHp2pXlu446iZBifFatD9CybHp2pXlu4od8jzLAyHmkybYxSRNdli8X(jEHchrQHI0vjSDcfphgTK4fkC0eg083vlpvxYCmpPmS8uDfaXq(AjKTGfo)dyqZ1WcE2ByPOiJGjz5P6se3ie8mYw6G7K4GBbGVNurmdlffzeeaXq(A5eUfa(wWWcrWNmhZhwEQU0cyvV3gm5fO3yemjJwGyyH)UAPB4e60rGjz0OLEdkUAjXluyItex(UAbHp2pXlu4isnuKUkHTtO45WccFSFIxOWDg4tYk1WczuWcKVyxphwq4J9t8cfoUoY8gsXhWuxphgTK4fkC0eg083vlpvxAbSQ3BdM8c0BmcMKLNQlzoMNuggnAzqWHRwGmF0GtFyjXlu4OjmO5VRwEQU0cyvV3gm5fO3yemjlpvxYCmpPmmA0YGQEUAbY8rdo9HLeVqHJMWGM)UA5P6slGv9EBWKxGEJrWKS8uDjZX8KYWOrlun65QfiZhn40hws8cfoAcdA(7QLNQlTaw17TbtEb6ngbtYYt1vaed5RLq2Yt1LiUri4zKT8uDjZX8KYWOrlJbbD1sIxOWrtyqZFxT8uDfaXq(AjKT8uDPfWQEVnyYlqVXiyswEQUK5yEszy0OLEJEUAjXluyItex(UAbHp2pXlu4od8jzLAyHmkybYxSRNdli8X(jEHchrQHI0vjSDcfphgTK4fkC0eg083vlpvxAbSQ3BdM8c0BmcMKLNQRaigYxlFaT8uDjIBecEsveYYt1LmhZtkdJgTqz0ZvljEHctCI4Y3vli8X(jEHchxhzEdP4dyQRNdli8X(jEHc3zGpjRudlKrblq(ID9CybHp2pXlu4isnuKUkHTtO45WOLeVqHJMWGM)UA5P6slGv9EBWKxGEJrWKS8uDjZX8KYWOrldIPNRwGmF0GtFyjXlu4OjmO5VRwEQU0cyvV3gm5fO3yemjlpvxYCmpPmmA0Yy0ZvljEHchnHbn)D1Yt1vaed5RLcNVGLNQl5q2ZEdlpvxAbSQ3BdM8c0BmcMKLNQlzoMNuggnAzqjYUAbY8rdo9HLeVqHJMWGM)UA5P6slGv9EBWKxGEJrWKS8uDjZX8KYWOrldc2ZvlqMpAWPpSK4fkC0eg083vlpvxAbSQ3BdM8c0BmcMKLNQlzoMNuggnAzmISRws8cfoAcdA(7QLNQRaigYxlfoFblpvxYHSN9iOLNQlTaw17TbtEb6ngbtYYt1LmhZtkdJgTq1y4QLeVqHjorC57Qfe(y)eVqHJRJmVHu8bm11ZEgTGC5cibwteGRwGmF0GttYIMBDefrora8rd8HLmVa9gJarHF4Ob(WOLeVqHJMWGM)UA5P6slGrqovGfY43ZbXsqlpvxbqmKVwIKaA5P6sMJ5jvdlpvxAbmE9hWGM9mcnS8uDjhYEsLLNQlrCJqWZiB5P6slGv9EBWKxGEJrWKmAbY8rdo9HrldkdxTaz(ObN(WsIxOWrtyqZFxT8uDPfWQEVnyYlqVXiyswEQUK5yEszy0OLbvdxTaz(ObN(WsIxOWrtyqZFxT8uDPfWQEVnyYlqVXiyswEQUK5yEszy0OLbvr2vlqMpAWPpSK4fkC0eg083vlpvxAbSQ3BdM8c0BmcMKLNQlzoMNuggnAzqPNRwGmF0GtFyjXlu4OjmO5VRwEQU0cyvV3gm5fO3yemjlpvxYCmpPmmA0Of(KAoNGttYOfSd6GL4iE)4JWrKweqGjqSK5fSqeNdTghPTabawycXUAXYs)JCHamAda",
    },
}


function DynamicCam:LoadPreset(defaultName)
    -- if there is a preset with this name, then load it into the current profile
    if (presets[defaultName]) then
        self:ImportIntoCurrentProfile(presets[defaultName].importString);
    end
end

function DynamicCam:GetPresets()
    local presetList = {};

    -- load a table full of the name (the key) and what we want the entry to read
    for name, tbl in pairs(presets) do
        local entry = string.format("%s (%s)", name, tbl.author);
        presetList[name] = entry;
    end

    return presetList;
end

function DynamicCam:GetPresetDescriptions()
    local descriptions = "";
    local sep = "";

    -- load a table full of the name (the key) and what we want the entry to read
    for name, tbl in pairs(presets) do
        local entry = string.format("%s|cFFFFFF00%s (%s):|r\n    %s", sep, name, tbl.author, tbl.description);
        descriptions = descriptions..entry;

        sep = "\n\n";
    end

    return descriptions;
end
