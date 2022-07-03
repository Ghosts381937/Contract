//For remix
const { expect } = require("chai")

var accounts

const deploy = async (contractName, constructorArgs) => {
    // Note that the script needs the ABI which is generated from the compilation artifact.
    // Make sure contract is compiled and artifacts are generated
    const artifactsPath = `browser/contracts/artifacts/${contractName}.json` // Change this for different path

    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))

    let contract = new web3.eth.Contract(metadata.abi)

    contract = contract.deploy({
        data: metadata.data.bytecode.object,
        arguments: constructorArgs
    })

    const contractInstance = await contract.send({
        from: accounts[0],
        gas: 1500000,
        gasPrice: '30000000000'
    })
    //console.log(contractName + ' Contract deployed at address: ' + contractInstance.options.address)
    return contractInstance
}
(async () => { 
    try {
        console.log('Running deployWithWeb3 script...')
        accounts = await web3.eth.getAccounts()
        var Token = await deploy('Token', [web3.utils.toWei('1', 'ether')])
        var Major = await deploy('Major', [Token.options.address])
        var dungeon = [
            {
                cost: web3.utils.toWei('0.01', 'ether'), 
                numbersOfOriginEnemy : ['100'],
                numbersOfEnemyOnSingleDungeon : ['10'] }, 
        ]
        //unit test
        describe('Token', async() => {
            let allowanceValue = web3.utils.toWei('100', 'ether')
            it('approve()', async() => {
                await Token.methods.approve(Major.options.address, allowanceValue)
                .send({
                    from: accounts[0]
                })
                await Token.methods.allowance(accounts[0], Major.options.address).call()
                .then((result) => {
                    expect(result).to.equal(allowanceValue)
                })
            })
        })
        describe('Major', async() => {
            it('createDungeon()', async() => {
                await Major.methods.createDungeon(dungeon[0].cost, dungeon[0].numbersOfOriginEnemy, dungeon[0].numbersOfEnemyOnSingleDungeon)
                .send({
                    from: accounts[0]
                })
                await Major.methods.dungeonOf(0).call()
                .then((result) => {
                    delete result[0]
                    delete result[1]
                    delete result[2]
                    delete result[3]
                    delete result.numbersOfRemaingEnemy
                    expect(result).to.deep.equal(dungeon[0])
                })
            })
            it('init()', async() => {
                let playerName = 'test'
                await Major.methods.init(playerName)
                .send({
                    from: accounts[0]
                })
                await Major.methods.playerStatusOf(accounts[0]).call()
                .then((result) => {
                    expect(result.name).to.deep.equal(playerName)
                })
            })
            it('enterDungeon()', async() => {
                let originBalance;
                await Token.methods.balanceOf(accounts[0]).call()
                .then((result) => {
                    originBalance = result
                })
                await Major.methods.enterDungeon('0')
                .send({
                    from: accounts[0]
                })
                await Token.methods.balanceOf(accounts[0]).call()
                .then((result) => {
                    expect(result).to.deep.equal((originBalance - dungeon[0].cost).toString())
                })
            })
        })
        
    } catch (e) {
        console.log(e.message)
    }
  })()
