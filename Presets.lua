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
        importString = "dqdcjaGEus7caBJKeZKKuMnjUPIu3gv7eK9sTBH(jq8xG63IAOkPgUKsoOePJjjNtsPAHa0sLuklgulxQhQO8uIhl45KAIaPPQWKrX0HUOsIomYLvDDjSruITssTzfjBxj(mk13ijPPPK03vunmL60ImAanEjfNuI6SKKQRjP68seltrSwLeEgjXUYdl1QZtLuUhwy(uuHcoBHAThwWRrWbI)MaTKiXtH1jmaeqsFwYlRjgdTbqvTGxJGde)nbAjrINcRtyaOHQSGxJGde)nbAjrINcRtyaiGK(SKxwtmGMNhLaPCdvzbVgbhi(Bc0sIepfwNWaqHtnUoTKXzfyEQPanPrdTTGxJGde)nbAjrINcRtyaiGK(SKxwtmSOuskY2qBaQ96wce)nTICMl16NXq13gTS8wNYrdnXsFkGPLVICM7HLhjyLZyaTqmmLJH(8hrTHQaOUfovZkYz(iXVH2auzHyykhd95pI6svMtLOn02skgkLHb00ut9(XWn0eJwMk1AS2kIg2IoHfeMYrThw2QOIhwEKGvoJHnAzprfpS8ibRCgdB0YERkEy5rcw5mg2Ofv2t8WYJeSYzmSrl79epSei(BAMAQ1EybVgbhi(BcKL3cWCHcZBdvbWeJwce)nvAat5O2dlSMZC1KsXnuDlytrDct54iXVHQaOUfmXFz90ung2cR5mxoIPiBlPOrJw2QY2dlbI)MMPMAThwWRrWbI)Maz5TamxOW82qBJgTSvPYdlpsWkNXWgTSvz7HLaXFtZutT2dl41i4aXFtGS8waMluyEBOTrJw213Eyjq830m1uR9WcEncoq83eilVfG5cfM3gAB0OL9KThwce)nntn1ApSGxJGde)nbYYBbyUqH5TH2gT8ibRCgdB0Ik7kpSSK(CpS8ibRCgdOLL0NdvWHFBOjw6RXCF1Pp3aA0sG4VPzQPw7Hf8AeCG4VjqwElaZfkmVnuLf8AeCG4VPb1SpYsouOlhX3uaxzKGvUHQSGxJGde)nnOM9rwYHcD5i(McOG9JSrGRtyaOH2wWRrWbI)MguZ(il5qHUCeFtbuW(r2iqvNMBOkJgTS319WsG4VPzQPw7Hf8AeCG4VjqwElaZfkmVnufatmAjq83uPbmLJApSWAoZvtkf3q1TGnf1jmLJJe)gQcG6wWe)L1tt1yylSMZC5iMISTKIgnAzRYQEy5rcw5mg2OLj7kpS8ibRCgdB0YEVQhwce)nntn1ApSGxJGde)nbYYBbyUqH5THQaOUrlbI)MknGPCu7HfwZzUAsP4gQAvlytrDct54iXVHQaOUfmXFz90ung2cR5mxoIPiBl5c0Orl7DLhwce)nntn1ApSGxJGde)nbYYBbyUqH5THQaOUrlbI)MknGPCu7HfwZzUAsP4gQAvlytrDct54iXVHQaOUfmXFz90ung2cR5mxoIPiBl5c0Orl7jR6HLhjyLZyyJw21R8WYJeSYzmSrlBvPYdlpsWkNXWgTOYE7HLL0N7HLhjyLZyaTSK(COco8BdnXsFnM7Ro95gqJwce)nvAat5O2dlyI)Y6PPAmSrlbI)MMPMAThwWRrWbI)Maz5TamxOW82qvwWRrWbI)MguZ(il5qHUCeFtbCLrcw5gQYcEncoq830GA2hzjhk0LJ4BkGc2pYgbUoHbGgABbVgbhi(BAqn7JSKdf6Yr8nfqb7hzJavDAUHQmA0YK92dllPp3dlpsWkNXaAzj95qfC43gsfl91yUV60NBanAjq83uPbmLJApSGj(lRNMQXWwQvcdab9S7FTHQQBPZiH3aAH1CMRMukUHw1sj0Cqp7(xBOjQ62sNrcVCetr2wyo7(xBH1CMlhXuKTf9rlytrDct54iXVHQmAjq830m1uR9WcEncoq83eilVfG5cfM3gAB0OLQ92dlpsWkNXWgTuTR8WYJeSYzmSrl7jvEy5rcw5mg2OrleZcfdNXaA0cwsTUfqNbEDTbclLvTvAjs8BPmN)wNwUfQabMBlQwbtQqpnvtIxOnAd",
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
