compile:
	truffle compile

abigen:
	truffle run abigen

deploy-testnet:
	truffle migrate --network bsctestnet --f 4 --to 4