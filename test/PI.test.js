const { expect, assert } = require("chai")
const { getNamedAccounts, deployments, ethers } = require( "hardhat" )


describe("PI Tests", () => {

    let PI, _deployer, _tester

    describe("Constructor", () => {
        
        beforeEach(async() => {
                const { deployer, tester } = await getNamedAccounts()
                _deployer = deployer
                _tester = tester
                await deployments.fixture([ "all" ])

                PI = await ethers.getContract("PaymentInterface", deployer)
        })

        it("should initialize the owner as deployer", async () =>{
            const expected = String( _deployer )
            const tested = String(await PI.whoIsOwner())
            
            expect(tested).to.equal(expected)
        })

    })

    describe("Mint tokens", () => {

        it("should generate an acknowledgement whenever anyone  calls the function", async() => {
            expect(await PI.mintCoins("100")).to.emit("PI_AtemptToUpdateSupply")
        })

        it("should add 100 tokens in the deployers account", async () => {
            const initialBalance = await PI.balanceOf(_deployer)
            await PI.mintCoins(100)
            const finalBalance = await PI.balanceOf(_deployer)
            expect(finalBalance).to.be.greaterThan(initialBalance)
        })

        it("Should emit an event on successful minting", async () => {
            expect(await PI.mintCoins(100)).to.emit("PI_SupplyAltered")
        })

        it("should fail on getting called by tester", async () => {
            const testersPI = await ethers.getContract("PaymentInterface", _tester)
            await expect(testersPI.mintCoins(100)).to.be.revertedWith("PI__trespassing")
        })

    })

    describe("Burn tokens", () => {

        it("should generate an acknowledgement whenever anyone  calls the function", async() => {
            expect(await PI.burnCoins("25")).to.emit("PI_AtemptToUpdateSupply")
        })

        it("should add 100 tokens in the deployers account", async () => {
            const initialBalance = await PI.balanceOf(_deployer)
            await PI.burnCoins("25")
            const finalBalance = await PI.balanceOf(_deployer)
            expect(initialBalance).to.be.greaterThan(finalBalance)
        })

        it("Should emit an event on successful minting", async () => {
            expect(await PI.burnCoins(25)).to.emit("PI_SupplyAltered")
        })

        it("should fail on getting called by tester", async () => {
            const testersPI = await ethers.getContract("PaymentInterface", _tester)
            await expect(testersPI.burnCoins(10)).to.be.revertedWith("PI__trespassing")
        })

    })

    describe("transfer", () => {

        let testersPI, reciever, tester

        beforeEach(async() => {
            const signers = await ethers.getSigners()
            reciever = signers[5].address
            tester = signers[4].address
            testersPI = await ethers.getContract("PaymentInterface", tester)
        })

        it("Should allow a good transfer", async() => {
            expect(await testersPI.transfer(reciever, 3))
        })

        it("should corectly alter the balances", async () => {
            const IBS = await PI.balanceOf(tester)
            const IBR = await PI.balanceOf(reciever)

            await testersPI.transfer(reciever, 5)

            const FBS = await PI.balanceOf(tester)
            const FBR = await PI.balanceOf(reciever)

            expect(IBS).to.be.greaterThan(FBS)
            expect(IBR).to.be.lessThan(FBR)

            console.log("IBS: " + IBS )
            console.log("IBS: " + IBR )
            console.log("IBS: " + FBS )
            console.log("IBS: " + FBR )

        })

        // Test inoperationsal Fix IT 
        // it("Should emit transfer event", async() => {
        //     const expectedArgs = [tester, reciever, 120]
        //     expect(await testersPI.transfer(tester, reciever, 10)).to.emit(testersPI, "Transfer").withArgs(expectedArgs)
        // })
    })

    describe("Allowances", () => {
        
        let owner, spender, testersPI, receiver, spendersPI

        beforeEach(async () => {
            const signers = await ethers.getSigners()
            owner = signers[2].address
            spender = signers[5].address
            receiver = signers[9].address
            spendersPI = await ethers.getContract("PaymentInterface", spender)
            testersPI = await ethers.getContract("PaymentInterface", owner) 
        })

        it("should emit event before approval", async () => {
            await expect(testersPI.approve(spender, 10)).to.emit(testersPI, "PI_AttemptToapprove").withArgs(owner, spender)
        })
        
        it("should emit event after approval", async () => {
            await expect(testersPI.approve(spender, 10)).to.emit(testersPI, "Approval").withArgs(owner, spender, 20)
        })

        it("should update allowances", async () => {
            expect(await testersPI.allowance(owner, spender)).to.equal(20)
        })

        it("should allow spender to spend", async() => {
            expect(await spendersPI.transferFrom(owner, receiver, 20)).to.emit(spendersPI, "PI_AllowanceSpent").withArgs(owner, spender, 20)
        })

        it("should not allow spender to overspend", async() => {
            await expect(spendersPI.transferFrom(owner, receiver, 1)).to.be.revertedWithCustomError(spendersPI, "PI__attemptToOverspendAllowances")
        })

    })

})