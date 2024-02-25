pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import "../src/core/ClientChainGateway.sol";
import "../src/core/Vault.sol";
import "../src/core/ExocoreGateway.sol";
import "../src/interfaces/precompiles/IDelegation.sol";
import "../src/interfaces/precompiles/IDeposit.sol";
import "../src/interfaces/precompiles/IWithdrawPrinciple.sol";
import "../src/interfaces/precompiles/IClaimReward.sol";
import "../test/mocks/NonShortCircuitLzEndpointMock.sol";
import "@layerzero-contracts/interfaces/ILayerZeroEndpoint.sol";
import "../src/storage/GatewayStorage.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

contract DeployScript is Script {
    Player[] players;
    Player depositor;
    Player clientChainDeployer;
    Player exocoreDeployer;
    Player relayer;
    Player exocoreValidatorSet;

    string clientChainRPCURL;
    string exocoreRPCURL;

    ERC20PresetFixedSupply restakeToken;

    ClientChainGateway clientGateway;
    Vault vault;
    ExocoreGateway exocoreGateway;
    ILayerZeroEndpoint clientChainLzEndpoint;
    ILayerZeroEndpoint exocoreLzEndpoint;

    uint16 exocoreChainId = 0;
    uint16 clientChainId = 101;
    uint256 clientChain;
    uint256 exocore;
    uint constant DEFAULT_ENDPOINT_CALL_GAS_LIMIT = 200000;
    uint256 constant DEPOSIT_AMOUNT = 10000;

    struct Player {
        uint256 privateKey;
        address addr;
    }
    
    function setUp() public {
        clientChainDeployer.privateKey = vm.envUint("TEST_ACCOUNT_ONE_PRIVATE_KEY");
        clientChainDeployer.addr = vm.addr(clientChainDeployer.privateKey);

        exocoreDeployer.privateKey = vm.envUint("TEST_ACCOUNT_TWO_PRIVATE_KEY");
        exocoreDeployer.addr = vm.addr(exocoreDeployer.privateKey);

        exocoreValidatorSet.privateKey = vm.envUint("TEST_ACCOUNT_THREE_PRIVATE_KEY");
        exocoreValidatorSet.addr = vm.addr(exocoreValidatorSet.privateKey);
        
        depositor.privateKey = vm.envUint("TEST_ACCOUNT_FOUR_PRIVATE_KEY");
        depositor.addr = vm.addr(depositor.privateKey);

        relayer.privateKey = vm.envUint("TEST_ACCOUNT_FOUR_PRIVATE_KEY");
        relayer.addr = vm.addr(relayer.privateKey);

        clientChainRPCURL = vm.envString("SEPOLIA_RPC");
        exocoreRPCURL = vm.envString("EXOCORE_TESETNET_RPC");

        string memory deployedContracts = vm.readFile("script/deployedContracts.json");

        clientGateway = ClientChainGateway(payable(stdJson.readAddress(deployedContracts, ".clientChain.clientChainGateway")));
        clientChainLzEndpoint = ILayerZeroEndpoint(stdJson.readAddress(deployedContracts, ".clientChain.lzEndpoint"));
        restakeToken = ERC20PresetFixedSupply(stdJson.readAddress(deployedContracts, ".clientChain.erc20Token"));
        vault = Vault(stdJson.readAddress(deployedContracts, ".clientChain.resVault"));

        exocoreGateway = ExocoreGateway(payable(stdJson.readAddress(deployedContracts, ".exocore.exocoreGateway")));
        exocoreLzEndpoint = ILayerZeroEndpoint(stdJson.readAddress(deployedContracts, ".exocore.lzEndpoint"));

        // transfer some gas fee to depositor, relayer and exocore gateway
        clientChain = vm.createSelectFork(clientChainRPCURL);
        address alexTest = 0x41B2ddC309Af448f0B96ba1595320D7Dc5121Bc0;
        vm.startBroadcast(exocoreValidatorSet.privateKey);
        if (restakeToken.balanceOf(alexTest) < 1000e18) {
            restakeToken.transfer(alexTest, 1000e18);
        }
        vm.stopBroadcast();
    }

    function run() public {
    
    }
}