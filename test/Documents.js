// const assert = require("assert");
const Web3 = require('web3');
const web3 = new Web3();
const BigNumber = require('bignumber.js');

contract('NFTFactory', accounts => {
  let dai;
  let owner;
  let nftFactory;
  let documents;
  let DocumentAnchoring = artifacts.require('DocumentAnchoring');
  let TestDAI = artifacts.require('DAI');
  let DocumentMinter = artifacts.require('NFTDocumentMinter');
  let NFTFactory = artifacts.require('NFTFactory');
  contract('#documents', () => {
    before(async () => {
      owner = accounts[0];
      dai = await TestDAI.deployed();
      nftFactory = await NFTFactory.deployed();
      documents = await DocumentAnchoring.deployed();
    });
    describe('when creating a document issuing provider', () => {
      it('should create a new NFT', async () => {
        assert.equal(nftFactory !== null, true);

        const res = await nftFactory.createMinter(
          "NOTARIO 9VNO - APOSTILLADO",
          "NOT9APOST",
          "0x0a2Cd4F28357D59e9ff26B1683715201Ea53Cc3b",
          20*10e18
        );

        // get NFTDocumentMinter and assert
        const _owner = await contract.owner();

        // assert.equal(_owner.toLowerCase(), accounts[0].toLowerCase());
        // const ok = await contract.addDocument(
        //   id,
        //   supplier,
        //   debtor,
        //   fileIpfsJson,
        //   fechaEmision,
        //   externalId,
        //   signature,
        //   fechaExpiracion,
        //   { from: supplierAddr }
        // );

        // assert.equal(!!ok.tx, true);
      });
    });

    describe('when debtor certifies', () => {
      it('should certify invoice by debtor', async () => {
        assert.equal(contract !== null, true);
        const toString = txt => web3.utils.fromUtf8(txt);

        const payload = {
          id: toString('urn:supplier:SUPERXYZ:1000'),
          amount: 100000
        };

        const _owner = await contract.owner();
        assert.equal(_owner.toLowerCase(), accounts[0].toLowerCase());
        const ok = await contract.certifyDebtor(payload.id, payload.amount, {
          from: debtorAddr
        });
        assert.equal(!!ok.tx, true);
      });
    });

    describe('when debtor certifies', () => {
      it('should certify invoice by debtor approval', async () => {
        assert.equal(contract !== null, true);
        const toString = txt => web3.utils.fromUtf8(txt);

        const toWei = usd => new BigNumber(usd);
        const payload = {
          id: toString('urn:supplier:SUPERXYZ:2000'),
          supplier: supplierAddr,
          debtor: debtorAddr,
          fileIpfsJson: toString(JSON.stringify([{ path: '', content: '' }])),
          fechaEmision: new Date().getTime() * 1000,
          externalId: toString('10001001'),
          signature: toString('.....'),
          fechaExpiracion: new Date().getTime() * 1000
        };
        const {
          id,
          supplier,
          debtor,
          fileIpfsJson,
          fechaEmision,
          signature,
          externalId,
          fechaExpiracion
        } = payload;
        const _owner = await contract.owner();

        assert.equal(_owner.toLowerCase(), accounts[0].toLowerCase());
        const ok = await contract.addDocument(
          id,
          supplier,
          debtor,
          fileIpfsJson,
          fechaEmision,
          externalId,
          signature,
          fechaExpiracion,
          { from: supplierAddr }
        );

        let tx = await contract.addApproval(
          editor,
          signers,
          limits,
          minimumSigners,
          {
            from: owner
          }
        );
        let _id = tx.logs[0].args.id * 1;

        let res = await contract.approvals(_id, signers[0]);
        assert.equal(res.signedStatus, 0);

        // 1
        await contract.certifyDebtorApproval(_id, payload.id, 99, {
          from: signers[0]
        });

        res = await contract.approvals(_id, signers[0]);
        assert.equal(res.signedStatus, 1);

        // 2
        await contract.certifyDebtorApproval(_id, payload.id, 99, {
          from: signers[1]
        });

        res = await contract.approvals(_id, signers[1]);
        assert.equal(res.signedStatus, 1);

        // // 3
        // await contract.certifyDebtorApproval(_id, payload.id, 99, {
        //   from: signers[2]
        // });

        // res = await contract.approvals(_id, signers[2]);
        // assert.equal(res.signedStatus, 1);

        // Closed
        tx = await contract.addApproval(editor, signers, limits, minimumSigners, {
          from: owner
        });
        _id = tx.logs[0].args.id * 1;

        try {
          await contract.certifyDebtorApproval(_id, payload.id, 99, {
            from: debtorAddr
          });
        } catch (e) {
        } finally {
          res = await contract.documents(payload.id, { from: debtorAddr });
          assert.equal(res.status, 6);
        }
      });
    });

    describe('when custodian certifies', () => {
      it('should certify invoice by custodian', async () => {
        assert.equal(contract !== null, true);
        const toString = txt => web3.utils.fromUtf8(txt);

        const payload = {
          id: toString('urn:supplier:SUPERXYZ:1000'),
          trust: toString('FWLA')
        };

        const _owner = await contract.owner();
        assert.equal(_owner.toLowerCase(), accounts[0].toLowerCase());
        const ok = await contract.certifyTrust(payload.id, payload.trust, {
          from: custodian
        });
        assert.equal(!!ok.tx, true);
      });

      it('should fail if not custodian', async () => {
        assert.equal(contract !== null, true);
        const toString = txt => web3.utils.fromUtf8(txt);

        const payload = {
          trust: toString('FWLA'),
          id: toString('urn:supplier:SUPERXYZ:1000')
        };

        const _owner = await contract.owner();
        assert.equal(_owner.toLowerCase(), accounts[0].toLowerCase());

        try {
          await contract.certifyTrust(payload.id, payload.trust, {
            from: supplierAddr
          });
        } catch (e) {
          assert.throws(() => {
            throw e;
          }, Error);
        }
      });
    });
  });
});
