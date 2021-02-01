# nft-document-swap
NFT &lt;> Document Swap

Cuando el evento de Burn se emite, llega una notificacion al API
El API desbloquea el evento de IPLD y hace una copia
Despues la copia de IPLD va a ejecutar una accion llamada "onSetToLockDocument" 
    y emite un evento "DocumentUnlock" el cual va a contar con el nuevo hash
El usuario recibe la notificacion en websocket y puede bajar el archivo con su DID

Poner status del flujo de Document anchoring
## development settings

1. `ganache-cli -m "describe uncle will various ankle film brother pelican apple congress animal segment" -i 10`
2. `truffle compile`
3. `truffle migrate --network development`
