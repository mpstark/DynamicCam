-------------
-- GLOBALS --
-------------
assert(DynamicCam)


------------
-- LOCALS --
------------
local presets = {

    ["Immersive"] = {
        author = "LudiusMaximus",
        description = "Some settings to make gameplay more immersive:\n-Zoom in/out when indoor/outdoor.\n-Slight shoulder offset, but not while in dungeons/raids.\n-Go to view 2 during NPC/Mailbox interaction.\n-Go to view 3 and start rotating when teleporting.\n\nNOTICE: You have to setup the views yourself! E.g. while interacting with an NPC, put the camera into a position you like, then type '/sv 2' into the console to store it. Similarly, find a good camera view facing your character from the right and type '/sv 3' to store it as the teleport start view.",
        importString = "dqd6iaGEus7sj12qvIzIQuMnQCtLe3MKDcYEP2Tq)ei(lq9BrgkanCjroOIkhtIoNKOAHayPsIYIrXYL6HkkpL4XcEoPMiqAQkmzqnDOlQOQomYLvDDjSruITIQAZkcBxj(mk13qvsttjPVRinmL60IA0aA8kIoPKYzrvQUMKQZljSmjP1QOkpdvXU0dlvQttK5UhwG)eubhoBHAThwWRrWbs9MaTIiPYbaZyaiaK(SKwaKGn0EnVAbVgbhi1Bc0kIKkhamJbGgQ0cEncoqQ3eOvejvoaygdabG0NL0cGemOPPrjqC3qLwWRrWbs9MaTIiPYbaZyaOOOgbmVKWzfyAIjanRrdTTGxJGdK6nbAfrsLdaMXaqai9zjTaibZcxf5iBdTxx51Tei1BAEPKsQ0pSHQVnAz5ToNIgQQL(uaZlFEPKYdlpsmCh2ayHGHRfd9vpIAdvUUUffn58sj1iRUH2RlTqWW1IH(Qhr9CCtPk0gABjhdZbddAEIjE)y4gQQrltKBnwzfrZyrNXccZPO2dlBE4XdlpsmCh2mgTSRYJhwEKy4oSzmAzV5fpS8iXWDyZy0cp7QEy5rIH7WMXOL9UQhwcK6nnJp1ApSGxJGdK6nbYYBbyQGd(THkxx1OLaPEtZfWCkQ9WcRPKIpXvCdv3cMvVMEfAsZybBkQZyofhz1nu566wynLuYrmhzBjhnA0YMNspS8iXWDyZy0s1DPhwEKy4oSzmAPCV9WYJed3HnJrl76BpSei1BAgFQ1EybVgbhi1BcKL3cWubh8BdTnA0s192dll5p1dlpsmCh2ayzj)PqfkM3gIhl91yQp)8NAamAjqQ30CbmNIApSWAkP4tCf3qRAbZQxtVcnPzS0jKWlhXCKTf4ZU)1wynLuYrmhzBrF0sf0uqp7(xBOQ862sNqcVbWc2uuNXCkoYQBOslvkJbGGE29V2qL1nAjqQ30m(uR9WcEncoqQ3eilVfGPco43gAB0OfE2LEyzj)PEy5rIH7Wgall5pfQqX82qvT0xJP(8ZFQbWOLaPEtZ4tT2dl41i4aPEtdQzFKLuOqxlIVPao)iXWDdvAbVgbhi1BcKL3cWubh8BdvAbVgbhi1BAqn7JSKcf6Ar8nfqb7hzJabmJbGgABbVgbhi1BAqn7JSKcf6Ar8nfqb7hzJa5DAQHknA0YEx3dlbs9MMXNAThwWRrWbs9Maz5TamvWb)2qLRRA0sGuVP5cyof1EyH1usXN4kUHQBbZQxtVcnPzSGnf1zmNIJS6gQCDDlSMsk5iMJSTKJgnAzZZQEy5rIH7WMXOLD1spS8iXWDyZy0YMxk9WYJed3HnJrl7DPhwcK6nnJp1ApSGxJGdK6nbYYBbyQGd(THkxx3OLaPEtZfWCkQ9WcRPKIpXvCdvUQfmREn9k0KMXc2uuNXCkoYQBOY11TWAkPKJyoY2sQanA0YU6QEy5rIH7WMXOLD9spS8iXWDyZy0YEVQhwcK6nnJp1ApSGxJGdK6nbYYBbyQGd(THkxx3OLaPEtZfWCkQ9WcRPKIpXvCdvUQfmREn9k0KMXc2uuNXCkoYQBOY11TWAkPKJyoY2sQanA0cp7ThwwYFQhwEKy4oSbWYs(tHkumVnuvl91yQp)8NAamAjqQ30m(uR9WcEncoqQ30GA2hzjfk01I4BkGZpsmC3qLwWRrWbs9Maz5TamvWb)2qLwWRrWbs9MguZ(ilPqHUweFtbuW(r2iqaZyaOH2wWRrWbs9MguZ(ilPqHUweFtbuW(r2iqENMAOsJgTSRU9WsGuVPz8Pw7Hf8AeCGuVjqwElatfCWVn02OLhjgUdBgJw28S9WsGuVPz8Pw7Hf8AeCGuVjqwElatfCWVn02OrlBEz7HLaPEtZ4tT2dl41i4aPEtGS8waMk4GFBOTrJwk3LEy5rIH7WMXOrle8cfdh2ay0cwrLUfqNbgWkdewQXBZ3sKu3snL6ToVClubcm1w4Tc4CHEfAYSQqB0ga",
    },

    ["Classic"] = {
        author = "dernPerkins",
        description = "No situations enabled, just ActionCam",
        importString = "dKdxpaGEc2fKQSniLMPusLzRKBsi3wLdJANQQ9k2nj)wYpPsv)LkACuPY0uidfQQVbPQy4sLoOuLttvhJkCoPQAHeQLkLuAXsXYj1dHu5PuEmrpxrtukXuvQjRGPJCrOOUkKQsptH66sP2iKSvQu2mKITdfULusgMQ8zi(UuvmsPQ0YGsJMkz8sfNekYzLskUgu58qvUmyTsjv9AivvhhzhRRUqJFbzhBaqd3ErOddwpZogbtYPKpqZBwJaeQs2EIjfbAwsywXnliFhXiysoL8bAUVapiQWaoqrgPbfc5kFhXiysoL8bAEZAeGqvY2tmRGdpmR4MfKVJyemjNs(anVzncqOkz7jMvWHNrAqHqUW3tsxbfUrVrJD0poCyD3Or46hTbnTchUyemjNs(an3cEk(8s89K0v(oIrWKCk5d08M1iaHQKTNysrGMLKrAqHqUW3tsxbfUrVrJD0poCyD3Or46hTbnTchUyemjNs(an3cEk(8s89K0LyEcOkmWNhck0o(H7nU)rOpUBSd3H2(Xf00kCJIrWKCk5d08M1iaHQKTNysrGMLKrAqHqUAnCFckCJEJg7OFC4W6UrJW1pAdAAfoCXiysoL8bAEZAeGqvY2tmRGdpJ0GcHC1A4(eu4g9gn2r)4WH1DJgHRF0g00kC4cfddqp9LkFSXqJxpPwBBvAIPbwsEmGwFvx2Xaf3SGHiogpmGjLudhOOzVvFy8M5)qpCHInaOHBVi3a90xQ8DeB6P2m5l1m7yVXJZogO4MfmKMys(an3ts(snZoMqvhkpTleKf85d6UycI4ycvDI4o5J9fkuSh2XzhduCZcgstmjFGM7jjFPMzhtOQdLN2fcYc(8bDxmbrCmHQorCN8X(cfk27H2SJbkUzbdPjMKpqZ9KKVuZSJju1zarEfsSjqHcfB8dB2Xaf3SGH0etYhOz05gRNzhJGj5uYhO5wWtXNxIVNKUeZtavHb(8q(p075igbtYPKpqZTGNIpVeFpjDLVJyemjNs(an7EmaT5QAVgaD(TYb6HlgbtYPKpqZTGNIpVeFpjDjMNaQcd85HwQ(OmjVG8FO3yCHIj5d0Cpj5l1m7ycvDUXR2q(4Iju1HYt7cbzbF(GUlMGioMqvNiUt(yFXWJ7tlaIgGz(TYXlMUiMadiYRqInaiAaMXeQ6mGiVcj2eOy6IyceZs0FehkumSphzhduCZcgstmjFGMrNBSEMDmcMKtjFGMBbpfFEj(Es6k)xmcMKtjFGM7lWdIkmGduKrAqHqUY)fJGj5uYhOz3JbOnxv71aOZ)fkMKpqZ9KKVuZSJju1HYt7cbzbF(GUlMGioMqvNiUt(yFHcf79WMDmqXnlyinXK8bAUNK8LAMDmHQo34vBiF3ftOQdLN2fcYc(8bDxmbrCmHQodiYRqI5vXeQ6eXDYh7luOyoEoYoMKpqZOZnwpZogbtYPKpqZ9f4brfgWbkYinOqix5)IrWKCk5d0S7Xa0MRQ9Aa05)cfduCZcgstmjFGM7jjFPMzhtOQZnE1gYFC)XeQ6q5PDHGSGpFq3ftqehtOQZaI8kKytGIju1jI7Kp2xOqXC8EzhtYhOz05gRNzhJGj5uYhO5wWtXNxIVNKUY)fJGj5uYhO5(c8GOcd4afzKguiKR8FXiysoL8bA29yaAZv1Ena68FHIbkUzbdPjMKpqZ9KKVuZSJju15gVAd5pgxmHQouEAxiil4Zh0DXeeXXeQ6mGiVcjw1MIju1jI7Kp2xOqXC8WMDmjFGMrNBSEMDmcMKtjFGMDpgG2CvTxdGo)xmcMKtjFGM7lWdIkmGduKrAqHqUY)fJGj5uYhO5wWtXNxIVNKUY)fkMKpqZ9KKVuZSJju1HYt7cbzbF(GUlMGioMqvNiUt(yFHcf7H7LDmqXnlyinXK8bAUNK8LAMDmHQouEAxiil4Zh0DXeeXXeQ6eXDYh7luOyyFVSJj5d0m6CJ1ZSJrWKCk5d0Cl4P4ZlX3tsx5)IrWKCk5d0CFbEquHbCGImsdkeYv(VyemjNs(an7EmaT5QAVgaD(VqXK8bAUNK8LAMDmHQorCN8X(Iju15gVAd5pkgPz10t(sT9hKVJxmDrmbgqKxHeBaq0amJju1zarEfsmVkgECFAbq0amZFmAFX0fXeeXXi)byAkI7KMycvDO80UqqwWNpO7IjiIdfd6qAEMDmx(ba9ftrCOyGIBwWqAcfB8Zr2Xaf3SGH0etYhO5EsYxQz2XeQ6CJxTH8hftOQdLN2fcYc(8bDxmbrCmHQodiYRqI5vXeQ6eXDYh7luOyVhUSJbkUzbdPjMKpqZ9KKVuZSJju1HYt7cbzbF(GUlMGioMqvNbe5viX8QycvDI4o5J9fkuS34rzhduCZcgstmjFGM7jjFPMzhtOQdLN2fcYc(8bDxmbrCmHQorCN8X(cfk2dRJSJbkUzbdPjMKpqZ9KKVuZSJju1HYt7cbzbF(GUlMGioMqvNiUt(yFHcf7HwhzhduCZcgstmjFGM7jjFPMzhtOQdLN2fcYc(8bDxmbrCmHQorCN8X(cfk275i7yGIBwWqAIj5d0Cpj5l1m7ycvDO80UqqwWNpO7IjiIJju1jYRY3XlMqvNbe5viX0ScbIju1jI7Kp2xOqXEyhLDmqXnlyinXK8bAUNK8LAMDmHQouEAxiil4Zh0DXeeXXeQ6eXDYh7luOypCoYogO4MfmKMys(an3ts(snZoMqvhkpTleKf85d6UycI4ycvDI4o5J9fkuS3Bu2Xaf3SGH0etYhO5EsYxQz2XeQ6q5PDHGSGpFq3ftqehtOQtKxLVdCXeQ6mGiVcjMMviqmHQorCN8X(cfk243l7yGIBwWqAIj5d0m6CJ1ZSJrWKCk5d0Cl4P4ZlX3tsx57igbtYPKpqZBwJaeQs2EIjfbAwsywXnliFhXiysoL8bAEZAeGqvY2tmRGdpmR4MfKVJqXK8bAUNK8LAMDmHQouEctkPgoqrZ8FOhUycvDO80UqqwWNpO7IjiIJju1jI7K)4xmHQouEc)A6jFPYV)xmHQorEv(JJju15gVAd5pkMqvNbe5viXqJNcfk2d7l7yGIBwWqAIj5d0Cpj5l1m7ycvDO80UqqwWNpO7IjiIJju1jI7Kp2xOqXEJFzhduCZcgstmjFGM7jjFPMzhtOQdLN2fcYc(8bDxmbrCmHQorCN8X(cfk2BSJSJbkUzbdPjMKpqZ9KKVuZSJju1HYt7cbzbF(GUlMGioMqvNiUt(yFHcf7H2x2Xaf3SGH0etYhO5EsYxQz2XeQ6q5PDHGSGpFq3ftqehtOQte3jFSVqHcfJhWGvsyiIdfJWRleRf05e)wR7rHPwhMJP4dIHUfpNEzmUn5Q0XgaTcFqJ(9QzOea",
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
