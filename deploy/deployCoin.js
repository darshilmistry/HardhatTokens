module.exports = async function ({deployments, getNamedAccounts}) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts() 

    const name = "GeekCoin"
    const symbol = "GEC"

        log("Deploying Coin>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        const Coin = await deploy("Coin", {
            from: deployer,
            args: [name, symbol],
            log: true
        })
        log(Coin.address + ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        log("Coin Deployed>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")

}

module.exports.tags = ["all", "coin"]