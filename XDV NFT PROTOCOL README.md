# XDV NFT PROTOCOL

👋 Bienvenido a XDV!

XDV NFT Protocolo puede ser utilizado por cualquiera, para mint tokens de documentos NFT por medio del token XDV. Debe ser usado en combinacion con IPLD y tecnologias DID. El protocolo solo define como almacenar o anchor un archivo o cid de referencia para usar el XDV NFT como tokenizador de documentos. 

> En otras palabras, para cualquier documento verificable.

## **Arquitectura**

### **XDV NFT Token**

Emite token únicos con el documento enlazado. Al quemar, un backend service libera cualquier documento previamente solicitado para un proveedor de servicio.

Se adhiere al estándar ERC-721.

XDV  o Caja Segura hay  2 actores o personas 

 El Proveedor de Servicios de Datos y el Usuario 

Proveedor de Servicios de Datos  puede:

1. registerMinter: Registrarse como proveedor de servicios
2. Recibir solicitudes de usuarios dirigidas a su identidad digital o dirección
3. RequestMint: Solicitar acunar NFTs. Requiere estar previamente whitelisted por un backoffice admin de la plataforma.

 Usuario puede:

1. requestDataProviderService: Enviar solicitud a Proveedor de Datos. Usuario debe pagar un fee de comisión de uso del servicio inicial.
2. Mint acuna NFTs: Este proceso es después de recibir la solicitud con el documento adjunto, almacenado seguramente en IPLD.
3. Burn: Usuario realiza el 'quemado' o liberacion de los documentos. Un API backend escucha los eventos y desencripta el documento y lo guarda a IPLD con la version encriptada entre Proveedor de Datos y Usuario. El contrato inteligente cobra el servicios y comision y estos son pagados o transferidos.

### **XDV Controller**

Administra a los Proveedores de Tokenizacion de Documentos, minter, burn y permisos adicionales, y otros métodos administrativos.

### **Registro y Whitelist de Proveedores de Tokenizacion de Documentos**

1. Un proveedor de servicio se registra y obtiene un whitelisting para emitir monedas.

```jsx
   /**
    * @dev Registers a data tokenization service
    *
     */
    function registerMinter(
        address minter,
        string memory name, 
        address paymentAddress,
        bool userHasKyc,
        uint feeStructure)
        public
        returns (uint)
    {
```

> Nota: En esta V1 del sistema en testnet no se aplicara KYC a los proveedores. Para mainnet el whitelisting no sera automatico y es posible requiera previo KYC.

1. El proveedor debe consultar la lista y eventos emitidos para obtener la lista mas actualizada de solicitudes pendientes.

### **Solicitudes**

1. Un usuario solicita el servicio de un proveedor de datos por medio de `requestDataProviderService`

```jsx
  function requestDataProviderService(
        string memory minterDid,
        address minterAddress,
        string memory userDid,
        string memory documentURI,
        string memory description
    ) public payable returns(uint){
```

1. Un proveedor de tokenizacion, previamente registrado, `mint un token NFT` despues de elaborar la solicitud del usuario. Este proceso es similar a un envio de mensajeria express, lo llamamos `Caja Segura`, donde el sobre es el NFT y contiene los documentos encriptados/firmados almancenados en `IPLD`.

```jsx
    /**
     * @dev Mints a XDV Data Token if whitelisted
     */
   function mint(
       uint requestId,
       address user, 
       address dataProvider,
       string memory tokenURI
    )
        public
        returns (uint256)
```

1. El usuario recibe el token XDV NFT y procede a `burn` o quemarlo en el protocolo XDV NFT. Este proceso es donde se paga por el servicio de envío de `Caja Segura`, es decir, el usuario en la accion de quemar, se le solicita pago previo para habilitar sus documentos.

```jsx
function burn(uint requestId, uint dataProviderId, uint tokenId)
        public
        payable
        returns (bool)
    {
```

1. El usuario espera por un determinado tiempo la notificación de un backend donde le notifica los documentos están disponibles. (Este paso en V1 `testnet` no esta disponible, en `mainnet` será habilitador en un API).

**Copyright IFESA 2021, Rogelio Morrell C., Luis Sanchez, Ruben Guevara**

Visita el [Github](https://github.com/Electronic-Signatures-Industries/nft-document-swap) para conocer más sobre XDV NFT PROTOCOL