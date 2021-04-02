# XDV NFT Protocol


## development settings

1. `ganache-cli -m "describe uncle will various ankle film brother pelican apple congress animal segment" -i 10`
2. `truffle compile`
3. `truffle migrate --network development`


## XDV NFT Protocol

XDV NFT Protocolo puede ser utilizado por cualquiera, para mint tokens de documentos NFT por medio del token XDV. Debe ser usado en combinacion con IPLD y tecnologias DID. El protocolo solo define como almacenar o anchor un archivo o cid de referencia para usar el XDV NFT como tokenizador de documentos.

Para el intercambio seguro de archivos, proponemos una integracion con Noise Protocol para el intercambio seguro de llaves y XDV Universal Wallet.


### Arquitectura

#### XDV.sol

Emite token unicos con el documento enlazado. Al quemar, un backend service libera cualquier documento previamente solicitado para un proveedor de servicio.,

Se adhiere al estandar ERC-721.

#### XDVController.sol

Administra a los Proveedores de Tokenizacion de Documentos, minting, burning y permisos adicionales, y otros metodos administrativos.

### Protocolo

#### Registro de Proveedor de Datos

Un proveedor de servicio se registra y obtiene un whitelisting para emitir monedas.

```solidity
    function registerMinter(
        string memory name, 
        address paymentAddress,
        bool userHasKyc,
        uint feeStructure)
        public
        returns (uint)
```

Ejemplo

```typescript
// Crea un proveeedor llamado "NOTARIO 9VNO - APOSTILLADO"
// con direccion de pago "0x0a2Cd4F28357D59e9ff26B1683715201Ea53Cc3b"
// no requiere pasarela de kyc
// estructura de pagos
const res = await ctrl.registerMinter(
    "NOTARIO 9VNO - APOSTILLADO",
    "0x0a2Cd4F28357D59e9ff26B1683715201Ea53Cc3b",
    false,
    new BigNumber(20 * 10e18), {
    from: accounts[1]
    }
);

```

El proveedor debe consultar la lista y eventos emitidos para obtener la lista mas actualizada de solicitudes pendientes.

#### Solicitud de Servicio

Un usuario solicita el servicio de un proveedor de datos por medio de `requestDataProviderService`

```solidity
   function requestDataProviderService(
        string memory minterDid,
        address minterAddress,
        string memory userDid,
        string memory documentURI,
        string memory description
    ) public returns(uint){
```

Ejemplo
```typescript
// minterDid: DID del Minter
// minterAddress: Direccion del Minter
// userDid: DID del usuario
// documentUri: Metadata Uri del documento
// description: descripicion
const res = await ctrl.requestDataProviderService(
    "did:ethr:" + accounts[1],
    accounts[1],
    "did:ethr:" + accounts[2],
    "https://ipfs.io/ipfs/xxxx",
    "Notariar", {
    from: accounts[2]
}
);
```

#### Mint

Un proveedor de tokenizacion, previamente registrado, `mint un token NFT` despues de elaborar la solicitud del usuario. Este proceso es similar a un envio de mensajeria express, lo llamamos `Caja Segura`, donde el sobre es el NFT y contiene los documentos encriptados/firmados almancenados en `IPLD`.

```solidity

    /**
     * @dev Mints a XDV Data Token if whitelisted
     */
    function mint(address user, string memory tokenURI)
        public
        returns (uint256)
    {
```

#### Burn

El usuario recibe el token XDV NFT y procede a `burn` o quemarlo en el protocolo XDV NFT. Este proceso es donde se paga por el servicio de envio de `Caja Segura`, es decir, el usuario en la accion de quemar, se le solicita pago previo para habilitar sus documentos.

```solidity
    function burn(
        uint256 requestId,
        address dataProvider,
        uint256 tokenId
    ) public returns (bool) 
```

```typescript
await ctrl.burn(
    id,
    documentMinterAddress,
    1, {
    from: accounts[2]
    }
)
```

### Redes

#### BSC Testnet

- `XDVController.sol`: **0xDC24EAe130164B900F4784b494aba906F62A3C86**
- `XDV.sol`: **0xA3965469419721587993Cec23F5228eF36DB5846**
- `USDC.sol`: **0x90dfB53185D33cf556A2fF94eBF85EB4e1bAfc6F**

### Encriptacion por medio de SSS  y Key Exchange

```
1. Cuando solicita, `XDV Universal Wallet` crea 2 `Secret Shamir Sharing` shares, uno se almacena
en la wallet del usuario y la otra en la solicitud.
2. Cuando el minter crea el NFT, encripta documentos despues de realizar un key exchange por medio del protocolo Noise.
3. Cuando el usuario burn, XDV NFT smart contracts verifica 
a) Que el share de Alicia y el share del smart contract son verificables
b) Si los shares no son verificables, no es posible continuar
c) Si lo es, se realiza el cobro del servicio y se completa
4. Una vez Alicia verifique que el documento es valido, realiza un key exchange por medio del protocolo Noise y desencripta el documento.


```

## Copyright IFESA 2021, Rogelio Morrell C., Luis Sanchez, Ruben Guevara