const { mineUpTo } = require("@nomicfoundation/hardhat-network-helpers")
const { expect, assert } = require("chai")
const { getNamedAccounts, deployments, ethers } = require( "hardhat" )


describe("Coin Tests", () => {

    let coin, _deployer, _tester

    describe("Constructor", () => {
        
        beforeEach(async() => {
                const { deployer, tester } = await getNamedAccounts()
                _deployer = deployer
                _tester = tester
                await deployments.fixture([ "all" ])

                coin = await ethers.getContract("Coin", deployer)
        })

        it("should initialize the owner as deployer", async () =>{
            const expected = String( _deployer )
            const tested = String(await coin.whoIsOwner())
            
            expect(tested).to.equal(expected)
        })

    })

    describe("Mint tokens", () => {

        it("should generate an acknowledgement whenever anyone  calls the function", async() => {
            expect(await coin.mintCoin("100")).to.emit("Coin_AtemptToUpdateSupply")
        })

        it("should add 100 tokens in the deployers account", async () => {
            const initialBalance = await coin.balanceOf(_deployer)
            await coin.mintCoin(100)
            const finalBalance = await coin.balanceOf(_deployer)
            expect(finalBalance).to.be.greaterThan(initialBalance)
        })

        it("Should emit an event on successful minting", async () => {
            expect(await coin.mintCoin(100)).to.emit("Coin_SupplyAltered")
        })

        it("should fail on getting called by tester", async () => {
            const testersCoin = await ethers.getContract("Coin", _tester)
            expect(await testersCoin.mintCoin(100)).to.be.revertedWith("Coin__trespassing")
        })

    })

    describe("Burn tokens", () => {

        it("should generate an acknowledgement whenever anyone  calls the function", async() => {
            expect(await coin.mintCoin("100")).to.emit("Coin_AtemptToUpdateSupply")
        })

        it("should add 100 tokens in the deployers account", async () => {
            const initialBalance = await coin.balanceOf(_deployer)
            await coin.burnCoins(100)
            const finalBalance = await coin.balanceOf(_deployer)
            expect(initialBalance).to.be.greaterThan(finalBalance)
        })

        it("Should emit an event on successful minting", async () => {
            expect(await coin.mintCoin(100)).to.emit("Coin_SupplyAltered")
        })

        it("should fail on getting called by tester", async () => {
            const testersCoin = await ethers.getContract("Coin", _tester)
            expect(await testersCoin.mintCoin(100)).to.be.revertedWith("Coin__trespassing")
        })

    })

    describe("transfer", () => {

        let testersCoin, reciever

        beforeEach(async() => {
            const signers = await ethers.getSigners()
            testersCoin = await ethers.getContract("Coin", _tester)
            reciever = signers[5]
        })

        it("Should revert with invalid reciever address", async() => {
            const invalidReciever = 0x91F79Bf6EB2c4F970365E785982E1f101e03b906
            expect(testersCoin.transfer(_tester.address, invalidReciever, 3)).to.be.revertedWith("Coin__invalidAddress")
        })

        // todo check posetive

    })

    describe("")

})