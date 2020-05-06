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
        importString = "dKejlaGiOQrrQQoLkcZIQKDbvmmeDmvyzqKNrvQPrQkxdIABKk03ivKXPIiDoveX6urbVdcY9ivuhubzHqOhQOmrOsxesXgvGpcbmssfCsfQvcPQzcb6MqQSts5NksdLuPJQIcTuvuXtfMQQCviL2QIQVQIIoRkQ0AHG6TQOu3vfLSxP)cjdgkhMyXuQhlQjJWLbBMuLptvmAvYPP41QOQztj3Mk7gPFlYWvqTCLEojth11PQ2Uk13veJxfPZRqA9keVxfr5(QiQ2VQ6E0xJH3KEglOVgeGEIVfp7wwvFnyqXOYIdwb3rPIZK11W5leffmiDRRqunsC0PgmOyuzXbRG7OuXzY6A48v1oAWGIrLfhScUJsfNjRRHZxikkyq6wxHa30eAKflOAhnyqXOYIdwb3rPIZK11W5RWjlRR5oXZ85KE6HRrXvJSbdkgvwCWk4okvCMSUgoFHOOGbPBDfIbwJAOEQgjoNeKBKfhSccNsUyyaiQgYKLBCdRYKOvdPgkd7lSjrv91G0BV7RbqfBlGO2LBqIK391aOITfqu7Ynij1X(AauX2ciQD5gEtIuFnaQyBbe1UCdssK6RrwCWkZMlRQVgmOyuzXbRm9g24k5BraB1oWbPYnYIdwzOmBsuvFngjLCZflFOAi3GnoyScDYP1UbVcvzytI(moOAh4GCJrsjxamBOEAyOLl3G0B91xdGk2warTl3GePJ(AauX2ciQD5gKEt2xJS4GvMnxwvFnyqXOYIdwz6nSXvY3Ia2QrwUCdsKj7RrwCWkZMlRQVgmOyuzXbRm9g24k5BraB1ilxUbjsK91iloyLzZLv1xdgumQS4GvMEdBCL8TiGTAKLBauX2ciQD5gEtE0xJBdmPVgavSTaIIyJBdmrZ3zdB1qQXckoTWCdmPiwUrwCWkZMlRQVgmOyuzXbRm9g24k5BraB1oAWGIrLfhSYtwpapiL9vJPmSsMrdvSTGQD0GbfJkloyLNSEaEqk7RgtzyLmh8cup8LUgoFvnYgmOyuzXbR8K1dWdszF1ykdRK5GxG6HVoxzs1okxUbjjY91iloyLzZLv1xdgumQS4GvMEdBCL8TiGTAh4Gu5gzXbRmuMnjQQVgJKsU5ILpunKBWghmwHo50A3GxHQmSjrFghuTdCqUXiPKlaMnupnm0YLBq69rFnaQyBbe1UCdKip6RbqfBlGO2LBqsQV(AKfhSYS5YQ6RbdkgvwCWktVHnUs(weWwTdCqUCJS4GvgkZMev1xJrsj3CXYhQ2H(AWghmwHo50A3GxHQmSjrFghuTdCqUXiPKlaMnupns(C5Ynijp6RrwCWkZMlRQVgmOyuzXbRm9g24k5BraB1oWb5YnYIdwzOmBsuvFngjLCZflFOAh6RbBCWyf6KtRDdEfQYWMe9zCq1oWb5gJKsUay2q90i5ZLl3Gej91xdGk2warTl3Ge5J(AauX2ciQD5gK64rFnaQyBbe1UCdVjj7RXTbM0xdGk2warrSXTbMO57SHTAi1ybfNwyUbMuel3iloyLzZLv1xdgumQS4GvMEdBCL8TiGTAhnyqXOYIdw5jRhGhKY(QXugwjZOHk2wq1oAWGIrLfhSYtwpapiL9vJPmSsMdEbQh(sxdNVQgzdgumQS4GvEY6b4bPSVAmLHvYCWlq9WxNRmPAhLBKtucdBs0gwPSy9XuxPj0pMo)X0tSuac9rVEP9JDEVU)yg6hByXSk9Zxgfo6TIduN4JrK(O)J9X(yFmJEFm9Jcbo77Z6JjuIpgke4SVpRZWyvCLMq1)joXhJVa6h9FSp2h7J9X(yFSpM6knH(X05pgV(ac9r)h7J9X(yFSp2h7JzVGCEe6J(p2h7J9XakXh9aL4J(fy)L(Xql1WO5uJIv6hpD4m(t8XekXhdTudpwHwQH1pE6Wz8E9XWZY6by8N4JjuIpM6knHIqnGtHSpdtPJPgUbFzu4O3koq9X05p2jdpci7Auj6mzyjByZnGRrnSLm6GvCaEV(y4ruONFWkoaVxFm8Od28Lq5bR4a8E9XWJajLYm8GvCaEV(y4Nzjk1Bfdf2bR4a8E9XWFg9bfpyfhG3Rpg(XohSktIoyfhG3Rpg(H8ZSjrhSIdW71hd)zklXMSHbR4a8E9XWJO4HMOik0ZpyfhCG)K3aUbkR6RAhN0gdH2zVXt1qPdtrBGguZqWPbAWTAh6uJHq7S34PAO0HPOnqdQqhMEMLl3ajsY(ACBGj91aOITfqueBCBGjA(oByRM3nwqXPfMBGjfXYnYIdwzOmBsuvFnyJdgRqNCATBmSHZx4cEwauv7a5gBIfgkIngjLCZflFOA6RXOYeCbplaQQHKor2ytSWqamBOEAqaEwaungjLCbWSH6PHc4g8kuLHnj6Z4GQDuUrwCWkZMlRQVgmOyuzXbRm9g24k5BraB1ilxUXbjzFnaQyBbe1UCdsDKSVgzXbRmBUSQ(AWGIrLfhSY0ByJRKVfbSvJSC5ghKh91aOITfqu7YLBONzv854tRDJfKmBUbeoLC91aOITfqueBieeJP5fCaLvv7ahKB4Ktr4uY9moOAK4C0qiigtZl4akRgYAImQQAKnm08qee4A0tpybAgQgsLBie3cndefXYn4rhgAG7mu6EothmgbrtdQ4GgiOpHXx9XMy4Rp2TbMOAi(8vABGG(egFf6KtnoFv5wa",
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
