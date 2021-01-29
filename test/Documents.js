// const assert = require("assert");
const Web3 = require('web3');
const web3 = new Web3();
const BigNumber = require('bignumber.js');

contract('Documents', accounts => {
  let owner;
  let supplierAddr;
  let debtorAddr;
  let custodian;
  let DocumentContract = artifacts.require('Documents');
  let editor;
  let ApprovalContract = artifacts.require('Approvals');
  let signers;
  let approvalCtr;
  let limits;
  let minimumSigners = 2;

  contract('#documents', () => {
    before(async () => {
      signers = [
        accounts[0],
        accounts[2], // debtorAddr
        '0xda31d24d6008f35cb87dbc492accce50dcfe5675'
      ];

     // approvalCtr = await ApprovalContract.deployed();
      owner = accounts[0];
      editor = '0xea817a76993ae9cd3a706ff9d4e6d96a581838db';

      // await contract.addACL(owner, 0); // add owner as admin

      limits = [1000, 100, 1000];

      // assert.equal(approvalCtr !== null, true);

      contract = await DocumentContract.deployed();
      owner = accounts[0];
      supplierAddr = accounts[1];
      debtorAddr = accounts[2];
      custodian = accounts[3];
      await contract.addACL(editor, 1, { from: owner }); // add supplier

      //  await contract.addACL(owner, 0); // add owner as admin
      await contract.addACL(supplierAddr, 1); // add supplier
      await contract.addACL(signers[0], 2); // add debtor
      await contract.addACL(signers[1], 2); // add debtor
      await contract.addACL(signers[2], 2); // add debtor
      await contract.addACL(custodian, 3); // add custodian

      assert.equal(contract !== null, true);
    });
    describe('when supplier invoices', () => {
      it('should create a new invoice', async () => {
        assert.equal(contract !== null, true);
        const toString = txt => web3.utils.fromUtf8(txt);
        const toWei = usd => new BigNumber(usd);
        const payload = {
          id: toString('urn:supplier:SUPERXYZ:1000'),
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

        assert.equal(!!ok.tx, true);
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
