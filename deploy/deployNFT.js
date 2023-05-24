module.exports = async function ({deployments, getNamedAccounts}) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts() 

    const name = "GeekToken"
    const symbol = "GTC"

        log("Deploying NFT>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        const NFT = await deploy("NFT", {
            from: deployer,
            args: [name, symbol],
            log: true
        })
        log(NFT.address + ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        log("NFT Deployed>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")

}

module.exports.tags = ["all", "nft"]