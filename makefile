compile:
	truffle compile

abigen:
	truffle run abigen

deploy-testnet:
	truffle migrate --network bsctestnet --f 4 --to 4

deploy-local:
	truffle migrate --network development --f 4 --to 4

run-truffle:
	ganache-cli -m "describe uncle will various ankle film brother pelican apple congress animal segment" -i 10