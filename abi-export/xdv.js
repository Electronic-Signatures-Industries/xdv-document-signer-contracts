module.exports = {"VERSION":"1.0.0","XDVDocumentAnchoring":{"raw":{"abi":[{"inputs":[{"internalType":"address","name":"tokenAddress","type":"address"}],"stateMutability":"nonpayable","type":"constructor","signature":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":true,"internalType":"string","name":"userDid","type":"string"},{"indexed":false,"internalType":"string","name":"documentURI","type":"string"},{"indexed":false,"internalType":"uint256","name":"id","type":"uint256"}],"name":"DocumentAnchored","type":"event","signature":"0x0a007e579f0793671747216eab1061026d102ff0f66e876d2edaa6277ad53e66"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"payee","type":"address"},{"indexed":false,"internalType":"uint256","name":"weiAmount","type":"uint256"}],"name":"Withdrawn","type":"event","signature":"0x7084f5476618d8e60b11ef0d7d3f06914655adb8793e28ff7f018d4c76d505d5"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"accounting","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x991edf3f"},{"inputs":[],"name":"fee","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0xddca3f43"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"minterDocumentAnchorCounter","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x7efa0456"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"}],"name":"minterDocumentAnchors","outputs":[{"internalType":"address","name":"user","type":"address"},{"internalType":"string","name":"userDid","type":"string"},{"internalType":"string","name":"documentURI","type":"string"},{"internalType":"string","name":"description","type":"string"},{"internalType":"uint256","name":"timestamp","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x2d2103c1"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"multiApprovalDocumentAnchors","outputs":[{"internalType":"address","name":"user","type":"address"},{"internalType":"string","name":"userDid","type":"string"},{"internalType":"string","name":"documentURI","type":"string"},{"internalType":"string","name":"description","type":"string"},{"internalType":"uint256","name":"timestamp","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x943053c5"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x8da5cb5b"},{"inputs":[],"name":"stablecoin","outputs":[{"internalType":"contract IERC20","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true,"signature":"0xe9cbd822"},{"inputs":[{"internalType":"address","name":"tokenAddress","type":"address"}],"name":"setStableCoin","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x23af4e17"},{"inputs":[{"internalType":"address payable","name":"payee","type":"address"}],"name":"withdraw","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x51cff8d9"},{"inputs":[{"internalType":"address payable","name":"payee","type":"address"},{"internalType":"address","name":"erc20token","type":"address"}],"name":"withdrawToken","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x3aeac4e1"},{"inputs":[{"internalType":"uint256","name":"_fee","type":"uint256"}],"name":"setProtocolConfig","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x2f8d845a"},{"inputs":[],"name":"getProtocolConfig","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0xed700b3e"},{"inputs":[{"internalType":"uint256","name":"docid","type":"uint256"},{"internalType":"string","name":"userDid","type":"string"},{"internalType":"string","name":"documentUri","type":"string"},{"internalType":"bool","name":"isComplete","type":"bool"}],"name":"peerSigning","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"payable","type":"function","payable":true,"signature":"0x195543a5"},{"inputs":[{"internalType":"string","name":"userDid","type":"string"},{"internalType":"string","name":"documentURI","type":"string"},{"internalType":"string","name":"description","type":"string"},{"internalType":"address[]","name":"whitelist","type":"address[]"}],"name":"addDocument","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"payable","type":"function","payable":true,"signature":"0x1feb9e2a"}]},"address":{"bsc-fork":"0xBD4259Ecaa508140aac3c142deE6Efa8e5eB2f7b","bsc":"0xBD4259Ecaa508140aac3c142deE6Efa8e5eB2f7b"}}}