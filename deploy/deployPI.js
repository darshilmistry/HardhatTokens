module.exports = async function ({deployments, getNamedAccounts}) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts() 

    const name = "PayCoin"
    const symbol = "PAC"

        log("Deploying PaymentInterface>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        const PI = await deploy("PaymentInterface", {
            contract: "PaymentInterface",
            from: deployer,
            args: [name, symbol],
            log: true
        })
        log(PI.address + ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        log("Deployed PaymentInterface>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        
}

module.exports.tags = ["all", "PaymentInterface"]