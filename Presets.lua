-------------
-- GLOBALS --
-------------
assert(DynamicCam)


------------
-- LOCALS --
------------
local presets = {
    
    ["Ludius with views"] = {
        author = "LudiusMaximus",
        description = "My personal favourite:\n-Zoom in/out when indoor/outdoor.\n-Slight shoulder offset, but not while in dungeons/raids.\n-Go to view 2 during NPC/Mailbox interaction.\n-Go to view 3 and start rotating when teleporting.\n\nNOTICE: You have to setup the views yourself! E.g. while interacting with an NPC, put the camera into a position you like, then type '/sv 2' into the console to store it. Similarly, find a good camera view facing your character from the right and type '/sv 3' to store it as the teleport start view.",
        importString = "dK0zlaGiczukcoLiQMLiYUqedJGJPKwMsPNPiAAekDniLTrOW3qKQXbbW5GaADqQuVdcQ7rOOdsbTqi0dvuMiIYfvkAJukFKqLrkIItsPALqQAMkcDtLc7eQ(jfAOiQokeGwkHQEQWuvLRIizRkrFfsLCwivSweP8wiqDxiq2R0FHKbdLdtAXu0JvyYiCzWMPaFwegTs1PPYRHGmBk52u1Ur63IA4kswUkpNOPJ66I02HOVROA8kHoVIuRxj49IOK7lIsTFv1DTVgtDzdCwqFniad0ulEgs9K91GbjJAOE4uYMMQE3GChp2ruLGTmsYvIIlqcP3GbjJAOE4uYMMQE3GChp2l(AdgKmQH6HtjBAQ6DdYD8yhrvc2YijxjilpNgd1ck(AdgKmQH6HtjBAQ6DdYD8yp86XK7qM5zPC2adiZj5Il0GbjJAOE4uYMMQE3GChp2ruLGTmsYvcBwt7OjkUajiq0AmupCkPLZ(ykaikoAcLBGeoPltl(2gshNQSltL91qyYj7RbqvtlGOMLBiSDY(Aau10ciQz5gccIrFnaQAAbe1SCJjf22xdGQMwarnl3yvyTVgavnTaIAwUHGW2(AmupCQHd2LPY(ASqo7dGzhnrdhTb78GD5g6I1SbFkv6yxM(CEO4RKGwJfYz)s1kfkoALBmupC6SL6j7Rbdsg1q9WPgrcxSNtTiGR4RKSTC5gcIHqFngQhoD2s9K91GbjJAOE4uJiHl2ZPweWvCHYLBSki0xdGQMwarnl3yvyBFnaQAAbe1SCdb0e6RXq9WPZwQNSVgmizud1dNAejCXEo1IaUIluUCJTcc91aPdM3xdGQMwarrSbshmhp1BcxXNSXbsoFWshmViwUXq9WPgoyxMk7RXc5SpaMD0enKa3GpLkDSltFopu81gxMvgcGzhnrdciXbGSXc5SFPALcfxSnMwNtgK4aqw8TKUqJlZkdfXgSZd2LBOlwZgt54XozqIdazXxrRCJH6HtNTupzFnyqYOgQho1is4I9CQfbCfxOC5gtkS2xdKoyEFnaQAAbefXgiDWC8uVjCfFBJdKC(GLoyErSCJH6HtNTupzFnyqYOgQho9PxcGTLhPs7ugoDWBsvtlO4RnyqYOgQho1is4I9CQfbCfFTbdsg1q9WPp9saST8ivANYWPdo4dOj4DYD8yV4cnyqYOgQho9PxcGTLhPs7ugoDWbFanbVJo68IVwUCdbb06RXq9WPgoyxMk7RXc5SpaMD0enC0gSZd2LBOlwZg8PuPJDz6Z5HIVscAnwiN9lvRuO4OvUXq9WPZwQNSVgmizud1dNAejCXEo1IaUIVsY2YLBim5AFnaQAAbe1SCdHTR91aOQPfquZYneeJ1(Aau10ciQz5gccR91yOE4udhSltL91yHC2haZoAIg5uUb78GD5g6I1SbFkv6yxM(CEO4RKGwJfYz)s1kfk(Qyl3yOE40zl1t2xdgKmQH6HtnIeUypNAraxXxjbTYLBiSvS91aOQPfquZYneqBTVgavnTaIAwUHGGy7RXq9WPgoyxMk7RXc5SpaMD0enYPCd25b7Yn0fRzd(uQ0XUm958qXxjbTglKZ(LQvku8vXwUXq9WPZwQNSVgmizud1dNAejCXEo1IaUIVscALl3ysbH(AG0bZ7RbqvtlGOi2aPdMJN6nHR4BBCGKZhS0bZlILBmupC6SL6j7Rbdsg1q9WPp9saST8ivANYWPdEtQAAbfFTbdsg1q9WPgrcxSNtTiGR4RnyqYOgQho9PxcGTLhPs7ugoDWbFanbVtUJh7fxObdsg1q9WPp9saST8ivANYWPdo4dOj4D0rNx81YngzkHJDzAdR8qT(yY98C6htm)ygOwsaH)O3G89XqOKq(XC0p2uQ7KtG3Dssm4upit(hJi)r)h7J9X(yod(ytaL4qWirqFmLs8Xqjoemsee62Um2ZZPti5j)JX7a9J(p2h7J9X(yFSp2htUNNt)yI5hJVuaH)O)J9X(yFSp2h7J9Xmpqrie(J(p2h7J9XakXh9aL4J(d40J(Xif1XBUOtYYjiIo1quY)ykL4JrkQJTljf1XtqeDQHOK(yIy9saSOK)XukXhtUNNtr4gWIWiLbJu7uh3G3Dssm4upi)yI5hlzjsC6DozMotNsho2HeiZjNYsN22PEqusFmriQueY2PEqusFmrBa3yxPSTt9GOK(yIexwkDtz7upikPpMOzwQu(o1rHZ2PEqusFmriGPGKTDQheL0htKDVhoPltTDQheL0htKHPd2LP2o1dIs6JjcDPhXLnbBN6brj9XeHOMGMPiQueY2PEyvuYUbGeOSSVIVIa0Wqsn7z3ioQKXiPInrnBIgJnjR4RiWgpXBiESHrXjE72qhugjFt8IVs6nmKuZE2nIJkzmsQyturYyeDv8TcnEI3q8ydJIt82THoOMnrJXMLl3qyRqFngQhoD2s9K91GbjJAOE4uJiHl2ZPweWvCHYnaQAAbe1SCdHjf6RXq9WPZwQNSVgmizud1dNAejCXEo1IaUIluUCJTcR91aOQPfquZYneMuS91aOQPfquZYLByG7KS4tP1SXb6GDibslN991aOQPfqueBOee2PJd8aLLfFLe0A41fjTC2)CEO4cKS2qjiSthh4bkln0AUoTS4cnC0HHeeK5mWa4a6ak(2YnucKkDaefXYn4PNcAq2muKlEJ2SpXnBqvp0yIPeUu5hBUJ3)yiDWCzdnL3ZxJjMs4sLBOl68PYYTa",
    },
    ["Vanillalike"] = {
        author = "mpstark",
        description = "Almost no ActionCam, mostly just nicities for zoom.",
        importString = "dCt2maGEvzxiuABiumteqnBPCte1TvANkAVu7wu)ui0Wu43KUmyOcvnoeqA4ivhuiDyuhtQY5ecYcrKLkeulwfwUepeHQNsSmK45QQjkuzQsAYQOPdDreqCvPIupdj56iOnIu2kczZcrSDKuFwLoTGPje13LkIrkvu)vQQrlvA8cLtke4wcr6AiqNxQWRrawRurYJfz3Zvl0lAKeAGRwkaNWa1qNs11vlqMpAWPjz0YjejmHnKiO8dA2ZEw(bKqgdA(7QLbvu5QfiZhn40hws8cfoAcdA(7QLNQlTaw17TbtEb6ngbtYYt1LmhZtkdJgTmOqLRwGmF0GtFyjXlu4OjmO5VRwEQU0cyvV3gm5fO3yemjlpvxYCmpPmmA0YyqmUAbY8rdo9HLeVqHJMWGM)UA5P6kaIH81YhqJgTq1GIRws8cfM4eXLVRwq4J9t8cfoUoY8gsXhWuxs8hOPuhpF65Gyh9SGWh7N4fkCCDK5nKIpGPUE2ZccFSFIxOWrKAOiDvcBNqXZiThXsqli8X(jEHchxhzEdP4dyQlj(d0uQJNpJt7KSK4g45GyPIGgTK4fkC0eg083vlpvxbqmKVw(aA5P6slGv9EBWKxGEJrWKS8uDjZX8KYWshCNehCla89ms7nSuuKrqaed5RLt4wa4B5P6se3ie8KGwkkYiqIteGjz0OLbXmC1cK5JgC6dljEHchnHbn)D1Yt1LwaR692GjVa9gJGjz5P6sMJ5jLHrJwgdkUAjXlu4OjmO5VRwEQU0cyvV3gm5fO3yemjlpvxbqmKVwczlpvxI4gHGNeOwEQUK5yEszy0OLEJHRws8cfM4eXLVRwq4J9t8cfoUoY8gsXhWuxphwq4J9t8cfUZaFswPgwiJcwG8f765WccFSFIxOWrKAOiDvcBNqXZHrljEHchnHbn)D1Yt1LwaR692GjVa9gJGjz5P6kaIH81IsiA5P6se3ie8KkcA5P6sMJ5jLHrJwOmgUAjXluyItex(UAbHp2pXlu446iZBifFatD9CybHp2pXlu4od8jzLAyHmkybYxSRNdli8X(jEHchrQHI0vjSDcfphgTK4fkC0eg083vlpvxYCmpPmS8uDfaXq(AjKTGfo)dyqZ1WcE2ByPOiJGjz5P6se3ie8mYw6G7K4GBbGVNurmdlffzeeaXq(A5eUfa(wWWcrWNmhZhwEQU0cyvV3gm5fO3yemjJwGyyH)UAPB4e60rGjz0OLEdkUAjXluyItex(UAbHp2pXlu4isnuKUkHTtO45WccFSFIxOWDg4tYk1WczuWcKVyxphwq4J9t8cfoUoY8gsXhWuxphgTK4fkC0eg083vlpvxAbSQ3BdM8c0BmcMKLNQlzoMNuggnAzqWHRwGmF0GtFyjXlu4OjmO5VRwEQU0cyvV3gm5fO3yemjlpvxYCmpPmmA0YGQEUAbY8rdo9HLeVqHJMWGM)UA5P6slGv9EBWKxGEJrWKS8uDjZX8KYWOrlun65QfiZhn40hws8cfoAcdA(7QLNQlTaw17TbtEb6ngbtYYt1vaed5RLq2Yt1LiUri4zKT8uDjZX8KYWOrlJbbD1sIxOWrtyqZFxT8uDfaXq(AjKT8uDPfWQEVnyYlqVXiyswEQUK5yEszy0OLEJEUAjXluyItex(UAbHp2pXlu4od8jzLAyHmkybYxSRNdli8X(jEHchrQHI0vjSDcfphgTK4fkC0eg083vlpvxAbSQ3BdM8c0BmcMKLNQRaigYxlFaT8uDjIBecEsveYYt1LmhZtkdJgTqz0ZvljEHctCI4Y3vli8X(jEHchxhzEdP4dyQRNdli8X(jEHc3zGpjRudlKrblq(ID9CybHp2pXlu4isnuKUkHTtO45WOLeVqHJMWGM)UA5P6slGv9EBWKxGEJrWKS8uDjZX8KYWOrldIPNRwGmF0GtFyjXlu4OjmO5VRwEQU0cyvV3gm5fO3yemjlpvxYCmpPmmA0Yy0ZvljEHchnHbn)D1Yt1vaed5RLcNVGLNQl5q2ZEdlpvxAbSQ3BdM8c0BmcMKLNQlzoMNuggnAzqjYUAbY8rdo9HLeVqHJMWGM)UA5P6slGv9EBWKxGEJrWKS8uDjZX8KYWOrldc2ZvlqMpAWPpSK4fkC0eg083vlpvxAbSQ3BdM8c0BmcMKLNQlzoMNuggnAzmISRws8cfoAcdA(7QLNQRaigYxlfoFblpvxYHSN9iOLNQlTaw17TbtEb6ngbtYYt1LmhZtkdJgTq1y4QLeVqHjorC57Qfe(y)eVqHJRJmVHu8bm11ZEgTGC5cibwteGRwGmF0GttYIMBDefrora8rd8HLmVa9gJarHF4Ob(WOLeVqHJMWGM)UA5P6slGrqovGfY43ZbXsqlpvxbqmKVwIKaA5P6sMJ5jvdlpvxAbmE9hWGM9mcnS8uDjhYEsLLNQlrCJqWZiB5P6slGv9EBWKxGEJrWKmAbY8rdo9HrldkdxTaz(ObN(WsIxOWrtyqZFxT8uDPfWQEVnyYlqVXiyswEQUK5yEszy0OLbvdxTaz(ObN(WsIxOWrtyqZFxT8uDPfWQEVnyYlqVXiyswEQUK5yEszy0OLbvr2vlqMpAWPpSK4fkC0eg083vlpvxAbSQ3BdM8c0BmcMKLNQlzoMNuggnAzqPNRwGmF0GtFyjXlu4OjmO5VRwEQU0cyvV3gm5fO3yemjlpvxYCmpPmmA0Of(KAoNGttYOfSd6GL4iE)4JWrKweqGjqSK5fSqeNdTghPTabawycXUAXYs)JCHamAda",
    },
}


function DynamicCam:LoadPreset(defaultName)
    -- if there is a preset with this name, then load it into the current profile
    if presets[defaultName] then
        self:ImportIntoCurrentProfile(presets[defaultName].importString)
    end
end

function DynamicCam:GetPresets()
    local presetList = {}

    -- load a table full of the name (the key) and what we want the entry to read
    for name, tbl in pairs(presets) do
        local entry = string.format("%s (%s)", name, tbl.author)
        presetList[name] = entry
    end

    return presetList
end

function DynamicCam:GetPresetDescriptions()
    local descriptions = ""
    local sep = ""

    -- load a table full of the name (the key) and what we want the entry to read
    for name, tbl in pairs(presets) do
        local entry = string.format("%s|cFFFFFF00%s (%s):|r\n    %s", sep, name, tbl.author, tbl.description)
        descriptions = descriptions..entry

        sep = "\n\n"
    end

    return descriptions
end
