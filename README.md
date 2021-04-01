# XDV NFT Protocol


## development settings

1. `ganache-cli -m "describe uncle will various ankle film brother pelican apple congress animal segment" -i 10`
2. `truffle compile`
3. `truffle migrate --network development`


## XDV NFT Protocol

XDV NFT Protocolo puede ser utilizado por cualquiera, para mint tokens de documentos NFT por medio del token XDV. Debe ser usado en combinacion con IPLD y tecnologias DID. El protocolo solo define como almacenar o anchor un archivo o cid de referencia para usar el XDV NFT como tokenizador de documentos.

### Arquitectura

#### XDV NFT Token

Emite token unicos con el documento enlazado. Al quemar, un backend service libera cualquier documento previamente solicitado para un proveedor de servicio.,

Se adhiere al estandar ERC-721.

#### XDV Controller

Administra a los Proveedores de Tokenizacion de Documentos, minting, burning y permisos adicionales, y otros metodos administrativos.

### Registro y Whitelist de Proveedores de Tokenizacion de Documentos

1. Un proveedor de servicio se registra y obtiene un whitelisting para emitir monedas.

```solidity
    function registerMinter(
        address minter,
        string memory name, 
        address paymentAddress,
        bool userHasKyc,
        uint feeStructure)
        public
        returns (uint)
```

>Nota: En esta V1 del sistema en `testnet` no se aplicara KYC a los proveedores. Para `mainnet` el whitelisting no sera automatico y es posible requiera previo KYC.

2. El proveedor debe consultar la lista y eventos emitidos para obtener la lista mas actualizada de solicitudes pendientes.

### Solicitudes

1. Un usuario solicita el servicio de un proveedor de datos por medio de `requestDataProviderService`

```solidity
   function requestDataProviderService(
        string memory minterDid,
        address minterAddress,
        string memory userDid,
        string memory documentURI,
        string memory description
    ) public payable returns(uint){
```

2. Un proveedor de tokenizacion, previamente registrado, `mint un token NFT` despues de elaborar la solicitud del usuario. Este proceso es similar a un envio de mensajeria express, lo llamamos `Caja Segura`, donde el sobre es el NFT y contiene los documentos encriptados/firmados almancenados en `IPLD`.

```solidity

    /**
     * @dev Mints a XDV Data Token if whitelisted
     */
    function mint(address user, string memory tokenURI)
        public
        returns (uint256)
    {
```

3. El usuario recibe el token XDV NFT y procede a `burn` o quemarlo en el protocolo XDV NFT. Este proceso es donde se paga por el servicio de envio de `Caja Segura`, es decir, el usuario en la accion de quemar, se le solicita pago previo para habilitar sus documentos.

4. El usuario espera por un determinado tiempo la notificacion de un backend donde le notifica los documentos estan disponibles. (Este paso en V1 `testnet` no esta disponible, en `mainnet` sera habilitador en un API).


### Encriptacion por medio de Key Exchange

```
1. Minter cuando sube el o los archivos, crea un IPLD item adicional y este va tener una o varias firmas por el minter sobre el documento y key exchange con Alicia
2. Cuando ocurre el burn, tenemos un Ecrecover ya sea ECDSA o ED25519 , sobre esa firma para ver si minter firmo. Aqui el cliente tiene que leer esa firma y subir el R,S,V del ECDSA
3. Si no firmo, no burn, no se libera. Si firmo, se cobra, se burn, se retorna el link por el evento as is, encriptado o partial anon creds.
4. Alicia solo tiene la seg que Bob firmo, por el IPLD existe otro archivo para key exchange entre Bob, obtiene la llave para desencriptar y lo realiza SOLO SI se verifica que en efecto Bob firmo
```

## Copyright IFESA 2021, Rogelio Morrell C., Luis Sanchez, Ruben Guevara